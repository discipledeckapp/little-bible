import type { Metadata } from 'next';
import { prisma } from '@/lib/prisma';
import Link from 'next/link';
import { getChapter } from '@/lib/content';
import { BIBLE_BOOKS } from '@/lib/bibleBooks';

export const metadata: Metadata = { title: 'Reviews' };

interface PageProps {
  searchParams: Promise<{ status?: string; book?: string }>;
}

const STATUS_STYLES: Record<string, string> = {
  pending:        'bg-stone-100 text-stone-600',
  approved:       'bg-emerald-100 text-emerald-700',
  needs_revision: 'bg-amber-100 text-amber-700',
  flagged:        'bg-red-100 text-red-700',
};

const CONCERN_LABELS: Record<string, string> = {
  theological:   '⚠ Theological',
  too_difficult: '📚 Too Difficult',
  language:      '💬 Language',
  other:         '• Other',
};

export default async function ReviewsPage({ searchParams }: PageProps) {
  const { status = 'pending', book = '' } = await searchParams;

  const where = {
    ...(status ? { status }         : {}),
    ...(book   ? { bookSlug: book } : {}),
  };

  const [reviews, counts] = await Promise.all([
    prisma.contentReview.findMany({
      where,
      orderBy: [{ status: 'asc' }, { createdAt: 'desc' }],
      take: 50,
    }),
    prisma.contentReview.groupBy({
      by: ['status'],
      _count: { id: true },
    }),
  ]);

  const statusCounts = Object.fromEntries(counts.map(c => [c.status, c._count.id]));

  const statusTabs = [
    { key: 'pending',        label: 'Pending',        count: statusCounts.pending ?? 0 },
    { key: 'flagged',        label: 'Flagged',        count: statusCounts.flagged ?? 0 },
    { key: 'needs_revision', label: 'Needs Revision', count: statusCounts.needs_revision ?? 0 },
    { key: 'approved',       label: 'Approved',       count: statusCounts.approved ?? 0 },
  ];

  return (
    <div className="p-8 max-w-6xl mx-auto w-full">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-stone-900">Content Reviews</h1>
        <p className="text-stone-500 text-sm mt-0.5">Review and approve verse adaptations</p>
      </div>

      {/* Status tabs */}
      <div className="flex gap-1 mb-6 bg-stone-100 p-1 rounded-xl w-fit">
        {statusTabs.map(tab => (
          <Link
            key={tab.key}
            href={`/admin/reviews?status=${tab.key}${book ? `&book=${book}` : ''}`}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold transition-colors ${
              status === tab.key
                ? 'bg-white text-stone-800 shadow-sm'
                : 'text-stone-500 hover:text-stone-700'
            }`}
          >
            {tab.label}
            {tab.count > 0 && (
              <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded-full ${
                tab.key === 'flagged'        ? 'bg-red-100 text-red-600' :
                tab.key === 'needs_revision' ? 'bg-amber-100 text-amber-700' :
                'bg-stone-200 text-stone-600'
              }`}>
                {tab.count}
              </span>
            )}
          </Link>
        ))}
      </div>

      {reviews.length === 0 ? (
        <div className="bg-white rounded-2xl border border-stone-200 p-12 text-center">
          <p className="text-4xl mb-3">✓</p>
          <p className="text-stone-600 font-semibold">No {status} reviews</p>
          <p className="text-stone-400 text-sm mt-1">All content in this category has been processed</p>
        </div>
      ) : (
        <div className="space-y-3">
          {reviews.map(review => {
            const bookMeta = BIBLE_BOOKS.find(b => b.slug === review.bookSlug);
            const chapterData = (() => {
              try { return getChapter(review.bookSlug, review.chapter, 'en'); } catch { return null; }
            })();
            const verse = review.verseNum
              ? chapterData?.verses.find(v => v.verse === review.verseNum)
              : null;

            return (
              <div key={review.id} className="bg-white rounded-2xl border border-stone-200 p-5">
                <div className="flex items-start justify-between gap-4 mb-3">
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-lg" aria-hidden="true">{bookMeta?.emoji ?? '📖'}</span>
                      <p className="text-sm font-bold text-stone-800">
                        {bookMeta?.name ?? review.bookSlug} {review.chapter}
                        {review.verseNum ? `:${review.verseNum}` : ''}
                      </p>
                      <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${STATUS_STYLES[review.status] ?? STATUS_STYLES.pending}`}>
                        {review.status.replace('_', ' ')}
                      </span>
                      {review.concern && (
                        <span className="text-[10px] font-semibold text-stone-400">
                          {CONCERN_LABELS[review.concern] ?? review.concern}
                        </span>
                      )}
                    </div>
                    <p className="text-xs text-stone-400">
                      {new Date(review.createdAt).toLocaleDateString('en-GB', {
                        day: 'numeric', month: 'short', year: 'numeric',
                      })}
                    </p>
                  </div>
                  <div className="flex gap-2 shrink-0">
                    <ApproveButton reviewId={review.id} />
                    <FlagButton reviewId={review.id} />
                  </div>
                </div>

                {/* Verse content preview */}
                {verse && (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-3 pt-3 border-t border-stone-50">
                    <div>
                      <p className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-1.5">KJV</p>
                      <p className="text-sm text-stone-600 leading-relaxed">{verse.kjv}</p>
                    </div>
                    <div>
                      <p className="text-[10px] font-bold text-amber-500 uppercase tracking-widest mb-1.5">Little Bible</p>
                      <p className="text-sm text-stone-800 leading-relaxed">{verse.little_bible}</p>
                    </div>
                  </div>
                )}

                {review.notes && (
                  <div className="mt-3 pt-3 border-t border-stone-50">
                    <p className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-1">Reviewer Notes</p>
                    <p className="text-sm text-stone-600">{review.notes}</p>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

// Client-interactive approve/flag buttons would need 'use client' — shown as static here
// In production, wrap in a client component with server action
function ApproveButton({ reviewId }: { reviewId: string }) {
  return (
    <button
      className="text-xs font-semibold px-3 py-1.5 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 rounded-lg transition-colors"
      title={`Approve review ${reviewId}`}
      disabled
    >
      ✓ Approve
    </button>
  );
}

function FlagButton({ reviewId }: { reviewId: string }) {
  return (
    <button
      className="text-xs font-semibold px-3 py-1.5 bg-red-50 text-red-600 hover:bg-red-100 rounded-lg transition-colors"
      title={`Flag review ${reviewId}`}
      disabled
    >
      ⚠ Flag
    </button>
  );
}
