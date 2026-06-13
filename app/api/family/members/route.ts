import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';

// POST /api/family/members — add a child profile
export async function POST(req: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const body = await req.json().catch(() => ({}));
  const { name, age, avatarId, accentColor, faithGoals } = body;

  if (!name?.trim()) return NextResponse.json({ error: 'Name is required' }, { status: 400 });

  const family = await prisma.family.findUnique({ where: { ownerId: session.user.id } });
  if (!family) return NextResponse.json({ error: 'Family not found' }, { status: 404 });

  const count = await prisma.familyMember.count({ where: { familyId: family.id } });

  const member = await prisma.familyMember.create({
    data: {
      familyId: family.id,
      name: name.trim(),
      age: age ? parseInt(age) : null,
      avatarId: avatarId ?? 'lion',
      accentColor: accentColor ?? null,
      faithGoals: faithGoals ?? [],
      sortOrder: count,
    },
  });

  return NextResponse.json(member, { status: 201 });
}
