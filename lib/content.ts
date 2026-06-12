import fs from 'fs';
import path from 'path';
import type { BookIndexEntry, ChapterIndexEntry, Chapter } from '@/types';

const DATA_ROOT = path.join(process.cwd(), 'public', 'data');

export function getLanguageIndex(lang = 'en'): BookIndexEntry[] {
  const filePath = path.join(DATA_ROOT, lang, 'index.json');
  return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
}

export function getBookIndex(bookSlug: string, lang = 'en'): ChapterIndexEntry[] {
  const filePath = path.join(DATA_ROOT, lang, bookSlug, 'index.json');
  return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
}

export function getChapter(
  bookSlug: string,
  chapterNum: number,
  lang = 'en'
): Chapter | null {
  try {
    const index = getBookIndex(bookSlug, lang);
    const entry = index.find((c) => c.chapter === chapterNum);
    if (!entry) return null;
    const filePath = path.join(DATA_ROOT, lang, bookSlug, entry.file);
    return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  } catch {
    return null;
  }
}

export interface ChapterMeta extends ChapterIndexEntry {
  verseCount: number;
}

export interface BookMeta extends BookIndexEntry {
  chapters: ChapterMeta[];
}

export function getAllBooksWithMeta(lang = 'en'): BookMeta[] {
  try {
    const books = getLanguageIndex(lang);
    return books.map((book) => {
      const chapters = getBookIndex(book.slug, lang);
      const chaptersWithMeta: ChapterMeta[] = chapters.map((ch) => {
        try {
          const filePath = path.join(DATA_ROOT, lang, book.slug, ch.file);
          const chapter: Chapter = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
          return { ...ch, verseCount: chapter.verses.length };
        } catch {
          return { ...ch, verseCount: 0 };
        }
      });
      return { ...book, chapters: chaptersWithMeta };
    });
  } catch {
    return [];
  }
}
