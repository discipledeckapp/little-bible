'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { getAllStoryProgress } from '@/lib/story-progress';
import type { StoryProgress } from '@/types';

export default function StoryGarden() {
  const [completed, setCompleted] = useState<StoryProgress[]>([]);

  useEffect(() => {
    const all = getAllStoryProgress();
    const done = Object.values(all).filter(
      p => p.status === 'complete' || p.status === 'memorised'
    );
    setCompleted(done);
  }, []);

  if (completed.length === 0) return null;

  // Story emoji map (since we don't load full story objects here)
  const STORY_EMOJI: Record<string, string> = {
    'god-made-everything':   '🌍',
    'god-made-me':           '✨',
    'noahs-big-boat':        '🚢',
    'gods-rainbow-promise':  '🌈',
    'david-the-shepherd-boy':'⭐',
    'daniel-and-the-lions':  '🦁',
    'jonah-and-the-big-fish':'🐋',
    'birth-of-jesus':        '⭐',
    'jesus-loves-children':  '❤️',
    'the-good-shepherd':     '🐑',
    'the-lost-sheep':        '🐑',
    'the-lost-son':          '🏃',
    'how-to-pray':           '🙏',
    'the-good-neighbour':    '🤝',
    'jesus-saves':           '✝️',
  };

  const STORY_TITLE: Record<string, string> = {
    'god-made-everything':   'God Made Everything',
    'god-made-me':           'God Made Me',
    'noahs-big-boat':        "Noah's Big Boat",
    'gods-rainbow-promise':  "God's Rainbow",
    'david-the-shepherd-boy':'David the Shepherd',
    'daniel-and-the-lions':  'Daniel & the Lions',
    'jonah-and-the-big-fish':'Jonah & the Fish',
    'birth-of-jesus':        'Jesus Is Born',
    'jesus-loves-children':  'Jesus Loves Children',
    'the-good-shepherd':     'The Good Shepherd',
    'the-lost-sheep':        'The Lost Sheep',
    'the-lost-son':          'The Lost Son',
    'how-to-pray':           'How to Pray',
    'the-good-neighbour':    'The Good Neighbour',
    'jesus-saves':           'Jesus Saves',
  };

  return (
    <section className="py-10 px-4" style={{ background: 'var(--color-warm-cream)' }}>
      <div className="max-w-5xl mx-auto">
        <div className="flex items-center justify-between mb-5">
          <div>
            <p className="text-xs font-semibold text-amber-600 uppercase tracking-widest mb-0.5">
              Your Story Garden
            </p>
            <h2
              className="text-xl font-bold text-stone-800"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              {completed.length} {completed.length === 1 ? 'story' : 'stories'} planted 🌱
            </h2>
          </div>
        </div>

        <div className="flex gap-3 overflow-x-auto pb-2 -mx-4 px-4 snap-x">
          {completed.map(p => (
            <Link
              key={p.storyId}
              href={`/stories/${p.storyId}`}
              className="snap-start shrink-0 w-24 flex flex-col items-center gap-2 p-3 bg-white rounded-2xl shadow-sm border border-amber-100 hover:shadow-md transition-all active:scale-95"
            >
              <span className="text-3xl">{STORY_EMOJI[p.storyId] ?? '📖'}</span>
              <p className="text-xs font-medium text-stone-600 text-center leading-tight line-clamp-2">
                {STORY_TITLE[p.storyId] ?? p.storyId}
              </p>
              {p.status === 'memorised' && (
                <span className="text-xs text-amber-500">⭐ Memorised</span>
              )}
              {p.status === 'complete' && (
                <span className="text-xs text-green-600">✓ Done</span>
              )}
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}
