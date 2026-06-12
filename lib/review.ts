import type { ChapterReview, ReviewStatus } from '@/types';

const getKey = (book: string, chapter: number) =>
  `little_bible_review_${book.toLowerCase()}_${chapter}`;

export function getChapterReview(book: string, chapter: number): ChapterReview | null {
  if (typeof window === 'undefined') return null;
  const raw = localStorage.getItem(getKey(book, chapter));
  return raw ? JSON.parse(raw) : null;
}

export function saveVerseReview(
  book: string,
  chapter: number,
  verseNum: number,
  status: ReviewStatus
): ChapterReview {
  const existing = getChapterReview(book, chapter) ?? {
    book,
    chapter,
    reviewed: false,
    reviewedAt: '',
    verses: [],
  };

  const verses = existing.verses.filter((v) => v.verse !== verseNum);
  verses.push({ verse: verseNum, status });

  const updated: ChapterReview = {
    ...existing,
    verses,
    reviewed: true,
    reviewedAt: new Date().toISOString(),
  };

  localStorage.setItem(getKey(book, chapter), JSON.stringify(updated));
  return updated;
}

export function clearVerseReview(
  book: string,
  chapter: number,
  verseNum: number
): ChapterReview {
  const existing = getChapterReview(book, chapter) ?? {
    book,
    chapter,
    reviewed: false,
    reviewedAt: '',
    verses: [],
  };

  const verses = existing.verses.filter((v) => v.verse !== verseNum);
  const updated: ChapterReview = {
    ...existing,
    verses,
    reviewed: verses.length > 0,
    reviewedAt: new Date().toISOString(),
  };

  localStorage.setItem(getKey(book, chapter), JSON.stringify(updated));
  return updated;
}

export function exportReviewReport(review: ChapterReview): void {
  const blob = new Blob([JSON.stringify(review, null, 2)], {
    type: 'application/json',
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `review-${review.book.toLowerCase()}-chapter-${review.chapter}.json`;
  a.click();
  URL.revokeObjectURL(url);
}
