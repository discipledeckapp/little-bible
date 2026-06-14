import { createHmac, createHash, randomBytes, timingSafeEqual as cryptoEqual } from 'crypto';
export { ADMIN_COOKIE } from './constants';

const SESSION_DURATION_MS = 8 * 60 * 60 * 1000; // 8 hours
export const SESSION_MAX_AGE = SESSION_DURATION_MS / 1000;

function secret(): string {
  return process.env.ADMIN_SESSION_SECRET ?? 'dev-only-fallback-change-in-prod';
}

function sign(payload: string): string {
  return createHmac('sha256', secret()).update(payload).digest('base64url');
}

function safeEqual(a: string, b: string): boolean {
  const ha = createHash('sha256').update(a).digest();
  const hb = createHash('sha256').update(b).digest();
  return cryptoEqual(ha, hb);
}

/** Creates a signed token. Synchronous — no jose required. */
export function createAdminToken(): string {
  const payload = JSON.stringify({
    role: 'SUPER_ADMIN',
    exp:  Date.now() + SESSION_DURATION_MS,
    jti:  randomBytes(8).toString('hex'),
  });
  const encoded = Buffer.from(payload).toString('base64url');
  const sig     = sign(encoded);
  return `${encoded}.${sig}`;
}

/** Verifies a signed token. Returns true if valid and not expired. */
export function verifyAdminToken(token: string | undefined): boolean {
  if (!token) return false;
  const lastDot = token.lastIndexOf('.');
  if (lastDot === -1) return false;
  const encoded  = token.slice(0, lastDot);
  const sig      = token.slice(lastDot + 1);
  if (!safeEqual(sig, sign(encoded))) return false;
  try {
    const { exp } = JSON.parse(Buffer.from(encoded, 'base64url').toString('utf8'));
    return typeof exp === 'number' && Date.now() < exp;
  } catch {
    return false;
  }
}

/** Compares submitted credentials against env vars. */
export function checkAdminCredentials(email: string, password: string): boolean {
  const expectedEmail    = process.env.ADMIN_EMAIL    ?? '';
  const expectedPassword = process.env.ADMIN_PASSWORD ?? '';
  if (!expectedEmail || !expectedPassword) return false;
  const hashInput    = createHash('sha256').update(email    + ':' + password).digest('hex');
  const hashExpected = createHash('sha256').update(expectedEmail + ':' + expectedPassword).digest('hex');
  return hashInput === hashExpected;
}
