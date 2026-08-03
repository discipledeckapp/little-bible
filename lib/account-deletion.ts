import { sendEmail } from './email';
import { prisma } from './prisma';

export async function permanentlyDeleteUser(userId: string): Promise<boolean> {
  const user = await prisma.user.findUnique({ where: { id: userId }, select: { email: true, name: true } });
  if (!user) return false;
  await prisma.$transaction([
    prisma.analyticsEvent.deleteMany({ where: { userId } }),
    prisma.activityRecord.deleteMany({ where: { userId } }),
    prisma.memoryVerseProgress.deleteMany({ where: { userId } }),
    prisma.adminAuditLog.deleteMany({ where: { adminId: userId } }),
    prisma.user.delete({ where: { id: userId } }),
  ]);
  if (user.email) await sendEmail({
    to: [{ email: user.email, name: user.name ?? undefined }],
    subject: 'Your Little Bible data has been deleted',
    htmlBody: '<p>Your Little Bible account and all associated data have been permanently deleted.</p>',
    textBody: 'Your Little Bible account and all associated data have been permanently deleted.',
  });
  return true;
}
