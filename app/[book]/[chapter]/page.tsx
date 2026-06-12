import { notFound } from 'next/navigation';
import Link from 'next/link';
import type { Metadata } from 'next';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import ChapterPageClient from '@/components/reader/ChapterPageClient';
import { getChapter, getLanguageIndex, getBookIndex } from '@/lib/content';

interface PageProps {
  params: Promise<{ book: string; chapter: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { book, chapter } = await params;
  const chapterNum = parseInt(chapter, 10);
  const data = getChapter(book, chapterNum, 'en');
  if (!data) return {};
  return {
    title: `${data.book} ${data.chapter} — Little Bible`,
    description: data.main_lesson,
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

  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="flex-1 max-w-3xl mx-auto w-full px-4 sm:px-6 py-8">
        {/* Back link */}
        <Link
          href="/"
          className="inline-flex items-center gap-1.5 text-sm text-amber-600 hover:text-amber-800 font-semibold mb-8 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded"
          aria-label="Back to book library"
        >
          ← Back to Library
        </Link>

        <ChapterPageClient chapter={chapter} bookSlug={bookSlug} />
      </main>
      <Footer />
    </div>
  );
}
