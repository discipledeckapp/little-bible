# Little Bible — Review Checklist
**Version 1.0 | Established 2026-06-12**

---

> Every chapter must pass this checklist before it is added to the book index.
> Adding to the index = published. Do not publish content that has not passed every check.

---

## How to Use This Checklist

Run every check below for every verse in the chapter.
Mark ✓ (pass), ✗ (fail), or N/A where the check does not apply.
A single ✗ means the chapter is not approved — fix and re-run.

---

## Part A — Source Text Fidelity

### A1 — No Verse Skipping
- [ ] Every KJV verse of the chapter has a corresponding verse object in the JSON.
- [ ] No verse numbers are missing from the sequence.

### A2 — KJV Text Accuracy
- [ ] The `kjv` field for every verse matches the public-domain KJV exactly.
- [ ] No KJV text has been edited, paraphrased, or rearranged.

### A3 — No Verse Merging
- [ ] Every verse object corresponds to exactly one KJV verse.
- [ ] No two verses have been combined into a single object.

---

## Part B — `little_bible` Field Quality

### B1 — Sentence Length
- [ ] Every sentence in `little_bible` is **8 words or fewer**.
- [ ] Most sentences are **3–6 words** (the preferred range).

### B2 — One Idea Per Sentence
- [ ] No sentence carries two distinct ideas joined with "and" or "but" (unless the total is ≤ 8 words and both ideas are simple).

### B3 — Prohibited Vocabulary
- [ ] No Tier 3 vocabulary appears (see `LittleBible_Vocabulary_Guide.md`).
- [ ] No archaic KJV forms: thee, thou, thy, hast, doth, hath, ye, verily.

### B4 — Meaning Preserved
- [ ] Every distinct theological idea in the source verse appears in `little_bible`.
- [ ] No doctrine has been removed to simplify.
- [ ] No doctrine has been added that is not in the source verse.

### B5 — Doctrinal Policies
- [ ] **Fear of the Lord:** Present where source verse contains it. Uses approved language.
- [ ] **Sin:** Not removed. Not reframed as a mere mistake. Uses approved language.
- [ ] **Consequences:** Not softened or removed.
- [ ] **Commands:** Preserved in imperative form.
- [ ] **Promises:** Preserved and clearly stated.

### B6 — Child Comprehension Test
- [ ] Read the `little_bible` text aloud.
- [ ] Ask: "Would a typical 4-year-old understand every word of every sentence?"
- [ ] If no → revise before approving.

---

## Part C — `memory_phrase` Field Quality

### C1 — Word Count
- [ ] The `memory_phrase` is **4 words or fewer**. Count every word.

### C2 — Complete Thought
- [ ] The phrase is a grammatically complete statement or command.
- [ ] It makes sense standing alone, out of context.

### C3 — Theological Accuracy
- [ ] The phrase accurately represents the verse's core truth.
- [ ] It is not merely inspirational-sounding but theologically correct.

### C4 — Memorability
- [ ] A 4-year-old could repeat this phrase after hearing it once or twice.
- [ ] It is rhythmically natural when spoken aloud.

---

## Part D — `prayer` Field Quality

### D1 — Opening
- [ ] The prayer begins with `God,` — not `Dear God,` and not any other opening.

### D2 — Word Count
- [ ] The prayer is **10 words or fewer**. Count every word including "God".

### D3 — Relevance
- [ ] The prayer responds directly to this specific verse — not a generic prayer that could apply to any verse.

### D4 — Child Voice
- [ ] The prayer sounds like something a 4-year-old could naturally pray.
- [ ] No adult language or complex sentence structure.

---

## Part E — `discussion_question` Field Quality

### E1 — Single Question
- [ ] There is exactly **one** question in the field.
- [ ] No compound questions joined with "and" or "or".

### E2 — Word Count
- [ ] The question is **10 words or fewer**.

### E3 — Answerable by a Child
- [ ] The question can be attempted by a 4-year-old who has heard only the `little_bible` text.
- [ ] The question does not require knowledge the child has not been given.

### E4 — Opens Conversation
- [ ] The question opens a real conversation between parent and child.
- [ ] It is not a yes/no question if an open question was possible.

---

## Part F — `meaning` Field Quality

### F1 — Theological Accuracy
- [ ] The `meaning` accurately represents the theological content of the verse.
- [ ] It is written at adult level — not dumbed down.

### F2 — No Omission
- [ ] The `meaning` does not omit difficult aspects of the verse (sin, judgment, consequences).

### F3 — Cross-Reference Accuracy (if used)
- [ ] Any cross-references cited are accurate and relevant.

---

## Part G — Chapter-Level Fields

### G1 — `chapter_summary`
- [ ] 3–6 sentences covering the full arc of the chapter.
- [ ] Written at adult level.
- [ ] Includes the chapter's main warning, promise, and command (if present).

### G2 — `main_lesson`
- [ ] 1–2 sentences. Child-accessible (age 6–7 level).
- [ ] Reflects the dominant theological theme — not just the most comfortable idea.

### G3 — `parent_guide`
- [ ] 2–4 paragraphs.
- [ ] Covers: theological context, key theme, age-appropriate application.
- [ ] Written at adult level. Pastoral, not academic.
- [ ] Does not omit the chapter's warnings or difficult content.

### G4 — `application_for_children`
- [ ] 1–3 sentences.
- [ ] Concrete and practical — one action a child can take this week.
- [ ] Doable with parental support by a 4-year-old.

### G5 — `memory_verse`
- [ ] The KJV text of the most theologically significant verse in the chapter.
- [ ] Accurate to the KJV.

---

## Part H — Seven Discipleship Goals

For the chapter as a whole, confirm:

- [ ] **Know God** — The chapter helps a child understand something specific about who God is.
- [ ] **Love God** — At least some content makes God appear loveable, not only authoritative.
- [ ] **Trust God** — At least one promise is clearly presented.
- [ ] **Obey God** — At least one command is clearly preserved.
- [ ] **Pray to God** — Every verse has a prayer that makes prayer feel natural.
- [ ] **Memorize Scripture** — Every memory phrase is within the 4-word limit.
- [ ] **Follow Jesus** — The `meaning` or `parent_guide` connects to Christ where appropriate.

---

## Part I — Technical Checks

### I1 — JSON Validity
- [ ] The chapter file is valid JSON (no syntax errors).
- [ ] All required fields are present in every verse object.
- [ ] All required chapter-level fields are present.

### I2 — File Naming
- [ ] File is named `{book_slug}_chapter_{nn}.json` with zero-padded chapter number.

### I3 — Index Entry
- [ ] The chapter is added to the book's `index.json` only after passing all checks above.

---

## Approval Sign-Off

| Check group | Passed? | Notes |
|-------------|---------|-------|
| A — Source fidelity | | |
| B — `little_bible` quality | | |
| C — `memory_phrase` quality | | |
| D — `prayer` quality | | |
| E — `discussion_question` quality | | |
| F — `meaning` quality | | |
| G — Chapter-level fields | | |
| H — Seven discipleship goals | | |
| I — Technical checks | | |

**Chapter:** _______ **Book:** _______ **Reviewed by:** _______ **Date:** _______

All groups marked passed → Chapter approved for publication.
