import Link from 'next/link';
import AppInterestPanel from './AppInterestPanel';
import { PLAY_STORE_URL } from '@/lib/appStore';

export default function AppInterestBanner() {
  return (
    <section className="py-16 px-4 bg-amber-950">
      <div className="max-w-3xl mx-auto">

        {/* Header */}
        <div className="text-center mb-10">
          <div className="inline-flex items-center gap-2 bg-amber-800/60 rounded-2xl px-4 py-2 border border-amber-700/40 mb-5">
            <span className="text-xl">📱</span>
            <p className="text-amber-300 text-xs font-bold uppercase tracking-widest">
              Out Now on Android
            </p>
          </div>

          <h2
            className="text-3xl sm:text-4xl font-bold text-white mb-4"
            style={{ fontFamily: 'var(--font-display)' }}
          >
            Little Bible for<br />
            <span className="text-amber-300">iPhone &amp; Android</span>
          </h2>

          <p className="text-amber-200/70 text-base max-w-md mx-auto leading-relaxed">
            Little Bible is out now on Google Play. Tell us if you want the
            iPhone version and we&apos;ll send one message when it lands.
          </p>
        </div>

        {/* Panel */}
        <div className="bg-white rounded-3xl p-6 sm:p-8 shadow-2xl">
          <AppInterestPanel compact />
        </div>

        {/* App store badges — Android live, iOS pending */}
        <div className="flex items-center justify-center gap-4 mt-8 flex-wrap">
          <a
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-3 bg-white hover:bg-amber-50 rounded-2xl px-5 py-3 shadow-lg transition-colors"
          >
            <span className="text-2xl">🤖</span>
            <div className="text-left">
              <p className="text-stone-500 text-[10px] font-medium leading-tight">GET IT ON</p>
              <p className="text-stone-900 text-sm font-bold leading-tight">Google Play</p>
            </div>
          </a>

          <div
            className="flex items-center gap-3 bg-white/8 border border-white/12 rounded-2xl px-5 py-3 opacity-60"
            aria-label="App Store — iOS, coming soon"
          >
            <span className="text-2xl">🍎</span>
            <div>
              <p className="text-white text-xs font-semibold">App Store</p>
              <p className="text-amber-400/70 text-[10px] font-medium">iOS — Coming Soon</p>
            </div>
          </div>
        </div>

        <p className="text-center mt-6">
          <Link
            href="/download"
            className="text-amber-400 hover:text-amber-300 text-sm font-semibold underline underline-offset-2 transition-colors"
          >
            Learn more about the app →
          </Link>
        </p>

      </div>
    </section>
  );
}
