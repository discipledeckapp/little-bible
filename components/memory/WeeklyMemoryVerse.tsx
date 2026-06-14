'use client';

import { useState, useEffect } from 'react';
import { isWeeklyVersePracticed, markWeeklyVersePracticed } from '@/lib/activities';
import MemoryBuilder from '@/components/activities/MemoryBuilder';
import SeedToast from '@/components/growth/SeedToast';
import { addSeeds } from '@/lib/progress';

interface VerseData {
  ref: string;
  text: string;
  littleBible: string;
  phrase: string;
  phraseWords: string[];
  weekStart: string;
  seedsForPractice: number;
  lumiMessage: string;
}

export default function WeeklyMemoryVerse() {
  const [verse, setVerse] = useState<VerseData | null>(null);
  const [practiced, setPracticed] = useState(false);
  const [practicing, setPracticing] = useState(false);
  const [seedToast, setSeedToast] = useState<number | null>(null);

  useEffect(() => {
    fetch('/data/en/weekly-verse.json')
      .then(r => r.ok ? r.json() : null)
      .then((data: VerseData | null) => {
        if (data) {
          setVerse(data);
          setPracticed(isWeeklyVersePracticed(data.weekStart));
        }
      })
      .catch(() => {});
  }, []);

  if (!verse) return null;

  function handlePracticeComplete(seeds: number) {
    if (!verse) return;
    addSeeds(seeds);
    markWeeklyVersePracticed(verse.weekStart);
    setPracticed(true);
    setPracticing(false);
    setSeedToast(seeds);
  }

  if (practicing) {
    return (
      <section className="py-10 px-4 bg-amber-50 border-y border-amber-100">
        <div className="max-w-lg mx-auto bg-white rounded-3xl shadow-md overflow-hidden">
          <MemoryBuilder
            data={{
              phrase:      verse.phrase,
              phraseWords: verse.phraseWords,
              verseRef:    verse.ref,
              verseText:   verse.text,
            }}
            onComplete={(seeds) => handlePracticeComplete(seeds)}
            onBack={() => setPracticing(false)}
          />
        </div>
      </section>
    );
  }

  return (
    <>
      {seedToast !== null && (
        <SeedToast amount={seedToast} onHide={() => setSeedToast(null)} />
      )}
      <section className="py-10 px-4 bg-amber-50 border-y border-amber-100">
        <div className="max-w-2xl mx-auto">

          {/* Header */}
          <div className="flex items-center gap-3 mb-5">
            <div className="w-10 h-10 bg-amber-100 rounded-xl flex items-center justify-center text-xl">
              📅
            </div>
            <div>
              <p className="text-xs font-bold text-amber-600 uppercase tracking-widest">This Week</p>
              <p className="text-stone-800 font-bold text-base leading-tight">Memory Verse</p>
            </div>
            {practiced && (
              <div className="ml-auto flex items-center gap-1.5 bg-green-100 rounded-full px-3 py-1">
                <span className="text-green-600 text-sm">✓</span>
                <span className="text-green-700 text-xs font-bold">Practiced!</span>
              </div>
            )}
          </div>

          {/* Verse card */}
          <div className="bg-white rounded-2xl px-5 py-5 shadow-sm border border-amber-100 mb-4">
            <p className="text-xs font-bold text-amber-500 uppercase tracking-widest mb-2">{verse.ref}</p>

            <p
              className="text-stone-800 text-xl font-bold leading-relaxed mb-3"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              &ldquo;{verse.phrase}&rdquo;
            </p>

            <p className="text-stone-500 text-sm leading-relaxed">
              {verse.littleBible}
            </p>
          </div>

          {/* Practice CTA */}
          <div className="flex items-center gap-3">
            {practiced ? (
              <div className="flex-1 py-3.5 rounded-2xl bg-green-100 border border-green-200 text-center">
                <p className="font-bold text-green-800 text-sm">🌱 Verse practiced this week!</p>
                <p className="text-green-600 text-xs mt-0.5">Come back next week for a new verse.</p>
              </div>
            ) : (
              <button
                onClick={() => setPracticing(true)}
                className="flex-1 py-3.5 rounded-2xl bg-amber-500 hover:bg-amber-600 text-white font-bold text-sm active:scale-95 transition-all shadow-sm"
              >
                🔤 Practice This Verse
                <span className="ml-2 text-amber-200 font-normal text-xs">+{verse.seedsForPractice} seeds</span>
              </button>
            )}
            <button
              onClick={() => {
                if (!verse) return;
                const phrase = verse.phrase;
                if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
                  const utt = new SpeechSynthesisUtterance(phrase);
                  utt.rate = 0.75;
                  utt.pitch = 1.05;
                  window.speechSynthesis.speak(utt);
                }
              }}
              className="w-12 h-12 rounded-xl bg-white border border-amber-200 hover:bg-amber-50 flex items-center justify-center text-xl transition-colors active:scale-95"
              aria-label="Hear the verse"
              title="Hear it"
            >
              🔊
            </button>
          </div>

        </div>
      </section>
    </>
  );
}
