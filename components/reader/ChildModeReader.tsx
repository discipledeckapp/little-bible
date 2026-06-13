'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import type { Chapter, Badge } from '@/types';
import { speakText, stopSpeech, isSpeechSupported } from '@/lib/audio';
import {
  markVerseComplete,
  markChapterComplete,
  getChapterCompletedVerses,
  recordSession,
} from '@/lib/progress';
import IllustrationZone from './IllustrationZone';
import LumiMascot, { getLumiStage, getLumiLabel } from '@/components/mascot/LumiMascot';
import { getProgress } from '@/lib/progress';

const ENCOURAGEMENTS = [
  { text: 'Great listening!',   emoji: '🌟' },
  { text: "You're amazing!",    emoji: '⭐' },
  { text: 'God loves you!',     emoji: '❤️' },
  { text: 'Keep it up!',        emoji: '🎉' },
  { text: 'Wonderful!',         emoji: '🌈' },
  { text: 'Well done!',         emoji: '👏' },
  { text: 'You are so loved!',  emoji: '💛' },
  { text: 'Beautiful!',         emoji: '🌸' },
];

interface ChildModeReaderProps {
  chapter: Chapter;
  bookSlug: string;
  nextChapterNum?: number;
}

// Paginated dots: always shows at most MAX_DOTS, active centred
const MAX_DOTS = 9;
function getPaginatedRange(current: number, total: number) {
  if (total <= MAX_DOTS) return { start: 0, end: total - 1 };
  const half = Math.floor(MAX_DOTS / 2);
  const start = Math.max(0, Math.min(current - half, total - MAX_DOTS));
  return { start, end: start + MAX_DOTS - 1 };
}

const READER_MODE_KEY = 'little_bible_reader_mode';

export default function ChildModeReader({ chapter, bookSlug, nextChapterNum }: ChildModeReaderProps) {
  const router = useRouter();

  const hasLittleReader = chapter.verses.some((v) => !!v.little_reader_adaptation);

  const [verseIndex, setVerseIndex] = useState(() => {
    // Resume from last completed verse
    const done = getChapterCompletedVerses(bookSlug, chapter.chapter);
    const next = done.length < chapter.verses.length ? done.length : 0;
    return next;
  });

  const [littleReaderMode, setLittleReaderMode] = useState(() => {
    if (typeof window === 'undefined') return false;
    return localStorage.getItem(READER_MODE_KEY) === 'little';
  });

  const [speaking, setSpeaking]           = useState(false);
  const [prayerOpen, setPrayerOpen]       = useState(false);
  const [encouragement, setEncouragement] = useState<{ text: string; emoji: string } | null>(null);
  const [animKey, setAnimKey]             = useState(0);
  const [chapterDone, setChapterDone]     = useState(false);
  const [earnedBadge, setEarnedBadge]     = useState<Badge | null>(null);
  const [totalSeedsEarned, setTotalSeedsEarned] = useState(0);

  const toggleLittleReader = useCallback(() => {
    setLittleReaderMode((prev) => {
      const next = !prev;
      localStorage.setItem(READER_MODE_KEY, next ? 'little' : 'standard');
      return next;
    });
  }, []);

  const verse   = chapter.verses[verseIndex];
  const total   = chapter.verses.length;
  const isFirst = verseIndex === 0;
  const isLast  = verseIndex === total - 1;
  const progress = Math.round(((verseIndex + 1) / total) * 100);

  // Record session start
  useEffect(() => {
    recordSession(bookSlug, chapter.chapter, verse.verse, 'child');
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Stop speech when verse changes or component unmounts
  useEffect(() => {
    return () => stopSpeech();
  }, [verseIndex]);

  const verseText = (littleReaderMode && verse.little_reader_adaptation)
    ? verse.little_reader_adaptation
    : verse.little_bible;

  const startReading = useCallback(() => {
    if (!isSpeechSupported()) return;
    setSpeaking(true);
    speakText(verseText, {
      rate: 0.78,
      pitch: 1.08,
      onEnd:   () => setSpeaking(false),
      onError: () => setSpeaking(false),
    });
  }, [verseText]);

  const stopReading = useCallback(() => {
    stopSpeech();
    setSpeaking(false);
  }, []);

  const goToVerse = useCallback((idx: number) => {
    stopSpeech();
    setSpeaking(false);
    setPrayerOpen(false);
    setVerseIndex(idx);
    setAnimKey((k) => k + 1);
  }, []);

  const handleNext = useCallback(() => {
    if (isLast || encouragement) return;

    // 1. Mark verse complete + collect seeds
    const { progress: newP, newBadge } = markVerseComplete(bookSlug, chapter.chapter, verse.verse);
    if (newBadge) setEarnedBadge(newBadge);

    // 2. Navigate to next verse immediately
    goToVerse(verseIndex + 1);

    // 3. Show encouragement AFTER navigation (doesn't block)
    const pick = ENCOURAGEMENTS[Math.floor(Math.random() * ENCOURAGEMENTS.length)];
    setEncouragement(pick);
    setTimeout(() => setEncouragement(null), 1100);

    void newP; // used for seeds count if needed
  }, [isLast, encouragement, bookSlug, chapter.chapter, verse.verse, verseIndex, goToVerse]);

  const handleFinish = useCallback(() => {
    if (encouragement) return;

    // Mark last verse + chapter complete
    const { progress: vp } = markVerseComplete(bookSlug, chapter.chapter, verse.verse);
    const { progress: cp, newBadge } = markChapterComplete(bookSlug, chapter.chapter);

    setTotalSeedsEarned(cp.wisdomSeeds - (vp.wisdomSeeds - (chapter.verses.length + 5)));
    if (newBadge) setEarnedBadge(newBadge);
    setChapterDone(true);
  }, [encouragement, bookSlug, chapter.chapter, chapter.verses.length, verse.verse]);

  // Paginated dots
  const { start, end } = getPaginatedRange(verseIndex, total);
  const showLeftFade  = start > 0;
  const showRightFade = end < total - 1;

  // ── Chapter Complete Screen ──────────────────────────────────────────────
  if (chapterDone) {
    const prog      = getProgress();
    const lumiStage = getLumiStage(prog.wisdomSeeds);
    const lumiLabel = getLumiLabel(lumiStage);
    return (
      <div className="fixed inset-0 z-50 bg-gradient-to-b from-amber-400 via-amber-500 to-amber-600 flex flex-col items-center justify-center text-white text-center px-6 py-12 celebrate-in">
        {/* Lumi mascot — animated, grows with seeds earned */}
        <div className="mb-4">
          <LumiMascot stage={lumiStage} className="w-28 h-28 sm:w-36 sm:h-36" animate />
          <p className="text-amber-100 text-sm font-bold mt-1">{lumiLabel}</p>
        </div>

        <h2 className="text-4xl font-extrabold mb-2 font-display">Chapter Complete!</h2>
        <p className="text-amber-100 text-lg mb-8">
          You read all {total} verses of {chapter.book} {chapter.chapter}!
        </p>

        {/* Badge */}
        {earnedBadge && (
          <div className="bg-white/20 backdrop-blur-sm rounded-3xl px-8 py-5 mb-6 border border-white/30 shine-pulse">
            <p className="text-amber-100 text-xs font-bold uppercase tracking-widest mb-1">
              Badge Unlocked!
            </p>
            <p className="text-4xl mb-1" aria-hidden="true">{earnedBadge.emoji}</p>
            <p className="text-xl font-extrabold">{earnedBadge.label}</p>
          </div>
        )}

        {/* Seeds */}
        <div className="flex items-center gap-2 mb-10 bg-white/15 rounded-full px-6 py-3">
          <span className="text-2xl" aria-hidden="true">🌱</span>
          <span className="font-bold text-lg">+{total + 5} Wisdom Seeds</span>
        </div>

        <div className="flex flex-col gap-3 w-full max-w-xs">
          {nextChapterNum && (
            <Link
              href={`/${bookSlug}/${nextChapterNum}`}
              className="w-full max-w-xs flex items-center gap-4 bg-white/15 hover:bg-white/25 border border-white/20 rounded-2xl px-5 py-4 mb-3 transition-all active:scale-95 fade-in"
            >
              <span className="text-2xl shrink-0" aria-hidden="true">📖</span>
              <div className="text-left flex-1 min-w-0">
                <p className="text-amber-200 text-xs font-bold uppercase tracking-widest">Up Next</p>
                <p className="text-white font-extrabold text-sm leading-tight">
                  {chapter.book} Chapter {nextChapterNum}
                </p>
              </div>
              <span className="text-white/60 text-lg shrink-0" aria-hidden="true">→</span>
            </Link>
          )}
          <button
            onClick={() => router.push('/')}
            className="bg-white text-amber-700 font-extrabold py-4 rounded-2xl text-lg hover:bg-amber-50 transition-colors"
          >
            ← Back to Library
          </button>
        </div>
      </div>
    );
  }

  // ── Main Verse Reader ────────────────────────────────────────────────────
  return (
    <div className="max-w-lg mx-auto pb-8">

      {/* Progress bar */}
      <div className="mb-5">
        <div className="flex items-center justify-between mb-1.5">
          <span className="text-sm font-bold text-stone-400">
            <span className="text-amber-600 font-extrabold">{chapter.book} {chapter.chapter}:{verse.verse}</span>
            <span className="text-stone-300 mx-1.5">·</span>
            {verseIndex + 1} of {total}
          </span>
          <span className="text-sm font-extrabold text-amber-600">{progress}%</span>
        </div>
        <div
          role="progressbar"
          aria-valuenow={verseIndex + 1}
          aria-valuemin={1}
          aria-valuemax={total}
          aria-label={`Reading progress: verse ${verseIndex + 1} of ${total}`}
          className="w-full bg-amber-100 rounded-full h-3 overflow-hidden"
        >
          <div
            className="bg-amber-400 h-3 rounded-full transition-all duration-500"
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>

      {/* Verse card */}
      <div key={animKey} className="verse-enter">
        <div className="bg-white rounded-3xl shadow-lg border border-amber-100 overflow-hidden">

          {/* Illustration zone */}
          <div className="px-4 pt-5">
            <IllustrationZone
              bookSlug={bookSlug}
              chapter={chapter.chapter}
              verse={verse.verse}
              keywords={verse.keywords}
            />
          </div>

          <div className="px-5 sm:px-7 pt-5 pb-6 space-y-5">

            {/* Ages selector pill — shown only when little reader content exists */}
            {hasLittleReader && (
              <div className="flex items-center justify-center gap-1 mb-3 bg-stone-50 rounded-xl p-1">
                <button
                  onClick={() => !littleReaderMode && toggleLittleReader()}
                  className={`flex-1 py-1.5 px-3 rounded-lg text-xs font-bold transition-colors focus:outline-none ${
                    !littleReaderMode
                      ? 'bg-amber-500 text-white shadow-sm'
                      : 'text-stone-500 hover:text-stone-700'
                  }`}
                  aria-pressed={!littleReaderMode}
                >
                  Ages 5–7
                </button>
                <button
                  onClick={() => littleReaderMode && toggleLittleReader()}
                  className={`flex-1 py-1.5 px-3 rounded-lg text-xs font-bold transition-colors focus:outline-none ${
                    littleReaderMode
                      ? 'bg-amber-500 text-white shadow-sm'
                      : 'text-stone-500 hover:text-stone-700'
                  }`}
                  aria-pressed={littleReaderMode}
                >
                  🌱 Ages 4–5
                </button>
              </div>
            )}

            {/* Persistent verse reference */}
            <div className="flex items-center justify-between mb-1">
              <span className="inline-flex items-center gap-1.5 text-xs font-bold text-stone-400 uppercase tracking-widest">
                <span className="text-amber-500">{chapter.book}</span>
                <span className="text-stone-300">·</span>
                <span>{chapter.chapter}:{verse.verse}</span>
              </span>
              {/* KJV reference toggle if needed */}
            </div>

            {/* ① Read aloud — PRIMARY action, top of content */}
            <button
              onClick={speaking ? stopReading : startReading}
              className={`w-full flex items-center justify-center gap-3 py-5 rounded-2xl text-lg font-extrabold transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                speaking
                  ? 'bg-amber-100 text-amber-700 border-2 border-amber-300'
                  : 'bg-amber-500 text-white hover:bg-amber-600 shadow-lg hover:shadow-xl'
              }`}
              aria-label={speaking ? 'Stop reading' : 'Read verse aloud'}
            >
              <span className="text-3xl" aria-hidden="true">
                {speaking ? '⏹' : '🔊'}
              </span>
              {speaking ? 'Stop' : 'Read to me'}
            </button>

            {/* ② Verse text — large, Nunito Bold */}
            <div>
              <p className="text-stone-800 text-2xl sm:text-3xl font-bold leading-relaxed font-child">
                {verseText}
              </p>
            </div>

            {/* ③ Memory phrase — always visible */}
            <div className="bg-amber-50 rounded-2xl px-5 py-4 border border-amber-200">
              <p className="text-amber-900 text-lg sm:text-xl font-extrabold leading-snug font-child">
                ✨ {verse.memory_phrase}
              </p>
            </div>

            {/* ④ Prayer — tap to expand */}
            <div>
              <button
                onClick={() => setPrayerOpen((o) => !o)}
                className="w-full flex items-center justify-between bg-blue-50 rounded-2xl px-5 py-3.5 border border-blue-100 hover:bg-blue-100 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-300"
                aria-expanded={prayerOpen}
                aria-label={prayerOpen ? 'Close prayer' : 'Open prayer'}
              >
                <span className="font-bold text-blue-700 text-base">🙏 Pray</span>
                <span className={`text-blue-400 transition-transform text-sm ${prayerOpen ? 'rotate-180' : ''}`} aria-hidden="true">▼</span>
              </button>

              {prayerOpen && (
                <div className="mt-2 bg-blue-50 rounded-2xl px-5 py-4 border border-blue-100 fade-in">
                  <p className="text-blue-900 text-base sm:text-lg leading-relaxed italic font-devotion">
                    {verse.prayer}
                  </p>
                  <button
                    onClick={() => speakText(verse.prayer, { rate: 0.72, pitch: 1.0 })}
                    className="mt-3 text-blue-400 hover:text-blue-600 text-sm font-semibold flex items-center gap-1.5 focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-300 rounded"
                    aria-label="Read prayer aloud"
                  >
                    <span aria-hidden="true">🔊</span> Read prayer
                  </button>
                </div>
              )}
            </div>

          </div>
        </div>
      </div>

      {/* Encouragement overlay */}
      {encouragement && (
        <div
          role="status"
          aria-live="polite"
          className="fixed inset-0 z-30 flex items-center justify-center pointer-events-none"
        >
          <div className="pop-in bg-white rounded-3xl shadow-2xl border-4 border-amber-200 px-10 py-7 text-center">
            <p className="text-6xl mb-2" aria-hidden="true">{encouragement.emoji}</p>
            <p className="text-2xl font-extrabold text-amber-700 font-child">{encouragement.text}</p>
          </div>
        </div>
      )}

      {/* Navigation */}
      <div className="flex gap-3 mt-5">
        <button
          onClick={() => goToVerse(verseIndex - 1)}
          disabled={isFirst}
          className="flex-1 flex items-center justify-center gap-1.5 py-4 rounded-2xl font-extrabold text-base border-2 border-amber-200 text-amber-700 hover:bg-amber-50 disabled:opacity-25 disabled:cursor-not-allowed transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
          aria-label="Previous verse"
        >
          <span aria-hidden="true">←</span> Back
        </button>

        {isLast ? (
          <button
            onClick={handleFinish}
            className="flex-1 flex items-center justify-center gap-1.5 py-4 rounded-2xl font-extrabold text-base bg-green-500 text-white hover:bg-green-600 transition-all active:scale-95 shadow-md hover:shadow-lg focus:outline-none focus-visible:ring-2 focus-visible:ring-green-400"
            aria-label="Finish chapter"
          >
            Finish 🎉
          </button>
        ) : (
          <button
            onClick={handleNext}
            disabled={!!encouragement}
            className="flex-1 flex items-center justify-center gap-1.5 py-4 rounded-2xl font-extrabold text-base bg-amber-500 text-white hover:bg-amber-600 disabled:opacity-60 transition-all active:scale-95 shadow-md hover:shadow-lg focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
            aria-label="Next verse"
          >
            Next <span aria-hidden="true">→</span>
          </button>
        )}
      </div>

      {/* Paginated dot navigation */}
      <div
        className="relative flex justify-center items-center gap-2 mt-5"
        role="navigation"
        aria-label="Jump to verse"
      >
        {showLeftFade && (
          <span className="text-stone-300 text-xs" aria-hidden="true">•••</span>
        )}
        {Array.from({ length: end - start + 1 }, (_, i) => {
          const idx = start + i;
          return (
            <button
              key={idx}
              onClick={() => goToVerse(idx)}
              className={`rounded-full transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                idx === verseIndex
                  ? 'w-6 h-3 bg-amber-500'
                  : 'w-3 h-3 bg-amber-200 hover:bg-amber-300'
              }`}
              aria-label={`Verse ${idx + 1}`}
              aria-current={idx === verseIndex ? 'step' : undefined}
            />
          );
        })}
        {showRightFade && (
          <span className="text-stone-300 text-xs" aria-hidden="true">•••</span>
        )}
      </div>

      {/* Badge notification (non-blocking) */}
      {earnedBadge && !chapterDone && (
        <div
          role="status"
          aria-live="polite"
          className="mt-5 bg-amber-50 rounded-2xl border border-amber-200 px-5 py-3 flex items-center gap-3 fade-in"
        >
          <span className="text-3xl" aria-hidden="true">{earnedBadge.emoji}</span>
          <div>
            <p className="text-xs font-bold text-amber-600 uppercase tracking-wide">Badge Earned!</p>
            <p className="font-bold text-amber-900">{earnedBadge.label}</p>
          </div>
        </div>
      )}
    </div>
  );
}
