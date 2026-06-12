# Little Bible — Content Framework
**Version 1.0 | Established 2026-06-12**

---

## Overview

Little Bible content is structured in three layers:

1. **Book layer** — one entry per Bible book in the language index
2. **Chapter layer** — one JSON file per chapter, with chapter-level fields
3. **Verse layer** — one object per verse inside the chapter file

Every layer serves the discipleship mission. No field is decorative.

---

## Data Architecture

### Language Index
`public/data/{lang}/index.json`

Lists all available books for a given language.

```json
[
  {
    "book": "Proverbs",
    "slug": "proverbs",
    "indexFile": "proverbs/index.json"
  }
]
```

### Book Index
`public/data/{lang}/{book_slug}/index.json`

Lists all available chapters for a book.

```json
[
  { "book": "Proverbs", "chapter": 1, "file": "proverbs_chapter_01.json" },
  { "book": "Proverbs", "chapter": 2, "file": "proverbs_chapter_02.json" }
]
```

A chapter file listed here is **published**. Do not add a chapter until it passes the full Review Checklist.

### Chapter File
`public/data/{lang}/{book_slug}/{book_slug}_chapter_{nn}.json`

Zero-pad chapter numbers to 2 digits: `_01`, `_02`, ..., `_31`.

---

## Chapter-Level Fields

Every chapter file must include all of the following:

### `book` *(string)*
The full book name as it appears in the KJV. Example: `"Proverbs"`.

### `chapter` *(integer)*
The chapter number. Example: `1`.

### `chapter_summary` *(string)*
A 3–6 sentence summary of the chapter. Written at an adult level. Purpose: gives the parent and reviewer theological context before reading the verses. Not shown to children in Child Mode.

**Standard:** Accurate, no embellishment, no omission of difficult themes.

### `main_lesson` *(string)*
One or two sentences. The single most important takeaway for a child. Written at child-accessible level (age 6–7). Shown in Family Mode and Review Mode.

**Standard:** Must reflect the chapter's dominant theological theme, not just its most comfortable idea.

### `memory_verse` *(string)*
The most important verse reference for the chapter — written as a short quote, not a citation. Example: `"The fear of the LORD is the beginning of knowledge."` Not required to be child-level — this is the KJV text of the key verse.

### `parent_guide` *(string)*
2–4 paragraphs for parents and teachers. Covers:
- Theological context
- Key themes for discussion
- Age-appropriate application
- Cross-references where helpful

Written at adult level. Shown in Family Mode and Review Mode.

### `application_for_children` *(string)*
1–3 sentences. One practical action a child can take this week in response to the chapter. Written so a parent can read it aloud and lead the child through it.

**Standard:** Must be concrete, not abstract. "Pray each morning: 'God, help me choose right.'" — not "Think about what wisdom means."

---

## Verse-Level Fields

Every verse object must include all of the following:

### `book` *(string)*
Same as chapter-level. Repeated for portability.

### `chapter` *(integer)*
Same as chapter-level. Repeated for portability.

### `verse` *(integer)*
The verse number.

### `kjv` *(string)*
The exact KJV text of the verse. Copied verbatim. Never modified.

### `little_bible` *(string)*
**The core child-accessible adaptation of the verse.**

Rules (see `LittleBible_Translation_Charter.md` and `LittleBible_Style_Guide.md` for full details):
- Maximum 8 words per sentence
- Preferred sentence length: 3–6 words
- One idea per sentence
- No paragraphs
- All prohibited words replaced
- Full theological content preserved
- Passes child comprehension test

### `meaning` *(string)*
The theological meaning of the verse, written at adult level. No word limit. Used in Review Mode and as a parent resource. May reference cross-references, theological depth, and nuance.

### `memory_phrase` *(string)*
**Maximum 4 words.** A complete, memorable statement of the verse's core truth. Designed to be memorized and repeated by a 4-year-old. Must be theologically accurate — not merely inspirational.

### `prayer` *(string)*
**Maximum 10 words.** Begins with `God,`. A short prayer a child can pray in response to the verse. Directly tied to the verse's message.

### `discussion_question` *(string)*
**Maximum 10 words.** One question only. Answerable by a 4-year-old who has heard only the `little_bible` text. Opens a natural conversation.

### `keywords` *(array of strings)*
2–5 keywords. Used by the illustration system (SVG/emoji fallback). Choose concrete, visual words: `"storm"`, `"path"`, `"prayer"`, `"king"` — not abstract concepts.

---

## The Seven Discipleship Goals

Every chapter must serve all seven. Reviewers check each one explicitly.

| Goal | How it shows up in content |
|------|---------------------------|
| **Know God** | `meaning`, `parent_guide` explain who God is in this passage |
| **Love God** | `little_bible` and `memory_phrase` make God loveable and real |
| **Trust God** | Promises are preserved and clearly stated |
| **Obey God** | Commands are preserved; `discussion_question` invites response |
| **Pray to God** | `prayer` field — every verse has one |
| **Memorize Scripture** | `memory_phrase` — short enough to memorize |
| **Follow Jesus** | `meaning` and `parent_guide` connect to Christ where applicable |

---

## Reading Modes

Content is displayed differently depending on the reading mode:

| Field | Child Mode | Family Mode | Review Mode |
|-------|------------|-------------|-------------|
| `little_bible` | ✓ Large, audio-first | ✓ | ✓ |
| `kjv` | Hidden | Collapsible | ✓ Always visible |
| `memory_phrase` | ✓ Always visible | ✓ In Remember step | ✓ |
| `prayer` | ✓ Tap to expand | ✓ In Pray step | ✓ |
| `discussion_question` | Hidden | ✓ In Discuss step | ✓ |
| `meaning` | Hidden | Hidden | ✓ |
| `chapter_summary` | Hidden | ✓ | ✓ |
| `parent_guide` | Hidden | ✓ Collapsible | ✓ |
| `application_for_children` | Hidden | ✓ | ✓ |

---

## Content Pipeline

The process from Scripture to published content:

```
1. KJV Source Text
       ↓
2. Chapter-level fields written (summary, lesson, parent guide, application)
       ↓
3. Verse-by-verse translation (little_bible)
       ↓
4. Memory phrases written (≤ 4 words each)
       ↓
5. Prayers written (≤ 10 words each)
       ↓
6. Discussion questions written (≤ 10 words each)
       ↓
7. Keywords assigned
       ↓
8. Meaning written (adult level)
       ↓
9. Review Checklist run (see LittleBible_Review_Checklist.md)
       ↓
10. Book index.json updated with new chapter
       ↓
11. Published
```

---

## File Naming Reference

| Book | Slug | Example file |
|------|------|--------------|
| Genesis | `genesis` | `genesis_chapter_01.json` |
| Psalms | `psalms` | `psalms_chapter_023.json` (3 digits for 100+ chapter books) |
| Proverbs | `proverbs` | `proverbs_chapter_01.json` |
| John | `john` | `john_chapter_03.json` |
| Romans | `romans` | `romans_chapter_08.json` |
| Revelation | `revelation` | `revelation_chapter_21.json` |

**Rule:** For books with more than 99 chapters (Psalms only), use 3-digit zero-padding. All others use 2-digit.

---

## Supported Languages

Language codes follow ISO 639-1:

| Language | Code | Status |
|----------|------|--------|
| English | `en` | Active (pilot) |
| Spanish | `es` | Planned |
| French | `fr` | Planned |
| Yoruba | `yo` | Planned |
| Portuguese | `pt` | Planned |
| Swahili | `sw` | Planned |
| Mandarin | `zh` | Planned |
| Hindi | `hi` | Planned |
| Arabic | `ar` | Planned |

For multi-language translation rules, see `LittleBible_Translation_Charter.md`.
