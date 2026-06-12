import { getAllCollections, getAllStories } from '@/lib/stories';
import CollectionCard from '@/components/stories/CollectionCard';
import StoryCard from '@/components/stories/StoryCard';
import { Story } from '@/types';

export default async function StoriesSection() {
  const [collections, stories] = await Promise.all([
    getAllCollections(),
    getAllStories(),
  ]);

  const storyMap = new Map<string, Story>(stories.map(s => [s.id, s]));

  if (collections.length === 0) return null;

  return (
    <section className="py-14 px-4 bg-[var(--color-background)]">
      <div className="max-w-5xl mx-auto">
        {/* Section header */}
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

        {/* Collections */}
        <div className="space-y-10">
          {collections.map(collection => {
            const collectionStories = collection.stories
              .map(id => storyMap.get(id))
              .filter(Boolean) as Story[];

            if (collectionStories.length === 0) return null;

            return (
              <div key={collection.id}>
                {/* Collection header */}
                <div className="flex items-center gap-3 mb-4">
                  <span className="text-2xl">{collection.emoji}</span>
                  <div>
                    <h3
                      className="font-bold text-stone-800 text-lg leading-tight"
                      style={{ fontFamily: 'var(--font-display)' }}
                    >
                      {collection.title}
                    </h3>
                    <p className="text-stone-400 text-xs">{collection.subtitle}</p>
                  </div>
                </div>

                {/* Story cards row */}
                <div className="flex gap-4 overflow-x-auto pb-3 -mx-4 px-4 snap-x snap-mandatory scrollbar-hide">
                  {collectionStories.map(story => (
                    <div key={story.id} className="snap-start shrink-0">
                      <StoryCard story={story} size="md" />
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
