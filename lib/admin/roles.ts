// SQLite/D1 has no native enums, so the former Prisma `AdminRole` enum is now a
// plain String column. This module is the single source of truth for the allowed
// role values and their string-literal union type across the app.

export const ADMIN_ROLES = [
  'SUPER_ADMIN',
  'CONTENT_EDITOR',
  'THEOLOGICAL_REVIEWER',
  'CURRICULUM_MANAGER',
  // The delivery plan requires a safeguarding sign-off distinct from the
  // theological and Christian-education ones before any package is published.
  'SAFEGUARDING_REVIEWER',
  'SUPPORT_ADMIN',
  'ANALYTICS_VIEWER',
] as const;

export type AdminRole = (typeof ADMIN_ROLES)[number];

export function isAdminRole(value: string | null | undefined): value is AdminRole {
  return !!value && (ADMIN_ROLES as readonly string[]).includes(value);
}
