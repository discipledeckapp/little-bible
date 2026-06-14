import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';

export default function TopicNotFound() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="flex-1 flex items-center justify-center px-4 py-16">
        <div className="max-w-md w-full text-center">

          <div className="text-7xl mb-5 select-none" role="img" aria-label="Topic not found">
            🏷
          </div>

          <h1 className="font-bold text-stone-800 text-2xl mb-3">
            That topic isn&apos;t available
          </h1>
          <p className="text-stone-500 text-base leading-relaxed mb-8 max-w-sm mx-auto">
            This topic may have been renamed or may not exist yet.
            Browse all our Scripture topics below.
          </p>

          <div className="flex flex-col gap-3">
            <Link
              href="/topics"
              className="inline-flex items-center justify-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-6 py-3.5 rounded-2xl transition-all active:scale-95 shadow-sm"
            >
              🏷 Browse All Topics
            </Link>
            <Link
              href="/topics/love"
              className="inline-flex items-center justify-center gap-2 bg-white hover:bg-rose-50 text-stone-700 font-bold px-6 py-3 rounded-2xl border border-stone-200 hover:border-rose-300 transition-all"
            >
              ❤️ God&apos;s Love
            </Link>
            <Link
              href="/topics/prayer"
              className="inline-flex items-center justify-center gap-2 bg-white hover:bg-purple-50 text-stone-700 font-bold px-6 py-3 rounded-2xl border border-stone-200 hover:border-purple-300 transition-all"
            >
              🙏 Prayer
            </Link>
            <Link
              href="/stories"
              className="text-amber-600 hover:text-amber-800 font-semibold text-sm transition-colors mt-1"
            >
              Browse Bible Stories →
            </Link>
          </div>

        </div>
      </main>
      <Footer />
    </div>
  );
}
