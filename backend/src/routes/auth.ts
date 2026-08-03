import { Env } from '../types';

export async function handleAuth(request: Request, env: Env): Promise<Response> {
  const { idToken } = await request.json() as { idToken: string };
  if (!idToken) return new Response('Missing idToken', { status: 400 });

  // Verify with Google
  const verifyUrl = `https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`;
  const verifyRes = await fetch(verifyUrl);
  if (!verifyRes.ok) return new Response('Invalid token', { status: 401 });

  const payload = await verifyRes.json() as { sub: string; email: string; aud: string };
  if (payload.aud !== env.GOOGLE_CLIENT_ID) return new Response('Wrong audience', { status: 401 });

  // Upsert user
  const userId = crypto.randomUUID();
  await env.DB.prepare(`
    INSERT INTO users (id, google_sub, email) VALUES (?, ?, ?)
    ON CONFLICT(google_sub) DO UPDATE SET email = excluded.email, updated_at = datetime('now')
  `).bind(userId, payload.sub, payload.email).run();

  const user = await env.DB.prepare('SELECT id, unlocked FROM users WHERE google_sub = ?')
    .bind(payload.sub).first<{ id: string; unlocked: number }>();

  return Response.json({ userId: user!.id, unlocked: user!.unlocked === 1 });
}
