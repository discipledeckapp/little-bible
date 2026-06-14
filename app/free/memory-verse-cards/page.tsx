import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Memory Verse Cards — Little Bible',
  description:
    '12 free Bible memory verse cards for children ages 4–7. One key verse per month, with a child-friendly paraphrase and memory tip. Print and stick on the fridge.',
};

const VERSES = [
  {
    month: 'January',
    num: 1,
    ref: 'Psalm 139:14',
    text: '"I am fearfully and wonderfully made."',
    paraphrase: 'God made me on purpose — every part of me!',
    tip: 'Point to yourself when you say "I am." Use your hands for "wonderfully made."',
    theme: 'Identity',
    color: 'bg-amber-50',
    accent: 'text-amber-700',
    border: 'border-amber-200',
    badge: 'bg-amber-100 text-amber-800',
    dot: 'bg-amber-400',
    emoji: '🌍',
  },
  {
    month: 'February',
    num: 2,
    ref: 'John 3:16',
    text: '"For God so loved the world that he gave his one and only Son."',
    paraphrase: 'God loves me so much He sent Jesus for me.',
    tip: 'Hold out your arms wide when you say "so loved." Then bring them to a hug.',
    theme: 'God\'s Love',
    color: 'bg-rose-50',
    accent: 'text-rose-700',
    border: 'border-rose-200',
    badge: 'bg-rose-100 text-rose-800',
    dot: 'bg-rose-400',
    emoji: '❤️',
  },
  {
    month: 'March',
    num: 3,
    ref: 'Psalm 23:1',
    text: '"The Lord is my shepherd; I shall not want."',
    paraphrase: 'God takes care of me like a shepherd takes care of his sheep.',
    tip: 'Pretend to be a shepherd walking with a staff. Then point to yourself for "my shepherd."',
    theme: 'God\'s Care',
    color: 'bg-emerald-50',
    accent: 'text-emerald-700',
    border: 'border-emerald-200',
    badge: 'bg-emerald-100 text-emerald-800',
    dot: 'bg-emerald-400',
    emoji: '🌿',
  },
  {
    month: 'April',
    num: 4,
    ref: 'Matthew 6:9',
    text: '"Our Father in heaven, holy is Your name."',
    paraphrase: 'God is my Father in heaven, and He is holy.',
    tip: 'Look up for "in heaven." Make a reverent bow for "holy is Your name."',
    theme: 'Prayer',
    color: 'bg-purple-50',
    accent: 'text-purple-700',
    border: 'border-purple-200',
    badge: 'bg-purple-100 text-purple-800',
    dot: 'bg-purple-400',
    emoji: '🙏',
  },
  {
    month: 'May',
    num: 5,
    ref: 'Proverbs 3:5',
    text: '"Trust in the Lord with all your heart."',
    paraphrase: 'I trust God completely — with my whole heart.',
    tip: 'Put both hands on your heart when you say "all your heart."',
    theme: 'Trust',
    color: 'bg-sky-50',
    accent: 'text-sky-700',
    border: 'border-sky-200',
    badge: 'bg-sky-100 text-sky-800',
    dot: 'bg-sky-400',
    emoji: '🌤️',
  },
  {
    month: 'June',
    num: 6,
    ref: 'Mark 10:14',
    text: '"Let the children come to me. Don\'t stop them."',
    paraphrase: 'Jesus loves children and always welcomes me.',
    tip: 'Open your arms wide for "come to me." Shake your head gently for "don\'t stop them."',
    theme: 'Jesus Loves Me',
    color: 'bg-teal-50',
    accent: 'text-teal-700',
    border: 'border-teal-200',
    badge: 'bg-teal-100 text-teal-800',
    dot: 'bg-teal-400',
    emoji: '✝️',
  },
  {
    month: 'July',
    num: 7,
    ref: 'Psalm 119:105',
    text: '"Your word is a lamp for my feet, a light on my path."',
    paraphrase: 'The Bible shows me the right way to go, like a light in the dark.',
    tip: 'Walk in place slowly. Pretend to shine a torch on the floor in front of your feet.',
    theme: 'God\'s Word',
    color: 'bg-yellow-50',
    accent: 'text-yellow-700',
    border: 'border-yellow-200',
    badge: 'bg-yellow-100 text-yellow-800',
    dot: 'bg-yellow-400',
    emoji: '💡',
  },
  {
    month: 'August',
    num: 8,
    ref: 'Jeremiah 29:11',
    text: '"For I know the plans I have for you," declares the Lord.',
    paraphrase: 'God has good plans for my life.',
    tip: 'Point upward for "the Lord." Hug yourself and smile for "good plans for you."',
    theme: 'God\'s Plans',
    color: 'bg-stone-50',
    accent: 'text-stone-700',
    border: 'border-stone-200',
    badge: 'bg-stone-100 text-stone-700',
    dot: 'bg-stone-400',
    emoji: '🌱',
  },
  {
    month: 'September',
    num: 9,
    ref: 'Philippians 4:13',
    text: '"I can do all things through Christ who gives me strength."',
    paraphrase: 'With Jesus helping me, I can do hard things.',
    tip: 'Flex your muscles for "strength." Then point up for "through Christ."',
    theme: 'Strength',
    color: 'bg-blue-50',
    accent: 'text-blue-700',
    border: 'border-blue-200',
    badge: 'bg-blue-100 text-blue-800',
    dot: 'bg-blue-400',
    emoji: '💪',
  },
  {
    month: 'October',
    num: 10,
    ref: 'Matthew 22:37',
    text: '"Love the Lord your God with all your heart."',
    paraphrase: 'I love God with everything I have.',
    tip: 'Put your hand over your heart and hold it there the whole time you say it.',
    theme: 'Love God',
    color: 'bg-red-50',
    accent: 'text-red-700',
    border: 'border-red-200',
    badge: 'bg-red-100 text-red-800',
    dot: 'bg-red-400',
    emoji: '🔥',
  },
  {
    month: 'November',
    num: 11,
    ref: 'Matthew 22:39',
    text: '"Love your neighbor as yourself."',
    paraphrase: 'I treat other people the way I want to be treated.',
    tip: 'Point to a person near you for "neighbor." Then point to yourself for "yourself."',
    theme: 'Love Others',
    color: 'bg-orange-50',
    accent: 'text-orange-700',
    border: 'border-orange-200',
    badge: 'bg-orange-100 text-orange-800',
    dot: 'bg-orange-400',
    emoji: '🤝',
  },
  {
    month: 'December',
    num: 12,
    ref: 'Luke 2:11',
    text: '"Today in the town of David a Saviour has been born to you; he is the Messiah, the Lord."',
    paraphrase: 'Jesus is born! He is the Saviour God promised.',
    tip: 'Clap on "today!" Then cradle an imaginary baby for "has been born."',
    theme: 'Christmas',
    color: 'bg-indigo-50',
    accent: 'text-indigo-700',
    border: 'border-indigo-200',
    badge: 'bg-indigo-100 text-indigo-800',
    dot: 'bg-indigo-400',
    emoji: '⭐',
  },
];

export default function MemoryVerseCardsPage() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />

      <main className="flex-1">

        {/* Hero */}
        <section className="bg-gradient-to-b from-emerald-900 via-emerald-800 to-teal-700 py-14 sm:py-18 px-4 text-center">
          <div className="max-w-xl mx-auto">
            <Link
              href="/free"
              className="inline-flex items-center gap-1.5 text-emerald-300/70 hover:text-emerald-200 text-xs font-bold uppercase tracking-widest mb-6 transition-colors"
            >
              ← Free Resources
            </Link>
            <div className="text-5xl mb-4">🌟</div>
            <h1 className="font-display text-3xl sm:text-4xl font-bold text-white mb-4 leading-tight">
              Memory Verse Cards
            </h1>
            <p className="text-emerald-100/80 font-bold text-base mb-2">
              12 Key Verses Every Child Should Know
            </p>
            <p className="text-emerald-200/70 text-sm leading-relaxed mb-6">
              One verse per month, with a child-friendly paraphrase and a fun memory
              action. Read aloud together each morning — it takes under two minutes.
            </p>
            <div className="flex flex-wrap items-center justify-center gap-3">
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">12 Verses</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">Ages 4–7</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">One per Month</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">100% Free</span>
            </div>
          </div>
        </section>

        {/* How to use */}
        <section className="bg-emerald-50 border-b border-emerald-100 py-8 px-4">
          <div className="max-w-2xl mx-auto">
            <h2 className="font-bold text-stone-800 text-sm text-center mb-4 uppercase tracking-wider">How to Use These Cards</h2>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-center">
              {[
                { step: '1', icon: '📌', label: 'Print or save', detail: 'Each card fits on a phone screen or standard A5 paper.' },
                { step: '2', icon: '🌅', label: 'Read it daily', detail: 'Every morning say the verse together — just two minutes.' },
                { step: '3', icon: '🏆', label: 'Celebrate', detail: 'When they can say it alone by month end, celebrate!' },
              ].map(({ step, icon, label, detail }) => (
                <div key={step} className="bg-white rounded-2xl p-5 border border-emerald-100">
                  <p className="text-2xl mb-2">{icon}</p>
                  <p className="font-bold text-stone-800 text-sm mb-1">{step}. {label}</p>
                  <p className="text-stone-500 text-xs leading-relaxed">{detail}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Verse cards */}
        <section className="max-w-2xl mx-auto px-4 py-10 space-y-5">
          <h2 className="font-display text-xl font-bold text-stone-800 mb-6 text-center">
            Your 12 Monthly Verses
          </h2>

          {VERSES.map((v) => (
            <div key={v.num} className={`rounded-3xl border ${v.border} overflow-hidden`}>
              {/* Card header */}
              <div className={`${v.color} px-6 pt-6 pb-4`}>
                <div className="flex items-start justify-between gap-3 mb-4">
                  <div className="flex items-center gap-3">
                    <div className={`w-9 h-9 ${v.dot} rounded-full flex items-center justify-center text-white font-extrabold text-sm flex-shrink-0`}>
                      {v.num}
                    </div>
                    <div>
                      <p className={`${v.accent} text-[10px] font-extrabold uppercase tracking-widest`}>{v.month}</p>
                      <p className="font-bold text-stone-800 text-base leading-tight">{v.emoji} {v.theme}</p>
                    </div>
                  </div>
                  <span className={`text-[10px] font-extrabold uppercase tracking-wide px-2.5 py-1 rounded-full flex-shrink-0 ${v.badge}`}>
                    {v.ref}
                  </span>
                </div>

                {/* Verse */}
                <blockquote className="bg-white/70 rounded-2xl px-4 py-3 border border-white/80 mb-3">
                  <p className="text-stone-700 text-sm font-semibold italic leading-relaxed">
                    {v.text}
                  </p>
                  <p className={`${v.accent} text-[11px] font-extrabold mt-1`}>{v.ref}</p>
                </blockquote>

                {/* Paraphrase */}
                <p className="text-stone-600 text-sm leading-relaxed">
                  <span className="font-bold text-stone-700">In their words:</span> &ldquo;{v.paraphrase}&rdquo;
                </p>
              </div>

              {/* Memory tip */}
              <div className="bg-white px-6 py-4">
                <div className="flex gap-3">
                  <span className="text-lg flex-shrink-0">🎭</span>
                  <div>
                    <p className="text-xs font-extrabold text-stone-500 uppercase tracking-wider mb-1">Memory Action</p>
                    <p className="text-stone-600 text-sm leading-relaxed">{v.tip}</p>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </section>

        {/* CTA */}
        <section className="max-w-2xl mx-auto px-4 pb-12">
          <div className="bg-emerald-50 rounded-3xl p-8 border border-emerald-100 text-center">
            <div className="text-4xl mb-3">📖</div>
            <h2 className="font-display text-2xl font-bold text-stone-800 mb-3">
              Read the stories behind the verses
            </h2>
            <p className="text-stone-500 text-sm leading-relaxed mb-6 max-w-sm mx-auto">
              Every verse here has a story in Little Bible. Help your child see where
              these words come from and why they matter.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
              <Link
                href="/stories"
                className="inline-flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 text-white font-extrabold px-6 py-3 rounded-2xl transition-all active:scale-95 shadow-sm"
              >
                📖 Browse Stories
              </Link>
              <Link
                href="/free/7-day-devotional"
                className="inline-flex items-center gap-2 bg-white hover:bg-stone-50 text-stone-700 font-bold px-6 py-3 rounded-2xl border border-stone-200 transition-all"
              >
                Get the 7-Day Devotional
              </Link>
            </div>
          </div>
        </section>

      </main>

      <Footer />
    </div>
  );
}
