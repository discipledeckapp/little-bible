'use client';

import { getTreeStage } from '@/types/family';
import type { FamilyMember } from '@/types/family';
import { AVATARS } from '@/types/family';

interface FamilyTreeVisualProps {
  totalSeeds: number;
  members: FamilyMember[];
  className?: string;
}

export default function FamilyTreeVisual({ totalSeeds, members, className = '' }: FamilyTreeVisualProps) {
  const tree = getTreeStage(totalSeeds);

  return (
    <div className={`bg-gradient-to-b from-sky-50 to-emerald-50 rounded-3xl border border-emerald-100 p-6 ${className}`}>
      {/* Tree illustration */}
      <div className="flex flex-col items-center mb-5">
        <div className="relative">
          {/* Tree trunk & canopy — grows with stage */}
          <div className="flex flex-col items-center">
            <div
              className="bg-emerald-100 rounded-full flex items-center justify-center transition-all duration-1000"
              style={{
                width: `${Math.min(120, 40 + tree.progress * 0.8)}px`,
                height: `${Math.min(120, 40 + tree.progress * 0.8)}px`,
              }}
              aria-hidden="true"
            >
              <span className="text-5xl select-none" style={{ fontSize: `${Math.min(4, 1.5 + tree.progress * 0.025)}rem` }}>
                {tree.emoji}
              </span>
            </div>

            {/* Member avatars around the tree */}
            {members.length > 0 && (
              <div className="flex items-center gap-2 mt-2">
                {members.slice(0, 4).map((m) => {
                  const avatar = AVATARS[m.avatarId] ?? AVATARS['lion'];
                  return (
                    <div
                      key={m.id}
                      className={`w-8 h-8 rounded-full ${avatar.bg} flex items-center justify-center text-sm border-2 border-white shadow-sm`}
                      title={m.name}
                      aria-label={m.name}
                    >
                      {avatar.emoji}
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Stage label + seed total */}
      <div className="text-center mb-4">
        <p className="text-xs font-extrabold text-emerald-600 uppercase tracking-widest mb-1">{tree.label}</p>
        <p className="text-stone-800 font-extrabold text-2xl">
          {totalSeeds.toLocaleString()}
          <span className="text-stone-400 text-sm font-semibold ml-1.5">seeds</span>
        </p>
      </div>

      {/* Progress bar to next stage */}
      {tree.next !== null && (
        <div>
          <div className="flex justify-between text-[10px] font-bold text-stone-400 mb-1.5">
            <span>{totalSeeds} seeds</span>
            <span>Next: {tree.next}</span>
          </div>
          <div className="w-full bg-emerald-100 rounded-full h-2.5 overflow-hidden">
            <div
              className="h-2.5 bg-emerald-400 rounded-full transition-all duration-700"
              style={{ width: `${tree.progress}%` }}
            />
          </div>
          <p className="text-stone-400 text-xs text-center mt-1.5">
            {(tree.next - totalSeeds).toLocaleString()} seeds until {getTreeStage(tree.next).label}
          </p>
        </div>
      )}

      {/* Per-member seeds */}
      {members.length > 0 && (
        <div className="mt-4 space-y-2">
          {members.map((m) => {
            const avatar = AVATARS[m.avatarId] ?? AVATARS['lion'];
            const pct = totalSeeds > 0 ? Math.round((m.seeds / totalSeeds) * 100) : 0;
            return (
              <div key={m.id} className="flex items-center gap-2.5">
                <span className="text-base shrink-0" aria-hidden="true">{avatar.emoji}</span>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between mb-0.5">
                    <span className="text-xs font-bold text-stone-600 truncate">{m.name}</span>
                    <span className="text-xs font-bold text-emerald-600 ml-2 shrink-0">🌱 {m.seeds}</span>
                  </div>
                  <div className="w-full bg-stone-100 rounded-full h-1.5 overflow-hidden">
                    <div
                      className="h-1.5 bg-emerald-300 rounded-full transition-all"
                      style={{ width: `${pct}%` }}
                    />
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
