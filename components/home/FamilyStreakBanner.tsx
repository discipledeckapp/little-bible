'use client';

import { useState, useEffect } from 'react';
import { getProgress } from '@/lib/progress';
import { getLumiStage, getLumiLabel } from '@/components/mascot/LumiMascot';

function growthEmoji(seeds: number): string {
  if (seeds >= 51) return '🌳';
  if (seeds >= 21) return '🌿';
  return '🌱';
}

function growthLabel(seeds: number): string {
  if (seeds >= 51) return 'Tree of Wisdom';
  if (seeds >= 21) return 'Growing Strong';
  return 'Just Planted';
}

export default function FamilyStreakBanner() {
  const [seeds,    setSeeds]    = useState(0);
  const [sessions, setSessions] = useState(0);
  const [mounted,  setMounted]  = useState(false);

  useEffect(() => {
    const p = getProgress();
    setSeeds(p.wisdomSeeds);
    setSessions(p.sessions.length);
    setMounted(true);
  }, []);

  // Don't render on server — progress lives in localStorage
  if (!mounted || seeds === 0) return null;

  const stage = getLumiStage(seeds);
  const label = getLumiLabel(stage);

  return (
    <div
      className="mx-4 sm:mx-auto max-w-5xl"
      role="region"
      aria-label="Your growth journey"
    >
      <div className="bg-gradient-to-r from-amber-50 via-amber-50 to-emerald-50 border border-amber-200 rounded-3xl px-5 py-4 flex items-center gap-4 flex-wrap sm:flex-nowrap shadow-sm">

        {/* Growth emoji + stage label */}
        <div className="flex items-center gap-3 flex-shrink-0">
          <span className="text-3xl leading-none" aria-hidden="true">
            {growthEmoji(seeds)}
          </span>
          <div>
            <p className="text-xs font-bold text-stone-400 uppercase tracking-widest leading-none mb-0.5">
              Growth Stage
            </p>
            <p className="text-amber-800 font-extrabold text-sm leading-tight">
              {growthLabel(seeds)}
            </p>
          </div>
        </div>

        {/* Divider */}
        <div className="hidden sm:block w-px h-10 bg-amber-200 flex-shrink-0" aria-hidden="true" />

        {/* Seeds count */}
        <div className="flex items-center gap-2 flex-shrink-0">
          <span className="text-xl leading-none" aria-hidden="true">🌱</span>
          <div>
            <p className="text-xs font-bold text-stone-400 uppercase tracking-widest leading-none mb-0.5">
              Wisdom Seeds
            </p>
            <p className="text-emerald-700 font-extrabold text-sm leading-tight">
              {seeds} collected
            </p>
          </div>
        </div>

        {/* Divider */}
        <div className="hidden sm:block w-px h-10 bg-amber-200 flex-shrink-0" aria-hidden="true" />

        {/* Session count */}
        <div className="flex items-center gap-2 flex-shrink-0">
          <span className="text-xl leading-none" aria-hidden="true">📖</span>
          <div>
            <p className="text-xs font-bold text-stone-400 uppercase tracking-widest leading-none mb-0.5">
              Bible Times
            </p>
            <p className="text-sky-700 font-extrabold text-sm leading-tight">
              {sessions} completed
            </p>
          </div>
        </div>

        {/* Lumi label — right edge on desktop */}
        <div className="sm:ml-auto flex items-center gap-2">
          <div className="bg-amber-100 rounded-2xl px-3 py-1.5 border border-amber-200">
            <p className="text-amber-800 text-xs font-bold">
              Lumi is a {label} ✨
            </p>
          </div>
        </div>

      </div>
    </div>
  );
}
