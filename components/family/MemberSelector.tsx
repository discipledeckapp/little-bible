'use client';

import { useState, useRef, useEffect } from 'react';
import { useFamily } from './FamilyContext';
import { AVATARS } from '@/types/family';

export default function MemberSelector() {
  const { family, activeMember, setActiveMemberId } = useFamily();
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function onClickOutside(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener('mousedown', onClickOutside);
    return () => document.removeEventListener('mousedown', onClickOutside);
  }, []);

  if (!family || family.members.length === 0) return null;

  const activeAvatar = activeMember ? (AVATARS[activeMember.avatarId] ?? AVATARS['lion']) : null;

  return (
    <div ref={ref} className="relative">
      <button
        onClick={() => setOpen((o) => !o)}
        className="flex items-center gap-2 bg-amber-50 hover:bg-amber-100 border border-amber-200 rounded-2xl px-3 py-2 text-sm font-bold text-amber-800 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
        aria-haspopup="listbox"
        aria-expanded={open}
        aria-label={activeMember ? `Reading for ${activeMember.name}` : 'Select who is reading'}
      >
        {activeAvatar && (
          <span className="text-base" aria-hidden="true">{activeAvatar.emoji}</span>
        )}
        <span className="max-w-[80px] truncate">
          {activeMember?.name ?? 'Select child'}
        </span>
        <span className="text-amber-500 text-[10px]" aria-hidden="true">▾</span>
      </button>

      {open && (
        <div
          role="listbox"
          aria-label="Choose who is reading"
          className="absolute right-0 top-full mt-2 w-52 bg-white rounded-2xl shadow-xl border border-stone-100 py-1.5 z-30 overflow-hidden"
        >
          <p className="text-[10px] font-extrabold text-stone-400 uppercase tracking-widest px-3 pt-1.5 pb-2">
            Who&apos;s reading?
          </p>
          {family.members.map((m) => {
            const av = AVATARS[m.avatarId] ?? AVATARS['lion'];
            const isActive = activeMember?.id === m.id;
            return (
              <button
                key={m.id}
                role="option"
                aria-selected={isActive}
                onClick={() => { setActiveMemberId(m.id); setOpen(false); }}
                className={`w-full flex items-center gap-3 px-3 py-2.5 text-sm font-bold transition-colors text-left ${
                  isActive ? 'bg-amber-50 text-amber-800' : 'text-stone-700 hover:bg-stone-50'
                }`}
              >
                <span className="text-lg shrink-0" aria-hidden="true">{av.emoji}</span>
                <div className="flex-1 min-w-0">
                  <p className="truncate">{m.name}</p>
                  {m.age && <p className="text-[10px] text-stone-400 font-normal">Age {m.age}</p>}
                </div>
                <div className="flex items-center gap-0.5 shrink-0">
                  <span className="text-[10px] text-amber-500">🌱</span>
                  <span className="text-[10px] font-extrabold text-amber-600">{m.seeds}</span>
                </div>
                {isActive && <span className="text-amber-500 shrink-0 text-xs">✓</span>}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
