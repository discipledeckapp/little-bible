'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import type { Journey, Story, StoryStatus } from '@/types';
import { getAllStoryProgress } from '@/lib/story-progress';
import LumiMascot, { getLumiLabel } from '@/components/mascot/LumiMascot';

interface JourneyDetailClientProps {
  journey: Journey;
  stories: Story[];
}

export default function JourneyDetailClient({ journey, stories }: JourneyDetailClientProps) {
  const [progressMap, setProgressMap] = useState<Record<string, StoryStatus>>({});

  useEffect(() => {
    const all = getAllStoryProgress();
    const map: Record<string, StoryStatus> = {};
    stories.forEach(s => {
      map[s.id] = all[s.id]?.status ?? 'unread';
    });
    setProgressMap(map);
  }, [stories]);

  const completedCount = stories.filter(s =>
    progressMap[s.id] === 'complete' || progressMap[s.id] === 'memorised'
  ).length;

  const total = stories.length;
  const pct = total > 0 ? (completedCount / total) * 100 : 0;
  const isStarted  = completedCount > 0;
  const isComplete = completedCount >= total && total > 0;

  // Find the first incomplete story for "Continue" CTA
  const nextStory = stories.find(s =>
    progressMap[s.id] !== 'complete' && progressMap[s.id] !== 'memorised'
  ) ?? stories[0];

  return (
    <div>
      {/* Header */}
      <div
        className="relative px-5 pt-12 pb-16 text-center overflow-hidden"
        style={{
          background: `linear-gradient(160deg, ${journey.coverColor}25 0%, ${journey.coverColor}40 100%)`,
        }}
      >
        {/* Back */}
        <Link
          href="/"
          className="absolute top-4 left-4 text-stone-600 hover:text-stone-800 font-semibold text-sm flex items-center gap-1 transition-colors"
        >
          ← Home
        </Link>

        {/* Cover emoji + Lumi */}
        <div className="flex items-end justify-center gap-4 mb-4">
          <span className="text-6xl">{journey.coverEmoji}</span>
          <LumiMascot
            stage={isComplete ? journey.lumiStageEnd : journey.lumiStageStart}
            animate={isComplete}
            className="w-20 h-20"
          />
        </div>

        {/* Meta */}
        <p className="text-xs font-bold uppercase tracking-widest mb-1" style={{ color: journey.coverColor }}>
          Ages {journey.ageRange} · {journey.durationWeeks} weeks
        </p>
        <h1
          className="text-3xl sm:text-4xl font-extrabold text-stone-800 mb-2 leading-tight"
          style={{ fontFamily: 'var(--font-display)' }}
        >
          {journey.name}
        </h1>
        <p className="text-stone-600 text-base max-w-sm mx-auto leading-relaxed mb-6">
          {journey.subtitle}
        </p>

        {/* Main truth */}
        <div
          className="inline-block rounded-2xl px-5 py-3 text-sm font-semibold max-w-xs mx-auto mb-6"
          style={{ background: journey.coverColor + '18', color: journey.coverColor }}
        >
          {journey.mainTruth}
        </div>

        {/* Progress bar */}
        {isStarted && (
          <div className="max-w-xs mx-auto">
            <div className="flex justify-between text-xs text-stone-400 mb-1.5">
              <span>{completedCount} of {total} stories complete</span>
              <span>{Math.round(pct)}%</span>
            </div>
            <div className="h-3 bg-white/60 rounded-full overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-700"
                style={{ width: `${pct}%`, background: journey.coverColor }}
              />
            </div>
          </div>
        )}
      </div>

      {/* Story list */}
      <div className="max-w-2xl mx-auto px-4 py-8">

        {/* Lumi stage labels */}
        <div className="flex items-center justify-between mb-6 px-1">
          <div className="flex items-center gap-2 text-xs text-stone-400">
            <LumiMascot stage={journey.lumiStageStart} className="w-8 h-8" />
            <span>{getLumiLabel(journey.lumiStageStart)}</span>
          </div>
          <div className="flex-1 mx-4 h-px bg-stone-200" />
          <div className="flex items-center gap-2 text-xs text-stone-400">
            <span>{getLumiLabel(journey.lumiStageEnd)}</span>
            <LumiMascot stage={journey.lumiStageEnd} className="w-8 h-8" />
          </div>
        </div>

        {/* Stories */}
        <div className="space-y-3">
          {stories.map((story, i) => {
            const status = progressMap[story.id] ?? 'unread';
            const isNext = story.id === nextStory?.id && !isComplete;
            return (
              <Link
                key={story.id}
                href={`/stories/${story.id}`}
                className={`flex items-center gap-4 p-4 rounded-2xl border transition-all hover:shadow-md active:scale-[0.99] ${
                  isNext
                    ? 'bg-white shadow-sm border-amber-200'
                    : 'bg-white border-stone-100'
                }`}
              >
                {/* Step number */}
                <div
                  className="w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold shrink-0"
                  style={
                    status === 'complete' || status === 'memorised'
                      ? { background: journey.coverColor + '20', color: journey.coverColor }
                      : isNext
                      ? { background: journey.coverColor, color: 'white' }
                      : { background: '#f5f5f4', color: '#a8a29e' }
                  }
                >
                  {status === 'complete' || status === 'memorised' ? '✓' : i + 1}
                </div>

                {/* Story info */}
                <div className="flex-1 min-w-0">
                  <p className="font-bold text-stone-800 text-sm leading-tight">{story.title}</p>
                  <p className="text-stone-400 text-xs mt-0.5 truncate">{story.subtitle}</p>
                </div>

                {/* Story emoji + status */}
                <div className="flex items-center gap-2 shrink-0">
                  <span className="text-2xl">{story.coverEmoji}</span>
                  {isNext && (
                    <span
                      className="text-xs font-bold px-2 py-0.5 rounded-full"
                      style={{ background: journey.coverColor + '20', color: journey.coverColor }}
                    >
                      {status === 'in-progress' ? 'In Progress' : 'Up Next'}
                    </span>
                  )}
                </div>
              </Link>
            );
          })}
        </div>

        {/* CTA */}
        <div className="mt-8">
          <Link
            href={`/stories/${nextStory?.id ?? stories[0]?.id}`}
            className="block w-full text-center text-white font-extrabold py-4 rounded-2xl text-base transition-all hover:opacity-90 active:scale-[0.98] shadow-md"
            style={{ background: journey.coverColor }}
          >
            {isComplete
              ? 'Journey Complete! Read Again ✓'
              : isStarted
              ? `Continue: ${nextStory?.title} →`
              : `Begin: ${stories[0]?.title} →`}
          </Link>

          {isComplete && journey.completionMessage && (
            <div
              className="mt-4 text-center px-6 py-4 rounded-2xl text-sm font-semibold"
              style={{ background: journey.coverColor + '15', color: journey.coverColor }}
            >
              🌳 {journey.completionMessage}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
