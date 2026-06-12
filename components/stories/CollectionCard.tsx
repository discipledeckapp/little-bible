import { Collection } from '@/types';

interface CollectionCardProps {
  collection: Collection;
  completedCount?: number;
  totalCount?: number;
  onClick?: () => void;
}

export default function CollectionCard({ collection, completedCount = 0, totalCount = 0, onClick }: CollectionCardProps) {
  const pct = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

  return (
    <button
      onClick={onClick}
      className="w-full text-left rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-all duration-200 hover:-translate-y-0.5 active:scale-[0.99] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
    >
      {/* Header band */}
      <div
        className="px-5 py-4 flex items-center gap-3"
        style={{ background: `linear-gradient(135deg, ${collection.color}22 0%, ${collection.color}44 100%)` }}
      >
        <span className="text-3xl" role="img" aria-label={collection.title}>
          {collection.emoji}
        </span>
        <div className="flex-1 min-w-0">
          <h3
            className="font-bold text-stone-800 text-base leading-tight"
            style={{ fontFamily: 'var(--font-display)' }}
          >
            {collection.title}
          </h3>
          <p className="text-stone-500 text-xs mt-0.5 leading-snug">
            {collection.subtitle}
          </p>
        </div>
        <span className="text-xs text-stone-400 shrink-0">
          {totalCount} {totalCount === 1 ? 'story' : 'stories'}
        </span>
      </div>

      {/* Progress bar */}
      {totalCount > 0 && (
        <div className="h-1 bg-stone-100">
          <div
            className="h-full transition-all duration-500"
            style={{ width: `${pct}%`, background: collection.color }}
          />
        </div>
      )}
    </button>
  );
}
