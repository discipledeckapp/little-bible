import { Env, SyncEntry } from '../types';

export async function handleProgress(request: Request, env: Env): Promise<Response> {
  const auth = request.headers.get('Authorization');
  const userId = await verifyUser(auth, env);
  if (!userId) return new Response('Unauthorized', { status: 401 });

  const { entries } = await request.json() as { entries: SyncEntry[] };
  if (!Array.isArray(entries) || entries.length === 0) {
    return new Response('No entries', { status: 400 });
  }

  // Batch upsert in a single D1 transaction
  const stmt = env.DB.prepare(`
    INSERT INTO child_progress (id, user_id, profile_id, story_id, status, last_scene_index, completed_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(user_id, profile_id, story_id) DO UPDATE SET
      status = excluded.status,
      last_scene_index = MAX(child_progress.last_scene_index, excluded.last_scene_index),
      completed_at = COALESCE(excluded.completed_at, child_progress.completed_at),
      synced_at = datetime('now')
  `);

  const batch = entries.map(e => stmt.bind(
    crypto.randomUUID(), userId, e.profileId, e.storyId,
    e.status, e.lastSceneIndex, e.completedAt ?? null
  ));

  await env.DB.batch(batch);
  return Response.json({ synced: entries.length });
}

async function verifyUser(auth: string | null, env: Env): Promise<string | null> {
  if (!auth?.startsWith('Bearer ')) return null;
  const userId = auth.slice(7);
  const user = await env.DB.prepare('SELECT id FROM users WHERE id = ?').bind(userId).first();
  return user ? userId : null;
}
