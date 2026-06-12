'use client';

import { useEffect, useRef } from 'react';
import { useSession } from 'next-auth/react';
import { downloadAndMergeProgress, uploadProgress } from '@/lib/sync';

const UPLOAD_INTERVAL_MS = 30_000; // upload every 30s while signed in

export default function ProgressSyncProvider({ children }: { children: React.ReactNode }) {
  const { data: session, status } = useSession();
  const hasDownloaded = useRef(false);

  // On sign-in: download cloud → merge into localStorage
  useEffect(() => {
    if (status !== 'authenticated' || hasDownloaded.current) return;
    hasDownloaded.current = true;
    downloadAndMergeProgress();
  }, [status]);

  // While signed in: upload localStorage → cloud every 30s
  useEffect(() => {
    if (!session?.user) return;

    const id = setInterval(uploadProgress, UPLOAD_INTERVAL_MS);
    return () => clearInterval(id);
  }, [session?.user]);

  // On sign-out: reset downloaded flag so next sign-in re-downloads
  useEffect(() => {
    if (status === 'unauthenticated') hasDownloaded.current = false;
  }, [status]);

  return <>{children}</>;
}
