'use client';

import { useState, useRef, useEffect } from 'react';

interface WonderWordProps {
  word: string;        // the visible highlighted word
  fact: string;        // the pop-up fact text
  emoji?: string;      // optional emoji shown in the bubble
}

export default function WonderWord({ word, fact, emoji = '✨' }: WonderWordProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLSpanElement>(null);

  // Close on outside click
  useEffect(() => {
    if (!open) return;
    function handleClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClick);
    document.addEventListener('touchstart', handleClick as EventListener);
    return () => {
      document.removeEventListener('mousedown', handleClick);
      document.removeEventListener('touchstart', handleClick as EventListener);
    };
  }, [open]);

  return (
    <span ref={ref} className="relative inline-block">
      {/* The tappable word */}
      <button
        onClick={() => setOpen(v => !v)}
        className="relative font-bold underline decoration-dotted decoration-amber-400 underline-offset-2 text-amber-700 cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded px-0.5 transition-colors hover:text-amber-600"
        aria-expanded={open}
        aria-haspopup="true"
      >
        {word}
        <span
          className="absolute -top-1.5 -right-1 text-[8px] leading-none select-none"
          aria-hidden="true"
        >
          ✦
        </span>
      </button>

      {/* Pop-up bubble */}
      {open && (
        <span
          className="wonder-reveal absolute bottom-full left-1/2 -translate-x-1/2 mb-2.5 z-50 w-52 max-w-[80vw]"
          role="tooltip"
        >
          <span className="block bg-amber-50 border border-amber-200 rounded-2xl px-4 py-3 shadow-lg text-left relative">
            {/* Arrow pointing down */}
            <span
              className="absolute top-full left-1/2 -translate-x-1/2 -mt-px"
              aria-hidden="true"
            >
              <svg width="16" height="8" viewBox="0 0 16 8" fill="none">
                <path d="M0 0 L8 8 L16 0" fill="#FEF3C7" stroke="#FDE68A" strokeWidth="1"/>
              </svg>
            </span>
            <span className="flex items-start gap-2">
              <span className="text-lg shrink-0" aria-hidden="true">{emoji}</span>
              <span className="text-amber-900 text-xs font-semibold leading-relaxed">{fact}</span>
            </span>
          </span>
        </span>
      )}
    </span>
  );
}
