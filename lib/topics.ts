import fs from 'fs';
import path from 'path';

export interface TopicVerse {
  ref: string;
  book_slug: string;
  chapter: number;
  verse_num: number;
  kjv: string;
  little_bible: string;
  memory_phrase: string;
}

export interface Topic {
  id: string;
  title: string;
  emoji: string;
  color: string;
  colorLight: string;
  colorText: string;
  colorBorder: string;
  description: string;
  parent_note: string;
  verses: TopicVerse[];
  memory_verse: { ref: string; kjv: string; little_bible: string };
  memory_phrase: string;
  prayer: string;
  do_it_today: string;
  illustration_prompt: string;
  illustration_url?: string;
}

const DATA_PATH = path.join(process.cwd(), 'public', 'data', 'en', 'topics', 'topics.json');

export function getAllTopics(): Topic[] {
  try {
    return JSON.parse(fs.readFileSync(DATA_PATH, 'utf-8'));
  } catch {
    return [];
  }
}

export function getTopicById(id: string): Topic | null {
  return getAllTopics().find(t => t.id === id) ?? null;
}
