'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import type { AdminRole } from '@prisma/client';
import { can, ROLE_LABELS, ROLE_COLORS, type AdminModule } from '@/lib/admin/permissions';
import LogoMark from '@/components/brand/LogoMark';

interface NavItem {
  href:   string;
  label:  string;
  icon:   string;
  module: AdminModule;
}

const NAV: NavItem[] = [
  { href: '/admin/dashboard',     label: 'Dashboard',     icon: '◈',  module: 'dashboard'     },
  { href: '/admin/analytics',     label: 'Analytics',     icon: '↗',  module: 'analytics'     },
  { href: '/admin/users',         label: 'Users',         icon: '◉',  module: 'users'         },
  { href: '/admin/families',      label: 'Families',      icon: '⬡',  module: 'families'      },
  { href: '/admin/content',       label: 'Content',       icon: '≡',  module: 'content'       },
  { href: '/admin/reviews',       label: 'Reviews',       icon: '✓',  module: 'reviews'       },
  { href: '/admin/feedback',      label: 'Feedback',      icon: '◷',  module: 'feedback'      },
  { href: '/admin/settings',      label: 'Settings',      icon: '⚙',  module: 'settings'      },
];

interface AdminSidebarProps {
  role:   AdminRole;
  name:   string | null;
  email:  string | null;
  image:  string | null;
}

export default function AdminSidebar({ role, name, email, image }: AdminSidebarProps) {
  const pathname = usePathname();

  const visibleNav = NAV.filter(item => can(role, item.module));

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
        {visibleNav.map(item => {
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

      {/* Back to app link */}
      <div className="px-3 pb-3">
        <Link
          href="/"
          className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-semibold text-stone-500 hover:text-stone-300 hover:bg-stone-800 transition-colors"
        >
          <span className="text-base w-5 text-center shrink-0 font-mono" aria-hidden="true">←</span>
          Back to App
        </Link>
      </div>

      {/* User info */}
      <div className="px-4 py-4 border-t border-stone-800">
        <div className="flex items-center gap-3">
          {image ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={image} alt={name ?? ''} className="w-8 h-8 rounded-full shrink-0" />
          ) : (
            <div className="w-8 h-8 rounded-full bg-stone-700 flex items-center justify-center text-stone-300 text-sm font-bold shrink-0">
              {(name ?? 'A')[0].toUpperCase()}
            </div>
          )}
          <div className="min-w-0 flex-1">
            <p className="text-white text-xs font-semibold truncate leading-tight">{name ?? 'Admin'}</p>
            <span className={`inline-block text-[9px] font-bold px-1.5 py-0.5 rounded-full leading-tight mt-0.5 ${ROLE_COLORS[role]}`}>
              {ROLE_LABELS[role]}
            </span>
          </div>
        </div>
      </div>
    </aside>
  );
}
