'use client';

import { useState, useEffect } from 'react';
import { signIn } from 'next-auth/react';
import LumiMascot from '@/components/mascot/LumiMascot';

const ONBOARDED_KEY   = 'little_bible_onboarded';
const READER_MODE_KEY = 'little_bible_reader_mode';

type AgeChoice = '4-5' | '5-7' | 'both';

const STEPS = ['welcome', 'age', 'signin'] as const;
type Step = (typeof STEPS)[number];

export default function OnboardingFlow() {
  const [show, setShow]     = useState(false);
  const [step, setStep]     = useState<Step>('welcome');
  const [age,  setAge]      = useState<AgeChoice | null>(null);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    if (!localStorage.getItem(ONBOARDED_KEY)) setShow(true);
  }, []);

  if (!mounted || !show) return null;

  function handleAgeSelect(choice: AgeChoice) {
    setAge(choice);
    // Set reader mode default based on age choice
    localStorage.setItem(READER_MODE_KEY, choice === '4-5' ? 'little' : 'standard');
    setStep('signin');
  }

  function handleFinishAsGuest() {
    localStorage.setItem(ONBOARDED_KEY, '1');
    setShow(false);
  }

  function handleGoogleSignIn() {
    localStorage.setItem(ONBOARDED_KEY, '1');
    signIn('google', { callbackUrl: '/proverbs/1' });
  }

  const stepIndex = STEPS.indexOf(step);
  const progress  = Math.round(((stepIndex + 1) / STEPS.length) * 100);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-amber-950/60 backdrop-blur-sm px-4"
      role="dialog"
      aria-modal="true"
      aria-label="Welcome to Little Bible"
    >
      <div className="bg-white rounded-3xl shadow-2xl w-full max-w-sm overflow-hidden">

        {/* Progress bar */}
        <div className="h-1 bg-amber-100">
          <div
            className="h-1 bg-amber-400 transition-all duration-500"
            style={{ width: `${progress}%` }}
            aria-hidden="true"
          />
        </div>

        <div className="px-7 py-8">

          {/* ── Step 1: Welcome ── */}
          {step === 'welcome' && (
            <div className="text-center space-y-5">
              <LumiMascot stage="seed" className="w-28 h-28 mx-auto" animate />

              <div>
                <h1 className="font-display text-2xl font-bold text-stone-800 mb-2 leading-tight">
                  Welcome to Little Bible
                </h1>
                <p className="text-stone-500 text-base leading-relaxed">
                  God&apos;s Word — faithfully adapted for little hearts.
                  Short daily devotions your whole family will love.
                </p>
              </div>

              <div className="space-y-2 text-left bg-amber-50 rounded-2xl p-4 border border-amber-100">
                {[
                  ['📖', 'Every verse of the Bible, in language kids understand'],
                  ['🙏', '5-step family devotions — Read, Discuss, Pray, Remember, Do It'],
                  ['🌱', 'Watch Lumi grow as your family reads together'],
                ].map(([emoji, text]) => (
                  <div key={text} className="flex items-start gap-2.5">
                    <span className="text-lg flex-shrink-0" aria-hidden="true">{emoji}</span>
                    <p className="text-stone-700 text-sm font-medium leading-snug">{text}</p>
                  </div>
                ))}
              </div>

              <button
                onClick={() => setStep('age')}
                className="w-full bg-amber-500 hover:bg-amber-600 text-white font-extrabold text-base py-4 rounded-2xl transition-all active:scale-95 shadow-sm focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
              >
                Let&apos;s begin! →
              </button>
            </div>
          )}

          {/* ── Step 2: Age range ── */}
          {step === 'age' && (
            <div className="text-center space-y-5">
              <div className="text-5xl" aria-hidden="true">👶🧒</div>

              <div>
                <h2 className="font-display text-xl font-bold text-stone-800 mb-2">
                  How old is your child?
                </h2>
                <p className="text-stone-400 text-sm">
                  We&apos;ll set the right reading level to start.
                  You can always change this later.
                </p>
              </div>

              <div className="space-y-3">
                {([
                  {
                    choice: '4-5' as AgeChoice,
                    emoji:  '🌱',
                    label:  'Ages 4–5',
                    desc:   'Simple sentences, big picture truths',
                  },
                  {
                    choice: '5-7' as AgeChoice,
                    emoji:  '📖',
                    label:  'Ages 5–7',
                    desc:   'Richer language, same faithful heart',
                  },
                  {
                    choice: 'both' as AgeChoice,
                    emoji:  '👨‍👩‍👧‍👦',
                    label:  'Mixed ages',
                    desc:   'Multiple kids — we\'ll include both levels',
                  },
                ] as const).map(({ choice, emoji, label, desc }) => (
                  <button
                    key={choice}
                    onClick={() => handleAgeSelect(choice)}
                    className={`w-full flex items-center gap-4 px-5 py-4 rounded-2xl border-2 text-left transition-all active:scale-[0.98] focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                      age === choice
                        ? 'border-amber-400 bg-amber-50'
                        : 'border-stone-200 hover:border-amber-200 hover:bg-amber-50/40'
                    }`}
                  >
                    <span className="text-2xl flex-shrink-0" aria-hidden="true">{emoji}</span>
                    <div>
                      <p className="font-extrabold text-stone-800 text-sm">{label}</p>
                      <p className="text-stone-400 text-xs">{desc}</p>
                    </div>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* ── Step 3: Sign in or guest ── */}
          {step === 'signin' && (
            <div className="text-center space-y-5">
              <LumiMascot stage="seed" className="w-20 h-20 mx-auto" />

              <div>
                <h2 className="font-display text-xl font-bold text-stone-800 mb-2">
                  Save your journey
                </h2>
                <p className="text-stone-500 text-sm leading-relaxed">
                  Sign in with Google to keep Lumi growing across all your devices.
                  Your family&apos;s progress is always safe.
                </p>
              </div>

              {/* Google sign-in — primary */}
              <button
                onClick={handleGoogleSignIn}
                className="w-full flex items-center justify-center gap-3 bg-white hover:bg-stone-50 text-stone-800 font-bold text-base px-6 py-4 rounded-2xl border-2 border-stone-200 shadow-sm transition-all active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
              >
                <GoogleIcon />
                Continue with Google
              </button>

              {/* Divider */}
              <div className="flex items-center gap-3">
                <div className="flex-1 h-px bg-stone-200" aria-hidden="true" />
                <span className="text-stone-400 text-xs font-medium">or</span>
                <div className="flex-1 h-px bg-stone-200" aria-hidden="true" />
              </div>

              {/* Guest option */}
              <button
                onClick={handleFinishAsGuest}
                className="w-full text-stone-500 hover:text-stone-700 font-semibold text-sm py-3 rounded-2xl border border-stone-200 hover:border-stone-300 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-stone-300"
              >
                Continue without signing in
              </button>

              <p className="text-stone-400 text-xs">
                No account needed to read. Sign in anytime from Settings.
              </p>
            </div>
          )}

        </div>

        {/* Step dots */}
        <div className="flex justify-center gap-2 pb-5" aria-hidden="true">
          {STEPS.map((s) => (
            <div
              key={s}
              className={`rounded-full transition-all ${
                s === step ? 'w-6 h-2 bg-amber-500' : 'w-2 h-2 bg-stone-200'
              }`}
            />
          ))}
        </div>

      </div>
    </div>
  );
}

function GoogleIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true">
      <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
      <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
      <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
      <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
    </svg>
  );
}
