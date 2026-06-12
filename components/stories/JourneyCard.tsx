import { Journey } from '@/types';
import LumiMascot, { getLumiStage, getLumiLabel } from '@/components/mascot/LumiMascot';

interface JourneyCardProps {
  journey: Journey;
  completedStories?: number;
  recommended?: boolean;
  onStart?: () => void;
}

export default function JourneyCard({ journey, completedStories = 0, recommended = false, onStart }: JourneyCardProps) {
  const total = journey.stories.length;
  const pct = total > 0 ? (completedStories / total) * 100 : 0;
  const isStarted = completedStories > 0;
  const isComplete = completedStories >= total && total > 0;

  return (
    <div
      className={`
        relative rounded-3xl overflow-hidden shadow-md
        ${recommended ? 'ring-2 ring-amber-400' : ''}
      `}
      style={{ background: `linear-gradient(160deg, ${journey.coverColor}15 0%, ${journey.coverColor}30 100%)` }}
    >
      {recommended && (
        <div className="absolute top-3 right-3 bg-amber-400 text-amber-900 text-xs font-bold px-2 py-0.5 rounded-full">
          Start Here
        </div>
      )}

      <div className="p-5">
        {/* Header */}
        <div className="flex items-start gap-4">
          <div className="shrink-0">
            <span className="text-4xl">{journey.coverEmoji}</span>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs font-semibold text-stone-400 uppercase tracking-wide mb-0.5">
              Ages {journey.ageRange} · {journey.durationWeeks} weeks
            </p>
            <h3
              className="text-xl font-bold text-stone-800 leading-tight"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              {journey.name}
            </h3>
            <p className="text-stone-500 text-sm mt-1 leading-snug">
              {journey.subtitle}
            </p>
          </div>
        </div>

        {/* Main truth */}
        <div
          className="mt-4 px-4 py-3 rounded-xl text-sm leading-relaxed"
          style={{ background: journey.coverColor + '18', color: journey.coverColor }}
        >
          <span className="font-semibold">You will learn: </span>
          {journey.mainTruth}
        </div>

        {/* Progress or story count */}
        {isStarted ? (
          <div className="mt-4">
            <div className="flex justify-between text-xs text-stone-400 mb-1.5">
              <span>{completedStories} of {total} stories</span>
              <span>{Math.round(pct)}%</span>
            </div>
            <div className="h-2 bg-white/60 rounded-full overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-500"
                style={{ width: `${pct}%`, background: journey.coverColor }}
              />
            </div>
          </div>
        ) : (
          <div className="mt-3 flex items-center gap-2">
            <span className="text-xs text-stone-400">{total} stories</span>
            <span className="text-stone-200">·</span>
            <span className="text-xs text-stone-400">~{journey.durationWeeks * 7} min total</span>
          </div>
        )}

        {/* CTA */}
        <button
          onClick={onStart}
          className="mt-4 w-full py-3 rounded-xl font-bold text-sm transition-all duration-200 hover:opacity-90 active:scale-[0.98]"
          style={{
            background: journey.coverColor,
            color: '#fff',
          }}
        >
          {isComplete ? 'Read Again' : isStarted ? 'Continue Journey' : 'Begin Journey →'}
        </button>
      </div>
    </div>
  );
}
