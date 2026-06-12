const STEPS = [
  {
    emoji: '📖',
    label: 'Read',
    title: 'Read Together',
    body: "Every verse is faithfully adapted into language your child truly understands. God's Word — every word.",
    bg: 'bg-amber-50',
    border: 'border-amber-100',
    numColor: 'text-amber-300',
    accent: 'bg-amber-500',
  },
  {
    emoji: '💬',
    label: 'Discuss',
    title: 'Talk About It',
    body: 'A guided discussion question opens the conversation. What does God want us to understand from this?',
    bg: 'bg-emerald-50',
    border: 'border-emerald-100',
    numColor: 'text-emerald-300',
    accent: 'bg-emerald-500',
  },
  {
    emoji: '🙏',
    label: 'Pray',
    title: 'Pray Together',
    body: "A short, real prayer — based on the verse. Your child's voice, speaking directly to God.",
    bg: 'bg-sky-50',
    border: 'border-sky-100',
    numColor: 'text-sky-300',
    accent: 'bg-sky-500',
  },
  {
    emoji: '⭐',
    label: 'Remember',
    title: 'Say it Together',
    body: 'Hear it slowly. Say it together. Repeat it. A 4-word phrase planted deep in a little heart.',
    bg: 'bg-amber-50',
    border: 'border-amber-100',
    numColor: 'text-amber-300',
    accent: 'bg-amber-400',
  },
  {
    emoji: '🌟',
    label: 'Do It',
    title: 'Do It Today',
    body: 'One concrete action. Not just knowledge — obedience. Faith that moves from the heart into real life.',
    bg: 'bg-violet-50',
    border: 'border-violet-100',
    numColor: 'text-violet-300',
    accent: 'bg-violet-500',
  },
];

export default function ExperienceSection() {
  return (
    <section className="bg-[#FFFBF5] py-12 sm:py-16 px-4">
      <div className="max-w-4xl mx-auto">

        <div className="text-center mb-10">
          <p className="text-amber-500 text-xs font-bold uppercase tracking-[0.2em] mb-3">
            The Devotion Journey
          </p>
          <h2 className="font-display text-3xl sm:text-4xl font-bold text-stone-800">
            Five minutes together.<br />
            <span className="text-amber-600">A lifetime of faith.</span>
          </h2>
          <p className="text-stone-400 text-sm mt-3 max-w-sm mx-auto">
            Every verse of Scripture becomes a complete family devotion.
          </p>
        </div>

        {/* 5-step flow */}
        <div className="relative">
          {/* Connecting line (desktop) */}
          <div
            className="hidden sm:block absolute top-11 left-[10%] right-[10%] h-0.5 bg-stone-100"
            aria-hidden="true"
          />

          <div className="grid grid-cols-1 sm:grid-cols-5 gap-3">
            {STEPS.map((s, i) => (
              <div key={s.label} className={`relative rounded-3xl p-5 border ${s.bg} ${s.border}`}>
                {/* Step number */}
                <div className="flex items-center gap-2 mb-3">
                  <div className={`w-8 h-8 rounded-xl ${s.accent} flex items-center justify-center text-white font-extrabold text-sm`}>
                    {i + 1}
                  </div>
                  <span className="text-xl" aria-hidden="true">{s.emoji}</span>
                </div>
                <p className="font-extrabold text-stone-800 text-sm mb-1">{s.title}</p>
                <p className="text-stone-500 text-xs leading-relaxed">{s.body}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Scripture quote */}
        <div className="mt-12 text-center max-w-2xl mx-auto">
          <div className="divider-amber mb-8" aria-hidden="true" />
          <blockquote>
            <p className="scripture-text text-stone-600 text-lg sm:text-xl leading-relaxed">
              &ldquo;Train up a child in the way he should go:
              and when he is old, he will not depart from it.&rdquo;
            </p>
            <footer className="mt-3 text-amber-500 text-xs font-bold uppercase tracking-widest">
              Proverbs 22:6
            </footer>
          </blockquote>
          <div className="divider-amber mt-8" aria-hidden="true" />
        </div>

      </div>
    </section>
  );
}
