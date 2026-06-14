'use client';

import { useState, useCallback, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import type { Chapter, Badge } from '@/types';
import type { FamilyStep } from '@/types';
import { recordMemberProgress, getActiveMemberId } from '@/lib/family-client';
import { speakText, stopSpeech, isSpeechSupported } from '@/lib/audio';
import {
  markVerseComplete,
  markChapterComplete,
  recordSession,
  getChapterCompletedVerses,
} from '@/lib/progress';
import IllustrationZone from './IllustrationZone';
import { getMemoryVerseText, getMemoryVerseRef } from '@/types';
import LumiMascot, { getLumiStage, getLumiLabel } from '@/components/mascot/LumiMascot';
import { getProgress } from '@/lib/progress';

const STEPS: { id: FamilyStep; label: string; emoji: string }[] = [
  { id: 'read',        label: 'Read',    emoji: '📖' },
  { id: 'discuss',     label: 'Discuss', emoji: '💬' },
  { id: 'pray',        label: 'Pray',    emoji: '🙏' },
  { id: 'remember',    label: 'Remember',emoji: '⭐' },
  { id: 'do_it_today', label: 'Do It',   emoji: '🌟' },
];

const STEP_CONFIG: Record<FamilyStep, {
  color: string;
  lightColor: string;
  textColor: string;
  borderColor: string;
  lumiMode: 'read' | 'discuss' | 'pray' | 'remember' | 'do';
}> = {
  read:        { color: '#F59E0B', lightColor: '#FFFBEB', textColor: '#78350F', borderColor: '#FDE68A', lumiMode: 'read' },
  discuss:     { color: '#0EA5E9', lightColor: '#F0F9FF', textColor: '#0C4A6E', borderColor: '#BAE6FD', lumiMode: 'discuss' },
  pray:        { color: '#7C3AED', lightColor: '#F5F3FF', textColor: '#3B0764', borderColor: '#DDD6FE', lumiMode: 'pray' },
  remember:    { color: '#16A34A', lightColor: '#F0FDF4', textColor: '#14532D', borderColor: '#BBF7D0', lumiMode: 'remember' },
  do_it_today: { color: '#EA580C', lightColor: '#FFF7ED', textColor: '#7C2D12', borderColor: '#FED7AA', lumiMode: 'do' },
};

type MemoryPhase = 'hear' | 'say' | 'done';

interface FamilyModeReaderProps {
  chapter: Chapter;
  bookSlug: string;
  initialVerse?: number;
}

export default function FamilyModeReader({ chapter, bookSlug, initialVerse }: FamilyModeReaderProps) {
  const router = useRouter();
  const [verseIndex, setVerseIndex] = useState(() => {
    if (initialVerse && initialVerse >= 1 && initialVerse <= chapter.verses.length) {
      return initialVerse - 1;
    }
    return 0;
  });
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
  const cfg = STEP_CONFIG[step];

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
    const { newBadge } = markVerseComplete(bookSlug, chapter.chapter, verse.verse);
    if (newBadge) setEarnedBadge(newBadge);
    recordSession(bookSlug, chapter.chapter, verse.verse, 'family');
    setSeedsThisChapter((n) => n + 1);
    const memberId = getActiveMemberId();
    if (memberId) {
      recordMemberProgress({ memberId, bookSlug, chapter: chapter.chapter, verse: verse.verse, mode: 'family', type: 'verse' });
    }

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

  useEffect(() => () => stopSpeech(), []);

  // ── Chapter Complete ─────────────────────────────────────────────────────
  if (chapterDone) {
    const totalSeeds = seedsThisChapter + 5;
    const progress   = getProgress();
    const lumiStage  = getLumiStage(progress.wisdomSeeds);
    const lumiLabel  = getLumiLabel(lumiStage);
    return (
      <div className="fixed inset-0 z-50 flex flex-col items-center justify-center text-white text-center px-6 py-12 celebrate-in"
        style={{ background: 'linear-gradient(160deg, #78350F 0%, #92400E 30%, #B45309 60%, #D97706 100%)' }}>
        <div className="mb-4">
          <LumiMascot stage={lumiStage} className="w-28 h-28 sm:w-36 sm:h-36" animate mode="remember" />
          <p className="text-amber-200 text-sm font-bold mt-1">{lumiLabel}</p>
        </div>

        <h2 className="text-4xl font-extrabold mb-2 font-display">Devotion Complete!</h2>
        <p className="text-amber-200 text-lg mb-8">
          You completed all {total} verses of {chapter.book} {chapter.chapter} as a family!
        </p>

        {earnedBadge && (
          <div className="bg-white/20 backdrop-blur-sm rounded-3xl px-8 py-5 mb-6 border border-white/30 shine-pulse">
            <p className="text-amber-200 text-xs font-bold uppercase tracking-widest mb-1">Badge Unlocked!</p>
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
          className="bg-white font-extrabold py-4 rounded-2xl text-lg w-full max-w-xs hover:bg-amber-50 transition-colors"
          style={{ color: '#78350F' }}
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
            <span className="text-sm font-extrabold" style={{ color: '#16A34A' }}>{seedsThisChapter}</span>
            <span className="text-xs font-semibold ml-0.5 hidden sm:inline" style={{ color: '#86EFAC' }}>seeds</span>
          </div>
        </div>
        <div
          role="progressbar"
          aria-valuenow={stepIndex + 1}
          aria-valuemin={1}
          aria-valuemax={STEPS.length}
          aria-label={`Devotion progress: step ${stepIndex + 1} of ${STEPS.length}`}
          className="w-full rounded-full h-3 overflow-hidden transition-colors duration-500"
          style={{ background: cfg.lightColor }}
        >
          <div
            className="h-3 rounded-full transition-all duration-500"
            style={{
              width: `${Math.round(((verseIndex * STEPS.length + stepIndex + 1) / (total * STEPS.length)) * 100)}%`,
              background: cfg.color,
            }}
          />
        </div>
      </div>

      {/* Verse reference — prominent Bible identity marker */}
      <div className="flex items-center justify-between mb-3">
        <span className="inline-flex items-center gap-1.5 bg-amber-100 text-amber-800 text-sm font-extrabold px-3 py-1 rounded-full border border-amber-200">
          📖 {chapter.book} {chapter.chapter}:{verse.verse}
        </span>
        <span className="text-xs text-stone-400 font-medium" aria-hidden="true">
          Step {STEPS.findIndex(s => s.id === step) + 1} of {STEPS.length}
        </span>
      </div>

      {/* Step indicator pills */}
      <div className="flex gap-1.5 mb-5" role="list" aria-label="Devotion steps">
        {STEPS.map((s, i) => {
          const done    = i < stepIndex;
          const current = s.id === step;
          const sCfg    = STEP_CONFIG[s.id];
          return (
            <div
              key={s.id}
              role="listitem"
              aria-current={current ? 'step' : undefined}
              className="flex-1 flex flex-col items-center gap-0.5 py-2 rounded-2xl transition-colors"
              style={
                current
                  ? { background: sCfg.color, color: 'white' }
                  : done
                  ? { background: sCfg.lightColor, color: sCfg.textColor }
                  : { background: '#f5f5f4', color: '#a8a29e' }
              }
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
        <div
          className="bg-white rounded-3xl shadow-lg overflow-hidden border"
          style={{ borderColor: cfg.borderColor }}
        >

          {/* Illustration — always shown */}
          <div className="px-4 pt-5">
            <IllustrationZone
              bookSlug={bookSlug}
              chapter={chapter.chapter}
              verse={verse.verse}
              keywords={verse.keywords}
              illustrationPrompt={verse.illustration_prompt}
              illustrationUrl={verse.illustration_url}
              illustrationAltText={verse.illustration_alt_text}
            />
          </div>

          <div className="px-5 sm:px-7 pt-5 pb-6 space-y-5">

            {/* ── READ step ── */}
            {step === 'read' && (
              <>
                <button
                  onClick={speaking ? () => { stopSpeech(); setSpeaking(false); } : handleRead}
                  className="w-full flex items-center justify-center gap-3 py-5 rounded-2xl text-lg font-extrabold transition-all active:scale-95 focus:outline-none focus-visible:ring-2"
                  style={
                    speaking
                      ? { background: cfg.lightColor, color: cfg.textColor, border: `2px solid ${cfg.borderColor}`, outlineColor: cfg.color }
                      : { background: cfg.color, color: 'white', boxShadow: '0 4px 14px rgba(245,158,11,0.35)', outlineColor: cfg.color }
                  }
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
                <div
                  className="rounded-2xl px-5 py-4 border"
                  style={{ background: cfg.lightColor, borderColor: cfg.borderColor }}
                >
                  <p className="text-xs font-bold uppercase tracking-widest mb-2" style={{ color: cfg.color }}>
                    Memory Phrase
                  </p>
                  <p className="text-lg font-extrabold leading-snug font-child" style={{ color: cfg.textColor }}>
                    ✨ {verse.memory_phrase}
                  </p>
                </div>

                <div>
                  <p className="text-xs font-bold uppercase tracking-widest mb-3" style={{ color: cfg.color }}>
                    💬 Talk Together
                  </p>
                  <ul className="space-y-3">
                    <li
                      className="rounded-2xl px-4 py-3 border text-base font-semibold"
                      style={{ background: cfg.lightColor, borderColor: cfg.borderColor, color: cfg.textColor }}
                    >
                      {verse.discussion_question || 'What is this verse telling us?'}
                    </li>
                    <li
                      className="rounded-2xl px-4 py-3 border text-base font-semibold"
                      style={{ background: cfg.lightColor, borderColor: cfg.borderColor, color: cfg.textColor }}
                    >
                      {verse.family_discussion || 'How can we do this today?'}
                    </li>
                  </ul>
                </div>
              </>
            )}

            {/* ── PRAY step ── */}
            {step === 'pray' && (
              <>
                <div
                  className="rounded-2xl px-5 py-5 border space-y-4"
                  style={{ background: cfg.lightColor, borderColor: cfg.borderColor }}
                >
                  <p className="text-xs font-bold uppercase tracking-widest" style={{ color: cfg.color }}>
                    Family Prayer
                  </p>
                  <p className="text-lg sm:text-xl leading-relaxed italic font-devotion" style={{ color: cfg.textColor }}>
                    {verse.prayer}
                  </p>
                  <button
                    onClick={handlePrayRead}
                    className="text-sm font-semibold flex items-center gap-1.5 focus:outline-none rounded transition-opacity hover:opacity-80"
                    style={{ color: cfg.color }}
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
                {/* Memory phrase card — ages 4-5 */}
                <div
                  className="rounded-3xl px-6 py-5 text-white text-center space-y-1.5 shine-pulse"
                  style={{ background: cfg.color }}
                >
                  <p className="text-3xl mb-1" aria-hidden="true">⭐</p>
                  <p className="text-[10px] font-bold uppercase tracking-widest opacity-75">Memory Phrase · Ages 4–5</p>
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
                    className="w-full flex items-center justify-center gap-2 py-4 rounded-2xl font-bold text-base border-2 transition-colors focus:outline-none focus-visible:ring-2"
                    style={{ background: cfg.lightColor, borderColor: cfg.borderColor, color: cfg.textColor, outlineColor: cfg.color }}
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
                      className="w-full flex items-center justify-center gap-2 py-4 rounded-2xl text-white font-extrabold text-base transition-colors focus:outline-none focus-visible:ring-2"
                      style={{ background: cfg.color, outlineColor: cfg.color }}
                    >
                      <span aria-hidden="true">✓</span> We said it!
                    </button>
                    <button
                      onClick={() => speakText(verse.memory_phrase, { rate: 0.65, pitch: 1.05 })}
                      className="w-full text-sm font-semibold flex items-center justify-center gap-1.5 py-2 focus:outline-none transition-opacity hover:opacity-80"
                      style={{ color: cfg.color }}
                    >
                      <span aria-hidden="true">🔊</span> Hear it again
                    </button>
                  </div>
                )}

                {/* Phase 3: Done — show chapter memory verse for ages 6-7 */}
                {memoryPhase === 'done' && (
                  <div className="space-y-3 fade-in">
                    <div
                      className="flex items-center gap-3 rounded-2xl px-4 py-3 border"
                      style={{ background: cfg.lightColor, borderColor: cfg.borderColor }}
                    >
                      <span className="text-2xl" aria-hidden="true">🌱</span>
                      <div>
                        <p className="text-sm font-bold" style={{ color: cfg.textColor }}>Memory phrase done!</p>
                        <p className="text-xs" style={{ color: cfg.color }}>+1 Wisdom Seed coming up.</p>
                      </div>
                    </div>

                    {/* Chapter memory verse — ages 6-7 / parent-led */}
                    {chapter.memory_verse && (
                      <div className="bg-white rounded-2xl border border-stone-200 px-5 py-4 space-y-2">
                        <div className="flex items-center gap-2">
                          <span className="text-base" aria-hidden="true">📖</span>
                          <p className="text-xs font-bold text-stone-500 uppercase tracking-widest">Weekly Memory Verse · Ages 6–7</p>
                        </div>
                        <p className="text-stone-800 text-base font-bold leading-snug font-child">
                          {getMemoryVerseText(chapter.memory_verse)}
                        </p>
                        {getMemoryVerseRef(chapter.memory_verse) && (
                          <p className="text-xs text-stone-400 font-semibold">
                            — {getMemoryVerseRef(chapter.memory_verse)}
                          </p>
                        )}
                        <button
                          onClick={() => speakText(getMemoryVerseText(chapter.memory_verse), { rate: 0.7, pitch: 1.0 })}
                          className="text-stone-400 hover:text-stone-600 text-xs font-semibold flex items-center gap-1 focus:outline-none rounded transition-colors"
                          aria-label="Hear memory verse"
                        >
                          <span aria-hidden="true">🔊</span> Hear the full verse
                        </button>
                      </div>
                    )}
                  </div>
                )}
              </>
            )}

            {/* ── DO IT TODAY step ── */}
            {step === 'do_it_today' && (
              <>
                <div
                  className="rounded-2xl px-5 py-5 border space-y-3"
                  style={{ background: cfg.lightColor, borderColor: cfg.borderColor }}
                >
                  <div className="flex items-center gap-2">
                    <span className="text-2xl" aria-hidden="true">🌟</span>
                    <p className="text-xs font-bold uppercase tracking-widest" style={{ color: cfg.color }}>
                      Do It Today!
                    </p>
                  </div>
                  <p className="text-stone-800 text-lg font-bold leading-snug font-child">
                    {verse.do_it_today ||
                      `Try to live out this truth today: "${verse.memory_phrase}"`}
                  </p>
                </div>

                {verse.action_challenge && (
                  <div
                    className="rounded-2xl px-4 py-3 border"
                    style={{ background: cfg.lightColor, borderColor: cfg.borderColor }}
                  >
                    <p className="text-xs font-bold uppercase tracking-widest mb-1" style={{ color: cfg.color }}>
                      Family Challenge
                    </p>
                    <p className="text-sm font-semibold leading-snug" style={{ color: cfg.textColor }}>
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
          className="flex-1 flex items-center justify-center gap-1.5 py-4 rounded-2xl font-extrabold text-base border-2 transition-all active:scale-95 focus:outline-none focus-visible:ring-2 disabled:opacity-25 disabled:cursor-not-allowed"
          style={{ borderColor: cfg.borderColor, color: cfg.textColor, outlineColor: cfg.color }}
          aria-label="Previous step"
        >
          <span aria-hidden="true">←</span> Back
        </button>

        <button
          onClick={handleNext}
          className="flex-1 flex items-center justify-center gap-1.5 py-4 rounded-2xl font-extrabold text-base text-white transition-all active:scale-95 shadow-md hover:shadow-lg focus:outline-none focus-visible:ring-2"
          style={{ background: cfg.color, outlineColor: cfg.color }}
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
          className="mt-5 rounded-2xl border px-5 py-3 flex items-center gap-3 fade-in"
          style={{ background: '#F0FDF4', borderColor: '#BBF7D0' }}
        >
          <span className="text-3xl" aria-hidden="true">{earnedBadge.emoji}</span>
          <div>
            <p className="text-xs font-bold uppercase tracking-wide" style={{ color: '#16A34A' }}>Badge Earned!</p>
            <p className="font-bold" style={{ color: '#14532D' }}>{earnedBadge.label}</p>
          </div>
        </div>
      )}
    </div>
  );
}
