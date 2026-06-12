'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { getProgress } from '@/lib/progress';
import LumiMascot, { getLumiStage } from '@/components/mascot/LumiMascot';

function getResumeHref(): string {
  if (typeof window === 'undefined') return '/proverbs/1';
  const p = getProgress();
  if (p.sessions.length > 0) {
    const last = p.sessions[p.sessions.length - 1];
    return `/${last.book}/${last.chapter}`;
  }
  return '/proverbs/1';
}

export default function HeroSection() {
  const [resumeHref, setResumeHref] = useState('/proverbs/1');
  const [hasHistory, setHasHistory] = useState(false);
  const [lumiStage, setLumiStage]   = useState<ReturnType<typeof getLumiStage>>('seed');

  useEffect(() => {
    const href = getResumeHref();
    setResumeHref(href);
    setHasHistory(href !== '/proverbs/1');
    const p = getProgress();
    setLumiStage(getLumiStage(p.wisdomSeeds));
  }, []);

  return (
    <section className="hero-bg wave-divider relative overflow-hidden">
      {/* Ambient glow layers */}
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
              Short, faithful, and warm — every verse of Scripture adapted so
              your child can understand, love, and remember God&apos;s Word
              from their earliest years.
            </p>

            {/* Discipleship pillars — concise */}
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
                href={resumeHref}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 bg-amber-400 hover:bg-amber-300 text-amber-950 font-extrabold text-base px-7 py-4 rounded-2xl transition-all active:scale-95 shadow-lg shadow-amber-900/40 hover:shadow-xl hover:shadow-amber-900/30 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
              >
                <span aria-hidden="true">📖</span>
                {hasHistory ? 'Continue Bible Time' : "Start Today's Bible Time"}
                <span aria-hidden="true" className="text-amber-700">→</span>
              </Link>

              <a
                href="#library"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 text-amber-200 hover:text-white font-semibold text-base px-7 py-4 rounded-2xl border border-amber-700/50 hover:border-amber-400/60 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
              >
                Explore the Bible
              </a>
            </div>

            <p className="mt-7 text-amber-400/50 text-xs font-medium">
              Free · Open source · Faithful to Scripture · All 66 books coming
            </p>
          </div>

          {/* ── Right: Featured verse card ── */}
          <div className="flex-shrink-0 w-full max-w-sm lg:max-w-[300px] xl:max-w-sm">
            <div
              className="card-glass rounded-3xl p-6 shadow-2xl border border-amber-200/30 relative"
              aria-label="Featured verse preview"
            >
              {/* Card header */}
              <div className="flex items-center justify-between mb-4">
                <div>
                  <p className="text-amber-600 text-xs font-bold uppercase tracking-widest">
                    Today&apos;s Reading
                  </p>
                  <p className="text-stone-700 font-bold text-base mt-0.5">Proverbs 1:7</p>
                </div>
                <LumiMascot className="w-12 h-12" />
              </div>

              {/* Verse */}
              <div className="bg-amber-50 rounded-2xl px-4 py-4 mb-4 border border-amber-100">
                <p className="scripture-text text-stone-700 text-sm leading-relaxed">
                  &ldquo;Respecting God is where wisdom begins.&rdquo;
                </p>
              </div>

              {/* Memory phrase */}
              <div className="flex items-center gap-2 mb-4">
                <span className="text-lg" aria-hidden="true">✨</span>
                <p className="text-stone-800 font-extrabold text-sm font-child">
                  Wisdom starts with God.
                </p>
              </div>

              {/* 5-step devotion preview */}
              <div className="divider-amber mb-4" aria-hidden="true" />
              <p className="text-stone-400 text-xs font-medium mb-2.5 uppercase tracking-widest">
                5-Step Family Devotion
              </p>
              <div className="flex gap-1.5">
                {[
                  { emoji: '📖', label: 'Read' },
                  { emoji: '💬', label: 'Discuss' },
                  { emoji: '🙏', label: 'Pray' },
                  { emoji: '⭐', label: 'Remember' },
                  { emoji: '🌟', label: 'Do It' },
                ].map((s, i) => (
                  <div
                    key={s.label}
                    className={`flex-1 flex flex-col items-center gap-0.5 py-2 rounded-xl ${
                      i === 0
                        ? 'bg-amber-500 text-white'
                        : 'bg-stone-100 text-stone-400'
                    }`}
                    aria-hidden="true"
                  >
                    <span className="text-xs">{s.emoji}</span>
                    <span className="text-[9px] font-bold leading-none">{s.label}</span>
                  </div>
                ))}
              </div>

              <Link
                href={resumeHref}
                className="mt-4 block w-full text-center bg-amber-500 hover:bg-amber-600 text-white font-extrabold py-3.5 rounded-2xl text-sm transition-colors active:scale-95"
              >
                Begin Devotion →
              </Link>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}
