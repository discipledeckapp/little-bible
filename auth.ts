import NextAuth from 'next-auth';
import Google from 'next-auth/providers/google';
import { PrismaAdapter } from '@auth/prisma-adapter';
import { prisma } from '@/lib/prisma';
import { sendEmail, welcomeEmailHtml } from '@/lib/email';

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: PrismaAdapter(prisma),
  providers: [
    Google({
      clientId:     process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
  ],
  callbacks: {
    session({ session, user }) {
      if (user) {
        session.user.id   = user.id;
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        session.user.role = (user as any).role ?? null;
      }
      return session;
    },
  },
  events: {
    async createUser({ user }) {
      if (!user.email) return;
      await sendEmail({
        to:       [{ email: user.email, name: user.name ?? undefined }],
        subject:  'Welcome to Little Bible 🌱',
        htmlBody: welcomeEmailHtml(user.name ?? ''),
        textBody: `Hi ${user.name ?? 'Friend'},\n\nWelcome to Little Bible! Start your first family devotion at https://littlebible.org/proverbs/1\n\nGod's Word for Little Hearts\nlittlebible.org`,
      });
    },
  },
  pages: {
    signIn: '/',
    error:  '/',
  },
});
