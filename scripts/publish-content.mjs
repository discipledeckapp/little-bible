#!/usr/bin/env node
/**
 * Seeds R2 + the KV manifest from the locally bundled content (US-23).
 *
 * The admin publish action does this one package at a time through the runtime
 * bindings; this script is the bulk path for the initial upload and for
 * re-syncing everything after a content sweep. Both produce identical keys
 * because both derive the version from the same SHA-256 content hash, so
 * re-running this is idempotent — unchanged files are skipped.
 *
 *   node scripts/publish-content.mjs --dry-run       # show the plan, upload nothing
 *   node scripts/publish-content.mjs --stories       # stories + activities only
 *   node scripts/publish-content.mjs --audio         # include the ~19MB of MP3s
 *   node scripts/publish-content.mjs --local         # target the local dev bindings
 */

import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { readFileSync, readdirSync, existsSync, writeFileSync, mkdtempSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { tmpdir } from 'node:os';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const BUCKET = 'little-bible-content';
const KV_BINDING = 'CONTENT_KV';
const MANIFEST_KEY = 'content:manifest:v1';
const MANIFEST_SCHEMA_VERSION = 1;

const args = new Set(process.argv.slice(2));
const dryRun = args.has('--dry-run');
const includeAudio = args.has('--audio');
const includeStories = args.has('--stories') || !includeAudio;
const remoteFlag = args.has('--local') ? '--local' : '--remote';

/** Must match contentHash() in lib/content-delivery.ts exactly. */
function contentHash(buffer) {
  return createHash('sha256').update(buffer).digest('hex').slice(0, 16);
}

function contentOrigin() {
  const base = process.env.CONTENT_PUBLIC_BASE;
  if (base) return base.replace(/\/$/, '');
  const app = (process.env.NEXT_PUBLIC_APP_URL ?? 'https://littlebible.org').replace(/\/$/, '');
  return `${app}/api/content`;
}

function wrangler(argv) {
  if (dryRun) return '';
  return execFileSync('npx', ['wrangler', ...argv], {
    cwd: ROOT,
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'inherit'],
  });
}

function objectExists(key) {
  if (dryRun) return false;
  try {
    execFileSync('npx', ['wrangler', 'r2', 'object', 'get', `${BUCKET}/${key}`, remoteFlag, '--pipe'], {
      cwd: ROOT,
      stdio: ['ignore', 'ignore', 'ignore'],
    });
    return true;
  } catch {
    return false;
  }
}

function collect(kind) {
  const items = [];
  if (kind === 'stories' || kind === 'activities') {
    const dir = join(ROOT, 'mobile', 'assets', kind);
    if (!existsSync(dir)) return items;
    for (const file of readdirSync(dir).filter((f) => f.endsWith('.json')).sort()) {
      items.push({
        id: file.replace(/\.json$/, ''),
        path: join(dir, file),
        contentType: 'application/json; charset=utf-8',
        extension: '.json',
      });
    }
    return items;
  }

  const dir = join(ROOT, 'mobile', 'assets', 'audio', 'stories');
  if (!existsSync(dir)) return items;
  for (const storyId of readdirSync(dir).sort()) {
    const storyDir = join(dir, storyId);
    for (const file of readdirSync(storyDir).filter((f) => f.endsWith('.mp3')).sort()) {
      items.push({
        // Audio ids are namespaced by story so one manifest entry maps to one file.
        id: `${storyId}/${file.replace(/\.mp3$/, '')}`,
        path: join(storyDir, file),
        contentType: 'audio/mpeg',
        extension: '.mp3',
      });
    }
  }
  return items;
}

function publishKind(kind) {
  const collected = collect(kind);
  const manifestItems = [];
  let uploaded = 0;
  let skipped = 0;

  for (const item of collected) {
    const buffer = readFileSync(item.path);
    const version = contentHash(buffer);
    const key = `${kind}/${item.id}/${version}${item.extension}`;

    if (objectExists(key)) {
      skipped += 1;
    } else {
      console.log(`  ${dryRun ? 'would upload' : 'upload'} ${key} (${buffer.length} bytes)`);
      wrangler([
        'r2', 'object', 'put', `${BUCKET}/${key}`,
        `--file=${item.path}`,
        `--content-type=${item.contentType}`,
        '--cache-control=public, max-age=31536000, immutable',
        remoteFlag,
      ]);
      uploaded += 1;
    }

    manifestItems.push({
      id: item.id,
      version,
      key,
      url: `${contentOrigin()}/${key}`,
      bytes: buffer.length,
      sha256: version,
    });
  }

  console.log(`${kind}: ${manifestItems.length} items (${uploaded} uploaded, ${skipped} already present)`);
  return manifestItems;
}

function collectionVersion(items) {
  if (items.length === 0) return 'empty';
  const fingerprint = [...items]
    .sort((a, b) => a.id.localeCompare(b.id))
    .map((i) => `${i.id}:${i.version}`)
    .join('|');
  return contentHash(Buffer.from(fingerprint, 'utf8'));
}

function main() {
  console.log(`Publishing to ${BUCKET} (${remoteFlag}${dryRun ? ', dry run' : ''})`);

  const stories = includeStories ? publishKind('stories') : [];
  const activities = includeStories ? publishKind('activities') : [];
  const audio = includeAudio ? publishKind('audio') : [];

  const manifest = {
    schemaVersion: MANIFEST_SCHEMA_VERSION,
    generatedAt: new Date().toISOString(),
    content: {
      stories: { version: collectionVersion(stories), items: stories },
      activities: { version: collectionVersion(activities), items: activities },
      audio: { version: collectionVersion(audio), items: audio },
    },
  };

  // A partial run must not blank out a collection it did not touch.
  if (!includeStories || !includeAudio) {
    console.log(
      'NOTE: this run only covers ' +
        [includeStories && 'stories/activities', includeAudio && 'audio'].filter(Boolean).join(' + ') +
        '. Run without flags plus --audio to publish a complete manifest.',
    );
  }

  const body = JSON.stringify(manifest);
  if (dryRun) {
    console.log(`\nManifest (${body.length} bytes):`);
    console.log(JSON.stringify({ ...manifest, content: {
      stories: { version: manifest.content.stories.version, items: `${stories.length} items` },
      activities: { version: manifest.content.activities.version, items: `${activities.length} items` },
      audio: { version: manifest.content.audio.version, items: `${audio.length} items` },
    } }, null, 2));
    return;
  }

  // Written via a file: the manifest is far past a safe argv length.
  const tmp = join(mkdtempSync(join(tmpdir(), 'lb-manifest-')), 'manifest.json');
  writeFileSync(tmp, body);
  wrangler(['kv', 'key', 'put', MANIFEST_KEY, `--path=${tmp}`, `--binding=${KV_BINDING}`, remoteFlag]);
  console.log(`\nManifest published to KV (${body.length} bytes)`);
}

main();
