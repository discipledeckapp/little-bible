'use client';

import { useState, useCallback, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import type { Chapter, Badge } from '@/types';
import type { FamilyStep } from '@/types';
import { speakText, stopSpeech, isSpeechSupported } from '@/lib/audio';
import {
  markVerseComplete,
  markChapterComplete,
  recordSession,
  getChapterCompletedVerses,
} from '@/lib/progress';
import IllustrationZone from './IllustrationZone';
import LumiMascot, { getLumiStage, getLumiLabel } from '@/components/mascot/LumiMascot';
import { getProgress } from '@/lib/progress';

const STEPS: { id: FamilyStep; label: string; emoji: string }[] = [
  { id: 'read',        label: 'Read',    emoji: '📖' },
  { id: 'discuss',     label: 'Discuss', emoji: '💬' },
  { id: 'pray',        label: 'Pray',    emoji: '🙏' },
  { id: 'remember',    label: 'Remember',emoji: '⭐' },
  { id: 'do_it_today', label: 'Do It',   emoji: '🌟' },
];

type MemoryPhase = 'hear' | 'say' | 'done';

interface FamilyModeReaderProps {
  chapter: Chapter;
  bookSlug: string;
}

export default function FamilyModeReader({ chapter, bookSlug }: FamilyModeReaderProps) {
  const router = useRouter();
  const [verseIndex, setVerseIndex] = useState(0);
  const [step, setStep]             = useState<FamilyStep>('read');
  const [direction, setDirection]   = useState<'forward' | 'back'>('forward');
  const [animKey, setAnimKey]       = useState(0);
  const [speaking, setSpeaking]     = useState(false);
  const [chapterDone, setChapterDone] = useState(false);
  const [earnedBadge, setEarnedBadge] = useState<Badge | null>(null);
  const [memoryPhase, setMemoryPhase] = useState<MemoryPhase>('hear');
  const [seedsThisChapter, setSeedsThisChapter] = useState(() =>
    typeof window !== 'undefined'
      ? getChapterCompletedVerses(bookSlug, chapter.chapter).length
      : 0
  );

  const verse      = chapter.verses[verseIndex];
  const total      = chapter.verses.length;
  const stepIndex  = STEPS.findIndex((s) => s.id === step);
  const isLastStep = stepIndex === STEPS.length - 1;
  const isLastVerse = verseIndex === total - 1;

  const navigate = useCallback((newStep: FamilyStep, newVerseIdx?: number) => {
    stopSpeech();
    setSpeaking(false);
    setStep(newStep);
    if (newVerseIdx !== undefined) setVerseIndex(newVerseIdx);
    if (newStep === 'remember') setMemoryPhase('hear');
    setAnimKey((k) => k + 1);
  }, []);

  const handleRead = useCallback(() => {
    if (!isSpeechSupported()) return;
    setSpeaking(true);
    speakText(verse.little_bible, {
      rate: 0.78,
      pitch: 1.08,
      onEnd:   () => setSpeaking(false),
      onError: () => setSpeaking(false),
    });
  }, [verse]);

  const handlePrayRead = useCallback(() => {
    if (!isSpeechSupported()) return;
    speakText(verse.prayer, { rate: 0.72, pitch: 1.02 });
  }, [verse]);

  const handleNext = useCallback(() => {
    if (!isLastStep) {
      setDirection('forward');
      navigate(STEPS[stepIndex + 1].id);
      return;
    }
    // End of last step — record completion
    const { newBadge } = markVerseComplete(bookSlug, chapter.chapter, verse.verse);
    if (newBadge) setEarnedBadge(newBadge);
    recordSession(bookSlug, chapter.chapter, verse.verse, 'family');
    setSeedsThisChapter((n) => n + 1);

    if (!isLastVerse) {
      setDirection('forward');
      navigate('read', verseIndex + 1);
    } else {
      markChapterComplete(bookSlug, chapter.chapter);
      setChapterDone(true);
    }
  }, [isLastStep, stepIndex, bookSlug, chapter.chapter, verse.verse, isLastVerse, verseIndex, navigate]);

  const handleBack = useCallback(() => {
    setDirection('back');
    if (stepIndex > 0) {
      navigate(STEPS[stepIndex - 1].id);
    } else if (verseIndex > 0) {
      navigate('do_it_today', verseIndex - 1);
    }
  }, [stepIndex, verseIndex, navigate]);

  const canGoBack = stepIndex > 0 || verseIndex > 0;

  // Stop speech on unmount
  useEffect(() => () => stopSpeech(), []);

  // ── Chapter Complete ─────────────────────────────────────────────────────
  if (chapterDone) {
    const totalSeeds = seedsThisChapter + 5;
    const progress   = getProgress();
    const lumiStage  = getLumiStage(progress.wisdomSeeds);
    const lumiLabel  = getLumiLabel(lumiStage);
    return (
      <div className="fixed inset-0 z-50 bg-gradient-to-b from-emerald-400 via-emerald-500 to-emerald-600 flex flex-col items-center justify-center text-white text-center px-6 py-12 celebrate-in">
        {/* Lumi mascot — animated, showing current growth stage */}
        <div className="mb-4">
          <LumiMascot stage={lumiStage} className="w-28 h-28 sm:w-36 sm:h-36" animate />
          <p className="text-emerald-100 text-sm font-bold mt-1">{lumiLabel}</p>
        </div>

        <h2 className="text-4xl font-extrabold mb-2 font-display">Devotion Complete!</h2>
        <p className="text-emerald-100 text-lg mb-8">
          You completed all {total} verses of {chapter.book} {chapter.chapter} as a family!
        </p>

        {earnedBadge && (
          <div className="bg-white/20 backdrop-blur-sm rounded-3xl px-8 py-5 mb-6 border border-white/30 shine-pulse">
            <p className="text-emerald-100 text-xs font-bold uppercase tracking-widest mb-1">Badge Unlocked!</p>
            <p className="text-4xl mb-1" aria-hidden="true">{earnedBadge.emoji}</p>
            <p className="text-xl font-extrabold">{earnedBadge.label}</p>
          </div>
        )}

        <div className="flex items-center gap-2 mb-10 bg-white/15 rounded-full px-6 py-3">
          <span className="text-2xl" aria-hidden="true">🌱</span>
          <span className="font-bold text-lg">+{totalSeeds} Wisdom Seeds</span>
        </div>

        <button
          onClick={() => router.push('/')}
          className="bg-white text-emerald-700 font-extrabold py-4 rounded-2xl text-lg w-full max-w-xs hover:bg-emerald-50 transition-colors"
        >
          ← Back to Library
        </button>
      </div>
    );
  }

  // ── Main Devotional Screen ────────────────────────────────────────────────
  return (
    <div className="max-w-lg mx-auto pb-8">

      {/* Header: verse indicator + seeds */}
      <div className="mb-5">
        <div className="flex items-center justify-between mb-1.5">
          <span className="text-sm font-bold text-stone-400">
            Verse {verseIndex + 1} of {total}
          </span>
          <div className="flex items-center gap-1" title="Wisdom Seeds earned this chapter">
            <span className="text-base" aria-hidden="true">🌱</span>
            <span className="text-sm font-extrabold text-emerald-600">{seedsThisChapter}</span>
            <span className="text-emerald-400 text-xs font-semibold ml-0.5 hidden sm:inline">seeds</span>
          </div>
        </div>
        <div
          role="progressbar"
          aria-valuenow={stepIndex + 1}
          aria-valuemin={1}
          aria-valuemax={STEPS.length}
          aria-label={`Devotion progress: step ${stepIndex + 1} of ${STEPS.length}`}
          className="w-full bg-emerald-100 rounded-full h-3 overflow-hidden"
        >
          <div
            className="bg-emerald-400 h-3 rounded-full transition-all duration-500"
            style={{ width: `${Math.round(((verseIndex * STEPS.length + stepIndex + 1) / (total * STEPS.length)) * 100)}%` }}
          />
        </div>
      </div>

      {/* Step indicator pills */}
      <div className="flex gap-1.5 mb-5" role="list" aria-label="Devotion steps">
        {STEPS.map((s, i) => {
          const done    = i < stepIndex;
          const current = s.id === step;
          return (
            <div
              key={s.id}
              role="listitem"
              aria-current={current ? 'step' : undefined}
              className={`flex-1 flex flex-col items-center gap-0.5 py-2 rounded-2xl transition-colors ${
                current
                  ? 'bg-emerald-500 text-white'
                  : done
                  ? 'bg-emerald-100 text-emerald-600'
                  : 'bg-stone-100 text-stone-400'
              }`}
            >
              <span className="text-sm leading-none" aria-hidden="true">{s.emoji}</span>
              <span className="text-xs font-bold leading-none">{s.label}</span>
            </div>
          );
        })}
      </div>

      {/* Step content card */}
      <div
        key={animKey}
        className={direction === 'forward' ? 'slide-in-right' : 'slide-in-left'}
      >
        <div className="bg-white rounded-3xl shadow-lg border border-emerald-100 overflow-hidden">

          {/* Illustration — always shown */}
          <div className="px-4 pt-5">
            <IllustrationZone
              bookSlug={bookSlug}
              chapter={chapter.chapter}
              verse={verse.verse}
              keywords={verse.keywords}
              illustrationPrompt={verse.illustration_prompt}
            />
          </div>

          <div className="px-5 sm:px-7 pt-5 pb-6 space-y-5">

            {/* ── READ step ── */}
            {step === 'read' && (
              <>
                <button
                  onClick={speaking ? () => { stopSpeech(); setSpeaking(false); } : handleRead}
                  className={`w-full flex items-center justify-center gap-3 py-5 rounded-2xl text-lg font-extrabold transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400 ${
                    speaking
                      ? 'bg-emerald-100 text-emerald-700 border-2 border-emerald-300'
                      : 'bg-emerald-500 text-white hover:bg-emerald-600 shadow-lg'
                  }`}
                  aria-label={speaking ? 'Stop reading' : 'Read verse aloud'}
                >
                  <span className="text-3xl" aria-hidden="true">{speaking ? '⏹' : '🔊'}</span>
                  {speaking ? 'Stop' : 'Read to me'}
                </button>

                <p className="text-stone-800 text-2xl sm:text-3xl font-bold leading-relaxed font-child">
                  {verse.little_bible}
                </p>

                {verse.kjv && (
                  <details className="group">
                    <summary className="text-xs font-bold text-stone-400 uppercase tracking-widest cursor-pointer select-none flex items-center gap-1.5">
                      <span className="group-open:rotate-90 transition-transform inline-block" aria-hidden="true">▶</span>
                      KJV Reference
                    </summary>
                    <p className="mt-2 text-stone-500 text-sm leading-relaxed italic font-devotion border-l-2 border-amber-200 pl-3">
                      {verse.kjv}
                    </p>
                  </details>
                )}
              </>
            )}

            {/* ── DISCUSS step ── */}
            {step === 'discuss' && (
              <>
                <div className="bg-amber-50 rounded-2xl px-5 py-4 border border-amber-100">
                  <p className="text-xs font-bold text-amber-600 uppercase tracking-widest mb-2">Memory Phrase</p>
                  <p className="text-amber-900 text-lg font-extrabold leading-snug font-child">
                    ✨ {verse.memory_phrase}
                  </p>
                </div>

                <div>
                  <p className="text-xs font-bold text-emerald-700 uppercase tracking-widest mb-3">
                    💬 Talk Together
                  </p>
                  <ul className="space-y-3">
                    <li className="bg-emerald-50 rounded-2xl px-4 py-3 border border-emerald-100 text-emerald-900 text-base font-semibold">
                      {verse.discussion_question || 'What is this verse telling us?'}
                    </li>
                    <li className="bg-emerald-50 rounded-2xl px-4 py-3 border border-emerald-100 text-emerald-900 text-base font-semibold">
                      {verse.family_discussion || 'How can we do this today?'}
                    </li>
                  </ul>
                </div>
              </>
            )}

            {/* ── PRAY step ── */}
            {step === 'pray' && (
              <>
                <div className="bg-blue-50 rounded-2xl px-5 py-5 border border-blue-100 space-y-4">
                  <p className="text-xs font-bold text-blue-600 uppercase tracking-widest">Family Prayer</p>
                  <p className="text-blue-900 text-lg sm:text-xl leading-relaxed italic font-devotion">
                    {verse.prayer}
                  </p>
                  <button
                    onClick={handlePrayRead}
                    className="text-blue-400 hover:text-blue-600 text-sm font-semibold flex items-center gap-1.5 focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-300 rounded"
                    aria-label="Read prayer aloud"
                  >
                    <span aria-hidden="true">🔊</span> Read prayer aloud
                  </button>
                </div>

                <p className="text-center text-stone-400 text-sm font-semibold">
                  Pray together when you're ready, then tap Next.
                </p>
              </>
            )}

            {/* ── REMEMBER step ── */}
            {step === 'remember' && (
              <>
                <div className="bg-amber-400 rounded-3xl px-6 py-6 text-white text-center space-y-2 shine-pulse">
                  <p className="text-4xl mb-2" aria-hidden="true">⭐</p>
                  <p className="text-xs font-bold uppercase tracking-widest opacity-80">Memory Phrase</p>
                  <p className="text-xl sm:text-2xl font-extrabold leading-snug font-child">
                    {verse.memory_phrase}
                  </p>
                </div>

                {/* Phase 1: Hear it */}
                {memoryPhase === 'hear' && (
                  <button
                    onClick={() => {
                      if (!isSpeechSupported()) { setMemoryPhase('say'); return; }
                      speakText(verse.memory_phrase, {
                        rate: 0.65,
                        pitch: 1.05,
                        onEnd: () => setMemoryPhase('say'),
                        onError: () => setMemoryPhase('say'),
                      });
                    }}
                    className="w-full flex items-center justify-center gap-2 py-4 rounded-2xl bg-amber-50 border-2 border-amber-200 text-amber-800 font-bold text-base hover:bg-amber-100 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
                    aria-label="Hear memory phrase slowly"
                  >
                    <span aria-hidden="true">🔊</span> Hear it slowly
                  </button>
                )}

                {/* Phase 2: Say it together */}
                {memoryPhase === 'say' && (
                  <div className="space-y-3 fade-in">
                    <p className="text-center text-stone-700 font-extrabold text-lg">
                      Now say it together! 👨‍👩‍👧
                    </p>
                    <button
                      onClick={() => setMemoryPhase('done')}
                      className="w-full flex items-center justify-center gap-2 py-4 rounded-2xl bg-emerald-500 text-white font-extrabold text-base hover:bg-emerald-600 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400"
                    >
                      <span aria-hidden="true">✓</span> We said it!
                    </button>
                    <button
                      onClick={() =>
                        speakText(verse.memory_phrase, { rate: 0.65, pitch: 1.05 })
                      }
                      className="w-full text-amber-500 hover:text-amber-700 text-sm font-semibold flex items-center justify-center gap-1.5 py-2 focus:outline-none"
                    >
                      <span aria-hidden="true">🔊</span> Hear it again
                    </button>
                  </div>
                )}

                {/* Phase 3: Done! */}
                {memoryPhase === 'done' && (
                  <div className="flex items-center gap-3 bg-emerald-50 rounded-2xl px-4 py-3 border border-emerald-100 fade-in">
                    <span className="text-2xl" aria-hidden="true">🌱</span>
                    <div>
                      <p className="text-emerald-700 text-sm font-bold">Well done!</p>
                      <p className="text-emerald-500 text-xs">+1 Wisdom Seed coming up.</p>
                    </div>
                  </div>
                )}
              </>
            )}

            {/* ── DO IT TODAY step ── */}
            {step === 'do_it_today' && (
              <>
                <div className="bg-gradient-to-br from-amber-50 to-emerald-50 rounded-2xl px-5 py-5 border border-amber-100 space-y-3">
                  <div className="flex items-center gap-2">
                    <span className="text-2xl" aria-hidden="true">🌟</span>
                    <p className="text-xs font-bold text-amber-700 uppercase tracking-widest">Do It Today!</p>
                  </div>
                  <p className="text-stone-800 text-lg font-bold leading-snug font-child">
                    {verse.do_it_today ||
                      `Try to live out this truth today: "${verse.memory_phrase}"`}
                  </p>
                </div>

                {verse.action_challenge && (
                  <div className="bg-amber-50 rounded-2xl px-4 py-3 border border-amber-100">
                    <p className="text-xs font-bold text-amber-600 uppercase tracking-widest mb-1">
                      Family Challenge
                    </p>
                    <p className="text-amber-900 text-sm font-semibold leading-snug">
                      {verse.action_challenge}
                    </p>
                  </div>
                )}

                <p className="text-center text-stone-400 text-sm font-semibold">
                  When you're ready, tap Next to continue.
                </p>
              </>
            )}

          </div>
        </div>
      </div>

      {/* Navigation */}
      <div className="flex gap-3 mt-5">
        <button
          onClick={handleBack}
          disabled={!canGoBack}
          className="flex-1 flex items-center justify-center gap-1.5 py-4 rounded-2xl font-extrabold text-base border-2 border-emerald-200 text-emerald-700 hover:bg-emerald-50 disabled:opacity-25 disabled:cursor-not-allowed transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400"
          aria-label="Previous step"
        >
          <span aria-hidden="true">←</span> Back
        </button>

        <button
          onClick={handleNext}
          className="flex-1 flex items-center justify-center gap-1.5 py-4 rounded-2xl font-extrabold text-base bg-emerald-500 text-white hover:bg-emerald-600 transition-all active:scale-95 shadow-md hover:shadow-lg focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400"
          aria-label={isLastStep && isLastVerse ? 'Finish devotion' : 'Next step'}
        >
          {isLastStep && isLastVerse ? 'Finish 🌳' : 'Next'}
          {!(isLastStep && isLastVerse) && <span aria-hidden="true">→</span>}
        </button>
      </div>

      {/* Badge notification */}
      {earnedBadge && !chapterDone && (
        <div
          role="status"
          aria-live="polite"
          className="mt-5 bg-emerald-50 rounded-2xl border border-emerald-200 px-5 py-3 flex items-center gap-3 fade-in"
        >
          <span className="text-3xl" aria-hidden="true">{earnedBadge.emoji}</span>
          <div>
            <p className="text-xs font-bold text-emerald-600 uppercase tracking-wide">Badge Earned!</p>
            <p className="font-bold text-emerald-900">{earnedBadge.label}</p>
          </div>
        </div>
      )}
    </div>
  );
}
