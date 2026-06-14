'use client';

import { useEffect, useState } from 'react';

interface SeedToastProps {
  amount: number;
  onHide: () => void;
}

export default function SeedToast({ amount, onHide }: SeedToastProps) {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    // Slide in
    const showTimer = setTimeout(() => setVisible(true), 50);
    // Slide out then hide
    const hideTimer = setTimeout(() => {
      setVisible(false);
      setTimeout(onHide, 400);
    }, 2600);

    return () => {
      clearTimeout(showTimer);
      clearTimeout(hideTimer);
    };
  }, [onHide]);

  return (
    <div
      role="status"
      aria-live="polite"
      className="fixed top-4 left-1/2 z-[60] pointer-events-none"
      style={{
        transform: `translateX(-50%) translateY(${visible ? '0' : '-80px'})`,
        opacity: visible ? 1 : 0,
        transition: 'transform 0.35s cubic-bezier(0.34, 1.56, 0.64, 1), opacity 0.3s ease',
      }}
    >
      <div className="flex items-center gap-2.5 bg-white rounded-full px-5 py-3 shadow-lg border border-amber-100">
        <div className="w-8 h-8 bg-amber-100 rounded-full flex items-center justify-center text-base">
          🌱
        </div>
        <span className="font-extrabold text-stone-800 text-base">
          +{amount} Wisdom {amount === 1 ? 'Seed' : 'Seeds'}
        </span>
        <span className="text-amber-500 font-bold text-sm">earned!</span>
      </div>
    </div>
  );
}
