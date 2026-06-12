# Little Bible — Project Instructions for Claude
**Read this file before performing any work in this repository.**

---

## What This Project Is

Little Bible is a **child-accessible Scripture adaptation and discipleship platform**.

It is adapted from the public-domain King James Version (KJV).

It is NOT a simplified story Bible, a paraphrase, or a creative retelling.

It is a faithful, verse-by-verse adaptation of every word of Scripture into language a child aged 4–5 can understand — while preserving the full theological content of the source text.

**Primary audience:** Children aged 4–5 (read aloud by a parent)
**Secondary audience:** Children aged 6–7 (emerging readers)

---

## Mission

> Help every child understand, love, remember, and obey God's Word from their earliest years.

Every chapter, verse, and feature must serve these seven goals:

1. **Know God**
2. **Love God**
3. **Trust God**
4. **Obey God**
5. **Pray to God**
6. **Memorize Scripture**
7. **Follow Jesus**

---

## Mandatory Operating Rule

**Before generating any Bible adaptation, chapter, verse, prayer, memory phrase, discussion question, illustration prompt, audio script, or any other content for this project:**

1. Read all relevant files in `/docs/`
2. Follow every standard defined there
3. Review the most recently approved content for consistency
4. Run the Review Checklist before declaring content complete
5. Explicitly state any deviation from the standards and why

**Before making any code changes:**

1. Read `CLAUDE.md` (this file) — you are already here ✓
2. Understand the product's purpose and its primary audience (ages 4–5)
3. Do not build features that contradict the design principles below
4. Do not change the content schema without updating the relevant docs

---

## Documentation Index

All project standards are in `/docs/`. Read the relevant file before working in its area.

| File | Purpose | Read when... |
|------|---------|--------------|
| `LittleBible_Mission.md` | Why we exist, target audience, desired outcomes | Working on any content or product feature |
| `LittleBible_Content_Framework.md` | Data architecture, field definitions, content pipeline | Adding/editing content; changing the schema |
| `LittleBible_Translation_Charter.md` | Binding rules for all content | Translating any verse |
| `LittleBible_Style_Guide.md` | Sentence construction, per-field rules, examples | Writing `little_bible`, prayers, memory phrases, questions |
| `LittleBible_Vocabulary_Guide.md` | Tier 1/2/3 word lists, KJV replacement table | Writing any child-level content |
| `LittleBible_Theology_Guide.md` | Doctrinal handling for all major themes | Writing any verse with God, sin, salvation, judgment, etc. |
| `LittleBible_Review_Checklist.md` | Chapter approval checklist | Before publishing any new chapter |
| `LittleBible_Product_Vision.md` | Platform phases and design principles | Adding features; making design decisions |

---

## Content Field Rules — Quick Reference

These are hard limits. They cannot be overridden by context or user request.

| Field | Rule |
|-------|------|
| `little_bible` sentence | Max **8 words**. Prefer 3–6. One idea per sentence. |
| `memory_phrase` | Max **4 words**. Hard limit. No exceptions. |
| `prayer` | Max **10 words**. Must start with `God,` not `Dear God,`. |
| `discussion_question` | Max **10 words**. One question only. |
| Source | Always adapted from KJV. `kjv` field = exact KJV text, never modified. |

---

## Content Schema

Every verse object in a chapter JSON must include:

```json
{
  "book": "string",
  "chapter": 1,
  "verse": 1,
  "kjv": "exact KJV text",
  "little_bible": "child-accessible adaptation",
  "meaning": "adult-level theological explanation",
  "memory_phrase": "max 4 words",
  "prayer": "God, max 10 words.",
  "discussion_question": "max 10 words?",
  "keywords": ["2-5 concrete visual keywords"]
}
```

Every chapter file must include:

```json
{
  "book": "string",
  "chapter": 1,
  "chapter_summary": "adult-level, 3-6 sentences",
  "main_lesson": "child-accessible, 1-2 sentences",
  "memory_verse": "KJV text of key verse",
  "parent_guide": "adult-level, 2-4 paragraphs",
  "application_for_children": "1-3 sentences, concrete action",
  "verses": [...]
}
```

---

## Theological Policies — Quick Reference

| Concept | Policy |
|---------|--------|
| Fear of the Lord | Never remove. Use: "Respecting God / God is holy / Honor Him." |
| Sin | Never remove. Never call it a "mistake." Use: "doing wrong / disobeying God." |
| Consequences | Never soften or remove. "Bad choices always come back to us." |
| Repentance | Use: "turn back to God / stop doing wrong / come back to God." |
| Promises | Always preserved and clearly stated in `little_bible`. |
| Commands | Always preserved in imperative form. |
| Judgment | Never removed. Framed as justice, not cruelty. |
| Jesus (OT) | Do not insert into `little_bible`. May connect in `meaning` and `parent_guide`. |
| Salvation | Never earned through behavior. `meaning` must reflect grace. |

---

## File Structure

```
/
├── CLAUDE.md                    ← This file. Read first.
├── app/
│   ├── page.tsx                 ← Homepage
│   ├── [book]/[chapter]/page.tsx ← Chapter page (SSG)
│   └── globals.css
├── components/
│   ├── home/                    ← HeroSection, ChapterCard, WisdomBar, etc.
│   ├── layout/                  ← Header, Footer, HeaderModeChip
│   └── reader/                  ← ChildModeReader, FamilyModeReader, ReviewModeReader, etc.
├── docs/                        ← ALL project standards (read before working)
├── lib/
│   ├── audio.ts                 ← SpeechSynthesis utilities
│   ├── content.ts               ← fs-based JSON loader (server-side)
│   ├── illustrations.ts         ← Illustration/emoji scene system
│   ├── mode.ts                  ← localStorage mode persistence
│   ├── progress.ts              ← Seeds, streaks, badges, sessions
│   └── review.ts                ← Review annotations and export
├── public/
│   └── data/
│       └── en/
│           ├── index.json        ← Language index (books available)
│           └── proverbs/
│               ├── index.json    ← Book index (chapters available)
│               └── proverbs_chapter_01.json
└── types/
    └── index.ts                  ← AppMode, Verse, Chapter, Progress, Badge, etc.
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 15 (App Router) |
| Language | TypeScript |
| Styling | Tailwind CSS v4 |
| Fonts | Nunito (child), Lora (devotion), Playfair Display (titles) |
| Content | Local JSON files via `fs.readFileSync` |
| State | React hooks + localStorage |
| Routing | Static params: `generateStaticParams` |
| Audio | SpeechSynthesis API (interim — Phase 2 will add recorded audio) |

---

## Design Principles

Always apply these when writing code or designing features:

1. **Reverence** — God's Word is being displayed. The design must reflect that. No game-show energy.
2. **Warmth** — Amber, cream, soft colors. Not clinical, not neon.
3. **Simplicity** — A 4-year-old should be able to use the core features.
4. **Touch-first** — Mobile and tablet are the primary devices.
5. **Calm** — Minimal animation. No startling effects. No overwhelming visual noise.
6. **Accessibility** — Large text, high contrast, audio support, reduced motion.
7. **Family-scale** — Design for the family unit, not just the individual child.

**Never build:**
- Gamification that distracts from Scripture
- Features that remove parents from the discipleship process
- Content that softens or removes doctrine for comfort

---

## Reading Mode Summary

| Mode | Who uses it | Primary experience |
|------|-------------|--------------------|
| **Child Mode** | Child aged 4–7 | Verse-by-verse. Audio-first. Large text. Encouragement. |
| **Family Mode** | Parent + child together | 5 steps: Read → Discuss → Pray → Remember → Do It Today |
| **Review Mode** | Content reviewer, parent | Full KJV comparison, annotations, export. PIN-protected. |

---

## Current Content

| Book | Chapters published | Status |
|------|--------------------|--------|
| Proverbs | 1 | ✓ Charter v1 compliant |

---

## Before Adding a New Chapter

1. Read `LittleBible_Translation_Charter.md`
2. Read `LittleBible_Style_Guide.md`
3. Read `LittleBible_Vocabulary_Guide.md`
4. Read `LittleBible_Theology_Guide.md`
5. Read the most recently published chapter JSON for style reference
6. Write all chapter fields and all verse fields
7. Run every check in `LittleBible_Review_Checklist.md`
8. Only then add the chapter to the book's `index.json`

---

## Owner

**Oluwaseyi Adelaju**

This project is open source. Standards may only be updated by the project owner.
All updates must be versioned and applied retroactively to existing content before new content is published.
