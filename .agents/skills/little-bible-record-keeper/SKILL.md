---
name: little-bible-record-keeper
description: Validate and publish Little Bible chapters that have matching theological and child-review approvals, maintain book indexes and completion records, reconcile counts, select the next missing chapter, and preserve audit history. Use after reviews finish or for read-only completion audits. Never write chapter content or overrule a failed/stale review.
---

# Little Bible Record Keeper

## Required inputs

Read `docs/LittleBible_Content_Standard_v2.md`, the workflow manifest, both review artifacts, target chapter, book index, and `docs/content-completion.json`.

## Exclusive ownership

- Claim `records` before mutations.
- Only this role may edit book indexes, completion totals, publication state, or select the next chapter.
- Never edit chapter prose or review verdicts.

## Publication gate

Publish only when:

1. Chapter JSON/schema/sequence/KJV validation passes.
2. Manifest draft hash equals the current chapter hash.
3. Both review artifacts say `PASS` for that exact hash and Standard 2.1 or later.
4. No role claim or revision is active.
5. Index does not already contain a conflicting entry.

If any condition fails, record the reason and do not publish. After publication, update counts once, append audit history, mark the work packet published, and reserve the numerically earliest missing chapter. Never infer approval.

## Reconciliation

Derive counts from chapter files rather than trusting cached totals. Preserve unrelated worktree changes and never repair legacy content without explicit authorization.

