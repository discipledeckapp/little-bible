'use server';

import { redirect } from 'next/navigation';
import { cookies } from 'next/headers';
import { ADMIN_COOKIE } from '@/lib/admin/session';

export async function logoutAction() {
  const cookieStore = await cookies();
  cookieStore.delete(ADMIN_COOKIE);
  redirect('/admin/login');
}
