'use client';

import { SessionProvider } from 'next-auth/react';
import type { Session } from 'next-auth';
import ProgressSyncProvider from './ProgressSyncProvider';

interface ProvidersProps {
  children: React.ReactNode;
  session?: Session | null;
}

export default function Providers({ children, session }: ProvidersProps) {
  return (
    <SessionProvider session={session}>
      <ProgressSyncProvider>
        {children}
      </ProgressSyncProvider>
    </SessionProvider>
  );
}
