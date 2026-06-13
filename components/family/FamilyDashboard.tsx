'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useSession } from 'next-auth/react';
import { useFamily } from './FamilyContext';
import ChildProfileCard from './ChildProfileCard';
import FamilyTreeVisual from './FamilyTreeVisual';
import { AVATARS } from '@/types/family';
import type { FamilyDashboard as DashboardData } from '@/types/family';

function BIBLE_BOOK_NAME(slug: string): string {
  const n: Record<string, string> = {
    genesis: 'Genesis', psalms: 'Psalms', proverbs: 'Proverbs',
    matthew: 'Matthew', mark: 'Mark', luke: 'Luke', john: 'John',
  };
  return n[slug] ?? slug.charAt(0).toUpperCase() + slug.slice(1);
}

export default function FamilyDashboard() {
  const { family, totalSeeds, loading } = useFamily();
  const { status } = useSession();
  const [dashboard, setDashboard] = useState<DashboardData | null>(null);
  const [dashLoading, setDashLoading] = useState(false);

  useEffect(() => {
    if (!family) return;
    setDashLoading(true);
    fetch('/api/family/dashboard')
      .then((r) => r.json())
      .then((d) => { setDashboard(d); setDashLoading(false); })
      .catch(() => setDashLoading(false));
  }, [family?.id]); // eslint-disable-line react-hooks/exhaustive-deps

  if (status === 'unauthenticated') return null;
  if (loading) return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 py-10 flex justify-center">
      <div className="w-8 h-8 border-4 border-amber-200 border-t-amber-500 rounded-full animate-spin" />
    </div>
  );
  if (!family) return null;

  const streak = family.streak;

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 py-10 space-y-8">

      {/* ── Family header ── */}
      <div className="flex items-center justify-between">
        <div>
          <p className="text-amber-500 text-xs font-extrabold uppercase tracking-widest mb-0.5">Your Family</p>
          <h2 className="font-display text-2xl font-extrabold text-stone-800">
            {family.name ?? 'Your Family Bible'}
          </h2>
        </div>
        <Link
          href="/family"
          className="text-sm font-bold text-amber-600 hover:text-amber-800 bg-amber-50 hover:bg-amber-100 border border-amber-200 rounded-2xl px-4 py-2 transition-colors"
        >
          Manage →
        </Link>
      </div>

      {/* ── Streak + seeds summary ── */}
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
        {streak && streak.currentStreak > 0 && (
          <div className="bg-orange-50 border border-orange-100 rounded-2xl px-4 py-4 text-center">
            <p className="text-3xl font-extrabold text-orange-600">🔥 {streak.currentStreak}</p>
            <p className="text-orange-400 text-xs font-bold mt-0.5">
              {streak.currentStreak === 1 ? 'Day Streak' : 'Day Streak'}
            </p>
          </div>
        )}
        <div className="bg-emerald-50 border border-emerald-100 rounded-2xl px-4 py-4 text-center">
          <p className="text-3xl font-extrabold text-emerald-600">🌱 {totalSeeds}</p>
          <p className="text-emerald-400 text-xs font-bold mt-0.5">Family Seeds</p>
        </div>
        <div className="bg-amber-50 border border-amber-100 rounded-2xl px-4 py-4 text-center">
          <p className="text-3xl font-extrabold text-amber-600">📖 {family.members.length}</p>
          <p className="text-amber-400 text-xs font-bold mt-0.5">
            {family.members.length === 1 ? 'Reader' : 'Readers'}
          </p>
        </div>
      </div>

      {/* ── Child profile cards ── */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-bold text-stone-700 text-sm uppercase tracking-widest">Your Children</h3>
          <Link href="/family" className="text-xs text-amber-600 font-bold hover:underline">
            + Add child
          </Link>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {family.members.map((m) => (
            <ChildProfileCard key={m.id} member={m} />
          ))}
        </div>
      </div>

      {/* ── Family tree ── */}
      <FamilyTreeVisual totalSeeds={totalSeeds} members={family.members} />

      {/* ── Recent activity ── */}
      {dashboard?.recentActivity && dashboard.recentActivity.length > 0 && (
        <div>
          <h3 className="font-bold text-stone-700 text-sm uppercase tracking-widest mb-4">Recent Together</h3>
          <div className="bg-white rounded-3xl border border-stone-100 shadow-sm divide-y divide-stone-50 overflow-hidden">
            {dashboard.recentActivity.slice(0, 8).map((item, i) => {
              const av = AVATARS[item.memberAvatarId] ?? AVATARS['lion'];
              return (
                <div key={i} className="flex items-center gap-3 px-5 py-3.5">
                  <span className="text-xl shrink-0" aria-hidden="true">{av.emoji}</span>
                  <p className="text-stone-700 text-sm font-medium flex-1">{item.description}</p>
                  <p className="text-stone-300 text-xs shrink-0">
                    {new Date(item.occurredAt).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* ── Memory verse (placeholder) ── */}
      <div className="bg-gradient-to-br from-amber-50 to-amber-100 rounded-3xl border border-amber-200 px-6 py-5">
        <p className="text-amber-600 text-xs font-extrabold uppercase tracking-widest mb-2">This Week's Memory Verse</p>
        <p className="text-amber-900 font-extrabold text-lg leading-snug font-child">
          "Your word is a lamp for my feet, a light on my path."
        </p>
        <p className="text-amber-500 text-sm font-bold mt-1">— Psalm 119:105</p>
      </div>

    </div>
  );
}
