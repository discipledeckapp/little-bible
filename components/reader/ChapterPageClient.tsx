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

const MODE_META: Record<AppMode, {
  label: string;
  sublabel: string;
  icon: string;
  activeClass: string;
  ringClass: string;
  description: string;
}> = {
  child: {
    label: 'Bible Time',
    sublabel: 'Solo',
    icon: '📖',
    activeClass: 'bg-amber-500 text-white shadow-sm shadow-amber-200',
    ringClass: 'focus-visible:ring-amber-400',
    description: 'Read verse by verse at your own pace',
  },
  family: {
    label: 'Family',
    sublabel: 'Together',
    icon: '❤️',
    activeClass: 'bg-emerald-500 text-white shadow-sm shadow-emerald-200',
    ringClass: 'focus-visible:ring-emerald-400',
    description: '5-step devotion with discussion, prayer, and action',
  },
  review: {
    label: 'Parent',
    sublabel: 'Review',
    icon: '🔍',
    activeClass: 'bg-stone-700 text-white shadow-sm shadow-stone-200',
    ringClass: 'focus-visible:ring-stone-400',
    description: 'KJV comparison, annotations, and chapter overview',
  },
};

export default function ChapterPageClient({ chapter, bookSlug, availableChapters = [], totalChapters = 0, nextChapterNum }: ChapterPageClientProps) {
  const [mode, setMode]             = useState<AppMode>('child');
  const [mounted, setMounted]       = useState(false);
  const [showPin, setShowPin]       = useState(false);
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

  const currentMeta = MODE_META[mode];

  return (
    <div>
      {/* PIN modal */}
      {showPin && <PinModal onUnlock={handlePinUnlock} />}

      {/* Chapter navigation */}
      {(availableChapters.length > 0 || totalChapters > 0) && (() => {
        const prevCh = availableChapters.filter(c => c < chapter.chapter).pop();
        const nextCh = availableChapters.find(c => c > chapter.chapter);
        return (
          <div className="flex items-center justify-between mb-5 bg-stone-50 rounded-2xl px-4 py-2.5 border border-stone-100">
            {prevCh ? (
              <Link
                href={`/${bookSlug}/${prevCh}`}
                className="flex items-center gap-1.5 text-sm font-bold text-amber-700 hover:text-amber-900 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded px-1 py-1 active:scale-95"
                aria-label={`Previous chapter: ${chapter.book} ${prevCh}`}
              >
                <span aria-hidden="true">←</span>
                <span>Ch {prevCh}</span>
              </Link>
            ) : (
              <div />
            )}
            <span className="text-xs font-bold text-stone-400 uppercase tracking-widest">
              {chapter.book} {chapter.chapter} of {totalChapters}
            </span>
            {nextCh ? (
              <Link
                href={`/${bookSlug}/${nextCh}`}
                className="flex items-center gap-1.5 text-sm font-bold text-amber-700 hover:text-amber-900 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded px-1 py-1 active:scale-95"
                aria-label={`Next chapter: ${chapter.book} ${nextCh}`}
              >
                <span>Ch {nextCh}</span>
                <span aria-hidden="true">→</span>
              </Link>
            ) : (
              <div />
            )}
          </div>
        );
      })()}

      {/* Chapter header */}
      <div className="mb-6">
        {/* Book + Chapter name */}
        <div className="flex flex-wrap items-start justify-between gap-4 mb-5">
          <div>
            <p className="text-amber-500 text-xs font-bold uppercase tracking-[0.2em] mb-1">
              {chapter.book}
            </p>
            <h1 className="text-3xl sm:text-4xl font-extrabold text-stone-800 leading-tight font-display">
              Chapter {chapter.chapter}
            </h1>
            {chapter.main_lesson && (
              <p className="text-stone-400 text-sm mt-1.5 max-w-xs leading-snug">
                {chapter.main_lesson}
              </p>
            )}
          </div>

          {/* Mode toggle — child and family only */}
          <div className="flex items-center gap-2 flex-shrink-0">
            <div
              role="group"
              aria-label="Reading mode"
              className="inline-flex bg-stone-100 rounded-2xl p-1 gap-1 flex-shrink-0"
            >
              {(['child', 'family'] as const).map((m) => {
                const meta = MODE_META[m];
                return (
                  <button
                    key={m}
                    onClick={() => switchMode(m)}
                    className={`flex flex-col items-center gap-0 px-4 py-2.5 rounded-xl text-xs font-bold transition-all focus:outline-none focus-visible:ring-2 ${meta.ringClass} ${
                      mode === m ? meta.activeClass : 'text-stone-500 hover:text-stone-700 hover:bg-stone-200/60'
                    }`}
                    aria-label={`Switch to ${meta.label} mode`}
                    aria-pressed={mode === m}
                  >
                    <span className="text-base leading-none mb-0.5" aria-hidden="true">{meta.icon}</span>
                    <span className="leading-none">{meta.label}</span>
                  </button>
                );
              })}
            </div>
            {mode !== 'review' && (
              <button
                onClick={() => switchMode('review')}
                className="text-xs text-stone-400 hover:text-stone-600 font-semibold flex items-center gap-1 px-2 py-1 rounded-lg hover:bg-stone-100 transition-colors focus:outline-none"
                aria-label="Parent review mode"
                title="Parent review — tap to unlock"
              >
                <span aria-hidden="true">👨‍👩‍👧</span>
                <span className="hidden sm:inline">Parent</span>
              </button>
            )}
          </div>
        </div>

        {/* Active mode context strip */}
        <div className={`rounded-2xl px-4 py-2.5 text-sm flex items-center gap-2 ${
          mode === 'child'
            ? 'bg-amber-50 text-amber-800 border border-amber-100'
            : mode === 'family'
            ? 'bg-emerald-50 text-emerald-800 border border-emerald-100'
            : 'bg-stone-100 text-stone-600 border border-stone-200'
        }`}>
          <span aria-hidden="true">{currentMeta.icon}</span>
          <span className="font-semibold">{currentMeta.label}:</span>
          <span className="font-normal">{currentMeta.description}</span>
        </div>
      </div>

      {/* Reader */}
      {mode === 'child' && (
        <ChildModeReader chapter={chapter} bookSlug={bookSlug} nextChapterNum={nextChapterNum} />
      )}
      {mode === 'family' && (
        <FamilyModeReader chapter={chapter} bookSlug={bookSlug} />
      )}
      {mode === 'review' && (
        <ReviewModeReader chapter={chapter} />
      )}
    </div>
  );
}
