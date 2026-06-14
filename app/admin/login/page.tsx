import type { Metadata } from 'next';
import { redirect } from 'next/navigation';
import { cookies } from 'next/headers';
import {
  checkAdminCredentials,
  createAdminToken,
  verifyAdminToken,
  ADMIN_COOKIE,
  SESSION_MAX_AGE,
} from '@/lib/admin/session';

import LogoMark from '@/components/brand/LogoMark';

export const metadata: Metadata = {
  title: 'Admin Sign In — Little Bible',
  robots: { index: false, follow: false },
};

interface PageProps {
  searchParams: Promise<{ error?: string }>;
}

export default async function AdminLoginPage({ searchParams }: PageProps) {
  // If already logged in, go to dashboard
  const cookieStore = await cookies();
  const existingToken = cookieStore.get(ADMIN_COOKIE)?.value;
  if (existingToken && verifyAdminToken(existingToken)) {
    redirect('/admin/dashboard');
  }

  const { error } = await searchParams;

  async function loginAction(formData: FormData) {
    'use server';
    const email    = String(formData.get('email')    ?? '').trim().toLowerCase();
    const password = String(formData.get('password') ?? '');

    if (!checkAdminCredentials(email, password)) {
      redirect('/admin/login?error=invalid');
    }

    const token = createAdminToken();
    const cookieStore = await cookies();
    cookieStore.set(ADMIN_COOKIE, token, {
      httpOnly: true,
      secure:   process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge:   SESSION_MAX_AGE,
      path:     '/admin',
    });
    redirect('/admin/dashboard');
  }

  return (
    <div className="min-h-screen bg-stone-950 flex flex-col items-center justify-center px-4">
      <div className="w-full max-w-sm">

        {/* Logo */}
        <div className="flex items-center justify-center gap-3 mb-8">
          <LogoMark size={40} />
          <div>
            <p className="text-white font-bold text-lg leading-tight">Little Bible</p>
            <p className="text-stone-500 text-xs font-semibold uppercase tracking-widest">Admin</p>
          </div>
        </div>

        {/* Card */}
        <div className="bg-stone-900 border border-stone-800 rounded-2xl p-7">
          <h1 className="text-white font-bold text-lg mb-1">Sign in</h1>
          <p className="text-stone-500 text-sm mb-6">Admin access only</p>

          {error === 'invalid' && (
            <div className="bg-red-950 border border-red-800 rounded-xl px-4 py-3 mb-5">
              <p className="text-red-300 text-sm font-semibold">Incorrect email or password.</p>
            </div>
          )}

          <form action={loginAction} className="space-y-4">
            <div>
              <label htmlFor="email" className="block text-stone-400 text-xs font-bold uppercase tracking-widest mb-1.5">
                Email
              </label>
              <input
                id="email"
                name="email"
                type="email"
                required
                autoComplete="email"
                placeholder="admin@example.com"
                className="w-full bg-stone-800 border border-stone-700 rounded-xl px-4 py-3 text-white placeholder-stone-600 text-sm focus:outline-none focus:border-amber-500 transition-colors"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-stone-400 text-xs font-bold uppercase tracking-widest mb-1.5">
                Password
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
                autoComplete="current-password"
                placeholder="••••••••"
                className="w-full bg-stone-800 border border-stone-700 rounded-xl px-4 py-3 text-white placeholder-stone-600 text-sm focus:outline-none focus:border-amber-500 transition-colors"
              />
            </div>

            <button
              type="submit"
              className="w-full bg-amber-500 hover:bg-amber-400 text-white font-extrabold py-3.5 rounded-xl text-sm transition-colors mt-2"
            >
              Sign in to Admin
            </button>
          </form>
        </div>

        <p className="text-stone-700 text-xs text-center mt-6">
          This area is restricted to authorised administrators only.
        </p>
      </div>
    </div>
  );
}
