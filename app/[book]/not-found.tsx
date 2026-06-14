import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';

export default function BookNotFound() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="flex-1 flex items-center justify-center px-4 py-16">
        <div className="max-w-md w-full text-center">

          <div className="text-7xl mb-5 select-none" role="img" aria-label="Book not found">
            📚
          </div>

          <h1 className="font-bold text-stone-800 text-2xl mb-3">
            That book isn&apos;t in our catalog
          </h1>
          <p className="text-stone-500 text-base leading-relaxed mb-8 max-w-sm mx-auto">
            We cover all 66 books of Scripture, though many are still being prepared.
            Try one of the books below.
          </p>

          <div className="flex flex-col gap-3">
            <Link
              href="/proverbs/1"
              className="inline-flex items-center justify-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-6 py-3.5 rounded-2xl transition-all active:scale-95 shadow-sm"
            >
              ✨ Start with Proverbs
            </Link>
            <Link
              href="/genesis/1"
              className="inline-flex items-center justify-center gap-2 bg-white hover:bg-amber-50 text-stone-700 font-bold px-6 py-3 rounded-2xl border border-stone-200 hover:border-amber-300 transition-all"
            >
              🌍 Open Genesis
            </Link>
            <Link
              href="/#library"
              className="inline-flex items-center justify-center gap-2 text-amber-600 hover:text-amber-800 font-semibold text-sm transition-colors mt-1"
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
