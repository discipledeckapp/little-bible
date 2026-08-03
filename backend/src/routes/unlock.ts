import { Env } from '../types';

export async function handleUnlock(request: Request, env: Env): Promise<Response> {
  const auth = request.headers.get('Authorization');
  const userId = await verifyUser(auth, env);
  if (!userId) return new Response('Unauthorized', { status: 401 });

  const { platform, receiptData, purchaseToken, productId } = await request.json() as {
    platform: 'ios' | 'android';
    receiptData?: string;
    purchaseToken?: string;
    productId: string;
  };

  if (productId !== 'com.littlebible.unlockall') {
    return new Response('Invalid product', { status: 400 });
  }

  let transactionId: string;

  if (platform === 'ios' && receiptData) {
    const valid = await validateAppleReceipt(receiptData, env);
    if (!valid) return new Response('Invalid receipt', { status: 403 });
    transactionId = `apple-${crypto.randomUUID()}`;
  } else if (platform === 'android' && purchaseToken) {
    const valid = await validateGooglePurchase(purchaseToken, productId, env);
    if (!valid) return new Response('Invalid purchase', { status: 403 });
    transactionId = `google-${purchaseToken.slice(0, 32)}`;
  } else {
    return new Response('Missing receipt data', { status: 400 });
  }

  // Record unlock (idempotent)
  await env.DB.prepare(`
    INSERT OR IGNORE INTO unlock_records (id, user_id, platform, transaction_id, product_id)
    VALUES (?, ?, ?, ?, ?)
  `).bind(crypto.randomUUID(), userId, platform, transactionId, productId).run();

  await env.DB.prepare("UPDATE users SET unlocked = 1, updated_at = datetime('now') WHERE id = ?")
    .bind(userId).run();

  return Response.json({ unlocked: true });
}

async function validateAppleReceipt(receiptData: string, env: Env): Promise<boolean> {
  const body = JSON.stringify({
    'receipt-data': receiptData,
    'password': env.IAP_SHARED_SECRET,
    'exclude-old-transactions': true,
  });
  // Use production first, fall back to sandbox
  for (const url of ['https://buy.itunes.apple.com/verifyReceipt', 'https://sandbox.itunes.apple.com/verifyReceipt']) {
    const res = await fetch(url, { method: 'POST', body });
    const data = await res.json() as { status: number };
    if (data.status === 0) return true;
    if (data.status === 21007) continue; // sandbox receipt sent to production
    return false;
  }
  return false;
}

async function validateGooglePurchase(purchaseToken: string, productId: string, env: Env): Promise<boolean> {
  const packageName = 'org.littlebible.little_bible';
  const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/products/${productId}/tokens/${purchaseToken}?key=${env.GOOGLE_PLAY_API_KEY}`;
  const res = await fetch(url);
  if (!res.ok) return false;
  const data = await res.json() as { purchaseState: number };
  return data.purchaseState === 0; // 0 = purchased
}

async function verifyUser(auth: string | null, env: Env): Promise<string | null> {
  if (!auth?.startsWith('Bearer ')) return null;
  const userId = auth.slice(7);
  const user = await env.DB.prepare('SELECT id FROM users WHERE id = ?').bind(userId).first();
  return user ? userId : null;
}
