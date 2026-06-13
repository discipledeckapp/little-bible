'use client';

// Client wrapper — allows Header (server component) to render MemberSelector
// without importing it directly (which would pull it into the server bundle).
import dynamic from 'next/dynamic';

const MemberSelector = dynamic(
  () => import('@/components/family/MemberSelector'),
  { ssr: false }
);

export default function MemberSelectorServer() {
  return <MemberSelector />;
}
