'use client';

import { useFamily } from '@/components/family/FamilyContext';
import FamilySetupFlow from '@/components/family/FamilySetupFlow';

// Renders the family setup flow overlay whenever showSetup is true.
// Lives in Providers so it can appear on any page after sign-in.
export default function FamilySetupGate() {
  const { showSetup } = useFamily();
  if (!showSetup) return null;
  return <FamilySetupFlow />;
}
