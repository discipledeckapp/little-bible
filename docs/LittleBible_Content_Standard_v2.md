# Little Bible Content Standard 2.1

**Established:** 2026-08-01  
**Revised:** 2026-08-02  
**Status:** Binding for all content created after this date  
**Legacy rule:** Existing chapter and story content is frozen and must not be rewritten during new-content production unless the user separately authorizes a legacy audit.

## 1. Purpose

Create child-accessible Bible content that is faithful to its source, developmentally appropriate, pastorally responsible, and safe. Production speed never overrides fidelity, child wellbeing, or review.

## 2. Existing storage contract

New chapters must retain the repository's existing chapter JSON structure and naming:

- File: `public/data/en/{book_slug}/{book_slug}_chapter_{NN}.json`
- Chapter fields: `book`, `chapter`, `chapter_summary`, `main_lesson`, `memory_verse`, `parent_guide`, `application_for_children`, `verses`
- Verse fields: `book`, `chapter`, `verse`, `kjv`, `little_bible`, `little_reader_adaptation`, `meaning`, `memory_phrase`, `prayer`, `discussion_question`, `family_discussion`, `do_it_today`, `illustration_prompt`, `keywords`
- Book index entry: `{ "book": "…", "chapter": N, "file": "…" }`

The structure is retained for compatibility. The semantic boundaries below govern what may be placed in each field.

## 3. Field boundaries

### `kjv`

- Exact public-domain KJV verse text.
- No editing, merging, omission, or modernization.
- One JSON record per verse.

### `little_bible`

- Faithful child-readable translation of that verse only—not commentary, explanation, summary, retelling, or devotional application.
- Preserve every essential idea in the source verse.
- Preserve person, tense, pronouns, direct speech, metaphors, logical connections, ambiguity, and every essential clause.
- Preserve the speaker, audience, command, warning, promise, uncertainty, question, comparison, condition, and genre.
- Keep direct speech as direct speech. Do not convert it into narration such as “Jesus said that…” merely to simplify it.
- Do not replace a pronoun with an interpreted referent unless grammar requires it and the referent is unambiguous in the verse itself.
- Do not resolve an ambiguity, harmonize another passage, identify an unstated motive, or add a safeguarding/theological conclusion.
- Do not add doctrine, promises, motives, outcomes, cross-references, personal application, speaker labels absent from the verse, or other details absent from the verse.
- Vocabulary and sentence structure may be modernized or shortened only when the same claim, relationships, and degree of certainty remain intact.
- Never turn a statement addressed uniquely to Jesus or another person into a direct statement about the child.
- Direct divine speech must remain clearly attributed.
- Translation test: a reader should be able to map every phrase back to the source verse, and every essential source phrase should be represented.
- Boundary test: if wording answers “what does this mean?”, “how should a child apply it?”, or “how should this be understood safely?”, it belongs in `meaning`, `parent_guide`, or an application field—not in `little_bible`.

### `little_reader_adaptation`

- Shorter simplified paraphrase and reading-support version of the same verse.
- Must remain faithful; simplicity does not permit changing the claim.
- It may simplify sentence relationships more freely than `little_bible`, but must not become commentary or silently delete a difficult essential claim.
- Prefer concrete words, one idea per sentence, and replayable read-aloud phrasing.

### `meaning`

- Adult-facing explanation of original literary and historical meaning.
- May explain context and warranted canonical connections.
- Distinguish original meaning from later Christian theological reflection.
- Identify denominationally disputed readings rather than presenting one as undisputed.

### `memory_phrase`

- A labelled summary, never represented as Scripture.
- Prefer four words or fewer; exceed only when fidelity or natural language requires it.
- Must not create a promise or universal claim absent from the verse.

### `prayer`

- Optional model response, not a required child action.
- Natural, brief, and connected to the verse.
- Must not promise outcomes, manipulate emotion, require disclosure, or imply that prayer earns safety, success, healing, or approval.

### Discussion and application fields

- Invite conversation; never interrogate, shame, demand disclosure, or assume one family structure.
- A child may always decline.
- Do not ask children to reveal secrets, approach strangers, reconcile with unsafe people, or obey unsafe instructions.
- Descriptive biblical events must not automatically become commands for a child.

## 4. Child-learning requirements

- Declare the intended access band during review: Early Learner 3–5, Emerging Reader 6–8, Independent Reader 9–12, or Parent Mode.
- Use short, concrete sentences and explain unavoidable abstract language in context.
- Do not rely only on reading, colour, sound, fine motor control, prior church knowledge, or one family experience.
- Avoid surveillance language, shame, fear-based compliance, perfectionism, and guaranteed cause-and-effect claims.
- Questions should support observation, sequencing, meaning, emotion, perspective, or safe application—not recall alone.
- Violent, sexual, abusive, frightening, death-related, self-harm, and complex doctrinal material requires sensitivity classification and age gating rather than silent sanitization.

## 5. Theological requirements

- Respect the passage's genre and original context.
- Do not force Christological symbolism into details unsupported by the text.
- Do not present human obedience or virtue as earning divine love or salvation.
- Do not imply faithful people are always physically protected.
- Do not present suffering as proof of insufficient faith.
- Distinguish God's covenant promises from general wishes or individualized guarantees.
- Preserve resurrection when teaching the death of Jesus.
- Maintain the unique identity of Jesus; adoption/belovedness language for believers must be explained through union with Christ, not copied directly from declarations uniquely addressed to the Son.
- Flag disputed doctrines for reviewer comment.

## 6. Safeguarding requirements

- Obedience material must never teach unconditional compliance with adults. Adjacent guidance must affirm that children can refuse unsafe touch, harmful requests, and secret-keeping and should tell a trusted safe adult.
- Forgiveness does not require restored access, secrecy, or return to an unsafe person.
- Helping others must be parent-supported and stranger-safe.
- The app never asks a child to confess or disclose secrets to the app.
- God's knowledge and presence must not be framed as threatening surveillance.

## 7. New-content workflow

1. Confirm the chapter is missing and reserve it in `docs/content-completion.json`.
2. Obtain and verify exact KJV text and verse count.
3. Record genre, context, sensitive material, and disputed doctrines.
4. Draft the complete chapter in the existing JSON schema.
5. Run structural, sequence, field, and language linting.
6. Obtain independent theological review.
7. Obtain independent child-learning and safeguarding review.
8. Revise only the new draft.
9. Re-run validation.
10. Add the chapter to its book index only after both reviews pass.
11. Update completion tracking and retain review notes.

## 8. Review status

- `missing`: no file exists.
- `reserved`: selected for current work.
- `drafted`: complete JSON draft exists but is not indexed.
- `theology_reviewed`: theological review completed.
- `child_reviewed`: child-learning/safeguarding review completed.
- `approved`: both reviews pass and all validation succeeds.
- `published`: approved file is present in the book index.
- `blocked`: cannot proceed without a source, policy, or user decision.

## 9. Batch policy

- Produce one complete chapter at a time to preserve the existing format.
- Review internally by coherent literary units of roughly 10–20 verses.
- Do not mark a chapter approved because only part of it passed.
- Existing content remains untouched during this programme.
