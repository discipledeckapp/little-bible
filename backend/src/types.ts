export interface Env {
  DB: D1Database;
  CONTENT: R2Bucket;
  MANIFEST_KV: KVNamespace;
  GOOGLE_CLIENT_ID: string;
  IAP_SHARED_SECRET: string;        // Apple IAP shared secret
  GOOGLE_PLAY_API_KEY: string;
}

export interface SyncEntry {
  profileId: string;
  storyId: string;
  status: 'in_progress' | 'completed';
  lastSceneIndex: number;
  completedAt?: string;
}

export interface ManifestEntry {
  storyId: string;
  version: number;
  publishedAt: string;
}
