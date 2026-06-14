'use client';

import { useState } from 'react';
import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';

const DAYS = [
  { day: 1, ref: 'Psalm 139:14',  theme: 'God Made You',          href: '/stories/god-made-me',        emoji: '🌍' },
  { day: 2, ref: 'John 3:16',     theme: 'God Loves You',          href: '/genesis/1',                  emoji: '❤️' },
  { day: 3, ref: 'Matthew 6:9',   theme: 'Pray Together',          href: '/stories/how-to-pray',        emoji: '🙏' },
  { day: 4, ref: 'Psalm 23:1',    theme: 'God is Your Shepherd',   href: '/stories/the-good-shepherd',  emoji: '🌿' },
  { day: 5, ref: 'Psalm 119:105', theme: 'Read the Bible',         href: '/proverbs/1',                 emoji: '💡' },
  { day: 6, ref: 'Mark 10:14',    theme: 'Jesus Loves Children',   href: '/stories/jesus-loves-children', emoji: '✝️' },
  { day: 7, ref: 'Jeremiah 29:11','theme': 'You Are Known',        href: '/stories/god-made-me',        emoji: '🌱' },
];

const SHARE_PLATFORMS = [
  { name: 'WhatsApp', icon: '💬', color: 'bg-green-500 hover:bg-green-600' },
  { name: 'Instagram', icon: '📸', color: 'bg-pink-500 hover:bg-pink-600' },
  { name: 'Facebook', icon: '👥', color: 'bg-blue-600 hover:bg-blue-700' },
  { name: 'Copy Link', icon: '🔗', color: 'bg-stone-600 hover:bg-stone-700' },
];

const CAPTION_TEMPLATES = [
  `We're taking the #LittleBibleChallenge! Reading the Bible with our kids every day for 7 days using @littlebible. Join us 👇 littlebible.org/challenge`,
  `Day [X] of the #LittleBibleChallenge! Today we read [VERSE] together. My [AGE]-year-old said "[SOMETHING SWEET]" 😭❤️ littlebible.org`,
  `Sunday school teachers — share this with your class families. The #LittleBibleChallenge gets children reading the Bible daily. Free at littlebible.org/challenge`,
  `If you're a Christian parent, grandparent, or teacher — you need Little Bible. 7 days. 10 minutes each. Life-changing. #LittleBibleChallenge littlebible.org`,
];

export default function ChallengePage() {
  const [completedDays, setCompletedDays] = useState<number[]>([]);
  const [copied, setCopied] = useState(false);

  function toggleDay(day: number) {
    setCompletedDays(prev =>
      prev.includes(day) ? prev.filter(d => d !== day) : [...prev, day]
    );
  }

  function copyLink() {
    navigator.clipboard.writeText('https://littlebible.org/challenge').then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  }

  const daysComplete = completedDays.length;
  const allComplete = daysComplete === 7;

  return (
    <div className="min-h-screen flex flex-col">
      <Header />

      <main className="flex-1">

        {/* Hero */}
        <section className="bg-gradient-to-b from-emerald-900 via-emerald-800 to-teal-700 py-14 px-4 text-center">
          <div className="max-w-xl mx-auto">
            <div className="inline-flex items-center gap-2 bg-white/15 text-white/90 text-xs font-extrabold uppercase tracking-widest px-4 py-2 rounded-full mb-6">
              🌿 The Challenge
            </div>
            <h1 className="font-display text-3xl sm:text-5xl font-bold text-white mb-5 leading-tight">
              #LittleBibleChallenge
            </h1>
            <p className="text-emerald-100/80 text-base sm:text-lg leading-relaxed mb-6 max-w-md mx-auto">
              Read the Bible with your child for 7 days in a row.
              10 minutes each day. Free. No sign-up required.
            </p>
            <p className="text-white/60 text-sm italic">
              &ldquo;Train up a child in the way he should go.&rdquo; — Proverbs 22:6
            </p>
          </div>
        </section>

        {/* Why this matters */}
        <section className="bg-emerald-50 border-b border-emerald-100 py-8 px-4">
          <div className="max-w-2xl mx-auto">
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-center">
              {[
                { stat: '85%', label: 'of lifelong Christians made their faith commitment before age 18' },
                { stat: '4–7', label: 'the critical window when children form their core beliefs' },
                { stat: '7 days', label: 'is enough to start a Bible habit that can last a lifetime' },
              ].map(({ stat, label }) => (
                <div key={stat} className="bg-white rounded-2xl p-5 border border-emerald-100">
                  <p className="font-display text-3xl font-bold text-emerald-600 mb-2">{stat}</p>
                  <p className="text-stone-500 text-xs leading-relaxed">{label}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* The 7 days */}
        <section className="max-w-2xl mx-auto px-4 py-10">
          <h2 className="font-display text-xl font-bold text-stone-800 mb-2 text-center">Your 7-Day Plan</h2>
          <p className="text-stone-400 text-sm text-center mb-6">
            Tap each day when you&apos;ve completed it. {daysComplete > 0 && `${daysComplete}/7 complete 🎉`}
          </p>

          {/* Progress bar */}
          {daysComplete > 0 && (
            <div className="mb-6">
              <div className="h-2 bg-stone-100 rounded-full overflow-hidden">
                <div
                  className="h-full bg-emerald-500 rounded-full transition-all duration-500"
                  style={{ width: `${(daysComplete / 7) * 100}%` }}
                />
              </div>
            </div>
          )}

          <div className="space-y-3">
            {DAYS.map((d) => {
              const done = completedDays.includes(d.day);
              return (
                <div
                  key={d.day}
                  className={`flex items-center gap-4 p-4 rounded-2xl border transition-all ${
                    done
                      ? 'bg-emerald-50 border-emerald-200'
                      : 'bg-white border-stone-200 hover:border-emerald-300'
                  }`}
                >
                  {/* Complete toggle */}
                  <button
                    onClick={() => toggleDay(d.day)}
                    className={`w-8 h-8 rounded-full border-2 flex items-center justify-center flex-shrink-0 font-bold text-sm transition-all ${
                      done
                        ? 'bg-emerald-500 border-emerald-500 text-white'
                        : 'border-stone-300 text-stone-300 hover:border-emerald-400 hover:text-emerald-400'
                    }`}
                    aria-label={`Mark day ${d.day} ${done ? 'incomplete' : 'complete'}`}
                  >
                    {done ? '✓' : d.day}
                  </button>

                  {/* Content */}
                  <div className="flex-1 min-w-0">
                    <p className={`font-bold text-sm ${done ? 'text-emerald-800' : 'text-stone-800'}`}>
                      {d.emoji} Day {d.day}: {d.theme}
                    </p>
                    <p className={`text-xs ${done ? 'text-emerald-600' : 'text-stone-400'}`}>{d.ref}</p>
                  </div>

                  {/* Read link */}
                  <Link
                    href={d.href}
                    className="text-xs font-bold text-emerald-600 hover:text-emerald-800 transition-colors flex-shrink-0"
                  >
                    Read →
                  </Link>
                </div>
              );
            })}
          </div>

          {/* Completion */}
          {allComplete && (
            <div className="mt-6 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-3xl p-6 text-white text-center">
              <div className="text-4xl mb-3">🎉</div>
              <h3 className="font-bold text-xl mb-2">You finished the challenge!</h3>
              <p className="text-white/80 text-sm mb-4">7 days. 7 readings. A habit worth keeping.</p>
              <p className="text-white/70 text-xs">Share this with another family ↓</p>
            </div>
          )}
        </section>

        {/* Share kit */}
        <section className="max-w-2xl mx-auto px-4 pb-8">
          <div className="bg-stone-50 rounded-3xl p-6 border border-stone-200">
            <h2 className="font-bold text-stone-800 text-base mb-1">📣 Share the Challenge</h2>
            <p className="text-stone-500 text-sm mb-4">
              Every family you invite could change a child&apos;s relationship with God.
            </p>

            {/* Share buttons */}
            <div className="flex flex-wrap gap-2 mb-5">
              <button
                onClick={copyLink}
                className="inline-flex items-center gap-1.5 bg-stone-700 hover:bg-stone-800 text-white font-bold text-xs px-4 py-2 rounded-xl transition-all active:scale-95"
              >
                🔗 {copied ? 'Copied!' : 'Copy Link'}
              </button>
              <a
                href={`https://wa.me/?text=${encodeURIComponent("We're taking the #LittleBibleChallenge! Reading the Bible with our kids every day for 7 days. Join us 👇 littlebible.org/challenge")}`}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 bg-green-600 hover:bg-green-700 text-white font-bold text-xs px-4 py-2 rounded-xl transition-all active:scale-95"
              >
                💬 Share on WhatsApp
              </a>
            </div>

            {/* Caption templates */}
            <p className="text-xs font-bold text-stone-400 uppercase tracking-wider mb-3">Ready-to-post captions</p>
            <div className="space-y-2">
              {CAPTION_TEMPLATES.map((caption, i) => (
                <div key={i} className="bg-white rounded-xl p-3 border border-stone-200">
                  <p className="text-stone-600 text-xs leading-relaxed mb-2">{caption}</p>
                  <button
                    onClick={() => { navigator.clipboard.writeText(caption); }}
                    className="text-[10px] font-bold text-emerald-600 hover:text-emerald-800 transition-colors"
                  >
                    Copy caption
                  </button>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Hashtag strategy note */}
        <section className="max-w-2xl mx-auto px-4 pb-12">
          <div className="bg-white rounded-3xl p-6 border border-stone-100">
            <p className="text-xs font-extrabold text-stone-400 uppercase tracking-wider mb-3">Recommended Hashtags</p>
            <div className="flex flex-wrap gap-2">
              {[
                '#LittleBibleChallenge', '#BibleForKids', '#ChristianParenting',
                '#FamilyDevotional', '#ChildrensFaith', '#SundaySchool',
                '#HomeschoolBible', '#FaithForFamilies', '#KidsBible',
                '#LittleBible', '#TeachThemEarly', '#BibleHabits',
              ].map(tag => (
                <span key={tag} className="text-xs font-semibold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2.5 py-1 rounded-full">
                  {tag}
                </span>
              ))}
            </div>
          </div>
        </section>

      </main>

      <Footer />
    </div>
  );
}
