'use client';

import { useState, useEffect } from 'react';
import type { ActivityMemoryBuilder } from '@/types/activities';

interface MemoryBuilderProps {
  data: ActivityMemoryBuilder;
  onComplete: (seedsEarned: number, perfect: boolean) => void;
  onBack: () => void;
}

const SEEDS_PERFECT = 5;
const SEEDS_PARTIAL = 2;

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

export default function MemoryBuilder({ data, onComplete, onBack }: MemoryBuilderProps) {
  const words = data.phraseWords;

  const [bankWords, setBankWords] = useState<string[]>([]);
  const [slots, setSlots] = useState<(string | null)[]>(() => Array(words.length).fill(null));
  const [checked, setChecked] = useState(false);
  const [correctSlots, setCorrectSlots] = useState<boolean[]>([]);
  const [done, setDone] = useState(false);

  // Shuffle only on client to avoid hydration mismatch
  useEffect(() => {
    let shuffled = shuffle(words);
    let attempts = 0;
    while (shuffled.join(',') === words.join(',') && attempts < 8) {
      shuffled = shuffle(words);
      attempts++;
    }
    setBankWords(shuffled);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const allFilled = slots.every(s => s !== null);

  function tapBankWord(word: string) {
    if (checked) return;
    const firstEmpty = slots.indexOf(null);
    if (firstEmpty === -1) return;
    const newSlots = [...slots];
    newSlots[firstEmpty] = word;
    setSlots(newSlots);
    setBankWords(prev => {
      const idx = prev.indexOf(word);
      const next = [...prev];
      next.splice(idx, 1);
      return next;
    });
  }

  function tapSlot(idx: number) {
    if (checked) return;
    const word = slots[idx];
    if (!word) return;
    const newSlots = [...slots];
    newSlots[idx] = null;
    setSlots(newSlots);
    setBankWords(prev => [...prev, word]);
  }

  function handleCheck() {
    const results = slots.map((s, i) => s === words[i]);
    setCorrectSlots(results);
    setChecked(true);
    const perfect = results.every(Boolean);
    const seeds = perfect ? SEEDS_PERFECT : SEEDS_PARTIAL;
    setDone(true);
    setTimeout(() => onComplete(seeds, perfect), 2500);
  }

  const perfect = checked && correctSlots.every(Boolean);
  const score = checked ? correctSlots.filter(Boolean).length : 0;

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
        <span className="text-2xl">🔤</span>
        <div>
          <p className="text-xs font-bold text-amber-600 uppercase tracking-widest">Memory Builder</p>
          <p className="text-stone-500 text-xs">Tap words to build the phrase in order</p>
        </div>
      </div>

      {/* Verse ref */}
      <p className="text-xs font-semibold text-stone-400 mb-4 text-center">{data.verseRef}</p>

      {/* Slots */}
      <div className="flex flex-wrap gap-2 justify-center mb-6 min-h-[52px]">
        {slots.map((word, i) => {
          const slotColor = checked
            ? correctSlots[i]
              ? 'bg-green-100 border-green-400 text-green-800'
              : 'bg-red-100 border-red-400 text-red-800'
            : word
              ? 'bg-amber-100 border-amber-400 text-amber-900 cursor-pointer'
              : 'bg-stone-100 border-dashed border-stone-300 text-stone-400';
          return (
            <button
              key={i}
              onClick={() => tapSlot(i)}
              disabled={checked || !word}
              className={`min-w-[52px] px-3 py-2.5 rounded-xl border-2 text-sm font-bold transition-all ${slotColor}`}
            >
              {word ?? '___'}
            </button>
          );
        })}
      </div>

      {/* Instruction */}
      {!checked && (
        <p className="text-center text-stone-400 text-xs mb-4">
          {allFilled ? 'Ready? Check your answer!' : 'Tap a word below to place it'}
        </p>
      )}

      {/* Checked result */}
      {checked && (
        <div className={`rounded-2xl px-5 py-3 mb-4 text-center fade-in ${perfect ? 'bg-green-50 border border-green-200' : 'bg-amber-50 border border-amber-200'}`}>
          {perfect ? (
            <>
              <p className="text-2xl mb-1">🎉</p>
              <p className="font-bold text-green-800">Perfect!</p>
              <p className="text-green-700 text-sm">&ldquo;{words.join(' ')}&rdquo;</p>
            </>
          ) : (
            <>
              <p className="text-2xl mb-1">🌱</p>
              <p className="font-bold text-amber-800">{score}/{words.length} correct</p>
              <p className="text-amber-700 text-sm mt-1">The right order: &ldquo;{words.join(' ')}&rdquo;</p>
            </>
          )}
          <div className="mt-3 flex items-center justify-center gap-2">
            <span className="text-lg">🌱</span>
            <span className="font-bold text-stone-700 text-sm">+{perfect ? SEEDS_PERFECT : SEEDS_PARTIAL} Seeds</span>
          </div>
          {done && <p className="text-stone-400 text-xs mt-2 animate-pulse">Returning to story…</p>}
        </div>
      )}

      {/* Word bank */}
      <div className="flex-1 flex flex-col justify-end">
        <p className="text-xs font-bold text-stone-400 uppercase tracking-wide mb-3 text-center">
          {checked ? 'Done' : 'Word Bank'}
        </p>
        <div className="flex flex-wrap gap-2 justify-center">
          {bankWords.map((word, i) => (
            <button
              key={`${word}-${i}`}
              onClick={() => tapBankWord(word)}
              disabled={checked}
              className="px-4 py-2.5 bg-amber-500 hover:bg-amber-600 text-white rounded-xl text-sm font-bold active:scale-95 transition-all disabled:opacity-40"
            >
              {word}
            </button>
          ))}
        </div>

        {/* Check button */}
        {!checked && allFilled && (
          <button
            onClick={handleCheck}
            className="mt-5 w-full py-4 rounded-2xl bg-green-500 text-white font-bold text-base hover:bg-green-600 active:scale-95 transition-all shadow-md"
          >
            Check! ✓
          </button>
        )}
      </div>
    </div>
  );
}
