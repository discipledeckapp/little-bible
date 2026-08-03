import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';
import { NextRequest, NextResponse } from 'next/server';

export async function GET() {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const preferences = await prisma.user.findUnique({
    where: { id: session.user.id },
    select: { wantsEmailDigest: true, wantsNotifications: true, cloudSyncEnabled: true, consentedAt: true },
  });
  return NextResponse.json(preferences);
}

export async function PATCH(req: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const body = await req.json().catch(() => null) as Record<string, unknown> | null;
  if (!body) return NextResponse.json({ error: 'Invalid JSON' }, { status: 400 });
  const data: { wantsEmailDigest?: boolean; wantsNotifications?: boolean } = {};
  if (typeof body.wantsEmailDigest === 'boolean') data.wantsEmailDigest = body.wantsEmailDigest;
  if (typeof body.wantsNotifications === 'boolean') data.wantsNotifications = body.wantsNotifications;
  const updated = await prisma.user.update({ where: { id: session.user.id }, data, select: {
    wantsEmailDigest: true, wantsNotifications: true, cloudSyncEnabled: true, consentedAt: true,
  }});
  return NextResponse.json(updated);
}
