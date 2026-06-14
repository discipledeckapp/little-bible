import { SignJWT, jwtVerify } from 'jose';
import { createHash } from 'crypto';
export { ADMIN_COOKIE } from './constants';
const SESSION_DURATION = 60 * 60 * 8; // 8 hours

function getSecret(): Uint8Array {
  const s = process.env.ADMIN_SESSION_SECRET ?? 'dev-only-fallback-change-in-prod';
  return new TextEncoder().encode(s);
}

export async function createAdminToken(): Promise<string> {
  return new SignJWT({ role: 'SUPER_ADMIN' })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(`${SESSION_DURATION}s`)
    .sign(getSecret());
}

export async function verifyAdminToken(token: string): Promise<boolean> {
  try {
    await jwtVerify(token, getSecret());
    return true;
  } catch {
    return false;
  }
}

export function checkAdminCredentials(email: string, password: string): boolean {
  const expectedEmail    = process.env.ADMIN_EMAIL    ?? '';
  const expectedPassword = process.env.ADMIN_PASSWORD ?? '';
  if (!expectedEmail || !expectedPassword) return false;
  // Timing-safe via equal-length hash comparison
  const hashInput    = createHash('sha256').update(email    + ':' + password).digest('hex');
  const hashExpected = createHash('sha256').update(expectedEmail + ':' + expectedPassword).digest('hex');
  return hashInput === hashExpected;
}

export const SESSION_MAX_AGE = SESSION_DURATION;
