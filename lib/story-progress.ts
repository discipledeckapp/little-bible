import type { StoryStatus, StoryProgress } from '@/types';

const KEY = 'little_bible_story_progress';

export function getAllStoryProgress(): Record<string, StoryProgress> {
  if (typeof window === 'undefined') return {};
  try {
    return JSON.parse(localStorage.getItem(KEY) ?? '{}');
  } catch {
    return {};
  }
}

export function getStoryProgress(storyId: string): StoryProgress {
  const all = getAllStoryProgress();
  return all[storyId] ?? { storyId, status: 'unread' };
}

export function setStoryProgress(progress: StoryProgress): void {
  if (typeof window === 'undefined') return;
  const all = getAllStoryProgress();
  all[progress.storyId] = progress;
  localStorage.setItem(KEY, JSON.stringify(all));
}

export function markStoryStarted(storyId: string): void {
  const current = getStoryProgress(storyId);
  if (current.status === 'unread') {
    setStoryProgress({ storyId, status: 'in-progress' });
  }
}

export function markStoryComplete(storyId: string): void {
  setStoryProgress({
    storyId,
    status: 'complete',
    completedAt: new Date().toISOString(),
  });
}

export function markStoryMemorised(storyId: string): void {
  const current = getStoryProgress(storyId);
  setStoryProgress({
    ...current,
    storyId,
    status: 'memorised',
    memorisedAt: new Date().toISOString(),
  });
}
