'use client';

import { useState, useEffect } from 'react';

const DISMISSED_KEY = 'little_bible_welcome_dismissed';

// Soft, dismissible welcome banner — replaces the old blocking modal.
// Users can browse, open books, read chapters, and use all features
// before ever seeing this. It appears at the top of the homepage only.
export default function OnboardingFlow() {
  const [show, setShow]       = useState(false);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    if (!localStorage.getItem(DISMISSED_KEY)) setShow(true);
  }, []);

  if (!mounted || !show) return null;

  function dismiss() {
    localStorage.setItem(DISMISSED_KEY, '1');
    setShow(false);
  }

  return (
    <div role="banner" className="bg-amber-50 border-b border-amber-100 px-4 py-3">
      <div className="max-w-4xl mx-auto flex items-center justify-between gap-4">
        <p className="text-amber-800 text-sm font-medium leading-snug">
          <span className="mr-2" aria-hidden="true">📖</span>
          <strong>Welcome to Little Bible</strong> — all 66 books of Scripture faithfully adapted for ages 4–7.
          {' '}Read freely. No account needed.
        </p>
        <button
          onClick={dismiss}
          className="text-amber-400 hover:text-amber-700 font-bold text-lg shrink-0 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded px-1"
          aria-label="Dismiss welcome message"
        >
          ✕
        </button>
      </div>
    </div>
  );
}
