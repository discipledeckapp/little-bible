import type { Metadata } from 'next';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';
import { can } from '@/lib/admin/permissions';
import type { AdminRole } from '@prisma/client';

export const metadata: Metadata = { title: 'Dashboard' };

async function getStats() {
  const now = new Date();
  const dayAgo   = new Date(now.getTime() - 86_400_000);
  const weekAgo  = new Date(now.getTime() - 7  * 86_400_000);
  const monthAgo = new Date(now.getTime() - 30 * 86_400_000);

  const [
    totalUsers, newUsersToday, totalFamilies, totalMembers,
    totalSessions, sessionsToday, sessionsWeek, sessionsMonth,
    seedsResult, dauRaw, topBooks, modes, recentUsers,
  ] = await Promise.all([
    prisma.user.count(),
    prisma.user.count({ where: { createdAt: { gte: dayAgo } } }),
    prisma.family.count(),
    prisma.familyMember.count(),
    prisma.memberSession.count(),
    prisma.memberSession.count({ where: { readAt: { gte: dayAgo } } }),
    prisma.memberSession.count({ where: { readAt: { gte: weekAgo } } }),
    prisma.memberSession.count({ where: { readAt: { gte: monthAgo } } }),
    prisma.familyMember.aggregate({ _sum: { seeds: true } }),
    prisma.memberSession.findMany({
      where: { readAt: { gte: dayAgo } },
      select: { memberId: true },
      distinct: ['memberId'],
    }),
    prisma.memberSession.groupBy({
      by: ['bookSlug'],
      _count: { id: true },
      orderBy: { _count: { id: 'desc' } },
      take: 8,
    }),
    prisma.memberSession.groupBy({
      by: ['mode'],
      _count: { id: true },
      orderBy: { _count: { id: 'desc' } },
    }),
    prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      take: 6,
      select: { id: true, name: true, email: true, createdAt: true, role: true },
    }),
  ]);

  // 30-day sparkline
  const sessionsByDay: Record<string, number> = {};
  for (let d = 29; d >= 0; d--) {
    const day = new Date(now.getTime() - d * 86_400_000);
    sessionsByDay[day.toISOString().slice(0, 10)] = 0;
  }
  const rawDaily = await prisma.$queryRaw<{ day: string; cnt: number }[]>`
    SELECT DATE("readAt") as day, COUNT(*) as cnt
    FROM "MemberSession"
    WHERE "readAt" >= ${monthAgo}
    GROUP BY DATE("readAt")
  `;
  for (const r of rawDaily) {
    const key = new Date(r.day).toISOString().slice(0, 10);
    if (key in sessionsByDay) sessionsByDay[key] = Number(r.cnt);
  }

  return {
    totalUsers, newUsersToday, totalFamilies, totalMembers,
    totalSessions, sessionsToday, sessionsWeek, sessionsMonth,
    totalSeeds: seedsResult._sum.seeds ?? 0,
    dau: dauRaw.length,
    topBooks,
    modes,
    recentUsers,
    sparkline: Object.entries(sessionsByDay).map(([date, count]) => ({ date, count })),
  };
}

function StatCard({
  label, value, sub, color = 'stone',
}: {
  label: string; value: string | number; sub?: string; color?: 'amber' | 'stone' | 'emerald' | 'blue';
}) {
  const accent = {
    amber:   'text-amber-600',
    stone:   'text-stone-700',
    emerald: 'text-emerald-600',
    blue:    'text-blue-600',
  }[color];

  return (
    <div className="bg-white rounded-2xl border border-stone-200 px-5 py-4">
      <p className="text-stone-500 text-xs font-semibold uppercase tracking-widest mb-1">{label}</p>
      <p className={`text-3xl font-extrabold ${accent} leading-none`}>{value.toLocaleString()}</p>
      {sub && <p className="text-stone-400 text-xs mt-1">{sub}</p>}
    </div>
  );
}

function MiniSparkline({ data }: { data: { date: string; count: number }[] }) {
  const max = Math.max(...data.map(d => d.count), 1);
  const w = 100 / data.length;
  return (
    <div className="flex items-end gap-px h-12">
      {data.map(({ date, count }) => (
        <div
          key={date}
          title={`${date}: ${count} sessions`}
          className="bg-amber-400 rounded-t flex-1 min-w-0 transition-all hover:bg-amber-500"
          style={{ height: `${Math.max(4, (count / max) * 100)}%` }}
        />
      ))}
    </div>
  );
}

export default async function DashboardPage() {
  const [session, stats] = await Promise.all([auth(), getStats()]);
  const role = session?.user?.role as AdminRole;
  const showAnalytics = can(role, 'analytics');

  const totalModeSessions = stats.modes.reduce((s, m) => s + m._count.id, 0);

  return (
    <div className="p-8 max-w-6xl mx-auto w-full">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-stone-900">Dashboard</h1>
        <p className="text-stone-500 text-sm mt-1">
          Platform overview · Little Bible Admin
        </p>
      </div>

      {/* Primary stats */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4 mb-8">
        <StatCard label="Total Users"     value={stats.totalUsers}    sub={`+${stats.newUsersToday} today`} color="stone" />
        <StatCard label="Families"        value={stats.totalFamilies}  sub="active family accounts"          color="amber" />
        <StatCard label="Child Profiles"  value={stats.totalMembers}   sub="across all families"              color="amber" />
        <StatCard label="DAU"             value={stats.dau}            sub="active readers today"             color="emerald" />
        <StatCard label="Sessions Today"  value={stats.sessionsToday}  sub={`${stats.sessionsWeek} this week`} color="blue" />
        <StatCard label="Sessions / Month" value={stats.sessionsMonth} sub="last 30 days"                    color="stone" />
        <StatCard label="Total Sessions"  value={stats.totalSessions}  sub="all time"                        color="stone" />
        <StatCard label="Seeds Earned"    value={stats.totalSeeds}     sub="wisdom seeds across all families" color="amber" />
      </div>

      {showAnalytics && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          {/* Sparkline */}
          <div className="lg:col-span-2 bg-white rounded-2xl border border-stone-200 p-5">
            <div className="flex items-center justify-between mb-4">
              <div>
                <p className="text-sm font-bold text-stone-800">Reading Sessions</p>
                <p className="text-stone-400 text-xs">Last 30 days</p>
              </div>
              <p className="text-2xl font-extrabold text-stone-800">{stats.sessionsMonth.toLocaleString()}</p>
            </div>
            <MiniSparkline data={stats.sparkline} />
          </div>

          {/* Mode breakdown */}
          <div className="bg-white rounded-2xl border border-stone-200 p-5">
            <p className="text-sm font-bold text-stone-800 mb-4">Reading Modes</p>
            <div className="space-y-3">
              {stats.modes.map(m => {
                const pct = totalModeSessions > 0 ? Math.round((m._count.id / totalModeSessions) * 100) : 0;
                const color = m.mode === 'child' ? 'bg-amber-400' : m.mode === 'family' ? 'bg-emerald-400' : 'bg-stone-400';
                return (
                  <div key={m.mode}>
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs font-semibold text-stone-700 capitalize">{m.mode}</span>
                      <span className="text-xs text-stone-400">{pct}%</span>
                    </div>
                    <div className="h-1.5 bg-stone-100 rounded-full overflow-hidden">
                      <div className={`h-full ${color} rounded-full`} style={{ width: `${pct}%` }} />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top books */}
        <div className="bg-white rounded-2xl border border-stone-200 p-5">
          <p className="text-sm font-bold text-stone-800 mb-4">Most Read Books</p>
          <div className="space-y-2">
            {stats.topBooks.length === 0 ? (
              <p className="text-stone-400 text-sm">No sessions recorded yet</p>
            ) : stats.topBooks.map((b, i) => {
              const max = stats.topBooks[0]?._count.id ?? 1;
              const pct = Math.round((b._count.id / max) * 100);
              return (
                <div key={b.bookSlug} className="flex items-center gap-3">
                  <span className="text-xs text-stone-400 w-4 shrink-0 text-right font-mono">{i + 1}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between mb-0.5">
                      <span className="text-xs font-semibold text-stone-700 capitalize">{b.bookSlug}</span>
                      <span className="text-xs text-stone-400 shrink-0 ml-2">{b._count.id}</span>
                    </div>
                    <div className="h-1 bg-stone-100 rounded-full overflow-hidden">
                      <div className="h-full bg-amber-400 rounded-full" style={{ width: `${pct}%` }} />
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Recent signups */}
        <div className="bg-white rounded-2xl border border-stone-200 p-5">
          <div className="flex items-center justify-between mb-4">
            <p className="text-sm font-bold text-stone-800">Recent Users</p>
            <a href="/admin/users" className="text-xs text-amber-600 hover:text-amber-800 font-semibold">View all →</a>
          </div>
          <div className="space-y-3">
            {stats.recentUsers.map(u => (
              <div key={u.id} className="flex items-center gap-3">
                <div className="w-7 h-7 rounded-full bg-stone-100 flex items-center justify-center text-stone-500 text-xs font-bold shrink-0">
                  {(u.name ?? u.email ?? 'U')[0].toUpperCase()}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-xs font-semibold text-stone-800 truncate">{u.name ?? '—'}</p>
                  <p className="text-[11px] text-stone-400 truncate">{u.email}</p>
                </div>
                <p className="text-[11px] text-stone-400 shrink-0">
                  {new Date(u.createdAt).toLocaleDateString('en-GB', { day: 'numeric', month: 'short' })}
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
