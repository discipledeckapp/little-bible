'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import HeaderModeChip from './HeaderModeChip';
import UserAvatar from '@/components/auth/UserAvatar';
import SignInButton from '@/components/auth/SignInButton';
import MemberSelectorClient from './MemberSelectorServer';
import LogoMark from '@/components/brand/LogoMark';
import BibleSelector from './BibleSelector';

const CENTER_NAV = [
  { href: '/stories',  label: 'Stories',  icon: '✨' },
  { href: '/journeys', label: 'Journeys', icon: '🌿' },
  { href: '/topics',   label: 'Topics',   icon: '🏷' },
] as const;

export default function Header() {
  const [bibleOpen, setBibleOpen] = useState(false);
  const pathname = usePathname();

  // Read tab is active on any Bible path (book / chapter pages)
  const isBibleActive =
    pathname !== '/' &&
    !pathname.startsWith('/stories') &&
    !pathname.startsWith('/topics') &&
    !pathname.startsWith('/journeys') &&
    !pathname.startsWith('/family') &&
    !pathname.startsWith('/admin') &&
    !pathname.startsWith('/settings') &&
    !pathname.startsWith('/donate') &&
    !pathname.startsWith('/download') &&
    !pathname.startsWith('/api');

  return (
    <header className="bg-white/95 border-b border-amber-100/80 sticky top-0 z-20 backdrop-blur-sm">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 py-3 flex items-center gap-3">

        {/* Logo */}
        <Link
          href="/"
          className="flex items-center gap-2.5 group flex-shrink-0"
          aria-label="Little Bible — Home"
        >
          <LogoMark size={34} className="group-hover:opacity-90 transition-opacity" />
          <div>
            <p className="font-bold text-amber-900 text-sm leading-tight">Little Bible</p>
            <p className="text-amber-500 text-[11px] leading-tight hidden sm:block font-medium">
              Children&apos;s Bible · Ages 4–7
            </p>
          </div>
        </Link>

        {/* ── Center navigation — desktop only ── */}
        <nav
          className="hidden md:flex items-center gap-0.5 flex-1 justify-center"
          aria-label="Primary navigation"
        >
          {/* Read — opens the Bible selector */}
          <div className="relative">
            <button
              onClick={() => setBibleOpen(v => !v)}
              aria-expanded={bibleOpen}
              aria-haspopup="dialog"
              className={`inline-flex items-center gap-1.5 font-bold text-sm px-3.5 py-2 rounded-xl transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                bibleOpen || isBibleActive
                  ? 'bg-amber-500 text-white shadow-sm'
                  : 'text-amber-700 hover:bg-amber-50 border border-amber-200 hover:border-amber-300'
              }`}
            >
              <span aria-hidden="true">📖</span>
              Read
              <span
                className={`text-[10px] transition-transform duration-150 ${bibleOpen ? 'rotate-180' : ''}`}
                aria-hidden="true"
              >
                ▾
              </span>
            </button>

            <BibleSelector
              isOpen={bibleOpen}
              onClose={() => setBibleOpen(false)}
              mode="dropdown"
            />
          </div>

          {CENTER_NAV.map(({ href, label, icon }) => {
            const active = pathname.startsWith(href);
            return (
              <Link
                key={href}
                href={href}
                className={`inline-flex items-center gap-1.5 font-semibold text-sm px-3 py-2 rounded-xl transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-stone-300 ${
                  active
                    ? 'bg-stone-100 text-stone-800'
                    : 'text-stone-600 hover:text-stone-800 hover:bg-stone-50'
                }`}
              >
                <span aria-hidden="true">{icon}</span>
                {label}
              </Link>
            );
          })}
        </nav>

        {/* ── Right side ── */}
        <div className="flex items-center gap-1.5 ml-auto">
          <HeaderModeChip />
          <MemberSelectorClient />

          <Link
            href="/family"
            className="hidden sm:inline-flex items-center gap-1 text-stone-500 hover:text-stone-700 font-semibold text-sm px-2 py-2 rounded-xl hover:bg-stone-50 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-stone-300"
            aria-label="Family dashboard"
            title="Family"
          >
            👨‍👩‍👧
          </Link>

          <UserAvatar />
          <SignInButton variant="compact" />
        </div>

      </div>
    </header>
  );
}
