'use client';

import type { Verse, ReviewStatus } from '@/types';

const REVIEW_OPTIONS: Array<{
  value: ReviewStatus;
  label: string;
  activeClass: string;
  hoverClass: string;
}> = [
  {
    value: 'approved',
    label: '✓ Approved',
    activeClass: 'bg-green-100 text-green-700 border-green-300',
    hoverClass: 'hover:bg-green-50 hover:border-green-200 hover:text-green-700',
  },
  {
    value: 'needs_review',
    label: '⚠ Needs Review',
    activeClass: 'bg-yellow-100 text-yellow-700 border-yellow-300',
    hoverClass: 'hover:bg-yellow-50 hover:border-yellow-200 hover:text-yellow-700',
  },
  {
    value: 'theological_concern',
    label: '⚡ Theological',
    activeClass: 'bg-red-100 text-red-700 border-red-300',
    hoverClass: 'hover:bg-red-50 hover:border-red-200 hover:text-red-700',
  },
  {
    value: 'too_difficult',
    label: '📖 Too Difficult',
    activeClass: 'bg-blue-100 text-blue-700 border-blue-300',
    hoverClass: 'hover:bg-blue-50 hover:border-blue-200 hover:text-blue-700',
  },
  {
    value: 'rewrite_needed',
    label: '✏ Rewrite',
    activeClass: 'bg-purple-100 text-purple-700 border-purple-300',
    hoverClass: 'hover:bg-purple-50 hover:border-purple-200 hover:text-purple-700',
  },
];

const BORDER_STATUS: Record<ReviewStatus, string> = {
  approved: 'border-l-green-400',
  needs_review: 'border-l-yellow-400',
  theological_concern: 'border-l-red-400',
  too_difficult: 'border-l-blue-400',
  rewrite_needed: 'border-l-purple-400',
};

function speak(text: string) {
  if (!('speechSynthesis' in window)) return;
  window.speechSynthesis.cancel();
  const u = new SpeechSynthesisUtterance(text);
  u.rate = 0.85;
  window.speechSynthesis.speak(u);
}

interface VerseCardProps {
  verse: Verse;
  showKJV: boolean;
  reviewMode: boolean;
  currentStatus?: ReviewStatus;
  onReview: (verseNum: number, status: ReviewStatus) => void;
}

export default function VerseCard({
  verse,
  showKJV,
  reviewMode,
  currentStatus,
  onReview,
}: VerseCardProps) {
  const statusOpt = REVIEW_OPTIONS.find((o) => o.value === currentStatus);
  const borderClass = currentStatus
    ? `border-l-4 ${BORDER_STATUS[currentStatus]}`
    : 'border-l-4 border-l-transparent';

  return (
    <article
      className={`bg-white rounded-2xl border border-stone-100 shadow-sm hover:shadow-md transition-shadow ${borderClass}`}
      aria-label={`Verse ${verse.verse}`}
    >
      {/* Header row */}
      <div className="flex items-center justify-between px-5 pt-5 pb-3">
        <div className="flex items-center gap-3 flex-wrap">
          <div className="w-9 h-9 bg-amber-100 rounded-xl flex items-center justify-center font-bold text-amber-700 text-sm">
            {verse.verse}
          </div>
          {statusOpt && (
            <span
              className={`text-xs px-2.5 py-1 rounded-full border font-semibold ${statusOpt.activeClass}`}
            >
              {statusOpt.label}
            </span>
          )}
        </div>
        <button
          onClick={() => speak(verse.little_bible)}
          className="p-2 rounded-xl hover:bg-amber-50 text-stone-300 hover:text-amber-500 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
          aria-label={`Read verse ${verse.verse} Little Bible text aloud`}
        >
          🔊
        </button>
      </div>

      <div className="px-5 pb-5 space-y-4">
        {/* KJV */}
        {showKJV && (
          <div className="pt-2 pb-4 border-b border-stone-100">
            <div className="flex items-center justify-between mb-1.5">
              <p className="text-xs font-bold text-stone-400 uppercase tracking-widest">KJV</p>
              <button
                onClick={() => speak(verse.kjv)}
                className="text-stone-300 hover:text-amber-500 transition-colors p-1 text-sm focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300 rounded"
                aria-label={`Read KJV of verse ${verse.verse} aloud`}
              >
                🔊
              </button>
            </div>
            <p className="text-stone-500 text-sm italic leading-relaxed">{verse.kjv}</p>
          </div>
        )}

        {/* Little Bible */}
        <div>
          <p className="text-xs font-bold text-amber-600 uppercase tracking-widest mb-1.5">
            Little Bible
          </p>
          <p className="text-stone-800 text-base font-semibold leading-relaxed">
            {verse.little_bible}
          </p>
        </div>

        {/* Meaning */}
        <div>
          <p className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-1">
            Meaning
          </p>
          <p className="text-stone-600 text-sm leading-relaxed">{verse.meaning}</p>
        </div>

        {/* Memory phrase */}
        <div className="bg-amber-50 rounded-xl px-4 py-3 border border-amber-100">
          <p className="text-xs font-bold text-amber-500 uppercase tracking-widest mb-1">
            ✨ Remember
          </p>
          <p className="text-amber-800 font-semibold text-sm">&ldquo;{verse.memory_phrase}&rdquo;</p>
        </div>

        {/* Prayer */}
        <div>
          <div className="flex items-center justify-between mb-1">
            <p className="text-xs font-bold text-stone-400 uppercase tracking-widest">
              🙏 Prayer
            </p>
            <button
              onClick={() => speak(verse.prayer)}
              className="text-stone-300 hover:text-amber-500 transition-colors p-1 text-sm focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300 rounded"
              aria-label={`Read prayer for verse ${verse.verse} aloud`}
            >
              🔊
            </button>
          </div>
          <p className="text-stone-500 text-sm italic leading-relaxed">{verse.prayer}</p>
        </div>

        {/* Discussion */}
        <div className="bg-blue-50 rounded-xl px-4 py-3 border border-blue-100">
          <p className="text-xs font-bold text-blue-400 uppercase tracking-widest mb-1">
            💬 Discussion
          </p>
          <p className="text-blue-800 text-sm">{verse.discussion_question}</p>
        </div>

        {/* Keywords */}
        <div className="flex flex-wrap gap-1.5 pt-1" aria-label="Keywords">
          {verse.keywords.map((kw) => (
            <span
              key={kw}
              className="px-2.5 py-0.5 bg-stone-100 text-stone-500 text-xs rounded-full"
            >
              {kw}
            </span>
          ))}
        </div>

        {/* Review controls */}
        {reviewMode && (
          <div className="pt-3 border-t border-stone-100">
            <p className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-3">
              Review Status
            </p>
            <div className="flex flex-wrap gap-2">
              {REVIEW_OPTIONS.map((option) => (
                <button
                  key={option.value}
                  onClick={() => onReview(verse.verse, option.value)}
                  className={`px-3 py-1.5 text-xs font-semibold rounded-xl border transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-1 focus-visible:ring-amber-400 ${
                    currentStatus === option.value
                      ? `${option.activeClass} ring-2 ring-current ring-offset-1`
                      : `border-stone-200 text-stone-500 ${option.hoverClass}`
                  }`}
                  aria-label={`Mark verse ${verse.verse} as ${option.label}`}
                  aria-pressed={currentStatus === option.value}
                >
                  {option.label}
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </article>
  );
}
