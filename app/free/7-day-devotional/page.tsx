import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: '7-Day Family Devotional — Little Bible',
  description:
    'A free 7-day family devotional for children ages 4–7. Each day: a Bible verse, simple explanation, family activity, and prayer. Read together in under 10 minutes.',
};

const DAYS = [
  {
    day: 1,
    emoji: '🌍',
    title: 'God Made You',
    verse: 'Psalm 139:14',
    verseText: '"I am fearfully and wonderfully made." — Psalm 139:14',
    littleBible: 'God carefully made every part of you — your hands, your heart, your laugh, your voice. You are not an accident. You are His work.',
    parentNote: 'Children ages 4–7 are developing their sense of identity. Today\'s truth — that they were made on purpose by a personal God — is foundational to everything else they will believe about themselves.',
    activity: 'Take turns saying one thing you love about each person in the family. Then say: "God made that about you!"',
    prayer: 'God, thank You for making [child\'s name]. Thank You that You made every part of them on purpose. Help them to know how special they are to You. Amen.',
    color: 'bg-amber-50',
    accent: 'text-amber-600',
    border: 'border-amber-200',
    dot: 'bg-amber-400',
  },
  {
    day: 2,
    emoji: '❤️',
    title: 'God Loves You',
    verse: 'John 3:16',
    verseText: '"For God so loved the world that he gave his one and only Son." — John 3:16',
    littleBible: 'God loves the whole world — and that includes YOU. He loves you so much that He sent Jesus, His own Son, to show us how much.',
    parentNote: 'John 3:16 is the most important sentence in the Bible. Don\'t rush past it. Ask your child: "Can you think of something you love SO much you would do anything for it?" Help them connect love to sacrifice.',
    activity: 'Hug your child tight and say: "That\'s a little bit of how much God loves you — but God\'s love is even bigger than this hug."',
    prayer: 'Father, thank You for loving [child\'s name] so much. Thank You for sending Jesus. Help them feel Your love today — everywhere they go. Amen.',
    color: 'bg-rose-50',
    accent: 'text-rose-600',
    border: 'border-rose-200',
    dot: 'bg-rose-400',
  },
  {
    day: 3,
    emoji: '🙏',
    title: 'You Can Talk to God',
    verse: 'Matthew 6:9',
    verseText: '"Our Father in heaven, holy is Your name." — Matthew 6:9',
    littleBible: 'Jesus taught His friends how to pray. Prayer is just talking to God — like talking to a friend who loves you and is always listening.',
    parentNote: 'Many adults are afraid to pray out loud because no one taught them it was simple. Model simple, honest prayer today. Let your child hear you talk to God like He\'s right there.',
    activity: 'Pray the Lord\'s Prayer together slowly, one line at a time. Pause and ask: "What do you think that means?"',
    prayer: 'God, thank You that we can talk to You any time. Teach [child\'s name] to pray. Help them know You are always listening. Amen.',
    color: 'bg-purple-50',
    accent: 'text-purple-600',
    border: 'border-purple-200',
    dot: 'bg-purple-400',
  },
  {
    day: 4,
    emoji: '🌿',
    title: 'God is Always With You',
    verse: 'Psalm 23:1',
    verseText: '"The Lord is my shepherd; I shall not want." — Psalm 23:1',
    littleBible: 'A shepherd takes care of his sheep every single day. He never leaves them alone. Jesus is our shepherd — He takes care of us every day too.',
    parentNote: 'Separation anxiety is real for young children. Psalm 23 is medicine for it. Returning to this psalm throughout childhood builds deep security.',
    activity: 'Ask: "Can you think of a time you were scared or worried?" Then say: "God was with you then too, even when you couldn\'t feel it."',
    prayer: 'Lord, be our shepherd today. Help [child\'s name] feel safe and cared for — at home, at school, and everywhere in between. Amen.',
    color: 'bg-emerald-50',
    accent: 'text-emerald-600',
    border: 'border-emerald-200',
    dot: 'bg-emerald-400',
  },
  {
    day: 5,
    emoji: '💡',
    title: "God's Word is a Light",
    verse: 'Psalm 119:105',
    verseText: '"Your word is a lamp for my feet, a light on my path." — Psalm 119:105',
    littleBible: 'The Bible is like a torch in a dark room. When you don\'t know what to do, the Bible shows you the way. It doesn\'t just explain things — it lights up the path.',
    parentNote: 'This is a good day to talk about why your family reads the Bible. Children need to understand it\'s not just a school subject — it\'s a guide for life.',
    activity: 'Turn off the lights (or go somewhere darker) and use a torch. Say: "The Bible is like this for our lives."',
    prayer: 'God, thank You for Your Word. Help [child\'s name] love the Bible and trust it as they grow up. Make it a light for every decision they ever face. Amen.',
    color: 'bg-yellow-50',
    accent: 'text-yellow-700',
    border: 'border-yellow-200',
    dot: 'bg-yellow-400',
  },
  {
    day: 6,
    emoji: '✝️',
    title: 'Jesus Loves Children',
    verse: 'Mark 10:14',
    verseText: '"Let the children come to me. Don\'t stop them." — Mark 10:14',
    littleBible: 'One day, some parents brought their children to Jesus. His friends tried to send the children away. But Jesus said: No. Bring them to me. Children are important to Jesus.',
    parentNote: 'Jesus said something radical for His time — children matter now, not just when they grow up. Your child is already at the right age to know Jesus personally.',
    activity: 'Ask your child: "If Jesus was sitting here right now, what would you say to Him?" Listen without interrupting.',
    prayer: 'Jesus, thank You for loving children. Thank You for welcoming [child\'s name] just as they are. Draw them close to You. Amen.',
    color: 'bg-sky-50',
    accent: 'text-sky-600',
    border: 'border-sky-200',
    dot: 'bg-sky-400',
  },
  {
    day: 7,
    emoji: '🌱',
    title: 'You Can Know God',
    verse: 'Jeremiah 29:11',
    verseText: '"For I know the plans I have for you," declares the Lord. — Jeremiah 29:11',
    littleBible: 'God knows your name, your future, and your heart. He had a plan for you before you were born. You are not lost — you are known.',
    parentNote: 'End the week with assurance. Your child now knows they were made on purpose, loved eternally, can talk to God, are never alone, have His Word, and are welcomed by Jesus. Today, remind them: God has a plan for them.',
    activity: 'Ask: "What do you think God\'s plan for you might be?" Dream together — big and small. Then pray it over them.',
    prayer: 'Lord, thank You for having plans for [child\'s name] — good plans, hopeful plans. Help them discover who You made them to be, and never forget how loved they are. Amen.',
    color: 'bg-stone-50',
    accent: 'text-stone-600',
    border: 'border-stone-200',
    dot: 'bg-stone-400',
  },
];

export default function DevotionalPage() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />

      <main className="flex-1">

        {/* Hero */}
        <section className="bg-gradient-to-b from-amber-900 via-amber-800 to-amber-700 py-14 sm:py-18 px-4 text-center">
          <div className="max-w-xl mx-auto">
            <Link
              href="/free"
              className="inline-flex items-center gap-1.5 text-amber-300/70 hover:text-amber-200 text-xs font-bold uppercase tracking-widest mb-6 transition-colors"
            >
              ← Free Resources
            </Link>
            <div className="text-5xl mb-4">📖</div>
            <h1 className="font-display text-3xl sm:text-4xl font-bold text-white mb-4 leading-tight">
              7-Day Family Devotional
            </h1>
            <p className="text-amber-100/80 font-bold text-base mb-2">
              God Loves Me — A First Journey Through Scripture
            </p>
            <p className="text-amber-200/70 text-sm leading-relaxed mb-6">
              Seven short readings for children ages 4–7. Each day takes under 10 minutes.
              No theology degree required — just you, your child, and God&apos;s Word.
            </p>
            <div className="flex flex-wrap items-center justify-center gap-3">
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">Ages 4–7</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">10 min/day</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">100% Free</span>
            </div>
          </div>
        </section>

        {/* Days */}
        <section className="max-w-2xl mx-auto px-4 py-10 space-y-8">

          {DAYS.map((d) => (
            <div key={d.day} className={`rounded-3xl border ${d.border} overflow-hidden`}>
              {/* Day header */}
              <div className={`${d.color} px-6 pt-6 pb-4`}>
                <div className="flex items-center gap-3 mb-3">
                  <div className={`w-8 h-8 ${d.dot} rounded-full flex items-center justify-center text-white font-extrabold text-sm flex-shrink-0`}>
                    {d.day}
                  </div>
                  <div>
                    <p className={`${d.accent} text-[10px] font-extrabold uppercase tracking-widest`}>Day {d.day}</p>
                    <h2 className="font-bold text-stone-800 text-lg leading-tight">
                      {d.emoji} {d.title}
                    </h2>
                  </div>
                </div>

                {/* Verse */}
                <blockquote className="bg-white/70 rounded-2xl px-4 py-3 border border-white/80 mb-3">
                  <p className="text-stone-700 text-sm font-devotion italic leading-relaxed">
                    {d.verseText}
                  </p>
                </blockquote>

                {/* Little Bible version */}
                <p className="text-stone-600 text-sm leading-relaxed">
                  <span className="font-bold text-stone-700">For your child:</span> {d.littleBible}
                </p>
              </div>

              {/* Cards */}
              <div className="bg-white px-6 pb-6 pt-4 space-y-3">

                {/* Parent note */}
                <div className="flex gap-3">
                  <span className="text-lg flex-shrink-0 mt-0.5">👨‍👩‍👧</span>
                  <div>
                    <p className="text-xs font-extrabold text-stone-500 uppercase tracking-wider mb-1">Parent Note</p>
                    <p className="text-stone-600 text-sm leading-relaxed">{d.parentNote}</p>
                  </div>
                </div>

                {/* Activity */}
                <div className="flex gap-3">
                  <span className="text-lg flex-shrink-0 mt-0.5">🎯</span>
                  <div>
                    <p className="text-xs font-extrabold text-stone-500 uppercase tracking-wider mb-1">Family Activity</p>
                    <p className="text-stone-600 text-sm leading-relaxed">{d.activity}</p>
                  </div>
                </div>

                {/* Prayer */}
                <div className="bg-stone-50 rounded-2xl p-4 border border-stone-100">
                  <p className="text-xs font-extrabold text-stone-400 uppercase tracking-wider mb-2">🙏 Today&apos;s Prayer</p>
                  <p className="text-stone-600 text-sm italic leading-relaxed">{d.prayer}</p>
                </div>

                {/* Read more */}
                {d.day === 1 && (
                  <Link href="/stories/god-made-me" className={`inline-flex items-center gap-1.5 text-xs font-bold ${d.accent} hover:opacity-80 transition-opacity`}>
                    📖 Read the full story on Little Bible →
                  </Link>
                )}
                {d.day === 4 && (
                  <Link href="/stories/the-good-shepherd" className={`inline-flex items-center gap-1.5 text-xs font-bold ${d.accent} hover:opacity-80 transition-opacity`}>
                    📖 Read The Good Shepherd →
                  </Link>
                )}
                {d.day === 6 && (
                  <Link href="/stories/jesus-loves-children" className={`inline-flex items-center gap-1.5 text-xs font-bold ${d.accent} hover:opacity-80 transition-opacity`}>
                    📖 Read Jesus Loves Children →
                  </Link>
                )}
              </div>
            </div>
          ))}
        </section>

        {/* What's next */}
        <section className="max-w-2xl mx-auto px-4 pb-12">
          <div className="bg-amber-50 rounded-3xl p-8 border border-amber-100 text-center">
            <div className="text-4xl mb-3">🌱</div>
            <h2 className="font-display text-2xl font-bold text-stone-800 mb-3">
              You finished the 7-day devotional!
            </h2>
            <p className="text-stone-500 text-sm leading-relaxed mb-6 max-w-sm mx-auto">
              Keep the habit going. Little Bible has 22 stories, guided journeys,
              memory verses, and the full Bible — all adapted for your child.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
              <Link
                href="/journeys/god-loves-me"
                className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-6 py-3 rounded-2xl transition-all active:scale-95 shadow-sm"
              >
                🌿 Continue the Journey
              </Link>
              <Link
                href="/challenge"
                className="inline-flex items-center gap-2 bg-white hover:bg-stone-50 text-stone-700 font-bold px-6 py-3 rounded-2xl border border-stone-200 transition-all"
              >
                Take the #LittleBibleChallenge
              </Link>
            </div>
          </div>
        </section>

      </main>

      <Footer />
    </div>
  );
}
