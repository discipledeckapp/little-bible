import { notFound } from 'next/navigation';
import { Suspense } from 'react';
import Link from 'next/link';
import type { Metadata } from 'next';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import ChapterPageClient from '@/components/reader/ChapterPageClient';
import JsonLd from '@/components/seo/JsonLd';
import { getChapter, getLanguageIndex, getBookIndex } from '@/lib/content';
import { BIBLE_BOOKS } from '@/lib/bibleBooks';

interface PageProps {
  params: Promise<{ book: string; chapter: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { book, chapter } = await params;
  const chapterNum = parseInt(chapter, 10);
  const data = getChapter(book, chapterNum, 'en');
  if (!data) return {};

  const title = `${data.book} Chapter ${data.chapter} — Little Bible`;
  const description = data.main_lesson
    ? `${data.main_lesson} — ${data.book} ${data.chapter} faithfully adapted for children ages 4–7.`
    : `Read ${data.book} Chapter ${data.chapter} — every verse adapted for children ages 4–7 on Little Bible.`;
  const url = `https://littlebible.org/${book}/${chapter}`;

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      url,
      siteName: 'Little Bible',
      type: 'article',
    },
    twitter: {
      card: 'summary',
      title,
      description,
    },
    alternates: { canonical: url },
  };
}

export async function generateStaticParams() {
  try {
    const books = getLanguageIndex('en');
    const paths: { book: string; chapter: string }[] = [];
    for (const book of books) {
      const chapters = getBookIndex(book.slug, 'en');
      for (const ch of chapters) {
        paths.push({ book: book.slug, chapter: String(ch.chapter) });
      }
    }
    return paths;
  } catch {
    return [];
  }
}

export default async function ChapterPage({ params }: PageProps) {
  const { book: bookSlug, chapter: chapterStr } = await params;
  const chapterNum = parseInt(chapterStr, 10);
  if (isNaN(chapterNum)) notFound();

  const chapter = getChapter(bookSlug, chapterNum, 'en');
  if (!chapter) notFound();

  const bookMeta = BIBLE_BOOKS.find(b => b.slug === bookSlug);
  let availableChapters: number[] = [];
  try {
    const idx = getBookIndex(bookSlug, 'en');
    availableChapters = idx.map(c => c.chapter).sort((a, b) => a - b);
  } catch {
    availableChapters = [chapterNum];
  }
  const totalChapters = bookMeta?.totalChapters ?? chapterNum;
  const nextChapterNum = availableChapters.find(c => c > chapterNum);

  const chapterJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: `${chapter.book} Chapter ${chapter.chapter}`,
    description: chapter.main_lesson ?? undefined,
    url: `https://littlebible.org/${bookSlug}/${chapterNum}`,
    isPartOf: {
      '@type': 'Book',
      name: chapter.book,
      url: `https://littlebible.org/${bookSlug}`,
    },
    publisher: {
      '@type': 'Organization',
      name: 'Little Bible',
      url: 'https://littlebible.org',
    },
    inLanguage: 'en',
    audience: { '@type': 'Audience', audienceType: 'Children ages 4–7' },
  };

  return (
    <div className="min-h-screen flex flex-col">
      <JsonLd data={chapterJsonLd} />
      <Header />
      <main className="flex-1 max-w-3xl mx-auto w-full px-4 sm:px-6 py-8">
        {/* Back link — goes to book page, not home */}
        <Link
          href={`/${bookSlug}`}
          className="inline-flex items-center gap-1.5 text-sm text-amber-600 hover:text-amber-800 font-semibold mb-6 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded"
          aria-label={`Back to ${chapter.book}`}
        >
          ← {chapter.book}
        </Link>

        <Suspense fallback={
          <div className="flex justify-center py-12">
            <div className="w-8 h-8 border-4 border-amber-200 border-t-amber-500 rounded-full animate-spin" />
          </div>
        }>
          <ChapterPageClient
            chapter={chapter}
            bookSlug={bookSlug}
            availableChapters={availableChapters}
            totalChapters={totalChapters}
            nextChapterNum={nextChapterNum}
          />
        </Suspense>
      </main>
      <Footer />
    </div>
  );
}
