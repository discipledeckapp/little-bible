import type { Metadata } from 'next';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import HeroSection from '@/components/home/HeroSection';
import JourneySection from '@/components/home/JourneySection';
import StoriesSection from '@/components/home/StoriesSection';
import WisdomBar from '@/components/home/WisdomBar';
import FamilyStreakBanner from '@/components/home/FamilyStreakBanner';
import LibrarySection from '@/components/home/LibrarySection';
import StoryGarden from '@/components/stories/StoryGarden';
import FamilyDashboardSection from '@/components/home/FamilyDashboardSection';
import TopicsSection from '@/components/home/TopicsSection';
import JsonLd from '@/components/seo/JsonLd';
import { getAllBooksWithMeta } from '@/lib/content';
import { getAllStories } from '@/lib/stories';
import { getAllTopics } from '@/lib/topics';

export const metadata: Metadata = {
  title: "Little Bible — God's Word for Little Hearts",
  description:
    'Daily family devotions for children ages 4–7. Every verse of Scripture — faithfully adapted, beautifully simple.',
};

export default async function HomePage() {
  const [books, allStories, topics] = await Promise.all([
    Promise.resolve(getAllBooksWithMeta('en')),
    getAllStories(),
    Promise.resolve(getAllTopics()),
  ]);

  const storySearchItems = allStories.map(s => ({
    id: s.id,
    title: s.title,
    emoji: s.coverEmoji ?? '📖',
  }));

  const topicSearchItems = topics.map(t => ({
    id: t.id,
    title: t.title,
    emoji: t.emoji,
    description: t.description,
  }));

  const websiteJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'Little Bible',
    url: 'https://littlebible.org',
    description:
      'All 66 books of Scripture faithfully adapted for children ages 4–7. Read, discuss, pray, and live God\'s Word together as a family.',
    publisher: {
      '@type': 'Organization',
      name: 'Little Bible',
      url: 'https://littlebible.org',
      logo: {
        '@type': 'ImageObject',
        url: 'https://littlebible.org/icon',
      },
    },
    inLanguage: 'en',
  };

  return (
    <div className="min-h-screen flex flex-col">
      <JsonLd data={websiteJsonLd} />
      <Header />

      {/* 1. Hero */}
      <HeroSection stories={storySearchItems} topics={topicSearchItems} />

      {/* 2. Progress (shown when started) */}
      <div className="bg-[#FFFBF5] px-0 py-2">
        <WisdomBar />
      </div>
      <div className="bg-[#FFFBF5] pb-4">
        <FamilyStreakBanner />
      </div>

      {/* 3. Family dashboard — shown to signed-in users with a family */}
      <FamilyDashboardSection />

      {/* 4. Full Bible library — the primary product identity */}
      <LibrarySection availableBooks={books} />

      {/* 4. Journey paths — age-based discipleship paths */}
      <JourneySection />

      {/* 5. Topics — scriptures by theme */}
      <TopicsSection topics={topics} />

      {/* 6. Stories by collection — story-first browsing */}
      <StoriesSection />

      {/* 6. Story Garden — user's completed stories (client, hidden until progress exists) */}
      <StoryGarden />

      <Footer />
    </div>
  );
}
