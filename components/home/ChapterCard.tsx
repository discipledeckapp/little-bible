'use client';

import Link from 'next/link';
import { useState, useEffect } from 'react';
import { getChapterCompletedVerses, isChapterComplete } from '@/lib/progress';

interface ChapterCardProps {
  bookSlug: string;
  bookName: string;
  chapter: number;
  verseCount: number;
}

export default function ChapterCard({ bookSlug, bookName, chapter, verseCount }: ChapterCardProps) {
  const [completedCount, setCompletedCount] = useState(0);
  const [done, setDone]                     = useState(false);

  useEffect(() => {
    const completed = getChapterCompletedVerses(bookSlug, chapter);
    setCompletedCount(completed.length);
    setDone(isChapterComplete(bookSlug, chapter, verseCount));
  }, [bookSlug, chapter, verseCount]);

  const started  = completedCount > 0;
  const progress = verseCount > 0 ? Math.round((completedCount / verseCount) * 100) : 0;

  return (
    <Link
      href={`/${bookSlug}/${chapter}`}
      className="block group focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded-2xl"
      aria-label={`Read ${bookName} chapter ${chapter}, ${verseCount} verses${done ? ', completed' : started ? `, ${completedCount} of ${verseCount} verses read` : ''}`}
    >
      <div className={`bg-white rounded-2xl border p-5 shadow-sm group-hover:shadow-md group-active:scale-95 transition-all cursor-pointer h-full ${
        done
          ? 'border-amber-300 bg-amber-50/40'
          : started
          ? 'border-amber-100 group-hover:border-amber-200'
          : 'border-stone-100 group-hover:border-amber-100'
      }`}>
        {/* Chapter badge + arrow */}
        <div className="flex items-center justify-between mb-3">
          <div className={`w-12 h-12 rounded-2xl flex items-center justify-center text-xl font-bold transition-colors ${
            done
              ? 'bg-amber-400 text-white'
              : started
              ? 'bg-amber-100 text-amber-700 group-hover:bg-amber-200'
              : 'bg-stone-100 text-stone-600 group-hover:bg-amber-100 group-hover:text-amber-700'
          }`}>
            {done ? '✓' : chapter}
          </div>
          <span
            className={`text-xl transition-colors ${
              done ? 'text-amber-400' : 'text-stone-200 group-hover:text-amber-400'
            }`}
            aria-hidden="true"
          >
            →
          </span>
        </div>

        <h3 className={`font-bold text-base leading-tight transition-colors ${
          done ? 'text-amber-800' : 'text-stone-800 group-hover:text-amber-700'
        }`}>
          {bookName} {chapter}
        </h3>
        <p className="text-stone-400 text-sm mt-0.5">{verseCount} verses</p>

        {/* Progress bar or status */}
        <div className="mt-3">
          {done ? (
            <div className="flex items-center gap-1.5">
              <span className="text-amber-500 text-sm font-bold" aria-hidden="true">🌟</span>
              <span className="text-amber-600 text-xs font-bold">Complete!</span>
            </div>
          ) : started ? (
            <>
              <div
                role="progressbar"
                aria-valuenow={completedCount}
                aria-valuemin={0}
                aria-valuemax={verseCount}
                aria-label={`${completedCount} of ${verseCount} verses read`}
                className="w-full bg-amber-100 rounded-full h-1.5 mb-1.5 overflow-hidden"
              >
                <div
                  className="bg-amber-400 h-1.5 rounded-full transition-all"
                  style={{ width: `${progress}%` }}
                />
              </div>
              <span className="text-amber-500 text-xs font-semibold">{progress}% read</span>
            </>
          ) : (
            <div className="flex items-center gap-1.5">
              <div className="w-2 h-2 rounded-full bg-stone-200" aria-hidden="true" />
              <span className="text-stone-400 text-xs">Tap to begin</span>
            </div>
          )}
        </div>
      </div>
    </Link>
  );
}
