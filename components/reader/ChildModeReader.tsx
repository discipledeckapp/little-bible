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
import { recordMemberProgress, getActiveMemberId } from '@/lib/family-client';
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
  initialVerse?: number;
  onVerseChange?: (verseNum: number) => void;
}

const MAX_DOTS = 9;
function getPaginatedRange(current: number, total: number) {
  if (total <= MAX_DOTS) return { start: 0, end: total - 1 };
  const half = Math.floor(MAX_DOTS / 2);
  const start = Math.max(0, Math.min(current - half, total - MAX_DOTS));
  return { start, end: start + MAX_DOTS - 1 };
}

const READER_MODE_KEY = 'little_bible_reader_mode';

export default function ChildModeReader({ chapter, bookSlug, nextChapterNum, initialVerse, onVerseChange }: ChildModeReaderProps) {
  const router = useRouter();

  const hasLittleReader = chapter.verses.some((v) => !!v.little_reader_adaptation);

  const [verseIndex, setVerseIndex] = useState(() => {
    if (initialVerse && initialVerse >= 1 && initialVerse <= chapter.verses.length) {
      return initialVerse - 1;
    }
    const done = getChapterCompletedVerses(bookSlug, chapter.chapter);
    const next = done.length < chapter.verses.length ? done.length : 0;
    return next;
  });

  const [littleReaderMode, setLittleReaderMode] = useState(() => {
    if (typeof window === 'undefined') return false;
    return localStorage.getItem(READER_MODE_KEY) === 'little';
  });

  const [speaking, setSpeaking]         = useState(false);
  const [familyOpen, setFamilyOpen]     = useState(false);
  const [encouragement, setEncouragement] = useState<{ text: string; emoji: string } | null>(null);
  const [animKey, setAnimKey]           = useState(0);
  const [chapterDone, setChapterDone]   = useState(false);
  const [earnedBadge, setEarnedBadge]   = useState<Badge | null>(null);

  const toggleLittleReader = useCallback(() => {
    setLittleReaderMode((prev) => {
      const next = !prev;
      localStorage.setItem(READER_MODE_KEY, next ? 'little' : 'standard');
      return next;
    });
  }, []);

  const verse    = chapter.verses[verseIndex];
  const total    = chapter.verses.length;
  const isFirst  = verseIndex === 0;
  const isLast   = verseIndex === total - 1;
  const progress = Math.round(((verseIndex + 1) / total) * 100);

  useEffect(() => {
    recordSession(bookSlug, chapter.chapter, verse.verse, 'child');
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

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
    setFamilyOpen(false);
    setVerseIndex(idx);
    setAnimKey((k) => k + 1);
    onVerseChange?.(chapter.verses[idx]?.verse ?? idx + 1);
  }, [chapter.verses, onVerseChange]);

  const handleNext = useCallback(() => {
    if (isLast || encouragement) return;
    const { newBadge } = markVerseComplete(bookSlug, chapter.chapter, verse.verse);
    if (newBadge) setEarnedBadge(newBadge);
    // Also record against the active family member if one is selected
    const memberId = getActiveMemberId();
    if (memberId) {
      recordMemberProgress({ memberId, bookSlug, chapter: chapter.chapter, verse: verse.verse, mode: 'child', type: 'verse' });
    }
    goToVerse(verseIndex + 1);
    const pick = ENCOURAGEMENTS[Math.floor(Math.random() * ENCOURAGEMENTS.length)];
    setEncouragement(pick);
    setTimeout(() => setEncouragement(null), 1100);
  }, [isLast, encouragement, bookSlug, chapter.chapter, verse.verse, verseIndex, goToVerse]);

  const handleFinish = useCallback(() => {
    if (encouragement) return;
    markVerseComplete(bookSlug, chapter.chapter, verse.verse);
    const { newBadge } = markChapterComplete(bookSlug, chapter.chapter);
    if (newBadge) setEarnedBadge(newBadge);
    // Record chapter completion against active family member
    const memberId = getActiveMemberId();
    if (memberId) {
      recordMemberProgress({ memberId, bookSlug, chapter: chapter.chapter, verse: verse.verse, mode: 'child', type: 'chapter' });
    }
    setChapterDone(true);
  }, [encouragement, bookSlug, chapter.chapter, verse.verse]);

  const { start, end } = getPaginatedRange(verseIndex, total);
  const showLeftFade   = start > 0;
  const showRightFade  = end < total - 1;

  // ── Chapter Complete ────────────────────────────────────────────────────────
  if (chapterDone) {
    const prog      = getProgress();
    const lumiStage = getLumiStage(prog.wisdomSeeds);
    const lumiLabel = getLumiLabel(lumiStage);
    return (
      <div className="fixed inset-0 z-50 bg-gradient-to-b from-amber-400 via-amber-500 to-amber-600 flex flex-col items-center justify-center text-white text-center px-6 py-12 celebrate-in">
        <div className="mb-4">
          <LumiMascot stage={lumiStage} className="w-28 h-28 sm:w-36 sm:h-36" animate />
          <p className="text-amber-100 text-sm font-bold mt-1">{lumiLabel}</p>
        </div>
        <h2 className="text-4xl font-extrabold mb-2 font-display">Chapter Complete!</h2>
        <p className="text-amber-100 text-lg mb-8">
          You read all {total} verses of {chapter.book} {chapter.chapter}!
        </p>
        {earnedBadge && (
          <div className="bg-white/20 backdrop-blur-sm rounded-3xl px-8 py-5 mb-6 border border-white/30 shine-pulse">
            <p className="text-amber-100 text-xs font-bold uppercase tracking-widest mb-1">Badge Unlocked!</p>
            <p className="text-4xl mb-1" aria-hidden="true">{earnedBadge.emoji}</p>
            <p className="text-xl font-extrabold">{earnedBadge.label}</p>
          </div>
        )}
        <div className="flex items-center gap-2 mb-10 bg-white/15 rounded-full px-6 py-3">
          <span className="text-2xl" aria-hidden="true">🌱</span>
          <span className="font-bold text-lg">+{total + 5} Wisdom Seeds</span>
        </div>
        <div className="flex flex-col gap-3 w-full max-w-xs">
          {nextChapterNum && (
            <Link
              href={`/${bookSlug}/${nextChapterNum}`}
              className="w-full flex items-center gap-4 bg-white/15 hover:bg-white/25 border border-white/20 rounded-2xl px-5 py-4 transition-all active:scale-95 fade-in"
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

  // ── Main Reader ─────────────────────────────────────────────────────────────
  return (
    <div className="max-w-lg mx-auto pb-8">

      {/* Progress bar */}
      <div className="mb-5">
        <div className="flex items-center justify-between mb-1.5">
          <span className="text-sm font-bold text-stone-400">
            {verseIndex + 1} of {total} verses
          </span>
          <span className="text-sm font-extrabold text-amber-600">{progress}%</span>
        </div>
        <div
          role="progressbar"
          aria-valuenow={verseIndex + 1}
          aria-valuemin={1}
          aria-valuemax={total}
          aria-label={`Reading progress: verse ${verseIndex + 1} of ${total}`}
          className="w-full bg-amber-100 rounded-full h-2.5 overflow-hidden"
        >
          <div
            className="bg-amber-400 h-2.5 rounded-full transition-all duration-500"
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>

      {/* ── Verse card ── */}
      <div key={animKey} className="verse-enter">
        <div className="bg-white rounded-3xl shadow-lg border border-amber-100 overflow-hidden">

          {/* Illustration */}
          <div className="px-4 pt-5">
            <IllustrationZone
              bookSlug={bookSlug}
              chapter={chapter.chapter}
              verse={verse.verse}
              keywords={verse.keywords}
            />
          </div>

          <div className="px-5 sm:px-7 pt-4 pb-6 space-y-4">

            {/* 1. Verse reference — unmissable Bible identity */}
            <div>
              <span className="inline-flex items-center gap-1.5 bg-amber-100 text-amber-800 text-sm font-extrabold px-3 py-1 rounded-full border border-amber-200">
                📖 {chapter.book} {chapter.chapter}:{verse.verse}
              </span>
            </div>

            {/* 2. Bible text — primary content, large */}
            <p className="text-stone-800 text-2xl sm:text-3xl font-bold leading-relaxed font-child">
              {verseText}
            </p>

            {/* 3. Read to me */}
            <button
              onClick={speaking ? stopReading : startReading}
              className={`w-full flex items-center justify-center gap-3 py-4 rounded-2xl text-lg font-extrabold transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                speaking
                  ? 'bg-amber-100 text-amber-700 border-2 border-amber-300'
                  : 'bg-amber-500 text-white hover:bg-amber-600 shadow-md hover:shadow-lg'
              }`}
              aria-label={speaking ? 'Stop reading' : 'Read verse aloud'}
            >
              <span className="text-2xl" aria-hidden="true">{speaking ? '⏹' : '🔊'}</span>
              {speaking ? 'Stop' : 'Read to me'}
            </button>

            {/* 4. Family tools — collapsed by default */}
            <div>
              <button
                onClick={() => setFamilyOpen((o) => !o)}
                className="w-full flex items-center justify-between px-4 py-3 rounded-2xl text-sm font-bold text-stone-500 bg-stone-50 hover:bg-stone-100 border border-stone-200 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-stone-300"
                aria-expanded={familyOpen}
              >
                <span className="flex items-center gap-2">
                  <span aria-hidden="true">👨‍👩‍👧</span>
                  Family tools
                </span>
                <span className={`transition-transform text-xs ${familyOpen ? 'rotate-180' : ''}`} aria-hidden="true">▼</span>
              </button>

              {familyOpen && (
                <div className="mt-3 space-y-3 fade-in">

                  {/* Age toggle — only if simpler text exists */}
                  {hasLittleReader && (
                    <div className="flex items-center gap-1 bg-stone-50 rounded-xl p-1">
                      <button
                        onClick={() => littleReaderMode && toggleLittleReader()}
                        className={`flex-1 py-1.5 px-3 rounded-lg text-xs font-bold transition-colors focus:outline-none ${
                          !littleReaderMode ? 'bg-amber-500 text-white shadow-sm' : 'text-stone-500 hover:text-stone-700'
                        }`}
                        aria-pressed={!littleReaderMode}
                      >
                        Ages 5–7
                      </button>
                      <button
                        onClick={() => !littleReaderMode && toggleLittleReader()}
                        className={`flex-1 py-1.5 px-3 rounded-lg text-xs font-bold transition-colors focus:outline-none ${
                          littleReaderMode ? 'bg-amber-500 text-white shadow-sm' : 'text-stone-500 hover:text-stone-700'
                        }`}
                        aria-pressed={littleReaderMode}
                      >
                        🌱 Ages 4–5
                      </button>
                    </div>
                  )}

                  {/* Meaning */}
                  {verse.meaning && (
                    <div className="bg-sky-50 rounded-2xl px-4 py-3 border border-sky-100">
                      <p className="text-xs font-bold text-sky-600 uppercase tracking-widest mb-1.5">💡 What this means</p>
                      <p className="text-sky-900 text-sm leading-relaxed">{verse.meaning}</p>
                    </div>
                  )}

                  {/* Memory phrase */}
                  {verse.memory_phrase && (
                    <div className="bg-amber-50 rounded-2xl px-4 py-3 border border-amber-200">
                      <p className="text-xs font-bold text-amber-600 uppercase tracking-widest mb-1.5">✨ Remember</p>
                      <p className="text-amber-900 text-base font-extrabold leading-snug font-child">
                        {verse.memory_phrase}
                      </p>
                      <button
                        onClick={() => speakText(verse.memory_phrase, { rate: 0.65, pitch: 1.05 })}
                        className="mt-2 text-amber-500 hover:text-amber-700 text-xs font-semibold flex items-center gap-1 focus:outline-none rounded"
                        aria-label="Hear memory phrase"
                      >
                        <span aria-hidden="true">🔊</span> Hear it slowly
                      </button>
                    </div>
                  )}

                  {/* Prayer */}
                  {verse.prayer && (
                    <div className="bg-blue-50 rounded-2xl px-4 py-3 border border-blue-100">
                      <p className="text-xs font-bold text-blue-600 uppercase tracking-widest mb-1.5">🙏 Pray</p>
                      <p className="text-blue-900 text-sm leading-relaxed italic font-devotion">{verse.prayer}</p>
                      <button
                        onClick={() => speakText(verse.prayer, { rate: 0.72, pitch: 1.0 })}
                        className="mt-2 text-blue-400 hover:text-blue-600 text-xs font-semibold flex items-center gap-1 focus:outline-none rounded"
                        aria-label="Read prayer aloud"
                      >
                        <span aria-hidden="true">🔊</span> Read prayer
                      </button>
                    </div>
                  )}

                  {/* Discussion */}
                  {(verse.discussion_question || verse.family_discussion) && (
                    <div className="bg-emerald-50 rounded-2xl px-4 py-3 border border-emerald-100 space-y-2">
                      <p className="text-xs font-bold text-emerald-600 uppercase tracking-widest">💬 Talk Together</p>
                      {verse.discussion_question && (
                        <p className="text-emerald-900 text-sm font-semibold leading-snug">{verse.discussion_question}</p>
                      )}
                      {verse.family_discussion && (
                        <p className="text-emerald-800 text-sm leading-snug">{verse.family_discussion}</p>
                      )}
                    </div>
                  )}

                  {/* Do it today */}
                  {verse.do_it_today && (
                    <div className="bg-orange-50 rounded-2xl px-4 py-3 border border-orange-100">
                      <p className="text-xs font-bold text-orange-600 uppercase tracking-widest mb-1.5">🌟 Do It Today</p>
                      <p className="text-orange-900 text-sm font-semibold leading-snug">{verse.do_it_today}</p>
                    </div>
                  )}

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

      {/* Navigation — always at bottom, prominent */}
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

      {/* Dot navigation */}
      <div
        className="relative flex justify-center items-center gap-2 mt-5"
        role="navigation"
        aria-label="Jump to verse"
      >
        {showLeftFade && <span className="text-stone-300 text-xs" aria-hidden="true">•••</span>}
        {Array.from({ length: end - start + 1 }, (_, i) => {
          const idx = start + i;
          return (
            <button
              key={idx}
              onClick={() => goToVerse(idx)}
              className={`rounded-full transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                idx === verseIndex ? 'w-6 h-3 bg-amber-500' : 'w-3 h-3 bg-amber-200 hover:bg-amber-300'
              }`}
              aria-label={`Verse ${idx + 1}`}
              aria-current={idx === verseIndex ? 'step' : undefined}
            />
          );
        })}
        {showRightFade && <span className="text-stone-300 text-xs" aria-hidden="true">•••</span>}
      </div>

      {/* Badge notification */}
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
