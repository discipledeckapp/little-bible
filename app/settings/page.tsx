'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useSession, signIn, signOut } from 'next-auth/react';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import { getProgress, resetProgress } from '@/lib/progress';
import LumiMascot, { getLumiStage, getLumiLabel } from '@/components/mascot/LumiMascot';

const READER_MODE_KEY = 'little_bible_reader_mode';
const APP_MODE_KEY    = 'little_bible_mode';
const PIN_KEY         = 'little_bible_review_pin';

export default function SettingsPage() {
  const { data: session, status } = useSession();
  const [mounted, setMounted]     = useState(false);

  // Preference state
  const [readerMode, setReaderMode] = useState<'standard' | 'little'>('standard');
  const [appMode,    setAppMode]    = useState<string>('child');

  // PIN state
  const [currentPin, setCurrentPin]  = useState('1234');
  const [pinInput,   setPinInput]    = useState('');
  const [changingPin, setChangingPin] = useState(false);
  const [pinSaved,   setPinSaved]    = useState(false);

  // Reset state
  const [confirmReset, setConfirmReset] = useState(false);
  const [resetDone,    setResetDone]    = useState(false);

  // Progress stats
  const [seeds,    setSeeds]    = useState(0);
  const [streak,   setStreak]   = useState(0);
  const [sessions, setSessions] = useState(0);

  useEffect(() => {
    setMounted(true);
    setReaderMode((localStorage.getItem(READER_MODE_KEY) as 'standard' | 'little') ?? 'standard');
    setAppMode(localStorage.getItem(APP_MODE_KEY) ?? 'child');
    setCurrentPin(localStorage.getItem(PIN_KEY) ?? '1234');

    const p = getProgress();
    setSeeds(p.wisdomSeeds);
    setStreak(p.streak);
    setSessions(p.sessions.length);
  }, []);

  if (!mounted) return null;

  const lumiStage = getLumiStage(seeds);
  const lumiLabel = getLumiLabel(lumiStage);

  function saveReaderMode(mode: 'standard' | 'little') {
    setReaderMode(mode);
    localStorage.setItem(READER_MODE_KEY, mode);
  }

  function saveAppMode(mode: string) {
    setAppMode(mode);
    localStorage.setItem(APP_MODE_KEY, mode);
  }

  function handleSavePin() {
    if (pinInput.length !== 4 || !/^\d{4}$/.test(pinInput)) return;
    localStorage.setItem(PIN_KEY, pinInput);
    setCurrentPin(pinInput);
    setPinInput('');
    setChangingPin(false);
    setPinSaved(true);
    setTimeout(() => setPinSaved(false), 2500);
  }

  function handleReset() {
    if (!confirmReset) { setConfirmReset(true); return; }
    resetProgress();
    setSeeds(0); setStreak(0); setSessions(0);
    setConfirmReset(false);
    setResetDone(true);
    setTimeout(() => setResetDone(false), 3000);
  }

  return (
    <div className="min-h-screen flex flex-col bg-[#FFFBF5]">
      <Header />

      <main className="flex-1 max-w-xl mx-auto w-full px-4 py-8 space-y-6">

        {/* Page title */}
        <div className="flex items-center gap-3 mb-2">
          <Link
            href="/"
            className="text-stone-400 hover:text-stone-700 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 rounded"
            aria-label="Back to home"
          >
            ←
          </Link>
          <h1 className="font-display text-2xl font-bold text-stone-800">Settings</h1>
        </div>

        {/* ── Account ─────────────────────────────────────────── */}
        <section className="bg-white rounded-3xl border border-stone-100 shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-100">
            <h2 className="font-bold text-stone-700 text-sm uppercase tracking-widest">Account</h2>
          </div>

          {status === 'loading' ? (
            <div className="px-6 py-5">
              <div className="animate-pulse h-10 bg-stone-100 rounded-xl" />
            </div>
          ) : session?.user ? (
            <div className="px-6 py-5 flex items-center gap-4">
              {session.user.image && (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={session.user.image}
                  alt=""
                  width={44}
                  height={44}
                  className="w-11 h-11 rounded-full border-2 border-amber-200"
                />
              )}
              <div className="flex-1 min-w-0">
                <p className="font-bold text-stone-800 truncate">{session.user.name}</p>
                <p className="text-stone-400 text-xs truncate">{session.user.email}</p>
                <p className="text-emerald-600 text-xs font-semibold mt-0.5">✓ Progress synced to cloud</p>
              </div>
              <button
                onClick={() => signOut({ callbackUrl: '/' })}
                className="text-stone-400 hover:text-stone-600 text-sm font-semibold transition-colors"
              >
                Sign out
              </button>
            </div>
          ) : (
            <div className="px-6 py-5 space-y-3">
              <p className="text-stone-500 text-sm">
                Sign in to sync Lumi&apos;s growth across all your devices.
              </p>
              <button
                onClick={() => signIn('google', { callbackUrl: '/settings' })}
                className="flex items-center justify-center gap-3 w-full bg-white hover:bg-stone-50 text-stone-700 font-semibold text-sm px-4 py-3 rounded-xl border border-stone-200 shadow-sm transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
              >
                <GoogleIcon />
                Sign in with Google
              </button>
            </div>
          )}
        </section>

        {/* ── Lumi's Growth ───────────────────────────────────── */}
        <section className="bg-white rounded-3xl border border-stone-100 shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-100">
            <h2 className="font-bold text-stone-700 text-sm uppercase tracking-widest">Lumi&apos;s Growth</h2>
          </div>
          <div className="px-6 py-5 flex items-center gap-5">
            <LumiMascot stage={lumiStage} className="w-16 h-16 flex-shrink-0" />
            <div className="flex-1">
              <p className="font-extrabold text-stone-800">{lumiLabel}</p>
              <div className="grid grid-cols-3 gap-2 mt-2">
                <StatChip label="Seeds" value={seeds} />
                <StatChip label="Streak" value={`${streak}d`} />
                <StatChip label="Sessions" value={sessions} />
              </div>
            </div>
          </div>
        </section>

        {/* ── Reading Experience ───────────────────────────────── */}
        <section className="bg-white rounded-3xl border border-stone-100 shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-100">
            <h2 className="font-bold text-stone-700 text-sm uppercase tracking-widest">Reading Experience</h2>
          </div>

          <div className="divide-y divide-stone-100">
            {/* Default age mode */}
            <div className="px-6 py-4">
              <p className="font-semibold text-stone-800 text-sm mb-3">Default age level</p>
              <div className="flex gap-2">
                {[
                  { value: 'standard', label: 'Ages 5–7', emoji: '📖' },
                  { value: 'little',   label: 'Ages 4–5', emoji: '🌱' },
                ].map((opt) => (
                  <button
                    key={opt.value}
                    onClick={() => saveReaderMode(opt.value as 'standard' | 'little')}
                    className={`flex-1 flex flex-col items-center gap-1 py-3 rounded-2xl border-2 text-sm font-bold transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                      readerMode === opt.value
                        ? 'border-amber-400 bg-amber-50 text-amber-800'
                        : 'border-stone-200 text-stone-500 hover:border-stone-300'
                    }`}
                  >
                    <span className="text-lg" aria-hidden="true">{opt.emoji}</span>
                    {opt.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Default mode */}
            <div className="px-6 py-4">
              <p className="font-semibold text-stone-800 text-sm mb-3">Default reading mode</p>
              <div className="flex gap-2">
                {[
                  { value: 'child',  label: 'Bible Time', emoji: '📖' },
                  { value: 'family', label: 'Family',     emoji: '❤️' },
                ].map((opt) => (
                  <button
                    key={opt.value}
                    onClick={() => saveAppMode(opt.value)}
                    className={`flex-1 flex flex-col items-center gap-1 py-3 rounded-2xl border-2 text-sm font-bold transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                      appMode === opt.value
                        ? 'border-emerald-400 bg-emerald-50 text-emerald-800'
                        : 'border-stone-200 text-stone-500 hover:border-stone-300'
                    }`}
                  >
                    <span className="text-lg" aria-hidden="true">{opt.emoji}</span>
                    {opt.label}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* ── Privacy & Security ───────────────────────────────── */}
        <section className="bg-white rounded-3xl border border-stone-100 shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-100">
            <h2 className="font-bold text-stone-700 text-sm uppercase tracking-widest">Privacy & Security</h2>
          </div>

          <div className="px-6 py-4 space-y-3">
            <div className="flex items-center justify-between">
              <div>
                <p className="font-semibold text-stone-800 text-sm">Parent Review PIN</p>
                <p className="text-stone-400 text-xs">Used to enter Parent mode</p>
              </div>
              {pinSaved ? (
                <span className="text-emerald-600 text-sm font-bold">✓ Saved</span>
              ) : (
                <button
                  onClick={() => setChangingPin((c) => !c)}
                  className="text-amber-600 hover:text-amber-800 text-sm font-semibold transition-colors"
                >
                  {changingPin ? 'Cancel' : 'Change PIN'}
                </button>
              )}
            </div>

            {changingPin && (
              <div className="flex gap-2 mt-1">
                <input
                  type="password"
                  inputMode="numeric"
                  pattern="[0-9]{4}"
                  maxLength={4}
                  placeholder="New 4-digit PIN"
                  value={pinInput}
                  onChange={(e) => setPinInput(e.target.value.replace(/\D/g, '').slice(0, 4))}
                  className="flex-1 border border-stone-200 rounded-xl px-4 py-2.5 text-sm font-bold text-stone-800 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 tracking-widest"
                  aria-label="New 4-digit PIN"
                  autoFocus
                />
                <button
                  onClick={handleSavePin}
                  disabled={pinInput.length !== 4}
                  className="bg-amber-500 hover:bg-amber-600 disabled:opacity-40 text-white font-bold px-4 py-2.5 rounded-xl text-sm transition-colors"
                >
                  Save
                </button>
              </div>
            )}
          </div>
        </section>

        {/* ── Danger zone ─────────────────────────────────────── */}
        <section className="bg-white rounded-3xl border border-stone-100 shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-100">
            <h2 className="font-bold text-stone-700 text-sm uppercase tracking-widest">Progress</h2>
          </div>

          <div className="px-6 py-4">
            {resetDone ? (
              <p className="text-emerald-600 text-sm font-semibold text-center py-2">
                ✓ Progress reset. Lumi is a Wisdom Seed again.
              </p>
            ) : (
              <div className="space-y-2">
                <p className="text-stone-500 text-xs">
                  This will clear all seeds, sessions, and badges from this device.
                  {session?.user && ' Cloud progress will also be cleared on next sync.'}
                </p>
                <button
                  onClick={handleReset}
                  className={`w-full py-3 rounded-2xl text-sm font-bold transition-all focus:outline-none focus-visible:ring-2 ${
                    confirmReset
                      ? 'bg-red-500 text-white hover:bg-red-600 focus-visible:ring-red-400'
                      : 'border border-red-200 text-red-500 hover:bg-red-50 focus-visible:ring-red-300'
                  }`}
                >
                  {confirmReset ? '⚠️ Yes, reset everything' : 'Reset all progress'}
                </button>
                {confirmReset && (
                  <button
                    onClick={() => setConfirmReset(false)}
                    className="w-full text-stone-400 hover:text-stone-600 text-sm py-1.5 transition-colors"
                  >
                    Cancel
                  </button>
                )}
              </div>
            )}
          </div>
        </section>

        {/* ── About ───────────────────────────────────────────── */}
        <section className="bg-white rounded-3xl border border-stone-100 shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-100">
            <h2 className="font-bold text-stone-700 text-sm uppercase tracking-widest">About</h2>
          </div>
          <div className="px-6 py-5 space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-stone-500">Version</span>
              <span className="text-stone-700 font-semibold">0.1.0</span>
            </div>
            <div className="flex justify-between">
              <span className="text-stone-500">Licence</span>
              <span className="text-stone-700 font-semibold">Open Source · MIT</span>
            </div>
            <div className="flex justify-between">
              <span className="text-stone-500">Scripture basis</span>
              <span className="text-stone-700 font-semibold">KJV (public domain)</span>
            </div>
            <div className="pt-2">
              <Link
                href="/donate"
                className="flex items-center justify-center gap-2 w-full bg-amber-50 hover:bg-amber-100 text-amber-700 font-bold py-3.5 rounded-2xl border border-amber-200 transition-colors text-sm"
              >
                <span aria-hidden="true">❤️</span>
                Support this project
              </Link>
            </div>
          </div>
        </section>

      </main>

      <Footer />
    </div>
  );
}

function StatChip({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="bg-amber-50 rounded-xl px-2 py-1.5 text-center border border-amber-100">
      <p className="text-amber-700 font-extrabold text-sm leading-none">{value}</p>
      <p className="text-amber-500 text-[10px] font-semibold mt-0.5">{label}</p>
    </div>
  );
}

function GoogleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true">
      <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
      <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
      <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
      <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
    </svg>
  );
}
