// Helpers for the JSON-encoded TEXT columns that replaced Postgres scalar-list
// (String[]) and Json fields during the D1/SQLite migration. Use these at the
// Prisma boundary so the rest of the app keeps working with real arrays/objects.

/** Parse a JSON TEXT column into a string[] (empty array on null/invalid). */
export function parseStrArray(raw: string | null | undefined): string[] {
  if (!raw) return [];
  try {
    const v = JSON.parse(raw);
    return Array.isArray(v) ? (v as string[]) : [];
  } catch {
    return [];
  }
}

/** Parse a JSON TEXT column into an arbitrary object/value (null on invalid). */
export function parseJson<T = unknown>(raw: string | null | undefined): T | null {
  if (!raw) return null;
  try {
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

/** Encode any value for storage in a JSON TEXT column. */
export function toJson(value: unknown): string {
  return JSON.stringify(value ?? null);
}
