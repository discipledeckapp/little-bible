import { prisma } from '@/lib/prisma';

export async function GET() {
  try {
    const count = await prisma.user.count();
    const first = await prisma.user.findFirst({ select: { id: true, email: true, createdAt: true } });
    return Response.json({ ok: true, userCount: count, sample: first });
  } catch (e: unknown) {
    const err = e as Error;
    return Response.json({ ok: false, error: err.message, stack: err.stack?.slice(0, 600) }, { status: 500 });
  }
}
