import Link from 'next/link';
import AppInterestPanel from './AppInterestPanel';

export default function AppInterestBanner() {
  return (
    <section className="py-16 px-4 bg-amber-950">
      <div className="max-w-3xl mx-auto">

        {/* Header */}
        <div className="text-center mb-10">
          <div className="inline-flex items-center gap-2 bg-amber-800/60 rounded-2xl px-4 py-2 border border-amber-700/40 mb-5">
            <span className="text-xl">📱</span>
            <p className="text-amber-300 text-xs font-bold uppercase tracking-widest">
              Coming to Your Phone
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
            The app is in development. Be the first to know when it launches
            on your platform — no marketing, just one message.
          </p>
        </div>

        {/* Panel */}
        <div className="bg-white rounded-3xl p-6 sm:p-8 shadow-2xl">
          <AppInterestPanel compact />
        </div>

        {/* App store badges — coming soon */}
        <div className="flex items-center justify-center gap-4 mt-8">
          {[
            { icon: '🍎', label: 'App Store',    sub: 'iOS — Coming Soon'     },
            { icon: '🤖', label: 'Google Play',  sub: 'Android — Coming Soon' },
          ].map(b => (
            <div
              key={b.label}
              className="flex items-center gap-3 bg-white/8 border border-white/12 rounded-2xl px-5 py-3 opacity-60"
              aria-label={`${b.label} — ${b.sub}`}
            >
              <span className="text-2xl">{b.icon}</span>
              <div>
                <p className="text-white text-xs font-semibold">{b.label}</p>
                <p className="text-amber-400/70 text-[10px] font-medium">{b.sub}</p>
              </div>
            </div>
          ))}
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
