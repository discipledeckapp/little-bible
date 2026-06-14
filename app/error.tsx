'use client';

import { useEffect } from 'react';
import Link from 'next/link';

interface Props {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function GlobalError({ error, reset }: Props) {
  useEffect(() => {
    // Log to console in development; swap for your analytics/monitoring here
    console.error('[Little Bible] Unhandled error:', error);
  }, [error]);

  return (
    <div className="min-h-screen bg-gradient-to-b from-stone-50 to-white flex flex-col items-center justify-center px-4 py-16">
      <div className="max-w-md w-full text-center">

        {/* Logo */}
        <Link href="/" className="inline-flex items-center gap-2.5 mb-10 group">
          <div className="w-10 h-10 bg-amber-500 rounded-2xl flex items-center justify-center text-xl shadow-sm">
            📖
          </div>
          <span className="font-bold text-amber-900 text-lg">Little Bible</span>
        </Link>

        {/* Icon */}
        <div className="text-7xl mb-4 select-none" role="img" aria-label="Something went wrong">
          ☁️
        </div>

        {/* Message */}
        <h1 className="font-bold text-stone-800 text-2xl mb-3">
          Something went wrong
        </h1>
        <p className="text-stone-500 text-base leading-relaxed mb-2 max-w-sm mx-auto">
          We hit an unexpected error. This has been noted and we&apos;ll look into it.
        </p>
        {error.digest && (
          <p className="text-stone-400 text-xs font-mono mb-6">
            Error ID: {error.digest}
          </p>
        )}

        {/* Actions */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-3 mt-6">
          <button
            onClick={reset}
            className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-6 py-3 rounded-2xl transition-all active:scale-95 shadow-sm w-full sm:w-auto justify-center"
          >
            ↩ Try Again
          </button>
          <Link
            href="/"
            className="inline-flex items-center gap-2 bg-white hover:bg-stone-50 text-stone-700 font-bold px-6 py-3 rounded-2xl border border-stone-200 hover:border-stone-300 transition-all w-full sm:w-auto justify-center"
          >
            🏠 Go Home
          </Link>
        </div>

        {/* Secondary links */}
        <div className="flex items-center justify-center gap-4 mt-6">
          <Link href="/stories" className="text-sm text-amber-600 hover:text-amber-800 font-semibold transition-colors">
            ✨ Stories
          </Link>
          <span className="text-stone-300">·</span>
          <Link href="/genesis/1" className="text-sm text-amber-600 hover:text-amber-800 font-semibold transition-colors">
            📖 Read
          </Link>
          <span className="text-stone-300">·</span>
          <a href="mailto:hello@littlebible.org" className="text-sm text-stone-400 hover:text-stone-600 transition-colors">
            Report this
          </a>
        </div>

      </div>
    </div>
  );
}
