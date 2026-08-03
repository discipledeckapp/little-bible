const allowedOperations = new Set(['progress', 'verse_mastery', 'unlock']);
const prohibitedKeys = /^(nickname|name|email|phone|birth(date)?|drawing|voice|text|answer|location|deviceId|advertisingId)$/i;

export interface MobileSyncEntry {
  clientId: string;
  profileId: string;
  operation: string;
  payload: Record<string, unknown>;
  createdAt: string;
}

export function parseMobileSyncEntry(value: unknown): MobileSyncEntry | null {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return null;
  const item = value as Record<string, unknown>;
  if (
    typeof item.clientId !== 'string' || item.clientId.length < 1 || item.clientId.length > 100 ||
    typeof item.profileId !== 'string' || item.profileId.length < 8 || item.profileId.length > 100 ||
    typeof item.operation !== 'string' || !allowedOperations.has(item.operation) ||
    typeof item.createdAt !== 'string' || Number.isNaN(Date.parse(item.createdAt)) ||
    !item.payload || typeof item.payload !== 'object' || Array.isArray(item.payload)
  ) return null;

  const payload = item.payload as Record<string, unknown>;
  if (containsProhibitedData(payload) || JSON.stringify(payload).length > 4096) return null;
  return item as unknown as MobileSyncEntry;
}

function containsProhibitedData(value: unknown): boolean {
  if (!value || typeof value !== 'object') return false;
  if (Array.isArray(value)) return value.some(containsProhibitedData);
  return Object.entries(value as Record<string, unknown>).some(
    ([key, child]) => prohibitedKeys.test(key) || containsProhibitedData(child),
  );
}
