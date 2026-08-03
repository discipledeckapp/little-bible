import { auth } from '@/auth';
import { parseMobileSyncEntry } from '@/lib/mobile-privacy';
import { prisma } from '@/lib/prisma';
import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
    select: { cloudSyncEnabled: true },
  });
  if (!user?.cloudSyncEnabled) {
    return NextResponse.json({ error: 'Cloud sync consent is not enabled' }, { status: 403 });
  }

  const body = await req.json().catch(() => null) as { entries?: unknown[] } | null;
  if (!body?.entries || !Array.isArray(body.entries) || body.entries.length > 100) {
    return NextResponse.json({ error: 'entries must contain 1–100 items' }, { status: 400 });
  }
  const entries = body.entries.map(parseMobileSyncEntry);
  if (entries.some((entry) => entry === null)) {
    return NextResponse.json({ error: 'Invalid or non-minimised sync entry' }, { status: 400 });
  }

  const accepted: string[] = [];
  for (const entry of entries) {
    if (!entry || entry.operation === 'unlock') continue;
    await prisma.mobileProgress.upsert({
      where: { userId_clientId: { userId: session.user.id, clientId: entry.clientId } },
      create: {
        userId: session.user.id,
        clientId: entry.clientId,
        profileId: entry.profileId,
        operation: entry.operation,
        payload: JSON.stringify(entry.payload),
        createdAt: new Date(entry.createdAt),
      },
      update: {},
    });
    accepted.push(entry.clientId);
  }
  return NextResponse.json({ accepted });
}
