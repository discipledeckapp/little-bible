import { notFound } from 'next/navigation';
import Link from 'next/link';
import type { Metadata } from 'next';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import { BIBLE_BOOKS } from '@/lib/bibleBooks';
import { getBookIndex } from '@/lib/content';
import LumiMascot from '@/components/mascot/LumiMascot';

interface PageProps {
  params: Promise<{ book: string }>;
}

export async function generateStaticParams() {
  return BIBLE_BOOKS.map((b) => ({ book: b.slug }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { book: slug } = await params;
  const bookMeta = BIBLE_BOOKS.find((b) => b.slug === slug);
  if (!bookMeta) return {};

  const testament = bookMeta.testament === 'OT' ? 'Old Testament' : 'New Testament';
  const description = `${bookMeta.tagline} — ${bookMeta.name} is a ${testament} book with ${bookMeta.totalChapters} chapters, faithfully adapted for children ages 4–7.`;

  return {
    title: `${bookMeta.name} — Little Bible`,
    description,
    openGraph: {
      title: `${bookMeta.name} — Little Bible`,
      description,
      url: `https://littlebible.org/${slug}`,
      siteName: 'Little Bible',
      type: 'website',
    },
    twitter: {
      card: 'summary',
      title: `${bookMeta.name} — Little Bible`,
      description,
    },
    alternates: { canonical: `https://littlebible.org/${slug}` },
  };
}

export default async function BookPage({ params }: PageProps) {
  const { book: slug } = await params;
  const bookMeta = BIBLE_BOOKS.find((b) => b.slug === slug);
  if (!bookMeta) notFound();

  // Try to load available chapter index — gracefully fails for coming-soon books
  let availableChapterNums: number[] = [];
  try {
    const index = getBookIndex(slug, 'en');
    availableChapterNums = index.map((c) => c.chapter);
  } catch {
    // No data yet
  }

  const isAvailable    = availableChapterNums.length > 0;
  const totalChapters  = bookMeta.totalChapters;
  const availableCount = availableChapterNums.length;

  return (
    <div className="min-h-screen flex flex-col">
      <Header />

      <main className="flex-1">

        {/* Book hero */}
        <section
          className={`py-12 sm:py-16 px-4 ${
            isAvailable
              ? 'bg-gradient-to-b from-amber-950 via-amber-900 to-amber-800'
              : 'bg-gradient-to-b from-stone-800 via-stone-700 to-stone-600'
          }`}
        >
          <div className="max-w-3xl mx-auto">
            <Link
              href="/#library"
              className="inline-flex items-center gap-1.5 text-sm font-semibold mb-8 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-white/50 rounded text-white/60 hover:text-white"
              aria-label="Back to Bible Library"
            >
              ← All Books
            </Link>

            <div className="flex flex-col sm:flex-row items-start sm:items-center gap-6">
              {/* Mascot */}
              <div className="flex-shrink-0">
                {isAvailable ? (
                  <LumiMascot stage="seed" className="w-20 h-20 sm:w-24 sm:h-24" />
                ) : (
                  <div className="w-20 h-20 sm:w-24 sm:h-24 bg-white/10 rounded-3xl flex items-center justify-center text-5xl">
                    {bookMeta.emoji}
                  </div>
                )}
              </div>

              <div>
                <p className="text-amber-300/70 text-xs font-bold uppercase tracking-[0.2em] mb-1">
                  {bookMeta.testament === 'OT' ? 'Old Testament' : 'New Testament'} · {bookMeta.group}
                </p>
                <h1 className="font-display text-4xl sm:text-5xl font-bold text-white mb-2">
                  {bookMeta.name}
                </h1>
                <p className="text-white/70 text-lg leading-relaxed max-w-xl">
                  {bookMeta.tagline}
                </p>

                <div className="flex items-center gap-3 mt-4 flex-wrap">
                  <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">
                    {totalChapters} {totalChapters === 1 ? 'chapter' : 'chapters'}
                  </span>
                  {isAvailable ? (
                    <span className="bg-amber-400 text-amber-950 text-xs font-extrabold px-3 py-1.5 rounded-full">
                      ✅ {availableCount} chapter{availableCount !== 1 ? 's' : ''} available
                    </span>
                  ) : (
                    <span className="bg-white/15 text-white/80 text-xs font-bold px-3 py-1.5 rounded-full">
                      🌱 Coming Soon
                    </span>
                  )}
                </div>
              </div>
            </div>
          </div>
        </section>

        <div className="max-w-3xl mx-auto px-4 py-10">

          {isAvailable ? (
            <>
              {/* Chapter grid */}
              <div className="mb-8">
                <h2 className="font-display text-xl font-bold text-stone-800 mb-5">
                  Chapters
                </h2>
                <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-2.5">
                  {Array.from({ length: totalChapters }, (_, i) => i + 1).map((ch) => {
                    const hasData = availableChapterNums.includes(ch);
                    return hasData ? (
                      <Link
                        key={ch}
                        href={`/${slug}/${ch}`}
                        className="group flex flex-col items-center gap-1.5 p-3 bg-amber-50 hover:bg-amber-100 border border-amber-200 hover:border-amber-400 rounded-2xl transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 active:scale-95"
                        aria-label={`Read ${bookMeta.name} chapter ${ch}`}
                      >
                        <span className="font-extrabold text-amber-800 text-lg leading-none">{ch}</span>
                        <span className="text-amber-500 text-[10px] font-bold uppercase tracking-wide">Read</span>
                      </Link>
                    ) : (
                      <div
                        key={ch}
                        className="flex flex-col items-center gap-1.5 p-3 bg-white border border-stone-100 rounded-2xl opacity-50"
                        aria-label={`Chapter ${ch} — Coming Soon`}
                      >
                        <span className="font-extrabold text-stone-400 text-lg leading-none">{ch}</span>
                        <span className="text-stone-300 text-[10px] font-bold uppercase tracking-wide">Soon</span>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Start reading CTA */}
              <div className="bg-amber-50 rounded-3xl p-6 border border-amber-100 text-center">
                <p className="text-amber-700 text-sm font-semibold mb-4">
                  Begin with chapter 1 — every verse faithfully adapted for little hearts.
                </p>
                <Link
                  href={`/${slug}/1`}
                  className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-7 py-3.5 rounded-2xl transition-all active:scale-95 shadow-sm"
                >
                  <span aria-hidden="true">📖</span>
                  Start Reading
                  <span aria-hidden="true">→</span>
                </Link>
              </div>
            </>
          ) : (
            /* Coming soon state */
            <div className="text-center py-12">
              <div className="text-7xl mb-4" aria-hidden="true">{bookMeta.emoji}</div>
              <h2 className="font-display text-2xl font-bold text-stone-800 mb-3">
                {bookMeta.name} is coming soon
              </h2>
              <p className="text-stone-500 text-base max-w-md mx-auto mb-3 leading-relaxed">
                {bookMeta.tagline}
              </p>
              <p className="text-stone-400 text-sm max-w-sm mx-auto mb-8">
                We are working through all 66 books of Scripture, one faithful chapter at a time.
                Start your journey with what&apos;s available today.
              </p>

              <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
                <Link
                  href="/proverbs/1"
                  className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-7 py-3.5 rounded-2xl transition-all active:scale-95 shadow-sm"
                >
                  <span aria-hidden="true">✨</span>
                  Start with Proverbs
                </Link>
                <Link
                  href="/#library"
                  className="inline-flex items-center gap-2 text-stone-600 hover:text-stone-800 font-semibold px-7 py-3.5 rounded-2xl border border-stone-200 hover:border-stone-300 transition-all"
                >
                  ← Back to Library
                </Link>
              </div>

              {/* Bible context */}
              <div className="mt-12 bg-stone-50 rounded-3xl p-6 border border-stone-100 max-w-md mx-auto text-left">
                <p className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-2">About this Book</p>
                <p className="text-stone-600 text-sm leading-relaxed">
                  <strong>{bookMeta.name}</strong> is in the {bookMeta.group} of the{' '}
                  {bookMeta.testament === 'OT' ? 'Old' : 'New'} Testament.
                  It has {totalChapters} {totalChapters === 1 ? 'chapter' : 'chapters'}.
                </p>
                <p className="text-amber-600 text-sm leading-relaxed mt-2">
                  {bookMeta.tagline}
                </p>
              </div>
            </div>
          )}

        </div>
      </main>

      <Footer />
    </div>
  );
}
