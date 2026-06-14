import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { requireAdminApi } from '@/lib/admin/auth';

export async function GET() {
  const result = await requireAdminApi('dashboard');
  if (result.error) return result.error;

  const [
    total,
    iosOnly,
    androidOnly,
    both,
    byEmail,
    byPush,
    byBothNotify,
    withFamily,
    byCountry,
    recent,
  ] = await Promise.all([
    prisma.appInterest.count(),
    prisma.appInterest.count({ where: { wantsIos: true,  wantsAndroid: false } }),
    prisma.appInterest.count({ where: { wantsIos: false, wantsAndroid: true  } }),
    prisma.appInterest.count({ where: { wantsIos: true,  wantsAndroid: true  } }),
    prisma.appInterest.count({ where: { wantsEmail: true } }),
    prisma.appInterest.count({ where: { wantsPush: true  } }),
    prisma.appInterest.count({ where: { wantsEmail: true, wantsPush: true } }),
    // Users who have a family account
    prisma.appInterest.count({
      where: { user: { family: { isNot: null } } },
    }),
    // Country breakdown — top 20
    prisma.$queryRaw<{ countryCode: string | null; cnt: bigint }[]>`
      SELECT "countryCode", COUNT(*) as cnt
      FROM "AppInterest"
      GROUP BY "countryCode"
      ORDER BY cnt DESC
      LIMIT 20
    `,
    // Most recent 10 sign-ups
    prisma.appInterest.findMany({
      orderBy: { createdAt: 'desc' },
      take: 10,
      select: {
        createdAt:    true,
        wantsIos:     true,
        wantsAndroid: true,
        countryCode:  true,
        user: { select: { name: true, email: true, image: true } },
      },
    }),
  ]);

  return NextResponse.json({
    summary: {
      total,
      iosOnly,
      androidOnly,
      both,
      wantsIos:    iosOnly + both,
      wantsAndroid: androidOnly + both,
    },
    notifications: {
      byEmail,
      byPush,
      byBothNotify,
      emailOnly: byEmail - byBothNotify,
      pushOnly:  byPush  - byBothNotify,
    },
    families: {
      withFamily,
      withoutFamily: total - withFamily,
    },
    countries: byCountry.map(r => ({
      code:  r.countryCode ?? 'unknown',
      count: Number(r.cnt),
    })),
    recent,
  });
}
