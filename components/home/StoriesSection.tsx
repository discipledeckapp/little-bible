import { getAllCollections, getAllStories } from '@/lib/stories';
import StoriesClientGrid from './StoriesClientGrid';

export default async function StoriesSection() {
  const [collections, stories] = await Promise.all([
    getAllCollections(),
    getAllStories(),
  ]);

  if (collections.length === 0) return null;

  return (
    <section className="py-14 px-4 bg-[var(--color-background)]">
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-10">
          <p className="text-xs font-semibold text-amber-600 uppercase tracking-widest mb-2">
            Bible Stories
          </p>
          <h2
            className="text-3xl font-bold text-stone-800"
            style={{ fontFamily: 'var(--font-display)' }}
          >
            Stories from God&apos;s Word
          </h2>
          <p className="text-stone-500 mt-2 text-base max-w-sm mx-auto leading-relaxed">
            Each story is a window into the same great story — God rescuing the world He loves.
          </p>
        </div>
        <StoriesClientGrid collections={collections} stories={stories} />
      </div>
    </section>
  );
}
