export interface ActivityMemoryBuilder {
  phrase: string;
  phraseWords: string[];
  verseRef: string;
  verseText: string;
  verseWords?: string[];
}

export interface ActivitySequenceItem {
  id: string;
  label: string;
  emoji: string;
  order: number;
}

export interface ActivitySequence {
  prompt: string;
  items: ActivitySequenceItem[];
}

export interface ActivityMatchPair {
  leftId: string;
  left: string;
  leftEmoji: string;
  rightId: string;
  right: string;
  rightEmoji: string;
}

export interface ActivityMatches {
  prompt: string;
  pairs: ActivityMatchPair[];
}

export interface ActivityOption {
  id: string;
  label: string;
  emoji: string;
}

export interface ActivityApplication {
  question: string;
  options: ActivityOption[];
  followUp: string;
}

export interface StoryActivity {
  storyId: string;
  memoryBuilder?: ActivityMemoryBuilder;
  sequence?: ActivitySequence;
  matches?: ActivityMatches;
  application?: ActivityApplication;
}

export type ActivityType =
  | 'memory-builder'
  | 'story-sequence'
  | 'character-match'
  | 'application';

export interface ActivityResult {
  type: ActivityType;
  seedsEarned: number;
  perfect: boolean;
}
