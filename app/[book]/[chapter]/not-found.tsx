import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';

export default function ChapterNotFound() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="flex-1 flex items-center justify-center px-4 py-16">
        <div className="max-w-md w-full text-center">

          <div className="text-7xl mb-5 select-none" role="img" aria-label="Chapter not available">
            📖
          </div>

          <h1 className="font-bold text-stone-800 text-2xl mb-3">
            This chapter isn&apos;t available yet
          </h1>
          <p className="text-stone-500 text-base leading-relaxed mb-2 max-w-sm mx-auto">
            We&apos;re adding chapters one by one, faithfully adapting every verse for children ages 4–7.
          </p>
          <p className="text-stone-400 text-sm mb-8">
            Start with what&apos;s available today.
          </p>

          <div className="flex flex-col gap-3">
            <Link
              href="/proverbs/1"
              className="inline-flex items-center justify-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-6 py-3.5 rounded-2xl transition-all active:scale-95 shadow-sm"
            >
              ✨ Read Proverbs 1
            </Link>
            <Link
              href="/genesis/1"
              className="inline-flex items-center justify-center gap-2 bg-white hover:bg-amber-50 text-stone-700 font-bold px-6 py-3 rounded-2xl border border-stone-200 hover:border-amber-300 transition-all"
            >
              🌍 Read Genesis 1
            </Link>
            <Link
              href="/stories"
              className="inline-flex items-center justify-center gap-2 bg-white hover:bg-stone-50 text-stone-600 font-semibold text-sm px-6 py-3 rounded-2xl border border-stone-200 transition-all"
            >
              ✨ Browse Bible Stories
            </Link>
            <Link
              href="/#library"
              className="text-amber-600 hover:text-amber-800 font-semibold text-sm transition-colors mt-1"
            >
              Browse All 66 Books →
            </Link>
          </div>

        </div>
      </main>
      <Footer />
    </div>
  );
}
