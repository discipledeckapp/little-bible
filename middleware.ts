import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { ADMIN_COOKIE } from '@/lib/admin/session';

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  if (pathname.startsWith('/admin') || pathname.startsWith('/api/admin')) {
    // Login page and logout action are always accessible
    if (pathname === '/admin/login') return NextResponse.next();

    const adminSession = req.cookies.get(ADMIN_COOKIE)?.value;
    if (!adminSession) {
      const url = req.nextUrl.clone();
      url.pathname = '/admin/login';
      url.searchParams.delete('error');
      return NextResponse.redirect(url);
    }
    // Full JWT verification runs in Node.js runtime (admin layout)
    return NextResponse.next();
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/admin/:path*', '/api/admin/:path*'],
};
