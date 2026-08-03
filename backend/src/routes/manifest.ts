import { Env, ManifestEntry } from '../types';

export async function handleManifest(_request: Request, env: Env): Promise<Response> {
  const cacheKey = 'content-manifest-v1';

  // Try KV cache first (60-second TTL)
  const cached = await env.MANIFEST_KV.get(cacheKey, 'json') as ManifestEntry[] | null;
  if (cached) {
    return Response.json(cached, {
      headers: { 'Cache-Control': 'public, max-age=60' },
    });
  }

  const rows = await env.DB.prepare('SELECT story_id, version, published_at FROM content_versions ORDER BY story_id')
    .all<{ story_id: string; version: number; published_at: string }>();

  const manifest = rows.results.map(r => ({
    storyId: r.story_id,
    version: r.version,
    publishedAt: r.published_at,
  }));

  // Cache for 60 seconds
  await env.MANIFEST_KV.put(cacheKey, JSON.stringify(manifest), { expirationTtl: 60 });

  return Response.json(manifest, {
    headers: { 'Cache-Control': 'public, max-age=60' },
  });
}
