'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import BibleSelector from './BibleSelector';

export default function MobileTabBar() {
  const [bibleOpen, setBibleOpen] = useState(false);
  const pathname = usePathname();

  // Active state for the Read tab — any path that isn't a known section
  const isBibleActive =
    pathname !== '/' &&
    !pathname.startsWith('/stories') &&
    !pathname.startsWith('/topics') &&
    !pathname.startsWith('/journeys') &&
    !pathname.startsWith('/family') &&
    !pathname.startsWith('/admin') &&
    !pathname.startsWith('/settings') &&
    !pathname.startsWith('/donate') &&
    !pathname.startsWith('/download');

  const isActive = (href: string) => pathname.startsWith(href);

  const linkClass = (active: boolean) =>
    `flex-1 flex flex-col items-center justify-center gap-0.5 text-[10px] font-bold transition-colors ${
      active ? 'text-amber-600' : 'text-stone-400 active:text-stone-600'
    }`;

  return (
    <>
      <BibleSelector
        isOpen={bibleOpen}
        onClose={() => setBibleOpen(false)}
        mode="sheet"
      />

      <nav
        className="md:hidden fixed bottom-0 inset-x-0 z-30 bg-white/96 backdrop-blur-sm border-t border-stone-200"
        style={{ paddingBottom: 'env(safe-area-inset-bottom, 0px)' }}
        aria-label="Mobile navigation"
      >
        <div className="flex items-stretch h-16">

          {/* Read — opens Bible selector */}
          <button
            onClick={() => setBibleOpen(true)}
            className={linkClass(isBibleActive)}
            aria-label="Open the Bible"
          >
            <span className="text-[22px] leading-none">📖</span>
            <span>Read</span>
          </button>

          <Link href="/stories" className={linkClass(isActive('/stories'))}>
            <span className="text-[22px] leading-none">✨</span>
            <span>Stories</span>
          </Link>

          <Link href="/journeys" className={linkClass(isActive('/journeys'))}>
            <span className="text-[22px] leading-none">🌿</span>
            <span>Journeys</span>
          </Link>

          <Link href="/topics" className={linkClass(isActive('/topics'))}>
            <span className="text-[22px] leading-none">🏷</span>
            <span>Topics</span>
          </Link>

          <Link href="/family" className={linkClass(isActive('/family'))}>
            <span className="text-[22px] leading-none">👤</span>
            <span>Me</span>
          </Link>

        </div>
      </nav>
    </>
  );
}
