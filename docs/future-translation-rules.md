# Little Bible Future Translation Rules v1

**Status: Official — required workflow for all future chapters**

---

## Before You Begin Any New Chapter

### Step 1 — Read the KJV chapter through completely
Understand the arc of the whole chapter before translating a single verse.
Note: What is the main theme? What is the warning? What is the promise?

### Step 2 — Read the most recently approved Little Bible chapter
Calibrate your style, sentence length, and vocabulary level.

### Step 3 — Write the chapter-level fields first
Before touching any verse, write:
- `chapter_summary` (adult-written, for context)
- `main_lesson` (1 sentence, child-accessible)
- `memory_verse` (the single most important verse reference)
- `parent_guide` (adult; 2–4 paragraphs)
- `application_for_children` (1–3 sentences, practical)

These set the theological intention before verse-level work begins.

---

## Verse Translation Workflow

For each verse, work through these fields in order:

### Field 1: `little_bible`

1. Read the KJV verse.
2. Identify every distinct idea in the verse. List them.
3. Write one sentence per idea.
4. Count words in each sentence. Must be ≤ 8. Target 3–6.
5. Check for prohibited words (see vocabulary guide). Replace all.
6. Read aloud. Would a 4-year-old understand every word?
7. Check doctrinal rules — is sin present? Is it preserved? Is the promise preserved?

### Field 2: `memory_phrase`

1. Identify the single core truth of this verse. Just one.
2. Write it in 4 words or fewer.
3. Test: Can a 4-year-old say this from memory tomorrow?
4. Test: Is this theologically accurate — not just inspiring-sounding?

### Field 3: `prayer`

1. What would a child naturally ask God after hearing this verse?
2. Write it beginning with "God,"
3. Count words. Must be ≤ 10.
4. The prayer must flow directly from the verse — not generic.

### Field 4: `discussion_question`

1. Think of what a parent reading this verse to their child would naturally ask.
2. Write one question only. Max 10 words.
3. Test: Can a 4-year-old attempt an answer based on the `little_bible` text alone?

### Field 5: `meaning`

1. Write for a parent or content reviewer.
2. No word limit — be thorough.
3. Explain the theological depth. Cross-reference if helpful.
4. Do not simplify — this is the adult layer.

### Field 6: `keywords`

1. 2–5 keywords maximum.
2. Used by the illustration system — be specific.
3. Choose words that visually evoke the verse: e.g., "lion", "path", "storm", "prayer"

---

## Chapter JSON Structure

Every chapter file must follow this exact structure:

```json
{
  "book": "Book Name",
  "chapter": 1,
  "chapter_summary": "...",
  "main_lesson": "...",
  "memory_verse": "...",
  "parent_guide": "...",
  "application_for_children": "...",
  "verses": [
    {
      "book": "Book Name",
      "chapter": 1,
      "verse": 1,
      "kjv": "...",
      "little_bible": "...",
      "meaning": "...",
      "memory_phrase": "...",
      "prayer": "...",
      "discussion_question": "...",
      "keywords": ["keyword1", "keyword2"]
    }
  ]
}
```

### File naming
`{book_slug}_chapter_{nn}.json` — zero-padded to 2 digits.

Examples:
- `proverbs_chapter_01.json`
- `proverbs_chapter_02.json`
- `genesis_chapter_01.json`
- `john_chapter_03.json`

### Index file
Every book requires an `index.json`:
```json
[
  { "book": "Book Name", "chapter": 1, "file": "bookslug_chapter_01.json" },
  { "book": "Book Name", "chapter": 2, "file": "bookslug_chapter_02.json" }
]
```

---

## Quality Control Pass

After writing all verses for a chapter, run this pass:

| Check | Test |
|-------|------|
| Sentence length | Every `little_bible` sentence ≤ 8 words |
| Memory phrases | Every `memory_phrase` ≤ 4 words |
| Prayers | Every `prayer` ≤ 10 words, starts with "God," |
| Questions | Every `discussion_question` ≤ 10 words, 1 question only |
| Forbidden words | No Tier 3 words unexplained |
| Theological fidelity | Sin not removed, consequences not softened, promises kept |
| Child comprehension | Every verse passes the 4-year-old read-aloud test |
| Consistency | Style matches the previous approved chapter |

---

## Book Priority Order (Suggested)

Start with wisdom and Gospel books before historical narrative.

### Priority 1 — Wisdom and Gospel
- Proverbs (31 chapters)
- Psalms (150 chapters — selected passages first)
- John (21 chapters)
- Luke (24 chapters)

### Priority 2 — Core Narrative
- Genesis (50 chapters — selected passages first)
- Exodus (selected passages)
- Acts

### Priority 3 — Epistles
- Romans
- 1 Corinthians
- Galatians
- Ephesians
- James
- 1 John

### Priority 4 — Remaining OT and NT
All 66 books — in canonical order, working through Priority 1 books fully before moving on.

---

## Translation Status Tracking

Every chapter should be tracked in `public/data/{lang}/index.json` only once it is:

1. Fully written
2. Quality control pass complete
3. Approved by project owner

A chapter file added to the index is considered **published** and will be shown to users.

---

## Multi-Language Workflow

When translating to a second language (e.g., Spanish, French, Yoruba):

1. The English Little Bible text is the source — not the KJV.
2. Translate the `little_bible`, `memory_phrase`, `prayer`, and `discussion_question` fields.
3. Keep the same word limits (4/10/10 words) in the target language.
4. Do not translate `kjv` — keep it in English or add a parallel field `kjv_translation` for the target language's public-domain version.
5. Adjust `keywords` for the illustration system if needed.

Language codes: `en`, `es`, `fr`, `yo`, `pt`, `sw`, `zh`, `hi`, `ar`

---

## Versioning

If any charter, vocabulary, or style rules change:

1. Increment the version number on all affected documents.
2. Audit all existing chapters for compliance with the new rules.
3. Update non-compliant verses before publishing new chapters.

---

## The Discipleship Layer

Every chapter of Little Bible must serve these goals:

1. **Know God** — Who is God in this passage?
2. **Love God** — What in this passage makes a child want to love God more?
3. **Trust God** — What promise or truth can a child hold onto?
4. **Obey God** — What does God ask of us in this passage?
5. **Pray to God** — The prayer field must make this natural.
6. **Grow in wisdom** — The meaning and discussion question must deepen understanding.
7. **Follow Jesus** — Even in the Old Testament, point toward the character of Christ where possible.

A chapter that only simplifies Scripture but does not make a child want to know and follow God has failed its mission.
