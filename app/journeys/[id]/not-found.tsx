import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';

export default function JourneyNotFound() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="flex-1 flex items-center justify-center px-4 py-16">
        <div className="max-w-md w-full text-center">

          <div className="text-7xl mb-5 select-none" role="img" aria-label="Journey not found">
            🌿
          </div>

          <h1 className="font-bold text-stone-800 text-2xl mb-3">
            That journey doesn&apos;t exist
          </h1>
          <p className="text-stone-500 text-base leading-relaxed mb-8 max-w-sm mx-auto">
            We currently have three guided reading journeys. Choose one below to start
            exploring Scripture with your child.
          </p>

          <div className="flex flex-col gap-3">
            <Link
              href="/journeys/god-loves-me"
              className="inline-flex items-center justify-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-extrabold px-6 py-3.5 rounded-2xl transition-all active:scale-95 shadow-sm"
            >
              🌱 God Loves Me (Ages 4–5)
            </Link>
            <Link
              href="/journeys/follow-jesus"
              className="inline-flex items-center justify-center gap-2 bg-white hover:bg-emerald-50 text-stone-700 font-bold px-6 py-3 rounded-2xl border border-stone-200 hover:border-emerald-300 transition-all"
            >
              ✝️ Follow Jesus (Ages 6–7)
            </Link>
            <Link
              href="/journeys/wisdom-path"
              className="inline-flex items-center justify-center gap-2 bg-white hover:bg-sky-50 text-stone-700 font-bold px-6 py-3 rounded-2xl border border-stone-200 hover:border-sky-300 transition-all"
            >
              ✨ Wisdom Path (Ages 6–7)
            </Link>
            <Link
              href="/journeys"
              className="text-amber-600 hover:text-amber-800 font-semibold text-sm transition-colors mt-1"
            >
              See All Journeys →
            </Link>
          </div>

        </div>
      </main>
      <Footer />
    </div>
  );
}
