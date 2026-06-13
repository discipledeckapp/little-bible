import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';

async function getMemberAndVerifyOwnership(memberId: string, userId: string) {
  const member = await prisma.familyMember.findUnique({
    where: { id: memberId },
    include: { family: true },
  });
  if (!member) return null;
  if (member.family.ownerId !== userId) return null;
  return member;
}

// PATCH /api/family/members/[id]
export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const { id } = await params;
  const member = await getMemberAndVerifyOwnership(id, session.user.id);
  if (!member) return NextResponse.json({ error: 'Not found' }, { status: 404 });

  const body = await req.json().catch(() => ({}));
  const data: Record<string, unknown> = {};
  if ('name' in body && body.name?.trim()) data.name = body.name.trim();
  if ('age' in body) data.age = body.age ? parseInt(body.age) : null;
  if ('avatarId' in body) data.avatarId = body.avatarId;
  if ('accentColor' in body) data.accentColor = body.accentColor;
  if ('faithGoals' in body) data.faithGoals = body.faithGoals;
  if ('sortOrder' in body) data.sortOrder = body.sortOrder;

  const updated = await prisma.familyMember.update({ where: { id }, data });
  return NextResponse.json(updated);
}

// DELETE /api/family/members/[id]
export async function DELETE(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const { id } = await params;
  const member = await getMemberAndVerifyOwnership(id, session.user.id);
  if (!member) return NextResponse.json({ error: 'Not found' }, { status: 404 });

  await prisma.familyMember.delete({ where: { id } });
  return NextResponse.json({ ok: true });
}
