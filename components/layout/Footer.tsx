import Link from 'next/link';

export default function Footer() {
  return (
    <footer className="bg-amber-950 text-amber-100 pt-14 pb-10 px-4">
      <div className="max-w-4xl mx-auto">

        {/* Main footer content */}
        <div className="flex flex-col sm:flex-row items-start justify-between gap-10 mb-10">

          {/* Brand */}
          <div className="max-w-xs">
            <div className="flex items-center gap-2.5 mb-4">
              <div className="w-9 h-9 bg-amber-800 rounded-xl flex items-center justify-center text-xl select-none" aria-hidden="true">
                📖
              </div>
              <p className="font-bold text-white text-base">Little Bible</p>
            </div>
            <p className="text-amber-300/80 text-sm leading-relaxed">
              Helping every child understand, love, remember, and obey God&apos;s Word
              from their earliest years.
            </p>
            <p className="mt-4 text-amber-500 text-xs font-medium">
              Free · Open source · Faithful to Scripture
            </p>
          </div>

          {/* Links */}
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-x-12 gap-y-2">

            {/* Read */}
            <div>
              <p className="text-amber-400 text-xs font-bold uppercase tracking-widest mb-3">Read</p>
              <ul className="space-y-2">
                <li>
                  <Link href="/genesis/1" className="text-amber-200/80 hover:text-white text-sm transition-colors">
                    Genesis
                  </Link>
                </li>
                <li>
                  <Link href="/proverbs/1" className="text-amber-200/80 hover:text-white text-sm transition-colors">
                    Proverbs
                  </Link>
                </li>
                <li>
                  <a href="#library" className="text-amber-200/80 hover:text-white text-sm transition-colors">
                    All 66 Books
                  </a>
                </li>
              </ul>
            </div>

            {/* Explore */}
            <div>
              <p className="text-amber-400 text-xs font-bold uppercase tracking-widest mb-3">Explore</p>
              <ul className="space-y-2">
                <li>
                  <Link href="/stories" className="text-amber-200/80 hover:text-white text-sm transition-colors">
                    Bible Stories
                  </Link>
                </li>
                <li>
                  <Link href="/journeys" className="text-amber-200/80 hover:text-white text-sm transition-colors">
                    Start a Journey
                  </Link>
                </li>
                <li>
                  <Link href="/topics" className="text-amber-200/80 hover:text-white text-sm transition-colors">
                    Scripture Topics
                  </Link>
                </li>
              </ul>
            </div>

            {/* App + Support */}
            <div>
              <p className="text-amber-400 text-xs font-bold uppercase tracking-widest mb-3">App &amp; Support</p>
              <ul className="space-y-2">
                <li>
                  <Link href="/download" className="text-amber-200/80 hover:text-white text-sm transition-colors">
                    📱 Get the App
                  </Link>
                </li>
                <li>
                  <Link href="/donate" className="text-amber-200/80 hover:text-white text-sm transition-colors">
                    ❤️ Support Us
                  </Link>
                </li>
                <li>
                  <Link href="/family" className="text-amber-200/80 hover:text-white text-sm transition-colors">
                    👨‍👩‍👧 Family Setup
                  </Link>
                </li>
              </ul>
            </div>

          </div>
        </div>

        {/* App store chips */}
        <div className="flex items-center gap-3 flex-wrap mb-8">
          <p className="text-amber-600/70 text-xs font-semibold uppercase tracking-widest">App coming soon:</p>
          {[
            { icon: '🍎', label: 'App Store',   href: '/download' },
            { icon: '🤖', label: 'Google Play', href: '/download' },
          ].map(b => (
            <Link
              key={b.label}
              href={b.href}
              className="flex items-center gap-2 bg-white/8 hover:bg-white/14 border border-white/12 rounded-xl px-3.5 py-2 transition-colors"
            >
              <span className="text-base">{b.icon}</span>
              <span className="text-amber-200/80 text-xs font-semibold">{b.label}</span>
              <span className="text-amber-500/60 text-[10px] font-medium">Soon</span>
            </Link>
          ))}
        </div>

        {/* Divider */}
        <div className="h-px bg-amber-800/60 mb-6" aria-hidden="true" />

        {/* Scripture + copyright */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <blockquote className="text-amber-400/70 text-xs italic font-devotion max-w-sm">
            &ldquo;Train up a child in the way he should go.&rdquo; — Proverbs 22:6
          </blockquote>
          <p className="text-amber-600/60 text-xs">
            Scripture adapted from the public-domain KJV
          </p>
        </div>

      </div>
    </footer>
  );
}
