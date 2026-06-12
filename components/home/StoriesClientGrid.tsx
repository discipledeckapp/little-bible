'use client';

import { useEffect, useState } from 'react';
import type { Story, Collection, StoryStatus, StoryProgress } from '@/types';
import StoryCard from '@/components/stories/StoryCard';
import { getAllStoryProgress } from '@/lib/story-progress';

interface StoriesClientGridProps {
  collections: Collection[];
  stories: Story[];
}

export default function StoriesClientGrid({ collections, stories }: StoriesClientGridProps) {
  const [progress, setProgress] = useState<Record<string, StoryProgress>>({});

  useEffect(() => {
    // Read progress on mount and whenever the window gains focus
    function loadProgress() {
      setProgress(getAllStoryProgress());
    }
    loadProgress();
    window.addEventListener('focus', loadProgress);
    return () => window.removeEventListener('focus', loadProgress);
  }, []);

  const storyMap = new Map<string, Story>(stories.map(s => [s.id, s]));

  return (
    <div className="space-y-10">
      {collections.map(collection => {
        const collectionStories = collection.stories
          .map(id => storyMap.get(id))
          .filter(Boolean) as Story[];

        if (collectionStories.length === 0) return null;

        const completedInCollection = collectionStories.filter(
          s => ['complete', 'memorised'].includes(progress[s.id]?.status ?? 'unread')
        ).length;

        return (
          <div key={collection.id}>
            {/* Collection header */}
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
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
              {completedInCollection > 0 && (
                <span className="text-xs text-stone-400 shrink-0">
                  {completedInCollection}/{collectionStories.length}
                </span>
              )}
            </div>

            {/* Story cards row */}
            <div className="flex gap-4 overflow-x-auto pb-3 -mx-4 px-4 snap-x snap-mandatory">
              {collectionStories.map(story => (
                <div key={story.id} className="snap-start shrink-0">
                  <StoryCard
                    story={story}
                    status={(progress[story.id]?.status as StoryStatus) ?? 'unread'}
                    size="md"
                  />
                </div>
              ))}
            </div>
          </div>
        );
      })}
    </div>
  );
}
