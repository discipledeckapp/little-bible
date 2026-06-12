import { getAllJourneys } from '@/lib/stories';
import JourneyCard from '@/components/stories/JourneyCard';

export default async function JourneySection() {
  const journeys = await getAllJourneys();

  if (journeys.length === 0) return null;

  return (
    <section className="py-12 px-4 bg-[var(--color-warm-cream)]">
      <div className="max-w-4xl mx-auto">
        {/* Section header */}
        <div className="text-center mb-8">
          <p className="text-xs font-semibold text-amber-600 uppercase tracking-widest mb-2">
            Start Your Journey
          </p>
          <h2
            className="text-3xl font-bold text-stone-800"
            style={{ fontFamily: 'var(--font-display)' }}
          >
            Every child has a path
          </h2>
          <p className="text-stone-500 mt-2 text-base max-w-sm mx-auto leading-relaxed">
            Guided journeys through Scripture, designed for your child&apos;s age.
          </p>
        </div>

        {/* Journey grid */}
        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {journeys.map((journey, i) => (
            <JourneyCard
              key={journey.id}
              journey={journey}
              recommended={i === 0}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
