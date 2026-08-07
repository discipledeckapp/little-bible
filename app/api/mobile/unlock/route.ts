import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';
import { NextRequest, NextResponse } from 'next/server';

const UNLOCK_PRODUCT_ID = 'com.littlebible.unlock';

// The two stores use DIFFERENT identifiers and they must be kept separate.
// A single shared constant used to serve both, which meant neither matched:
//  - Android `applicationId`      → mobile/android/app/build.gradle.kts
//  - iOS PRODUCT_BUNDLE_IDENTIFIER → mobile/ios/Runner.xcodeproj/project.pbxproj
// Deriving one from the other by string substitution (the previous
// `BUNDLE_ID.replace(/_/g, '.')`) produced `org.littlebible.little.bible`,
// a package that does not exist, so every Android receipt failed.
const ANDROID_PACKAGE_NAME = 'org.littlebible.little_bible';
const IOS_BUNDLE_ID = 'org.littlebible.littleBible';

interface UnlockBody {
  productId?: unknown;
  transactionId?: unknown;
  source?: unknown;       // 'app_store' | 'google_play'
  verificationData?: unknown;
  deviceId?: unknown;
}

/**
 * Records a validated store purchase.
 *
 * This endpoint is deliberately NOT session-authenticated. The mobile app has
 * no login flow, so requiring a NextAuth cookie meant the client could never
 * call it and no receipt ever reached the server. The store-signed receipt is
 * itself the credential: it is verified against Apple's or Google's servers
 * before anything is written. A session, when one happens to exist, is used
 * only to attribute the entitlement to a user.
 */
export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => null) as UnlockBody | null;
  if (
    !body ||
    body.productId !== UNLOCK_PRODUCT_ID ||
    typeof body.transactionId !== 'string' || body.transactionId.length < 1 ||
    (body.source !== 'app_store' && body.source !== 'google_play') ||
    typeof body.verificationData !== 'string' || body.verificationData.length < 1
  ) {
    return NextResponse.json({ error: 'Invalid unlock request' }, { status: 400 });
  }

  const deviceId = typeof body.deviceId === 'string' && body.deviceId.length > 0
    ? body.deviceId.slice(0, 128)
    : null;

  // transactionId is the idempotency key — a replayed receipt is a no-op.
  const existing = await prisma.mobileEntitlement.findUnique({
    where: { transactionId: body.transactionId },
  });
  if (existing) {
    return NextResponse.json({ unlocked: true, entitlementId: existing.id });
  }

  const valid = body.source === 'app_store'
    ? await validateApple(body.verificationData, body.transactionId)
    : await validateGoogle(body.verificationData, body.transactionId);

  if (!valid) {
    return NextResponse.json({ error: 'Receipt validation failed' }, { status: 403 });
  }

  // Attribute to a user only if this request happens to carry a web session.
  const session = await auth().catch(() => null);
  const userId = session?.user?.id ?? null;

  const entitlement = await prisma.mobileEntitlement.create({
    data: {
      userId,
      deviceId,
      productId: UNLOCK_PRODUCT_ID,
      platform: body.source,
      transactionId: body.transactionId,
      status: 'active',
    },
  });

  return NextResponse.json({ unlocked: true, entitlementId: entitlement.id });
}

/**
 * Whether an unvalidatable receipt may be accepted.
 *
 * Fails CLOSED. The previous behaviour was `NODE_ENV !== 'production'`, which
 * accepted any forged receipt whenever store credentials were missing — and
 * nothing in wrangler.jsonc sets NODE_ENV, so that was one config slip away
 * from being wide open in the deployed Worker. Now it takes a deliberate,
 * explicit opt-in that would never be set in a real environment.
 */
function unverifiedReceiptsAllowed(): boolean {
  return process.env.ALLOW_UNVERIFIED_IAP === '1';
}

// ── Apple App Store Server API (StoreKit 2) ───────────────────────────────────

async function validateApple(signedTransaction: string, transactionId: string): Promise<boolean> {
  // NOTE: APPLE_ISSUER_ID / APPLE_KEY_ID / APPLE_PRIVATE_KEY are deliberately
  // NOT required here. Verifying a StoreKit 2 signed transaction is a signature
  // check against Apple's certificate chain — it needs the root CAs and nothing
  // else. Those three credentials authenticate OUTBOUND calls to the App Store
  // Server API (refund/revocation lookups, history), which this route does not
  // make. Gating on them, as this used to, blocked every Apple receipt on
  // credentials the verification path never reads.
  //
  // Apple's verifier needs the real root CAs as DER buffers. Passing an empty
  // array (as this used to) does NOT fall back to a bundled set — the library
  // has no bundled set, so verification could never succeed.
  const rootCerts = appleRootCerts();
  if (rootCerts.length === 0) {
    console.warn('[unlock] APPLE_ROOT_CA_CERTS not configured — cannot verify Apple receipts');
    return unverifiedReceiptsAllowed();
  }

  try {
    const { SignedDataVerifier, Environment } = await import('@apple/app-store-server-library');
    const env = process.env.NODE_ENV === 'production' ? Environment.PRODUCTION : Environment.SANDBOX;
    const verifier = new SignedDataVerifier(rootCerts, true, env, IOS_BUNDLE_ID, 0);
    const payload = await verifier.verifyAndDecodeTransaction(signedTransaction);

    // The client sends PurchaseDetails.purchaseID, which may be either the
    // transaction id or the original transaction id depending on whether the
    // purchase was new or restored. Accept either rather than only the latter.
    const idMatches =
      payload.transactionId === transactionId ||
      payload.originalTransactionId === transactionId;

    return (
      payload.bundleId === IOS_BUNDLE_ID &&
      payload.productId === UNLOCK_PRODUCT_ID &&
      idMatches &&
      payload.revocationDate == null
    );
  } catch (err) {
    console.warn('[unlock] Apple receipt verification threw', err);
    return false;
  }
}

/** Apple root CAs, supplied as a comma-separated list of base64 DER certs. */
function appleRootCerts(): Buffer[] {
  const raw = process.env.APPLE_ROOT_CA_CERTS;
  if (!raw) return [];
  return raw
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s.length > 0)
    .map((s) => Buffer.from(s, 'base64'));
}

// ── Google Play Developer API ────────────────────────────────────────────────

async function validateGoogle(purchaseToken: string, orderId: string): Promise<boolean> {
  const serviceKey = process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_KEY;

  if (!serviceKey) {
    console.warn('[unlock] Google Play credentials not configured — receipt not validated');
    return unverifiedReceiptsAllowed();
  }

  try {
    const { google } = await import('googleapis');
    const key = JSON.parse(serviceKey);
    const auth = new google.auth.GoogleAuth({
      credentials: key,
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });
    const androidpublisher = google.androidpublisher({ version: 'v3', auth });
    const res = await androidpublisher.purchases.products.get({
      packageName: ANDROID_PACKAGE_NAME,
      productId: UNLOCK_PRODUCT_ID,
      token: purchaseToken,
    });

    // purchaseState 0 = purchased. Google omits orderId on some test and
    // promotional purchases, so only compare it when it is actually present —
    // the purchase token we just verified is the stronger claim anyway.
    if (res.data.purchaseState !== 0) return false;
    if (res.data.orderId && res.data.orderId !== orderId) return false;
    return true;
  } catch (err) {
    console.warn('[unlock] Google Play verification threw', err);
    return false;
  }
}
