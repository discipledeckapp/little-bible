'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import type { Chapter, AppMode } from '@/types';
import { getStoredMode, storeMode } from '@/lib/mode';
import ChildModeReader from './ChildModeReader';
import FamilyModeReader from './FamilyModeReader';
import ReviewModeReader from './ReviewModeReader';
import PinModal from './PinModal';
import BiblePicker from './BiblePicker';
import dynamic from 'next/dynamic';

const MemberSelector = dynamic(() => import('@/components/family/MemberSelector'), { ssr: false });

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
  const router       = useRouter();
  const searchParams = useSearchParams();

  const [mode, setMode]                     = useState<AppMode>('child');
  const [mounted, setMounted]               = useState(false);
  const [showPin, setShowPin]               = useState(false);
  const [reviewUnlocked, setReviewUnlocked] = useState(false);

  // Track which verse is shown so BiblePicker can display it
  const [displayVerse, setDisplayVerse] = useState(1);

  useEffect(() => {
    setMode(getStoredMode());
    const v = parseInt(searchParams.get('v') ?? '1', 10);
    setDisplayVerse(isNaN(v) || v < 1 ? 1 : v);
    setMounted(true);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // When URL ?v param changes (after BiblePicker navigation), update displayVerse
  useEffect(() => {
    if (!mounted) return;
    const v = parseInt(searchParams.get('v') ?? '1', 10);
    setDisplayVerse(isNaN(v) || v < 1 ? 1 : v);
  }, [searchParams, mounted]);

  const switchMode = (m: AppMode) => {
    if (m === 'review' && !reviewUnlocked) { setShowPin(true); return; }
    setMode(m);
    storeMode(m);
  };

  const handlePinUnlock = () => {
    setShowPin(false);
    setReviewUnlocked(true);
    setMode('review');
    storeMode('review');
  };

  // Called by BiblePicker when user selects a book/chapter/verse
  const handleNavigate = (newBook: string, newChapter: number, newVerse: number) => {
    if (newBook === bookSlug && newChapter === chapter.chapter) {
      // Same chapter — update URL param to trigger verse jump via key remount
      const params = new URLSearchParams(searchParams.toString());
      params.set('v', String(newVerse));
      router.push(`/${bookSlug}/${chapter.chapter}?${params.toString()}`);
    } else {
      // Different chapter or book — full navigation
      router.push(`/${newBook}/${newChapter}?v=${newVerse}`);
    }
  };

  // Initial verse derived from URL search param (stable across renders)
  const initialVerse = (() => {
    const v = parseInt(searchParams.get('v') ?? '1', 10);
    return isNaN(v) || v < 1 ? 1 : Math.min(v, chapter.verses.length);
  })();

  if (!mounted) {
    return (
      <div className="flex justify-center py-12">
        <div className="w-8 h-8 border-4 border-amber-200 border-t-amber-500 rounded-full animate-spin" />
      </div>
    );
  }

  const prevCh = availableChapters.filter(c => c < chapter.chapter).pop();
  const nextCh = availableChapters.find(c => c > chapter.chapter);

  // Key on initialVerse so readers remount when the verse picker changes it
  const readerKey = `${bookSlug}-${chapter.chapter}-${initialVerse}`;

  return (
    <div>
      {showPin && <PinModal onUnlock={handlePinUnlock} />}

      {/* ── Bible Picker + Chapter nav ── */}
      <div className="mb-4 space-y-2">
        {/* Top row: reference picker + member selector */}
        <div className="flex items-center justify-between gap-2">
          <BiblePicker
            bookSlug={bookSlug}
            chapterNum={chapter.chapter}
            verseNum={displayVerse}
            availableChapters={availableChapters}
            verseCount={chapter.verses.length}
            onNavigate={handleNavigate}
          />
          <MemberSelector />
        </div>

        {/* Chapter prev/next row */}
        {(availableChapters.length > 0 || totalChapters > 0) && (
          <div className="flex items-center justify-between bg-stone-50 rounded-2xl px-4 py-2 border border-stone-100">
            {prevCh ? (
              <Link
                href={`/${bookSlug}/${prevCh}`}
                className="flex items-center gap-1.5 text-sm font-bold text-amber-700 hover:text-amber-900 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded px-1 py-1 active:scale-95"
                aria-label={`Previous chapter: ${chapter.book} ${prevCh}`}
              >
                <span aria-hidden="true">←</span> Ch {prevCh}
              </Link>
            ) : <div />}

            <Link
              href={`/${bookSlug}`}
              className="text-xs font-bold text-stone-400 hover:text-amber-700 uppercase tracking-widest transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded px-2 py-1 hover:bg-amber-50"
              aria-label={`All chapters of ${chapter.book}`}
            >
              {totalChapters > 0 ? `${chapter.chapter} of ${totalChapters} chapters` : `Chapter ${chapter.chapter}`}
            </Link>

            {nextCh ? (
              <Link
                href={`/${bookSlug}/${nextCh}`}
                className="flex items-center gap-1.5 text-sm font-bold text-amber-700 hover:text-amber-900 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded px-1 py-1 active:scale-95"
                aria-label={`Next chapter: ${chapter.book} ${nextCh}`}
              >
                Ch {nextCh} <span aria-hidden="true">→</span>
              </Link>
            ) : <div />}
          </div>
        )}
      </div>

      {/* ── Mode toggle ── */}
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

      {/* ── Readers — keyed on initialVerse to remount on verse jump ── */}
      {mode === 'child' && (
        <ChildModeReader
          key={`child-${readerKey}`}
          chapter={chapter}
          bookSlug={bookSlug}
          nextChapterNum={nextChapterNum}
          initialVerse={initialVerse}
          onVerseChange={setDisplayVerse}
        />
      )}
      {mode === 'family' && (
        <FamilyModeReader
          key={`family-${readerKey}`}
          chapter={chapter}
          bookSlug={bookSlug}
          initialVerse={initialVerse}
        />
      )}
      {mode === 'review' && (
        <ReviewModeReader chapter={chapter} />
      )}
    </div>
  );
}
