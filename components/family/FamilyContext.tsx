'use client';

import { createContext, useContext, useState, useEffect, useCallback, useRef } from 'react';
import { useSession } from 'next-auth/react';
import type { FamilyData, FamilyMember } from '@/types/family';
import { fetchFamily, getActiveMemberId, setActiveMemberId } from '@/lib/family-client';

interface FamilyContextValue {
  family: FamilyData | null;
  loading: boolean;
  activeMember: FamilyMember | null;
  activeMemberId: string | null;
  totalSeeds: number;
  setActiveMemberId: (id: string | null) => void;
  mutate: () => Promise<void>;
  showSetup: boolean;
  setShowSetup: (v: boolean) => void;
}

const FamilyContext = createContext<FamilyContextValue>({
  family: null,
  loading: true,
  activeMember: null,
  activeMemberId: null,
  totalSeeds: 0,
  setActiveMemberId: () => {},
  mutate: async () => {},
  showSetup: false,
  setShowSetup: () => {},
});

export function FamilyProvider({ children }: { children: React.ReactNode }) {
  const { status } = useSession();
  const [family, setFamily]           = useState<FamilyData | null>(null);
  const [loading, setLoading]         = useState(false);
  const [activeMemberIdState, setActiveMemberIdState] = useState<string | null>(null);
  const [showSetup, setShowSetup]     = useState(false);
  const fetchedRef                    = useRef(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await fetchFamily();
      setFamily(data);
      // If signed in but no family → show setup flow
      if (data === null && status === 'authenticated') {
        setShowSetup(true);
      }
    } catch {
      // network error — silently ignore
    } finally {
      setLoading(false);
    }
  }, [status]);

  // Load on sign-in
  useEffect(() => {
    if (status === 'authenticated' && !fetchedRef.current) {
      fetchedRef.current = true;
      load();
    }
    if (status === 'unauthenticated') {
      setFamily(null);
      setLoading(false);
      fetchedRef.current = false;
    }
  }, [status, load]);

  // Restore active member from localStorage
  useEffect(() => {
    setActiveMemberIdState(getActiveMemberId());
  }, []);

  // When family loads, validate stored memberId still exists
  useEffect(() => {
    if (!family) return;
    const stored = getActiveMemberId();
    if (stored && family.members.some((m) => m.id === stored)) {
      setActiveMemberIdState(stored);
    } else if (family.members.length > 0) {
      // Default to first member
      setActiveMemberIdState(family.members[0].id);
      setActiveMemberId(family.members[0].id);
    }
  }, [family]);

  const handleSetActiveMember = useCallback((id: string | null) => {
    setActiveMemberId(id);
    setActiveMemberIdState(id);
  }, []);

  const activeMember = family?.members.find((m) => m.id === activeMemberIdState) ?? null;
  const totalSeeds   = family?.members.reduce((s, m) => s + m.seeds, 0) ?? 0;

  return (
    <FamilyContext.Provider
      value={{
        family,
        loading,
        activeMember,
        activeMemberId: activeMemberIdState,
        totalSeeds,
        setActiveMemberId: handleSetActiveMember,
        mutate: load,
        showSetup,
        setShowSetup,
      }}
    >
      {children}
    </FamilyContext.Provider>
  );
}

export function useFamily() {
  return useContext(FamilyContext);
}
