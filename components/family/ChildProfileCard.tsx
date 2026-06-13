'use client';

import Link from 'next/link';
import type { FamilyMember } from '@/types/family';
import { AVATARS } from '@/types/family';
import { useFamily } from './FamilyContext';

interface ChildProfileCardProps {
  member: FamilyMember;
  onSelect?: () => void;
}

function timeAgo(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime();
  const days = Math.floor(diff / 86_400_000);
  if (days === 0) return 'today';
  if (days === 1) return 'yesterday';
  if (days < 7) return `${days} days ago`;
  return `${Math.floor(days / 7)}w ago`;
}

function BIBLE_BOOK_NAME(slug: string): string {
  const names: Record<string, string> = {
    genesis: 'Genesis', psalms: 'Psalms', proverbs: 'Proverbs',
    matthew: 'Matthew', mark: 'Mark', luke: 'Luke', john: 'John',
    exodus: 'Exodus', acts: 'Acts', romans: 'Romans',
  };
  return names[slug] ?? slug.charAt(0).toUpperCase() + slug.slice(1);
}

export default function ChildProfileCard({ member, onSelect }: ChildProfileCardProps) {
  const { activeMemberId, setActiveMemberId } = useFamily();
  const avatar  = AVATARS[member.avatarId] ?? AVATARS['lion'];
  const isActive = activeMemberId === member.id;
  const lastRead = member.lastReadAt ? timeAgo(member.lastReadAt) : null;
  const currentChapter = member.lastReadBook
    ? `${BIBLE_BOOK_NAME(member.lastReadBook)} ${member.lastReadChapter}`
    : null;

  const readingLink = member.lastReadBook && member.lastReadChapter
    ? `/${member.lastReadBook}/${member.lastReadChapter}`
    : '/genesis/1';

  function handleSelect() {
    setActiveMemberId(member.id);
    onSelect?.();
  }

  return (
    <div
      className={`relative bg-white rounded-3xl border-2 shadow-sm overflow-hidden transition-all ${
        isActive ? 'border-amber-400 shadow-amber-100 shadow-lg' : 'border-stone-100 hover:border-amber-200'
      }`}
    >
      {/* Active indicator */}
      {isActive && (
        <div className="absolute top-3 right-3 bg-amber-500 text-white text-[10px] font-extrabold px-2 py-0.5 rounded-full">
          Reading
        </div>
      )}

      <div className="p-5">
        {/* Avatar + Name */}
        <div className="flex items-start gap-3 mb-4">
          <div className={`w-14 h-14 rounded-2xl ${avatar.bg} flex items-center justify-center text-3xl shrink-0`}>
            {avatar.emoji}
          </div>
          <div className="min-w-0">
            <h3 className="font-extrabold text-stone-800 text-lg leading-tight">{member.name}</h3>
            {member.age && (
              <p className="text-stone-400 text-xs font-semibold mt-0.5">Age {member.age}</p>
            )}
          </div>
        </div>

        {/* Current chapter */}
        <div className="bg-stone-50 rounded-2xl px-3 py-2.5 mb-4 border border-stone-100">
          {currentChapter ? (
            <>
              <p className="text-stone-400 text-[10px] font-bold uppercase tracking-widest mb-0.5">Currently reading</p>
              <p className="font-bold text-stone-700 text-sm">{currentChapter}</p>
              {lastRead && (
                <p className={`text-xs mt-0.5 font-medium ${lastRead === 'today' ? 'text-emerald-500' : lastRead === 'yesterday' ? 'text-amber-500' : 'text-stone-400'}`}>
                  {lastRead}
                </p>
              )}
            </>
          ) : (
            <>
              <p className="text-stone-400 text-[10px] font-bold uppercase tracking-widest mb-0.5">Ready to start</p>
              <p className="font-bold text-stone-700 text-sm">Genesis 1</p>
            </>
          )}
        </div>

        {/* Seeds */}
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-1.5">
            <span className="text-base" aria-hidden="true">🌱</span>
            <span className="font-extrabold text-amber-700 text-sm">{member.seeds}</span>
            <span className="text-amber-400 text-xs font-semibold">seeds</span>
          </div>
          <p className="text-stone-300 text-xs">
            {member.completedChapters?.length ?? 0} chapters done
          </p>
        </div>

        {/* Actions */}
        <div className="flex gap-2">
          <button
            onClick={handleSelect}
            className={`flex-1 py-2.5 rounded-2xl text-sm font-extrabold transition-all active:scale-95 ${
              isActive
                ? 'bg-amber-100 text-amber-700 border border-amber-200'
                : 'bg-stone-100 text-stone-600 hover:bg-amber-50 hover:text-amber-700 border border-stone-200'
            }`}
          >
            {isActive ? '✓ Selected' : 'Select'}
          </button>
          <Link
            href={readingLink}
            onClick={handleSelect}
            className="flex-1 flex items-center justify-center gap-1.5 py-2.5 rounded-2xl text-sm font-extrabold bg-amber-500 text-white hover:bg-amber-600 transition-all active:scale-95 shadow-sm"
          >
            Read →
          </Link>
        </div>
      </div>
    </div>
  );
}
