'use client';

import dynamic from 'next/dynamic';

// Lazy-load the full dashboard — avoids SSR issues with session/context.
// Only renders when the user has a family (FamilyDashboard handles its own auth check).
const FamilyDashboard = dynamic(
  () => import('@/components/family/FamilyDashboard'),
  { ssr: false, loading: () => null }
);

export default function FamilyDashboardSection() {
  return (
    <section className="bg-[#FFFBF5] border-b border-amber-50">
      <FamilyDashboard />
    </section>
  );
}
