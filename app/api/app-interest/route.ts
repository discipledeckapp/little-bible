import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';

export async function GET() {
  const session = await auth();
  if (!session?.user?.id) {
    return NextResponse.json({ interest: null }, { status: 200 });
  }

  const interest = await prisma.appInterest.findUnique({
    where: { userId: session.user.id },
    select: {
      wantsIos:     true,
      wantsAndroid: true,
      wantsPush:    true,
      wantsEmail:   true,
      createdAt:    true,
      updatedAt:    true,
    },
  });

  return NextResponse.json({ interest });
}

export async function POST(req: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) {
    return NextResponse.json({ error: 'Sign in to save your preferences.' }, { status: 401 });
  }

  const body = await req.json() as {
    wantsIos?: boolean;
    wantsAndroid?: boolean;
    wantsPush?: boolean;
    wantsEmail?: boolean;
  };

  const wantsIos     = Boolean(body.wantsIos);
  const wantsAndroid = Boolean(body.wantsAndroid);
  const wantsPush    = body.wantsPush !== false;
  const wantsEmail   = body.wantsEmail !== false;

  // Derive country from Vercel/Cloudflare geo headers when available
  const countryCode =
    req.headers.get('x-vercel-ip-country') ??
    req.headers.get('cf-ipcountry') ??
    undefined;

  const interest = await prisma.appInterest.upsert({
    where:  { userId: session.user.id },
    update: { wantsIos, wantsAndroid, wantsPush, wantsEmail, ...(countryCode ? { countryCode } : {}) },
    create: { userId: session.user.id, wantsIos, wantsAndroid, wantsPush, wantsEmail, countryCode },
    select: {
      wantsIos:     true,
      wantsAndroid: true,
      wantsPush:    true,
      wantsEmail:   true,
    },
  });

  return NextResponse.json({ interest });
}

export async function DELETE() {
  const session = await auth();
  if (!session?.user?.id) {
    return NextResponse.json({ error: 'Unauthorised' }, { status: 401 });
  }

  await prisma.appInterest.deleteMany({ where: { userId: session.user.id } });
  return NextResponse.json({ ok: true });
}
