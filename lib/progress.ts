import type { Progress, Badge, DevotionSession, AppMode } from '@/types';

// Lazy import — avoids circular deps; only fires in browser when signed in
function scheduleCloudSync(): void {
  if (typeof window === 'undefined') return;
  // Fire-and-forget; ProgressSyncProvider also uploads on interval
  import('@/lib/sync').then(({ uploadProgress }) => uploadProgress()).catch(() => {});
}

const PROGRESS_KEY = 'little_bible_progress';

const BADGE_DEFINITIONS: Record<string, Omit<Badge, 'earnedAt'>> = {
  first_verse:     { id: 'first_verse',     emoji: '🌱', label: 'First Step' },
  wisdom_seeker:   { id: 'wisdom_seeker',   emoji: '📖', label: 'Wisdom Seeker' },
  prayer_warrior:  { id: 'prayer_warrior',  emoji: '🙏', label: 'Prayer Warrior' },
  family_reader:   { id: 'family_reader',   emoji: '👨‍👩‍👧', label: 'Family Reader' },
  scripture_star:  { id: 'scripture_star',  emoji: '⭐', label: 'Scripture Star' },
  seven_day:       { id: 'seven_day',       emoji: '🔥', label: '7-Day Streak' },
  proverbs_done:   { id: 'proverbs_done',   emoji: '🕊', label: 'Book of Proverbs' },
};

function defaultProgress(): Progress {
  return {
    wisdomSeeds: 0,
    streak: 0,
    lastActiveDate: '',
    completedVerses: {},
    completedChapters: [],
    badges: [],
    sessions: [],
  };
}

export function getProgress(): Progress {
  if (typeof window === 'undefined') return defaultProgress();
  try {
    const raw = localStorage.getItem(PROGRESS_KEY);
    return raw ? { ...defaultProgress(), ...JSON.parse(raw) } : defaultProgress();
  } catch {
    return defaultProgress();
  }
}

function saveProgress(p: Progress): void {
  localStorage.setItem(PROGRESS_KEY, JSON.stringify(p));
}

function updateStreak(p: Progress): void {
  const today = new Date().toISOString().split('T')[0];
  if (p.lastActiveDate === today) return;

  const yesterday = new Date(Date.now() - 86_400_000).toISOString().split('T')[0];
  p.streak = p.lastActiveDate === yesterday ? p.streak + 1 : 1;
  p.lastActiveDate = today;

  if (p.streak >= 7) awardBadge(p, 'seven_day');
}

function awardBadge(p: Progress, id: string): void {
  if (p.badges.some((b) => b.id === id)) return;
  const def = BADGE_DEFINITIONS[id];
  if (!def) return;
  p.badges.push({ ...def, earnedAt: new Date().toISOString() });
}

export function markVerseComplete(
  bookSlug: string,
  chapter: number,
  verse: number
): { progress: Progress; newBadge: Badge | null } {
  const p = getProgress();
  const key = `${bookSlug}_${chapter}`;

  if (!p.completedVerses[key]) p.completedVerses[key] = [];

  let newBadge: Badge | null = null;
  if (!p.completedVerses[key].includes(verse)) {
    p.completedVerses[key].push(verse);
    p.wisdomSeeds += 1;
    updateStreak(p);

    // First ever verse
    if (!p.badges.some((b) => b.id === 'first_verse')) {
      awardBadge(p, 'first_verse');
      newBadge = p.badges[p.badges.length - 1];
    }
  }

  saveProgress(p);
  scheduleCloudSync();
  return { progress: p, newBadge };
}

export function markChapterComplete(
  bookSlug: string,
  chapter: number
): { progress: Progress; newBadge: Badge | null } {
  const p = getProgress();
  const key = `${bookSlug}_${chapter}`;

  let newBadge: Badge | null = null;
  if (!p.completedChapters.includes(key)) {
    p.completedChapters.push(key);
    p.wisdomSeeds += 5; // bonus seeds

    if (bookSlug === 'proverbs' && chapter === 1) {
      awardBadge(p, 'wisdom_seeker');
      newBadge = p.badges.find((b) => b.id === 'wisdom_seeker') ?? null;
    }

    // All 31 Proverbs chapters
    const proverbsDone = Array.from({ length: 31 }, (_, i) => `proverbs_${i + 1}`).every((k) =>
      p.completedChapters.includes(k)
    );
    if (proverbsDone) {
      awardBadge(p, 'proverbs_done');
      newBadge = p.badges.find((b) => b.id === 'proverbs_done') ?? newBadge;
    }
  }

  saveProgress(p);
  scheduleCloudSync();
  return { progress: p, newBadge };
}

export function recordSession(
  bookSlug: string,
  chapter: number,
  verse: number,
  mode: AppMode
): void {
  const p = getProgress();
  updateStreak(p);

  if (mode === 'family') {
    const familyCount = p.sessions.filter((s) => s.mode === 'family').length;
    if (familyCount >= 4) awardBadge(p, 'family_reader');
  }

  p.sessions.push({
    date: new Date().toISOString().split('T')[0],
    book: bookSlug,
    chapter,
    verse,
    mode,
  });

  // Keep last 100 sessions only
  if (p.sessions.length > 100) p.sessions = p.sessions.slice(-100);

  saveProgress(p);
}

export function getChapterCompletedVerses(bookSlug: string, chapter: number): number[] {
  return getProgress().completedVerses[`${bookSlug}_${chapter}`] ?? [];
}

export function isChapterComplete(
  bookSlug: string,
  chapter: number,
  totalVerses: number
): boolean {
  const done = getChapterCompletedVerses(bookSlug, chapter);
  return done.length >= totalVerses;
}

export function addSeeds(amount: number): void {
  const p = getProgress();
  p.wisdomSeeds += amount;
  updateStreak(p);
  saveProgress(p);
  scheduleCloudSync();
}

export function resetProgress(): void {
  if (typeof window !== 'undefined') localStorage.removeItem(PROGRESS_KEY);
}
