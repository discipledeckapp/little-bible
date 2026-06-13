import { NextResponse } from 'next/server';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';

// GET /api/family/dashboard
export async function GET() {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const family = await prisma.family.findUnique({
    where: { ownerId: session.user.id },
    include: {
      members: {
        include: {
          progress: true,
          sessions: { orderBy: { readAt: 'desc' }, take: 5 },
        },
        orderBy: { sortOrder: 'asc' },
      },
      streak: true,
      milestones: { orderBy: { achievedAt: 'desc' }, take: 10 },
    },
  });

  if (!family) return NextResponse.json(null, { status: 200 });

  const totalSeeds = family.members.reduce((sum, m) => sum + m.seeds, 0);

  // Build recent activity across all members
  type RawActivity = {
    type: string;
    memberId: string;
    memberName: string;
    memberAvatarId: string;
    description: string;
    bookSlug?: string;
    chapter?: number;
    occurredAt: string;
  };

  const recentActivity: RawActivity[] = [];

  for (const member of family.members) {
    for (const session of member.sessions) {
      recentActivity.push({
        type: 'session',
        memberId: member.id,
        memberName: member.name,
        memberAvatarId: member.avatarId,
        description: `${member.name} read ${capitalise(session.bookSlug)} ${session.chapter}`,
        bookSlug: session.bookSlug,
        chapter: session.chapter,
        occurredAt: session.readAt.toISOString(),
      });
    }
  }

  for (const milestone of family.milestones) {
    const member = milestone.memberId
      ? family.members.find((m) => m.id === milestone.memberId)
      : null;

    recentActivity.push({
      type: 'milestone',
      memberId: milestone.memberId ?? '',
      memberName: member?.name ?? 'Family',
      memberAvatarId: member?.avatarId ?? 'star',
      description: milestoneCopy(milestone.type, member?.name ?? 'Family'),
      occurredAt: milestone.achievedAt.toISOString(),
    });
  }

  recentActivity.sort((a, b) => new Date(b.occurredAt).getTime() - new Date(a.occurredAt).getTime());

  return NextResponse.json({
    family: {
      id: family.id,
      name: family.name,
      journeyId: family.journeyId,
      createdAt: family.createdAt.toISOString(),
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
    },
    totalSeeds,
    recentActivity: recentActivity.slice(0, 20),
  });
}

function capitalise(s: string) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

function milestoneCopy(type: string, memberName: string) {
  const copies: Record<string, string> = {
    first_chapter: `${memberName} completed their first chapter`,
    first_book: `${memberName} finished their first book`,
    '7_day_streak': 'Family read together for 7 days',
    '30_day_streak': 'Family read together for 30 days',
    '100_seeds': 'Family reached 100 Wisdom Seeds',
    '500_seeds': 'Family reached 500 Wisdom Seeds',
  };
  return copies[type] ?? `${memberName} reached a milestone`;
}
