import type { AdminRole } from '@/lib/admin/roles';

// Governance rules for the content review workflow (US-19).
//
// These are pure functions over plain data so the rules that decide whether
// children see a package are testable without a database. The routes in
// app/api/admin/content are thin wrappers that load rows, ask these functions,
// and persist the answer.

export const REVIEW_KINDS = ['theological', 'christian_education', 'safeguarding'] as const;
export type ReviewKind = (typeof REVIEW_KINDS)[number];

export const REVIEW_KIND_LABELS: Record<ReviewKind, string> = {
  theological: 'Biblical / theological',
  christian_education: 'Children’s ministry / Christian education',
  safeguarding: 'Safeguarding',
};

/**
 * Which role may cast which review. A super admin may stand in for any of them —
 * on a small team that is unavoidable — but never for more than one on the same
 * version, and never on a version they authored. Both limits are enforced below.
 */
export const REVIEW_KIND_ROLES: Record<ReviewKind, AdminRole[]> = {
  theological: ['THEOLOGICAL_REVIEWER', 'SUPER_ADMIN'],
  christian_education: ['CURRICULUM_MANAGER', 'SUPER_ADMIN'],
  safeguarding: ['SAFEGUARDING_REVIEWER', 'SUPER_ADMIN'],
};

export type PackageStatus = 'draft' | 'in_review' | 'approved' | 'published' | 'archived';
export type VersionStatus = 'in_review' | 'approved' | 'rejected' | 'published' | 'superseded';
export type ReviewDecision = 'approved' | 'revision_requested';

export interface ApprovalRecord {
  reviewKind: ReviewKind;
  reviewerId: string;
  decision: ReviewDecision;
  comment: string;
}

export interface VersionRecord {
  id: string;
  authorId: string;
  status: VersionStatus;
  approvals: ApprovalRecord[];
}

export interface WorkflowCheck {
  allowed: boolean;
  reason?: string;
}

const ok: WorkflowCheck = { allowed: true };
const deny = (reason: string): WorkflowCheck => ({ allowed: false, reason });

export function canReviewKind(role: AdminRole | null | undefined, kind: ReviewKind): boolean {
  if (!role) return false;
  return REVIEW_KIND_ROLES[kind].includes(role);
}

/** The review kinds a role may cast, in workflow order. */
export function reviewKindsForRole(role: AdminRole | null | undefined): ReviewKind[] {
  if (!role) return [];
  return REVIEW_KINDS.filter((kind) => canReviewKind(role, kind));
}

/**
 * Whether [reviewerId] may record [kind] on [version].
 *
 * The two hard rules from the plan: no one reviews their own work, and no one
 * person supplies two of the three required approvals.
 */
export function canRecordReview(params: {
  version: VersionRecord;
  reviewerId: string;
  reviewerRole: AdminRole | null | undefined;
  kind: ReviewKind;
  comment: string;
}): WorkflowCheck {
  const { version, reviewerId, reviewerRole, kind, comment } = params;

  if (!canReviewKind(reviewerRole, kind)) {
    return deny(`Your role cannot record the ${REVIEW_KIND_LABELS[kind]} review.`);
  }
  if (version.authorId === reviewerId) {
    return deny('You authored this version — its author cannot review it.');
  }
  if (version.status === 'published') {
    return deny('This version is already published.');
  }
  if (version.status === 'superseded') {
    return deny('A newer version has replaced this one.');
  }
  if (!comment.trim()) {
    return deny('A review must carry a comment, whether approving or requesting revision.');
  }

  const otherKindBySameReviewer = version.approvals.find(
    (a) => a.reviewerId === reviewerId && a.reviewKind !== kind,
  );
  if (otherKindBySameReviewer) {
    return deny(
      `You already recorded the ${REVIEW_KIND_LABELS[otherKindBySameReviewer.reviewKind]} ` +
        'review on this version. Each of the three approvals must come from a different person.',
    );
  }

  return ok;
}

/** Review kinds still outstanding on a version. */
export function outstandingReviews(version: VersionRecord): ReviewKind[] {
  return REVIEW_KINDS.filter(
    (kind) => !version.approvals.some((a) => a.reviewKind === kind && a.decision === 'approved'),
  );
}

export function revisionRequests(version: VersionRecord): ApprovalRecord[] {
  return version.approvals.filter((a) => a.decision === 'revision_requested');
}

/**
 * Whether a version has everything it needs to go to R2/KV: three approvals, one
 * per kind, from three distinct people, none of them the author, and no
 * outstanding revision request.
 */
export function canPublish(params: {
  version: VersionRecord;
  publisherRole: AdminRole | null | undefined;
}): WorkflowCheck {
  const { version, publisherRole } = params;

  if (publisherRole !== 'SUPER_ADMIN' && publisherRole !== 'CURRICULUM_MANAGER') {
    return deny('Only a super admin or curriculum manager can publish content.');
  }
  if (version.status === 'published') {
    return deny('This version is already published.');
  }
  if (version.status === 'superseded') {
    return deny('A newer version has replaced this one.');
  }

  const pending = revisionRequests(version);
  if (pending.length > 0) {
    return deny(
      `${pending.length} reviewer(s) requested revisions. Publish a new version instead.`,
    );
  }

  const missing = outstandingReviews(version);
  if (missing.length > 0) {
    return deny(
      `Missing approval: ${missing.map((k) => REVIEW_KIND_LABELS[k]).join(', ')}.`,
    );
  }

  const approvals = version.approvals.filter((a) => a.decision === 'approved');
  if (approvals.some((a) => a.reviewerId === version.authorId)) {
    return deny('The author of a version cannot also be one of its approvers.');
  }

  const distinctReviewers = new Set(approvals.map((a) => a.reviewerId));
  if (distinctReviewers.size < REVIEW_KINDS.length) {
    return deny(
      'The three approvals must come from three different people; one reviewer supplied more than one.',
    );
  }

  return ok;
}

/** Derived version status — never stored ahead of the approvals it summarises. */
export function deriveVersionStatus(version: VersionRecord): VersionStatus {
  if (version.status === 'published' || version.status === 'superseded') return version.status;
  if (revisionRequests(version).length > 0) return 'rejected';
  if (outstandingReviews(version).length === 0) return 'approved';
  return 'in_review';
}

// ─── Package form requirements (US-19 first acceptance criterion) ────────────

export const GENRES = ['narrative', 'wisdom', 'lament', 'teaching', 'parable', 'poetry'] as const;
export type Genre = (typeof GENRES)[number];

export const SENSITIVITY_TIERS = ['general', 'guided', 'parental_presence'] as const;
export type SensitivityTier = (typeof SENSITIVITY_TIERS)[number];

export const AGE_BANDS = ['early', 'emerging', 'independent'] as const;

/** The beats each genre's template requires, from the delivery plan. */
export const GENRE_BEATS: Record<Genre, string[]> = {
  narrative: ['setting', 'tension', 'divine or human response', 'meaning'],
  wisdom: ['question', 'insight', 'example', 'practice'],
  lament: ['pain', 'honest prayer', 'remembrance', 'hope without forced resolution'],
  teaching: ['historical context', 'core truth', 'example', 'reflection'],
  parable: ['setting', 'surprise or reversal', 'meaning', 'open reflection'],
  poetry: ['image', 'context', 'theological claim', 'wonder, lament or hope'],
};

export interface PackageDraft {
  id?: string;
  title?: string;
  genre?: string;
  sensitivityTier?: string;
  ageBand?: string;
  learningObjective?: string;
  originalContext?: string;
  canonicalConnection?: string;
  verseContext?: string;
}

export interface FieldError {
  field: string;
  message: string;
}

/**
 * The gating fields the form demands *before* it will show the genre beats.
 * A package that cannot answer these is not ready to be written.
 */
export function validatePackageDraft(draft: PackageDraft): FieldError[] {
  const errors: FieldError[] = [];
  const required: Array<[keyof PackageDraft, string]> = [
    ['id', 'Story id'],
    ['title', 'Title'],
    ['learningObjective', 'Learning objective'],
    ['originalContext', 'Original context'],
    ['canonicalConnection', 'Whole-Bible connection'],
    ['verseContext', 'Key verse context'],
  ];

  for (const [field, label] of required) {
    if (!draft[field]?.toString().trim()) {
      errors.push({ field, message: `${label} is required.` });
    }
  }

  if (draft.id && !/^[a-z0-9]+(-[a-z0-9]+)*$/.test(draft.id)) {
    errors.push({ field: 'id', message: 'Story id must be lower-case kebab-case.' });
  }
  if (!draft.genre || !(GENRES as readonly string[]).includes(draft.genre)) {
    errors.push({ field: 'genre', message: 'Select a biblical genre.' });
  }
  if (
    !draft.sensitivityTier ||
    !(SENSITIVITY_TIERS as readonly string[]).includes(draft.sensitivityTier)
  ) {
    errors.push({ field: 'sensitivityTier', message: 'Select a sensitivity tier.' });
  }
  if (draft.ageBand && !(AGE_BANDS as readonly string[]).includes(draft.ageBand)) {
    errors.push({ field: 'ageBand', message: 'Select a valid age band.' });
  }

  return errors;
}
