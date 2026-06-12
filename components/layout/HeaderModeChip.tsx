'use client';

import { useState, useEffect } from 'react';
import { getStoredMode } from '@/lib/mode';
import type { AppMode } from '@/types';

const CHIP: Record<AppMode, { icon: string; label: string; className: string }> = {
  child:  { icon: '📖', label: 'Child',  className: 'bg-amber-100 text-amber-700' },
  family: { icon: '❤️', label: 'Family', className: 'bg-emerald-100 text-emerald-700' },
  review: { icon: '📝', label: 'Review', className: 'bg-stone-200 text-stone-600' },
};

export default function HeaderModeChip() {
  const [mode, setMode]     = useState<AppMode>('child');
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMode(getStoredMode());
    setMounted(true);

    // Sync across tabs / reader navigation
    const onStorage = (e: StorageEvent) => {
      if (e.key === 'little_bible_mode' && e.newValue) {
        setMode(e.newValue as AppMode);
      }
    };
    window.addEventListener('storage', onStorage);
    return () => window.removeEventListener('storage', onStorage);
  }, []);

  if (!mounted) return null;

  const chip = CHIP[mode];

  return (
    <span
      className={`hidden sm:inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold ${chip.className}`}
      title={`Current reading mode: ${chip.label}`}
      aria-label={`Reading mode: ${chip.label}`}
    >
      <span aria-hidden="true">{chip.icon}</span>
      {chip.label}
    </span>
  );
}
