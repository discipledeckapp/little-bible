import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';
import type { Family, FamilyMember, FamilyStreak, MemberProgress } from '@prisma/client';

type FamilyWithAll = Family & {
  members: (FamilyMember & { progress: MemberProgress | null })[];
  streak: FamilyStreak | null;
};

// GET /api/family — fetch current user's family
export async function GET() {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const family = await prisma.family.findUnique({
    where: { ownerId: session.user.id },
    include: {
      members: {
        include: { progress: true },
        orderBy: { sortOrder: 'asc' },
      },
      streak: true,
    },
  });

  if (!family) return NextResponse.json(null, { status: 200 });

  return NextResponse.json(shapeFamilyResponse(family));
}

// POST /api/family — create family
export async function POST(req: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const body = await req.json().catch(() => ({}));
  const name: string | null = body.name?.trim() || null;

  const existing = await prisma.family.findUnique({ where: { ownerId: session.user.id } });
  if (existing) return NextResponse.json({ error: 'Family already exists' }, { status: 409 });

  const family = await prisma.family.create({
    data: {
      ownerId: session.user.id,
      name,
    },
    include: {
      members: { include: { progress: true } },
      streak: true,
    },
  });

  return NextResponse.json(shapeFamilyResponse(family), { status: 201 });
}

// PATCH /api/family — update family name / journeyId
export async function PATCH(req: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const body = await req.json().catch(() => ({}));
  const data: { name?: string | null; journeyId?: string | null } = {};
  if ('name' in body) data.name = body.name?.trim() || null;
  if ('journeyId' in body) data.journeyId = body.journeyId || null;

  const family = await prisma.family.update({
    where: { ownerId: session.user.id },
    data,
    include: {
      members: { include: { progress: true }, orderBy: { sortOrder: 'asc' } },
      streak: true,
    },
  });

  return NextResponse.json(shapeFamilyResponse(family));
}

function shapeFamilyResponse(family: FamilyWithAll) {
  return {
    id: family.id,
    name: family.name,
    journeyId: family.journeyId,
    createdAt: family.createdAt,
    members: family.members.map((m) => ({
      id: m.id,
      name: m.name,
      age: m.age,
      avatarId: m.avatarId,
      accentColor: m.accentColor,
      faithGoals: m.faithGoals,
      seeds: m.seeds,
      sortOrder: m.sortOrder,
      lastReadBook: m.progress?.lastReadBook ?? null,
      lastReadChapter: m.progress?.lastReadChapter ?? null,
      lastReadAt: m.progress?.lastReadAt?.toISOString() ?? null,
      completedChapters: m.progress?.completedChapters ?? [],
    })),
    streak: family.streak
      ? {
          currentStreak: family.streak.currentStreak,
          longestStreak: family.streak.longestStreak,
          lastReadDate: family.streak.lastReadDate,
        }
      : null,
  };
}
