'use client';

import { useState, useEffect } from 'react';
import { useSession, signIn } from 'next-auth/react';

type Prefs = {
  wantsIos:     boolean;
  wantsAndroid: boolean;
  wantsPush:    boolean;
  wantsEmail:   boolean;
};

interface AppInterestPanelProps {
  compact?: boolean; // banner mode vs. full page mode
}

export default function AppInterestPanel({ compact = false }: AppInterestPanelProps) {
  const { data: session, status } = useSession();
  const [loading,  setLoading]  = useState(false);
  const [saved,    setSaved]    = useState(false);
  const [error,    setError]    = useState('');
  const [prefs,    setPrefs]    = useState<Prefs>({
    wantsIos:     false,
    wantsAndroid: false,
    wantsPush:    true,
    wantsEmail:   true,
  });

  // Load existing preferences when signed in
  useEffect(() => {
    if (status !== 'authenticated') return;
    fetch('/api/app-interest')
      .then(r => r.json())
      .then(data => {
        if (data.interest) {
          setPrefs(data.interest);
          setSaved(true);
        }
      })
      .catch(() => {});
  }, [status]);

  async function handleSave() {
    if (!prefs.wantsIos && !prefs.wantsAndroid) {
      setError('Please select at least one platform.');
      return;
    }
    if (!prefs.wantsEmail && !prefs.wantsPush) {
      setError('Please select at least one notification method.');
      return;
    }
    setLoading(true);
    setError('');
    try {
      const res = await fetch('/api/app-interest', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(prefs),
      });
      if (!res.ok) throw new Error('Save failed');
      setSaved(true);
    } catch {
      setError('Could not save. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  function toggle(key: keyof Prefs) {
    setPrefs(prev => ({ ...prev, [key]: !prev[key] }));
    if (saved) setSaved(false); // reset saved state so they can re-save
    setError('');
  }

  // ── Loading state ──────────────────────────────────────────────
  if (status === 'loading') {
    return (
      <div className={`animate-pulse bg-stone-100 rounded-2xl ${compact ? 'h-16' : 'h-48'}`} />
    );
  }

  // ── Signed-out state ──────────────────────────────────────────
  if (status === 'unauthenticated') {
    return (
      <div className="text-center">
        <p className={`text-stone-500 mb-4 ${compact ? 'text-sm' : 'text-base'}`}>
          Sign in to save your platform preferences and get notified the moment the app launches.
          No marketing emails — one notification per platform launch.
        </p>
        <button
          onClick={() => signIn('google')}
          className="inline-flex items-center gap-2.5 bg-amber-500 hover:bg-amber-600 text-white font-bold px-6 py-3.5 rounded-2xl transition-all active:scale-95 shadow-md focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
        >
          <svg viewBox="0 0 24 24" className="w-5 h-5 shrink-0" aria-hidden="true">
            <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
            <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
            <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
            <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
          </svg>
          Sign in with Google to Get Notified
        </button>
        <p className="mt-3 text-stone-400 text-xs">
          Already a Little Bible user? Sign in with the same account.
        </p>
      </div>
    );
  }

  // ── Saved / confirmed state ────────────────────────────────────
  if (saved && !loading) {
    const platforms = [
      prefs.wantsIos     && 'iPhone',
      prefs.wantsAndroid && 'Android',
    ].filter(Boolean).join(' & ');

    const methods = [
      prefs.wantsEmail && 'email',
      prefs.wantsPush  && 'push notification',
    ].filter(Boolean).join(' and ');

    return (
      <div className="text-center">
        <div className="text-5xl mb-4">🌱</div>
        <p className="text-stone-800 font-bold text-xl mb-2">Saved!</p>
        <p className="text-stone-500 text-sm mb-1">
          You&apos;ll be notified when the <strong>{platforms}</strong> app launches.
        </p>
        <p className="text-stone-400 text-xs mb-5">
          We&apos;ll send you a {methods}. That&apos;s it.
        </p>
        <button
          onClick={() => setSaved(false)}
          className="text-amber-600 hover:text-amber-700 text-sm font-semibold underline underline-offset-2 focus:outline-none"
        >
          Update preferences
        </button>
      </div>
    );
  }

  // ── Preference form ────────────────────────────────────────────
  return (
    <div className="space-y-6">
      {session?.user?.name && (
        <p className="text-stone-500 text-sm text-center">
          Saving preferences for{' '}
          <span className="font-semibold text-stone-700">{session.user.name}</span>
        </p>
      )}

      {/* Platform */}
      <div>
        <p className="text-stone-700 font-bold text-sm mb-3">
          Which platform(s) do you want?
        </p>
        <div className="grid grid-cols-2 gap-3">
          {[
            { key: 'wantsIos'     as const, label: 'iPhone',  sub: 'iOS · App Store',   icon: '🍎' },
            { key: 'wantsAndroid' as const, label: 'Android', sub: 'Google Play Store',  icon: '🤖' },
          ].map(p => (
            <button
              key={p.key}
              onClick={() => toggle(p.key)}
              aria-pressed={prefs[p.key]}
              className={`flex items-center gap-3 p-4 rounded-2xl border-2 transition-all text-left focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                prefs[p.key]
                  ? 'border-amber-500 bg-amber-50 shadow-sm'
                  : 'border-stone-200 bg-stone-50 hover:border-stone-300'
              }`}
            >
              <span className="text-2xl">{p.icon}</span>
              <div className="flex-1 min-w-0">
                <p className="font-bold text-stone-800 text-sm">{p.label}</p>
                <p className="text-stone-400 text-xs">{p.sub}</p>
              </div>
              <div
                className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 transition-all ${
                  prefs[p.key]
                    ? 'border-amber-500 bg-amber-500'
                    : 'border-stone-300 bg-white'
                }`}
              >
                {prefs[p.key] && (
                  <svg viewBox="0 0 12 12" className="w-3 h-3" fill="none">
                    <path d="M2 6l3 3 5-5" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                )}
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Notification method */}
      <div>
        <p className="text-stone-700 font-bold text-sm mb-3">
          How would you like to be notified?
        </p>
        <div className="grid grid-cols-2 gap-3">
          {[
            { key: 'wantsEmail' as const, label: 'Email',             sub: 'One email on launch',    icon: '✉️' },
            { key: 'wantsPush'  as const, label: 'Push notification', sub: 'In-app notification',    icon: '🔔' },
          ].map(p => (
            <button
              key={p.key}
              onClick={() => toggle(p.key)}
              aria-pressed={prefs[p.key]}
              className={`flex items-center gap-3 p-4 rounded-2xl border-2 transition-all text-left focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                prefs[p.key]
                  ? 'border-amber-500 bg-amber-50 shadow-sm'
                  : 'border-stone-200 bg-stone-50 hover:border-stone-300'
              }`}
            >
              <span className="text-2xl">{p.icon}</span>
              <div className="flex-1 min-w-0">
                <p className="font-bold text-stone-800 text-sm">{p.label}</p>
                <p className="text-stone-400 text-xs">{p.sub}</p>
              </div>
              <div
                className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 transition-all ${
                  prefs[p.key]
                    ? 'border-amber-500 bg-amber-500'
                    : 'border-stone-300 bg-white'
                }`}
              >
                {prefs[p.key] && (
                  <svg viewBox="0 0 12 12" className="w-3 h-3" fill="none">
                    <path d="M2 6l3 3 5-5" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                )}
              </div>
            </button>
          ))}
        </div>
      </div>

      {error && (
        <p className="text-red-500 text-sm font-medium" role="alert">{error}</p>
      )}

      <button
        onClick={handleSave}
        disabled={loading}
        className="w-full bg-amber-500 hover:bg-amber-600 disabled:opacity-60 text-white font-extrabold py-4 rounded-2xl transition-all active:scale-98 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 text-base"
      >
        {loading ? 'Saving…' : 'Save My Preferences'}
      </button>

      <p className="text-stone-400 text-xs text-center leading-relaxed">
        No spam. One notification per platform when it launches. You can update or
        remove your preferences any time from your account settings.
      </p>
    </div>
  );
}
