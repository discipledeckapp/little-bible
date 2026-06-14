import type { StoryActivity } from '@/types/activities';

export async function fetchStoryActivity(storyId: string): Promise<StoryActivity | null> {
  try {
    const res = await fetch(`/data/en/activities/${storyId}.json`);
    if (!res.ok) return null;
    return (await res.json()) as StoryActivity;
  } catch {
    return null;
  }
}

export async function fetchWeeklyVerse(): Promise<{
  ref: string;
  text: string;
  littleBible: string;
  phrase: string;
  phraseWords: string[];
  weekStart: string;
  storyId: string | null;
  seedsForPractice: number;
  lumiMessage: string;
} | null> {
  try {
    const res = await fetch('/data/en/weekly-verse.json');
    if (!res.ok) return null;
    return res.json();
  } catch {
    return null;
  }
}

export function getWeekKey(weekStart: string): string {
  return `littleBible_weekly_${weekStart}`;
}

export function isWeeklyVersePracticed(weekStart: string): boolean {
  if (typeof window === 'undefined') return false;
  return localStorage.getItem(getWeekKey(weekStart)) === 'practiced';
}

export function markWeeklyVersePracticed(weekStart: string): void {
  if (typeof window === 'undefined') return;
  localStorage.setItem(getWeekKey(weekStart), 'practiced');
}
