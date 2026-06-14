'use client';

import { useState, useEffect } from 'react';
import type { ActivitySequenceItem } from '@/types/activities';

interface StorySequencerProps {
  prompt: string;
  items: ActivitySequenceItem[];
  onComplete: (seedsEarned: number, perfect: boolean) => void;
  onBack: () => void;
}

const SEEDS_PERFECT = 4;
const SEEDS_PARTIAL = 1;

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

const ORDINAL = ['1st', '2nd', '3rd', '4th', '5th'];

export default function StorySequencer({ prompt, items, onComplete, onBack }: StorySequencerProps) {
  const [shuffled, setShuffled] = useState<ActivitySequenceItem[]>([]);
  const [tapped, setTapped] = useState<string[]>([]);
  const [checked, setChecked] = useState(false);
  const [correct, setCorrect] = useState<boolean[]>([]);
  const [done, setDone] = useState(false);

  useEffect(() => {
    let s = shuffle(items);
    let attempts = 0;
    while (s.map(i => i.id).join(',') === items.map(i => i.id).join(',') && attempts < 8) {
      s = shuffle(items);
      attempts++;
    }
    setShuffled(s);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const nextPosition = tapped.length + 1;
  const allTapped = tapped.length === items.length;

  function handleTap(item: ActivitySequenceItem) {
    if (checked) return;
    const pos = tapped.indexOf(item.id);
    if (pos !== -1) {
      // Remove this item and all after it (cascade undo)
      setTapped(prev => prev.slice(0, pos));
    } else if (!allTapped) {
      setTapped(prev => [...prev, item.id]);
    }
  }

  function handleCheck() {
    // The correct order is items sorted by order ascending
    const sortedByOrder = [...items].sort((a, b) => a.order - b.order);
    const results = tapped.map((id, i) => id === sortedByOrder[i]?.id);
    setCorrect(results);
    setChecked(true);
    const perfect = results.every(Boolean);
    const seeds = perfect ? SEEDS_PERFECT : SEEDS_PARTIAL;
    setDone(true);
    setTimeout(() => onComplete(seeds, perfect), 2500);
  }

  const perfect = checked && correct.every(Boolean);
  const sortedByOrder = [...items].sort((a, b) => a.order - b.order);

  return (
    <div className="flex flex-col h-full px-5 py-6">
      {/* Back */}
      <button
        onClick={onBack}
        className="self-start text-sm font-semibold text-stone-400 hover:text-stone-600 mb-5 flex items-center gap-1.5"
      >
        ← Activities
      </button>

      {/* Header */}
      <div className="flex items-center gap-2 mb-4">
        <span className="text-2xl">📅</span>
        <div>
          <p className="text-xs font-bold text-sky-600 uppercase tracking-widest">Story Order</p>
          <p className="text-stone-500 text-xs">Tap in the order it happened</p>
        </div>
      </div>

      {/* Prompt */}
      <div className="bg-sky-50 rounded-2xl px-4 py-3 mb-2 border border-sky-100">
        <p className="text-stone-800 font-semibold text-sm leading-relaxed">{prompt}</p>
      </div>

      {/* Next position hint */}
      {!checked && !allTapped && (
        <p className="text-center text-sky-600 font-bold text-sm my-3 animate-pulse">
          What happened {ORDINAL[tapped.length]}? Tap it!
        </p>
      )}
      {!checked && allTapped && (
        <p className="text-center text-green-600 font-bold text-sm my-3">
          All placed! Tap Check to see how you did.
        </p>
      )}

      {/* Items */}
      {!checked ? (
        <div className="space-y-2 flex-1 overflow-y-auto my-2">
          {shuffled.map(item => {
            const rank = tapped.indexOf(item.id);
            const isRanked = rank !== -1;
            return (
              <button
                key={item.id}
                onClick={() => handleTap(item)}
                className={`w-full flex items-center gap-3 rounded-2xl px-4 py-3.5 border-2 transition-all active:scale-[0.97] text-left ${
                  isRanked
                    ? 'bg-sky-100 border-sky-400'
                    : 'bg-white border-stone-100 hover:border-sky-200'
                }`}
              >
                <span className="text-2xl shrink-0">{item.emoji}</span>
                <p className="flex-1 text-stone-800 font-semibold text-sm leading-snug">{item.label}</p>
                <div
                  className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm shrink-0 transition-all ${
                    isRanked
                      ? 'bg-sky-500 text-white'
                      : 'bg-stone-100 text-stone-400'
                  }`}
                >
                  {isRanked ? rank + 1 : '?'}
                </div>
              </button>
            );
          })}
        </div>
      ) : (
        /* Results view */
        <div className="space-y-2 flex-1 overflow-y-auto my-2">
          {sortedByOrder.map((item, i) => {
            const isCorrect = correct[i];
            return (
              <div
                key={item.id}
                className={`flex items-center gap-3 rounded-2xl px-4 py-3.5 border-2 ${
                  isCorrect ? 'bg-green-50 border-green-300' : 'bg-red-50 border-red-200'
                }`}
              >
                <span className="text-xl shrink-0">{item.emoji}</span>
                <p className="flex-1 text-stone-800 font-semibold text-sm leading-snug">{item.label}</p>
                <span className="text-lg shrink-0">{isCorrect ? '✅' : '❌'}</span>
              </div>
            );
          })}
        </div>
      )}

      {/* Result / CTA */}
      {checked ? (
        <div className={`rounded-2xl px-5 py-3 text-center mt-2 fade-in ${perfect ? 'bg-green-50 border border-green-200' : 'bg-amber-50 border border-amber-200'}`}>
          <p className="font-bold text-stone-800 mb-1">{perfect ? '🎉 Perfect order!' : '🌱 Good try!'}</p>
          <div className="flex items-center justify-center gap-2 mt-1">
            <span className="text-lg">🌱</span>
            <span className="font-bold text-stone-700 text-sm">+{perfect ? SEEDS_PERFECT : SEEDS_PARTIAL} Seeds</span>
          </div>
          {done && <p className="text-stone-400 text-xs mt-2 animate-pulse">Returning to story…</p>}
        </div>
      ) : (
        allTapped && (
          <button
            onClick={handleCheck}
            className="mt-2 w-full py-4 rounded-2xl bg-green-500 text-white font-bold text-base hover:bg-green-600 active:scale-95 transition-all shadow-md"
          >
            Check! ✓
          </button>
        )
      )}
    </div>
  );
}
