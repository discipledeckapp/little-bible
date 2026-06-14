import Link from 'next/link';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Page Not Found — Little Bible',
  description: 'This page does not exist. Browse Bible stories, journeys, and Scripture adapted for children ages 4–7.',
};

export default function NotFound() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-amber-50 to-white flex flex-col items-center justify-center px-4 py-16">
      <div className="max-w-md w-full text-center">

        {/* Logo mark */}
        <Link
          href="/"
          className="inline-flex items-center gap-2.5 mb-10 group"
          aria-label="Little Bible — Home"
        >
          <div className="w-10 h-10 bg-amber-500 group-hover:bg-amber-600 transition-colors rounded-2xl flex items-center justify-center text-xl shadow-sm">
            📖
          </div>
          <span className="font-bold text-amber-900 text-lg">Little Bible</span>
        </Link>

        {/* Lumi mascot */}
        <div className="text-8xl mb-4 select-none" role="img" aria-label="Lumi the wisdom seed">
          🌱
        </div>

        {/* Heading */}
        <h1 className="font-bold text-stone-800 text-2xl sm:text-3xl mb-3 leading-tight">
          This page doesn&apos;t exist yet
        </h1>
        <p className="text-stone-500 text-base leading-relaxed mb-2 max-w-sm mx-auto">
          You might have followed a broken link, or this content hasn&apos;t been added to Little Bible yet.
        </p>
        <p className="text-stone-400 text-sm mb-8">
          We&apos;re working through all 66 books of Scripture — more is coming!
        </p>

        {/* Primary CTA */}
        <Link
          href="/"
          className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-8 py-3.5 rounded-2xl transition-all active:scale-95 shadow-sm mb-4 w-full sm:w-auto justify-center"
        >
          🏠 Go Home
        </Link>

        {/* Secondary actions */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 mt-2">
          <Link
            href="/stories"
            className="flex items-center justify-center gap-1.5 bg-white hover:bg-amber-50 text-stone-700 font-bold text-sm px-4 py-3 rounded-2xl border border-stone-200 hover:border-amber-300 transition-all active:scale-95"
          >
            ✨ Stories
          </Link>
          <Link
            href="/genesis/1"
            className="flex items-center justify-center gap-1.5 bg-white hover:bg-amber-50 text-stone-700 font-bold text-sm px-4 py-3 rounded-2xl border border-stone-200 hover:border-amber-300 transition-all active:scale-95"
          >
            📖 Read Bible
          </Link>
          <Link
            href="/journeys"
            className="flex items-center justify-center gap-1.5 bg-white hover:bg-amber-50 text-stone-700 font-bold text-sm px-4 py-3 rounded-2xl border border-stone-200 hover:border-amber-300 transition-all active:scale-95"
          >
            🌿 Journeys
          </Link>
        </div>

        {/* Start reading suggestions */}
        <div className="mt-10 pt-8 border-t border-amber-100">
          <p className="text-stone-400 text-xs font-bold uppercase tracking-widest mb-4">
            Good places to start
          </p>
          <div className="flex flex-wrap items-center justify-center gap-2">
            {[
              { href: '/proverbs/1',        label: '✨ Proverbs' },
              { href: '/genesis/1',         label: '🌍 Genesis' },
              { href: '/stories/jesus-loves-children', label: '❤️ Jesus Loves Children' },
              { href: '/topics',            label: '🏷 Browse Topics' },
              { href: '/journeys/god-loves-me', label: '🌱 God Loves Me' },
            ].map(({ href, label }) => (
              <Link
                key={href}
                href={href}
                className="text-xs font-semibold text-amber-700 hover:text-amber-900 bg-amber-50 hover:bg-amber-100 px-3 py-1.5 rounded-full border border-amber-200 hover:border-amber-400 transition-all"
              >
                {label}
              </Link>
            ))}
          </div>
        </div>

        {/* Support link */}
        <p className="text-stone-400 text-xs mt-8">
          Think something&apos;s broken?{' '}
          <a
            href="mailto:hello@littlebible.org"
            className="text-amber-600 hover:text-amber-800 underline"
          >
            Let us know
          </a>
        </p>

      </div>
    </div>
  );
}
