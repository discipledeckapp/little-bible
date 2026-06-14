import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: "Children's Prayer Guide — Little Bible",
  description:
    "Teaching your child to pray in 7 simple steps. A free guide for parents with model prayers, conversation starters, and a daily prayer prompt card for children ages 4–7.",
};

const STEPS = [
  {
    num: 1,
    emoji: '🗣️',
    title: 'Tell them prayer is just talking',
    body: 'Many children think prayer has to sound grown-up or formal. It doesn\'t. Tell them: "Prayer is just talking to God — exactly the way you\'re talking to me right now." No special words. No kneeling required. Just honest conversation.',
    parentTip: 'Pray out loud in front of your child using completely ordinary words. Say "God, I\'m worried about…" or "Thank You for the sun today." Let them hear that prayer sounds normal.',
    modelPrayer: 'God, it\'s me. I just wanted to say thank You for today. I love You. Amen.',
    color: 'bg-amber-50',
    accent: 'text-amber-700',
    border: 'border-amber-200',
    dot: 'bg-amber-400',
  },
  {
    num: 2,
    emoji: '🙏',
    title: 'Teach them the four types of prayer',
    body: 'Children understand prayer better when they see there are different kinds. Use the word ACTS as a simple anchor: Adoration (praising God), Confession (saying sorry), Thanksgiving (saying thank You), and Supplication (asking for things).',
    parentTip: 'Don\'t teach all four at once. Start with Thanksgiving — it\'s the most natural for young children. Add one per week.',
    modelPrayer: 'God, You are so great. I\'m sorry for being mean today. Thank You for my family. Please help my friend feel better. Amen.',
    color: 'bg-purple-50',
    accent: 'text-purple-700',
    border: 'border-purple-200',
    dot: 'bg-purple-400',
  },
  {
    num: 3,
    emoji: '📅',
    title: 'Give prayer a regular time',
    body: 'Young children build habits through rhythm. Pick one consistent moment: at breakfast, before bed, or in the car on the way to school. When prayer has a regular time, it stops feeling like a chore and starts feeling like part of the day.',
    parentTip: 'Bedtime is the easiest anchor for most families. It\'s calm, there\'s no rush, and it doubles as a settling ritual. Keep the prayer short — under 60 seconds — to hold their attention.',
    modelPrayer: 'God, thank You for this day. Thank You for [three things from today]. Help me sleep well. I love You. Amen.',
    color: 'bg-sky-50',
    accent: 'text-sky-700',
    border: 'border-sky-200',
    dot: 'bg-sky-400',
  },
  {
    num: 4,
    emoji: '👂',
    title: 'Teach them to listen',
    body: 'Prayer isn\'t just talking — it\'s also listening. Teach your child to sit quietly for a few seconds after they pray. Say: "Now let\'s be still and see if God wants to say anything to our hearts." They may not hear a voice — but cultivating stillness is itself a gift.',
    parentTip: 'After prayer, ask: "Did any thoughts come into your mind?" Validate anything they share. God often speaks through imagination, peace, and quiet nudges — not dramatic voices.',
    modelPrayer: 'God, I\'m going to be quiet now. Is there anything You want me to know today? [5 seconds of silence] Amen.',
    color: 'bg-emerald-50',
    accent: 'text-emerald-700',
    border: 'border-emerald-200',
    dot: 'bg-emerald-400',
  },
  {
    num: 5,
    emoji: '❤️',
    title: 'Pray about real feelings',
    body: 'Children are honest. Encourage them to bring whatever they actually feel to God — including anger, fear, sadness, and confusion. The Psalms are full of honest, raw prayers. Pray with your child about their real feelings, not the feelings you wish they had.',
    parentTip: 'If your child says "I\'m angry at God" — don\'t correct it. Say: "Tell Him." Honest prayers are more powerful than polite ones. God can handle their feelings.',
    modelPrayer: 'God, I felt sad today when… I felt scared about… I felt angry because… You know how I feel. Help me. Amen.',
    color: 'bg-rose-50',
    accent: 'text-rose-700',
    border: 'border-rose-200',
    dot: 'bg-rose-400',
  },
  {
    num: 6,
    emoji: '🌍',
    title: 'Pray for others',
    body: 'When children learn to pray for others, they develop empathy alongside faith. Help them build a small "prayer list" — three to five people they care about. Review it weekly and celebrate when prayers are answered.',
    parentTip: 'Include non-family members: a teacher, a friend, a neighbour. Bring global concerns down to child-scale: "There are children in [place] who need food — let\'s ask God to help them."',
    modelPrayer: 'God, please help [name]. I know they are having a hard time. Please be close to them today. Amen.',
    color: 'bg-teal-50',
    accent: 'text-teal-700',
    border: 'border-teal-200',
    dot: 'bg-teal-400',
  },
  {
    num: 7,
    emoji: '✝️',
    title: 'Pray in Jesus\' name — and explain why',
    body: '"In Jesus\' name, Amen" is not a magic phrase. Explain it simply: "We pray in Jesus\' name because Jesus is the one who made it possible for us to talk to God. He is our way in." This plants a seed of theology that can grow for a lifetime.',
    parentTip: 'Children who understand why they say "in Jesus\' name" are more likely to hold onto their faith as they grow. Don\'t just teach the phrase — teach the Person.',
    modelPrayer: 'Thank You, Jesus, that because of You, I can talk to God. In Your name, Amen.',
    color: 'bg-stone-50',
    accent: 'text-stone-700',
    border: 'border-stone-200',
    dot: 'bg-stone-400',
  },
];

const DAILY_PROMPTS = [
  { day: 'Monday',    prompt: 'Thank God for one thing about your body — something He made that works amazingly.' },
  { day: 'Tuesday',  prompt: 'Ask God to help a friend or someone in your class who might be having a hard week.' },
  { day: 'Wednesday',prompt: 'Tell God about something that made you feel sad or worried this week.' },
  { day: 'Thursday', prompt: 'Praise God — just tell Him how great He is. No asking for anything, just praise.' },
  { day: 'Friday',   prompt: 'Say sorry for one thing you did this week that you wish you hadn\'t.' },
  { day: 'Saturday', prompt: 'Pray for your family — name each person and ask God to bless them today.' },
  { day: 'Sunday',   prompt: 'Thank God for Jesus. In your own words, tell God what Jesus means to you.' },
];

export default function PrayerGuidePage() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />

      <main className="flex-1">

        {/* Hero */}
        <section className="bg-gradient-to-b from-purple-900 via-purple-800 to-violet-700 py-14 sm:py-18 px-4 text-center">
          <div className="max-w-xl mx-auto">
            <Link
              href="/free"
              className="inline-flex items-center gap-1.5 text-purple-300/70 hover:text-purple-200 text-xs font-bold uppercase tracking-widest mb-6 transition-colors"
            >
              ← Free Resources
            </Link>
            <div className="text-5xl mb-4">🙏</div>
            <h1 className="font-display text-3xl sm:text-4xl font-bold text-white mb-4 leading-tight">
              Children&apos;s Prayer Guide
            </h1>
            <p className="text-purple-100/80 font-bold text-base mb-2">
              Teaching Your Child to Pray in 7 Simple Steps
            </p>
            <p className="text-purple-200/70 text-sm leading-relaxed mb-6">
              A practical guide for parents who want to help their child develop a
              real prayer life — not just a rote one. Includes model prayers,
              conversation starters, and a daily prompt card.
            </p>
            <div className="flex flex-wrap items-center justify-center gap-3">
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">7 Steps</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">Ages 4–7</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">Model Prayers</span>
              <span className="bg-white/15 text-white text-xs font-bold px-3 py-1.5 rounded-full">100% Free</span>
            </div>
          </div>
        </section>

        {/* Intro */}
        <section className="bg-purple-50 border-b border-purple-100 py-8 px-4">
          <div className="max-w-2xl mx-auto text-center">
            <p className="text-stone-600 text-sm leading-relaxed max-w-lg mx-auto">
              Most parents want their children to pray — but few were taught <em>how</em> to
              teach it. This guide gives you everything you need: simple explanations,
              model prayers to borrow, and parent tips for each step.
            </p>
          </div>
        </section>

        {/* Steps */}
        <section className="max-w-2xl mx-auto px-4 py-10 space-y-6">
          <h2 className="font-display text-xl font-bold text-stone-800 mb-6 text-center">
            7 Steps to a Real Prayer Life
          </h2>

          {STEPS.map((s) => (
            <div key={s.num} className={`rounded-3xl border ${s.border} overflow-hidden`}>
              {/* Header */}
              <div className={`${s.color} px-6 pt-6 pb-4`}>
                <div className="flex items-center gap-3 mb-4">
                  <div className={`w-9 h-9 ${s.dot} rounded-full flex items-center justify-center text-white font-extrabold text-sm flex-shrink-0`}>
                    {s.num}
                  </div>
                  <div>
                    <p className={`${s.accent} text-[10px] font-extrabold uppercase tracking-widest`}>Step {s.num}</p>
                    <h2 className="font-bold text-stone-800 text-base leading-tight">
                      {s.emoji} {s.title}
                    </h2>
                  </div>
                </div>
                <p className="text-stone-600 text-sm leading-relaxed">{s.body}</p>
              </div>

              {/* Cards */}
              <div className="bg-white px-6 pb-6 pt-4 space-y-4">
                {/* Parent tip */}
                <div className="flex gap-3">
                  <span className="text-lg flex-shrink-0 mt-0.5">👨‍👩‍👧</span>
                  <div>
                    <p className="text-xs font-extrabold text-stone-500 uppercase tracking-wider mb-1">Parent Tip</p>
                    <p className="text-stone-600 text-sm leading-relaxed">{s.parentTip}</p>
                  </div>
                </div>

                {/* Model prayer */}
                <div className="bg-stone-50 rounded-2xl p-4 border border-stone-100">
                  <p className="text-xs font-extrabold text-stone-400 uppercase tracking-wider mb-2">🙏 Model Prayer</p>
                  <p className="text-stone-600 text-sm italic leading-relaxed">{s.modelPrayer}</p>
                </div>
              </div>
            </div>
          ))}
        </section>

        {/* Daily prompt card */}
        <section className="max-w-2xl mx-auto px-4 pb-10">
          <div className="bg-purple-50 rounded-3xl border border-purple-100 overflow-hidden">
            <div className="bg-gradient-to-r from-purple-600 to-violet-600 px-6 py-5 text-white">
              <h2 className="font-bold text-lg mb-1">📋 Daily Prayer Prompt Card</h2>
              <p className="text-purple-100/80 text-sm">One prompt per day of the week. Cut it out or save it to your phone.</p>
            </div>
            <div className="px-6 py-5 space-y-3">
              {DAILY_PROMPTS.map(({ day, prompt }) => (
                <div key={day} className="flex items-start gap-3">
                  <span className="font-extrabold text-purple-600 text-xs w-20 flex-shrink-0 pt-0.5">{day}</span>
                  <p className="text-stone-600 text-sm leading-relaxed">{prompt}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* CTA */}
        <section className="max-w-2xl mx-auto px-4 pb-12">
          <div className="bg-amber-50 rounded-3xl p-8 border border-amber-100 text-center">
            <div className="text-4xl mb-3">📖</div>
            <h2 className="font-display text-2xl font-bold text-stone-800 mb-3">
              Pair prayer with Scripture
            </h2>
            <p className="text-stone-500 text-sm leading-relaxed mb-6 max-w-sm mx-auto">
              The best prayers are rooted in God&apos;s Word. The 7-Day Family Devotional
              and the Bible stories on Little Bible give your child the Scripture to pray from.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
              <Link
                href="/free/7-day-devotional"
                className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-6 py-3 rounded-2xl transition-all active:scale-95 shadow-sm"
              >
                📖 Get the Devotional
              </Link>
              <Link
                href="/stories"
                className="inline-flex items-center gap-2 bg-white hover:bg-stone-50 text-stone-700 font-bold px-6 py-3 rounded-2xl border border-stone-200 transition-all"
              >
                Browse Bible Stories
              </Link>
            </div>
          </div>
        </section>

      </main>

      <Footer />
    </div>
  );
}
