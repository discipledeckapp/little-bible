import { notFound } from 'next/navigation';
import type { Metadata } from 'next';
import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import { getAllTopics, getTopicById } from '@/lib/topics';

interface PageProps {
  params: Promise<{ slug: string }>;
}

export async function generateStaticParams() {
  const topics = getAllTopics();
  return topics.map(t => ({ slug: t.id }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const topic = getTopicById(slug);
  if (!topic) return { title: 'Topic — Little Bible' };

  const title = `${topic.title} — Scriptures by Topic · Little Bible`;
  const description = `${topic.description} Key verses, a memory verse, family prayer, and a do-it-today challenge.`;
  const url = `https://littlebible.org/topics/${slug}`;

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

export default async function TopicPage({ params }: PageProps) {
  const { slug } = await params;
  const topic = getTopicById(slug);
  if (!topic) notFound();

  const allTopics = getAllTopics();
  const currentIndex = allTopics.findIndex(t => t.id === slug);
  const prevTopic = currentIndex > 0 ? allTopics[currentIndex - 1] : null;
  const nextTopic = currentIndex < allTopics.length - 1 ? allTopics[currentIndex + 1] : null;

  return (
    <div className="min-h-screen flex flex-col bg-[var(--color-background)]">
      <Header />

      <main className="flex-1">

        {/* ── 1. Hero ───────────────────────────────────────────────── */}
        <section className={`${topic.colorLight} border-b ${topic.colorBorder} px-4 pt-12 pb-10`}>
          <div className="max-w-3xl mx-auto text-center">
            <Link
              href="/topics"
              className="inline-flex items-center gap-1.5 text-xs font-semibold text-stone-500 hover:text-stone-700 uppercase tracking-widest mb-6 transition-colors"
            >
              ← All Topics
            </Link>

            <div
              className={`text-6xl sm:text-7xl mx-auto mb-5 w-24 h-24 flex items-center justify-center rounded-3xl ${topic.color} shadow-lg`}
              aria-hidden="true"
            >
              {topic.emoji}
            </div>

            <h1
              className={`text-4xl sm:text-5xl font-bold ${topic.colorText} mb-3 leading-tight`}
              style={{ fontFamily: 'var(--font-display)' }}
            >
              {topic.title}
            </h1>

            <p className="text-stone-600 text-base sm:text-lg max-w-xl mx-auto leading-relaxed">
              {topic.description}
            </p>
          </div>
        </section>

        <div className="max-w-3xl mx-auto px-4 py-10 space-y-10">

          {/* ── 2. Key Verses ─────────────────────────────────────────── */}
          <section>
            <h2
              className="text-2xl font-bold text-stone-800 mb-5"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              Key Verses
            </h2>
            <div className="space-y-4">
              {topic.verses.map(verse => (
                <div
                  key={verse.ref}
                  className="bg-white rounded-3xl shadow-sm border border-stone-100 overflow-hidden"
                >
                  {/* Ref badge + chapter link */}
                  <div className="px-5 pt-5 pb-3 flex items-center justify-between gap-3">
                    <Link
                      href={`/${verse.book_slug}/${verse.chapter}`}
                      className={`inline-flex items-center gap-1.5 text-xs font-bold uppercase tracking-wide px-3 py-1.5 rounded-full ${topic.colorLight} ${topic.colorText} hover:opacity-80 transition-opacity`}
                    >
                      {verse.ref}
                      <span aria-hidden="true">↗</span>
                    </Link>
                    <span className="text-xs text-stone-400 font-medium">KJV</span>
                  </div>

                  {/* KJV text — subtle, smaller */}
                  <div className="px-5 pb-3">
                    <p className="text-stone-400 text-xs leading-relaxed italic border-l-2 border-stone-100 pl-3">
                      {verse.kjv}
                    </p>
                  </div>

                  {/* Little Bible text — prominent */}
                  <div className="px-5 pb-4">
                    <p className="text-stone-700 text-base sm:text-lg leading-relaxed font-medium">
                      {verse.little_bible}
                    </p>
                  </div>

                  {/* Memory phrase chip */}
                  <div className="px-5 pb-5">
                    <span className="inline-flex items-center gap-1.5 bg-amber-50 text-amber-700 text-xs font-bold px-3 py-1.5 rounded-full border border-amber-100">
                      <span aria-hidden="true">⭐</span>
                      {verse.memory_phrase}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* ── 3. Memory Verse ───────────────────────────────────────── */}
          <section>
            <h2
              className="text-2xl font-bold text-stone-800 mb-5"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              Memory Verse
            </h2>
            <div className={`${topic.colorLight} ${topic.colorBorder} border rounded-3xl p-6 sm:p-8`}>
              <div className="flex items-start gap-3 mb-4">
                <span className={`text-xs font-bold uppercase tracking-wide px-3 py-1.5 rounded-full ${topic.color} text-white`}>
                  {topic.memory_verse.ref}
                </span>
              </div>
              <p className="text-stone-400 text-xs leading-relaxed italic mb-4 border-l-2 border-stone-200 pl-3">
                {topic.memory_verse.kjv}
              </p>
              <p className={`text-xl sm:text-2xl font-bold ${topic.colorText} leading-snug mb-5`}>
                &ldquo;{topic.memory_verse.little_bible}&rdquo;
              </p>
              <div className="flex items-center gap-2">
                <span className="bg-amber-400 text-white text-xs font-bold px-3 py-1.5 rounded-full">
                  Memory Phrase
                </span>
                <span className="text-stone-700 font-semibold text-sm">
                  {topic.memory_phrase}
                </span>
              </div>
            </div>
          </section>

          {/* ── 4. Family Prayer ──────────────────────────────────────── */}
          <section>
            <h2
              className="text-2xl font-bold text-stone-800 mb-5"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              Family Prayer
            </h2>
            <div className="bg-sky-50 border border-sky-100 rounded-3xl p-6 sm:p-8">
              <div className="flex items-center gap-2 mb-4">
                <span className="text-sky-400 text-xl" aria-hidden="true">🙏</span>
                <span className="text-xs font-bold uppercase tracking-wide text-sky-600">Pray Together</span>
              </div>
              <p className="text-stone-700 text-base sm:text-lg leading-relaxed">
                {topic.prayer}
              </p>
            </div>
          </section>

          {/* ── 5. Do It Today ────────────────────────────────────────── */}
          <section>
            <h2
              className="text-2xl font-bold text-stone-800 mb-5"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              Do It Today
            </h2>
            <div className="bg-amber-400 rounded-3xl p-6 sm:p-8 shadow-sm">
              <div className="flex items-center gap-2 mb-3">
                <span className="text-white text-xl" aria-hidden="true">✅</span>
                <span className="text-xs font-bold uppercase tracking-wide text-amber-100">Family Challenge</span>
              </div>
              <p className="text-white text-base sm:text-lg font-semibold leading-relaxed">
                {topic.do_it_today}
              </p>
            </div>
          </section>

          {/* ── 6. Parent Note (collapsible) ──────────────────────────── */}
          <section>
            <details className="group bg-stone-50 border border-stone-200 rounded-3xl overflow-hidden">
              <summary className="flex items-center justify-between gap-3 px-6 py-5 cursor-pointer list-none select-none">
                <div className="flex items-center gap-2.5">
                  <span className="text-stone-400 text-lg" aria-hidden="true">👨‍👩‍👧</span>
                  <h2
                    className="text-lg font-bold text-stone-700"
                    style={{ fontFamily: 'var(--font-display)' }}
                  >
                    Note for Parents
                  </h2>
                </div>
                <span className="text-stone-400 text-sm font-medium group-open:hidden">Show</span>
                <span className="text-stone-400 text-sm font-medium hidden group-open:block">Hide</span>
              </summary>
              <div className="px-6 pb-6 pt-1">
                <p className="text-stone-600 text-sm sm:text-base leading-relaxed">
                  {topic.parent_note}
                </p>
              </div>
            </details>
          </section>

          {/* ── Navigation ────────────────────────────────────────────── */}
          <nav className="flex items-center justify-between pt-4 border-t border-stone-100 gap-4">
            {prevTopic ? (
              <Link
                href={`/topics/${prevTopic.id}`}
                className="flex items-center gap-2 text-stone-500 hover:text-stone-800 font-semibold text-sm transition-colors group"
              >
                <span className="group-hover:-translate-x-0.5 transition-transform" aria-hidden="true">←</span>
                <span>{prevTopic.emoji} {prevTopic.title}</span>
              </Link>
            ) : (
              <div />
            )}

            <Link
              href="/topics"
              className="text-xs font-bold text-amber-600 hover:text-amber-800 uppercase tracking-wide transition-colors"
            >
              All Topics
            </Link>

            {nextTopic ? (
              <Link
                href={`/topics/${nextTopic.id}`}
                className="flex items-center gap-2 text-stone-500 hover:text-stone-800 font-semibold text-sm transition-colors group"
              >
                <span>{nextTopic.emoji} {nextTopic.title}</span>
                <span className="group-hover:translate-x-0.5 transition-transform" aria-hidden="true">→</span>
              </Link>
            ) : (
              <div />
            )}
          </nav>

        </div>
      </main>

      <Footer />
    </div>
  );
}
