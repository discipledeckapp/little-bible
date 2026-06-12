interface StatsBarProps {
  bookCount: number;
  chapterCount: number;
  verseCount: number;
}

export default function StatsBar({ bookCount, chapterCount, verseCount }: StatsBarProps) {
  const stats = [
    { icon: '📚', value: bookCount, label: bookCount === 1 ? 'Book' : 'Books' },
    { icon: '📄', value: chapterCount, label: chapterCount === 1 ? 'Chapter' : 'Chapters' },
    { icon: '✨', value: verseCount, label: verseCount === 1 ? 'Verse' : 'Verses' },
  ];

  return (
    <div className="bg-amber-500 text-white">
      <div className="max-w-4xl mx-auto px-4 py-4 flex justify-center gap-10 sm:gap-16">
        {stats.map((s) => (
          <div key={s.label} className="text-center">
            <div className="text-lg leading-none mb-0.5" aria-hidden="true">
              {s.icon}
            </div>
            <div className="text-2xl font-bold leading-tight">{s.value}</div>
            <div className="text-amber-100 text-xs">{s.label}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
