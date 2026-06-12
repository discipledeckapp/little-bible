'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { getProgress } from '@/lib/progress';
import { getAllStoryProgress } from '@/lib/story-progress';
import LumiMascot, { getLumiStage } from '@/components/mascot/LumiMascot';

const FIRST_STORY_ID = 'god-made-everything';

const FEATURED_STORIES = [
  {
    id:       'god-made-everything',
    title:    'God Made Everything',
    subtitle: 'In the very beginning, God made it all.',
    emoji:    '🌍',
    color:    '#F59E0B',
    ref:      'Genesis 1',
    memory:   'God made everything, and it was good.',
  },
  {
    id:       'birth-of-jesus',
    title:    'Jesus Is Born',
    subtitle: 'The most amazing night the world had ever seen.',
    emoji:    '⭐',
    color:    '#0EA5E9',
    ref:      'Luke 2',
    memory:   'Jesus came to be with us.',
  },
  {
    id:       'how-to-pray',
    title:    'How to Pray',
    subtitle: 'Jesus taught us exactly how to talk to God.',
    emoji:    '🙏',
    color:    '#7C3AED',
    ref:      'Matthew 6:9-13',
    memory:   'Our Father in heaven.',
  },
];

function getStoryResumeState(): {
  href: string;
  label: string;
  hasStory: boolean;
} {
  if (typeof window === 'undefined') {
    return { href: `/stories/${FIRST_STORY_ID}`, label: 'Start a Story', hasStory: false };
  }

  const storyProgress = getAllStoryProgress();
  const allStories    = Object.values(storyProgress);
  const inProgress    = allStories.find(s => s.status === 'in-progress');
  const lastComplete  = allStories
    .filter(s => s.status === 'complete' || s.status === 'memorised')
    .sort((a, b) => (b.completedAt ?? '').localeCompare(a.completedAt ?? ''))
    .at(0);

  if (inProgress) {
    return { href: `/stories/${inProgress.storyId}`, label: 'Continue Your Story', hasStory: true };
  }
  if (lastComplete) {
    return { href: `/stories/${FIRST_STORY_ID}`, label: 'Start Another Story', hasStory: true };
  }

  return { href: `/stories/${FIRST_STORY_ID}`, label: 'Start a Story', hasStory: false };
}

export default function HeroSection() {
  const [cta,       setCta]       = useState({ href: `/stories/${FIRST_STORY_ID}`, label: 'Start a Story', hasStory: false });
  const [lumiStage, setLumiStage] = useState<ReturnType<typeof getLumiStage>>('seed');
  const [featured,  setFeatured]  = useState(FEATURED_STORIES[0]);

  useEffect(() => {
    const state = getStoryResumeState();
    setCta(state);

    const p = getProgress();
    setLumiStage(getLumiStage(p.wisdomSeeds));

    // Rotate featured story daily
    const dayOfYear = Math.floor(Date.now() / 86_400_000) % FEATURED_STORIES.length;
    setFeatured(FEATURED_STORIES[dayOfYear]);
  }, []);

  return (
    <section className="hero-bg wave-divider relative overflow-hidden">
      {/* Ambient glow */}
      <div
        className="absolute inset-0 opacity-[0.06]"
        style={{
          backgroundImage:
            'radial-gradient(circle at 15% 60%, #fbbf24 0%, transparent 55%), radial-gradient(circle at 85% 20%, #f59e0b 0%, transparent 45%)',
        }}
        aria-hidden="true"
      />

      <div className="relative max-w-5xl mx-auto px-5 sm:px-8 pt-14 pb-28 sm:pt-20 sm:pb-36">
        <div className="flex flex-col lg:flex-row items-center gap-10 lg:gap-16">

          {/* ── Left: Story + CTAs ── */}
          <div className="flex-1 text-center lg:text-left max-w-xl mx-auto lg:mx-0">

            {/* Eyebrow with Lumi */}
            <div className="inline-flex items-center gap-3 mb-6 bg-white/10 backdrop-blur-sm rounded-2xl px-4 py-2.5 border border-white/15">
              <LumiMascot stage={lumiStage} className="w-8 h-8 flex-shrink-0" />
              <p className="text-amber-200 text-xs font-bold tracking-wide">
                Family Devotions · Ages 4–7
              </p>
            </div>

            {/* Headline */}
            <h1 className="font-display text-5xl sm:text-6xl lg:text-[68px] font-bold text-white leading-[1.05] tracking-tight mb-5">
              God&apos;s Word<br />
              <span className="text-amber-300">for Little</span><br />
              Hearts
            </h1>

            {/* Body */}
            <p className="text-amber-100/75 text-lg sm:text-xl leading-relaxed mb-4 max-w-md mx-auto lg:mx-0">
              Bible stories that disciple — every verse faithfully adapted so
              your child can understand, love, and remember God&apos;s Word
              from their earliest years.
            </p>

            {/* Pillars */}
            <div className="flex flex-wrap gap-2 justify-center lg:justify-start mb-9">
              {['Know God', 'Love God', 'Pray', 'Memorize', 'Obey', 'Follow Jesus'].map((p) => (
                <span
                  key={p}
                  className="text-amber-300/80 text-xs font-semibold bg-white/8 border border-amber-500/25 rounded-full px-3 py-1"
                >
                  {p}
                </span>
              ))}
            </div>

            {/* CTAs */}
            <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-3">
              <Link
                href={cta.href}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 bg-amber-400 hover:bg-amber-300 text-amber-950 font-extrabold text-base px-7 py-4 rounded-2xl transition-all active:scale-95 shadow-lg shadow-amber-900/40 hover:shadow-xl hover:shadow-amber-900/30 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
              >
                <span aria-hidden="true">📖</span>
                {cta.label}
                <span aria-hidden="true" className="text-amber-700">→</span>
              </Link>

              <a
                href="#library"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 text-amber-200 hover:text-white font-semibold text-base px-7 py-4 rounded-2xl border border-amber-700/50 hover:border-amber-400/60 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
              >
                Open the Bible
              </a>
            </div>

            <p className="mt-7 text-amber-400/50 text-xs font-medium">
              Free · Faithful to Scripture · All 66 books · Complete Bible coming
            </p>
          </div>

          {/* ── Right: Featured story card ── */}
          <div className="flex-shrink-0 w-full max-w-sm lg:max-w-[300px] xl:max-w-sm">
            <Link
              href={`/stories/${featured.id}`}
              className="card-glass rounded-3xl p-6 shadow-2xl border border-amber-200/30 relative block group hover:scale-[1.02] transition-transform duration-200"
              aria-label={`Featured story: ${featured.title}`}
            >
              {/* Card header */}
              <div className="flex items-center justify-between mb-4">
                <div>
                  <p className="text-amber-600 text-xs font-bold uppercase tracking-widest">
                    Featured Story
                  </p>
                  <p className="text-stone-500 text-xs mt-0.5">{featured.ref}</p>
                </div>
                <LumiMascot stage={lumiStage} className="w-12 h-12" />
              </div>

              {/* Story cover */}
              <div
                className="rounded-2xl px-5 py-6 mb-4 flex flex-col items-center text-center gap-2"
                style={{ background: featured.color + '18', border: `1px solid ${featured.color}30` }}
              >
                <span className="text-5xl" aria-hidden="true">{featured.emoji}</span>
                <p
                  className="font-extrabold text-stone-800 text-lg leading-tight"
                  style={{ fontFamily: 'var(--font-display)' }}
                >
                  {featured.title}
                </p>
                <p className="text-stone-500 text-sm leading-snug">{featured.subtitle}</p>
              </div>

              {/* Memory phrase */}
              <div className="flex items-center gap-2 mb-4">
                <span className="text-lg" aria-hidden="true">✨</span>
                <p className="text-stone-800 font-extrabold text-sm font-child">
                  {featured.memory}
                </p>
              </div>

              {/* 5-step devotion preview */}
              <div className="divider-amber mb-4" aria-hidden="true" />
              <p className="text-stone-400 text-xs font-medium mb-2.5 uppercase tracking-widest">
                5-Step Family Devotion
              </p>
              <div className="flex gap-1.5">
                {[
                  { emoji: '📖', label: 'Read',    color: '#F59E0B' },
                  { emoji: '💬', label: 'Discuss', color: '#0EA5E9' },
                  { emoji: '🙏', label: 'Pray',    color: '#7C3AED' },
                  { emoji: '⭐', label: 'Remember',color: '#16A34A' },
                  { emoji: '🌟', label: 'Do It',   color: '#EA580C' },
                ].map((s, i) => (
                  <div
                    key={s.label}
                    className="flex-1 flex flex-col items-center gap-0.5 py-2 rounded-xl transition-colors"
                    style={
                      i === 0
                        ? { background: s.color, color: 'white' }
                        : { background: '#f5f5f4', color: '#a8a29e' }
                    }
                    aria-hidden="true"
                  >
                    <span className="text-xs">{s.emoji}</span>
                    <span className="text-[9px] font-bold leading-none">{s.label}</span>
                  </div>
                ))}
              </div>

              <div
                className="mt-4 block w-full text-center text-white font-extrabold py-3.5 rounded-2xl text-sm transition-colors group-hover:opacity-90"
                style={{ background: featured.color }}
              >
                Read This Story →
              </div>
            </Link>
          </div>

        </div>
      </div>
    </section>
  );
}
