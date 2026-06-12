'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import type { Story, StoryStep } from '@/types';
import { markStoryStarted, markStoryComplete } from '@/lib/story-progress';
import { addSeeds, getProgress } from '@/lib/progress';
import LumiMascot, { getLumiStage } from '@/components/mascot/LumiMascot';
import LumiStageUp from '@/components/mascot/LumiStageUp';
import type { LumiStage } from '@/components/mascot/LumiMascot';
import WonderWord from '@/components/stories/WonderWord';
import { getWonderWords, type WonderWordDef } from '@/lib/wonder-words';

type Step = 'cover' | 'read' | 'discuss' | 'pray' | 'remember' | 'do' | 'complete';

const STEPS: Step[] = ['read', 'discuss', 'pray', 'remember', 'do'];

interface StepConfig {
  label: string;
  color: string;
  lightColor: string;
  textColor: string;
  modeKey: 'read' | 'discuss' | 'pray' | 'remember' | 'do';
  icon: string;
}

const STEP_CONFIG: Record<string, StepConfig> = {
  read:     { label: 'Read',     color: '#F59E0B', lightColor: '#FFFBEB', textColor: '#78350F', modeKey: 'read',     icon: '📖' },
  discuss:  { label: 'Discuss',  color: '#0EA5E9', lightColor: '#F0F9FF', textColor: '#0C4A6E', modeKey: 'discuss',  icon: '💬' },
  pray:     { label: 'Pray',     color: '#7C3AED', lightColor: '#F5F3FF', textColor: '#3B0764', modeKey: 'pray',     icon: '🙏' },
  remember: { label: 'Remember', color: '#16A34A', lightColor: '#F0FDF4', textColor: '#14532D', modeKey: 'remember', icon: '🌱' },
  do:       { label: 'Do Today', color: '#EA580C', lightColor: '#FFF7ED', textColor: '#7C2D12', modeKey: 'do',       icon: '⚡' },
};

interface StoryReaderProps {
  story: Story;
}

export default function StoryReader({ story }: StoryReaderProps) {
  const router = useRouter();
  const [step, setStep] = useState<Step>('cover');
  const [revealed, setRevealed] = useState(false);
  const [seeds, setSeeds] = useState(0);
  const [stageUpTo, setStageUpTo] = useState<LumiStage | null>(null);

  useEffect(() => {
    const p = getProgress();
    setSeeds(p.wisdomSeeds);
  }, []);

  useEffect(() => {
    if (step !== 'cover') {
      markStoryStarted(story.id);
    }
  }, [step, story.id]);

  function goNext() {
    const idx = STEPS.indexOf(step as (typeof STEPS)[number]);
    if (step === 'cover') { setStep('read'); return; }
    if (idx < STEPS.length - 1) {
      setStep(STEPS[idx + 1]);
      setRevealed(false);
    } else {
      markStoryComplete(story.id);
      const { newStage } = addSeeds(10);
      if (newStage) setStageUpTo(newStage);
      setSeeds(s => s + 10);
      setStep('complete');
    }
  }

  function goBack() {
    const idx = STEPS.indexOf(step as (typeof STEPS)[number]);
    if (step === 'cover') { router.back(); return; }
    if (idx === 0) { setStep('cover'); return; }
    setStep(STEPS[idx - 1]);
    setRevealed(false);
  }

  // ── Cover ──────────────────────────────────────────────────────────────────
  if (step === 'cover') {
    return (
      <div className="min-h-screen flex flex-col" style={{ background: story.coverColor + '12' }}>
        {/* Back button */}
        <div className="p-4">
          <button onClick={() => router.back()} className="text-stone-400 hover:text-stone-600 transition-colors">
            ← Back
          </button>
        </div>

        {/* Cover content */}
        <div className="flex-1 flex flex-col items-center justify-center px-6 text-center pb-12">
          <div className="text-8xl mb-6 animate-bounce" style={{ animationDuration: '2s' }}>
            {story.coverEmoji}
          </div>
          <p className="text-xs font-semibold uppercase tracking-widest mb-2" style={{ color: story.coverColor }}>
            {story.bibleRef} · {story.durationMinutes} min
          </p>
          <h1 className="text-3xl font-bold text-stone-800 mb-3 leading-tight" style={{ fontFamily: 'var(--font-display)' }}>
            {story.title}
          </h1>
          <p className="text-stone-500 text-base leading-relaxed max-w-xs mb-2">
            {story.subtitle}
          </p>

          {/* Main truth pill */}
          <div className="mt-4 px-5 py-3 rounded-2xl max-w-xs" style={{ background: story.coverColor + '20' }}>
            <p className="text-sm font-medium leading-relaxed" style={{ color: story.coverColor }}>
              &ldquo;{story.mainTruth}&rdquo;
            </p>
          </div>

          {/* Step preview */}
          <div className="flex gap-2 mt-6 mb-8">
            {STEPS.map(s => {
              const cfg = STEP_CONFIG[s];
              return (
                <div key={s} className="flex flex-col items-center gap-1">
                  <span className="text-lg">{cfg.icon}</span>
                  <span className="text-xs text-stone-400">{cfg.label}</span>
                </div>
              );
            })}
          </div>

          <button
            onClick={goNext}
            className="w-full max-w-xs py-4 rounded-2xl font-bold text-white text-lg shadow-lg hover:opacity-90 active:scale-95 transition-all"
            style={{ background: story.coverColor }}
          >
            Begin Story →
          </button>
        </div>
      </div>
    );
  }

  // ── Complete ───────────────────────────────────────────────────────────────
  if (step === 'complete') {
    const lumiStage = getLumiStage(seeds);
    return (
      <div className="min-h-screen flex flex-col items-center justify-center px-6 text-center bg-amber-50 pb-12">
        {stageUpTo && (
          <LumiStageUp newStage={stageUpTo} onDismiss={() => setStageUpTo(null)} />
        )}
        <div className="lumi-grow mb-2">
          <LumiMascot stage={lumiStage} animate className="w-28 h-28" />
        </div>
        <p className="text-xs font-semibold text-amber-600 uppercase tracking-widest mb-2">
          Story Complete
        </p>
        <h2 className="text-3xl font-bold text-stone-800 mb-2" style={{ fontFamily: 'var(--font-display)' }}>
          Well done!
        </h2>
        <p className="text-stone-500 text-base leading-relaxed max-w-xs mb-2">
          You finished <strong>{story.title}</strong>.
        </p>
        <div className="leaf-plant mt-2 mb-6 px-5 py-3 bg-amber-100 rounded-2xl">
          <p className="text-amber-800 font-medium text-sm">
            +10 Wisdom Seeds 🌱
          </p>
          <p className="text-amber-700 text-xs mt-1">
            &ldquo;{story.steps.remember.memoryPhrase}&rdquo;
          </p>
        </div>
        <button
          onClick={() => router.push('/')}
          className="w-full max-w-xs py-4 rounded-2xl font-bold text-white bg-amber-500 hover:bg-amber-600 active:scale-95 transition-all"
        >
          ← Back to Stories
        </button>
      </div>
    );
  }

  // ── Active step ────────────────────────────────────────────────────────────
  const cfg = STEP_CONFIG[step];
  if (!cfg) return null;

  const stepData = step === 'do' ? story.steps.doToday : story.steps[step as keyof Omit<Story['steps'], 'doToday'>];
  const stepIdx = STEPS.indexOf(step as (typeof STEPS)[number]);

  return (
    <div className="min-h-screen flex flex-col" style={{ background: cfg.lightColor }}>
      {/* Top nav */}
      <div className="px-4 pt-4 pb-3 flex items-center justify-between">
        <button
          onClick={goBack}
          className="text-sm font-medium transition-colors"
          style={{ color: cfg.color }}
        >
          ← {stepIdx === 0 ? 'Cover' : STEP_CONFIG[STEPS[stepIdx - 1]]?.label}
        </button>

        {/* Step dots */}
        <div className="flex gap-1.5">
          {STEPS.map((s, i) => (
            <div
              key={s}
              className="rounded-full transition-all duration-300"
              style={{
                width: s === step ? '20px' : '8px',
                height: '8px',
                background: s === step ? cfg.color : (i < stepIdx ? cfg.color + '80' : '#D6D3D1'),
              }}
            />
          ))}
        </div>

        <span className="text-sm font-medium" style={{ color: cfg.color }}>
          {cfg.icon} {cfg.label}
        </span>
      </div>

      {/* Step header */}
      <div className="px-5 pt-2 pb-4" style={{ borderBottom: `2px solid ${cfg.color}22` }}>
        <div className="flex items-center gap-2 mb-1">
          <span className="text-xl">{cfg.icon}</span>
          <h2 className="text-xl font-bold" style={{ color: cfg.textColor, fontFamily: 'var(--font-display)' }}>
            {stepData.title}
          </h2>
        </div>
        <p className="text-xs font-medium uppercase tracking-wider" style={{ color: cfg.color }}>
          {story.title}
        </p>
      </div>

      {/* Step body */}
      <div className="flex-1 overflow-y-auto px-5 py-5 slide-in-right">
        <StepBody step={step} stepData={stepData} cfg={cfg} revealed={revealed} setRevealed={setRevealed} wonderDefs={getWonderWords(story.id)} />
      </div>

      {/* Bottom CTA */}
      <div className="px-5 pb-8 pt-3" style={{ borderTop: `1px solid ${cfg.color}22` }}>
        <button
          onClick={goNext}
          className="w-full py-4 rounded-2xl font-bold text-white text-base shadow-md hover:opacity-90 active:scale-95 transition-all"
          style={{ background: cfg.color }}
        >
          {stepIdx === STEPS.length - 1
            ? 'Complete Story 🎉'
            : `Next: ${STEP_CONFIG[STEPS[stepIdx + 1]]?.label} ${STEP_CONFIG[STEPS[stepIdx + 1]]?.icon}`}
        </button>
      </div>
    </div>
  );
}

// ── renderWithWonderWords ─────────────────────────────────────────────────────

function renderWithWonderWords(text: string, defs: WonderWordDef[]): React.ReactNode {
  if (defs.length === 0) return text;

  let parts: (string | React.ReactNode)[] = [text];

  defs.forEach((def, defIdx) => {
    const next: (string | React.ReactNode)[] = [];
    parts.forEach((part, partIdx) => {
      if (typeof part !== 'string') {
        next.push(part);
        return;
      }
      const idx = part.toLowerCase().indexOf(def.phrase.toLowerCase());
      if (idx === -1) {
        next.push(part);
        return;
      }
      const before = part.slice(0, idx);
      const match  = part.slice(idx, idx + def.phrase.length);
      const after  = part.slice(idx + def.phrase.length);
      if (before) next.push(before);
      next.push(
        <WonderWord
          key={`${defIdx}-${partIdx}`}
          word={match}
          fact={def.fact}
          emoji={def.emoji}
        />
      );
      if (after) next.push(after);
    });
    parts = next;
  });

  return <>{parts}</>;
}

// ── StepBody ──────────────────────────────────────────────────────────────────

interface StepBodyProps {
  step: string;
  stepData: StoryStep;
  cfg: StepConfig;
  revealed: boolean;
  setRevealed: (v: boolean) => void;
  wonderDefs: WonderWordDef[];
}

function StepBody({ step, stepData, cfg, revealed, setRevealed, wonderDefs }: StepBodyProps) {
  // READ step
  if (step === 'read') {
    return (
      <div className="space-y-5">
        {/* Narrative text */}
        {stepData.text && (
          <div className="prose prose-stone max-w-none">
            {stepData.text.split('\n').filter(Boolean).map((para, i) => (
              <p key={i} className="text-stone-700 text-base leading-relaxed mb-3" style={{ fontFamily: 'var(--font-devotion)' }}>
                {renderWithWonderWords(para, wonderDefs)}
              </p>
            ))}
          </div>
        )}

        {/* KJV verses */}
        {stepData.verses && stepData.verses.length > 0 && (
          <div className="space-y-3">
            {stepData.verses.map((v, i) => (
              <div key={i} className="rounded-2xl overflow-hidden shadow-sm">
                <div className="px-4 py-3" style={{ background: cfg.color + '15' }}>
                  <p className="text-xs font-bold mb-1" style={{ color: cfg.color }}>{v.ref}</p>
                  <p className="scripture-text text-sm text-stone-600 leading-relaxed mb-2">
                    &ldquo;{v.kjv}&rdquo;
                  </p>
                  <p className="text-sm text-stone-700 leading-snug font-medium">
                    {v.little_bible}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    );
  }

  // DISCUSS step
  if (step === 'discuss') {
    return (
      <div className="space-y-5">
        <div className="rounded-2xl p-5" style={{ background: cfg.color + '15' }}>
          <p className="text-xs font-bold uppercase tracking-wide mb-2" style={{ color: cfg.color }}>
            Ask your child:
          </p>
          <p className="text-stone-800 text-lg font-medium leading-relaxed" style={{ fontFamily: 'var(--font-display)' }}>
            {stepData.question}
          </p>
        </div>

        {stepData.familyQuestion && (
          <div className="rounded-2xl p-5 bg-white shadow-sm">
            <p className="text-xs font-bold uppercase tracking-wide mb-2 text-stone-400">
              Go deeper:
            </p>
            <p className="text-stone-700 text-base leading-relaxed">
              {stepData.familyQuestion}
            </p>
          </div>
        )}

        {stepData.parentGuide && (
          <details className="rounded-xl overflow-hidden">
            <summary className="px-4 py-3 bg-white cursor-pointer text-sm font-medium text-stone-500 flex items-center gap-2 select-none">
              <span>💡</span> Parent guide
            </summary>
            <div className="px-4 py-3 bg-stone-50 text-sm text-stone-600 leading-relaxed border-t border-stone-100">
              {stepData.parentGuide}
            </div>
          </details>
        )}
      </div>
    );
  }

  // PRAY step
  if (step === 'pray') {
    return (
      <div className="space-y-5">
        {/* Guided prayer */}
        <div className="rounded-2xl p-5" style={{ background: cfg.color + '12' }}>
          <p className="text-xs font-bold uppercase tracking-wide mb-3" style={{ color: cfg.color }}>
            Pray together:
          </p>
          <p className="text-stone-700 text-base leading-relaxed" style={{ fontFamily: 'var(--font-devotion)', fontStyle: 'italic' }}>
            {stepData.guidedPrayer}
          </p>
        </div>

        {/* Child prompt */}
        {stepData.childPrompt && (
          <div className="rounded-2xl p-5 bg-white shadow-sm">
            <p className="text-xs font-bold uppercase tracking-wide mb-2" style={{ color: cfg.color }}>
              Then let your child add:
            </p>
            <p className="text-stone-600 text-sm leading-relaxed">
              {stepData.childPrompt}
            </p>
          </div>
        )}

        {/* Prayer points */}
        {stepData.prayerPoints && stepData.prayerPoints.length > 0 && (
          <div className="space-y-2">
            {stepData.prayerPoints.map((pt, i) => (
              <div key={i} className="flex items-start gap-3 px-4 py-3 bg-white rounded-xl shadow-sm">
                <span className="text-sm mt-0.5" style={{ color: cfg.color }}>🙏</span>
                <p className="text-sm text-stone-600 leading-relaxed">{pt}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    );
  }

  // REMEMBER step
  if (step === 'remember') {
    return (
      <div className="space-y-5">
        {/* Memory verse — tap to reveal */}
        <div
          className="rounded-2xl overflow-hidden cursor-pointer"
          onClick={() => setRevealed(true)}
          style={{ background: cfg.color + '15' }}
        >
          <div className="px-5 py-4">
            <p className="text-xs font-bold uppercase tracking-wide mb-2" style={{ color: cfg.color }}>
              {stepData.ref}
            </p>
            {revealed ? (
              <p className="scripture-text text-base text-stone-700 leading-relaxed wonder-reveal">
                &ldquo;{stepData.memoryVerse}&rdquo;
              </p>
            ) : (
              <div className="text-center py-3">
                <p className="text-sm text-stone-400 mb-2">Tap to reveal the verse</p>
                <div className="flex gap-1 justify-center">
                  {[1, 2, 3, 4, 5].map(i => (
                    <div key={i} className="h-2 rounded-full" style={{ width: `${20 + i * 8}px`, background: cfg.color + '40' }} />
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Memory phrase */}
        <div className="rounded-2xl p-5 bg-white shadow-sm text-center">
          <p className="text-xs font-bold uppercase tracking-wide mb-3 text-stone-400">
            Short version to remember:
          </p>
          <p className="text-2xl font-bold leading-tight" style={{ color: cfg.color, fontFamily: 'var(--font-display)' }}>
            &ldquo;{stepData.memoryPhrase}&rdquo;
          </p>
        </div>

        {/* Memory tip */}
        {stepData.tip && (
          <div className="rounded-xl px-4 py-3 bg-stone-50 flex gap-3">
            <span className="text-lg">💡</span>
            <p className="text-sm text-stone-600 leading-relaxed">{stepData.tip}</p>
          </div>
        )}
      </div>
    );
  }

  // DO TODAY step
  if (step === 'do') {
    return (
      <div className="space-y-5">
        <div className="rounded-2xl p-6 text-center" style={{ background: cfg.color + '15' }}>
          <span className="text-5xl mb-3 block">⚡</span>
          <p className="text-xs font-bold uppercase tracking-wide mb-3" style={{ color: cfg.color }}>
            Do It Today
          </p>
          <p className="text-stone-800 text-lg font-medium leading-relaxed" style={{ fontFamily: 'var(--font-display)' }}>
            {stepData.action}
          </p>
        </div>

        {stepData.parentNote && (
          <div className="rounded-xl px-4 py-3 bg-white shadow-sm flex gap-3">
            <span className="text-lg">📌</span>
            <div>
              <p className="text-xs font-bold text-stone-400 uppercase tracking-wide mb-1">Parent note</p>
              <p className="text-sm text-stone-600 leading-relaxed">{stepData.parentNote}</p>
            </div>
          </div>
        )}
      </div>
    );
  }

  return null;
}
