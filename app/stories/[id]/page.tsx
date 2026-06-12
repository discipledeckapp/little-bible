import { notFound } from 'next/navigation';
import { getStory } from '@/lib/stories';
import StoryReader from '@/components/reader/StoryReader';
import type { Metadata } from 'next';

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
  return <StoryReader story={story} />;
}
