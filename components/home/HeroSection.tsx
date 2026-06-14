'use client';

import { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getProgress } from '@/lib/progress';
import LumiMascot, { getLumiStage } from '@/components/mascot/LumiMascot';

// All books for search — 66 total (available ones navigable)
const ALL_BOOKS_SEARCH = [
  { slug: 'genesis', name: 'Genesis', emoji: '🌍', available: true },
  { slug: 'exodus', name: 'Exodus', emoji: '🔥', available: false },
  { slug: 'leviticus', name: 'Leviticus', emoji: '📜', available: false },
  { slug: 'numbers', name: 'Numbers', emoji: '🔢', available: false },
  { slug: 'deuteronomy', name: 'Deuteronomy', emoji: '📋', available: false },
  { slug: 'joshua', name: 'Joshua', emoji: '⚔️', available: false },
  { slug: 'judges', name: 'Judges', emoji: '🛡️', available: false },
  { slug: 'ruth', name: 'Ruth', emoji: '🌾', available: false },
  { slug: 'psalms', name: 'Psalms', emoji: '🎵', available: true },
  { slug: 'proverbs', name: 'Proverbs', emoji: '✨', available: true },
  { slug: 'jonah', name: 'Jonah', emoji: '🐳', available: false },
  { slug: 'matthew', name: 'Matthew', emoji: '✝️', available: true },
  { slug: 'mark', name: 'Mark', emoji: '📖', available: false },
  { slug: 'luke', name: 'Luke', emoji: '⭐', available: true },
  { slug: 'john', name: 'John', emoji: '💙', available: true },
  { slug: 'acts', name: 'Acts', emoji: '🕊️', available: false },
  { slug: 'romans', name: 'Romans', emoji: '✉️', available: false },
  { slug: 'revelation', name: 'Revelation', emoji: '👑', available: false },
];

type StorySearchItem = { id: string; title: string; emoji: string };
type TopicSearchItem = { id: string; title: string; emoji: string; description: string };

type SearchResult =
  | { kind: 'book'; slug: string; name: string; emoji: string; available: boolean }
  | { kind: 'story'; id: string; title: string; emoji: string }
  | { kind: 'topic'; id: string; title: string; emoji: string; description: string };

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

// Quick-start books — available books first, clearly marked
const QUICK_BOOKS = [
  { slug: 'genesis',  name: 'Genesis',  emoji: '🌍', available: true  },
  { slug: 'proverbs', name: 'Proverbs', emoji: '✨', available: true  },
  { slug: 'psalms',   name: 'Psalms',   emoji: '🎵', available: true  },
  { slug: 'matthew',  name: 'Matthew',  emoji: '✝️', available: true  },
  { slug: 'luke',     name: 'Luke',     emoji: '⭐', available: true  },
  { slug: 'john',     name: 'John',     emoji: '💙', available: true  },
];

function getReadingResume(): { href: string; label: string } {
  if (typeof window === 'undefined') return { href: '/genesis/1', label: 'Start Reading' };
  const p = getProgress();
  if (p.sessions.length > 0) {
    const last = p.sessions[p.sessions.length - 1];
    return { href: `/${last.book}/${last.chapter}`, label: 'Continue Reading' };
  }
  return { href: '/genesis/1', label: 'Start with Genesis' };
}

interface HeroSectionProps {
  stories?: StorySearchItem[];
  topics?: TopicSearchItem[];
}

export default function HeroSection({ stories = [], topics = [] }: HeroSectionProps) {
  const router = useRouter();
  const [resume,    setResume]    = useState({ href: '/genesis/1', label: 'Start with Genesis' });
  const [lumiStage, setLumiStage] = useState<ReturnType<typeof getLumiStage>>('seed');
  const [seedCount, setSeedCount] = useState(0);

  const [searchQuery,   setSearchQuery]   = useState('');
  const [searchFocused, setSearchFocused] = useState(false);
  const [activeIndex,   setActiveIndex]   = useState(-1);
  const searchRef = useRef<HTMLDivElement>(null);

  const searchResults = searchContent(searchQuery, stories, topics);
  const showDropdown  = searchFocused && searchQuery.trim().length > 0;

  useEffect(() => {
    setResume(getReadingResume());
    const p = getProgress();
    setLumiStage(getLumiStage(p.wisdomSeeds));
    setSeedCount(p.wisdomSeeds);
  }, []);

  // Close dropdown on outside click
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
    if (r.kind === 'book') return r.available ? `/${r.slug}/1` : `/${r.slug}`;
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
        className="absolute inset-0 opacity-[0.07]"
        style={{
          backgroundImage:
            'radial-gradient(circle at 20% 60%, #fbbf24 0%, transparent 50%), radial-gradient(circle at 80% 20%, #f59e0b 0%, transparent 40%)',
        }}
        aria-hidden="true"
      />

      <div className="relative max-w-5xl mx-auto px-5 sm:px-8 pt-10 pb-14 sm:pt-14 sm:pb-20">

        {/* ── Top identity badge ── */}
        <div className="flex items-center justify-center lg:justify-start mb-6">
          <div className="inline-flex items-center gap-2.5 bg-white/10 backdrop-blur-sm rounded-2xl px-4 py-2 border border-white/15">
            <span className="text-lg" aria-hidden="true">📖</span>
            <p className="text-amber-200 text-xs font-bold tracking-wide">
              Children&apos;s Bible · 66 Books · Every Verse · Ages 4–7
            </p>
          </div>
        </div>

        <div className="flex flex-col lg:flex-row items-start gap-10 lg:gap-16">

          {/* ── Left column ── */}
          <div className="flex-1 text-center lg:text-left max-w-xl mx-auto lg:mx-0">

            {/* Main headline — "Bible" is the first word */}
            <h1 className="font-display text-5xl sm:text-6xl lg:text-[64px] font-bold text-white leading-[1.05] tracking-tight mb-4">
              The Bible<br />
              <span className="text-amber-300">for Little</span><br />
              Hearts
            </h1>

            <p className="text-amber-100/80 text-lg sm:text-xl leading-relaxed mb-6 max-w-md mx-auto lg:mx-0">
              All 66 books of Scripture — every verse faithfully adapted
              so your child can read, understand, and love God&apos;s Word
              from their earliest years.
            </p>

            {/* ── Quick-start books ── */}
            <div className="mb-7">
              <p className="text-amber-400/70 text-xs font-bold uppercase tracking-widest mb-3 text-center lg:text-left">
                Jump to a book
              </p>
              <div className="grid grid-cols-3 sm:grid-cols-6 lg:grid-cols-3 gap-2 max-w-xs sm:max-w-none lg:max-w-xs mx-auto lg:mx-0">
                {QUICK_BOOKS.map((book) => (
                  <Link
                    key={book.slug}
                    href={book.available ? `/${book.slug}/1` : `/${book.slug}`}
                    className={`flex flex-col items-center gap-1 py-2.5 px-1 rounded-xl border text-center transition-all active:scale-95 ${
                      book.available
                        ? 'bg-white/15 border-white/20 hover:bg-white/25 text-white'
                        : 'bg-white/5 border-white/10 text-white/40 cursor-default'
                    }`}
                    tabIndex={book.available ? undefined : -1}
                  >
                    <span className="text-xl leading-none" aria-hidden="true">{book.emoji}</span>
                    <span className="text-[10px] font-bold leading-tight">{book.name}</span>
                    {!book.available && (
                      <span className="text-[9px] text-white/30 leading-none">Soon</span>
                    )}
                  </Link>
                ))}
              </div>
            </div>

            {/* Primary CTA */}
            <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-3">
              <Link
                href={resume.href}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 bg-amber-400 hover:bg-amber-300 text-amber-950 font-extrabold text-base px-7 py-4 rounded-2xl transition-all active:scale-95 shadow-lg shadow-amber-900/40 hover:shadow-xl focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
              >
                <span aria-hidden="true">📖</span>
                {resume.label}
                <span className="text-amber-700" aria-hidden="true">→</span>
              </Link>

              <div className="flex items-center gap-2 w-full sm:w-auto">
                <a
                  href="#library"
                  className="flex-1 sm:flex-none inline-flex items-center justify-center gap-1.5 text-amber-200 hover:text-white font-semibold text-sm px-4 py-4 rounded-2xl border border-amber-700/50 hover:border-amber-400/60 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
                >
                  📚 All 66 Books
                </a>
                <Link
                  href="/stories"
                  className="flex-1 sm:flex-none inline-flex items-center justify-center gap-1.5 text-amber-200 hover:text-white font-semibold text-sm px-4 py-4 rounded-2xl border border-amber-700/50 hover:border-amber-400/60 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-300"
                >
                  ✨ Stories
                </Link>
              </div>
            </div>

            {/* Search bar */}
            <div ref={searchRef} className="relative mt-5">
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

              {/* Dropdown results */}
              {showDropdown && (
                <div
                  role="listbox"
                  aria-label="Search results"
                  className="absolute top-full mt-2 left-0 right-0 bg-white rounded-2xl shadow-2xl border border-stone-100 overflow-hidden z-30"
                >
                  {searchResults.length === 0 ? (
                    <p className="px-4 py-3 text-sm text-stone-400 text-center">No results for &quot;{searchQuery}&quot;</p>
                  ) : (
                    searchResults.map((result, i) => {
                      const href = getResultHref(result);
                      const label = result.kind === 'book' ? result.name : result.title;
                      const sub   = result.kind === 'book'
                        ? (result.available ? 'Bible Book' : 'Coming soon')
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
                            i === activeIndex
                              ? 'bg-amber-50'
                              : 'hover:bg-stone-50'
                          }`}
                        >
                          <span className="text-xl shrink-0" aria-hidden="true">{result.emoji}</span>
                          <div className="min-w-0">
                            <p className="text-sm font-bold text-stone-800 truncate">{label}</p>
                            <p className="text-xs text-stone-400">{sub}</p>
                          </div>
                          {result.kind === 'book' && !result.available && (
                            <span className="ml-auto text-[10px] font-bold text-stone-300 uppercase tracking-wide shrink-0">Soon</span>
                          )}
                        </button>
                      );
                    })
                  )}
                </div>
              )}
            </div>

            <p className="mt-4 text-amber-400/50 text-xs font-medium text-center lg:text-left">
              Free · Open source · Faithful to Scripture
            </p>
          </div>

          {/* ── Right: Bible stats card ── */}
          <div className="flex-shrink-0 w-full max-w-xs lg:max-w-[280px] mx-auto lg:mx-0">
            <div
              className="card-glass rounded-3xl p-5 shadow-2xl border border-amber-200/30"
              aria-label="What's in Little Bible"
            >
              {/* Lumi + seeds */}
              <div className="flex items-center justify-between mb-4">
                <div>
                  <p className="text-amber-600 text-xs font-bold uppercase tracking-widest">Your Bible</p>
                  {seedCount > 0 && (
                    <p className="text-stone-500 text-xs mt-0.5">{seedCount} Wisdom Seeds 🌱</p>
                  )}
                </div>
                <LumiMascot stage={lumiStage} className="w-12 h-12" />
              </div>

              {/* Bible stats */}
              <div className="space-y-2.5 mb-4">
                {[
                  { label: '66 books',        sub: 'Genesis to Revelation', icon: '📚', highlight: true },
                  { label: 'Every verse',      sub: 'Nothing skipped',       icon: '✓',  highlight: false },
                  { label: 'Faithfully adapted', sub: 'For ages 4–7',        icon: '❤️', highlight: false },
                  { label: 'Free forever',     sub: 'No subscription',       icon: '🎁', highlight: false },
                ].map((item) => (
                  <div
                    key={item.label}
                    className={`flex items-center gap-3 px-3 py-2.5 rounded-xl ${
                      item.highlight ? 'bg-amber-50 border border-amber-200' : 'bg-stone-50'
                    }`}
                  >
                    <span className="text-lg shrink-0" aria-hidden="true">{item.icon}</span>
                    <div>
                      <p className={`text-sm font-bold leading-tight ${item.highlight ? 'text-amber-900' : 'text-stone-800'}`}>
                        {item.label}
                      </p>
                      <p className="text-stone-400 text-xs">{item.sub}</p>
                    </div>
                  </div>
                ))}
              </div>

              {/* 5-step devotion preview */}
              <div className="divider-amber mb-3.5" aria-hidden="true" />
              <p className="text-stone-400 text-[10px] font-bold uppercase tracking-widest mb-2">
                Each verse includes
              </p>
              <div className="flex gap-1">
                {[
                  { emoji: '📖', label: 'Read',     color: '#F59E0B' },
                  { emoji: '💬', label: 'Discuss',  color: '#0EA5E9' },
                  { emoji: '🙏', label: 'Pray',     color: '#7C3AED' },
                  { emoji: '⭐', label: 'Remember', color: '#16A34A' },
                  { emoji: '🌟', label: 'Do',       color: '#EA580C' },
                ].map((s) => (
                  <div
                    key={s.label}
                    className="flex-1 flex flex-col items-center gap-0.5 py-1.5 rounded-lg bg-stone-50"
                    aria-hidden="true"
                  >
                    <span className="text-xs">{s.emoji}</span>
                    <span className="text-[8px] font-bold text-stone-400 leading-none">{s.label}</span>
                  </div>
                ))}
              </div>

              <Link
                href={resume.href}
                className="mt-3.5 block w-full text-center bg-amber-500 hover:bg-amber-600 text-white font-extrabold py-3 rounded-2xl text-sm transition-colors active:scale-95"
              >
                {resume.label} →
              </Link>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}
