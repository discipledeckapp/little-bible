'use client';

import { useState } from 'react';
import type { ActivityApplication } from '@/types/activities';

interface ApplicationPromptProps {
  data: ActivityApplication;
  onComplete: (seedsEarned: number) => void;
  onBack: () => void;
}

const SEEDS_FOR_APPLICATION = 2;

export default function ApplicationPrompt({ data, onComplete, onBack }: ApplicationPromptProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [done, setDone] = useState(false);

  function handleSelect(id: string) {
    if (done) return;
    setSelectedId(id);
    setDone(true);
    setTimeout(() => onComplete(SEEDS_FOR_APPLICATION), 2200);
  }

  const selected = data.options.find(o => o.id === selectedId);

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
      <div className="flex items-center gap-2 mb-6">
        <span className="text-2xl">💭</span>
        <div>
          <p className="text-xs font-bold text-purple-600 uppercase tracking-widest">Think About It</p>
          <p className="text-stone-500 text-xs">No wrong answers — all choices lead to reflection</p>
        </div>
      </div>

      {/* Question */}
      <div className="bg-purple-50 rounded-2xl px-5 py-4 mb-6 border border-purple-100">
        <p className="text-stone-800 text-lg font-semibold leading-relaxed" style={{ fontFamily: 'var(--font-display)' }}>
          {data.question}
        </p>
      </div>

      {/* Options */}
      {!done ? (
        <div className="space-y-3 flex-1">
          {data.options.map(opt => (
            <button
              key={opt.id}
              onClick={() => handleSelect(opt.id)}
              className="w-full flex items-center gap-4 bg-white rounded-2xl px-5 py-4 border-2 border-stone-100 hover:border-purple-300 hover:bg-purple-50 active:scale-[0.97] transition-all text-left"
            >
              <span className="text-3xl shrink-0">{opt.emoji}</span>
              <p className="font-semibold text-stone-800 text-base leading-snug">{opt.label}</p>
            </button>
          ))}
        </div>
      ) : (
        <div className="flex-1 flex flex-col items-center justify-center text-center gap-4 fade-in">
          {/* Selected answer */}
          <div className="text-6xl mb-2">{selected?.emoji}</div>
          <p className="text-lg font-bold text-stone-800" style={{ fontFamily: 'var(--font-display)' }}>
            {selected?.label}
          </p>

          {/* Follow-up message */}
          <div className="bg-amber-50 rounded-2xl px-5 py-4 border border-amber-100 max-w-xs">
            <p className="text-stone-700 text-sm leading-relaxed">{data.followUp}</p>
          </div>

          {/* Seeds earned */}
          <div className="flex items-center gap-2 bg-green-100 rounded-full px-5 py-2.5">
            <span className="text-xl">🌱</span>
            <span className="font-bold text-green-800 text-base">+{SEEDS_FOR_APPLICATION} Wisdom Seeds</span>
          </div>

          <p className="text-stone-400 text-xs mt-1 animate-pulse">Returning to story…</p>
        </div>
      )}
    </div>
  );
}
