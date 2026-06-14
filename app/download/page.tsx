import type { Metadata } from 'next';
import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import LumiMascot from '@/components/mascot/LumiMascot';
import AppInterestPanel from '@/components/app-interest/AppInterestPanel';

export const metadata: Metadata = {
  title: 'Get the App — Little Bible',
  description:
    'Little Bible is coming to iPhone and Android. Be the first to know when it launches — all 66 books of Scripture for little hearts, on your phone.',
};

const FEATURES = [
  { icon: '📖', title: 'Offline reading',     desc: 'Read every verse without an internet connection.' },
  { icon: '🔊', title: 'Audio narration',      desc: 'Hear God\'s Word read aloud to your child.' },
  { icon: '🌱', title: 'Lumi & family progress', desc: 'Watch Lumi grow as your family reads together.' },
  { icon: '🙏', title: 'Family devotions',     desc: 'Read, discuss, pray, and remember — together.' },
  { icon: '🔔', title: 'Daily reminders',      desc: 'Gentle nudges to keep your streak going.' },
  { icon: '👨‍👩‍👧', title: 'Multiple children',    desc: 'One app for every child in your family.' },
];

export default function DownloadPage() {
  return (
    <div className="min-h-screen flex flex-col bg-[var(--color-background)]">
      <Header />

      {/* ── Hero ── */}
      <section className="hero-bg py-16 px-4 text-center">
        <div className="max-w-2xl mx-auto">
          {/* Lumi — tree-of-life (aspirational) */}
          <div className="flex justify-center mb-6">
            <LumiMascot stage="tree-of-life" className="w-32 h-32 sm:w-40 sm:h-40" animate />
          </div>

          <div className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm rounded-2xl px-4 py-2 border border-white/15 mb-6">
            <span className="text-base">📱</span>
            <p className="text-amber-200 text-xs font-bold tracking-wide uppercase">App Coming Soon</p>
          </div>

          <h1
            className="text-4xl sm:text-5xl font-bold text-white mb-4 leading-tight"
            style={{ fontFamily: 'var(--font-display)' }}
          >
            Little Bible<br />
            <span className="text-amber-300">for Your Phone</span>
          </h1>

          <p className="text-amber-100/80 text-lg leading-relaxed mb-6 max-w-md mx-auto">
            All 66 books of Scripture, faithfully adapted for children ages 4–7.
            We&apos;re building the app — be the first to know when it launches.
          </p>

          {/* App store badges — coming soon */}
          <div className="flex items-center justify-center gap-3 mb-8">
            {[
              { icon: '🍎', name: 'App Store',   sub: 'iOS · Coming Soon'     },
              { icon: '🤖', name: 'Google Play', sub: 'Android · Coming Soon' },
            ].map(b => (
              <div
                key={b.name}
                className="flex items-center gap-2.5 bg-white/10 border border-white/15 rounded-2xl px-5 py-3 opacity-70"
              >
                <span className="text-2xl">{b.icon}</span>
                <div className="text-left">
                  <p className="text-white text-xs font-bold leading-tight">{b.name}</p>
                  <p className="text-amber-300/70 text-[10px] font-medium">{b.sub}</p>
                </div>
              </div>
            ))}
          </div>

          <p className="text-amber-400/60 text-sm">
            Meanwhile —{' '}
            <Link href="/" className="text-amber-300 hover:text-white font-semibold underline underline-offset-2 transition-colors">
              read free on the web →
            </Link>
          </p>
        </div>
      </section>

      {/* ── App Interest Form ── */}
      <section className="py-14 px-4 bg-[var(--color-warm-cream)]">
        <div className="max-w-lg mx-auto">
          <div className="text-center mb-8">
            <h2
              className="text-2xl sm:text-3xl font-bold text-stone-800 mb-2"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              Save Your Preferences
            </h2>
            <p className="text-stone-500 text-sm leading-relaxed">
              Tell us which platform you want and how to notify you.
              This is a product preference, not a marketing list.
            </p>
          </div>
          <div className="bg-white rounded-3xl p-6 sm:p-8 shadow-md border border-stone-100">
            <AppInterestPanel />
          </div>
        </div>
      </section>

      {/* ── What's coming in the app ── */}
      <section className="py-14 px-4 bg-white">
        <div className="max-w-3xl mx-auto">
          <div className="text-center mb-10">
            <p className="text-xs font-bold text-amber-600 uppercase tracking-widest mb-2">Coming in the app</p>
            <h2
              className="text-2xl sm:text-3xl font-bold text-stone-800"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              Everything you love, on your phone
            </h2>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {FEATURES.map(f => (
              <div key={f.title} className="flex items-start gap-4 p-4 rounded-2xl bg-stone-50 border border-stone-100">
                <div className="w-11 h-11 rounded-xl bg-amber-100 flex items-center justify-center text-xl flex-shrink-0">
                  {f.icon}
                </div>
                <div>
                  <p className="font-bold text-stone-800 text-sm mb-1">{f.title}</p>
                  <p className="text-stone-500 text-xs leading-relaxed">{f.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Read now on web ── */}
      <section className="py-12 px-4 bg-amber-50 border-t border-amber-100">
        <div className="max-w-xl mx-auto text-center">
          <p className="text-2xl mb-3">📖</p>
          <h3 className="font-bold text-stone-800 text-xl mb-2" style={{ fontFamily: 'var(--font-display)' }}>
            The web version is free, right now
          </h3>
          <p className="text-stone-500 text-sm mb-6 leading-relaxed">
            Don&apos;t wait for the app. All 66 books are available on the web today,
            on any device, for free.
          </p>
          <Link
            href="/"
            className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-7 py-3.5 rounded-2xl transition-all active:scale-95 shadow-md focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
          >
            Start Reading Now
            <span aria-hidden="true">→</span>
          </Link>
        </div>
      </section>

      <Footer />
    </div>
  );
}
