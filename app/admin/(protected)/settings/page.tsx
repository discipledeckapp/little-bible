import type { Metadata } from 'next';
import { ROLE_LABELS, ROLE_COLORS } from '@/lib/admin/permissions';
import type { AdminRole } from '@prisma/client';

export const metadata: Metadata = { title: 'Settings' };

export default async function SettingsPage() {
  const adminEmail = process.env.ADMIN_EMAIL ?? '';
  const adminName  = adminEmail.split('@')[0] ?? 'Admin';

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
          <p className="text-stone-400 text-xs mt-0.5">Credentials-based access — managed via env vars</p>
        </div>
        <div className="px-5 py-4 flex items-center gap-4">
          <div className="w-9 h-9 rounded-full bg-amber-100 flex items-center justify-center text-amber-700 font-bold text-sm shrink-0">
            {adminName[0]?.toUpperCase() ?? 'A'}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold text-stone-800 truncate capitalize">{adminName}</p>
            <p className="text-xs text-stone-400 truncate">{adminEmail}</p>
          </div>
          <span className={`text-xs font-bold px-2.5 py-1 rounded-full shrink-0 ${ROLE_COLORS.SUPER_ADMIN}`}>
            {ROLE_LABELS.SUPER_ADMIN}
          </span>
        </div>
      </div>

      {/* Role reference */}
      <div className="bg-white rounded-2xl border border-stone-200 overflow-hidden">
        <div className="px-5 py-4 border-b border-stone-100">
          <p className="font-bold text-stone-800 text-sm">Role Permissions</p>
        </div>
        <div className="divide-y divide-stone-50">
          {allRoles.map(role => {
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

      {/* Credentials info */}
      <div className="mt-6 bg-stone-50 border border-stone-200 rounded-2xl p-5">
        <p className="text-sm font-bold text-stone-800 mb-1">Admin Credentials</p>
        <p className="text-stone-600 text-xs leading-relaxed mb-3">
          Admin access is controlled by environment variables — no user database account needed.
          Update credentials in your hosting environment (e.g., Vercel → Project → Environment Variables).
        </p>
        <code className="block bg-stone-100 text-stone-800 text-xs font-mono p-3 rounded-lg space-y-1 leading-relaxed">
          ADMIN_EMAIL=your@email.com<br />
          ADMIN_PASSWORD=your-secure-password<br />
          ADMIN_SESSION_SECRET=32-char-random-string
        </code>
      </div>
    </div>
  );
}
