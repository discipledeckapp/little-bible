import { NextResponse } from 'next/server';

const storyIds = [
  'god-made-everything', 'god-made-me', 'the-first-family', 'the-very-sad-choice',
  'god-promises-a-rescuer', 'two-brothers', 'noahs-big-boat', 'noahs-rainbow-promise',
  'the-tall-tower', 'god-calls-abraham', 'stars-in-the-sky', 'the-promised-son',
  'god-provides-a-lamb', 'jacob-learns-grace', 'joseph-and-his-brothers',
  'joseph-forgives-his-family',
  'baby-moses-is-kept-safe', 'god-calls-from-the-fire', 'let-my-people-go',
  'the-passover-lamb', 'a-way-through-the-sea', 'bread-in-the-wilderness',
  'gods-good-commands', 'god-lives-with-his-people',
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
