import { contentBucket, IMMUTABLE_CACHE_CONTROL } from '@/lib/content-delivery';

/**
 * Streams a version-addressed content object out of R2 (US-23).
 *
 * The R2 body is piped straight through as a ReadableStream — the Worker never
 * buffers a payload. When an R2 custom domain is configured via
 * CONTENT_PUBLIC_BASE, the manifest points clients directly at R2 and this route
 * is only a fallback.
 *
 * Keys are immutable, so a superseded key genuinely 404s: that is the signal for
 * the client to re-read the manifest rather than retry the same URL.
 */
export async function GET(
  request: Request,
  { params }: { params: Promise<{ path: string[] }> },
) {
  const { path } = await params;
  const key = path.join('/');

  if (!key || key.includes('..')) {
    return new Response('Not found', { status: 404 });
  }

  const bucket = contentBucket();
  if (!bucket) {
    return Response.json(
      { error: 'content_bucket_unavailable' },
      { status: 503, headers: { 'cache-control': 'no-store' } },
    );
  }

  const object = await bucket.get(key);
  if (!object) {
    return new Response('Not found', {
      status: 404,
      headers: { 'cache-control': 'public, max-age=60' },
    });
  }

  const etag = object.httpEtag;
  if (request.headers.get('if-none-match') === etag) {
    return new Response(null, {
      status: 304,
      headers: { etag, 'cache-control': IMMUTABLE_CACHE_CONTROL },
    });
  }

  return new Response(object.body, {
    headers: {
      'content-type': object.httpMetadata?.contentType ?? 'application/octet-stream',
      'content-length': String(object.size),
      'cache-control': IMMUTABLE_CACHE_CONTROL,
      etag,
    },
  });
}
