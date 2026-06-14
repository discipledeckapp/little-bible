'use client';

import { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getProgress } from '@/lib/progress';
import { getLumiStage } from '@/components/mascot/LumiMascot';
import HeroScene from '@/components/home/HeroScene';

// All 66 books for search
const ALL_BOOKS_SEARCH = [
  { slug: 'genesis',      name: 'Genesis',      emoji: '🌍', available: true  },
  { slug: 'exodus',       name: 'Exodus',        emoji: '🔥', available: false },
  { slug: 'leviticus',    name: 'Leviticus',     emoji: '📜', available: false },
  { slug: 'numbers',      name: 'Numbers',       emoji: '🔢', available: false },
  { slug: 'deuteronomy',  name: 'Deuteronomy',   emoji: '📋', available: false },
  { slug: 'joshua',       name: 'Joshua',        emoji: '⚔️', available: false },
  { slug: 'judges',       name: 'Judges',        emoji: '🛡️', available: false },
  { slug: 'ruth',         name: 'Ruth',          emoji: '🌾', available: false },
  { slug: 'psalms',       name: 'Psalms',        emoji: '🎵', available: true  },
  { slug: 'proverbs',     name: 'Proverbs',      emoji: '✨', available: true  },
  { slug: 'jonah',        name: 'Jonah',         emoji: '🐳', available: false },
  { slug: 'matthew',      name: 'Matthew',       emoji: '✝️', available: true  },
  { slug: 'mark',         name: 'Mark',          emoji: '📖', available: false },
  { slug: 'luke',         name: 'Luke',          emoji: '⭐', available: true  },
  { slug: 'john',         name: 'John',          emoji: '💙', available: true  },
  { slug: 'acts',         name: 'Acts',          emoji: '🕊️', available: false },
  { slug: 'romans',       name: 'Romans',        emoji: '✉️', available: false },
  { slug: 'revelation',   name: 'Revelation',    emoji: '👑', available: false },
];

type StorySearchItem = { id: string; title: string; emoji: string };
type TopicSearchItem = { id: string; title: string; emoji: string; description: string };

type SearchResult =
  | { kind: 'book';  slug: string; name: string;  emoji: string; available: boolean }
  | { kind: 'story'; id: string;   title: string;  emoji: string }
  | { kind: 'topic'; id: string;   title: string;  emoji: string; description: string };

function searchContent(q: string, stories: StorySearchItem[], topics: TopicSearchItem[]): SearchResult[] {
  if (!q.trim()) return [];
  const lower = q.toLowerCase();
  const books: SearchResult[] = ALL_BOOKS_SEARCH
    .filter(b => b.name.toLowerCase().includes(lower))
    .slice(0, 2)
    .map(b => ({ kind: 'book' as const, ...b }));
  const storyResults: SearchResult[] = stories
    .filter(s => s.title.toLowerCase().includes(lower))
    .slice(0, 3)
    .map(s => ({ kind: 'story' as const, ...s }));
  const topicResults: SearchResult[] = topics
    .filter(t => t.title.toLowerCase().includes(lower) || t.description.toLowerCase().includes(lower))
    .slice(0, 2)
    .map(t => ({ kind: 'topic' as const, ...t }));
  return [...books, ...storyResults, ...topicResults].slice(0, 6);
}

interface HeroSectionProps {
  stories?: StorySearchItem[];
  topics?: TopicSearchItem[];
}

type CTA = {
  href:    string;
  label:   string;
  context: string; // short label e.g. "Genesis 1" for returning users
  isReturn: boolean;
};

function getSmartCTA(): CTA {
  if (typeof window === 'undefined') {
    return { href: '/stories', label: 'Begin Reading', context: '', isReturn: false };
  }
  const p = getProgress();
  if (p.sessions.length > 0) {
    const last = p.sessions[p.sessions.length - 1];
    const bookName = last.book.charAt(0).toUpperCase() + last.book.slice(1);
    return {
      href:     `/${last.book}/${last.chapter}`,
      label:    `Continue Reading`,
      context:  `${bookName} ${last.chapter}`,
      isReturn: true,
    };
  }
  return { href: '/stories', label: 'Begin Reading', context: '', isReturn: false };
}

export default function HeroSection({ stories = [], topics = [] }: HeroSectionProps) {
  const router = useRouter();
  const [cta,       setCta]       = useState<CTA>({ href: '/stories', label: 'Begin Reading', context: '', isReturn: false });
  const [lumiStage, setLumiStage] = useState<ReturnType<typeof getLumiStage>>('seed');

  const [searchQuery,   setSearchQuery]   = useState('');
  const [searchFocused, setSearchFocused] = useState(false);
  const [activeIndex,   setActiveIndex]   = useState(-1);
  const searchRef = useRef<HTMLDivElement>(null);

  const searchResults = searchContent(searchQuery, stories, topics);
  const showDropdown  = searchFocused && searchQuery.trim().length > 0;

  useEffect(() => {
    setCta(getSmartCTA());
    const p = getProgress();
    setLumiStage(getLumiStage(p.wisdomSeeds));
  }, []);

  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (searchRef.current && !searchRef.current.contains(e.target as Node)) {
        setSearchFocused(false);
      }
    }
    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, []);

  function getResultHref(r: SearchResult): string {
    if (r.kind === 'book')  return r.available ? `/${r.slug}/1` : `/${r.slug}`;
    if (r.kind === 'topic') return `/topics/${r.id}`;
    return `/stories/${r.id}`;
  }

  function navigateToResult(r: SearchResult) {
    setSearchQuery('');
    setSearchFocused(false);
    setActiveIndex(-1);
    router.push(getResultHref(r));
  }

  function handleSearchKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (!showDropdown) return;
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setActiveIndex(i => Math.min(i + 1, searchResults.length - 1));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setActiveIndex(i => Math.max(i - 1, 0));
    } else if (e.key === 'Enter' && activeIndex >= 0) {
      e.preventDefault();
      navigateToResult(searchResults[activeIndex]);
    } else if (e.key === 'Escape') {
      setSearchFocused(false);
      setActiveIndex(-1);
    }
  }

  return (
    <section className="hero-bg relative overflow-hidden">
      {/* Ambient glow */}
      <div
        className="absolute inset-0 opacity-[0.06]"
        style={{
          backgroundImage:
            'radial-gradient(circle at 20% 60%, #fbbf24 0%, transparent 50%), radial-gradient(circle at 80% 20%, #f59e0b 0%, transparent 40%)',
        }}
        aria-hidden="true"
      />

      <div className="relative max-w-5xl mx-auto px-5 sm:px-8 pt-10 pb-14 sm:pt-14 sm:pb-18">

        {/* ── Identity badge ── */}
        <div className="flex items-center justify-center lg:justify-start mb-7">
          <div className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm rounded-2xl px-3.5 py-1.5 border border-white/15">
            <span className="text-base" aria-hidden="true">📖</span>
            <p className="text-amber-200 text-xs font-bold tracking-wide">
              Children&apos;s Bible · 66 Books · Every Verse · Ages 4–7
            </p>
            <span className="bg-amber-400 text-amber-950 text-[10px] font-extrabold px-1.5 py-0.5 rounded-md uppercase tracking-wider ml-0.5">
              Free
            </span>
          </div>
        </div>

        <div className="flex flex-col lg:flex-row items-start gap-10 lg:gap-12">

          {/* ── Left column ── */}
          <div className="flex-1 text-center lg:text-left max-w-xl mx-auto lg:mx-0">

            {/* Headline */}
            <h1 className="font-display text-5xl sm:text-6xl lg:text-[66px] font-bold text-white leading-[1.04] tracking-tight mb-5">
              The Bible<br />
              <span className="text-amber-300">for Little</span><br />
              Hearts
            </h1>

            <p className="text-amber-100/80 text-lg sm:text-xl leading-relaxed mb-7 max-w-md mx-auto lg:mx-0">
              All 66 books of Scripture — every verse faithfully adapted
              so your child can read, understand, and love God&apos;s Word
              from their earliest years.
            </p>

            {/* ── Primary CTA cluster ── */}
            <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-3 mb-4">
              {/* Smart primary button */}
              <Link
                href={cta.href}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 bg-amber-400 hover:bg-amber-300 text-amber-950 font-extrabold text-base px-7 py-4 rounded-2xl transition-all active:scale-95 shadow-lg shadow-amber-900/40 hover:shadow-xl focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
              >
                <span aria-hidden="true">📖</span>
                <span>
                  {cta.label}
                  {cta.isReturn && cta.context && (
                    <span className="ml-1.5 font-bold opacity-75">· {cta.context}</span>
                  )}
                </span>
                <span className="text-amber-700" aria-hidden="true">→</span>
              </Link>
            </div>

            {/* Secondary CTAs */}
            <div className="flex items-center justify-center lg:justify-start gap-2 flex-wrap mb-7">
              <a
                href="#library"
                className="inline-flex items-center gap-1.5 text-amber-200 hover:text-white font-semibold text-sm px-3.5 py-2.5 rounded-xl border border-amber-700/50 hover:border-amber-400/60 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
              >
                📚 All 66 Books
              </a>
              <Link
                href="/stories"
                className="inline-flex items-center gap-1.5 text-amber-200 hover:text-white font-semibold text-sm px-3.5 py-2.5 rounded-xl border border-amber-700/50 hover:border-amber-400/60 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
              >
                ✨ Stories
              </Link>
              <Link
                href="/download"
                className="inline-flex items-center gap-1.5 text-amber-200 hover:text-white font-semibold text-sm px-3.5 py-2.5 rounded-xl border border-amber-700/50 hover:border-amber-400/60 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
              >
                📱 Get the App
              </Link>
            </div>

            {/* Search */}
            <div ref={searchRef} className="relative">
              <div className="flex items-center gap-3 bg-white/10 hover:bg-white/15 backdrop-blur-sm border border-white/20 rounded-2xl px-4 py-3 transition-colors focus-within:bg-white/15 focus-within:border-amber-300/40">
                <span className="text-amber-300/80 text-base shrink-0" aria-hidden="true">🔍</span>
                <input
                  type="search"
                  value={searchQuery}
                  onChange={e => { setSearchQuery(e.target.value); setActiveIndex(-1); }}
                  onFocus={() => setSearchFocused(true)}
                  onKeyDown={handleSearchKeyDown}
                  placeholder="Search books, stories, topics…"
                  aria-label="Search books, stories and topics"
                  aria-expanded={showDropdown}
                  aria-autocomplete="list"
                  className="flex-1 bg-transparent text-white placeholder-amber-300/40 text-sm font-medium outline-none min-w-0"
                />
                {searchQuery && (
                  <button
                    onClick={() => { setSearchQuery(''); setActiveIndex(-1); }}
                    className="text-amber-300/60 hover:text-amber-200 text-xs shrink-0 focus:outline-none"
                    aria-label="Clear search"
                  >
                    ✕
                  </button>
                )}
              </div>

              {showDropdown && (
                <div
                  role="listbox"
                  aria-label="Search results"
                  className="absolute top-full mt-2 left-0 right-0 bg-white rounded-2xl shadow-2xl border border-stone-100 overflow-hidden z-30"
                >
                  {searchResults.length === 0 ? (
                    <p className="px-4 py-3 text-sm text-stone-400 text-center">
                      No results for &quot;{searchQuery}&quot;
                    </p>
                  ) : (
                    searchResults.map((result, i) => {
                      const href  = getResultHref(result);
                      const label = result.kind === 'book' ? result.name : result.title;
                      const sub   =
                        result.kind === 'book'
                          ? result.available ? 'Bible Book' : 'Coming soon'
                          : result.kind === 'topic'
                          ? 'Scripture Topic'
                          : 'Bible Story';
                      return (
                        <button
                          key={`${result.kind}-${result.kind === 'book' ? result.slug : result.id}`}
                          role="option"
                          aria-selected={i === activeIndex}
                          onClick={() => navigateToResult(result)}
                          className={`w-full flex items-center gap-3 px-4 py-3 text-left transition-colors focus:outline-none border-b border-stone-50 last:border-0 ${
                            i === activeIndex ? 'bg-amber-50' : 'hover:bg-stone-50'
                          }`}
                        >
                          <span className="text-xl shrink-0" aria-hidden="true">{result.emoji}</span>
                          <div className="min-w-0">
                            <p className="text-sm font-bold text-stone-800 truncate">{label}</p>
                            <p className="text-xs text-stone-400">{sub}</p>
                          </div>
                          {result.kind === 'book' && !result.available && (
                            <span className="ml-auto text-[10px] font-bold text-stone-300 uppercase tracking-wide shrink-0">
                              Soon
                            </span>
                          )}
                        </button>
                      );
                    })
                  )}
                </div>
              )}
            </div>

            {/* Trust strip */}
            <p className="mt-4 text-amber-400/55 text-xs font-medium text-center lg:text-left">
              Free forever · No sign-up needed · Faithful to Scripture
            </p>
          </div>

          {/* ── Right: Illustrated Lumi scene ── */}
          <div className="flex-shrink-0 w-full max-w-sm lg:max-w-[340px] mx-auto lg:mx-0 lg:self-stretch">
            <HeroScene lumiStage={lumiStage} />
          </div>

        </div>
      </div>
    </section>
  );
}
