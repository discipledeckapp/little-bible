import { NextResponse } from 'next/server';

const storyIds = [
  'god-made-everything', 'god-made-me', 'noahs-big-boat', 'noahs-rainbow-promise',
  'birth-of-jesus', 'jesus-loves-children', 'david-the-shepherd-boy',
  'daniel-and-the-lions', 'jonah-and-the-big-fish', 'the-lost-sheep',
  'the-lost-son', 'the-good-shepherd', 'how-to-pray',
  'the-good-neighbour', 'jesus-saves',
] as const;

export function GET() {
  const origin = process.env.NEXT_PUBLIC_CONTENT_ORIGIN ?? process.env.NEXT_PUBLIC_APP_URL ?? 'https://littlebible.org';
  const version = process.env.CONTENT_VERSION ?? '2026-08-03.1';
  return NextResponse.json({
    schemaVersion: 1,
    generatedAt: new Date().toISOString(),
    content: {
      stories: {
        version,
        items: storyIds.map((id) => ({
          id,
          version,
          url: `${origin}/data/en/stories/${id}.json?v=${version}`,
        })),
      },
    },
  }, { headers: { 'cache-control': 'public, max-age=60, stale-while-revalidate=300' } });
}
