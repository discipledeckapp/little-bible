import type { Metadata } from 'next';
import { auth } from '@/auth';
import { prisma } from '@/lib/prisma';
import { can } from '@/lib/admin/permissions';
import { ROLE_LABELS, ROLE_COLORS } from '@/lib/admin/permissions';
import type { AdminRole } from '@prisma/client';

export const metadata: Metadata = { title: 'Settings' };

export default async function SettingsPage() {
  const session = await auth();
  if (!session?.user?.role || !can(session.user.role as AdminRole, 'settings')) {
    return (
      <div className="p-8 max-w-3xl mx-auto">
        <div className="bg-red-50 border border-red-200 rounded-2xl p-6 text-center">
          <p className="text-red-700 font-semibold">Access Denied</p>
          <p className="text-red-500 text-sm mt-1">Only Super Admins can access Settings.</p>
        </div>
      </div>
    );
  }

  const admins = await prisma.user.findMany({
    where: { role: { not: null } },
    orderBy: { createdAt: 'asc' },
    select: { id: true, name: true, email: true, image: true, role: true, createdAt: true },
  });

  const allRoles = Object.keys(ROLE_LABELS) as AdminRole[];

  return (
    <div className="p-8 max-w-3xl mx-auto w-full">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-stone-900">Settings</h1>
        <p className="text-stone-500 text-sm mt-0.5">Admin roles and access control</p>
      </div>

      {/* Admin team */}
      <div className="bg-white rounded-2xl border border-stone-200 overflow-hidden mb-6">
        <div className="px-5 py-4 border-b border-stone-100">
          <p className="font-bold text-stone-800 text-sm">Admin Team</p>
          <p className="text-stone-400 text-xs mt-0.5">{admins.length} users with admin access</p>
        </div>
        <div className="divide-y divide-stone-50">
          {admins.map(admin => (
            <div key={admin.id} className="flex items-center gap-4 px-5 py-4">
              {admin.image ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={admin.image} alt="" className="w-9 h-9 rounded-full shrink-0" />
              ) : (
                <div className="w-9 h-9 rounded-full bg-stone-100 flex items-center justify-center text-stone-500 font-bold text-sm shrink-0">
                  {(admin.name ?? admin.email ?? 'A')[0].toUpperCase()}
                </div>
              )}
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-stone-800 truncate">{admin.name ?? '—'}</p>
                <p className="text-xs text-stone-400 truncate">{admin.email}</p>
              </div>
              {admin.role && (
                <span className={`text-xs font-bold px-2.5 py-1 rounded-full shrink-0 ${ROLE_COLORS[admin.role as AdminRole]}`}>
                  {ROLE_LABELS[admin.role as AdminRole]}
                </span>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Role reference */}
      <div className="bg-white rounded-2xl border border-stone-200 overflow-hidden">
        <div className="px-5 py-4 border-b border-stone-100">
          <p className="font-bold text-stone-800 text-sm">Role Permissions</p>
        </div>
        <div className="divide-y divide-stone-50">
          {allRoles.map(role => {
            const { can: canRole } = { can: (m: AdminRole) => ROLE_LABELS[m] };
            return (
              <div key={role} className="px-5 py-4">
                <div className="flex items-center gap-3 mb-2">
                  <span className={`text-xs font-bold px-2.5 py-1 rounded-full ${ROLE_COLORS[role]}`}>
                    {ROLE_LABELS[role]}
                  </span>
                </div>
                <p className="text-xs text-stone-400">
                  {role === 'SUPER_ADMIN'           && 'Full access to all modules'}
                  {role === 'CONTENT_EDITOR'        && 'Content management and review queue'}
                  {role === 'THEOLOGICAL_REVIEWER'  && 'Review queue and content reading'}
                  {role === 'CURRICULUM_MANAGER'    && 'Journey and curriculum management'}
                  {role === 'SUPPORT_ADMIN'         && 'User and family management, feedback'}
                  {role === 'ANALYTICS_VIEWER'      && 'Dashboard and analytics read-only'}
                </p>
              </div>
            );
          })}
        </div>
      </div>

      {/* How to assign roles */}
      <div className="mt-6 bg-amber-50 border border-amber-100 rounded-2xl p-5">
        <p className="text-sm font-bold text-amber-800 mb-1">Assigning Admin Roles</p>
        <p className="text-amber-700 text-xs leading-relaxed">
          Use the <strong>Users</strong> page to find a user, then use the API or Prisma Studio to set their role.
          A role management UI is planned for the next admin release.
        </p>
        <code className="block mt-3 bg-amber-100 text-amber-900 text-xs font-mono p-3 rounded-lg">
          PATCH /api/admin/users<br />
          {'{ "userId": "...", "role": "CONTENT_EDITOR" }'}
        </code>
      </div>
    </div>
  );
}
