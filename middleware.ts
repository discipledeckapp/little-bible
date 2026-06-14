import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// Edge-compatible middleware — no Prisma/Node.js imports allowed here.
// Role check is handled in app/admin/layout.tsx (Node.js runtime).
export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  if (pathname.startsWith('/admin') || pathname.startsWith('/api/admin')) {
    const hasSession =
      req.cookies.has('authjs.session-token') ||
      req.cookies.has('__Secure-authjs.session-token');

    if (!hasSession) {
      const url = req.nextUrl.clone();
      url.pathname = '/';
      url.searchParams.set('callbackUrl', pathname);
      return NextResponse.redirect(url);
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/admin/:path*', '/api/admin/:path*'],
};
