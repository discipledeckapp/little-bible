'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import type { Chapter, AppMode } from '@/types';
import { getStoredMode, storeMode } from '@/lib/mode';
import ChildModeReader from './ChildModeReader';
import FamilyModeReader from './FamilyModeReader';
import ReviewModeReader from './ReviewModeReader';
import PinModal from './PinModal';

interface ChapterPageClientProps {
  chapter: Chapter;
  bookSlug: string;
  availableChapters?: number[];
  totalChapters?: number;
  nextChapterNum?: number;
}

const MODES: { id: AppMode; label: string; icon: string }[] = [
  { id: 'child',  label: 'Child',  icon: '📖' },
  { id: 'family', label: 'Family', icon: '❤️' },
  { id: 'review', label: 'Review', icon: '🔍' },
];

const MODE_ACTIVE: Record<AppMode, string> = {
  child:  'bg-amber-500 text-white shadow-sm',
  family: 'bg-emerald-500 text-white shadow-sm',
  review: 'bg-stone-700 text-white shadow-sm',
};

export default function ChapterPageClient({
  chapter,
  bookSlug,
  availableChapters = [],
  totalChapters = 0,
  nextChapterNum,
}: ChapterPageClientProps) {
  const [mode, setMode]                     = useState<AppMode>('child');
  const [mounted, setMounted]               = useState(false);
  const [showPin, setShowPin]               = useState(false);
  const [reviewUnlocked, setReviewUnlocked] = useState(false);

  useEffect(() => {
    setMode(getStoredMode());
    setMounted(true);
  }, []);

  const switchMode = (m: AppMode) => {
    if (m === 'review' && !reviewUnlocked) {
      setShowPin(true);
      return;
    }
    setMode(m);
    storeMode(m);
  };

  const handlePinUnlock = () => {
    setShowPin(false);
    setReviewUnlocked(true);
    setMode('review');
    storeMode('review');
  };

  if (!mounted) {
    return (
      <div className="flex justify-center py-12">
        <div className="w-8 h-8 border-4 border-amber-200 border-t-amber-500 rounded-full animate-spin" />
      </div>
    );
  }

  const prevCh = availableChapters.filter(c => c < chapter.chapter).pop();
  const nextCh = availableChapters.find(c => c > chapter.chapter);

  return (
    <div>
      {showPin && <PinModal onUnlock={handlePinUnlock} />}

      {/* ── Chapter navigation bar ── */}
      {(availableChapters.length > 0 || totalChapters > 0) && (
        <div className="flex items-center justify-between mb-4 bg-stone-50 rounded-2xl px-4 py-2.5 border border-stone-100">
          {prevCh ? (
            <Link
              href={`/${bookSlug}/${prevCh}`}
              className="flex items-center gap-1.5 text-sm font-bold text-amber-700 hover:text-amber-900 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded px-1 py-1 active:scale-95"
              aria-label={`Previous chapter: ${chapter.book} ${prevCh}`}
            >
              <span aria-hidden="true">←</span>
              <span>Ch {prevCh}</span>
            </Link>
          ) : <div />}

          <Link
            href={`/${bookSlug}`}
            className="text-xs font-bold text-amber-600 hover:text-amber-800 uppercase tracking-widest transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded px-2 py-1 hover:bg-amber-50"
            aria-label={`All chapters of ${chapter.book}`}
            title="Tap to see all chapters"
          >
            {chapter.book} · Ch {chapter.chapter} of {totalChapters} ▾
          </Link>

          {nextCh ? (
            <Link
              href={`/${bookSlug}/${nextCh}`}
              className="flex items-center gap-1.5 text-sm font-bold text-amber-700 hover:text-amber-900 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded px-1 py-1 active:scale-95"
              aria-label={`Next chapter: ${chapter.book} ${nextCh}`}
            >
              <span>Ch {nextCh}</span>
              <span aria-hidden="true">→</span>
            </Link>
          ) : <div />}
        </div>
      )}

      {/* ── Persistent mode toggle ── */}
      <div
        role="group"
        aria-label="Reading mode"
        className="flex bg-stone-100 rounded-2xl p-1 gap-1 mb-6"
      >
        {MODES.map(({ id, label, icon }) => (
          <button
            key={id}
            onClick={() => switchMode(id)}
            className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl text-sm font-bold transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 active:scale-95 ${
              mode === id
                ? MODE_ACTIVE[id]
                : 'text-stone-500 hover:text-stone-700 hover:bg-stone-200/60'
            }`}
            aria-pressed={mode === id}
            aria-label={
              id === 'review'
                ? 'Review mode — full KJV comparison and annotations (parent)'
                : id === 'family'
                ? 'Family mode — 5-step devotion flow'
                : 'Child mode — simple Bible reading'
            }
          >
            <span aria-hidden="true">{icon}</span>
            {label}
          </button>
        ))}
      </div>

      {/* ── Chapter header ── */}
      <div className="mb-6">
        <p className="text-amber-600 text-sm font-extrabold uppercase tracking-[0.15em] mb-0.5">
          {chapter.book}
        </p>
        <h1 className="text-3xl sm:text-4xl font-extrabold text-stone-800 leading-tight font-display">
          Chapter {chapter.chapter}
        </h1>
        {chapter.main_lesson && mode !== 'child' && (
          <p className="text-stone-400 text-sm mt-1.5 max-w-sm leading-snug">
            {chapter.main_lesson}
          </p>
        )}
      </div>

      {/* ── Reader ── */}
      {mode === 'child'  && <ChildModeReader  chapter={chapter} bookSlug={bookSlug} nextChapterNum={nextChapterNum} />}
      {mode === 'family' && <FamilyModeReader chapter={chapter} bookSlug={bookSlug} />}
      {mode === 'review' && <ReviewModeReader chapter={chapter} />}
    </div>
  );
}
