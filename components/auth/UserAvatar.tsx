'use client';

import { useState, useRef, useEffect } from 'react';
import { useSession, signOut } from 'next-auth/react';
import Link from 'next/link';
import Image from 'next/image';

export default function UserAvatar() {
  const { data: session } = useSession();
  const [open, setOpen]   = useState(false);
  const ref               = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  if (!session?.user) return null;

  const user     = session.user;
  const initials = (user.name ?? user.email ?? 'U').slice(0, 2).toUpperCase();

  return (
    <div ref={ref} className="relative">
      <button
        onClick={() => setOpen((o) => !o)}
        className="flex items-center gap-2 rounded-xl p-1 hover:bg-amber-50 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
        aria-label="Account menu"
        aria-expanded={open}
      >
        {user.image ? (
          <Image
            src={user.image}
            alt={user.name ?? 'User avatar'}
            width={32}
            height={32}
            className="w-8 h-8 rounded-full object-cover border-2 border-amber-200"
          />
        ) : (
          <div className="w-8 h-8 rounded-full bg-amber-400 flex items-center justify-center text-amber-950 text-xs font-extrabold border-2 border-amber-200">
            {initials}
          </div>
        )}
        <span className="hidden sm:block text-stone-700 font-semibold text-sm max-w-[120px] truncate">
          {user.name?.split(' ')[0] ?? 'You'}
        </span>
        <span className="text-stone-400 text-xs" aria-hidden="true">{open ? '▲' : '▼'}</span>
      </button>

      {open && (
        <div className="absolute right-0 top-full mt-2 w-52 bg-white rounded-2xl border border-stone-200 shadow-xl py-2 z-50 text-sm">
          <div className="px-4 py-2.5 border-b border-stone-100">
            <p className="font-bold text-stone-800 truncate">{user.name}</p>
            <p className="text-stone-400 text-xs truncate">{user.email}</p>
          </div>

          <Link
            href="/settings"
            onClick={() => setOpen(false)}
            className="flex items-center gap-2.5 px-4 py-2.5 text-stone-600 hover:text-stone-800 hover:bg-stone-50 transition-colors"
          >
            <span aria-hidden="true">⚙️</span> Settings
          </Link>

          <button
            onClick={() => signOut({ callbackUrl: '/' })}
            className="w-full text-left flex items-center gap-2.5 px-4 py-2.5 text-stone-500 hover:text-stone-700 hover:bg-stone-50 transition-colors"
          >
            <span aria-hidden="true">👋</span> Sign out
          </button>
        </div>
      )}
    </div>
  );
}
