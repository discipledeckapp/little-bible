import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';

const VALID_TYPES = ['memory-builder', 'story-sequence', 'character-match', 'application'] as const;

export async function POST(req: NextRequest) {
  const body = await req.json() as {
    storyId?: string;
    activityType?: string;
    score?: number;
    perfect?: boolean;
    seedsEarned?: number;
    memberId?: string;
  };

  const { storyId, activityType, score, perfect, seedsEarned, memberId } = body;

  if (!storyId || !activityType || !VALID_TYPES.includes(activityType as typeof VALID_TYPES[number])) {
    return NextResponse.json({ error: 'Missing or invalid fields' }, { status: 400 });
  }

  const session = await auth();

  if (session?.user?.id) {
    await prisma.activityRecord.create({
      data: {
        userId:       session.user.id,
        memberId:     memberId ?? null,
        storyId,
        activityType,
        score:        score       ?? 0,
        perfect:      perfect     ?? false,
        seedsEarned:  seedsEarned ?? 0,
      },
    });
  }

  return NextResponse.json({ success: true });
}
