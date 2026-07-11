import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: '30-Day Bible Reading Chart — Little Bible',
  description:
    'A free 30-day family Bible reading tracker for children ages 4–7. Track streaks, celebrate milestones, and build the Bible habit together. Works for families, Sunday school classes, and homeschool groups.',
  openGraph: {
    title: 'Free 30-Day Bible Reading Chart — Little Bible',
    description: 'Track 30 days of family Bible reading with milestone badges at days 7, 14, 21 & 30. Free printable tracker for families, Sunday school & homeschool.',
    url: 'https://littlebible.org/free/reading-chart',
    siteName: 'Little Bible',
    images: [{ url: '/brand/free/reading-chart-cover.svg', width: 1200, height: 630, alt: 'Little Bible 30-Day Reading Chart' }],
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Free 30-Day Bible Reading Chart — Little Bible',
    description: 'Track 30 days of family Bible reading with milestone badges. Free for families, Sunday school & homeschool.',
    images: ['/brand/free/reading-chart-cover.svg'],
  },
};

const DAYS = Array.from({ length: 30 }, (_, i) => i + 1);

const MILESTONES = [
  { day: 7,  emoji: '⭐', label: '1 week! You\'re building a habit.' },
  { day: 14, emoji: '🌟', label: '2 weeks! You\'re halfway there.' },
  { day: 21, emoji: '🔥', label: '3 weeks! This is now a habit.' },
  { day: 30, emoji: '🏆', label: '30 days! You did it. Celebrate BIG.' },
];

const READING_PLAN = [
  { days: '1–5',   theme: 'God Made Everything',   refs: ['Genesis 1', 'Psalm 139:14', 'Genesis 2', 'John 1:1–3', 'Psalm 8'] },
  { days: '6–10',  theme: 'God Loves You',          refs: ['John 3:16', 'Romans 5:8', 'Psalm 136:1', '1 John 4:8', 'Psalm 100'] },
  { days: '11–15', theme: 'Jesus is Here',          refs: ['Luke 2:1–7', 'Luke 2:8–20', 'Matthew 2:1–12', 'Luke 3:21–22', 'Mark 10:13–16'] },
  { days: '16–20', theme: 'How to Live',            refs: ['Proverbs 3:5–6', 'Matthew 22:37–39', 'Ephesians 6:1–3', 'Philippians 4:13', 'Psalm 119:105'] },
  { days: '21–25', theme: 'God is Always There',   refs: ['Psalm 23', 'Joshua 1:9', 'Matthew 6:25–26', 'Romans 8:38–39', 'Jeremiah 29:11'] },
  { days: '26–30', theme: 'Tell Others',            refs: ['Matthew 28:19–20', 'Acts 1:8', 'Mark 16:15', '2 Timothy 3:16–17', 'Revelation 22:20–21'] },
];

export default function ReadingChartPage() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />

      <main className="flex-1">

        {/* Hero */}
        <section className="bg-gradient-to-b from-sky-900 via-sky-800 to-blue-700 py-14 sm:py-18 px-4 text-center">
          <div className="max-w-xl mx-auto">
            <Link
              href="/free"
              className="inline-flex items-center gap-1.5 text-sky-300/70 hover:text-sky-200 text-xs font-bold uppercase tracking-widest mb-6 transition-colors"
            >
              ← Free Resources
            </Link>
            <div className="text-5xl mb-4">📅</div>
            <h1 className="font-display text-3xl sm:text-4xl font-bold text-white mb-4 leading-tight">
              30-Day Bible Reading Chart
            </h1>
            <p className="text-sky-100/80 font-bold text-base mb-2">
              Family Bible Reading Tracker
            </p>
            <p className="text-sky-200/70 text-sm leading-relaxed mb-6">
              30 days. 30 readings. Each one under 10 minutes. Track your streak,
              celebrate milestones, and build the Bible habit that lasts a lifetime.
            </p>
            <div className="flex flex-wrap items-center justify-center gap-3">
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">30 Days</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">Ages 4–7</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">Printable</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">100% Free</span>
            </div>
          </div>
        </section>

        {/* How it works */}
        <section className="bg-sky-50 border-b border-sky-100 py-8 px-4">
          <div className="max-w-2xl mx-auto">
            <h2 className="font-bold text-stone-800 text-sm text-center mb-4 uppercase tracking-wider">How It Works</h2>
            <div className="grid grid-cols-1 sm:grid-cols-4 gap-4 text-center">
              {[
                { icon: '📖', label: 'Read together', detail: 'Pick a verse or passage from the plan below.' },
                { icon: '✅', label: 'Mark the day', detail: 'Tick the box or let your child colour it in.' },
                { icon: '🏅', label: 'Hit milestones', detail: 'Celebrate at 7, 14, 21, and 30 days.' },
                { icon: '📣', label: 'Share it', detail: 'Post your streak with #LittleBibleChallenge.' },
              ].map(({ icon, label, detail }) => (
                <div key={label} className="bg-white rounded-2xl p-4 border border-sky-100">
                  <p className="text-2xl mb-2">{icon}</p>
                  <p className="font-bold text-stone-800 text-sm mb-1">{label}</p>
                  <p className="text-stone-500 text-xs leading-relaxed">{detail}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* The chart */}
        <section className="max-w-2xl mx-auto px-4 py-10">
          <h2 className="font-display text-xl font-bold text-stone-800 mb-2 text-center">Your 30-Day Chart</h2>
          <p className="text-stone-400 text-sm text-center mb-6">
            Print this page, or save it to your phone and screenshot after each day.
          </p>

          {/* Grid */}
          <div className="bg-white rounded-3xl border border-sky-100 p-6 mb-6">
            <div className="grid grid-cols-5 sm:grid-cols-6 gap-3">
              {DAYS.map((day) => {
                const milestone = MILESTONES.find(m => m.day === day);
                return (
                  <div
                    key={day}
                    className={`relative aspect-square flex flex-col items-center justify-center rounded-2xl border-2 transition-all ${
                      milestone
                        ? 'border-amber-300 bg-amber-50'
                        : 'border-sky-100 bg-sky-50 hover:border-sky-300'
                    }`}
                  >
                    {milestone && (
                      <span className="absolute -top-2 -right-2 text-base">{milestone.emoji}</span>
                    )}
                    <span className="font-extrabold text-sky-700 text-sm">{day}</span>
                    <div className="w-4 h-4 border-2 border-sky-300 rounded-sm mt-1 bg-white" />
                  </div>
                );
              })}
            </div>

            {/* Milestone legend */}
            <div className="mt-5 space-y-2 border-t border-stone-100 pt-4">
              {MILESTONES.map(m => (
                <div key={m.day} className="flex items-center gap-3 text-xs text-stone-600">
                  <span className="text-base w-6 flex-shrink-0">{m.emoji}</span>
                  <span className="font-bold text-stone-500">Day {m.day}:</span>
                  <span>{m.label}</span>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Reading plan */}
        <section className="max-w-2xl mx-auto px-4 pb-10">
          <h2 className="font-display text-xl font-bold text-stone-800 mb-2 text-center">30-Day Reading Plan</h2>
          <p className="text-stone-400 text-sm text-center mb-6">
            Six themes over five days each — read together in whatever Bible translation you use at home.
          </p>

          <div className="space-y-4">
            {READING_PLAN.map((block, i) => (
              <div key={block.days} className="bg-white rounded-2xl border border-stone-100 overflow-hidden">
                <div className="bg-sky-50 px-5 py-3 border-b border-sky-100">
                  <p className="text-[10px] font-extrabold text-sky-600 uppercase tracking-widest">Days {block.days}</p>
                  <p className="font-bold text-stone-800">{block.theme}</p>
                </div>
                <div className="px-5 py-3">
                  <div className="flex flex-wrap gap-2">
                    {block.refs.map((ref, j) => (
                      <span key={ref} className="inline-flex items-center gap-1 text-xs font-semibold text-stone-600 bg-stone-50 border border-stone-200 px-2.5 py-1 rounded-full">
                        <span className="text-stone-400 font-normal">Day {(i * 5) + j + 1}:</span> {ref}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* What to do when you finish */}
        <section className="max-w-2xl mx-auto px-4 pb-12">
          <div className="bg-gradient-to-r from-sky-500 to-blue-600 rounded-3xl p-8 text-white text-center">
            <div className="text-4xl mb-3">🏆</div>
            <h2 className="font-display text-2xl font-bold mb-3">
              Finished 30 days?
            </h2>
            <p className="text-white/80 text-sm leading-relaxed mb-6 max-w-sm mx-auto">
              You&apos;ve built something real. Keep going with guided journeys
              and the full Bible on Little Bible — all designed for your child.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
              <Link
                href="/journeys"
                className="inline-flex items-center gap-2 bg-white text-sky-700 font-extrabold px-6 py-3 rounded-2xl transition-all active:scale-95 hover:shadow-md"
              >
                🌿 Start a Journey
              </Link>
              <Link
                href="/challenge"
                className="inline-flex items-center gap-2 bg-white/15 hover:bg-white/25 text-white font-bold px-6 py-3 rounded-2xl transition-all border border-white/20"
              >
                Share the Challenge
              </Link>
            </div>
          </div>
        </section>

      </main>

      <Footer />
    </div>
  );
}
