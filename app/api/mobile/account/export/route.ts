import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';
import { NextResponse } from 'next/server';

export async function GET() {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
    select: {
      id: true, name: true, email: true, createdAt: true, wantsEmailDigest: true,
      wantsNotifications: true, cloudSyncEnabled: true, consentedAt: true,
      family: { include: { members: { include: { progress: true, sessions: true } }, streak: true } },
      mobileProgress: true, mobileEntitlements: true,
    },
  });
  return new NextResponse(JSON.stringify({ exportedAt: new Date().toISOString(), user }, null, 2), {
    headers: { 'content-type': 'application/json', 'content-disposition': 'attachment; filename="little-bible-data.json"' },
  });
}
