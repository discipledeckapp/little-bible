import Link from 'next/link';
import HeaderModeChip from './HeaderModeChip';
import UserAvatar from '@/components/auth/UserAvatar';
import SignInButton from '@/components/auth/SignInButton';
import MemberSelectorClient from './MemberSelectorServer';

export default function Header() {
  return (
    <header className="bg-white/95 border-b border-amber-100/80 sticky top-0 z-20 backdrop-blur-sm">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 py-3.5 flex items-center justify-between gap-4">

        {/* Logo */}
        <Link
          href="/"
          className="flex items-center gap-2.5 group flex-shrink-0"
          aria-label="Little Bible — Home"
        >
          <div className="w-9 h-9 bg-amber-100 rounded-xl flex items-center justify-center text-xl group-hover:bg-amber-200 transition-colors select-none">
            📖
          </div>
          <div>
            <p className="font-bold text-amber-900 text-base leading-tight">Little Bible</p>
            <p className="text-amber-500 text-xs leading-tight hidden sm:block font-medium">
              Children&apos;s Bible · Ages 4–7
            </p>
          </div>
        </Link>

        {/* Right side */}
        <div className="flex items-center gap-2.5">
          <HeaderModeChip />

          {/* Active child selector — only visible when family has members */}
          <MemberSelectorClient />

          <Link
            href="/stories"
            className="hidden sm:inline-flex items-center gap-1.5 text-stone-600 hover:text-stone-800 font-semibold text-sm px-3 py-2 rounded-xl hover:bg-stone-50 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-stone-300"
          >
            ✨ Stories
          </Link>

          <Link
            href="/donate"
            className="hidden md:inline-flex items-center gap-1.5 text-amber-600 hover:text-amber-800 font-semibold text-sm px-3 py-2 rounded-xl hover:bg-amber-50 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
          >
            ❤️ Support
          </Link>

          <Link
            href="/family"
            className="hidden sm:inline-flex items-center gap-1.5 text-stone-600 hover:text-stone-800 font-semibold text-sm px-2.5 py-2 rounded-xl hover:bg-stone-50 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-stone-300"
            aria-label="Your Family"
            title="Your Family"
          >
            👨‍👩‍👧
          </Link>

          <Link
            href="/genesis/1"
            className="hidden sm:inline-flex items-center gap-1.5 bg-amber-500 hover:bg-amber-600 text-white font-bold text-sm px-4 py-2.5 rounded-xl transition-all active:scale-95 shadow-sm focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
          >
            <span aria-hidden="true">📖</span>
            Read
          </Link>

          {/* Auth */}
          <UserAvatar />
          <SignInButton variant="compact" />
        </div>

      </div>
    </header>
  );
}
