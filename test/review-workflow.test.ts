import { describe, expect, it } from 'vitest';
import {
  canRecordReview,
  canPublish,
  outstandingReviews,
  deriveVersionStatus,
  reviewKindsForRole,
  validatePackageDraft,
  REVIEW_KINDS,
  type ApprovalRecord,
  type VersionRecord,
  type ReviewKind,
} from '@/lib/content/review-workflow';

const AUTHOR = 'user-author';

const approval = (
  kind: ReviewKind,
  reviewerId: string,
  decision: ApprovalRecord['decision'] = 'approved',
): ApprovalRecord => ({ reviewKind: kind, reviewerId, decision, comment: 'Looks right.' });

const version = (over: Partial<VersionRecord> = {}): VersionRecord => ({
  id: 'v1',
  authorId: AUTHOR,
  status: 'in_review',
  approvals: [],
  ...over,
});

/** A version with all three approvals from three different non-author reviewers. */
const fullyApproved = () =>
  version({
    approvals: [
      approval('theological', 'user-theo'),
      approval('christian_education', 'user-edu'),
      approval('safeguarding', 'user-safe'),
    ],
  });

describe('reviewKindsForRole', () => {
  it('maps each reviewer role to exactly its own review kind', () => {
    expect(reviewKindsForRole('THEOLOGICAL_REVIEWER')).toEqual(['theological']);
    expect(reviewKindsForRole('CURRICULUM_MANAGER')).toEqual(['christian_education']);
    expect(reviewKindsForRole('SAFEGUARDING_REVIEWER')).toEqual(['safeguarding']);
  });

  it('lets a super admin stand in for any kind', () => {
    expect(reviewKindsForRole('SUPER_ADMIN')).toEqual([...REVIEW_KINDS]);
  });

  it('gives a content editor no review authority at all', () => {
    expect(reviewKindsForRole('CONTENT_EDITOR')).toEqual([]);
    expect(reviewKindsForRole(null)).toEqual([]);
  });
});

describe('canRecordReview', () => {
  const base = {
    reviewerId: 'user-theo',
    reviewerRole: 'THEOLOGICAL_REVIEWER' as const,
    kind: 'theological' as ReviewKind,
    comment: 'Doctrinally sound.',
  };

  it('allows a qualified reviewer who is not the author', () => {
    expect(canRecordReview({ ...base, version: version() }).allowed).toBe(true);
  });

  it('refuses the author reviewing their own version', () => {
    const check = canRecordReview({ ...base, reviewerId: AUTHOR, version: version() });
    expect(check.allowed).toBe(false);
    expect(check.reason).toContain('cannot review it');
  });

  it('refuses the author even when they hold the reviewer role', () => {
    const check = canRecordReview({
      ...base,
      reviewerId: AUTHOR,
      reviewerRole: 'SUPER_ADMIN',
      version: version(),
    });
    expect(check.allowed).toBe(false);
  });

  it('refuses a role that does not own that review kind', () => {
    const check = canRecordReview({
      ...base,
      kind: 'safeguarding',
      version: version(),
    });
    expect(check.allowed).toBe(false);
    expect(check.reason).toContain('Safeguarding');
  });

  it('refuses a review with no comment, in either direction', () => {
    expect(canRecordReview({ ...base, comment: '   ', version: version() }).allowed).toBe(false);
  });

  it('refuses one person supplying a second review kind on the same version', () => {
    const check = canRecordReview({
      ...base,
      reviewerId: 'user-super',
      reviewerRole: 'SUPER_ADMIN',
      kind: 'safeguarding',
      version: version({ approvals: [approval('theological', 'user-super')] }),
    });
    expect(check.allowed).toBe(false);
    expect(check.reason).toContain('different person');
  });

  it('allows re-recording the same kind by the same reviewer (a changed mind)', () => {
    const check = canRecordReview({
      ...base,
      version: version({
        approvals: [approval('theological', 'user-theo', 'revision_requested')],
      }),
    });
    expect(check.allowed).toBe(true);
  });

  it('refuses review of a published or superseded version', () => {
    expect(canRecordReview({ ...base, version: version({ status: 'published' }) }).allowed).toBe(false);
    expect(canRecordReview({ ...base, version: version({ status: 'superseded' }) }).allowed).toBe(false);
  });
});

describe('outstandingReviews', () => {
  it('lists all three on a fresh version', () => {
    expect(outstandingReviews(version())).toEqual([...REVIEW_KINDS]);
  });

  it('does not count a revision request as satisfying its kind', () => {
    const v = version({ approvals: [approval('theological', 'user-theo', 'revision_requested')] });
    expect(outstandingReviews(v)).toContain('theological');
  });

  it('is empty once every kind is approved', () => {
    expect(outstandingReviews(fullyApproved())).toEqual([]);
  });
});

describe('canPublish', () => {
  it('allows a fully approved version', () => {
    expect(canPublish({ version: fullyApproved(), publisherRole: 'SUPER_ADMIN' }).allowed).toBe(true);
  });

  it('refuses when an approval is missing', () => {
    const v = version({ approvals: [approval('theological', 'user-theo')] });
    const check = canPublish({ version: v, publisherRole: 'SUPER_ADMIN' });
    expect(check.allowed).toBe(false);
    expect(check.reason).toContain('Missing approval');
  });

  it('refuses while any reviewer has requested revisions', () => {
    const v = version({
      approvals: [
        approval('theological', 'user-theo'),
        approval('christian_education', 'user-edu'),
        approval('safeguarding', 'user-safe', 'revision_requested'),
      ],
    });
    const check = canPublish({ version: v, publisherRole: 'SUPER_ADMIN' });
    expect(check.allowed).toBe(false);
    expect(check.reason).toContain('requested revisions');
  });

  it('refuses when the author is among the approvers', () => {
    const v = version({
      approvals: [
        approval('theological', AUTHOR),
        approval('christian_education', 'user-edu'),
        approval('safeguarding', 'user-safe'),
      ],
    });
    const check = canPublish({ version: v, publisherRole: 'SUPER_ADMIN' });
    expect(check.allowed).toBe(false);
    expect(check.reason).toContain('cannot also be one of its approvers');
  });

  it('refuses when one person supplied two of the three approvals', () => {
    const v = version({
      approvals: [
        approval('theological', 'user-both'),
        approval('christian_education', 'user-both'),
        approval('safeguarding', 'user-safe'),
      ],
    });
    const check = canPublish({ version: v, publisherRole: 'SUPER_ADMIN' });
    expect(check.allowed).toBe(false);
    expect(check.reason).toContain('three different people');
  });

  it('refuses a publisher without publish authority', () => {
    for (const role of ['CONTENT_EDITOR', 'THEOLOGICAL_REVIEWER', 'ANALYTICS_VIEWER'] as const) {
      expect(canPublish({ version: fullyApproved(), publisherRole: role }).allowed).toBe(false);
    }
  });

  it('refuses republishing an already published version', () => {
    const v = { ...fullyApproved(), status: 'published' as const };
    expect(canPublish({ version: v, publisherRole: 'SUPER_ADMIN' }).allowed).toBe(false);
  });
});

describe('deriveVersionStatus', () => {
  it('is in_review while approvals are outstanding', () => {
    expect(deriveVersionStatus(version())).toBe('in_review');
  });

  it('is rejected as soon as any reviewer requests revisions', () => {
    const v = version({
      approvals: [
        approval('theological', 'user-theo'),
        approval('christian_education', 'user-edu', 'revision_requested'),
      ],
    });
    expect(deriveVersionStatus(v)).toBe('rejected');
  });

  it('is approved once all three are in', () => {
    expect(deriveVersionStatus(fullyApproved())).toBe('approved');
  });

  it('never downgrades a terminal status', () => {
    expect(deriveVersionStatus(version({ status: 'published' }))).toBe('published');
    expect(deriveVersionStatus(version({ status: 'superseded' }))).toBe('superseded');
  });
});

describe('validatePackageDraft', () => {
  const good = {
    id: 'the-lost-son',
    title: 'The Lost Son',
    genre: 'parable',
    sensitivityTier: 'general',
    ageBand: 'emerging',
    learningObjective: 'The child can say that the father runs to meet the son.',
    originalContext: 'Jesus answers religious leaders complaining about his table guests.',
    canonicalConnection: 'The father’s welcome pictures God receiving sinners.',
    verseContext: 'The turning point, while the son is still far from home.',
  };

  it('accepts a complete draft', () => {
    expect(validatePackageDraft(good)).toEqual([]);
  });

  it.each([
    'learningObjective',
    'originalContext',
    'canonicalConnection',
    'verseContext',
    'title',
  ] as const)('requires %s before the package can be written', (field) => {
    const errors = validatePackageDraft({ ...good, [field]: '' });
    expect(errors.map((e) => e.field)).toContain(field);
  });

  it('rejects a genre outside the plan’s six templates', () => {
    const errors = validatePackageDraft({ ...good, genre: 'epic' });
    expect(errors.map((e) => e.field)).toContain('genre');
  });

  it('requires an explicit sensitivity tier — there is no safe default', () => {
    const errors = validatePackageDraft({ ...good, sensitivityTier: undefined });
    expect(errors.map((e) => e.field)).toContain('sensitivityTier');
  });

  it('rejects a story id that is not kebab-case', () => {
    expect(validatePackageDraft({ ...good, id: 'The Lost Son' }).map((e) => e.field)).toContain('id');
    expect(validatePackageDraft({ ...good, id: 'the_lost_son' }).map((e) => e.field)).toContain('id');
  });
});
