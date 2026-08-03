import { auth } from '@/auth';
import { permanentlyDeleteUser } from '@/lib/account-deletion';
import { NextRequest, NextResponse } from 'next/server';

export async function DELETE(req: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const body = await req.json().catch(() => null) as { confirmation?: unknown } | null;
  if (body?.confirmation !== 'DELETE') return NextResponse.json({ error: 'Type DELETE to confirm' }, { status: 400 });

  await permanentlyDeleteUser(session.user.id);
  return NextResponse.json({ deleted: true });
}
