import Link from 'next/link';
import type { BookMeta } from '@/lib/content';
import {
  BIBLE_BOOKS,
  getBibleBooksByTestament,
  getGroupsForTestament,
  type BookStatus,
} from '@/lib/bibleBooks';

interface LibrarySectionProps {
  availableBooks: BookMeta[];
}

const STATUS_BADGE: Record<BookStatus, { label: string; classes: string; dot: string }> = {
  available:    { label: 'Available',   classes: 'bg-amber-100 text-amber-700 border-amber-200',    dot: 'bg-amber-500' },
  'in-progress':{ label: 'Coming Soon', classes: 'bg-emerald-50 text-emerald-600 border-emerald-200', dot: 'bg-emerald-400' },
  'coming-soon':{ label: 'Coming Soon', classes: 'bg-stone-100 text-stone-400 border-stone-200',    dot: 'bg-stone-300' },
};

const TESTAMENT_META = {
  OT: {
    label: 'Old Testament',
    count: 39,
    tagline: 'Creation, Exodus, Kings, Prophets — the story of God and His people',
    gradientFrom: 'from-amber-800',
    textColor: 'text-amber-800',
    bgSection: 'bg-[#FFFBF5]',
  },
  NT: {
    label: 'New Testament',
    count: 27,
    tagline: "Jesus, the early church, and the promise of God's kingdom",
    gradientFrom: 'from-emerald-800',
    textColor: 'text-emerald-800',
    bgSection: 'bg-emerald-50/30',
  },
};

export default function LibrarySection({ availableBooks }: LibrarySectionProps) {
  const availableSet = new Set(availableBooks.map((b) => b.slug));

  return (
    <section id="library" className="py-16 sm:py-24 px-4">
      <div className="max-w-5xl mx-auto">

        {/* Section header */}
        <div className="text-center mb-14">
          <p className="text-amber-500 text-xs font-bold uppercase tracking-[0.2em] mb-3">
            The Complete Bible
          </p>
          <h2 className="font-display text-3xl sm:text-4xl font-bold text-stone-800 mb-4 leading-tight">
            66 Books.<br className="sm:hidden" />
            <span className="text-amber-600"> Every verse. </span>
            One journey.
          </h2>
          <p className="text-stone-500 text-base max-w-md mx-auto leading-relaxed">
            Start with Proverbs. Grow through every book of Scripture.
            Little Bible is being built one faithful chapter at a time.
          </p>

          {/* Legend */}
          <div className="flex items-center justify-center gap-6 mt-6 flex-wrap">
            {Object.entries(STATUS_BADGE).map(([key, val]) => (
              <div key={key} className="flex items-center gap-1.5">
                <span className={`w-2 h-2 rounded-full ${val.dot}`} aria-hidden="true" />
                <span className="text-stone-500 text-xs font-medium">{val.label}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Old Testament */}
        <TestamentSection testament="OT" availableSet={availableSet} />

        {/* New Testament */}
        <div className="mt-16">
          <TestamentSection testament="NT" availableSet={availableSet} />
        </div>

      </div>
    </section>
  );
}

function TestamentSection({
  testament,
  availableSet,
}: {
  testament: 'OT' | 'NT';
  availableSet: Set<string>;
}) {
  const meta = TESTAMENT_META[testament];
  const books = getBibleBooksByTestament(testament);
  const groups = getGroupsForTestament(testament);

  return (
    <div>
      {/* Testament header */}
      <div className="flex items-center gap-4 mb-8">
        <div className="flex-1 h-px bg-stone-200" aria-hidden="true" />
        <div className="text-center px-2">
          <p className={`font-display font-bold text-xl ${meta.textColor}`}>
            {meta.label}
          </p>
          <p className="text-stone-400 text-xs font-medium mt-0.5">{meta.count} books</p>
        </div>
        <div className="flex-1 h-px bg-stone-200" aria-hidden="true" />
      </div>

      {/* Groups */}
      <div className="space-y-10">
        {groups.map((group) => {
          const groupBooks = books.filter((b) => b.group === group);
          return (
            <div key={group}>
              <p className="text-xs font-bold text-stone-400 uppercase tracking-[0.15em] mb-3">
                {group}
              </p>
              <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-2.5">
                {groupBooks.map((book) => {
                  const effectiveStatus: BookStatus = availableSet.has(book.slug)
                    ? 'available'
                    : book.status;
                  return (
                    <BookTile
                      key={book.slug}
                      book={book}
                      status={effectiveStatus}
                    />
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function BookTile({
  book,
  status,
}: {
  book: (typeof BIBLE_BOOKS)[number];
  status: BookStatus;
}) {
  const badge = STATUS_BADGE[status];
  const isAvailable = status === 'available';
  const isInProgress = status === 'in-progress';

  const inner = (
    <div
      className={`relative rounded-2xl border p-3 flex flex-col items-center gap-1.5 text-center transition-all h-full ${
        isAvailable
          ? 'bg-amber-50 border-amber-200 hover:border-amber-400 hover:shadow-md hover:shadow-amber-100 cursor-pointer group'
          : isInProgress
          ? 'bg-white border-stone-200 hover:border-emerald-200 cursor-pointer group'
          : 'bg-white border-stone-100 opacity-60'
      }`}
    >
      {/* Status dot */}
      <span
        className={`absolute top-2 right-2 w-2 h-2 rounded-full ${badge.dot}`}
        aria-hidden="true"
      />

      {/* Emoji */}
      <span
        className={`text-2xl leading-none transition-transform ${
          isAvailable || isInProgress ? 'group-hover:scale-110' : ''
        }`}
        aria-hidden="true"
      >
        {book.emoji}
      </span>

      {/* Name */}
      <p
        className={`font-extrabold text-xs leading-tight ${
          isAvailable
            ? 'text-amber-900'
            : isInProgress
            ? 'text-stone-700'
            : 'text-stone-400'
        }`}
      >
        {book.name}
      </p>

      {/* Available indicator */}
      {isAvailable && (
        <span className="text-amber-500 text-xs font-bold" aria-hidden="true">
          ✅
        </span>
      )}
      {isInProgress && (
        <span className="text-emerald-500 text-xs" aria-hidden="true">
          🌱
        </span>
      )}
    </div>
  );

  // All books link to their book page — available shows chapters, coming-soon shows placeholder
  return (
    <Link
      href={`/${book.slug}`}
      aria-label={`${book.name} — ${book.tagline}`}
      className={`block focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded-2xl ${
        !isAvailable && !isInProgress ? 'pointer-events-none' : ''
      }`}
      tabIndex={!isAvailable && !isInProgress ? -1 : undefined}
    >
      {inner}
    </Link>
  );
}
