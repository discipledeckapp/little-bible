'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { useSession } from 'next-auth/react';
import { Suspense } from 'react';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import LumiMascot from '@/components/mascot/LumiMascot';

const USD_AMOUNTS = [
  { cents: 500,   label: '$5'   },
  { cents: 1000,  label: '$10'  },
  { cents: 2500,  label: '$25'  },
  { cents: 5000,  label: '$50'  },
];

const NGN_AMOUNTS = [
  { kobo: 200000,  label: '₦2,000'  },
  { kobo: 500000,  label: '₦5,000'  },
  { kobo: 1000000, label: '₦10,000' },
  { kobo: 2500000, label: '₦25,000' },
];

type Currency = 'usd' | 'ngn';

function DonateContent() {
  const router        = useRouter();
  const searchParams  = useSearchParams();
  const { data: session } = useSession();
  const [currency,    setCurrency]    = useState<Currency>('usd');
  const [loading,     setLoading]     = useState(false);
  const [email,       setEmail]       = useState('');
  const [showSuccess, setShowSuccess] = useState(false);

  useEffect(() => {
    if (searchParams.get('success') === '1') setShowSuccess(true);
  }, [searchParams]);

  async function handleDonate(amount: number) {
    setLoading(true);
    try {
      const endpoint = currency === 'usd' ? '/api/donate/stripe' : '/api/donate/paystack';
      const body: Record<string, unknown> = { amount, currency };
      if (currency === 'ngn' && !session?.user?.email) body.email = email || 'anonymous@littlebible.app';

      const res  = await fetch(endpoint, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(body),
      });
      const data = await res.json() as { url?: string; error?: string };

      if (data.url) {
        router.push(data.url);
      }
    } catch {
      // silently fail — user can retry
    } finally {
      setLoading(false);
    }
  }

  if (showSuccess) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center text-center px-6 py-16">
        <LumiMascot stage="tree" className="w-36 h-36 mx-auto mb-6" animate />
        <h2 className="font-display text-3xl font-bold text-stone-800 mb-3">
          Thank you so much! 🙏
        </h2>
        <p className="text-stone-500 text-lg max-w-sm leading-relaxed mb-8">
          Your generosity helps bring God&apos;s Word to children around the world.
          Lumi grew a little today because of you.
        </p>
        <a
          href="/"
          className="bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-8 py-4 rounded-2xl transition-colors shadow-sm"
        >
          Continue reading ✨
        </a>
      </div>
    );
  }

  const amounts = currency === 'usd' ? USD_AMOUNTS : NGN_AMOUNTS;

  return (
    <main className="flex-1 max-w-xl mx-auto w-full px-4 py-10 space-y-8">

      {/* Hero */}
      <div className="text-center space-y-4">
        <LumiMascot stage="plant" className="w-24 h-24 mx-auto" />
        <h1 className="font-display text-3xl font-bold text-stone-800 leading-tight">
          Help Lumi keep growing
        </h1>
        <p className="text-stone-500 text-base leading-relaxed max-w-sm mx-auto">
          Little Bible is free for every family. Your donation keeps it open,
          expanding to all 66 books of Scripture — faithfully, for free.
        </p>

        <div className="flex justify-center gap-3 flex-wrap text-sm text-stone-500">
          {['Open source', 'Ad-free', 'No subscriptions', 'All 66 books'].map((tag) => (
            <span key={tag} className="bg-amber-50 border border-amber-200 text-amber-700 rounded-full px-3 py-1 font-semibold">
              {tag}
            </span>
          ))}
        </div>
      </div>

      {/* Currency toggle */}
      <div>
        <p className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-3 text-center">
          Choose currency
        </p>
        <div className="grid grid-cols-2 gap-2">
          {([
            { value: 'usd', flag: '🇺🇸', label: 'US Dollars' },
            { value: 'ngn', flag: '🇳🇬', label: 'Nigerian Naira' },
          ] as const).map((opt) => (
            <button
              key={opt.value}
              onClick={() => setCurrency(opt.value)}
              className={`flex items-center justify-center gap-2.5 py-3.5 rounded-2xl border-2 font-bold text-sm transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400 ${
                currency === opt.value
                  ? 'border-amber-400 bg-amber-50 text-amber-800'
                  : 'border-stone-200 text-stone-500 hover:border-stone-300'
              }`}
            >
              <span className="text-xl" aria-hidden="true">{opt.flag}</span>
              {opt.label}
            </button>
          ))}
        </div>
      </div>

      {/* Amount selection */}
      <div>
        <p className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-3 text-center">
          Choose an amount
        </p>
        <div className="grid grid-cols-2 gap-3">
          {'cents' in amounts[0]
            ? (amounts as typeof USD_AMOUNTS).map(({ cents, label }) => (
                <button
                  key={cents}
                  onClick={() => handleDonate(cents)}
                  disabled={loading}
                  className="flex flex-col items-center gap-1 py-5 rounded-2xl border-2 border-stone-200 hover:border-amber-400 hover:bg-amber-50 font-extrabold text-stone-800 text-xl transition-all active:scale-95 disabled:opacity-50 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
                >
                  {label}
                  <span className="text-xs font-semibold text-stone-400">one-time</span>
                </button>
              ))
            : (amounts as typeof NGN_AMOUNTS).map(({ kobo, label }) => (
                <button
                  key={kobo}
                  onClick={() => handleDonate(kobo)}
                  disabled={loading}
                  className="flex flex-col items-center gap-1 py-5 rounded-2xl border-2 border-stone-200 hover:border-green-400 hover:bg-green-50 font-extrabold text-stone-800 text-xl transition-all active:scale-95 disabled:opacity-50 focus:outline-none focus-visible:ring-2 focus-visible:ring-green-400"
                >
                  {label}
                  <span className="text-xs font-semibold text-stone-400">one-time</span>
                </button>
              ))
          }
        </div>
      </div>

      {/* Email for Paystack guest */}
      {currency === 'ngn' && !session?.user?.email && (
        <div>
          <label className="block text-sm font-semibold text-stone-600 mb-1.5" htmlFor="donor-email">
            Your email (for receipt)
          </label>
          <input
            id="donor-email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="your@email.com"
            className="w-full border border-stone-200 rounded-xl px-4 py-3 text-sm text-stone-800 focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400"
          />
        </div>
      )}

      {loading && (
        <p className="text-center text-amber-600 font-semibold text-sm animate-pulse">
          Opening payment page…
        </p>
      )}

      {/* Mission note */}
      <div className="bg-amber-50 rounded-3xl px-6 py-5 border border-amber-100 text-sm text-stone-600 leading-relaxed text-center">
        Every donation goes directly toward writing and translating content.
        No ads. No venture capital. Just families and faith.
      </div>

    </main>
  );
}

export default function DonatePage() {
  return (
    <div className="min-h-screen flex flex-col bg-[#FFFBF5]">
      <Header />
      <Suspense fallback={<div className="flex-1" />}>
        <DonateContent />
      </Suspense>
      <Footer />
    </div>
  );
}
