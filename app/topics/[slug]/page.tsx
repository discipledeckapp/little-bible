import { notFound } from 'next/navigation';
import type { Metadata } from 'next';
import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import JsonLd from '@/components/seo/JsonLd';
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

  const title = `${topic.title} — Scripture Topic · Little Bible`;
  const description = `${topic.child_intro} Key verses, Bible stories, a memory verse, family prayer, and a do-it-today challenge. Ages 4–7.`;
  const url = `https://littlebible.org/topics/${slug}`;

  return {
    title,
    description,
    openGraph: { title, description, url, siteName: 'Little Bible', type: 'article' },
    twitter: { card: 'summary', title, description },
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

  const url = `https://littlebible.org/topics/${slug}`;
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: `${topic.title} — Scripture Topic · Little Bible`,
    description: `${topic.child_intro} Ages 4–7.`,
    url,
    publisher: {
      '@type': 'Organization',
      name: 'Little Bible',
      url: 'https://littlebible.org',
      logo: { '@type': 'ImageObject', url: 'https://littlebible.org/icon' },
    },
    mainEntityOfPage: { '@type': 'WebPage', '@id': url },
  };

  const featuredVerses = topic.verses.slice(0, 2);
  const moreVerses = topic.verses.slice(2);

  return (
    <div className="min-h-screen flex flex-col bg-[var(--color-background)]">
      <JsonLd data={jsonLd} />
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

          {/* ── 2. Child Intro ────────────────────────────────────────── */}
          <section>
            <div className={`${topic.colorLight} ${topic.colorBorder} border-l-4 rounded-2xl px-6 py-5 flex items-start gap-4`}>
              <span className="text-3xl shrink-0 mt-0.5" aria-hidden="true">{topic.emoji}</span>
              <div>
                <p className={`text-xs font-bold uppercase tracking-widest ${topic.colorText} mb-1.5`}>
                  For young readers
                </p>
                <p className="text-stone-800 text-base sm:text-lg leading-relaxed font-medium">
                  {topic.child_intro}
                </p>
              </div>
            </div>
          </section>

          {/* ── 3. Featured Bible Stories ─────────────────────────────── */}
          {topic.stories.length > 0 && (
            <section>
              <h2
                className="text-2xl font-bold text-stone-800 mb-2"
                style={{ fontFamily: 'var(--font-display)' }}
              >
                Bible Stories about {topic.title}
              </h2>
              <p className="text-stone-500 text-sm mb-5">
                Read these stories with your family to see {topic.title.toLowerCase()} in action.
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                {topic.stories.map(story => (
                  <Link
                    key={story.id}
                    href={`/stories/${story.id}`}
                    className="group flex flex-col items-center gap-2 bg-white border border-stone-100 hover:border-stone-200 rounded-2xl p-4 text-center shadow-sm hover:shadow-md transition-all duration-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
                  >
                    <span className="text-3xl" aria-hidden="true">{story.emoji}</span>
                    <p className="text-xs font-bold text-stone-700 leading-tight group-hover:text-stone-900 transition-colors">
                      {story.title}
                    </p>
                    <span className={`text-[10px] font-bold uppercase tracking-wide ${topic.colorText} opacity-70`}>
                      Read →
                    </span>
                  </Link>
                ))}
              </div>
            </section>
          )}

          {/* ── 4. Key Verses ─────────────────────────────────────────── */}
          <section>
            <h2
              className="text-2xl font-bold text-stone-800 mb-2"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              Key Verses
            </h2>
            <p className="text-stone-500 text-sm mb-5">
              What the Bible says about {topic.title.toLowerCase()}, in words your child can understand.
            </p>
            <div className="space-y-4">
              {featuredVerses.map(verse => (
                <VerseCard key={verse.ref} verse={verse} topic={topic} />
              ))}
            </div>

            {moreVerses.length > 0 && (
              <details className="mt-4 group">
                <summary className="cursor-pointer list-none">
                  <span className={`inline-flex items-center gap-1.5 text-xs font-bold uppercase tracking-wide ${topic.colorText} hover:opacity-70 transition-opacity`}>
                    <span className="group-open:hidden">+ Show {moreVerses.length} more verse{moreVerses.length > 1 ? 's' : ''}</span>
                    <span className="hidden group-open:inline">− Show fewer verses</span>
                  </span>
                </summary>
                <div className="space-y-4 mt-4">
                  {moreVerses.map(verse => (
                    <VerseCard key={verse.ref} verse={verse} topic={topic} />
                  ))}
                </div>
              </details>
            )}
          </section>

          {/* ── 5. Memory Verse ───────────────────────────────────────── */}
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
                <span className="text-xs font-semibold text-stone-400 mt-1">Learn this verse</span>
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
                <span className="text-stone-700 font-semibold text-sm italic">
                  &ldquo;{topic.memory_phrase}&rdquo;
                </span>
              </div>
            </div>
          </section>

          {/* ── 6. Family Prayer ──────────────────────────────────────── */}
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

          {/* ── 7. Do It Today ────────────────────────────────────────── */}
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

          {/* ── 8. Related Bible Reading ──────────────────────────────── */}
          {topic.related_reading.length > 0 && (
            <section>
              <h2
                className="text-2xl font-bold text-stone-800 mb-2"
                style={{ fontFamily: 'var(--font-display)' }}
              >
                Read More in the Bible
              </h2>
              <p className="text-stone-500 text-sm mb-5">
                Explore these Bible chapters to go deeper on {topic.title.toLowerCase()}.
              </p>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                {topic.related_reading.map(reading => (
                  <Link
                    key={`${reading.book_slug}-${reading.chapter}`}
                    href={`/${reading.book_slug}/${reading.chapter}`}
                    className="group flex items-center gap-3 bg-white border border-stone-100 hover:border-stone-200 rounded-2xl px-4 py-3.5 shadow-sm hover:shadow-md transition-all duration-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
                  >
                    <span className="text-xl shrink-0" aria-hidden="true">📖</span>
                    <p className="text-sm font-semibold text-stone-700 group-hover:text-stone-900 leading-tight flex-1">
                      {reading.label}
                    </p>
                    <span className={`text-xs font-bold ${topic.colorText} shrink-0 group-hover:translate-x-0.5 transition-transform`} aria-hidden="true">
                      →
                    </span>
                  </Link>
                ))}
              </div>
            </section>
          )}

          {/* ── 9. Family Guide (collapsible) ─────────────────────────── */}
          <section>
            <details className="group bg-stone-50 border border-stone-200 rounded-3xl overflow-hidden">
              <summary className="flex items-center justify-between gap-3 px-6 py-5 cursor-pointer list-none select-none">
                <div className="flex items-center gap-2.5">
                  <span className="text-stone-400 text-lg" aria-hidden="true">👨‍👩‍👧</span>
                  <h2
                    className="text-lg font-bold text-stone-700"
                    style={{ fontFamily: 'var(--font-display)' }}
                  >
                    Family Discussion Guide
                  </h2>
                </div>
                <span className="text-stone-400 text-sm font-medium group-open:hidden">Show</span>
                <span className="text-stone-400 text-sm font-medium hidden group-open:block">Hide</span>
              </summary>
              <div className="px-6 pb-6 pt-2 space-y-5">

                {/* Discussion prompts */}
                {topic.discussion_prompts.length > 0 && (
                  <div>
                    <p className="text-xs font-bold uppercase tracking-widest text-stone-400 mb-3">
                      Talk About It
                    </p>
                    <ul className="space-y-2.5">
                      {topic.discussion_prompts.map((prompt, i) => (
                        <li key={i} className="flex items-start gap-2.5">
                          <span className={`text-xs font-extrabold ${topic.colorText} shrink-0 mt-0.5`}>
                            {i + 1}.
                          </span>
                          <p className="text-stone-600 text-sm leading-relaxed">{prompt}</p>
                        </li>
                      ))}
                    </ul>
                  </div>
                )}

                {/* Parent note */}
                <div>
                  <p className="text-xs font-bold uppercase tracking-widest text-stone-400 mb-3">
                    Note for Parents
                  </p>
                  <p className="text-stone-600 text-sm sm:text-base leading-relaxed">
                    {topic.parent_note}
                  </p>
                </div>
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

function VerseCard({
  verse,
  topic,
}: {
  verse: { ref: string; book_slug: string; chapter: number; kjv: string; little_bible: string; memory_phrase: string };
  topic: { colorLight: string; colorText: string; colorBorder: string };
}) {
  return (
    <div className="bg-white rounded-3xl shadow-sm border border-stone-100 overflow-hidden">
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

      <div className="px-5 pb-3">
        <p className="text-stone-400 text-xs leading-relaxed italic border-l-2 border-stone-100 pl-3">
          {verse.kjv}
        </p>
      </div>

      <div className="px-5 pb-4">
        <p className="text-stone-700 text-base sm:text-lg leading-relaxed font-medium">
          {verse.little_bible}
        </p>
      </div>

      <div className="px-5 pb-5">
        <span className="inline-flex items-center gap-1.5 bg-amber-50 text-amber-700 text-xs font-bold px-3 py-1.5 rounded-full border border-amber-100">
          <span aria-hidden="true">⭐</span>
          {verse.memory_phrase}
        </span>
      </div>
    </div>
  );
}
