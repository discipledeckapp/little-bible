import type { Metadata } from 'next';
import { prisma } from '@/lib/prisma';
import Link from 'next/link';

export const metadata: Metadata = { title: 'App Interest' };

const FLAG: Record<string, string> = {
  US: '🇺🇸', GB: '🇬🇧', NG: '🇳🇬', CA: '🇨🇦', AU: '🇦🇺',
  ZA: '🇿🇦', GH: '🇬🇭', KE: '🇰🇪', IN: '🇮🇳', DE: '🇩🇪',
  FR: '🇫🇷', BR: '🇧🇷', NZ: '🇳🇿', IE: '🇮🇪', SG: '🇸🇬',
};

export default async function AppInterestPage() {
  const now     = new Date();
  const weekAgo = new Date(now.getTime() - 7 * 86_400_000);

  const [
    total,
    iosOnly,
    androidOnly,
    both,
    byEmail,
    byPush,
    byBothNotify,
    withFamily,
    newThisWeek,
    byCountryRaw,
    recent,
  ] = await Promise.all([
    prisma.appInterest.count(),
    prisma.appInterest.count({ where: { wantsIos: true,  wantsAndroid: false } }),
    prisma.appInterest.count({ where: { wantsIos: false, wantsAndroid: true  } }),
    prisma.appInterest.count({ where: { wantsIos: true,  wantsAndroid: true  } }),
    prisma.appInterest.count({ where: { wantsEmail: true  } }),
    prisma.appInterest.count({ where: { wantsPush:  true  } }),
    prisma.appInterest.count({ where: { wantsEmail: true, wantsPush: true } }),
    prisma.appInterest.count({ where: { user: { family: { isNot: null } } } }),
    prisma.appInterest.count({ where: { createdAt: { gte: weekAgo } } }),
    prisma.$queryRaw<{ countryCode: string | null; cnt: bigint }[]>`
      SELECT "countryCode", COUNT(*) as cnt
      FROM "AppInterest"
      GROUP BY "countryCode"
      ORDER BY cnt DESC
      LIMIT 20
    `,
    prisma.appInterest.findMany({
      orderBy: { createdAt: 'desc' },
      take: 15,
      select: {
        createdAt:    true,
        wantsIos:     true,
        wantsAndroid: true,
        wantsEmail:   true,
        wantsPush:    true,
        countryCode:  true,
        user: { select: { name: true, email: true, image: true } },
      },
    }),
  ]);

  const wantsIos     = iosOnly + both;
  const wantsAndroid = androidOnly + both;
  const countries = byCountryRaw.map(r => ({ code: r.countryCode ?? 'unknown', count: Number(r.cnt) }));

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-stone-800">App Interest</h1>
          <p className="text-stone-400 text-sm mt-0.5">Platform preferences from registered users</p>
        </div>
        <Link
          href="/admin/dashboard"
          className="text-sm text-stone-500 hover:text-stone-700 font-medium"
        >
          ← Dashboard
        </Link>
      </div>

      {/* ── Summary cards ── */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        {[
          { label: 'Total Interested', value: total,        icon: '📱', highlight: true  },
          { label: 'This Week',        value: newThisWeek,  icon: '📅', highlight: false },
          { label: 'Want iPhone',      value: wantsIos,     icon: '🍎', highlight: false },
          { label: 'Want Android',     value: wantsAndroid, icon: '🤖', highlight: false },
        ].map(c => (
          <div
            key={c.label}
            className={`rounded-2xl p-5 border ${
              c.highlight
                ? 'bg-amber-50 border-amber-200'
                : 'bg-white border-stone-100'
            }`}
          >
            <p className="text-2xl mb-2">{c.icon}</p>
            <p className={`text-3xl font-extrabold mb-1 ${c.highlight ? 'text-amber-700' : 'text-stone-800'}`}>
              {c.value}
            </p>
            <p className="text-stone-400 text-xs font-medium uppercase tracking-wide">{c.label}</p>
          </div>
        ))}
      </div>

      {/* ── Platform breakdown ── */}
      <div className="grid sm:grid-cols-2 gap-6">

        {/* Platform split */}
        <div className="bg-white rounded-2xl border border-stone-100 p-6">
          <h2 className="font-bold text-stone-700 text-sm mb-4 uppercase tracking-wide">Platform Split</h2>
          <div className="space-y-3">
            {[
              { label: 'iPhone only',     value: iosOnly,     color: 'bg-blue-500'   },
              { label: 'Android only',    value: androidOnly, color: 'bg-green-500'  },
              { label: 'Both platforms',  value: both,        color: 'bg-amber-500'  },
            ].map(r => (
              <div key={r.label} className="flex items-center gap-3">
                <div className={`w-3 h-3 rounded-full ${r.color} flex-shrink-0`} />
                <div className="flex-1 flex items-center justify-between">
                  <span className="text-stone-600 text-sm">{r.label}</span>
                  <div className="flex items-center gap-2">
                    <div className="w-24 h-2 bg-stone-100 rounded-full overflow-hidden">
                      <div
                        className={`h-full ${r.color} rounded-full`}
                        style={{ width: total > 0 ? `${(r.value / total) * 100}%` : '0%' }}
                      />
                    </div>
                    <span className="text-stone-800 font-bold text-sm w-6 text-right">{r.value}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Notification split */}
        <div className="bg-white rounded-2xl border border-stone-100 p-6">
          <h2 className="font-bold text-stone-700 text-sm mb-4 uppercase tracking-wide">Notification Method</h2>
          <div className="space-y-3">
            {[
              { label: 'Email only',          value: byEmail - byBothNotify, color: 'bg-purple-500' },
              { label: 'Push only',           value: byPush  - byBothNotify, color: 'bg-sky-500'    },
              { label: 'Both email + push',   value: byBothNotify,           color: 'bg-amber-500'  },
            ].map(r => (
              <div key={r.label} className="flex items-center gap-3">
                <div className={`w-3 h-3 rounded-full ${r.color} flex-shrink-0`} />
                <div className="flex-1 flex items-center justify-between">
                  <span className="text-stone-600 text-sm">{r.label}</span>
                  <div className="flex items-center gap-2">
                    <div className="w-24 h-2 bg-stone-100 rounded-full overflow-hidden">
                      <div
                        className={`h-full ${r.color} rounded-full`}
                        style={{ width: total > 0 ? `${(r.value / total) * 100}%` : '0%' }}
                      />
                    </div>
                    <span className="text-stone-800 font-bold text-sm w-6 text-right">{r.value}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Family breakdown */}
          <div className="mt-5 pt-5 border-t border-stone-100">
            <h3 className="font-bold text-stone-500 text-xs uppercase tracking-wide mb-2">Family Accounts</h3>
            <div className="flex items-center gap-4">
              <div>
                <p className="text-2xl font-extrabold text-stone-800">{withFamily}</p>
                <p className="text-stone-400 text-xs">Have a family</p>
              </div>
              <div>
                <p className="text-2xl font-extrabold text-stone-800">{total - withFamily}</p>
                <p className="text-stone-400 text-xs">No family yet</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ── Country breakdown ── */}
      {countries.length > 0 && (
        <div className="bg-white rounded-2xl border border-stone-100 p-6">
          <h2 className="font-bold text-stone-700 text-sm mb-4 uppercase tracking-wide">Country Breakdown</h2>
          <div className="flex flex-wrap gap-2">
            {countries.map(c => (
              <div
                key={c.code}
                className="flex items-center gap-2 bg-stone-50 rounded-xl px-3 py-2 border border-stone-100"
              >
                <span className="text-lg">{FLAG[c.code.toUpperCase()] ?? '🌍'}</span>
                <span className="text-stone-600 text-sm font-medium">{c.code.toUpperCase()}</span>
                <span className="text-stone-800 font-extrabold text-sm">{c.count}</span>
              </div>
            ))}
          </div>
          <p className="text-stone-400 text-xs mt-3">
            Country data requires Vercel or Cloudflare geo headers.
            Entries without a country show as &quot;unknown&quot;.
          </p>
        </div>
      )}

      {/* ── Recent sign-ups ── */}
      <div className="bg-white rounded-2xl border border-stone-100 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-100">
          <h2 className="font-bold text-stone-700 text-sm uppercase tracking-wide">Recent Sign-ups</h2>
        </div>
        <div className="divide-y divide-stone-50">
          {recent.length === 0 ? (
            <p className="px-6 py-8 text-center text-stone-400 text-sm">No sign-ups yet.</p>
          ) : (
            recent.map((r, i) => (
              <div key={i} className="flex items-center gap-4 px-6 py-3">
                {/* Avatar */}
                <div className="w-9 h-9 rounded-full bg-amber-100 flex items-center justify-center text-sm flex-shrink-0 overflow-hidden">
                  {r.user.image ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={r.user.image} alt="" className="w-full h-full object-cover" />
                  ) : (
                    <span>👤</span>
                  )}
                </div>
                {/* Name + email */}
                <div className="flex-1 min-w-0">
                  <p className="text-stone-800 font-semibold text-sm truncate">
                    {r.user.name ?? 'Unknown'}
                  </p>
                  <p className="text-stone-400 text-xs truncate">{r.user.email}</p>
                </div>
                {/* Platforms */}
                <div className="flex gap-1 flex-shrink-0">
                  {r.wantsIos     && <span title="iPhone"  className="text-base">🍎</span>}
                  {r.wantsAndroid && <span title="Android" className="text-base">🤖</span>}
                </div>
                {/* Notify methods */}
                <div className="flex gap-1 flex-shrink-0">
                  {r.wantsEmail && <span title="Email" className="text-sm">✉️</span>}
                  {r.wantsPush  && <span title="Push"  className="text-sm">🔔</span>}
                </div>
                {/* Country */}
                {r.countryCode && (
                  <span className="text-base flex-shrink-0" title={r.countryCode}>
                    {FLAG[r.countryCode.toUpperCase()] ?? '🌍'}
                  </span>
                )}
                {/* Date */}
                <p className="text-stone-400 text-xs flex-shrink-0 hidden sm:block">
                  {new Date(r.createdAt).toLocaleDateString()}
                </p>
              </div>
            ))
          )}
        </div>
      </div>

    </div>
  );
}
