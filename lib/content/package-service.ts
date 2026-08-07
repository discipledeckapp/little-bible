import { prisma } from '@/lib/prisma';
import { contentHash, publishContent, type ContentKind } from '@/lib/content-delivery';
import {
  canPublish,
  deriveVersionStatus,
  type VersionRecord,
  type ReviewKind,
} from './review-workflow';
import type { AdminRole } from '@/lib/admin/roles';

// Database side of the content review workflow (US-19). The rules themselves live
// in review-workflow.ts; this module only loads rows, asks those rules, and
// persists the answer — including the audit trail every decision leaves behind.

export interface LoadedVersion extends VersionRecord {
  packageId: string;
  versionNumber: number;
  body: string;
  contentHash: string;
  changeNote: string | null;
  createdAt: Date;
  publishedAt: Date | null;
  r2Key: string | null;
}

function toVersionRecord(row: {
  id: string;
  authorId: string;
  status: string;
  approvals: { reviewKind: string; reviewerId: string; decision: string; comment: string }[];
}): VersionRecord {
  return {
    id: row.id,
    authorId: row.authorId,
    status: row.status as VersionRecord['status'],
    approvals: row.approvals.map((a) => ({
      reviewKind: a.reviewKind as ReviewKind,
      reviewerId: a.reviewerId,
      decision: a.decision as 'approved' | 'revision_requested',
      comment: a.comment,
    })),
  };
}

export async function loadVersion(versionId: string) {
  const row = await prisma.contentVersion.findUnique({
    where: { id: versionId },
    include: {
      approvals: true,
      package: true,
      author: { select: { id: true, name: true, email: true } },
    },
  });
  if (!row) return null;
  return { row, record: toVersionRecord(row) };
}

async function audit(adminId: string, action: string, targetId: string, details: object) {
  await prisma.adminAuditLog.create({
    data: { adminId, action, targetId, details: JSON.stringify(details) },
  });
}

/**
 * Adds a new version to a package. Content is never edited in place: the previous
 * unpublished version is marked superseded so it can no longer collect approvals,
 * while published versions stay untouched as rollback targets.
 */
export async function createVersion(params: {
  packageId: string;
  body: string;
  authorId: string;
  changeNote?: string;
}) {
  const { packageId, body, authorId, changeNote } = params;

  const latest = await prisma.contentVersion.findFirst({
    where: { packageId },
    orderBy: { versionNumber: 'desc' },
    select: { id: true, versionNumber: true, status: true },
  });

  if (latest && latest.status !== 'published') {
    await prisma.contentVersion.update({
      where: { id: latest.id },
      data: { status: 'superseded' },
    });
  }

  const version = await prisma.contentVersion.create({
    data: {
      packageId,
      versionNumber: (latest?.versionNumber ?? 0) + 1,
      body,
      contentHash: await contentHash(body),
      changeNote: changeNote ?? null,
      authorId,
      status: 'in_review',
    },
  });

  await prisma.contentPackage.update({
    where: { id: packageId },
    data: { status: 'in_review' },
  });

  await audit(authorId, 'content.version.created', version.id, {
    packageId,
    versionNumber: version.versionNumber,
  });

  return version;
}

/** Records one reviewer's decision and recomputes the version's derived status. */
export async function recordReview(params: {
  versionId: string;
  reviewKind: ReviewKind;
  reviewerId: string;
  decision: 'approved' | 'revision_requested';
  comment: string;
}) {
  const { versionId, reviewKind, reviewerId, decision, comment } = params;

  await prisma.contentApproval.upsert({
    where: { versionId_reviewKind: { versionId, reviewKind } },
    create: { versionId, reviewKind, reviewerId, decision, comment },
    update: { reviewerId, decision, comment, createdAt: new Date() },
  });

  const loaded = await loadVersion(versionId);
  if (!loaded) throw new Error('version disappeared mid-review');

  const status = deriveVersionStatus(loaded.record);
  await prisma.contentVersion.update({ where: { id: versionId }, data: { status } });
  await prisma.contentPackage.update({
    where: { id: loaded.row.packageId },
    data: { status: status === 'approved' ? 'approved' : 'in_review' },
  });

  await audit(reviewerId, 'content.review.recorded', versionId, {
    reviewKind,
    decision,
    resultingStatus: status,
  });

  return { status };
}

/**
 * Publishes an approved version to R2 + KV, then records the result.
 *
 * The governance check runs first and the D1 write runs last, so a failed R2/KV
 * publish leaves the version approved-but-unpublished rather than claiming a
 * publication that never reached a client.
 */
export async function publishVersion(params: {
  versionId: string;
  publisherId: string;
  publisherRole: AdminRole;
}) {
  const { versionId, publisherId, publisherRole } = params;

  const loaded = await loadVersion(versionId);
  if (!loaded) return { ok: false as const, reason: 'Version not found.' };

  const check = canPublish({ version: loaded.record, publisherRole });
  if (!check.allowed) return { ok: false as const, reason: check.reason! };

  const kind = (loaded.row.package.kind ?? 'stories') as ContentKind;
  const published = await publishContent(kind, loaded.row.packageId, loaded.row.body);

  await prisma.contentVersion.update({
    where: { id: versionId },
    data: { status: 'published', publishedAt: new Date(), r2Key: published.key },
  });
  await prisma.contentVersion.updateMany({
    where: { packageId: loaded.row.packageId, id: { not: versionId }, status: 'published' },
    data: { status: 'superseded' },
  });
  await prisma.contentPackage.update({
    where: { id: loaded.row.packageId },
    data: { status: 'published', publishedVersionId: versionId },
  });

  await audit(publisherId, 'content.version.published', versionId, {
    packageId: loaded.row.packageId,
    r2Key: published.key,
    supersededKey: published.supersededKey,
  });

  return { ok: true as const, published };
}

/**
 * Rolls a package back to an earlier version's exact bytes.
 *
 * The target must itself have been published — a rollback restores a state that
 * already carried its three approvals, so it never routes unreviewed content to
 * children.
 */
export async function rollbackToVersion(params: {
  versionId: string;
  publisherId: string;
  publisherRole: AdminRole;
}) {
  const { versionId, publisherId, publisherRole } = params;

  if (publisherRole !== 'SUPER_ADMIN' && publisherRole !== 'CURRICULUM_MANAGER') {
    return { ok: false as const, reason: 'Only a super admin or curriculum manager can roll back.' };
  }

  const loaded = await loadVersion(versionId);
  if (!loaded) return { ok: false as const, reason: 'Version not found.' };
  if (!loaded.row.publishedAt) {
    return {
      ok: false as const,
      reason: 'Only a version that was previously published can be rolled back to.',
    };
  }

  const kind = (loaded.row.package.kind ?? 'stories') as ContentKind;
  const published = await publishContent(kind, loaded.row.packageId, loaded.row.body);

  await prisma.contentVersion.updateMany({
    where: { packageId: loaded.row.packageId, status: 'published' },
    data: { status: 'superseded' },
  });
  await prisma.contentVersion.update({
    where: { id: versionId },
    data: { status: 'published', publishedAt: new Date(), r2Key: published.key },
  });
  await prisma.contentPackage.update({
    where: { id: loaded.row.packageId },
    data: { status: 'published', publishedVersionId: versionId },
  });

  await audit(publisherId, 'content.version.rolledback', versionId, {
    packageId: loaded.row.packageId,
    r2Key: published.key,
  });

  return { ok: true as const, published };
}

/** Everyone who should be told a package has entered review. */
export async function reviewerRecipients(): Promise<string[]> {
  const reviewers = await prisma.user.findMany({
    where: {
      role: { in: ['THEOLOGICAL_REVIEWER', 'CURRICULUM_MANAGER', 'SAFEGUARDING_REVIEWER'] },
      email: { not: null },
    },
    select: { email: true },
  });
  return reviewers.map((r) => r.email!).filter(Boolean);
}
