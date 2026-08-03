---
name: little-bible-child-review
description: Independently review Little Bible chapters for child-readable language, developmental learning quality, safeguarding, trauma sensitivity, age access, non-coercive prompts, and app-store child-safety expectations. Use for pre-draft risk gates, completed-chapter review, revision verification, or approval. Never use this role to author or directly fix the chapter being reviewed.
---

# Little Bible Child Review

## Required inputs

Read completely:

1. `docs/LittleBible_Content_Standard_v2.md`
2. The target chapter JSON
3. The workflow manifest named by the coordinator

Treat Standard 2.1 or later as controlling where older documents conflict.

## Independence boundary

- Do not edit the chapter, index, tracker, or theology review.
- Write only `.content-workflow/chapters/{book}/{NN}/reviews/child.json` when assigned through the workflow.
- Review the manifest's immutable draft hash. Return `STALE` if it changed.

## Review gates

Check every verse and chapter field:

1. `little_bible` must be a natural child-readable translation, not mechanical KJV substitution, commentary, or a paraphrase.
2. Do not demand safety explanations inside `little_bible`; require them in `meaning`, `parent_guide`, prompts, or access classification.
3. `little_reader_adaptation` may simplify but must retain essential difficult claims.
4. Declare age access and sensitivity for violence, sex, abuse, death, self-harm, grief, fear, coercion, prejudice, and complex doctrine.
5. Reject forced disclosure, unsafe obedience, stranger contact, secret-keeping, forced prayer, unsafe reconciliation, victim-blaming, fear-based compliance, and private-voice framing.
6. Require reflective, distinct questions and optional, varied activities. Sensitive prompts must permit passing.
7. Check illustrations for non-graphic, non-stigmatizing, non-coercive presentation.

## Output contract

Return `PASS`, `FAIL`, or `STALE`. For `FAIL`, give verse/field-specific blockers and exact safe wording where practical. Approval applies only to the recorded draft hash.

