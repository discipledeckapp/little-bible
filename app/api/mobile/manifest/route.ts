import { NextResponse } from 'next/server';
import { readManifest, MANIFEST_SCHEMA_VERSION } from '@/lib/content-delivery';

// Bundled catalogue. Used only as the fallback manifest before anything has been
// published to R2/KV — every id here also ships inside the app, so a client that
// sees this manifest already has the content and simply records the version.
const bundledStoryIds = [
  'god-made-everything', 'god-made-me', 'the-first-family', 'the-very-sad-choice',
  'god-promises-a-rescuer', 'two-brothers', 'noahs-big-boat', 'noahs-rainbow-promise',
  'the-tall-tower', 'god-calls-abraham', 'stars-in-the-sky', 'the-promised-son',
  'god-provides-a-lamb', 'jacob-learns-grace', 'joseph-and-his-brothers',
  'joseph-forgives-his-family',
  'baby-moses-is-kept-safe', 'god-calls-from-the-fire', 'let-my-people-go',
  'the-passover-lamb', 'a-way-through-the-sea', 'bread-in-the-wilderness',
  'gods-good-commands', 'god-lives-with-his-people',
  'twelve-spies', 'joshua-and-the-walls', 'deborah-leads-gods-people',
  'gideons-tiny-army', 'ruth-finds-a-home', 'samuel-listens-to-god',
  'saul-the-king',
  'david-and-the-giant',
  'davids-sin-and-gods-mercy',
  'gods-forever-king-promise',
  'solomon-asks-for-wisdom',
  'elijah-and-the-only-true-god',
  'the-prophets-promise-new-hearts',
  'an-angel-visits-mary',
  'visitors-worship-the-king',
  'jesus-grows-and-obeys',
  'jesus-is-baptised',
  'jesus-says-no-to-tempter',
  'jesus-calls-his-helpers',
  'birth-of-jesus', 'jesus-loves-children', 'david-the-shepherd-boy',
  'daniel-and-the-lions', 'jonah-and-the-big-fish', 'the-lost-sheep',
  'the-lost-son', 'the-good-shepherd', 'how-to-pray',
  'the-good-neighbour', 'jesus-saves',
 'jesus-calms-the-storm',
 'jesus-heals-and-forgives',
 'jesus-feeds-the-crowd',
 'jesus-raises-lazarus',
 'the-king-rides-in',
 'servant-king-washes-feet',
 'the-last-supper',
 'jesus-prays-in-garden',
 'jesus-dies-for-sinners',
 'jesus-is-alive',
 'jesus-returns-to-his-father',
 'the-holy-spirit-comes',
 'a-new-sharing-family',
 'stephen-sees-jesus',
 'saul-meets-the-risen-jesus',
 'peter-welcomes-cornelius',
 'paul-and-silas-in-prison',
 'the-spirit-grows-good-fruit',
 'gods-armour-for-hard-days',
 'when-anger-knocks',
 'when-i-feel-alone',
 'when-life-feels-unfair',
 'when-someone-we-love-dies',
 'jesus-will-come-again',
 'the-king-judges',
 'god-makes-everything-new',
] as const;

function fallbackManifest() {
  const origin =
    process.env.NEXT_PUBLIC_CONTENT_ORIGIN ??
    process.env.NEXT_PUBLIC_APP_URL ??
    'https://littlebible.org';
  const version = process.env.CONTENT_VERSION ?? '2026-08-03.1';
  return {
    schemaVersion: MANIFEST_SCHEMA_VERSION,
    generatedAt: new Date().toISOString(),
    source: 'bundled' as const,
    content: {
      stories: {
        version,
        items: bundledStoryIds.map((id) => ({
          id,
          version,
          key: `stories/${id}/${version}.json`,
          url: `${origin}/data/en/stories/${id}.json?v=${version}`,
          bytes: 0,
          sha256: '',
        })),
      },
      activities: { version: 'empty', items: [] },
      audio: { version: 'empty', items: [] },
    },
  };
}

/**
 * The mobile content manifest (US-12). Served from KV once content has been
 * published, so a publish is visible to clients within KV's propagation window
 * without a redeploy. Falls back to the bundled catalogue when KV is empty.
 *
 * Short max-age: this is the only mutable pointer in the content system, while
 * everything it points at is immutable and cached for a year.
 */
export async function GET() {
  let manifest: unknown = null;
  try {
    const published = await readManifest();
    if (published) manifest = { ...published, source: 'published' as const };
  } catch {
    // KV unavailable (binding missing, local dev) — fall through to bundled.
  }

  return NextResponse.json(manifest ?? fallbackManifest(), {
    headers: { 'cache-control': 'public, max-age=60, stale-while-revalidate=300' },
  });
}
