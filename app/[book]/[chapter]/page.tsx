import { notFound } from 'next/navigation';
import Link from 'next/link';
import type { Metadata } from 'next';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import ChapterPageClient from '@/components/reader/ChapterPageClient';
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

  return (
    <div className="min-h-screen flex flex-col">
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

        <ChapterPageClient
          chapter={chapter}
          bookSlug={bookSlug}
          availableChapters={availableChapters}
          totalChapters={totalChapters}
          nextChapterNum={nextChapterNum}
        />
      </main>
      <Footer />
    </div>
  );
}
