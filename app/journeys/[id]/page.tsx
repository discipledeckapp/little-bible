import { notFound } from 'next/navigation';
import { getJourney, getStory } from '@/lib/stories';
import type { Metadata } from 'next';
import JourneyDetailClient from '@/components/journey/JourneyDetailClient';

interface Props {
  params: Promise<{ id: string }>;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params;
  const journey = await getJourney(id);
  if (!journey) return { title: 'Journey not found' };
  return {
    title: `${journey.name} — Little Bible`,
    description: journey.subtitle,
  };
}

export default async function JourneyPage({ params }: Props) {
  const { id } = await params;
  const journey = await getJourney(id);
  if (!journey) notFound();

  // Load story metadata for each story in the journey
  const stories = await Promise.all(
    journey.stories.map(storyId => getStory(storyId))
  );
  const validStories = stories.filter(Boolean) as NonNullable<Awaited<ReturnType<typeof getStory>>>[];

  return (
    <main className="min-h-screen bg-[var(--color-background)]">
      <JourneyDetailClient journey={journey} stories={validStories} />
    </main>
  );
}
