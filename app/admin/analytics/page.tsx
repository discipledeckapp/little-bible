import type { Metadata } from 'next';
import { prisma } from '@/lib/prisma';
import { BIBLE_BOOKS } from '@/lib/bibleBooks';

export const metadata: Metadata = { title: 'Analytics' };

async function getAnalytics() {
  const now      = new Date();
  const monthAgo = new Date(now.getTime() - 30 * 86_400_000);
  const yearAgo  = new Date(now.getTime() - 365 * 86_400_000);

  const [rawDaily, rawMonthly, topBooks, topChapters, modesAll, signupsMonthly] = await Promise.all([
    // Daily sessions — last 30 days
    prisma.$queryRaw<{ day: string; cnt: number }[]>`
      SELECT DATE("readAt") as day, COUNT(*) as cnt
      FROM "MemberSession"
      WHERE "readAt" >= ${monthAgo}
      GROUP BY DATE("readAt")
      ORDER BY day ASC
    `,
    // Monthly sessions — last 12 months
    prisma.$queryRaw<{ month: string; cnt: number }[]>`
      SELECT TO_CHAR(DATE_TRUNC('month', "readAt"), 'YYYY-MM') as month, COUNT(*) as cnt
      FROM "MemberSession"
      WHERE "readAt" >= ${yearAgo}
      GROUP BY month
      ORDER BY month ASC
    `,
    // Top 15 books
    prisma.memberSession.groupBy({
      by: ['bookSlug'],
      _count: { id: true },
      orderBy: { _count: { id: 'desc' } },
      take: 15,
    }),
    // Top 10 chapters
    prisma.memberSession.groupBy({
      by: ['bookSlug', 'chapter'],
      _count: { id: true },
      orderBy: { _count: { id: 'desc' } },
      take: 10,
    }),
    // Modes — all time
    prisma.memberSession.groupBy({
      by: ['mode'],
      _count: { id: true },
    }),
    // User signups per month — last 12 months
    prisma.$queryRaw<{ month: string; cnt: number }[]>`
      SELECT TO_CHAR(DATE_TRUNC('month', "createdAt"), 'YYYY-MM') as month, COUNT(*) as cnt
      FROM "User"
      WHERE "createdAt" >= ${yearAgo}
      GROUP BY month
      ORDER BY month ASC
    `,
  ]);

  // Fill daily gaps
  const dailyMap: Record<string, number> = {};
  for (let d = 29; d >= 0; d--) {
    const key = new Date(now.getTime() - d * 86_400_000).toISOString().slice(0, 10);
    dailyMap[key] = 0;
  }
  for (const r of rawDaily) {
    const key = new Date(r.day).toISOString().slice(0, 10);
    if (key in dailyMap) dailyMap[key] = Number(r.cnt);
  }

  return {
    daily:  Object.entries(dailyMap).map(([date, count]) => ({ date, count })),
    monthly: rawMonthly.map(r => ({ month: r.month, count: Number(r.cnt) })),
    topBooks: topBooks.map(b => ({
      slug: b.bookSlug,
      name: BIBLE_BOOKS.find(bb => bb.slug === b.bookSlug)?.name ?? b.bookSlug,
      sessions: b._count.id,
    })),
    topChapters: topChapters.map(c => ({
      ref: `${c.bookSlug} ${c.chapter}`,
      sessions: c._count.id,
    })),
    modes: modesAll.map(m => ({ mode: m.mode, count: m._count.id })),
    signups: signupsMonthly.map(r => ({ month: r.month, count: Number(r.cnt) })),
  };
}

function BarChart({
  data, labelKey, valueKey, color = 'amber',
}: {
  data: Record<string, string | number>[];
  labelKey: string;
  valueKey: string;
  color?: 'amber' | 'emerald' | 'blue' | 'stone';
}) {
  const max = Math.max(...data.map(d => Number(d[valueKey])), 1);
  const barColor = {
    amber:   'bg-amber-400 hover:bg-amber-500',
    emerald: 'bg-emerald-400 hover:bg-emerald-500',
    blue:    'bg-blue-400 hover:bg-blue-500',
    stone:   'bg-stone-300 hover:bg-stone-400',
  }[color];

  return (
    <div className="flex items-end gap-1 h-32">
      {data.map((d, i) => {
        const val = Number(d[valueKey]);
        const pct = (val / max) * 100;
        const lbl = String(d[labelKey]);
        return (
          <div
            key={i}
            className="flex-1 flex flex-col items-center gap-0.5 min-w-0"
            title={`${lbl}: ${val}`}
          >
            <div
              className={`w-full ${barColor} rounded-t transition-all`}
              style={{ height: `${Math.max(2, pct)}%` }}
            />
          </div>
        );
      })}
    </div>
  );
}

export default async function AnalyticsPage() {
  const data = await getAnalytics();
  const totalSessions = data.modes.reduce((s, m) => s + m.count, 0);

  return (
    <div className="p-8 max-w-6xl mx-auto w-full">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-stone-900">Analytics</h1>
        <p className="text-stone-500 text-sm mt-0.5">Reading patterns and platform engagement</p>
      </div>

      {/* Daily sessions chart */}
      <div className="bg-white rounded-2xl border border-stone-200 p-6 mb-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <p className="font-bold text-stone-800">Daily Reading Sessions</p>
            <p className="text-stone-400 text-xs mt-0.5">Last 30 days</p>
          </div>
          <p className="text-2xl font-extrabold text-stone-800">
            {data.daily.reduce((s, d) => s + d.count, 0).toLocaleString()}
          </p>
        </div>
        <BarChart data={data.daily} labelKey="date" valueKey="count" color="amber" />
        <div className="flex items-center justify-between mt-2">
          <p className="text-[10px] text-stone-300">{data.daily[0]?.date}</p>
          <p className="text-[10px] text-stone-300">{data.daily[data.daily.length - 1]?.date}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        {/* Monthly sessions */}
        <div className="bg-white rounded-2xl border border-stone-200 p-6">
          <p className="font-bold text-stone-800 mb-1">Monthly Sessions</p>
          <p className="text-stone-400 text-xs mb-5">Last 12 months</p>
          <BarChart data={data.monthly} labelKey="month" valueKey="count" color="blue" />
        </div>

        {/* Monthly signups */}
        <div className="bg-white rounded-2xl border border-stone-200 p-6">
          <p className="font-bold text-stone-800 mb-1">Monthly Signups</p>
          <p className="text-stone-400 text-xs mb-5">New users per month</p>
          <BarChart data={data.signups} labelKey="month" valueKey="count" color="emerald" />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Top books */}
        <div className="lg:col-span-2 bg-white rounded-2xl border border-stone-200 p-6">
          <p className="font-bold text-stone-800 mb-5">Top Books by Sessions</p>
          <div className="space-y-3">
            {data.topBooks.map((b, i) => {
              const max = data.topBooks[0]?.sessions ?? 1;
              const pct = Math.round((b.sessions / max) * 100);
              return (
                <div key={b.slug} className="flex items-center gap-3">
                  <span className="text-xs text-stone-300 w-5 text-right font-mono shrink-0">{i + 1}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between mb-1">
                      <span className="text-xs font-semibold text-stone-700">{b.name}</span>
                      <span className="text-xs text-stone-400 shrink-0 ml-2">{b.sessions.toLocaleString()}</span>
                    </div>
                    <div className="h-1.5 bg-stone-100 rounded-full">
                      <div className="h-full bg-amber-400 rounded-full" style={{ width: `${pct}%` }} />
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Modes + Top chapters */}
        <div className="space-y-5">
          <div className="bg-white rounded-2xl border border-stone-200 p-5">
            <p className="font-bold text-stone-800 mb-4 text-sm">Mode Usage</p>
            <div className="space-y-3">
              {data.modes.map(m => {
                const pct = totalSessions > 0 ? Math.round((m.count / totalSessions) * 100) : 0;
                const color = m.mode === 'child' ? 'bg-amber-400' : m.mode === 'family' ? 'bg-emerald-400' : 'bg-stone-400';
                return (
                  <div key={m.mode}>
                    <div className="flex justify-between mb-1">
                      <span className="text-xs font-semibold text-stone-700 capitalize">{m.mode}</span>
                      <span className="text-xs text-stone-400">{pct}% · {m.count.toLocaleString()}</span>
                    </div>
                    <div className="h-1.5 bg-stone-100 rounded-full">
                      <div className={`h-full ${color} rounded-full`} style={{ width: `${pct}%` }} />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="bg-white rounded-2xl border border-stone-200 p-5">
            <p className="font-bold text-stone-800 mb-4 text-sm">Top Chapters</p>
            <div className="space-y-2">
              {data.topChapters.map((c, i) => (
                <div key={c.ref} className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="text-[10px] text-stone-300 font-mono w-4">{i + 1}</span>
                    <span className="text-xs font-semibold text-stone-700">{c.ref}</span>
                  </div>
                  <span className="text-xs text-stone-400">{c.sessions}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
