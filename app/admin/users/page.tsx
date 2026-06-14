import type { Metadata } from 'next';
import { prisma } from '@/lib/prisma';
import Link from 'next/link';
import { ROLE_COLORS, ROLE_LABELS } from '@/lib/admin/permissions';
import type { AdminRole } from '@prisma/client';

export const metadata: Metadata = { title: 'Users' };

interface PageProps {
  searchParams: Promise<{ q?: string; page?: string }>;
}

export default async function UsersPage({ searchParams }: PageProps) {
  const { q = '', page: pageStr = '1' } = await searchParams;
  const page     = Math.max(1, parseInt(pageStr, 10));
  const pageSize = 25;
  const search   = q.trim();

  const where = search
    ? {
        OR: [
          { name:  { contains: search, mode: 'insensitive' as const } },
          { email: { contains: search, mode: 'insensitive' as const } },
        ],
      }
    : {};

  const [total, users] = await Promise.all([
    prisma.user.count({ where }),
    prisma.user.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * pageSize,
      take: pageSize,
      select: {
        id: true, name: true, email: true, image: true, createdAt: true, role: true,
        family: {
          select: {
            name: true,
            members: { select: { id: true, seeds: true } },
            streak:  { select: { currentStreak: true } },
          },
        },
        progress: { select: { wisdomSeeds: true, streak: true, completedChapters: true } },
      },
    }),
  ]);

  const pages = Math.ceil(total / pageSize);

  return (
    <div className="p-8 max-w-6xl mx-auto w-full">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Users</h1>
          <p className="text-stone-500 text-sm mt-0.5">{total.toLocaleString()} total registered users</p>
        </div>
      </div>

      {/* Search */}
      <form className="mb-6">
        <div className="flex gap-2 max-w-md">
          <input
            name="q"
            defaultValue={q}
            placeholder="Search by name or email…"
            className="flex-1 border border-stone-200 rounded-xl px-4 py-2.5 text-sm text-stone-800 placeholder-stone-400 focus:outline-none focus:ring-2 focus:ring-amber-400 bg-white"
          />
          <button
            type="submit"
            className="bg-amber-500 hover:bg-amber-600 text-white font-semibold text-sm px-4 py-2.5 rounded-xl transition-colors"
          >
            Search
          </button>
          {q && (
            <Link
              href="/admin/users"
              className="border border-stone-200 text-stone-600 hover:text-stone-800 font-semibold text-sm px-4 py-2.5 rounded-xl transition-colors bg-white"
            >
              Clear
            </Link>
          )}
        </div>
      </form>

      {/* Table */}
      <div className="bg-white rounded-2xl border border-stone-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-stone-100">
                <th className="text-left text-xs font-semibold text-stone-400 uppercase tracking-wider px-5 py-3.5">User</th>
                <th className="text-left text-xs font-semibold text-stone-400 uppercase tracking-wider px-4 py-3.5">Joined</th>
                <th className="text-left text-xs font-semibold text-stone-400 uppercase tracking-wider px-4 py-3.5">Family</th>
                <th className="text-left text-xs font-semibold text-stone-400 uppercase tracking-wider px-4 py-3.5">Progress</th>
                <th className="text-left text-xs font-semibold text-stone-400 uppercase tracking-wider px-4 py-3.5">Role</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-50">
              {users.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-5 py-10 text-center text-stone-400 text-sm">
                    {search ? `No users matching "${search}"` : 'No users yet'}
                  </td>
                </tr>
              ) : users.map(u => (
                <tr key={u.id} className="hover:bg-stone-50 transition-colors">
                  <td className="px-5 py-3.5">
                    <div className="flex items-center gap-3">
                      {u.image ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img src={u.image} alt="" className="w-8 h-8 rounded-full shrink-0" />
                      ) : (
                        <div className="w-8 h-8 rounded-full bg-stone-100 flex items-center justify-center text-stone-500 text-xs font-bold shrink-0">
                          {(u.name ?? u.email ?? 'U')[0].toUpperCase()}
                        </div>
                      )}
                      <div className="min-w-0">
                        <p className="font-semibold text-stone-800 truncate text-sm">{u.name ?? '—'}</p>
                        <p className="text-stone-400 text-xs truncate">{u.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3.5 text-stone-500 text-xs whitespace-nowrap">
                    {new Date(u.createdAt).toLocaleDateString('en-GB', {
                      day: 'numeric', month: 'short', year: '2-digit',
                    })}
                  </td>
                  <td className="px-4 py-3.5">
                    {u.family ? (
                      <div>
                        <p className="text-sm font-semibold text-stone-700 truncate max-w-[140px]">
                          {u.family.name ?? 'Unnamed family'}
                        </p>
                        <p className="text-xs text-stone-400">
                          {u.family.members.length} {u.family.members.length === 1 ? 'child' : 'children'} · {u.family.members.reduce((s, m) => s + m.seeds, 0)} seeds
                        </p>
                      </div>
                    ) : (
                      <span className="text-stone-300 text-xs">No family</span>
                    )}
                  </td>
                  <td className="px-4 py-3.5">
                    {u.progress ? (
                      <div>
                        <p className="text-xs font-semibold text-stone-700">{u.progress.wisdomSeeds} seeds</p>
                        <p className="text-xs text-stone-400">{u.progress.completedChapters.length} chapters</p>
                      </div>
                    ) : (
                      <span className="text-stone-300 text-xs">—</span>
                    )}
                  </td>
                  <td className="px-4 py-3.5">
                    {u.role ? (
                      <span className={`inline-block text-[10px] font-bold px-2 py-1 rounded-full ${ROLE_COLORS[u.role as AdminRole]}`}>
                        {ROLE_LABELS[u.role as AdminRole]}
                      </span>
                    ) : (
                      <span className="text-stone-300 text-xs">User</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {pages > 1 && (
          <div className="flex items-center justify-between px-5 py-3.5 border-t border-stone-100 bg-stone-50/50">
            <p className="text-xs text-stone-400">
              Showing {(page - 1) * pageSize + 1}–{Math.min(page * pageSize, total)} of {total}
            </p>
            <div className="flex gap-1.5">
              {page > 1 && (
                <Link
                  href={`/admin/users?${new URLSearchParams({ ...(q ? { q } : {}), page: String(page - 1) })}`}
                  className="px-3 py-1.5 rounded-lg border border-stone-200 text-xs font-semibold text-stone-600 hover:bg-stone-100 transition-colors"
                >
                  ← Prev
                </Link>
              )}
              {page < pages && (
                <Link
                  href={`/admin/users?${new URLSearchParams({ ...(q ? { q } : {}), page: String(page + 1) })}`}
                  className="px-3 py-1.5 rounded-lg border border-stone-200 text-xs font-semibold text-stone-600 hover:bg-stone-100 transition-colors"
                >
                  Next →
                </Link>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
