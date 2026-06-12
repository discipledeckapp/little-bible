import type { Metadata } from 'next';
import { Nunito, Lora, Playfair_Display } from 'next/font/google';
import Providers from '@/components/providers/Providers';
import OnboardingFlow from '@/components/onboarding/OnboardingFlow';
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
  title: "Little Bible — God's Word for Little Hearts",
  description:
    'A child-friendly adaptation of Scripture for ages 4–7, preserving the heart of the KJV in language little ones understand.',
  keywords: ['Bible', 'children', 'Scripture', 'kids', 'Proverbs', 'faith'],
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body
        className={`${nunito.variable} ${lora.variable} ${playfair.variable} min-h-screen font-child`}
      >
        <Providers>
          <OnboardingFlow />
          {children}
        </Providers>
      </body>
    </html>
  );
}
