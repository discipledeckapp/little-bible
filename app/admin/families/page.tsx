import type { Metadata } from 'next';
import { prisma } from '@/lib/prisma';
import Link from 'next/link';

export const metadata: Metadata = { title: 'Families' };

interface PageProps {
  searchParams: Promise<{ q?: string; page?: string }>;
}

export default async function FamiliesPage({ searchParams }: PageProps) {
  const { q = '', page: pageStr = '1' } = await searchParams;
  const page     = Math.max(1, parseInt(pageStr, 10));
  const pageSize = 25;
  const search   = q.trim();

  const where = search
    ? {
        OR: [
          { name:  { contains: search, mode: 'insensitive' as const } },
          { owner: { email: { contains: search, mode: 'insensitive' as const } } },
          { owner: { name:  { contains: search, mode: 'insensitive' as const } } },
        ],
      }
    : {};

  const [total, families] = await Promise.all([
    prisma.family.count({ where }),
    prisma.family.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * pageSize,
      take: pageSize,
      select: {
        id: true, name: true, journeyId: true, createdAt: true,
        owner: { select: { name: true, email: true, image: true } },
        members: { select: { id: true, name: true, age: true, seeds: true, avatarId: true } },
        streak:  { select: { currentStreak: true, longestStreak: true, lastReadDate: true } },
      },
    }),
  ]);

  const pages = Math.ceil(total / pageSize);

  return (
    <div className="p-8 max-w-6xl mx-auto w-full">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-stone-900">Families</h1>
        <p className="text-stone-500 text-sm mt-0.5">{total.toLocaleString()} family accounts</p>
      </div>

      {/* Search */}
      <form className="mb-6">
        <div className="flex gap-2 max-w-md">
          <input
            name="q"
            defaultValue={q}
            placeholder="Search by family name or owner email…"
            className="flex-1 border border-stone-200 rounded-xl px-4 py-2.5 text-sm text-stone-800 placeholder-stone-400 focus:outline-none focus:ring-2 focus:ring-amber-400 bg-white"
          />
          <button type="submit" className="bg-amber-500 hover:bg-amber-600 text-white font-semibold text-sm px-4 py-2.5 rounded-xl transition-colors">
            Search
          </button>
          {q && <Link href="/admin/families" className="border border-stone-200 text-stone-600 font-semibold text-sm px-4 py-2.5 rounded-xl bg-white">Clear</Link>}
        </div>
      </form>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {families.length === 0 ? (
          <div className="col-span-full text-center py-12 text-stone-400">
            {search ? `No families matching "${search}"` : 'No families yet'}
          </div>
        ) : families.map(f => {
          const totalSeeds = f.members.reduce((s, m) => s + m.seeds, 0);
          const streakActive = f.streak?.lastReadDate
            ? new Date(f.streak.lastReadDate) > new Date(Date.now() - 48 * 3600_000)
            : false;

          return (
            <div key={f.id} className="bg-white rounded-2xl border border-stone-200 p-5">
              {/* Family header */}
              <div className="flex items-start justify-between mb-3">
                <div>
                  <p className="font-bold text-stone-800 text-sm">{f.name ?? 'Unnamed Family'}</p>
                  <p className="text-xs text-stone-400 mt-0.5">{f.owner.email}</p>
                </div>
                {streakActive && (
                  <span className="bg-amber-50 text-amber-700 text-[10px] font-bold px-2 py-1 rounded-full">
                    🔥 {f.streak?.currentStreak}d
                  </span>
                )}
              </div>

              {/* Children */}
              <div className="mb-3">
                <p className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-1.5">Children</p>
                {f.members.length === 0 ? (
                  <p className="text-xs text-stone-300">No children added</p>
                ) : (
                  <div className="flex flex-wrap gap-1.5">
                    {f.members.map(m => (
                      <span key={m.id} className="bg-amber-50 text-amber-800 text-xs font-semibold px-2 py-0.5 rounded-full">
                        {m.name}{m.age ? `, ${m.age}` : ''}
                      </span>
                    ))}
                  </div>
                )}
              </div>

              {/* Stats row */}
              <div className="flex items-center gap-4 pt-3 border-t border-stone-50 text-xs text-stone-400">
                <span>🌱 {totalSeeds} seeds</span>
                <span>🏆 {f.streak?.longestStreak ?? 0} best</span>
                <span>{f.members.length} {f.members.length === 1 ? 'child' : 'children'}</span>
              </div>
            </div>
          );
        })}
      </div>

      {pages > 1 && (
        <div className="flex items-center justify-between mt-6">
          <p className="text-xs text-stone-400">Page {page} of {pages}</p>
          <div className="flex gap-2">
            {page > 1 && (
              <Link href={`/admin/families?${new URLSearchParams({ ...(q ? { q } : {}), page: String(page - 1) })}`}
                className="px-4 py-2 rounded-xl border border-stone-200 text-xs font-semibold text-stone-600 hover:bg-stone-50">
                ← Prev
              </Link>
            )}
            {page < pages && (
              <Link href={`/admin/families?${new URLSearchParams({ ...(q ? { q } : {}), page: String(page + 1) })}`}
                className="px-4 py-2 rounded-xl border border-stone-200 text-xs font-semibold text-stone-600 hover:bg-stone-50">
                Next →
              </Link>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
