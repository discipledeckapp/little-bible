'use client';

import { useState, useEffect, useCallback, useRef } from 'react';

const PIN_KEY     = 'little_bible_review_pin';
const DEFAULT_PIN = '1234';
const PIN_LENGTH  = 4;

interface PinModalProps {
  onUnlock: () => void;
}

export default function PinModal({ onUnlock }: PinModalProps) {
  const [digits, setDigits]   = useState<string[]>([]);
  const [error, setError]     = useState(false);
  const [shake, setShake]     = useState(false);
  const [isSet, setIsSet]     = useState(false); // setting a new PIN vs entering
  const [confirm, setConfirm] = useState<string[]>([]);
  const [stage, setStage]     = useState<'enter' | 'set-new' | 'confirm-new'>('enter');
  const btnRef = useRef<HTMLButtonElement>(null);

  // Focus trap: keep focus inside modal
  useEffect(() => {
    btnRef.current?.focus();
  }, []);

  const storedPin = useCallback(() => {
    if (typeof window === 'undefined') return DEFAULT_PIN;
    return localStorage.getItem(PIN_KEY) ?? DEFAULT_PIN;
  }, []);

  const triggerShake = useCallback(() => {
    setError(true);
    setShake(true);
    setTimeout(() => { setShake(false); setDigits([]); }, 600);
    setTimeout(() => setError(false), 600);
  }, []);

  const handleDigit = useCallback((d: string) => {
    if (digits.length >= PIN_LENGTH) return;
    const next = [...digits, d];
    setDigits(next);

    if (next.length < PIN_LENGTH) return;

    const entered = next.join('');

    if (stage === 'enter') {
      if (entered === storedPin()) {
        onUnlock();
      } else {
        triggerShake();
      }
    } else if (stage === 'set-new') {
      setConfirm([]);
      setDigits([]);
      setStage('confirm-new');
      // stash the first entry in confirm
      setConfirm(next);
    } else if (stage === 'confirm-new') {
      if (entered === confirm.join('')) {
        localStorage.setItem(PIN_KEY, entered);
        onUnlock();
      } else {
        triggerShake();
        setStage('set-new');
        setConfirm([]);
      }
    }
  }, [digits, stage, storedPin, onUnlock, triggerShake, confirm]);

  const handleDelete = useCallback(() => {
    setDigits((d) => d.slice(0, -1));
    setError(false);
  }, []);

  const title = {
    'enter':       'Review Mode',
    'set-new':     'Set a New PIN',
    'confirm-new': 'Confirm New PIN',
  }[stage];

  const subtitle = {
    'enter':       'Enter your 4-digit PIN to continue',
    'set-new':     'Choose a 4-digit PIN for Review Mode',
    'confirm-new': 'Enter the same PIN again',
  }[stage];

  const KEYS = [
    ['1','2','3'],
    ['4','5','6'],
    ['7','8','9'],
  ];

  return (
    <div
      className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-end sm:items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-label="Review Mode PIN Entry"
    >
      <div
        className={`w-full max-w-xs bg-white rounded-3xl shadow-2xl overflow-hidden ${shake ? 'animate-[wiggle_0.5s_ease-in-out]' : ''}`}
        style={shake ? { animation: 'shake 0.5s ease-in-out' } : undefined}
      >

        {/* Header */}
        <div className="bg-gradient-to-b from-stone-700 to-stone-800 px-6 pt-7 pb-5 text-center">
          <p className="text-3xl mb-1" aria-hidden="true">🔒</p>
          <h2 className="text-white font-extrabold text-xl font-display">{title}</h2>
          <p className="text-stone-300 text-sm mt-1">{subtitle}</p>
        </div>

        {/* PIN dots */}
        <div className="flex justify-center gap-4 py-6" aria-label={`${digits.length} of ${PIN_LENGTH} digits entered`} aria-live="polite">
          {Array.from({ length: PIN_LENGTH }, (_, i) => (
            <span
              key={i}
              className={`pin-dot ${i < digits.length ? (error ? 'error' : 'filled') : ''}`}
            />
          ))}
        </div>

        {/* Numeric keypad */}
        <div className="px-6 pb-6 space-y-3">
          {KEYS.map((row) => (
            <div key={row.join('')} className="grid grid-cols-3 gap-3">
              {row.map((d) => (
                <button
                  key={d}
                  ref={d === '1' ? btnRef : undefined}
                  onClick={() => handleDigit(d)}
                  className="h-14 rounded-2xl bg-stone-100 hover:bg-amber-100 text-stone-800 text-2xl font-extrabold transition-colors active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
                  aria-label={`Digit ${d}`}
                >
                  {d}
                </button>
              ))}
            </div>
          ))}

          {/* Bottom row: change PIN | 0 | delete */}
          <div className="grid grid-cols-3 gap-3">
            {stage === 'enter' ? (
              <button
                onClick={() => { setDigits([]); setStage('set-new'); }}
                className="h-14 rounded-2xl bg-stone-50 text-stone-400 text-xs font-bold hover:bg-stone-100 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
                aria-label="Change PIN"
              >
                Change
              </button>
            ) : (
              <button
                onClick={() => { setDigits([]); setConfirm([]); setStage('enter'); }}
                className="h-14 rounded-2xl bg-stone-50 text-stone-400 text-xs font-bold hover:bg-stone-100 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
                aria-label="Cancel"
              >
                Cancel
              </button>
            )}

            <button
              onClick={() => handleDigit('0')}
              className="h-14 rounded-2xl bg-stone-100 hover:bg-amber-100 text-stone-800 text-2xl font-extrabold transition-colors active:scale-95 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
              aria-label="Digit 0"
            >
              0
            </button>

            <button
              onClick={handleDelete}
              disabled={digits.length === 0}
              className="h-14 rounded-2xl bg-stone-100 hover:bg-red-50 text-stone-500 text-xl font-bold transition-colors active:scale-95 disabled:opacity-30 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
              aria-label="Delete last digit"
            >
              ⌫
            </button>
          </div>
        </div>

        {/* Hint */}
        {stage === 'enter' && (
          <p className="text-center text-stone-300 text-xs pb-4">
            Default PIN: 1234
          </p>
        )}
      </div>
    </div>
  );
}
