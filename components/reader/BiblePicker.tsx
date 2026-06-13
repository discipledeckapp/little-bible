'use client';

import { useState, useCallback, useEffect, useRef } from 'react';
import { BIBLE_BOOKS } from '@/lib/bibleBooks';

interface BiblePickerProps {
  bookSlug: string;
  chapterNum: number;
  verseNum: number;
  availableChapters: number[];
  verseCount: number;
  onNavigate: (bookSlug: string, chapter: number, verse: number) => void;
}

type Step = 'book' | 'chapter' | 'verse';

// Module-level cache so repeated opens don't refetch
const bookIndexCache = new Map<string, number[]>();
const verseCountCache = new Map<string, number>();

export default function BiblePicker({
  bookSlug,
  chapterNum,
  verseNum,
  availableChapters,
  verseCount,
  onNavigate,
}: BiblePickerProps) {
  const [open, setOpen]                     = useState(false);
  const [step, setStep]                     = useState<Step>('book');
  const [pickedBook, setPickedBook]         = useState(bookSlug);
  const [pickedChapter, setPickedChapter]   = useState(chapterNum);
  const [chapterList, setChapterList]       = useState<{ ch: number; available: boolean }[]>([]);
  const [pickedVerseCount, setPickedVerseCount] = useState(verseCount);
  const [loading, setLoading]               = useState(false);
  const [availableBooks, setAvailableBooks] = useState<Set<string>>(new Set());
  const scrollRef                           = useRef<HTMLDivElement>(null);

  const pickedBookMeta = BIBLE_BOOKS.find(b => b.slug === pickedBook);
  const currentBookMeta = BIBLE_BOOKS.find(b => b.slug === bookSlug);

  // Fetch available books once
  useEffect(() => {
    fetch('/data/en/index.json')
      .then(r => r.json())
      .then((data: { slug: string }[]) => {
        setAvailableBooks(new Set(data.map(d => d.slug)));
      })
      .catch(() => {});
  }, []);

  const resetAndOpen = useCallback((startStep: Step) => {
    setPickedBook(bookSlug);
    setPickedChapter(chapterNum);
    setPickedVerseCount(verseCount);
    setChapterList(
      buildChapterList(bookSlug, availableChapters, BIBLE_BOOKS.find(b => b.slug === bookSlug)?.totalChapters ?? 0)
    );
    setStep(startStep);
    setOpen(true);
    setTimeout(() => scrollRef.current?.scrollTo(0, 0), 50);
  }, [bookSlug, chapterNum, verseCount, availableChapters]);

  const close = () => setOpen(false);

  const goBack = () => {
    if (step === 'verse') { setStep('chapter'); return; }
    if (step === 'chapter') { setStep('book'); return; }
    close();
  };

  // Book selection
  const handleBookSelect = async (slug: string) => {
    const meta = BIBLE_BOOKS.find(b => b.slug === slug);
    if (!meta) return;
    setPickedBook(slug);

    if (slug === bookSlug) {
      // Already have chapters for current book
      setChapterList(buildChapterList(slug, availableChapters, meta.totalChapters));
      setStep('chapter');
      scrollRef.current?.scrollTo(0, 0);
      return;
    }

    setLoading(true);
    let available: number[] = [];
    if (bookIndexCache.has(slug)) {
      available = bookIndexCache.get(slug)!;
    } else {
      try {
        const res = await fetch(`/data/en/${slug}/index.json`);
        if (res.ok) {
          const data: { chapter: number }[] = await res.json();
          available = data.map(c => c.chapter);
          bookIndexCache.set(slug, available);
        }
      } catch { /* book has no content */ }
    }
    setChapterList(buildChapterList(slug, available, meta.totalChapters));
    setLoading(false);
    setStep('chapter');
    scrollRef.current?.scrollTo(0, 0);
  };

  // Chapter selection
  const handleChapterSelect = async (ch: number, available: boolean) => {
    if (!available) return;
    setPickedChapter(ch);

    // Same chapter as currently loaded — use existing verse count
    if (pickedBook === bookSlug && ch === chapterNum) {
      setPickedVerseCount(verseCount);
      setStep('verse');
      scrollRef.current?.scrollTo(0, 0);
      return;
    }

    const cacheKey = `${pickedBook}:${ch}`;
    if (verseCountCache.has(cacheKey)) {
      setPickedVerseCount(verseCountCache.get(cacheKey)!);
      setStep('verse');
      scrollRef.current?.scrollTo(0, 0);
      return;
    }

    setLoading(true);
    try {
      const chStr = String(ch).padStart(2, '0');
      const res = await fetch(`/data/en/${pickedBook}/${pickedBook}_chapter_${chStr}.json`);
      if (res.ok) {
        const data = await res.json();
        const count = data.verses?.length ?? 0;
        verseCountCache.set(cacheKey, count);
        setPickedVerseCount(count);
      }
    } catch { /* leave verseCount at 0 */ }
    setLoading(false);
    setStep('verse');
    scrollRef.current?.scrollTo(0, 0);
  };

  // Verse selection
  const handleVerseSelect = (v: number) => {
    close();
    onNavigate(pickedBook, pickedChapter, v);
  };

  const stepTitle =
    step === 'book'
      ? 'Choose Book'
      : step === 'chapter'
      ? `${pickedBookMeta?.name ?? pickedBook} — Chapter`
      : `${pickedBookMeta?.name ?? pickedBook} ${pickedChapter} — Verse`;

  return (
    <>
      {/* ── Trigger: three-segment reference bar ── */}
      <div className="flex items-center bg-stone-100 rounded-2xl p-1 gap-0.5" role="navigation" aria-label="Bible reference picker">
        <button
          onClick={() => resetAndOpen('book')}
          className="flex items-center gap-1 px-3 py-2 rounded-xl text-sm font-bold text-stone-700 hover:bg-white hover:shadow-sm transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 active:scale-95"
          aria-label={`Book: ${currentBookMeta?.name ?? bookSlug}. Tap to change.`}
        >
          <span aria-hidden="true">📖</span>
          {currentBookMeta?.name ?? bookSlug}
          <span className="text-stone-400 text-[10px]" aria-hidden="true">▾</span>
        </button>

        <span className="text-stone-300 text-xs select-none" aria-hidden="true">·</span>

        <button
          onClick={() => resetAndOpen('chapter')}
          className="flex items-center gap-1 px-3 py-2 rounded-xl text-sm font-bold text-stone-700 hover:bg-white hover:shadow-sm transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 active:scale-95"
          aria-label={`Chapter ${chapterNum}. Tap to change.`}
        >
          Ch {chapterNum}
          <span className="text-stone-400 text-[10px]" aria-hidden="true">▾</span>
        </button>

        <span className="text-stone-300 text-xs select-none" aria-hidden="true">:</span>

        <button
          onClick={() => resetAndOpen('verse')}
          className="flex items-center gap-1 px-3 py-2 rounded-xl text-sm font-bold text-stone-700 hover:bg-white hover:shadow-sm transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 active:scale-95"
          aria-label={`Verse ${verseNum}. Tap to jump to a verse.`}
        >
          v.{verseNum}
          <span className="text-stone-400 text-[10px]" aria-hidden="true">▾</span>
        </button>
      </div>

      {/* ── Bottom sheet overlay ── */}
      {open && (
        <div className="fixed inset-0 z-50 flex flex-col justify-end" role="dialog" aria-modal="true" aria-label="Bible navigator">
          {/* Backdrop */}
          <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={close} aria-hidden="true" />

          {/* Sheet */}
          <div className="relative bg-white rounded-t-3xl max-h-[88vh] flex flex-col shadow-2xl">

            {/* Drag handle */}
            <div className="flex justify-center pt-3 pb-0" aria-hidden="true">
              <div className="w-10 h-1.5 bg-stone-200 rounded-full" />
            </div>

            {/* Header */}
            <div className="flex items-center justify-between px-5 py-3.5 border-b border-stone-100">
              <button
                onClick={goBack}
                className="flex items-center gap-1.5 text-sm font-bold text-amber-700 hover:text-amber-900 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded-lg px-2 py-1"
                aria-label={step === 'book' ? 'Close' : 'Back'}
              >
                {step === 'book' ? '✕' : '← Back'}
              </button>

              <h2 className="text-sm font-extrabold text-stone-800 text-center flex-1 px-4 truncate">
                {stepTitle}
              </h2>

              <button
                onClick={close}
                className="text-sm font-bold text-stone-400 hover:text-stone-600 focus:outline-none focus-visible:ring-2 focus-visible:ring-stone-400 rounded-lg px-2 py-1"
                aria-label="Close picker"
              >
                ✕
              </button>
            </div>

            {/* Scrollable content */}
            <div ref={scrollRef} className="overflow-y-auto flex-1 p-4 pb-8">

              {/* Loading */}
              {loading && (
                <div className="flex justify-center py-12">
                  <div className="w-8 h-8 border-4 border-amber-200 border-t-amber-500 rounded-full animate-spin" />
                </div>
              )}

              {/* ── Book grid ── */}
              {step === 'book' && !loading && (
                <div className="space-y-5">
                  {(['OT', 'NT'] as const).map(testament => {
                    const groups = testament === 'OT'
                      ? ['The Law', 'History', 'Wisdom & Poetry', 'Major Prophets', 'Minor Prophets']
                      : ['Gospels', 'The Early Church', "Paul's Letters", 'General Letters', 'Prophecy'];

                    return (
                      <div key={testament}>
                        <p className="text-xs font-extrabold text-stone-400 uppercase tracking-widest mb-3">
                          {testament === 'OT' ? '— Old Testament' : '— New Testament'}
                        </p>
                        {groups.map(group => {
                          const books = BIBLE_BOOKS.filter(b => b.testament === testament && b.group === group);
                          if (!books.length) return null;
                          return (
                            <div key={group} className="mb-4">
                              <p className="text-[10px] font-bold text-stone-300 uppercase tracking-wider mb-2 pl-1">{group}</p>
                              <div className="grid grid-cols-4 gap-2">
                                {books.map(book => {
                                  const isAvailable = availableBooks.has(book.slug);
                                  const isCurrent = book.slug === bookSlug;
                                  return (
                                    <button
                                      key={book.slug}
                                      onClick={() => handleBookSelect(book.slug)}
                                      className={`flex flex-col items-center gap-1 py-3 px-1 rounded-2xl border text-center transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                                        isCurrent
                                          ? 'bg-amber-500 border-amber-500 text-white shadow-md ring-2 ring-amber-300'
                                          : isAvailable
                                          ? 'bg-amber-50 border-amber-200 text-amber-900 hover:bg-amber-100 hover:border-amber-300'
                                          : 'bg-stone-50 border-stone-100 text-stone-400 cursor-pointer'
                                      }`}
                                      aria-label={`${book.name}${isAvailable ? '' : ' — coming soon'}`}
                                    >
                                      <span className="text-lg leading-none" aria-hidden="true">{book.emoji}</span>
                                      <span className="text-[10px] font-bold leading-tight">{book.abbrev}</span>
                                      {!isAvailable && (
                                        <span className="text-[8px] text-stone-300 leading-none font-semibold">Soon</span>
                                      )}
                                    </button>
                                  );
                                })}
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    );
                  })}
                </div>
              )}

              {/* ── Chapter grid ── */}
              {step === 'chapter' && !loading && (
                <>
                  {chapterList.some(c => c.available) ? (
                    <div className="grid grid-cols-5 gap-2">
                      {chapterList.map(({ ch, available }) => {
                        const isCurrent = pickedBook === bookSlug && ch === chapterNum;
                        return (
                          <button
                            key={ch}
                            onClick={() => handleChapterSelect(ch, available)}
                            disabled={!available}
                            className={`flex items-center justify-center py-3.5 rounded-2xl font-extrabold text-base transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                              isCurrent
                                ? 'bg-amber-500 text-white shadow-md ring-2 ring-amber-300'
                                : available
                                ? 'bg-amber-50 border border-amber-200 text-amber-900 hover:bg-amber-100'
                                : 'bg-stone-50 border border-stone-100 text-stone-300 cursor-not-allowed'
                            }`}
                            aria-label={`Chapter ${ch}${available ? '' : ' — coming soon'}`}
                          >
                            {ch}
                          </button>
                        );
                      })}
                    </div>
                  ) : (
                    <div className="text-center py-12 text-stone-400">
                      <p className="text-4xl mb-3" aria-hidden="true">{pickedBookMeta?.emoji ?? '📖'}</p>
                      <p className="font-extrabold text-stone-600 text-lg mb-1">{pickedBookMeta?.name}</p>
                      <p className="font-semibold">Coming soon</p>
                      <p className="text-sm mt-1">This book is being adapted right now.</p>
                    </div>
                  )}
                </>
              )}

              {/* ── Verse grid ── */}
              {step === 'verse' && !loading && pickedVerseCount > 0 && (
                <div className="grid grid-cols-5 gap-2">
                  {Array.from({ length: pickedVerseCount }, (_, i) => {
                    const v = i + 1;
                    const isCurrent = pickedBook === bookSlug && pickedChapter === chapterNum && v === verseNum;
                    return (
                      <button
                        key={v}
                        onClick={() => handleVerseSelect(v)}
                        className={`flex items-center justify-center py-3.5 rounded-2xl font-extrabold text-base transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                          isCurrent
                            ? 'bg-amber-500 text-white shadow-md ring-2 ring-amber-300'
                            : 'bg-amber-50 border border-amber-200 text-amber-900 hover:bg-amber-100'
                        }`}
                        aria-label={`Verse ${v}`}
                        aria-current={isCurrent ? 'true' : undefined}
                      >
                        {v}
                      </button>
                    );
                  })}
                </div>
              )}

            </div>
          </div>
        </div>
      )}
    </>
  );
}

function buildChapterList(
  slug: string,
  available: number[],
  total: number
): { ch: number; available: boolean }[] {
  return Array.from({ length: total }, (_, i) => ({
    ch: i + 1,
    available: available.includes(i + 1),
  }));
}
