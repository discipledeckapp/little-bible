import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';

// POST /api/family/progress
// Body: { memberId, bookSlug, chapter, verse, mode, type: 'verse' | 'chapter' | 'session' }
export async function POST(req: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const body = await req.json().catch(() => null);
  if (!body) return NextResponse.json({ error: 'Invalid body' }, { status: 400 });

  const { memberId, bookSlug, chapter, verse, mode, type } = body;
  if (!memberId || !bookSlug || !chapter || !verse) {
    return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
  }

  // Verify member belongs to this user's family
  const member = await prisma.familyMember.findFirst({
    where: {
      id: memberId,
      family: { ownerId: session.user.id },
    },
  });
  if (!member) return NextResponse.json({ error: 'Member not found' }, { status: 404 });

  const today = new Date().toISOString().split('T')[0];
  const chapterKey = `${bookSlug}_${chapter}`;

  // Record session
  await prisma.memberSession.create({
    data: { memberId, bookSlug, chapter: parseInt(chapter), verse: parseInt(verse), mode: mode ?? 'child' },
  });

  // Update member progress
  const existing = await prisma.memberProgress.findUnique({ where: { memberId } });
  let seedsToAdd = 0;

  if (type === 'verse') {
    // Award 1 seed per unique verse
    const verses: Record<string, number[]> = existing
      ? JSON.parse(existing.completedVersesJson || '{}')
      : {};
    const verseList = verses[chapterKey] ?? [];
    const verseNum = parseInt(verse);
    if (!verseList.includes(verseNum)) {
      verseList.push(verseNum);
      verses[chapterKey] = verseList;
      seedsToAdd = 1;
    }

    await prisma.memberProgress.upsert({
      where: { memberId },
      create: {
        memberId,
        completedVersesJson: JSON.stringify(verses),
        lastReadBook: bookSlug,
        lastReadChapter: parseInt(chapter),
        lastReadAt: new Date(),
      },
      update: {
        completedVersesJson: JSON.stringify(verses),
        lastReadBook: bookSlug,
        lastReadChapter: parseInt(chapter),
        lastReadAt: new Date(),
      },
    });
  }

  if (type === 'chapter') {
    // Award 5 bonus seeds per unique chapter
    const chapters = existing?.completedChapters ?? [];
    if (!chapters.includes(chapterKey)) {
      chapters.push(chapterKey);
      seedsToAdd = 5;
    }

    await prisma.memberProgress.upsert({
      where: { memberId },
      create: {
        memberId,
        completedChapters: chapters,
        lastReadBook: bookSlug,
        lastReadChapter: parseInt(chapter),
        lastReadAt: new Date(),
      },
      update: {
        completedChapters: chapters,
        lastReadBook: bookSlug,
        lastReadChapter: parseInt(chapter),
        lastReadAt: new Date(),
      },
    });
  }

  if (seedsToAdd > 0) {
    await prisma.familyMember.update({
      where: { id: memberId },
      data: { seeds: { increment: seedsToAdd } },
    });
  }

  // Update family streak
  const family = await prisma.family.findUnique({
    where: { ownerId: session.user.id },
    include: { streak: true },
  });

  if (family) {
    const streak = family.streak;
    const yesterday = new Date(Date.now() - 86_400_000).toISOString().split('T')[0];

    if (!streak) {
      await prisma.familyStreak.create({
        data: { familyId: family.id, currentStreak: 1, longestStreak: 1, lastReadDate: today },
      });
    } else if (streak.lastReadDate !== today) {
      const newCurrent = streak.lastReadDate === yesterday ? streak.currentStreak + 1 : 1;
      const newLongest = Math.max(streak.longestStreak, newCurrent);
      await prisma.familyStreak.update({
        where: { familyId: family.id },
        data: { currentStreak: newCurrent, longestStreak: newLongest, lastReadDate: today },
      });
    }
  }

  return NextResponse.json({ ok: true, seedsAwarded: seedsToAdd });
}
