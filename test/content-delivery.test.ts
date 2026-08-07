import { describe, expect, it, beforeEach, vi } from 'vitest';

// ─── In-memory R2 + KV doubles ───────────────────────────────────────────────

class FakeR2 {
  objects = new Map<string, { body: Uint8Array; contentType?: string; cacheControl?: string }>();
  putCalls: string[] = [];
  deleteCalls: string[] = [];

  async get(key: string) {
    const object = this.objects.get(key);
    if (!object) return null;
    return {
      body: null,
      httpEtag: `"${key}"`,
      size: object.body.byteLength,
      httpMetadata: { contentType: object.contentType },
    };
  }
  async put(
    key: string,
    value: ArrayBuffer | string,
    options?: { httpMetadata?: { contentType?: string; cacheControl?: string } },
  ) {
    this.putCalls.push(key);
    const body =
      typeof value === 'string' ? new TextEncoder().encode(value) : new Uint8Array(value);
    this.objects.set(key, {
      body,
      contentType: options?.httpMetadata?.contentType,
      cacheControl: options?.httpMetadata?.cacheControl,
    });
  }
  async delete(key: string | string[]) {
    for (const k of Array.isArray(key) ? key : [key]) {
      this.deleteCalls.push(k);
      this.objects.delete(k);
    }
  }
  async head(key: string) {
    const object = this.objects.get(key);
    return object ? { size: object.body.byteLength } : null;
  }
}

class FakeKV {
  store = new Map<string, string>();
  async get(key: string) {
    return this.store.get(key) ?? null;
  }
  async put(key: string, value: string) {
    this.store.set(key, value);
  }
  async delete(key: string) {
    this.store.delete(key);
  }
}

let bucket: FakeR2;
let kv: FakeKV;
let publicBase: string | undefined;

vi.mock('@opennextjs/cloudflare', () => ({
  getCloudflareContext: () => ({
    env: {
      CONTENT_BUCKET: bucket,
      CONTENT_KV: kv,
      CONTENT_PUBLIC_BASE: publicBase,
      NEXT_PUBLIC_APP_URL: 'https://littlebible.org',
    },
  }),
}));

const {
  publishContent,
  unpublishContent,
  readManifest,
  objectUrl,
  objectKey,
  contentHash,
  IMMUTABLE_CACHE_CONTROL,
  MANIFEST_KV_KEY,
} = await import('@/lib/content-delivery');

const STORY_V1 = JSON.stringify({ id: 'the-lost-son', title: 'The Lost Son' });
const STORY_V2 = JSON.stringify({ id: 'the-lost-son', title: 'The Lost Son (revised)' });

beforeEach(() => {
  bucket = new FakeR2();
  kv = new FakeKV();
  publicBase = undefined;
});

describe('content URLs', () => {
  it('resolves to the Worker content route when no R2 domain is configured', () => {
    expect(objectUrl('stories/the-lost-son/abc123.json')).toBe(
      'https://littlebible.org/api/content/stories/the-lost-son/abc123.json',
    );
  });

  it('resolves directly to R2 when a public base is configured, bypassing the Worker', () => {
    publicBase = 'https://content.littlebible.org/';
    const url = objectUrl('stories/the-lost-son/abc123.json');
    expect(url).toBe('https://content.littlebible.org/stories/the-lost-son/abc123.json');
    expect(url).not.toContain('/api/');
  });

  it('addresses objects by content version, not by a mutable name', async () => {
    const version = await contentHash(STORY_V1);
    expect(objectKey('stories', 'the-lost-son', version)).toBe(
      `stories/the-lost-son/${version}.json`,
    );
  });

  it('derives the version from the bytes, so identical content hashes identically', async () => {
    expect(await contentHash(STORY_V1)).toBe(await contentHash(STORY_V1));
    expect(await contentHash(STORY_V1)).not.toBe(await contentHash(STORY_V2));
  });
});

describe('publishContent', () => {
  it('writes the R2 object and repoints the KV manifest in one publish', async () => {
    const result = await publishContent('stories', 'the-lost-son', STORY_V1);

    expect(bucket.putCalls).toEqual([result.key]);
    expect(bucket.objects.get(result.key)?.cacheControl).toBe(IMMUTABLE_CACHE_CONTROL);

    const manifest = await readManifest();
    expect(manifest?.content.stories.items).toHaveLength(1);
    expect(manifest?.content.stories.items[0]).toMatchObject({
      id: 'the-lost-son',
      version: result.version,
      key: result.key,
    });
    expect(kv.store.has(MANIFEST_KV_KEY)).toBe(true);
  });

  it('404s the old URL after an update by deleting the superseded object', async () => {
    const first = await publishContent('stories', 'the-lost-son', STORY_V1);
    const second = await publishContent('stories', 'the-lost-son', STORY_V2);

    expect(second.key).not.toBe(first.key);
    expect(second.supersededKey).toBe(first.key);
    expect(bucket.deleteCalls).toEqual([first.key]);
    expect(await bucket.get(first.key)).toBeNull();
    expect(await bucket.get(second.key)).not.toBeNull();
  });

  it('deletes the old object only after the manifest already points at the new one', async () => {
    await publishContent('stories', 'the-lost-son', STORY_V1);

    // Capture what the manifest said at the moment of each delete.
    const manifestAtDelete: string[] = [];
    const realDelete = bucket.delete.bind(bucket);
    bucket.delete = async (key: string | string[]) => {
      const manifest = JSON.parse(kv.store.get(MANIFEST_KV_KEY)!);
      manifestAtDelete.push(manifest.content.stories.items[0].key);
      return realDelete(key);
    };

    const second = await publishContent('stories', 'the-lost-son', STORY_V2);
    expect(manifestAtDelete).toEqual([second.key]);
  });

  it('is idempotent — republishing identical bytes uploads nothing', async () => {
    const first = await publishContent('stories', 'the-lost-son', STORY_V1);
    const again = await publishContent('stories', 'the-lost-son', STORY_V1);

    expect(again.unchanged).toBe(true);
    expect(again.key).toBe(first.key);
    expect(bucket.putCalls).toHaveLength(1);
    expect(bucket.deleteCalls).toHaveLength(0);
  });

  it('re-uploads when the manifest is current but the object is gone', async () => {
    const first = await publishContent('stories', 'the-lost-son', STORY_V1);
    await bucket.delete(first.key);
    bucket.putCalls = [];

    const repaired = await publishContent('stories', 'the-lost-son', STORY_V1);
    expect(repaired.unchanged).toBe(false);
    expect(bucket.putCalls).toEqual([first.key]);
  });

  it('changes the collection version when any member changes', async () => {
    await publishContent('stories', 'the-lost-son', STORY_V1);
    const before = (await readManifest())!.content.stories.version;

    await publishContent('stories', 'the-lost-son', STORY_V2);
    const after = (await readManifest())!.content.stories.version;

    expect(after).not.toBe(before);
  });

  it('keeps other collections untouched', async () => {
    await publishContent('stories', 'the-lost-son', STORY_V1);
    await publishContent('activities', 'the-lost-son', '{"activities":[]}');

    const manifest = (await readManifest())!;
    expect(manifest.content.stories.items).toHaveLength(1);
    expect(manifest.content.activities.items).toHaveLength(1);
    expect(manifest.content.audio.items).toHaveLength(0);
  });

  it('keeps manifest items sorted by id so the manifest is stable', async () => {
    await publishContent('stories', 'zebra', '{"id":"zebra"}');
    await publishContent('stories', 'apple', '{"id":"apple"}');

    const ids = (await readManifest())!.content.stories.items.map((i) => i.id);
    expect(ids).toEqual(['apple', 'zebra']);
  });

  it('fails loudly when the bucket binding is missing', async () => {
    const saved = bucket;
    // @ts-expect-error deliberately removing the binding
    bucket = undefined;
    await expect(publishContent('stories', 'x', '{}')).rejects.toThrow('CONTENT_BUCKET');
    bucket = saved;
  });
});

describe('unpublishContent', () => {
  it('drops the manifest entry before deleting the object', async () => {
    const published = await publishContent('stories', 'the-lost-son', STORY_V1);

    const manifestAtDelete: number[] = [];
    const realDelete = bucket.delete.bind(bucket);
    bucket.delete = async (key: string | string[]) => {
      const manifest = JSON.parse(kv.store.get(MANIFEST_KV_KEY)!);
      manifestAtDelete.push(manifest.content.stories.items.length);
      return realDelete(key);
    };

    expect(await unpublishContent('stories', 'the-lost-son')).toBe(true);
    expect(manifestAtDelete).toEqual([0]);
    expect(await bucket.get(published.key)).toBeNull();
  });

  it('reports false for content that was never published', async () => {
    expect(await unpublishContent('stories', 'nope')).toBe(false);
  });
});

describe('readManifest', () => {
  it('returns null before anything is published', async () => {
    expect(await readManifest()).toBeNull();
  });

  it('returns null rather than throwing on a corrupt manifest', async () => {
    kv.store.set(MANIFEST_KV_KEY, 'not json');
    expect(await readManifest()).toBeNull();
  });
});
