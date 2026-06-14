'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { logoutAction } from '@/app/admin/actions/logout';
import LogoMark from '@/components/brand/LogoMark';

interface NavItem {
  href:  string;
  label: string;
  icon:  string;
}

const NAV: NavItem[] = [
  { href: '/admin/dashboard', label: 'Dashboard', icon: '◈' },
  { href: '/admin/analytics', label: 'Analytics', icon: '↗' },
  { href: '/admin/users',     label: 'Users',     icon: '◉' },
  { href: '/admin/families',  label: 'Families',  icon: '⬡' },
  { href: '/admin/content',   label: 'Content',   icon: '≡' },
  { href: '/admin/reviews',   label: 'Reviews',   icon: '✓' },
  { href: '/admin/feedback',  label: 'Feedback',  icon: '◷' },
  { href: '/admin/settings',  label: 'Settings',  icon: '⚙' },
];

interface AdminSidebarProps {
  name:  string;
  email: string;
}

export default function AdminSidebar({ name, email }: AdminSidebarProps) {
  const pathname = usePathname();

  return (
    <aside className="flex flex-col w-60 min-h-screen bg-stone-900 border-r border-stone-800 shrink-0">
      {/* Logo */}
      <div className="px-5 py-5 border-b border-stone-800">
        <Link href="/admin/dashboard" className="flex items-center gap-3 group">
          <LogoMark size={32} />
          <div>
            <p className="text-white text-sm font-bold leading-tight">Little Bible</p>
            <p className="text-stone-500 text-[10px] font-semibold uppercase tracking-widest leading-tight">Admin</p>
          </div>
        </Link>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-4 space-y-0.5">
        {NAV.map(item => {
          const active = pathname === item.href || pathname.startsWith(item.href + '/');
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-semibold transition-colors ${
                active
                  ? 'bg-amber-500 text-white'
                  : 'text-stone-400 hover:text-white hover:bg-stone-800'
              }`}
            >
              <span className="text-base w-5 text-center shrink-0 font-mono leading-none" aria-hidden="true">
                {item.icon}
              </span>
              {item.label}
            </Link>
          );
        })}
      </nav>

      {/* Back to app */}
      <div className="px-3 pb-1">
        <Link
          href="/"
          className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-semibold text-stone-500 hover:text-stone-300 hover:bg-stone-800 transition-colors"
        >
          <span className="text-base w-5 text-center shrink-0 font-mono" aria-hidden="true">←</span>
          Back to App
        </Link>
      </div>

      {/* User info + logout */}
      <div className="px-4 py-4 border-t border-stone-800">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-8 h-8 rounded-full bg-amber-900 flex items-center justify-center text-amber-200 text-sm font-bold shrink-0">
            {(name ?? 'A')[0].toUpperCase()}
          </div>
          <div className="min-w-0 flex-1">
            <p className="text-white text-xs font-semibold truncate leading-tight capitalize">{name}</p>
            <p className="text-stone-500 text-[10px] truncate">{email}</p>
          </div>
        </div>
        <form action={logoutAction}>
          <button
            type="submit"
            className="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-xs font-semibold text-stone-500 hover:text-red-400 hover:bg-stone-800 transition-colors focus:outline-none"
          >
            <span aria-hidden="true">⏻</span>
            Sign out
          </button>
        </form>
      </div>
    </aside>
  );
}
