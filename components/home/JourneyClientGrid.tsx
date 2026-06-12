'use client';

import { useEffect, useState } from 'react';
import type { Journey } from '@/types';
import JourneyCard from '@/components/stories/JourneyCard';
import { getAllStoryProgress } from '@/lib/story-progress';

interface JourneyClientGridProps {
  journeys: Journey[];
}

export default function JourneyClientGrid({ journeys }: JourneyClientGridProps) {
  const [completedMap, setCompletedMap] = useState<Record<string, number>>({});

  useEffect(() => {
    function loadProgress() {
      const allProgress = getAllStoryProgress();
      const map: Record<string, number> = {};
      journeys.forEach(journey => {
        const count = journey.stories.filter(
          storyId =>
            allProgress[storyId]?.status === 'complete' ||
            allProgress[storyId]?.status === 'memorised'
        ).length;
        map[journey.id] = count;
      });
      setCompletedMap(map);
    }
    loadProgress();
    window.addEventListener('focus', loadProgress);
    return () => window.removeEventListener('focus', loadProgress);
  }, [journeys]);

  return (
    <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
      {journeys.map((journey, i) => (
        <JourneyCard
          key={journey.id}
          journey={journey}
          completedStories={completedMap[journey.id] ?? 0}
          recommended={i === 0}
        />
      ))}
    </div>
  );
}
