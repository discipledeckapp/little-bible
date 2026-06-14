import Link from 'next/link';

const PATHS = [
  {
    id:       'journey',
    emoji:    '🌱',
    title:    'Begin a Journey',
    subtitle: 'God Loves Me',
    desc:     '5 Bible stories for ages 4–5 — follow Lumi through creation, prayer, and who God is.',
    meta:     'Ages 4–5 · 5 stories · ~4 weeks',
    cta:      'Start the Journey',
    href:     '/journeys/god-loves-me',
    bg:       'bg-amber-50',
    border:   'border-amber-200',
    iconBg:   'bg-amber-100',
    ctaClass: 'bg-amber-500 hover:bg-amber-600 text-white',
    tag:      'Best for ages 4–5',
    tagClass: 'bg-amber-100 text-amber-700',
  },
  {
    id:       'genesis',
    emoji:    '📖',
    title:    'Read the Whole Bible',
    subtitle: 'Start at Genesis 1',
    desc:     'Begin at the very beginning and read every verse of Scripture — faithfully adapted for little hearts.',
    meta:     'Ages 4–7 · 66 books · Every verse',
    cta:      'Open Genesis 1',
    href:     '/genesis/1',
    bg:       'bg-stone-50',
    border:   'border-stone-200',
    iconBg:   'bg-stone-100',
    ctaClass: 'bg-stone-800 hover:bg-stone-700 text-white',
    tag:      'The full Children\'s Bible',
    tagClass: 'bg-stone-100 text-stone-600',
  },
  {
    id:       'topics',
    emoji:    '✨',
    title:    'Explore by Topic',
    subtitle: 'What does God say about…',
    desc:     'Browse 20+ Scripture topics — love, courage, prayer, kindness, forgiveness, and more.',
    meta:     'Ages 4–7 · 20+ topics · Any time',
    cta:      'Browse Topics',
    href:     '/topics',
    bg:       'bg-purple-50',
    border:   'border-purple-200',
    iconBg:   'bg-purple-100',
    ctaClass: 'bg-purple-600 hover:bg-purple-700 text-white',
    tag:      'Explore by theme',
    tagClass: 'bg-purple-100 text-purple-700',
  },
] as const;

export default function WhereToStartSection() {
  return (
    <section className="py-14 px-4 bg-[var(--color-warm-cream)]">
      <div className="max-w-4xl mx-auto">

        {/* Header */}
        <div className="text-center mb-10">
          <p className="text-xs font-bold text-amber-600 uppercase tracking-widest mb-2">
            New to Little Bible?
          </p>
          <h2
            className="text-3xl sm:text-4xl font-bold text-stone-800 mb-3"
            style={{ fontFamily: 'var(--font-display)' }}
          >
            Where should we start?
          </h2>
          <p className="text-stone-500 text-base max-w-sm mx-auto leading-relaxed">
            Every family begins somewhere. Here are three ways in.
          </p>
        </div>

        {/* Three path cards */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          {PATHS.map((path) => (
            <div
              key={path.id}
              className={`relative flex flex-col rounded-3xl border-2 ${path.bg} ${path.border} p-6 transition-all hover:shadow-md`}
            >
              {/* Tag */}
              <span className={`self-start text-[10px] font-extrabold uppercase tracking-widest px-2.5 py-1 rounded-full mb-4 ${path.tagClass}`}>
                {path.tag}
              </span>

              {/* Icon */}
              <div className={`w-14 h-14 rounded-2xl ${path.iconBg} flex items-center justify-center text-3xl mb-4`}>
                {path.emoji}
              </div>

              {/* Text */}
              <h3 className="font-bold text-stone-800 text-lg mb-0.5" style={{ fontFamily: 'var(--font-display)' }}>
                {path.title}
              </h3>
              <p className="text-amber-700 text-sm font-semibold mb-2">{path.subtitle}</p>
              <p className="text-stone-500 text-sm leading-relaxed mb-4 flex-1">{path.desc}</p>

              {/* Meta */}
              <p className="text-stone-400 text-[11px] font-semibold uppercase tracking-wide mb-4">
                {path.meta}
              </p>

              {/* CTA */}
              <Link
                href={path.href}
                className={`inline-flex items-center justify-center gap-2 ${path.ctaClass} font-bold text-sm px-5 py-3 rounded-2xl transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-amber-400`}
              >
                {path.cta}
                <span aria-hidden="true">→</span>
              </Link>
            </div>
          ))}
        </div>

      </div>
    </section>
  );
}
