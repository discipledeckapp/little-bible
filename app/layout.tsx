import type { Metadata } from 'next';
import { Nunito, Lora, Playfair_Display } from 'next/font/google';
import Providers from '@/components/providers/Providers';
import './globals.css';

const nunito = Nunito({
  subsets: ['latin'],
  variable: '--font-nunito',
  weight: ['400', '600', '700', '800'],
  display: 'swap',
});

const lora = Lora({
  subsets: ['latin'],
  variable: '--font-lora',
  weight: ['400', '500', '600', '700'],
  display: 'swap',
});

const playfair = Playfair_Display({
  subsets: ['latin'],
  variable: '--font-playfair',
  weight: ['600', '700'],
  display: 'swap',
});

export const metadata: Metadata = {
  metadataBase: new URL('https://littlebible.org'),
  title: "Little Bible — God's Word for Little Hearts",
  description:
    'All 66 books of Scripture — every verse faithfully adapted so children ages 4–7 can read, understand, and love God\'s Word.',
  keywords: ['Bible', 'children', 'Scripture', 'kids', 'faith', 'devotional', 'Christian'],
  icons: {
    icon: [
      { url: '/favicon.svg', type: 'image/svg+xml' },
      { url: '/icon',        type: 'image/png'     },
    ],
    apple: '/apple-icon',
  },
  openGraph: {
    title: "Little Bible — God's Word for Little Hearts",
    description:
      'All 66 books of Scripture faithfully adapted for ages 4–7. Read, discuss, pray, remember, and live God\'s Word together.',
    siteName: 'Little Bible',
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: "Little Bible — God's Word for Little Hearts",
    description: 'Every verse of Scripture faithfully adapted for children ages 4–7.',
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body
        className={`${nunito.variable} ${lora.variable} ${playfair.variable} min-h-screen font-child`}
      >
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  );
}
