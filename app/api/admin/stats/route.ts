import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { requireAdminApi } from '@/lib/admin/auth';

export async function GET() {
  const result = await requireAdminApi('dashboard');
  if (result.error) return result.error;

  const now = new Date();
  const dayAgo   = new Date(now.getTime() - 86_400_000);
  const weekAgo  = new Date(now.getTime() - 7  * 86_400_000);
  const monthAgo = new Date(now.getTime() - 30 * 86_400_000);

  const [
    totalUsers,
    newUsersToday,
    newUsersWeek,
    totalFamilies,
    totalMembers,
    totalSessions,
    sessionsToday,
    sessionsWeek,
    sessionsMonth,
    totalSeeds,
    totalDonations,
    recentSessions,
    topBooks,
  ] = await Promise.all([
    prisma.user.count(),
    prisma.user.count({ where: { createdAt: { gte: dayAgo } } }),
    prisma.user.count({ where: { createdAt: { gte: weekAgo } } }),
    prisma.family.count(),
    prisma.familyMember.count(),
    prisma.memberSession.count(),
    prisma.memberSession.count({ where: { readAt: { gte: dayAgo } } }),
    prisma.memberSession.count({ where: { readAt: { gte: weekAgo } } }),
    prisma.memberSession.count({ where: { readAt: { gte: monthAgo } } }),
    prisma.familyMember.aggregate({ _sum: { seeds: true } }),
    prisma.donation.aggregate({
      where: { status: 'completed' },
      _sum: { amount: true },
      _count: true,
    }),
    // Daily session counts for last 30 days
    prisma.memberSession.groupBy({
      by: ['readAt'],
      _count: { id: true },
      where: { readAt: { gte: monthAgo } },
      orderBy: { readAt: 'asc' },
    }),
    // Top books by session count
    prisma.memberSession.groupBy({
      by: ['bookSlug'],
      _count: { id: true },
      orderBy: { _count: { id: 'desc' } },
      take: 10,
    }),
  ]);

  // Modes breakdown
  const modes = await prisma.memberSession.groupBy({
    by: ['mode'],
    _count: { id: true },
    orderBy: { _count: { id: 'desc' } },
  });

  // DAU — unique members with sessions in last 24h
  const dauMembers = await prisma.memberSession.findMany({
    where: { readAt: { gte: dayAgo } },
    select: { memberId: true },
    distinct: ['memberId'],
  });

  // Bucket daily sessions into date strings for the sparkline
  const sessionsByDay: Record<string, number> = {};
  for (let d = 0; d < 30; d++) {
    const day = new Date(now.getTime() - d * 86_400_000);
    sessionsByDay[day.toISOString().slice(0, 10)] = 0;
  }
  for (const row of recentSessions) {
    const key = new Date(row.readAt).toISOString().slice(0, 10);
    if (key in sessionsByDay) sessionsByDay[key] = (sessionsByDay[key] ?? 0) + row._count.id;
  }

  return NextResponse.json({
    users: {
      total: totalUsers,
      newToday: newUsersToday,
      newThisWeek: newUsersWeek,
    },
    families: { total: totalFamilies },
    members:  { total: totalMembers },
    sessions: {
      total: totalSessions,
      today: sessionsToday,
      thisWeek: sessionsWeek,
      thisMonth: sessionsMonth,
      dau: dauMembers.length,
    },
    seeds:  { total: totalSeeds._sum.seeds ?? 0 },
    donations: {
      total: totalDonations._count,
      amountUsd: Math.round((totalDonations._sum.amount ?? 0) / 100),
    },
    charts: {
      sessionsByDay: Object.entries(sessionsByDay)
        .map(([date, count]) => ({ date, count }))
        .reverse(),
      topBooks: topBooks.map(b => ({ slug: b.bookSlug, sessions: b._count.id })),
      modes: modes.map(m => ({ mode: m.mode, count: m._count.id })),
    },
  });
}
