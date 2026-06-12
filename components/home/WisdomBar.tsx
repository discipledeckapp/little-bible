'use client';

import { useState, useEffect } from 'react';
import { getProgress } from '@/lib/progress';

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

export default function WisdomBar() {
  const [seeds, setSeeds]   = useState(0);
  const [streak, setStreak] = useState(0);
  const [badges, setBadges] = useState(0);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    const p = getProgress();
    setSeeds(p.wisdomSeeds);
    setStreak(p.streak);
    setBadges(p.badges.length);
    setMounted(true);
  }, []);

  if (!mounted) return null;
  if (seeds === 0 && streak === 0) return null;

  const emoji = growthEmoji(seeds);
  const label = growthLabel(seeds);

  return (
    <div
      className="max-w-4xl mx-auto w-full px-4 sm:px-6 py-3"
      role="status"
      aria-label="Your reading progress"
    >
      <div className="bg-amber-50 border border-amber-100 rounded-2xl px-5 py-3 flex items-center justify-between gap-4 flex-wrap">
        <div className="flex items-center gap-5 flex-wrap">
          {/* Growth stage */}
          <div className="flex items-center gap-1.5" title={label}>
            <span className="text-xl" aria-hidden="true">{emoji}</span>
            <div>
              <span className="font-extrabold text-amber-800 text-sm">
                {seeds.toLocaleString()}
              </span>
              <span className="text-amber-500 text-xs font-semibold ml-1 hidden sm:inline">seeds</span>
            </div>
          </div>

          {/* Streak */}
          {streak > 0 && (
            <div className="flex items-center gap-1.5" title="Day streak">
              <span className="text-xl" aria-hidden="true">🔥</span>
              <span className="font-extrabold text-orange-700 text-sm">{streak}</span>
              <span className="text-orange-400 text-xs font-semibold hidden sm:inline">
                {streak === 1 ? 'day' : 'days'}
              </span>
            </div>
          )}

          {/* Badges */}
          {badges > 0 && (
            <div className="flex items-center gap-1.5" title="Badges earned">
              <span className="text-xl" aria-hidden="true">🏅</span>
              <span className="font-extrabold text-purple-700 text-sm">{badges}</span>
              <span className="text-purple-400 text-xs font-semibold hidden sm:inline">
                {badges === 1 ? 'badge' : 'badges'}
              </span>
            </div>
          )}
        </div>

        <p className="text-amber-600 text-xs font-semibold hidden sm:block">{label}</p>
      </div>
    </div>
  );
}
