import { auth } from '@/auth';
import { NextResponse } from 'next/server';
import { isAdmin } from '@/lib/admin/permissions';

export default auth((req) => {
  const { nextUrl, auth: session } = req;

  if (nextUrl.pathname.startsWith('/admin')) {
    if (!session?.user?.id || !isAdmin(session.user.role)) {
      const url = nextUrl.clone();
      url.pathname = '/';
      url.searchParams.set('callbackUrl', nextUrl.pathname);
      return NextResponse.redirect(url);
    }
  }

  return NextResponse.next();
});

export const config = {
  matcher: ['/admin/:path*', '/api/admin/:path*'],
};
