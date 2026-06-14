import { NextResponse } from 'next/server';
import { auth } from '@/auth';
import { isAdmin, can, type AdminModule } from './permissions';
import type { AdminRole } from '@prisma/client';

interface AdminAuthResult {
  session: { user: { id: string; role: AdminRole } };
  error?: never;
}
interface AdminAuthError {
  session?: never;
  error: NextResponse;
}

export async function requireAdminApi(
  module?: AdminModule
): Promise<AdminAuthResult | AdminAuthError> {
  const session = await auth();

  if (!session?.user?.id) {
    return { error: NextResponse.json({ error: 'Unauthorized' }, { status: 401 }) };
  }

  if (!isAdmin(session.user.role)) {
    return { error: NextResponse.json({ error: 'Forbidden' }, { status: 403 }) };
  }

  if (module && !can(session.user.role, module)) {
    return { error: NextResponse.json({ error: 'Forbidden' }, { status: 403 }) };
  }

  return { session: session as AdminAuthResult['session'] };
}
