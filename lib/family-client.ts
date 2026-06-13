'use client';

import type { FamilyData, FamilyMember } from '@/types/family';

const ACTIVE_MEMBER_KEY = 'little_bible_active_member';

export function getActiveMemberId(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(ACTIVE_MEMBER_KEY);
}

export function setActiveMemberId(id: string | null): void {
  if (typeof window === 'undefined') return;
  if (id) localStorage.setItem(ACTIVE_MEMBER_KEY, id);
  else localStorage.removeItem(ACTIVE_MEMBER_KEY);
}

export async function fetchFamily(): Promise<FamilyData | null> {
  const res = await fetch('/api/family', { cache: 'no-store' });
  if (!res.ok || res.status === 404) return null;
  return res.json();
}

export async function createFamily(name: string | null): Promise<FamilyData> {
  const res = await fetch('/api/family', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name }),
  });
  if (!res.ok) throw new Error('Failed to create family');
  return res.json();
}

export async function updateFamily(data: { name?: string | null; journeyId?: string | null }): Promise<FamilyData> {
  const res = await fetch('/api/family', {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  if (!res.ok) throw new Error('Failed to update family');
  return res.json();
}

export async function addMember(data: {
  name: string;
  age?: number | null;
  avatarId?: string;
  accentColor?: string | null;
  faithGoals?: string[];
}): Promise<FamilyMember> {
  const res = await fetch('/api/family/members', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  if (!res.ok) throw new Error('Failed to add member');
  return res.json();
}

export async function updateMember(id: string, data: Partial<FamilyMember>): Promise<FamilyMember> {
  const res = await fetch(`/api/family/members/${id}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  if (!res.ok) throw new Error('Failed to update member');
  return res.json();
}

export async function deleteMember(id: string): Promise<void> {
  const res = await fetch(`/api/family/members/${id}`, { method: 'DELETE' });
  if (!res.ok) throw new Error('Failed to delete member');
}

export function recordMemberProgress(data: {
  memberId: string;
  bookSlug: string;
  chapter: number;
  verse: number;
  mode: string;
  type: 'verse' | 'chapter' | 'session';
}): void {
  // Fire and forget — don't await, don't block reading
  fetch('/api/family/progress', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  }).catch(() => {});
}
