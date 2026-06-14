import { redirect } from 'next/navigation';
import { cookies } from 'next/headers';
import { verifyAdminToken, ADMIN_COOKIE } from '@/lib/admin/session';
import AdminSidebar from '@/components/admin/AdminSidebar';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: { default: 'Admin — Little Bible', template: '%s · LB Admin' },
  robots: { index: false, follow: false },
};

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const cookieStore = await cookies();
  const token = cookieStore.get(ADMIN_COOKIE)?.value;

  if (!token || !(await verifyAdminToken(token))) {
    redirect('/admin/login');
  }

  const adminEmail = process.env.ADMIN_EMAIL ?? '';
  const adminName  = adminEmail.split('@')[0] ?? 'Admin';

  return (
    <div className="flex min-h-screen bg-stone-50">
      <AdminSidebar
        name={adminName}
        email={adminEmail}
      />
      <div className="flex-1 flex flex-col min-w-0">
        {children}
      </div>
    </div>
  );
}
