import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Free Resources — Little Bible',
  description:
    'Free family Bible resources: 7-Day Family Devotional, Memory Verse Cards, Bible Reading Chart, and Children\'s Prayer Guide. Free for Christian families, Sunday school teachers, and homeschool parents.',
};

const RESOURCES = [
  {
    id: '7-day-devotional',
    emoji: '📖',
    tag: 'Most Popular',
    tagColor: 'bg-amber-100 text-amber-800',
    title: '7-Day Family Devotional',
    subtitle: 'God Loves Me — A First Journey Through Scripture',
    description:
      'Seven daily readings designed for children ages 4–7. Each day has a Bible verse, simple explanation, family activity, and a prayer prompt. Read together in under 10 minutes.',
    href: '/free/7-day-devotional',
    cta: 'Get the Devotional',
    color: 'from-amber-400 to-orange-400',
    light: 'bg-amber-50',
    border: 'border-amber-200',
  },
  {
    id: 'memory-verse-cards',
    emoji: '🌟',
    tag: 'For Ages 4–7',
    tagColor: 'bg-emerald-100 text-emerald-800',
    title: 'Memory Verse Cards',
    subtitle: '12 Key Verses Every Child Should Know',
    description:
      '12 beautifully illustrated verse cards — one for each month. Each card has the full verse, a child-friendly paraphrase, and a memory tip. Print and stick on the fridge.',
    href: '/free/memory-verse-cards',
    cta: 'Get the Cards',
    color: 'from-emerald-400 to-teal-400',
    light: 'bg-emerald-50',
    border: 'border-emerald-200',
  },
  {
    id: 'reading-chart',
    emoji: '📅',
    tag: 'Sunday School',
    tagColor: 'bg-sky-100 text-sky-800',
    title: 'Bible Reading Chart',
    subtitle: '30-Day Family Bible Reading Tracker',
    description:
      'A printable reading chart to help your family build the Bible habit. Track streaks, celebrate milestones, and stay consistent. Works for families, Sunday school classes, and homeschool groups.',
    href: '/free/reading-chart',
    cta: 'Get the Chart',
    color: 'from-sky-400 to-blue-400',
    light: 'bg-sky-50',
    border: 'border-sky-200',
  },
  {
    id: 'prayer-guide',
    emoji: '🙏',
    tag: 'Family Prayer',
    tagColor: 'bg-purple-100 text-purple-800',
    title: "Children's Prayer Guide",
    subtitle: 'Teaching Your Child to Pray in 7 Simple Steps',
    description:
      'A practical guide for parents who want to help their children develop a real prayer life. Includes model prayers, conversation starters, and a daily prayer prompt card.',
    href: '/free/prayer-guide',
    cta: 'Get the Guide',
    color: 'from-purple-400 to-violet-400',
    light: 'bg-purple-50',
    border: 'border-purple-200',
  },
];

const WHO = [
  { emoji: '👨‍👩‍👧', label: 'Christian Parents' },
  { emoji: '🏫', label: 'Sunday School Teachers' },
  { emoji: '⛪', label: "Children's Church" },
  { emoji: '🏠', label: 'Homeschool Families' },
  { emoji: '👵', label: 'Grandparents' },
  { emoji: '✝️', label: 'Church Leaders' },
];

export default function FreePage() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />

      <main className="flex-1">

        {/* Hero */}
        <section className="bg-gradient-to-b from-amber-900 via-amber-800 to-amber-700 py-14 sm:py-20 px-4 text-center">
          <div className="max-w-2xl mx-auto">
            <p className="text-amber-300/80 text-xs font-extrabold uppercase tracking-widest mb-4">
              Free Resources
            </p>
            <h1 className="font-display text-3xl sm:text-5xl font-bold text-white mb-5 leading-tight">
              Free Bible Resources<br className="hidden sm:block" /> for Your Family
            </h1>
            <p className="text-amber-100/80 text-base sm:text-lg leading-relaxed max-w-xl mx-auto mb-6">
              Devotionals, memory verse cards, reading charts, and prayer guides — designed for
              children ages 4–7 and the families, teachers, and churches who love them.
            </p>
            <p className="text-amber-400 font-bold text-sm">
              100% free. No email required.
            </p>
          </div>
        </section>

        {/* Who this is for */}
        <section className="bg-amber-50 border-b border-amber-100 py-5 px-4">
          <div className="max-w-3xl mx-auto flex flex-wrap items-center justify-center gap-3">
            <span className="text-amber-700 text-xs font-extrabold uppercase tracking-wider mr-1">For:</span>
            {WHO.map(({ emoji, label }) => (
              <span key={label} className="inline-flex items-center gap-1.5 text-xs font-bold text-amber-800 bg-white border border-amber-200 px-3 py-1.5 rounded-full">
                <span>{emoji}</span> {label}
              </span>
            ))}
          </div>
        </section>

        {/* Resource cards */}
        <section className="max-w-3xl mx-auto px-4 py-12 space-y-6">
          {RESOURCES.map((r) => (
            <div
              key={r.id}
              className={`rounded-3xl overflow-hidden border ${r.border} hover:shadow-lg transition-all group`}
            >
              <div className={`bg-gradient-to-r ${r.color} px-6 py-6 text-white`}>
                <div className="flex items-start justify-between gap-4">
                  <div className="min-w-0">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-2xl">{r.emoji}</span>
                      <span className={`text-[10px] font-extrabold uppercase tracking-widest px-2 py-0.5 rounded-full ${r.tagColor}`}>
                        {r.tag}
                      </span>
                    </div>
                    <h2 className="font-display text-xl sm:text-2xl font-bold mb-1">{r.title}</h2>
                    <p className="text-white/75 text-sm font-semibold">{r.subtitle}</p>
                  </div>
                </div>
              </div>
              <div className={`${r.light} px-6 py-5`}>
                <p className="text-stone-600 text-sm leading-relaxed mb-4">{r.description}</p>
                <Link
                  href={r.href}
                  className="inline-flex items-center gap-2 bg-white hover:bg-stone-50 text-stone-800 font-extrabold text-sm px-5 py-2.5 rounded-2xl border border-stone-200 hover:border-stone-300 transition-all active:scale-95 shadow-sm"
                >
                  {r.cta} →
                </Link>
              </div>
            </div>
          ))}
        </section>

        {/* Challenge CTA */}
        <section className="max-w-3xl mx-auto px-4 pb-12">
          <div className="bg-gradient-to-r from-emerald-600 to-teal-600 rounded-3xl p-8 text-white text-center">
            <div className="text-4xl mb-3">🌿</div>
            <h2 className="font-display text-2xl font-bold mb-2">Join the #LittleBibleChallenge</h2>
            <p className="text-white/80 text-sm leading-relaxed mb-5 max-w-md mx-auto">
              Read the Bible with your child every day for 7 days. Share your journey.
              Build the habit that changes everything.
            </p>
            <Link
              href="/challenge"
              className="inline-flex items-center gap-2 bg-white text-emerald-700 font-extrabold px-6 py-3 rounded-2xl transition-all active:scale-95 hover:shadow-md"
            >
              Take the Challenge →
            </Link>
          </div>
        </section>

        {/* Start reading */}
        <section className="bg-amber-50 border-t border-amber-100 py-10 px-4 text-center">
          <p className="text-stone-500 text-sm mb-3">
            Ready to start reading the Bible with your child?
          </p>
          <Link
            href="/stories"
            className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-6 py-3 rounded-2xl transition-all active:scale-95 shadow-sm"
          >
            📖 Start Reading Free
          </Link>
        </section>

      </main>

      <Footer />
    </div>
  );
}
