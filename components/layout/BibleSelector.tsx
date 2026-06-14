'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { BIBLE_BOOKS, OT_GROUPS, NT_GROUPS } from '@/lib/bibleBooks';
import type { BibleBook, Testament } from '@/lib/bibleBooks';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  /** 'dropdown' = anchored below a button; 'sheet' = bottom sheet (mobile) */
  mode?: 'dropdown' | 'sheet';
}

export default function BibleSelector({ isOpen, onClose, mode = 'dropdown' }: Props) {
  const router = useRouter();
  const [testament, setTestament] = useState<Testament>('NT');
  const [phase, setPhase] = useState<'books' | 'chapters'>('books');
  const [selectedBook, setSelectedBook] = useState<BibleBook | null>(null);
  const panelRef = useRef<HTMLDivElement>(null);

  // Reset inner state shortly after close so re-open starts fresh
  useEffect(() => {
    if (!isOpen) {
      const t = setTimeout(() => { setPhase('books'); setSelectedBook(null); }, 200);
      return () => clearTimeout(t);
    }
  }, [isOpen]);

  // Escape key
  useEffect(() => {
    const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    document.addEventListener('keydown', handler);
    return () => document.removeEventListener('keydown', handler);
  }, [onClose]);

  // Click-outside for dropdown mode (short delay to not fire on the opening click)
  useEffect(() => {
    if (mode !== 'dropdown' || !isOpen) return;
    const handler = (e: MouseEvent) => {
      if (panelRef.current && !panelRef.current.contains(e.target as Node)) onClose();
    };
    const t = setTimeout(() => document.addEventListener('mousedown', handler), 80);
    return () => { clearTimeout(t); document.removeEventListener('mousedown', handler); };
  }, [isOpen, mode, onClose]);

  if (!isOpen) return null;

  const groups: string[] = testament === 'OT' ? [...OT_GROUPS] : [...NT_GROUPS];
  const books = BIBLE_BOOKS.filter(b => b.testament === testament);

  function handleBookClick(book: BibleBook) {
    if (book.status === 'coming-soon') {
      router.push(`/${book.slug}`);
      onClose();
    } else {
      setSelectedBook(book);
      setPhase('chapters');
    }
  }

  function handleChapterClick(ch: number) {
    if (!selectedBook) return;
    router.push(`/${selectedBook.slug}/${ch}`);
    onClose();
  }

  const isSheet = mode === 'sheet';

  const panelClass = isSheet
    ? 'fixed inset-x-0 bottom-0 z-50 bg-white rounded-t-3xl shadow-2xl max-h-[82vh] flex flex-col overflow-hidden'
    : 'absolute top-full left-0 mt-2 w-[540px] max-w-[calc(100vw-2rem)] bg-white rounded-2xl shadow-2xl border border-amber-100 max-h-[480px] flex flex-col z-50 overflow-hidden';

  return (
    <>
      {/* Backdrop — dark for sheet, transparent for dropdown */}
      <div
        className={`fixed inset-0 ${isSheet ? 'z-40 bg-black/40 backdrop-blur-sm' : 'z-40'}`}
        onClick={onClose}
        aria-hidden="true"
      />

      <div
        ref={panelRef}
        className={panelClass}
        role="dialog"
        aria-modal="true"
        aria-label="Open the Bible"
      >
        {/* Drag handle (sheet only) */}
        {isSheet && (
          <div className="flex justify-center pt-3 pb-1 flex-shrink-0">
            <div className="w-10 h-1 bg-stone-200 rounded-full" />
          </div>
        )}

        {/* Panel header */}
        <div className="flex items-center justify-between px-5 py-3.5 border-b border-stone-100 flex-shrink-0 gap-3">
          <div className="flex items-center gap-2.5 min-w-0">
            {phase === 'chapters' && (
              <button
                onClick={() => { setPhase('books'); setSelectedBook(null); }}
                className="text-amber-600 hover:text-amber-800 font-bold text-sm flex items-center gap-1 transition-colors flex-shrink-0"
              >
                ← Back
              </button>
            )}
            <h2 className="font-bold text-stone-800 text-sm truncate">
              {phase === 'books'
                ? '📖 Open the Bible'
                : `${selectedBook?.emoji} ${selectedBook?.name} — ${selectedBook?.totalChapters} ${
                    selectedBook?.totalChapters === 1 ? 'chapter' : 'chapters'
                  }`
              }
            </h2>
          </div>
          <button
            onClick={onClose}
            className="w-7 h-7 flex items-center justify-center rounded-lg text-stone-400 hover:text-stone-600 hover:bg-stone-100 font-bold text-xl leading-none transition-colors flex-shrink-0"
            aria-label="Close"
          >
            ×
          </button>
        </div>

        {/* ── BOOKS PHASE ── */}
        {phase === 'books' && (
          <>
            {/* OT / NT toggle */}
            <div className="px-5 pt-3 pb-1 flex-shrink-0">
              <div className="inline-flex bg-stone-100 rounded-xl p-0.5">
                {(['NT', 'OT'] as Testament[]).map(t => (
                  <button
                    key={t}
                    onClick={() => setTestament(t)}
                    className={`px-4 py-1.5 rounded-[10px] text-xs font-extrabold transition-all ${
                      testament === t
                        ? t === 'NT'
                          ? 'bg-white text-emerald-700 shadow-sm'
                          : 'bg-white text-amber-700 shadow-sm'
                        : 'text-stone-500 hover:text-stone-700'
                    }`}
                  >
                    {t === 'NT' ? 'New Testament' : 'Old Testament'}
                  </button>
                ))}
              </div>
            </div>

            {/* Book groups */}
            <div className="overflow-y-auto flex-1 px-5 pb-5 space-y-4 mt-2">
              {groups.map(group => {
                const groupBooks = books.filter(b => b.group === group);
                return (
                  <div key={group}>
                    <p className="text-[10px] font-extrabold text-stone-400 uppercase tracking-[0.18em] mb-2">
                      {group}
                    </p>
                    <div className="grid grid-cols-3 sm:grid-cols-4 gap-1.5">
                      {groupBooks.map(book => (
                        <button
                          key={book.slug}
                          onClick={() => handleBookClick(book)}
                          title={book.status === 'coming-soon' ? `${book.name} — coming soon` : `Open ${book.name}`}
                          className={`flex items-center gap-1.5 px-2.5 py-2 rounded-xl text-left text-xs font-bold transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                            book.status === 'available'
                              ? 'bg-amber-50 hover:bg-amber-100 text-amber-900 border border-amber-200 hover:border-amber-400'
                              : book.status === 'in-progress'
                              ? 'bg-stone-50 hover:bg-stone-100 text-stone-700 border border-stone-200 hover:border-stone-300'
                              : 'bg-white text-stone-400 border border-stone-100 cursor-default opacity-60'
                          }`}
                        >
                          <span className="text-sm leading-none flex-shrink-0">{book.emoji}</span>
                          <span className="leading-tight line-clamp-1">{book.name}</span>
                        </button>
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
          </>
        )}

        {/* ── CHAPTERS PHASE ── */}
        {phase === 'chapters' && selectedBook && (
          <div className="overflow-y-auto flex-1 p-5">
            <p className="text-sm text-stone-500 mb-4 leading-relaxed italic">
              {selectedBook.tagline}
            </p>
            <div className="grid grid-cols-6 sm:grid-cols-8 gap-2">
              {Array.from({ length: selectedBook.totalChapters }, (_, i) => i + 1).map(ch => (
                <button
                  key={ch}
                  onClick={() => handleChapterClick(ch)}
                  className="flex items-center justify-center h-10 rounded-xl font-extrabold text-sm bg-amber-50 hover:bg-amber-500 hover:text-white text-amber-800 border border-amber-200 hover:border-amber-500 transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
                >
                  {ch}
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </>
  );
}
