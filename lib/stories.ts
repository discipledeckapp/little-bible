import fs from 'fs';
import path from 'path';
import type { Story, Collection, Journey } from '@/types';

// ── Story loading ─────────────────────────────────────────────────────────────

export async function getStory(id: string): Promise<Story | null> {
  try {
    const filePath = path.join(process.cwd(), 'public', 'data', 'en', 'stories', `${id}.json`);
    const raw = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export async function getAllStories(): Promise<Story[]> {
  try {
    const collections = await getAllCollections();
    const storyIds = [...new Set(collections.flatMap(c => c.stories))];
    const stories = await Promise.all(storyIds.map(id => getStory(id)));
    return stories.filter(Boolean) as Story[];
  } catch {
    return [];
  }
}

// ── Collection loading ────────────────────────────────────────────────────────

export async function getAllCollections(): Promise<Collection[]> {
  try {
    const filePath = path.join(process.cwd(), 'public', 'data', 'en', 'collections', 'index.json');
    const raw = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(raw);
  } catch {
    return [];
  }
}

export async function getCollection(id: string): Promise<Collection | null> {
  const collections = await getAllCollections();
  return collections.find(c => c.id === id) ?? null;
}

// ── Journey loading ───────────────────────────────────────────────────────────

const JOURNEY_IDS = ['god-loves-me', 'follow-jesus', 'wisdom-path'];

export async function getJourney(id: string): Promise<Journey | null> {
  try {
    const filePath = path.join(process.cwd(), 'public', 'data', 'en', 'journeys', `${id}.json`);
    const raw = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export async function getAllJourneys(): Promise<Journey[]> {
  const journeys = await Promise.all(JOURNEY_IDS.map(id => getJourney(id)));
  return journeys.filter(Boolean) as Journey[];
}

// ── Progress helpers ──────────────────────────────────────────────────────────

export function getStoriesForAge(stories: Story[], ageRange: '4-5' | '6-7'): Story[] {
  return stories.filter(s => {
    if (ageRange === '4-5') return s.ageRange === '4-5' || s.ageRange === '4-7';
    return true; // 6-7 sees everything
  });
}
