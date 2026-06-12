import Stripe from 'stripe';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2026-05-27.dahlia',
});

export async function POST(req: Request) {
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
