'use client';

import { useEffect, useRef } from 'react';
import LumiMascot, { getLumiLabel } from '@/components/mascot/LumiMascot';
import type { LumiStage } from '@/components/mascot/LumiMascot';

const STAGE_UP_MESSAGES: Record<LumiStage, { headline: string; body: string; emoji: string }> = {
  seed:         { headline: 'A seed is planted!',         body: 'Every journey starts with one small step.',              emoji: '🌱' },
  sprout:       { headline: 'Lumi is sprouting!',         body: 'You are growing in God\'s Word. Keep going!',            emoji: '🌿' },
  sapling:      { headline: 'A sapling appears!',         body: 'Your roots are going deep. God is proud of you.',        emoji: '🌳' },
  'young-tree': { headline: 'Lumi is growing tall!',      body: 'You\'re becoming like the tree in Psalm 1. Keep reading!', emoji: '🌲' },
  'tree-of-life': { headline: 'The Tree of Life!',        body: 'You have hidden God\'s Word in your heart. Well done!',  emoji: '✨' },
};

interface LumiStageUpProps {
  newStage: LumiStage;
  onDismiss: () => void;
}

export default function LumiStageUp({ newStage, onDismiss }: LumiStageUpProps) {
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const msg = STAGE_UP_MESSAGES[newStage];

  useEffect(() => {
    timerRef.current = setTimeout(onDismiss, 3500);
    return () => { if (timerRef.current) clearTimeout(timerRef.current); };
  }, [onDismiss]);

  return (
    <div
      className="fixed inset-0 z-[100] flex flex-col items-center justify-center text-center px-8 celebrate-in"
      style={{
        background: 'linear-gradient(160deg, #1c0d00 0%, #3d1a00 30%, #78350F 60%, #D97706 100%)',
      }}
      onClick={onDismiss}
      role="dialog"
      aria-modal="true"
      aria-label={`Lumi stage up: ${getLumiLabel(newStage)}`}
    >
      {/* Stars / sparkle bg */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden" aria-hidden="true">
        {[
          { top: '8%',  left: '12%', size: 'w-2 h-2', delay: '0s' },
          { top: '15%', left: '78%', size: 'w-3 h-3', delay: '0.2s' },
          { top: '72%', left: '8%',  size: 'w-2 h-2', delay: '0.4s' },
          { top: '80%', left: '85%', size: 'w-3 h-3', delay: '0.1s' },
          { top: '45%', left: '92%', size: 'w-2 h-2', delay: '0.3s' },
          { top: '30%', left: '5%',  size: 'w-2 h-2', delay: '0.5s' },
        ].map((star, i) => (
          <div
            key={i}
            className={`absolute ${star.size} rounded-full bg-amber-300 opacity-60 shine-pulse`}
            style={{ top: star.top, left: star.left, animationDelay: star.delay }}
          />
        ))}
      </div>

      {/* Lumi — large, animated */}
      <div className="relative mb-4">
        <LumiMascot
          stage={newStage}
          animate
          className="w-40 h-40 sm:w-48 sm:h-48 drop-shadow-2xl"
        />
        {/* Glow ring behind Lumi */}
        <div
          className="absolute inset-0 rounded-full blur-2xl opacity-40 -z-10 scale-110"
          style={{ background: '#F59E0B' }}
          aria-hidden="true"
        />
      </div>

      <div className="mb-2">
        <span className="text-4xl">{msg.emoji}</span>
      </div>

      <p className="text-amber-300 text-xs font-bold uppercase tracking-widest mb-2">
        {getLumiLabel(newStage)}
      </p>

      <h2
        className="text-3xl sm:text-4xl font-extrabold text-white mb-3 leading-tight"
        style={{ fontFamily: 'var(--font-display, Georgia)' }}
      >
        {msg.headline}
      </h2>

      <p className="text-amber-200 text-base max-w-xs leading-relaxed mb-10">
        {msg.body}
      </p>

      <p className="text-amber-400/60 text-xs font-medium">Tap anywhere to continue</p>
    </div>
  );
}
