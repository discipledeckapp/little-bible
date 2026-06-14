import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { requireAdminApi } from '@/lib/admin/auth';

export async function GET(req: NextRequest) {
  const result = await requireAdminApi('users');
  if (result.error) return result.error;

  const { searchParams } = req.nextUrl;
  const page     = Math.max(1, parseInt(searchParams.get('page') ?? '1', 10));
  const pageSize = 20;
  const search   = searchParams.get('q')?.trim() ?? '';

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
      skip:  (page - 1) * pageSize,
      take:  pageSize,
      select: {
        id:        true,
        name:      true,
        email:     true,
        image:     true,
        createdAt: true,
        role:      true,
        family: {
          select: {
            id:      true,
            name:    true,
            members: { select: { id: true, seeds: true } },
            streak:  { select: { currentStreak: true } },
          },
        },
        progress: {
          select: {
            wisdomSeeds:       true,
            streak:            true,
            completedChapters: true,
          },
        },
      },
    }),
  ]);

  const shaped = users.map(u => ({
    id:        u.id,
    name:      u.name,
    email:     u.email,
    image:     u.image,
    role:      u.role,
    createdAt: u.createdAt,
    family: u.family
      ? {
          id:       u.family.id,
          name:     u.family.name,
          children: u.family.members.length,
          seeds:    u.family.members.reduce((s, m) => s + m.seeds, 0),
          streak:   u.family.streak?.currentStreak ?? 0,
        }
      : null,
    progress: u.progress
      ? {
          seeds:   u.progress.wisdomSeeds,
          streak:  u.progress.streak,
          chapters: u.progress.completedChapters.length,
        }
      : null,
  }));

  return NextResponse.json({
    users:   shaped,
    total,
    page,
    pages:   Math.ceil(total / pageSize),
    pageSize,
  });
}

// PATCH — update user role
export async function PATCH(req: NextRequest) {
  const result = await requireAdminApi('users');
  if (result.error) return result.error;

  const body = await req.json().catch(() => ({}));
  const { userId, role } = body;

  if (!userId) return NextResponse.json({ error: 'userId required' }, { status: 400 });

  const user = await prisma.user.update({
    where: { id: userId },
    data:  { role: role ?? null },
    select: { id: true, name: true, email: true, role: true },
  });

  return NextResponse.json(user);
}
