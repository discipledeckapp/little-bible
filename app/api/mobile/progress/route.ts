import { auth } from '@/auth';
import { parseMobileSyncEntry } from '@/lib/mobile-privacy';
import { prisma } from '@/lib/prisma';
import { NextRequest, NextResponse } from 'next/server';

/** Extract the Bearer token from an Authorization header, or return null. */
function extractBearer(req: NextRequest): string | null {
  const header = req.headers.get('authorization') ?? '';
  if (!header.startsWith('Bearer ')) return null;
  const token = header.slice(7).trim();
  // Minimal sanity: UUID v4 is 36 chars; reject obviously malformed tokens.
  return token.length >= 16 && token.length <= 128 ? token : null;
}

export async function POST(req: NextRequest) {
  // Two auth schemes:
  //   1. Session cookie — web users / future authenticated mobile
  //   2. Device token Bearer — current mobile app (no login flow)
  const session = await auth();
  const userId = session?.user?.id ?? null;
  const deviceId = userId ? null : extractBearer(req);

  if (!userId && !deviceId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Cloud-sync consent guard applies only to session-authenticated users.
  if (userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { cloudSyncEnabled: true },
    });
    if (!user?.cloudSyncEnabled) {
      return NextResponse.json({ error: 'Cloud sync consent is not enabled' }, { status: 403 });
    }
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
    if (userId) {
      await prisma.mobileProgress.upsert({
        where: { userId_clientId: { userId, clientId: entry.clientId } },
        create: {
          userId,
          clientId: entry.clientId,
          profileId: entry.profileId,
          operation: entry.operation,
          payload: JSON.stringify(entry.payload),
          createdAt: new Date(entry.createdAt),
        },
        update: {},
      });
    } else {
      await prisma.mobileProgress.upsert({
        where: { deviceId_clientId: { deviceId: deviceId!, clientId: entry.clientId } },
        create: {
          deviceId: deviceId!,
          clientId: entry.clientId,
          profileId: entry.profileId,
          operation: entry.operation,
          payload: JSON.stringify(entry.payload),
          createdAt: new Date(entry.createdAt),
        },
        update: {},
      });
    }
    accepted.push(entry.clientId);
  }
  return NextResponse.json({ accepted });
}
