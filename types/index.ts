export interface Verse {
  book: string;
  chapter: number;
  verse: number;
  kjv: string;
  little_bible: string;                // primary adaptation (ages 5–7)
  little_reader_adaptation?: string;   // simpler adaptation (ages 4–5)
  meaning: string;
  memory_phrase: string;
  prayer: string;
  discussion_question: string;
  family_discussion?: string;          // "How can we do this today?" prompt
  do_it_today?: string;               // 5th Family Mode step — concrete action
  action_challenge?: string;           // optional bonus family challenge
  illustration_prompt?: string;        // what the illustration should depict
  keywords: string[];
}

export interface Chapter {
  book: string;
  chapter: number;
  chapter_summary: string;
  main_lesson: string;
  memory_verse: string;
  parent_guide: string;
  application_for_children: string;
  verses: Verse[];
}

export type ReviewStatus =
  | 'approved'
  | 'needs_review'
  | 'theological_concern'
  | 'too_difficult'
  | 'rewrite_needed';

export interface VerseReview {
  verse: number;
  status: ReviewStatus;
  note?: string;
}

export interface ChapterReview {
  book: string;
  chapter: number;
  reviewed: boolean;
  reviewedAt: string;
  verses: VerseReview[];
}

export interface ChapterIndexEntry {
  book: string;
  chapter: number;
  file: string;
}

export interface BookIndexEntry {
  book: string;
  slug: string;
  indexFile: string;
}

// Three-persona mode system
export type AppMode = 'child' | 'family' | 'review';

// Child sub-modes
export type ChildSubMode = 'story' | 'verse' | 'memory';

// Family mode step flow
export type FamilyStep = 'read' | 'discuss' | 'pray' | 'remember' | 'do_it_today';

// Progress & gamification
export interface Badge {
  id: string;
  label: string;
  emoji: string;
  earnedAt: string;
}

export interface DevotionSession {
  date: string;
  book: string;
  chapter: number;
  verse: number;
  mode: AppMode;
}

export interface Progress {
  wisdomSeeds: number;
  streak: number;
  lastActiveDate: string;
  completedVerses: Record<string, number[]>; // "proverbs_1" -> [1,2,3...]
  completedChapters: string[];              // ["proverbs_1", ...]
  badges: Badge[];
  sessions: DevotionSession[];
}
