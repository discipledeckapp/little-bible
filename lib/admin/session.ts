import { SignJWT, jwtVerify } from 'jose';

export const ADMIN_COOKIE = 'lb-admin-session';
const SESSION_DURATION = 60 * 60 * 8; // 8 hours in seconds

function getSecret(): Uint8Array {
  const s = process.env.ADMIN_SESSION_SECRET;
  if (!s) throw new Error('ADMIN_SESSION_SECRET env var is not set');
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
  // Timing-safe comparison via constant-length hash
  const { createHash } = require('crypto') as typeof import('crypto');
  const hashInput    = createHash('sha256').update(email    + password).digest('hex');
  const hashExpected = createHash('sha256').update(expectedEmail + expectedPassword).digest('hex');
  return hashInput === hashExpected;
}

export const SESSION_MAX_AGE = SESSION_DURATION;
