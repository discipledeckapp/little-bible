import { getCloudflareContext } from '@opennextjs/cloudflare';

// ─── Content delivery via R2 + KV (US-23) ────────────────────────────────────
//
// Story/activity/audio payloads live in R2 under *version-addressed* keys, so a
// published object is immutable and can be cached forever. The KV manifest is the
// only mutable pointer: publishing writes the new object, repoints the manifest,
// then deletes the superseded object so its URL 404s as the plan requires.
//
// Workers never buffer a content payload — /api/content streams the R2 body
// through, and when CONTENT_PUBLIC_BASE is configured (an R2 custom domain) the
// manifest hands out direct R2 URLs and the Worker is out of the path entirely.

/** Minimal structural types — avoids pulling workerd globals into the DOM lib. */
interface R2ObjectBody {
  body: ReadableStream | null;
  httpEtag: string;
  size: number;
  httpMetadata?: { contentType?: string };
}
interface R2Bucket {
  get(key: string): Promise<R2ObjectBody | null>;
  put(
    key: string,
    value: ArrayBuffer | string,
    options?: { httpMetadata?: { contentType?: string; cacheControl?: string } },
  ): Promise<unknown>;
  delete(key: string | string[]): Promise<void>;
  head(key: string): Promise<{ size: number } | null>;
}
interface KVNamespace {
  get(key: string, type?: 'text'): Promise<string | null>;
  put(key: string, value: string, options?: { expirationTtl?: number }): Promise<void>;
  delete(key: string): Promise<void>;
}

export const MANIFEST_KV_KEY = 'content:manifest:v1';
export const MANIFEST_SCHEMA_VERSION = 1;

/** Cached for a year — every content key is version-addressed and immutable. */
export const IMMUTABLE_CACHE_CONTROL = 'public, max-age=31536000, immutable';

export type ContentKind = 'stories' | 'activities' | 'audio';

export interface ManifestItem {
  id: string;
  /** Content hash of the payload. Changes iff the bytes change. */
  version: string;
  /** R2 object key this version resolves to. */
  key: string;
  /** Absolute URL the mobile client fetches. */
  url: string;
  bytes: number;
  sha256: string;
}

export interface ContentManifest {
  schemaVersion: number;
  generatedAt: string;
  content: {
    stories: { version: string; items: ManifestItem[] };
    activities: { version: string; items: ManifestItem[] };
    audio: { version: string; items: ManifestItem[] };
  };
}

interface ContentEnv {
  CONTENT_BUCKET?: R2Bucket;
  CONTENT_KV?: KVNamespace;
  CONTENT_PUBLIC_BASE?: string;
  NEXT_PUBLIC_APP_URL?: string;
}

function env(): ContentEnv {
  const { env: cfEnv } = getCloudflareContext();
  return cfEnv as unknown as ContentEnv;
}

/** Returns the R2 bucket, or null when the binding is not provisioned yet. */
export function contentBucket(): R2Bucket | null {
  return env().CONTENT_BUCKET ?? null;
}

/** Returns the manifest KV namespace, or null when not provisioned yet. */
export function contentKv(): KVNamespace | null {
  return env().CONTENT_KV ?? null;
}

export function contentOrigin(): string {
  const e = env();
  return (
    e.CONTENT_PUBLIC_BASE?.replace(/\/$/, '') ??
    `${(e.NEXT_PUBLIC_APP_URL ?? 'https://littlebible.org').replace(/\/$/, '')}/api/content`
  );
}

export function objectKey(kind: ContentKind, id: string, version: string): string {
  return `${kind}/${id}/${version}${kind === 'audio' ? '' : '.json'}`;
}

export function objectUrl(key: string): string {
  return `${contentOrigin()}/${key}`;
}

/** Short content hash used as the immutable version identifier. */
export async function contentHash(body: ArrayBuffer | string): Promise<string> {
  const bytes =
    typeof body === 'string' ? new TextEncoder().encode(body).buffer as ArrayBuffer : body;
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
    .slice(0, 16);
}

function emptyManifest(): ContentManifest {
  return {
    schemaVersion: MANIFEST_SCHEMA_VERSION,
    generatedAt: new Date().toISOString(),
    content: {
      stories: { version: 'empty', items: [] },
      activities: { version: 'empty', items: [] },
      audio: { version: 'empty', items: [] },
    },
  };
}

/** Reads the published manifest. Returns null when nothing has been published. */
export async function readManifest(): Promise<ContentManifest | null> {
  const kv = contentKv();
  if (!kv) return null;
  const raw = await kv.get(MANIFEST_KV_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as ContentManifest;
  } catch {
    return null;
  }
}

/** A manifest's collection version is the hash of its members' versions. */
async function collectionVersion(items: ManifestItem[]): Promise<string> {
  if (items.length === 0) return 'empty';
  const fingerprint = [...items]
    .sort((a, b) => a.id.localeCompare(b.id))
    .map((i) => `${i.id}:${i.version}`)
    .join('|');
  return contentHash(fingerprint);
}

export async function writeManifest(manifest: ContentManifest): Promise<void> {
  const kv = contentKv();
  if (!kv) throw new Error('CONTENT_KV binding is not available');
  await kv.put(MANIFEST_KV_KEY, JSON.stringify(manifest));
}

export interface PublishResult {
  id: string;
  kind: ContentKind;
  version: string;
  key: string;
  url: string;
  /** True when the bytes were already published under this exact version. */
  unchanged: boolean;
  /** Key of the object this publish superseded and deleted, if any. */
  supersededKey: string | null;
}

/**
 * Publishes one content payload: writes the version-addressed R2 object, repoints
 * the KV manifest, then deletes the object it superseded.
 *
 * Deletion is last so a reader that raced the manifest write still resolves the
 * old key; the window is bounded by KV's propagation, and the client retries on
 * 404 by re-reading the manifest.
 */
export async function publishContent(
  kind: ContentKind,
  id: string,
  body: ArrayBuffer | string,
  contentType = 'application/json; charset=utf-8',
): Promise<PublishResult> {
  const bucket = contentBucket();
  if (!bucket) throw new Error('CONTENT_BUCKET binding is not available');

  const version = await contentHash(body);
  const key = objectKey(kind, id, version);
  const url = objectUrl(key);

  const manifest = (await readManifest()) ?? emptyManifest();
  const collection = manifest.content[kind];
  const previous = collection.items.find((i) => i.id === id) ?? null;

  if (previous?.version === version && (await bucket.head(key))) {
    return { id, kind, version, key, url, unchanged: true, supersededKey: null };
  }

  const bytes =
    typeof body === 'string' ? new TextEncoder().encode(body).byteLength : body.byteLength;

  await bucket.put(key, body, {
    httpMetadata: { contentType, cacheControl: IMMUTABLE_CACHE_CONTROL },
  });

  const item: ManifestItem = { id, version, key, url, bytes, sha256: version };
  collection.items = [...collection.items.filter((i) => i.id !== id), item].sort((a, b) =>
    a.id.localeCompare(b.id),
  );
  collection.version = await collectionVersion(collection.items);
  manifest.generatedAt = new Date().toISOString();

  await writeManifest(manifest);

  const supersededKey = previous && previous.key !== key ? previous.key : null;
  if (supersededKey) {
    await bucket.delete(supersededKey);
  }

  return { id, kind, version, key, url, unchanged: false, supersededKey };
}

/**
 * Removes a content item: drops it from the manifest first, then deletes the
 * object, so no client can be pointed at a key that is already gone.
 */
export async function unpublishContent(kind: ContentKind, id: string): Promise<boolean> {
  const bucket = contentBucket();
  const manifest = await readManifest();
  if (!manifest) return false;

  const collection = manifest.content[kind];
  const existing = collection.items.find((i) => i.id === id);
  if (!existing) return false;

  collection.items = collection.items.filter((i) => i.id !== id);
  collection.version = await collectionVersion(collection.items);
  manifest.generatedAt = new Date().toISOString();
  await writeManifest(manifest);

  if (bucket) await bucket.delete(existing.key);
  return true;
}

/**
 * Rolls a content item back to a previously published payload. The body is
 * re-published, which restores its original hash-addressed key.
 */
export async function rollbackContent(
  kind: ContentKind,
  id: string,
  body: ArrayBuffer | string,
  contentType?: string,
): Promise<PublishResult> {
  return publishContent(kind, id, body, contentType);
}
