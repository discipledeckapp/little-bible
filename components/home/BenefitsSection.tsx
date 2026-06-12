const PILLARS = [
  {
    icon: '🌍',
    color: 'bg-amber-50 border-amber-100',
    iconBg: 'bg-amber-100',
    title: 'Know God',
    body: 'Every verse adapted so a 4-year-old can understand who God is, what He says, and why it matters — without losing the heart of Scripture.',
    quote: '"In the beginning, God…"',
  },
  {
    icon: '❤️',
    color: 'bg-rose-50 border-rose-100',
    iconBg: 'bg-rose-100',
    title: 'Love God',
    body: 'Beautiful prayers your child can actually pray. Not a recitation — a real conversation with a God who loves them.',
    quote: '"God, help me…"',
  },
  {
    icon: '⭐',
    color: 'bg-sky-50 border-sky-100',
    iconBg: 'bg-sky-100',
    title: 'Remember God',
    body: 'Every verse has a 4-word memory phrase. Short enough for little hearts to carry through the whole day.',
    quote: '"Wisdom starts with God."',
  },
  {
    icon: '🌱',
    color: 'bg-emerald-50 border-emerald-100',
    iconBg: 'bg-emerald-100',
    title: 'Follow God',
    body: 'A 5-step family devotion built into every verse. Read together. Discuss. Pray. Remember. And do it today.',
    quote: '"Read → Discuss → Pray → Remember → Do It"',
  },
];

export default function BenefitsSection() {
  return (
    <section className="bg-[#FFFBF5] py-16 sm:py-20 px-4">
      <div className="max-w-4xl mx-auto">

        {/* Section header */}
        <div className="text-center mb-12">
          <p className="text-amber-500 text-xs font-bold uppercase tracking-[0.2em] mb-3">
            A Discipleship Platform
          </p>
          <h2 className="font-display text-3xl sm:text-4xl font-bold text-stone-800 leading-tight">
            Not just a Bible app.<br />
            <span className="text-amber-600">A way to raise disciples.</span>
          </h2>
          <p className="text-stone-400 text-base mt-4 max-w-lg mx-auto leading-relaxed">
            Built for the window when children form their deepest beliefs about God.
            Ages 4 to 7. Every word faithful to Scripture.
          </p>
        </div>

        {/* Pillars grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {PILLARS.map((p) => (
            <div
              key={p.title}
              className={`benefit-card rounded-3xl p-6 border ${p.color}`}
            >
              <div className={`w-12 h-12 ${p.iconBg} rounded-2xl flex items-center justify-center text-2xl mb-4`}>
                <span aria-hidden="true">{p.icon}</span>
              </div>
              <h3 className="font-extrabold text-stone-800 text-lg mb-2">{p.title}</h3>
              <p className="text-stone-500 text-sm leading-relaxed mb-3">{p.body}</p>
              <p className="text-stone-400 text-xs italic font-devotion">{p.quote}</p>
            </div>
          ))}
        </div>

      </div>
    </section>
  );
}
