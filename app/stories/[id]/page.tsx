import { notFound } from 'next/navigation';
import { getStory, getAllCollections, getAllStories } from '@/lib/stories';
import StoryReader from '@/components/reader/StoryReader';
import type { Metadata } from 'next';
import type { Story } from '@/types';

interface PageProps {
  params: Promise<{ id: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { id } = await params;
  const story = await getStory(id);
  if (!story) return { title: 'Story — Little Bible' };
  return {
    title: `${story.title} — Little Bible`,
    description: story.mainTruth,
  };
}

export default async function StoryPage({ params }: PageProps) {
  const { id } = await params;
  const story = await getStory(id);
  if (!story) notFound();

  // Find the next story in the same collection
  let nextStory: Story | null = null;
  const [collections, allStories] = await Promise.all([
    getAllCollections(),
    getAllStories(),
  ]);
  const collection = collections.find(c => c.stories.includes(id));
  if (collection) {
    const idx = collection.stories.indexOf(id);
    const nextId = collection.stories[idx + 1];
    if (nextId) {
      nextStory = allStories.find(s => s.id === nextId) ?? null;
    }
  }

  return <StoryReader story={story} nextStory={nextStory} />;
}
