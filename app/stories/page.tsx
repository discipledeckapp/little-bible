import type { Metadata } from 'next';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import { getAllCollections, getAllStories } from '@/lib/stories';
import StoriesClientGrid from '@/components/home/StoriesClientGrid';

export const metadata: Metadata = {
  title: 'Bible Stories — Little Bible',
  description:
    'Explore 22 Bible stories organized by collection — from Creation to the Cross. Each story faithfully adapted for children ages 4–7.',
};

export default async function StoriesPage() {
  const [collections, stories] = await Promise.all([
    getAllCollections(),
    getAllStories(),
  ]);

  const totalStories = stories.length;
  const totalCollections = collections.length;

  return (
    <div className="min-h-screen flex flex-col bg-[var(--color-background)]">
      <Header />

      {/* Hero */}
      <section className="bg-gradient-to-b from-amber-50 to-[var(--color-background)] border-b border-amber-100/60 px-4 pt-12 pb-10">
        <div className="max-w-5xl mx-auto text-center">
          <p className="text-xs font-bold text-amber-600 uppercase tracking-widest mb-3">
            Bible Stories · Little Bible
          </p>
          <h1
            className="text-4xl sm:text-5xl font-bold text-stone-800 mb-3 leading-tight"
            style={{ fontFamily: 'var(--font-display)' }}
          >
            Stories from God&apos;s Word
          </h1>
          <p className="text-stone-500 text-base sm:text-lg max-w-md mx-auto leading-relaxed">
            Each story is a window into the same great story — God rescuing the world He loves.
          </p>

          {/* Stats row */}
          <div className="flex items-center justify-center gap-6 mt-6">
            <div className="text-center">
              <p className="text-2xl font-extrabold text-amber-600">{totalStories}</p>
              <p className="text-xs text-stone-400 font-semibold uppercase tracking-wide">Stories</p>
            </div>
            <div className="w-px h-8 bg-stone-200" />
            <div className="text-center">
              <p className="text-2xl font-extrabold text-amber-600">{totalCollections}</p>
              <p className="text-xs text-stone-400 font-semibold uppercase tracking-wide">Collections</p>
            </div>
            <div className="w-px h-8 bg-stone-200" />
            <div className="text-center">
              <p className="text-2xl font-extrabold text-amber-600">4–7</p>
              <p className="text-xs text-stone-400 font-semibold uppercase tracking-wide">Ages</p>
            </div>
          </div>
        </div>
      </section>

      {/* Stories grid */}
      <main className="flex-1 px-4 py-12">
        <div className="max-w-5xl mx-auto">
          <StoriesClientGrid collections={collections} stories={stories} />
        </div>
      </main>

      <Footer />
    </div>
  );
}
