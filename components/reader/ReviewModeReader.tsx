'use client';

import { useState, useEffect } from 'react';
import type { Chapter, ChapterReview, ReviewStatus } from '@/types';
import { getMemoryVerseText, getMemoryVerseRef } from '@/types';
import { getChapterReview, saveVerseReview, exportReviewReport } from '@/lib/review';
import VerseCard from './VerseCard';

interface ReviewModeReaderProps {
  chapter: Chapter;
}

export default function ReviewModeReader({ chapter }: ReviewModeReaderProps) {
  const [search, setSearch] = useState('');
  const [showKJV, setShowKJV] = useState(true);
  const [annotating, setAnnotating] = useState(false);
  const [review, setReview] = useState<ChapterReview | null>(null);

  useEffect(() => {
    setReview(getChapterReview(chapter.book, chapter.chapter));
  }, [chapter.book, chapter.chapter]);

  const handleReview = (verseNum: number, status: ReviewStatus) => {
    const updated = saveVerseReview(chapter.book, chapter.chapter, verseNum, status);
    setReview(updated);
  };

  const filteredVerses = search.trim()
    ? chapter.verses.filter((v) => {
        const q = search.toLowerCase();
        return (
          v.kjv.toLowerCase().includes(q) ||
          v.little_bible.toLowerCase().includes(q) ||
          v.meaning.toLowerCase().includes(q) ||
          v.keywords.some((k) => k.toLowerCase().includes(q))
        );
      })
    : chapter.verses;

  const reviewedCount = review?.verses.length ?? 0;

  return (
    <div>
      {/* Chapter metadata panel */}
      <div className="bg-amber-50 rounded-2xl border border-amber-100 p-5 mb-6 space-y-4">
        {/* Memory verse */}
        <div className="bg-amber-100 rounded-xl px-4 py-3 border border-amber-200">
          <p className="text-xs font-bold text-amber-600 uppercase tracking-widest mb-1">
            Memory Verse
            {getMemoryVerseRef(chapter.memory_verse) && (
              <span className="ml-2 font-medium normal-case tracking-normal opacity-70">
                — {getMemoryVerseRef(chapter.memory_verse)}
              </span>
            )}
          </p>
          <p className="text-amber-900 font-semibold text-base leading-relaxed">
            &ldquo;{getMemoryVerseText(chapter.memory_verse)}&rdquo;
          </p>
        </div>

        {/* Main lesson */}
        <div className="bg-green-50 rounded-xl px-4 py-3 border border-green-100">
          <p className="text-xs font-bold text-green-600 uppercase tracking-widest mb-1">
            Main Lesson
          </p>
          <p className="text-green-800 font-medium text-sm">{chapter.main_lesson}</p>
        </div>

        {/* Summary */}
        <div>
          <p className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-1.5">
            Chapter Summary
          </p>
          <p className="text-stone-600 text-sm leading-relaxed">{chapter.chapter_summary}</p>
        </div>

        {/* Parent guide */}
        <details className="group">
          <summary className="cursor-pointer flex items-center justify-between bg-blue-50 rounded-xl px-4 py-3 border border-blue-100 select-none">
            <span className="flex items-center gap-2 text-sm font-semibold text-blue-700">
              <span aria-hidden="true">👨‍👩‍👧</span> Parent Guide
            </span>
            <span
              className="text-blue-400 transition-transform group-open:rotate-180 text-xs"
              aria-hidden="true"
            >
              ▼
            </span>
          </summary>
          <div className="mt-2 px-4 py-4 bg-blue-50/60 rounded-xl border border-blue-100">
            <p className="text-stone-600 text-sm leading-relaxed">{chapter.parent_guide}</p>
          </div>
        </details>

        {/* Application */}
        <details className="group">
          <summary className="cursor-pointer flex items-center justify-between bg-purple-50 rounded-xl px-4 py-3 border border-purple-100 select-none">
            <span className="flex items-center gap-2 text-sm font-semibold text-purple-700">
              <span aria-hidden="true">🌱</span> Application for Children
            </span>
            <span
              className="text-purple-400 transition-transform group-open:rotate-180 text-xs"
              aria-hidden="true"
            >
              ▼
            </span>
          </summary>
          <div className="mt-2 px-4 py-4 bg-purple-50/60 rounded-xl border border-purple-100">
            <p className="text-stone-600 text-sm leading-relaxed">
              {chapter.application_for_children}
            </p>
          </div>
        </details>
      </div>

      {/* Toolbar */}
      <div className="bg-white rounded-2xl border border-stone-100 shadow-sm p-4 mb-6 space-y-3">
        <input
          type="search"
          placeholder="Search verses, meaning, or keywords..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-300 focus:border-transparent"
          aria-label="Search this chapter"
        />
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => setShowKJV(!showKJV)}
            className={`px-4 py-2 text-sm font-semibold rounded-xl border transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300 ${
              showKJV
                ? 'bg-stone-800 text-white border-stone-800'
                : 'border-stone-200 text-stone-600 hover:bg-stone-50'
            }`}
            aria-label={showKJV ? 'Hide KJV text' : 'Show KJV text'}
            aria-pressed={showKJV}
          >
            <span aria-hidden="true">👁</span> {showKJV ? 'Hide KJV' : 'Show KJV'}
          </button>

          <button
            onClick={() => setAnnotating(!annotating)}
            className={`px-4 py-2 text-sm font-semibold rounded-xl border transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300 ${
              annotating
                ? 'bg-amber-500 text-white border-amber-500'
                : 'border-stone-200 text-stone-600 hover:bg-stone-50'
            }`}
            aria-label={annotating ? 'Exit annotation mode' : 'Enter annotation mode'}
            aria-pressed={annotating}
          >
            <span aria-hidden="true">📝</span> {annotating ? 'Done Annotating' : 'Annotate'}
          </button>

          {reviewedCount > 0 && (
            <button
              onClick={() => review && exportReviewReport(review)}
              className="px-4 py-2 text-sm font-semibold rounded-xl border border-stone-200 text-stone-600 hover:bg-stone-50 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
              aria-label={`Export review report — ${reviewedCount} annotated verse${reviewedCount !== 1 ? 's' : ''}`}
            >
              <span aria-hidden="true">⬇</span> Export ({reviewedCount})
            </button>
          )}
        </div>
      </div>

      {/* Results count */}
      {search.trim() && (
        <p className="text-sm text-stone-400 mb-4" aria-live="polite">
          {filteredVerses.length === 0
            ? 'No verses matched.'
            : `${filteredVerses.length} verse${filteredVerses.length !== 1 ? 's' : ''} found`}
        </p>
      )}

      {/* Verse list */}
      <div className="space-y-4">
        {filteredVerses.map((verse) => (
          <VerseCard
            key={verse.verse}
            verse={verse}
            showKJV={showKJV}
            reviewMode={annotating}
            currentStatus={review?.verses.find((r) => r.verse === verse.verse)?.status}
            onReview={handleReview}
          />
        ))}
      </div>
    </div>
  );
}
