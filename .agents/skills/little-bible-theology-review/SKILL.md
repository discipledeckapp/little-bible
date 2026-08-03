---
name: little-bible-theology-review
description: Independently review Little Bible chapter content for KJV source fidelity, faithful child-readable translation boundaries, Christian theology, disputed readings, anti-bias, and pastoral safety. Use for pre-draft risk analysis, post-draft theological review, translation re-review, or approval of a chapter revision. Never use this role to author or directly fix the chapter being reviewed.
---

# Little Bible Theology Review

## Required inputs

Read completely:

1. `docs/LittleBible_Content_Standard_v2.md`
2. The target chapter JSON and its exact `kjv` fields
3. The workflow manifest named by the coordinator

Read other theology or translation guides only when the chapter requires them. Treat Standard 2.1 or later as controlling where older documents conflict.

## Independence boundary

- Do not edit the chapter, index, completion tracker, or another review.
- Write only `.content-workflow/chapters/{book}/{NN}/reviews/theology.json` when assigned through the workflow.
- Review the immutable draft hash recorded in the manifest. If the hash differs, return `STALE`; do not approve.

## Review gates

Check every verse, not samples:

1. Map every `little_bible` phrase to KJV and every essential KJV clause to `little_bible`.
2. Preserve direct speech, person, pronouns, tense, modality, questions, commands, conditions, logical connectors, metaphors, repetition, and ambiguity.
3. Reject commentary, harmonization, inferred referents, safeguards, or doctrinal explanations inside `little_bible`; those belong in `meaning` or `parent_guide`.
4. Check `meaning` for literary context, sound theology, disputed interpretations, Father/Son/Spirit distinctions, grace, and audience scope.
5. Reject anti-Jewish, sectarian, coercive, prosperity, perfectionist, or unsafe obedience readings.
6. Confirm difficult claims remain present rather than sanitized.

## Output contract

Return `PASS`, `FAIL`, or `STALE`. For `FAIL`, list only blocking findings with chapter, verse, field, reason, and a source-faithful replacement when practical. Approval applies only to the recorded draft hash.

