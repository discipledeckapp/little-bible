import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';
import type { Progress } from '@/types';

export async function GET() {
  const session = await auth();
  if (!session?.user?.id) return Response.json(null, { status: 401 });

  const row = await prisma.userProgress.findUnique({
    where: { userId: session.user.id },
  });

  if (!row) return Response.json(null, { status: 404 });

  const progress: Progress = {
    wisdomSeeds:      row.wisdomSeeds,
    streak:           row.streak,
    lastActiveDate:   row.lastActiveDate,
    completedVerses:  JSON.parse(row.completedVersesJson),
    completedChapters: row.completedChapters,
    badges:           JSON.parse(row.badgesJson),
    sessions:         JSON.parse(row.sessionsJson),
  };

  return Response.json(progress);
}

export async function POST(req: Request) {
  const session = await auth();
  if (!session?.user?.id) return Response.json(null, { status: 401 });

  const p: Progress = await req.json();

  const row = await prisma.userProgress.upsert({
    where:  { userId: session.user.id },
    create: {
      userId:              session.user.id,
      wisdomSeeds:         p.wisdomSeeds,
      streak:              p.streak,
      lastActiveDate:      p.lastActiveDate,
      completedVersesJson: JSON.stringify(p.completedVerses),
      completedChapters:   p.completedChapters,
      badgesJson:          JSON.stringify(p.badges),
      sessionsJson:        JSON.stringify(p.sessions.slice(-100)),
    },
    update: {
      wisdomSeeds:         p.wisdomSeeds,
      streak:              p.streak,
      lastActiveDate:      p.lastActiveDate,
      completedVersesJson: JSON.stringify(p.completedVerses),
      completedChapters:   p.completedChapters,
      badgesJson:          JSON.stringify(p.badges),
      sessionsJson:        JSON.stringify(p.sessions.slice(-100)),
    },
  });

  return Response.json({ ok: true, updatedAt: row.updatedAt });
}
