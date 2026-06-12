import { getAllJourneys } from '@/lib/stories';
import JourneyClientGrid from './JourneyClientGrid';

export default async function JourneySection() {
  const journeys = await getAllJourneys();
  if (journeys.length === 0) return null;

  return (
    <section className="py-12 px-4 bg-[var(--color-warm-cream)]">
      <div className="max-w-4xl mx-auto">
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
        <JourneyClientGrid journeys={journeys} />
      </div>
    </section>
  );
}
