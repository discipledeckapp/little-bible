import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';
import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const body = await req.json().catch(() => null) as { enabled?: unknown } | null;
  if (typeof body?.enabled !== 'boolean') return NextResponse.json({ error: 'enabled must be boolean' }, { status: 400 });
  if (!body.enabled) {
    await prisma.$transaction([
      prisma.mobileProgress.deleteMany({ where: { userId: session.user.id } }),
      prisma.user.update({ where: { id: session.user.id }, data: { cloudSyncEnabled: false, consentedAt: null } }),
    ]);
  } else {
    await prisma.user.update({
      where: { id: session.user.id },
      data: { cloudSyncEnabled: true, consentedAt: new Date() },
    });
  }
  return NextResponse.json({ cloudSyncEnabled: body.enabled });
}
