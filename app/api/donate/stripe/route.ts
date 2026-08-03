import Stripe from 'stripe';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';

// Constructed per request, not at module scope. `next build` imports every
// route module during "Collecting page data", so a module-scope client throws
// "Neither apiKey nor config.authenticator provided" and fails the whole build
// wherever STRIPE_SECRET_KEY is absent — which is every CI run, since the key
// lives in .env.local and is gitignored.
function getStripe(): Stripe | null {
  const key = process.env.STRIPE_SECRET_KEY;
  if (!key) return null;
  return new Stripe(key, { apiVersion: '2026-05-27.dahlia' });
}

export async function POST(req: Request) {
  const stripe = getStripe();
  if (!stripe) {
    console.error('STRIPE_SECRET_KEY is not configured; USD donations are unavailable.');
    return Response.json(
      { error: 'Card donations are temporarily unavailable. Please try again later.' },
      { status: 503 },
    );
  }

  const session = await auth();
  const { amount, currency = 'usd' } = await req.json() as { amount: number; currency?: string };

  if (!amount || amount < 100) {
    return Response.json({ error: 'Minimum donation is $1' }, { status: 400 });
  }

  const metadata: Record<string, string> = {};
  if (session?.user?.id) metadata.userId = session.user.id;

  const checkout = await stripe.checkout.sessions.create({
    mode:        'payment',
    currency,
    line_items:  [{
      quantity: 1,
      price_data: {
        currency,
        unit_amount: amount,
        product_data: {
          name:        'Support Little Bible',
          description: 'Help bring God\'s Word to more children around the world.',
          images:      ['https://littlebible.app/og-donate.png'],
        },
      },
    }],
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/donate?success=1`,
    cancel_url:  `${process.env.NEXT_PUBLIC_APP_URL}/donate`,
    metadata,
  });

  // Record pending donation
  await prisma.donation.create({
    data: {
      userId:    session?.user?.id ?? null,
      amount,
      currency,
      provider:  'stripe',
      reference: checkout.id,
      status:    'pending',
    },
  });

  return Response.json({ url: checkout.url });
}
