import type { AppMode } from '@/types';

const MODE_KEY = 'little_bible_mode';

export function getStoredMode(): AppMode {
  if (typeof window === 'undefined') return 'child';
  return (localStorage.getItem(MODE_KEY) as AppMode) ?? 'child';
}

export function storeMode(mode: AppMode): void {
  if (typeof window !== 'undefined') {
    localStorage.setItem(MODE_KEY, mode);
  }
}
