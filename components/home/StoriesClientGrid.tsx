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
  const [query, setQuery] = useState('');

  useEffect(() => {
    function loadProgress() {
      setProgress(getAllStoryProgress());
    }
    loadProgress();
    window.addEventListener('focus', loadProgress);
    return () => window.removeEventListener('focus', loadProgress);
  }, []);

  const storyMap = new Map<string, Story>(stories.map(s => [s.id, s]));

  // Search filter — matches title, subtitle, bibleRef, mainTruth
  const q = query.trim().toLowerCase();
  const filteredStories = q
    ? stories.filter(
        s =>
          s.title.toLowerCase().includes(q) ||
          s.subtitle.toLowerCase().includes(q) ||
          s.bibleRef.toLowerCase().includes(q) ||
          s.mainTruth.toLowerCase().includes(q)
      )
    : null; // null = show collections view

  return (
    <div>
      {/* Search bar */}
      <div className="relative mb-8">
        <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-stone-400 text-sm" aria-hidden="true">
          🔍
        </span>
        <input
          type="search"
          value={query}
          onChange={e => setQuery(e.target.value)}
          placeholder="Search stories by title, topic, or Bible reference…"
          className="w-full pl-10 pr-4 py-3 rounded-2xl border border-stone-200 bg-white text-stone-800 placeholder-stone-400 text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent transition-shadow"
          aria-label="Search Bible stories"
        />
        {query && (
          <button
            onClick={() => setQuery('')}
            className="absolute right-3.5 top-1/2 -translate-y-1/2 text-stone-400 hover:text-stone-600 text-lg leading-none"
            aria-label="Clear search"
          >
            ×
          </button>
        )}
      </div>

      {/* Search results */}
      {filteredStories !== null ? (
        filteredStories.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-3xl mb-3">🔍</p>
            <p className="text-stone-500 font-medium">No stories match &ldquo;{query}&rdquo;</p>
            <p className="text-stone-400 text-sm mt-1">Try a different word or Bible book name</p>
          </div>
        ) : (
          <div>
            <p className="text-xs text-stone-400 font-semibold uppercase tracking-widest mb-4">
              {filteredStories.length} result{filteredStories.length !== 1 ? 's' : ''}
            </p>
            <div className="flex flex-wrap gap-4">
              {filteredStories.map(story => (
                <StoryCard
                  key={story.id}
                  story={story}
                  status={(progress[story.id]?.status as StoryStatus) ?? 'unread'}
                  size="md"
                />
              ))}
            </div>
          </div>
        )
      ) : (
        /* Normal collections view */
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
      )}
    </div>
  );
}
