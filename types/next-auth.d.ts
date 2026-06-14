import type { DefaultSession } from 'next-auth';
import type { AdminRole } from '@prisma/client';

declare module 'next-auth' {
  interface Session {
    user: {
      id:   string;
      role: AdminRole | null;
    } & DefaultSession['user'];
  }
}
