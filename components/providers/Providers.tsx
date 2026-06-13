'use client';

import { SessionProvider } from 'next-auth/react';
import type { Session } from 'next-auth';
import ProgressSyncProvider from './ProgressSyncProvider';
import { FamilyProvider } from '@/components/family/FamilyContext';
import FamilySetupFlow from '@/components/family/FamilySetupFlow';
import FamilySetupGate from './FamilySetupGate';

interface ProvidersProps {
  children: React.ReactNode;
  session?: Session | null;
}

export default function Providers({ children, session }: ProvidersProps) {
  return (
    <SessionProvider session={session}>
      <ProgressSyncProvider>
        <FamilyProvider>
          <FamilySetupGate />
          {children}
        </FamilyProvider>
      </ProgressSyncProvider>
    </SessionProvider>
  );
}
