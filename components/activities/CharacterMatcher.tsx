'use client';

import { useState, useEffect } from 'react';
import type { ActivityMatchPair } from '@/types/activities';

interface CharacterMatcherProps {
  prompt: string;
  pairs: ActivityMatchPair[];
  onComplete: (seedsEarned: number, perfect: boolean) => void;
  onBack: () => void;
}

const SEEDS_PERFECT = 3;

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

export default function CharacterMatcher({ prompt, pairs, onComplete, onBack }: CharacterMatcherProps) {
  const [rightOrder, setRightOrder] = useState<ActivityMatchPair[]>([]);
  const [selectedLeft, setSelectedLeft] = useState<string | null>(null);
  const [matched, setMatched] = useState<Set<string>>(new Set());
  const [wrongFlash, setWrongFlash] = useState<{ left: string; right: string } | null>(null);
  const [done, setDone] = useState(false);

  useEffect(() => {
    setRightOrder(shuffle(pairs));
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function selectLeft(leftId: string) {
    if (wrongFlash || done) return;
    setSelectedLeft(prev => (prev === leftId ? null : leftId));
  }

  function selectRight(rightId: string) {
    if (!selectedLeft || wrongFlash || done) return;
    const pair = pairs.find(p => p.leftId === selectedLeft);
    if (!pair) return;

    if (pair.rightId === rightId) {
      const next = new Set(matched);
      next.add(selectedLeft);
      setMatched(next);
      setSelectedLeft(null);
      if (next.size === pairs.length) {
        setDone(true);
        setTimeout(() => onComplete(SEEDS_PERFECT, true), 1800);
      }
    } else {
      setWrongFlash({ left: selectedLeft, right: rightId });
      setTimeout(() => {
        setWrongFlash(null);
        setSelectedLeft(null);
      }, 700);
    }
  }

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
        <span className="text-2xl">🔗</span>
        <div>
          <p className="text-xs font-bold text-emerald-600 uppercase tracking-widest">Character Match</p>
          <p className="text-stone-500 text-xs">Tap left, then tap the match on the right</p>
        </div>
      </div>

      {/* Prompt */}
      <div className="bg-emerald-50 rounded-2xl px-4 py-3 mb-5 border border-emerald-100">
        <p className="text-stone-800 font-semibold text-sm leading-relaxed">{prompt}</p>
      </div>

      {/* Columns */}
      <div className="flex gap-3 flex-1 overflow-hidden">
        {/* Left column */}
        <div className="flex-1 space-y-2 overflow-y-auto">
          <p className="text-xs font-bold text-stone-400 uppercase tracking-wide text-center mb-2">Who</p>
          {pairs.map(pair => {
            const isMatched = matched.has(pair.leftId);
            const isSelected = selectedLeft === pair.leftId;
            const isWrong = wrongFlash?.left === pair.leftId;
            return (
              <button
                key={pair.leftId}
                onClick={() => selectLeft(pair.leftId)}
                disabled={isMatched || done}
                className={`w-full flex flex-col items-center gap-1 rounded-2xl px-2 py-3 border-2 transition-all active:scale-95 disabled:cursor-not-allowed ${
                  isMatched
                    ? 'bg-emerald-100 border-emerald-400 opacity-60'
                    : isWrong
                    ? 'bg-red-100 border-red-400'
                    : isSelected
                    ? 'bg-amber-100 border-amber-400 shadow-sm'
                    : 'bg-white border-stone-100 hover:border-emerald-200'
                }`}
              >
                <span className="text-2xl">{pair.leftEmoji}</span>
                <p className="text-xs font-semibold text-stone-700 text-center leading-tight">{pair.left}</p>
                {isMatched && <span className="text-green-500 text-xs">✓</span>}
              </button>
            );
          })}
        </div>

        {/* Arrow column */}
        <div className="flex flex-col pt-9 gap-2">
          {pairs.map(pair => (
            <div key={pair.leftId} className="h-[80px] flex items-center justify-center">
              <span className="text-stone-300 text-base">→</span>
            </div>
          ))}
        </div>

        {/* Right column */}
        <div className="flex-1 space-y-2 overflow-y-auto">
          <p className="text-xs font-bold text-stone-400 uppercase tracking-wide text-center mb-2">Match</p>
          {rightOrder.map(pair => {
            const isMatchedRight = matched.has(pair.leftId);
            const isWrong = wrongFlash?.right === pair.rightId;
            return (
              <button
                key={pair.rightId}
                onClick={() => selectRight(pair.rightId)}
                disabled={isMatchedRight || !selectedLeft || done}
                className={`w-full flex flex-col items-center gap-1 rounded-2xl px-2 py-3 border-2 transition-all active:scale-95 disabled:cursor-not-allowed ${
                  isMatchedRight
                    ? 'bg-emerald-100 border-emerald-400 opacity-60'
                    : isWrong
                    ? 'bg-red-100 border-red-400 animate-shake'
                    : selectedLeft
                    ? 'bg-white border-stone-200 hover:border-amber-300 hover:bg-amber-50 cursor-pointer'
                    : 'bg-white border-stone-100'
                }`}
              >
                <span className="text-2xl">{pair.rightEmoji}</span>
                <p className="text-xs font-semibold text-stone-700 text-center leading-tight">{pair.right}</p>
                {isMatchedRight && <span className="text-green-500 text-xs">✓</span>}
              </button>
            );
          })}
        </div>
      </div>

      {/* Instruction / done */}
      <div className="mt-4 text-center">
        {!done ? (
          <p className="text-stone-400 text-xs">
            {selectedLeft
              ? 'Now tap the matching item on the right →'
              : `${matched.size}/${pairs.length} matched — tap an item on the left to begin`}
          </p>
        ) : (
          <div className="bg-green-50 rounded-2xl px-5 py-3 border border-green-200 fade-in">
            <p className="font-bold text-green-800 mb-1">🎉 All matched!</p>
            <div className="flex items-center justify-center gap-2">
              <span className="text-lg">🌱</span>
              <span className="font-bold text-stone-700 text-sm">+{SEEDS_PERFECT} Seeds</span>
            </div>
            <p className="text-stone-400 text-xs mt-1 animate-pulse">Returning to story…</p>
          </div>
        )}
      </div>
    </div>
  );
}
