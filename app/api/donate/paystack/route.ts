import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';

export async function POST(req: Request) {
  const session = await auth();
  const { amount, email } = await req.json() as { amount: number; email?: string };

  if (!amount || amount < 10000) {
    return Response.json({ error: 'Minimum donation is ₦100' }, { status: 400 });
  }

  const donorEmail = email ?? session?.user?.email ?? 'anonymous@littlebible.app';
  const reference  = `lb_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;

  const res = await fetch('https://api.paystack.co/transaction/initialize', {
    method:  'POST',
    headers: {
      Authorization: `Bearer ${process.env.PAYSTACK_SECRET_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      email:       donorEmail,
      amount,               // in kobo (₦1 = 100 kobo)
      currency:    'NGN',
      reference,
      callback_url: `${process.env.NEXT_PUBLIC_APP_URL}/donate?success=1`,
      metadata: {
        userId:    session?.user?.id ?? null,
        app:       'little-bible',
      },
    }),
  });

  const data = await res.json() as { status: boolean; data?: { authorization_url: string } };

  if (!data.status || !data.data?.authorization_url) {
    return Response.json({ error: 'Paystack initialization failed' }, { status: 500 });
  }

  await prisma.donation.create({
    data: {
      userId:    session?.user?.id ?? null,
      amount,
      currency:  'ngn',
      provider:  'paystack',
      reference,
      status:    'pending',
    },
  });

  return Response.json({ url: data.data.authorization_url });
}
