import type { Metadata } from 'next';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import HeroSection from '@/components/home/HeroSection';
import BenefitsSection from '@/components/home/BenefitsSection';
import ExperienceSection from '@/components/home/ExperienceSection';
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

      {/* 1. Hero — story, CTAs, featured verse */}
      <HeroSection />

      {/* 2. Benefits — why Little Bible exists */}
      <BenefitsSection />

      {/* 3. Experience — how it works */}
      <ExperienceSection />

      {/* 4. Progress bar — only shown once user has started */}
      <div className="bg-[#FFFBF5] px-0 py-2">
        <WisdomBar />
      </div>

      {/* 5. Family streak + growth banner — only shown once user has started */}
      <div className="bg-[#FFFBF5] pb-4">
        <FamilyStreakBanner />
      </div>

      {/* 6. Library — browse content */}
      <LibrarySection availableBooks={books} />

      <Footer />
    </div>
  );
}
