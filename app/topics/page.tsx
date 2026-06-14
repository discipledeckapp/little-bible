import type { Metadata } from 'next';
import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import { getAllTopics } from '@/lib/topics';

export const metadata: Metadata = {
  title: 'Scriptures by Topic — Little Bible',
  description:
    'Explore 11 Bible topics with key verses, memory phrases, and family prayers — love, courage, faith, forgiveness, and more. Adapted for children ages 4–7.',
};

export default function TopicsPage() {
  const topics = getAllTopics();

  return (
    <div className="min-h-screen flex flex-col bg-[var(--color-background)]">
      <Header />

      {/* Hero */}
      <section className="bg-gradient-to-b from-amber-50 to-[var(--color-background)] border-b border-amber-100/60 px-4 pt-12 pb-10">
        <div className="max-w-5xl mx-auto text-center">
          <p className="text-xs font-bold text-amber-600 uppercase tracking-widest mb-3">
            Scriptures by Topic · Little Bible
          </p>
          <h1
            className="text-4xl sm:text-5xl font-bold text-stone-800 mb-3 leading-tight"
            style={{ fontFamily: 'var(--font-display)' }}
          >
            God&apos;s Word on Every Topic
          </h1>
          <p className="text-stone-500 text-base sm:text-lg max-w-md mx-auto leading-relaxed">
            Find the right verses for every season of life — verses your family can read, learn, and pray together.
          </p>

          {/* Stats row */}
          <div className="flex items-center justify-center gap-6 mt-6">
            <div className="text-center">
              <p className="text-2xl font-extrabold text-amber-600">{topics.length}</p>
              <p className="text-xs text-stone-400 font-semibold uppercase tracking-wide">Topics</p>
            </div>
            <div className="w-px h-8 bg-stone-200" />
            <div className="text-center">
              <p className="text-2xl font-extrabold text-amber-600">
                {topics.reduce((acc, t) => acc + t.verses.length, 0)}
              </p>
              <p className="text-xs text-stone-400 font-semibold uppercase tracking-wide">Verses</p>
            </div>
            <div className="w-px h-8 bg-stone-200" />
            <div className="text-center">
              <p className="text-2xl font-extrabold text-amber-600">4–7</p>
              <p className="text-xs text-stone-400 font-semibold uppercase tracking-wide">Ages</p>
            </div>
          </div>
        </div>
      </section>

      {/* Topics grid */}
      <main className="flex-1 px-4 py-12">
        <div className="max-w-5xl mx-auto">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {topics.map(topic => (
              <Link
                key={topic.id}
                href={`/topics/${topic.id}`}
                className="group block rounded-3xl shadow-sm border hover:shadow-lg transition-all duration-200 overflow-hidden focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
              >
                <div className={`${topic.colorLight} ${topic.colorBorder} border rounded-3xl p-6 h-full flex flex-col`}>
                  {/* Emoji + color dot */}
                  <div className="flex items-start justify-between mb-4">
                    <span
                      className={`text-4xl w-14 h-14 flex items-center justify-center rounded-2xl ${topic.color} text-white shadow-sm`}
                      aria-hidden="true"
                    >
                      {topic.emoji}
                    </span>
                    <span className={`text-xs font-bold uppercase tracking-wide ${topic.colorText} opacity-60 mt-1`}>
                      {topic.verses.length} verses
                    </span>
                  </div>

                  {/* Title */}
                  <h2 className={`text-xl font-bold ${topic.colorText} mb-2 group-hover:opacity-90 transition-opacity`}>
                    {topic.title}
                  </h2>

                  {/* Description */}
                  <p className="text-stone-600 text-sm leading-relaxed flex-1 line-clamp-3">
                    {topic.description}
                  </p>

                  {/* CTA */}
                  <div className="mt-4 pt-4 border-t border-stone-200/60 flex items-center justify-between">
                    <span className="text-xs text-stone-400 font-medium italic">
                      &ldquo;{topic.memory_phrase}&rdquo;
                    </span>
                    <span className={`text-sm font-bold ${topic.colorText} group-hover:translate-x-1 transition-transform inline-block`}>
                      Explore →
                    </span>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
