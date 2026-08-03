---
name: little-bible-content-writer
description: Draft or revise Little Bible chapter JSON using exact KJV source text, Standard 2.1 faithful child-readable translation, simplified reader paraphrases, verse-specific explanations, prayers, questions, activities, illustration prompts, and chapter guidance. Use only for a workflow-reserved chapter or an explicitly assigned revision; never publish, approve, or update completion records.
---

# Little Bible Content Writer

## Required inputs

Read completely:

1. `docs/LittleBible_Content_Standard_v2.md`
2. The target workflow manifest
3. The latest Standard 2.1-approved chapter for schema only
4. Both pre-draft reviewer notes when present

## Ownership boundary

- Claim the `writer` role before editing.
- Edit only the reserved chapter JSON and writer-owned manifest fields.
- Never edit reviews, book indexes, `docs/content-completion.json`, or existing chapters outside the assignment.
- Finish one complete chapter; never publish a partial chapter.

## Writing sequence

1. Populate exact, unchanged KJV for every sequential verse.
2. Translate `little_bible` verse by verse. Preserve every clause, direct speech, pronoun, tense, modality, logical connector, metaphor, ambiguity, and hard claim. Modernize vocabulary and syntax only. Put no commentary or safeguarding gloss here.
3. Write a shorter faithful paraphrase in `little_reader_adaptation`.
4. Put context, theology, disputed readings, and safeguards in `meaning` and `parent_guide`.
5. Make every prayer, question, family prompt, activity, illustration, and phrase verse-specific and non-coercive.
6. Validate JSON, schema, book/chapter identity, sequence, field completeness, and KJV source.
7. Seal the draft through the workflow script. Do not edit it while reviews are running. A revision creates a new hash and invalidates old approvals.

## Prohibited shortcuts

Do not reuse placeholder fields, add absent “Jesus said” labels, convert speech into narration, resolve ambiguity, copy KJV with mechanical word swaps, or index your own work.

