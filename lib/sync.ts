import type { Progress } from '@/types';
import { getProgress } from '@/lib/progress';

const PROGRESS_KEY = 'little_bible_progress';

function saveProgress(p: Progress): void {
  if (typeof window !== 'undefined') {
    localStorage.setItem(PROGRESS_KEY, JSON.stringify(p));
  }
}

/** Merge cloud + local — never loses data from either side */
export function mergeProgress(local: Progress, cloud: Progress): Progress {
  // Union of completed verses
  const mergedVerses: Record<string, number[]> = { ...local.completedVerses };
  for (const [key, verseNums] of Object.entries(cloud.completedVerses)) {
    if (!mergedVerses[key]) {
      mergedVerses[key] = verseNums;
    } else {
      mergedVerses[key] = Array.from(new Set([...mergedVerses[key], ...verseNums]));
    }
  }

  // Union of completed chapters
  const mergedChapters = Array.from(
    new Set([...local.completedChapters, ...cloud.completedChapters])
  );

  // Union of badges (by id)
  const badgeMap = new Map(local.badges.map((b) => [b.id, b]));
  for (const b of cloud.badges) {
    if (!badgeMap.has(b.id)) badgeMap.set(b.id, b);
  }

  // Merge sessions — dedupe by date+book+chapter+verse, keep last 100
  const sessionKey = (s: Progress['sessions'][0]) =>
    `${s.date}_${s.book}_${s.chapter}_${s.verse}_${s.mode}`;
  const sessionMap = new Map(local.sessions.map((s) => [sessionKey(s), s]));
  for (const s of cloud.sessions) sessionMap.set(sessionKey(s), s);
  const mergedSessions = Array.from(sessionMap.values())
    .sort((a, b) => a.date.localeCompare(b.date))
    .slice(-100);

  return {
    wisdomSeeds:      Math.max(local.wisdomSeeds, cloud.wisdomSeeds),
    streak:           cloud.streak > 0 ? cloud.streak : local.streak,
    lastActiveDate:   cloud.lastActiveDate > local.lastActiveDate
      ? cloud.lastActiveDate
      : local.lastActiveDate,
    completedVerses:  mergedVerses,
    completedChapters: mergedChapters,
    badges:           Array.from(badgeMap.values()),
    sessions:         mergedSessions,
  };
}

/** Upload current localStorage progress to cloud */
export async function uploadProgress(): Promise<void> {
  const p = getProgress();
  try {
    await fetch('/api/progress', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(p),
    });
  } catch {
    // Silent — offline or unauthenticated
  }
}

/** Download cloud progress and merge into localStorage */
export async function downloadAndMergeProgress(): Promise<void> {
  try {
    const res = await fetch('/api/progress');
    if (!res.ok) return;
    const cloud: Progress = await res.json();
    if (!cloud) return;

    const local  = getProgress();
    const merged = mergeProgress(local, cloud);
    saveProgress(merged);
  } catch {
    // Silent — offline or unauthenticated
  }
}
