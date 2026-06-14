import type { AdminRole } from '@prisma/client';

export type AdminModule =
  | 'dashboard'
  | 'users'
  | 'families'
  | 'analytics'
  | 'content'
  | 'reviews'
  | 'curriculum'
  | 'feedback'
  | 'notifications'
  | 'settings';

export const ROLE_PERMISSIONS: Record<AdminRole, AdminModule[]> = {
  SUPER_ADMIN: [
    'dashboard', 'users', 'families', 'analytics',
    'content', 'reviews', 'curriculum', 'feedback',
    'notifications', 'settings',
  ],
  CONTENT_EDITOR:        ['dashboard', 'content', 'reviews'],
  THEOLOGICAL_REVIEWER:  ['dashboard', 'reviews', 'content'],
  CURRICULUM_MANAGER:    ['dashboard', 'curriculum', 'content'],
  SUPPORT_ADMIN:         ['dashboard', 'users', 'families', 'feedback'],
  ANALYTICS_VIEWER:      ['dashboard', 'analytics'],
};

export function can(role: AdminRole | null | undefined, module: AdminModule): boolean {
  if (!role) return false;
  return ROLE_PERMISSIONS[role]?.includes(module) ?? false;
}

export function isAdmin(role: string | null | undefined): role is AdminRole {
  if (!role) return false;
  return Object.keys(ROLE_PERMISSIONS).includes(role);
}

export const ROLE_LABELS: Record<AdminRole, string> = {
  SUPER_ADMIN:           'Super Admin',
  CONTENT_EDITOR:        'Content Editor',
  THEOLOGICAL_REVIEWER:  'Theological Reviewer',
  CURRICULUM_MANAGER:    'Curriculum Manager',
  SUPPORT_ADMIN:         'Support Admin',
  ANALYTICS_VIEWER:      'Analytics Viewer',
};

export const ROLE_COLORS: Record<AdminRole, string> = {
  SUPER_ADMIN:           'bg-purple-100 text-purple-800',
  CONTENT_EDITOR:        'bg-blue-100 text-blue-800',
  THEOLOGICAL_REVIEWER:  'bg-emerald-100 text-emerald-800',
  CURRICULUM_MANAGER:    'bg-amber-100 text-amber-800',
  SUPPORT_ADMIN:         'bg-sky-100 text-sky-800',
  ANALYTICS_VIEWER:      'bg-stone-100 text-stone-700',
};
