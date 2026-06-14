import { redirect } from 'next/navigation';
import { auth } from '@/auth';
import { isAdmin } from '@/lib/admin/permissions';
import type { AdminRole } from '@prisma/client';
import AdminSidebar from '@/components/admin/AdminSidebar';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: { default: 'Admin — Little Bible', template: '%s · LB Admin' },
  robots: { index: false, follow: false },
};

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const session = await auth();

  if (!session?.user?.id || !isAdmin(session.user.role)) {
    redirect('/');
  }

  return (
    <div className="flex min-h-screen bg-stone-50">
      <AdminSidebar
        role={session.user.role as AdminRole}
        name={session.user.name ?? null}
        email={session.user.email ?? null}
        image={session.user.image ?? null}
      />
      <div className="flex-1 flex flex-col min-w-0">
        {children}
      </div>
    </div>
  );
}
