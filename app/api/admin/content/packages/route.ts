import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { requireAdminApi } from '@/lib/admin/auth';
import { sendEmail } from '@/lib/email';
import { validatePackageDraft } from '@/lib/content/review-workflow';
import { validateFields, type CharterField } from '@/lib/content/translation-charter';
import { createVersion, reviewerRecipients } from '@/lib/content/package-service';

export async function GET() {
  const auth = await requireAdminApi('content');
  if (auth.error) return auth.error;

  const packages = await prisma.contentPackage.findMany({
    orderBy: { updatedAt: 'desc' },
    include: {
      createdBy: { select: { name: true, email: true } },
      versions: {
        orderBy: { versionNumber: 'desc' },
        take: 1,
        include: { approvals: true, author: { select: { name: true, email: true } } },
      },
    },
  });

  return NextResponse.json({ packages });
}

/**
 * Creates a package and submits its first version for review (US-19).
 *
 * A charter violation aborts before anything is written — the acceptance
 * criterion is explicit that a rejected submission must leave no record behind.
 */
export async function POST(request: NextRequest) {
  const auth = await requireAdminApi('content');
  if (auth.error) return auth.error;

  const payload = (await request.json()) as {
    draft?: Record<string, string>;
    body?: unknown;
    charterFields?: Partial<Record<CharterField, string>>;
    changeNote?: string;
  };

  const draft = payload.draft ?? {};
  const fieldErrors = validatePackageDraft(draft);
  if (fieldErrors.length > 0) {
    return NextResponse.json({ error: 'invalid_draft', fieldErrors }, { status: 422 });
  }

  const charter = validateFields(payload.charterFields ?? {});
  if (!charter.ok) {
    return NextResponse.json(
      { error: 'charter_violation', issues: charter.issues },
      { status: 422 },
    );
  }

  if (!payload.body || typeof payload.body !== 'object') {
    return NextResponse.json({ error: 'missing_body' }, { status: 422 });
  }

  const existing = await prisma.contentPackage.findUnique({ where: { id: draft.id! } });
  if (existing) {
    return NextResponse.json({ error: 'package_exists', id: draft.id }, { status: 409 });
  }

  const created = await prisma.contentPackage.create({
    data: {
      id: draft.id!,
      title: draft.title!,
      genre: draft.genre!,
      sensitivityTier: draft.sensitivityTier!,
      ageBand: draft.ageBand ?? 'emerging',
      learningObjective: draft.learningObjective!,
      originalContext: draft.originalContext!,
      canonicalConnection: draft.canonicalConnection!,
      disputedDoctrines: draft.disputedDoctrines || null,
      status: 'in_review',
      createdById: auth.session.user.id,
    },
  });

  const version = await createVersion({
    packageId: created.id,
    body: JSON.stringify(payload.body),
    authorId: auth.session.user.id,
    changeNote: payload.changeNote,
  });

  // Notification is best-effort: a mail failure must not undo an accepted
  // submission that is already in the reviewers' queue.
  try {
    const recipients = await reviewerRecipients();
    await Promise.all(
      recipients.map((to) =>
        sendEmail({
          to,
          subject: `Little Bible — "${created.title}" is ready for review`,
          htmlBody: `<p>A new content package has been submitted for review.</p>
            <p><strong>${created.title}</strong> (${created.genre}, ${created.sensitivityTier})</p>
            <p>Learning objective: ${created.learningObjective}</p>
            <p>Open the admin reviews queue to record your decision.</p>`,
          textBody:
            `${created.title} (${created.genre}, ${created.sensitivityTier}) has been ` +
            'submitted for review. Open the admin reviews queue to record your decision.',
        }),
      ),
    );
  } catch {
    // Swallowed deliberately — see above.
  }

  return NextResponse.json({ package: created, version }, { status: 201 });
}
