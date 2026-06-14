import type { Metadata } from 'next';
import Link from 'next/link';
import { prisma } from '@/lib/prisma';
import { BIBLE_BOOKS } from '@/lib/bibleBooks';
import { getBookIndex } from '@/lib/content';

export const metadata: Metadata = { title: 'Content' };

const STATUS_STYLES: Record<string, string> = {
  pending:           'bg-stone-100 text-stone-500',
  approved:          'bg-emerald-100 text-emerald-700',
  needs_revision:    'bg-amber-100 text-amber-700',
  flagged:           'bg-red-100 text-red-700',
};

const STATUS_LABELS: Record<string, string> = {
  pending:        'Pending Review',
  approved:       'Approved',
  needs_revision: 'Needs Revision',
  flagged:        'Flagged',
};

export default async function ContentPage() {
  // Load review statuses from DB for all books that have content
  const reviews = await prisma.contentReview.findMany({
    select: { bookSlug: true, chapter: true, verseNum: true, status: true },
  });

  const reviewMap: Record<string, string> = {};
  for (const r of reviews) {
    reviewMap[`${r.bookSlug}:${r.chapter}:${r.verseNum ?? ''}` ] = r.status;
  }

  // Build content status per book
  const bookStatuses = BIBLE_BOOKS.map(book => {
    let availableChapters = 0;
    try {
      const idx = getBookIndex(book.slug, 'en');
      availableChapters = idx.length;
    } catch {
      availableChapters = 0;
    }

    const bookReviews = reviews.filter(r => r.bookSlug === book.slug);
    const approved    = bookReviews.filter(r => r.status === 'approved').length;
    const flagged     = bookReviews.filter(r => r.status === 'flagged').length;

    return { ...book, availableChapters, approved, flagged, totalReviews: bookReviews.length };
  });

  const withContent = bookStatuses.filter(b => b.availableChapters > 0);
  const coming      = bookStatuses.filter(b => b.availableChapters === 0);

  return (
    <div className="p-8 max-w-6xl mx-auto w-full">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Content</h1>
          <p className="text-stone-500 text-sm mt-0.5">
            {withContent.length} books published · {coming.length} coming soon
          </p>
        </div>
        <Link
          href="/admin/reviews"
          className="bg-amber-500 hover:bg-amber-600 text-white font-semibold text-sm px-4 py-2.5 rounded-xl transition-colors"
        >
          Review Queue →
        </Link>
      </div>

      {/* Status legend */}
      <div className="flex items-center gap-3 mb-6 flex-wrap">
        {Object.entries(STATUS_LABELS).map(([key, label]) => (
          <span key={key} className={`text-xs font-semibold px-2.5 py-1 rounded-full ${STATUS_STYLES[key]}`}>
            {label}
          </span>
        ))}
      </div>

      {/* Books with content */}
      <div className="bg-white rounded-2xl border border-stone-200 overflow-hidden mb-6">
        <div className="px-5 py-3.5 border-b border-stone-100 bg-stone-50/50">
          <p className="text-xs font-bold text-stone-500 uppercase tracking-wider">Available Content</p>
        </div>
        <div className="divide-y divide-stone-50">
          {withContent.map(book => (
            <div key={book.slug} className="flex items-center gap-4 px-5 py-3.5 hover:bg-stone-50 transition-colors">
              <span className="text-lg shrink-0" aria-hidden="true">{book.emoji}</span>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 flex-wrap">
                  <p className="text-sm font-semibold text-stone-800">{book.name}</p>
                  <span className="text-xs text-stone-400">{book.testament === 'OT' ? 'OT' : 'NT'} · {book.group}</span>
                </div>
              </div>
              <div className="flex items-center gap-6 shrink-0 text-xs text-stone-500">
                <span>{book.availableChapters}/{book.totalChapters} ch</span>
                {book.flagged > 0 && (
                  <span className="text-red-600 font-semibold">{book.flagged} flagged</span>
                )}
                {book.approved > 0 && (
                  <span className="text-emerald-600 font-semibold">{book.approved} approved</span>
                )}
              </div>
              <Link
                href={`/${book.slug}/1`}
                target="_blank"
                className="text-xs text-amber-600 hover:text-amber-800 font-semibold shrink-0"
              >
                View →
              </Link>
            </div>
          ))}
        </div>
      </div>

      {/* Coming soon books */}
      <div className="bg-white rounded-2xl border border-stone-200 overflow-hidden">
        <div className="px-5 py-3.5 border-b border-stone-100 bg-stone-50/50">
          <p className="text-xs font-bold text-stone-500 uppercase tracking-wider">Coming Soon ({coming.length})</p>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-px bg-stone-100">
          {coming.map(book => (
            <div key={book.slug} className="bg-white px-4 py-3 text-center">
              <span className="text-xl" aria-hidden="true">{book.emoji}</span>
              <p className="text-xs font-semibold text-stone-500 mt-1 truncate">{book.name}</p>
              <p className="text-[10px] text-stone-300">{book.totalChapters} ch</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
