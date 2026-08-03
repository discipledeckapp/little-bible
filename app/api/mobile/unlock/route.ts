import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';
import { NextRequest, NextResponse } from 'next/server';

const UNLOCK_PRODUCT_ID = 'com.littlebible.unlock';
const BUNDLE_ID = 'org.littlebible.little_bible';

interface UnlockBody {
  productId?: unknown;
  transactionId?: unknown;
  source?: unknown;       // 'app_store' | 'google_play'
  verificationData?: unknown;
}

export async function POST(req: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

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

  const existing = await prisma.mobileEntitlement.findUnique({
    where: { transactionId: body.transactionId },
  });
  if (existing) {
    // Idempotent — already validated, return success
    return NextResponse.json({ unlocked: true, entitlementId: existing.id });
  }

  const valid = body.source === 'app_store'
    ? await validateApple(body.verificationData, body.transactionId)
    : await validateGoogle(body.verificationData, body.transactionId);

  if (!valid) {
    return NextResponse.json({ error: 'Receipt validation failed' }, { status: 403 });
  }

  const entitlement = await prisma.mobileEntitlement.upsert({
    where: { userId_productId: { userId: session.user.id, productId: UNLOCK_PRODUCT_ID } },
    create: {
      userId: session.user.id,
      productId: UNLOCK_PRODUCT_ID,
      platform: body.source,
      transactionId: body.transactionId,
      status: 'active',
    },
    update: { status: 'active', verifiedAt: new Date() },
  });

  return NextResponse.json({ unlocked: true, entitlementId: entitlement.id });
}

// ── Apple App Store Server API (StoreKit 2) ───────────────────────────────────

async function validateApple(signedTransaction: string, transactionId: string): Promise<boolean> {
  const issuerId = process.env.APPLE_ISSUER_ID;
  const keyId = process.env.APPLE_KEY_ID;
  const privateKey = process.env.APPLE_PRIVATE_KEY;

  if (!issuerId || !keyId || !privateKey) {
    // No Apple credentials configured — skip validation in dev/test
    return process.env.NODE_ENV !== 'production';
  }

  try {
    const { SignedDataVerifier, Environment } = await import('@apple/app-store-server-library');
    const env = process.env.NODE_ENV === 'production' ? Environment.PRODUCTION : Environment.SANDBOX;
    // Apple root CAs are required; use the library's bundled set via empty array + enableOnlineChecks
    const verifier = new SignedDataVerifier([], true, env, BUNDLE_ID, 0);
    const payload = await verifier.verifyAndDecodeTransaction(signedTransaction);
    return (
      payload.bundleId === BUNDLE_ID &&
      payload.productId === UNLOCK_PRODUCT_ID &&
      payload.originalTransactionId === transactionId &&
      payload.revocationDate == null
    );
  } catch {
    return false;
  }
}

// ── Google Play Developer API ────────────────────────────────────────────────

async function validateGoogle(purchaseToken: string, orderId: string): Promise<boolean> {
  const serviceKey = process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_KEY;
  const packageName = BUNDLE_ID.replace(/_/g, '.');

  if (!serviceKey) {
    return process.env.NODE_ENV !== 'production';
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
      packageName,
      productId: UNLOCK_PRODUCT_ID,
      token: purchaseToken,
    });
    return (
      res.data.orderId === orderId &&
      res.data.purchaseState === 0 &&  // 0 = purchased
      res.data.consumptionState === 0  // 0 = yet to be consumed (non-consumable)
    );
  } catch {
    return false;
  }
}
