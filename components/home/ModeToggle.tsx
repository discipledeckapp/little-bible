'use client';

import { useState, useEffect } from 'react';
import type { AppMode } from '@/types';
import { getStoredMode, storeMode } from '@/lib/mode';

const MODES: { id: AppMode; icon: string; label: string; active: string }[] = [
  { id: 'child',  icon: '📖', label: 'Child',  active: 'bg-amber-500 text-white' },
  { id: 'family', icon: '❤️', label: 'Family', active: 'bg-emerald-500 text-white' },
  { id: 'review', icon: '📝', label: 'Review', active: 'bg-stone-700 text-white' },
];

export default function ModeToggle() {
  const [mode, setMode]     = useState<AppMode>('child');
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMode(getStoredMode());
    setMounted(true);
  }, []);

  const select = (m: AppMode) => {
    setMode(m);
    storeMode(m);
  };

  if (!mounted) {
    return (
      <div className="inline-flex bg-stone-100 rounded-2xl p-1 gap-1 opacity-0 pointer-events-none">
        {MODES.map((m) => (
          <div key={m.id} className="px-4 py-2.5 rounded-xl w-24 h-10" />
        ))}
      </div>
    );
  }

  return (
    <div
      role="group"
      aria-label="Default reading mode"
      className="inline-flex bg-stone-100 rounded-2xl p-1 gap-1"
    >
      {MODES.map((m) => (
        <button
          key={m.id}
          onClick={() => select(m.id)}
          className={`flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-sm font-semibold transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
            mode === m.id ? m.active + ' shadow-sm' : 'text-stone-500 hover:text-stone-700'
          }`}
          aria-pressed={mode === m.id}
          aria-label={`${m.label} Mode`}
        >
          <span aria-hidden="true">{m.icon}</span>
          <span className="hidden sm:inline">{m.label}</span>
        </button>
      ))}
    </div>
  );
}
