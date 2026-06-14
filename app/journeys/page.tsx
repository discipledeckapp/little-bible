import { getAllJourneys } from '@/lib/stories';
import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Journeys — Little Bible',
  description:
    'Guided reading journeys through Scripture — designed for children ages 4–7. Walk through the Bible together, one story at a time.',
};

const THEME: Record<string, { gradient: string; light: string; text: string; ring: string }> = {
  'god-loves-me': {
    gradient: 'from-amber-400 via-amber-500 to-orange-500',
    light:    'bg-amber-50',
    text:     'text-amber-900',
    ring:     'ring-amber-200',
  },
  'follow-jesus': {
    gradient: 'from-emerald-400 via-emerald-500 to-teal-500',
    light:    'bg-emerald-50',
    text:     'text-emerald-900',
    ring:     'ring-emerald-200',
  },
  'wisdom-path': {
    gradient: 'from-sky-400 via-sky-500 to-blue-500',
    light:    'bg-sky-50',
    text:     'text-sky-900',
    ring:     'ring-sky-200',
  },
};

const FALLBACK = {
  gradient: 'from-stone-400 to-stone-600',
  light:    'bg-stone-50',
  text:     'text-stone-900',
  ring:     'ring-stone-200',
};

export default async function JourneysPage() {
  const journeys = await getAllJourneys();

  return (
    <div className="min-h-screen flex flex-col">
      <Header />

      <main className="flex-1">

        {/* Hero */}
        <section className="bg-gradient-to-b from-stone-800 via-stone-700 to-stone-600 py-12 sm:py-16 px-4">
          <div className="max-w-3xl mx-auto text-center">
            <p className="text-stone-400 text-xs font-extrabold uppercase tracking-widest mb-3">
              Guided Learning
            </p>
            <h1 className="font-display text-3xl sm:text-4xl font-bold text-white mb-4">
              Journeys
            </h1>
            <p className="text-stone-300 text-base sm:text-lg max-w-xl mx-auto leading-relaxed">
              Step-by-step paths through Scripture, paced for your child&apos;s age.
              Read stories, learn verses, grow together.
            </p>
          </div>
        </section>

        {/* Journey cards */}
        <section className="max-w-3xl mx-auto px-4 py-10 space-y-5">
          <p className="text-stone-400 text-xs font-extrabold uppercase tracking-widest text-center mb-6">
            {journeys.length} journeys available
          </p>

          {journeys.map((journey, idx) => {
            const theme = THEME[journey.id] ?? FALLBACK;

            return (
              <Link
                key={journey.id}
                href={`/journeys/${journey.id}`}
                className={`block rounded-3xl overflow-hidden ring-1 ${theme.ring} hover:shadow-xl transition-all group`}
              >
                {/* Colored header */}
                <div className={`bg-gradient-to-r ${theme.gradient} px-6 pt-6 pb-5 text-white`}>
                  <div className="flex items-start justify-between gap-4">
                    <div className="min-w-0">
                      <p className="text-white/70 text-[11px] font-extrabold uppercase tracking-widest mb-2">
                        Ages {journey.ageRange} · {journey.durationWeeks} weeks · {journey.stories.length} stories
                      </p>
                      <h2 className="font-display text-2xl sm:text-3xl font-bold mb-2 flex items-center gap-2">
                        <span>{journey.coverEmoji}</span>
                        <span>{journey.name}</span>
                      </h2>
                      <p className="text-white/85 text-base leading-relaxed">
                        {journey.subtitle}
                      </p>
                    </div>
                    <span
                      className="text-white/50 group-hover:text-white font-bold text-2xl transition-colors flex-shrink-0 mt-1 group-hover:translate-x-1 transition-transform duration-200"
                      aria-hidden="true"
                    >
                      →
                    </span>
                  </div>
                </div>

                {/* Light-colored body */}
                <div className={`${theme.light} px-6 py-4`}>
                  <p className={`${theme.text} text-sm font-medium leading-relaxed mb-3`}>
                    {journey.mainTruth}
                  </p>
                  <ul className="space-y-1">
                    {journey.outcomes.slice(0, 2).map((outcome, i) => (
                      <li key={i} className={`${theme.text} text-xs opacity-70 flex items-start gap-1.5`}>
                        <span className="mt-0.5 flex-shrink-0">✓</span>
                        <span>{outcome}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </Link>
            );
          })}
        </section>

        {/* Gentle CTA for new families */}
        <div className="max-w-3xl mx-auto px-4 pb-12 text-center">
          <div className="bg-amber-50 rounded-3xl p-8 border border-amber-100">
            <p className="text-amber-700 font-bold text-base mb-2">Not sure where to start?</p>
            <p className="text-amber-600/80 text-sm mb-5 max-w-sm mx-auto">
              Begin with <strong>God Loves Me</strong> — your child&apos;s first journey through Scripture.
              Designed for ages 4–5, five stories over five weeks.
            </p>
            <Link
              href="/journeys/god-loves-me"
              className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-6 py-3 rounded-2xl transition-all active:scale-95 shadow-sm"
            >
              🌱 Start God Loves Me
            </Link>
          </div>
        </div>

      </main>

      <Footer />
    </div>
  );
}
