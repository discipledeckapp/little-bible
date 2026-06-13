import { notFound } from 'next/navigation';
import type { Metadata } from 'next';
import type { Story } from '@/types';
import { getStory, getAllCollections, getAllStories } from '@/lib/stories';
import StoryReader from '@/components/reader/StoryReader';
import JsonLd from '@/components/seo/JsonLd';

interface PageProps {
  params: Promise<{ id: string }>;
}

export async function generateStaticParams() {
  const stories = await getAllStories();
  return stories.map(s => ({ id: s.id }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { id } = await params;
  const story = await getStory(id);
  if (!story) return { title: 'Story — Little Bible' };

  const title = `${story.title} — Little Bible`;
  const description = story.subtitle
    ? `${story.mainTruth} ${story.subtitle}`
    : story.mainTruth;
  const url = `https://littlebible.org/stories/${id}`;

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      url,
      siteName: 'Little Bible',
      type: 'article',
    },
    twitter: {
      card: 'summary',
      title,
      description,
    },
    alternates: { canonical: url },
  };
}

export default async function StoryPage({ params }: PageProps) {
  const { id } = await params;
  const story = await getStory(id);
  if (!story) notFound();

  let nextStory: Story | null = null;
  const [collections, allStories] = await Promise.all([
    getAllCollections(),
    getAllStories(),
  ]);
  const collection = collections.find(c => c.stories.includes(id));
  if (collection) {
    const idx = collection.stories.indexOf(id);
    const nextId = collection.stories[idx + 1];
    if (nextId) nextStory = allStories.find(s => s.id === nextId) ?? null;
  }

  const storyJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: story.title,
    description: story.mainTruth,
    url: `https://littlebible.org/stories/${id}`,
    about: { '@type': 'Thing', name: story.bibleRef },
    publisher: {
      '@type': 'Organization',
      name: 'Little Bible',
      url: 'https://littlebible.org',
    },
    inLanguage: 'en',
    audience: {
      '@type': 'Audience',
      audienceType: `Children ages ${story.ageRange ?? '4–7'}`,
    },
  };

  return (
    <>
      <JsonLd data={storyJsonLd} />
      <StoryReader story={story} nextStory={nextStory} />
    </>
  );
}
