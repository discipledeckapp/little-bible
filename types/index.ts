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

// ── Story-First Navigation Types ──────────────────────────────────────────────

export interface StoryVerse {
  ref: string;         // e.g. "Genesis 1:1"
  kjv: string;
  little_bible: string;
}

export interface StoryStep {
  title: string;
  text?: string;
  childText?: string;
  verses?: StoryVerse[];
  question?: string;
  parentGuide?: string;
  familyQuestion?: string;
  guidedPrayer?: string;
  childPrompt?: string;
  prayerPoints?: string[];
  memoryVerse?: string;
  ref?: string;
  memoryPhrase?: string;
  tip?: string;
  action?: string;
  parentNote?: string;
}

export interface Story {
  id: string;
  title: string;
  subtitle: string;
  collection: string;
  mainTruth: string;
  ageRange: string;           // "4-5" | "6-7" | "4-7"
  bibleRef: string;
  durationMinutes: number;
  coverEmoji: string;
  coverColor: string;
  illustrationPrompt: string;
  steps: {
    read:     StoryStep;
    discuss:  StoryStep;
    pray:     StoryStep;
    remember: StoryStep;
    doToday:  StoryStep;
  };
}

export interface Collection {
  id: string;
  title: string;
  subtitle: string;
  emoji: string;
  color: string;
  stories: string[];          // array of story IDs
}

export interface JourneyStory {
  storyId: string;
  weekNumber: number;
}

export interface Journey {
  id: string;
  name: string;
  subtitle: string;
  ageRange: string;
  durationWeeks: number;
  mainTruth: string;
  coverEmoji: string;
  coverColor: string;
  outcomes: string[];
  stories: string[];          // ordered array of story IDs
  completionMessage: string;
  lumiStageStart: import('../components/mascot/LumiMascot').LumiStage;
  lumiStageEnd: import('../components/mascot/LumiMascot').LumiStage;
}

// Story completion state
export type StoryStatus = 'unread' | 'in-progress' | 'complete' | 'memorised';

export interface StoryProgress {
  storyId: string;
  status: StoryStatus;
  currentStep?: FamilyStep;
  completedAt?: string;
  memorisedAt?: string;
}
