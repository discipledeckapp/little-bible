import type { Metadata } from 'next';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import HeroSection from '@/components/home/HeroSection';
import JourneySection from '@/components/home/JourneySection';
import StoriesSection from '@/components/home/StoriesSection';
import WisdomBar from '@/components/home/WisdomBar';
import FamilyStreakBanner from '@/components/home/FamilyStreakBanner';
import LibrarySection from '@/components/home/LibrarySection';
import { getAllBooksWithMeta } from '@/lib/content';

export const metadata: Metadata = {
  title: "Little Bible — God's Word for Little Hearts",
  description:
    'Daily family devotions for children ages 4–7. Every verse of Scripture — faithfully adapted, beautifully simple.',
};

export default function HomePage() {
  const books = getAllBooksWithMeta('en');

  return (
    <div className="min-h-screen flex flex-col">
      <Header />

      {/* 1. Hero */}
      <HeroSection />

      {/* 2. Progress (shown when started) */}
      <div className="bg-[#FFFBF5] px-0 py-2">
        <WisdomBar />
      </div>
      <div className="bg-[#FFFBF5] pb-4">
        <FamilyStreakBanner />
      </div>

      {/* 3. Journey paths — age-based starting points */}
      <JourneySection />

      {/* 4. Stories by collection — story-first browsing */}
      <StoriesSection />

      {/* 5. Full Bible library — book/chapter navigation */}
      <LibrarySection availableBooks={books} />

      <Footer />
    </div>
  );
}
