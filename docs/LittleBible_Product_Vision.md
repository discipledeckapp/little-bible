# Little Bible — Product Vision
**Version 1.0 | Established 2026-06-12**

---

## Vision Statement

> **The world's most faithful, accessible, and comprehensive discipleship platform for children ages 4–7.**

Little Bible begins as a Scripture adaptation. It grows into a complete discipleship ecosystem that serves families across every language, culture, and context where children are growing up without accessible access to God's Word.

---

## Mission (See `LittleBible_Mission.md`)

Help every child understand, love, remember, and obey God's Word from their earliest years.

---

## Core Values

| Value | What it means in practice |
|-------|--------------------------|
| **Faithfulness** | We never simplify away doctrine. We translate it. |
| **Accessibility** | If a 4-year-old cannot understand it, it is not yet accessible. |
| **Completeness** | All 66 books. Every verse. Every language. No shortcuts. |
| **Family-centeredness** | Parents are the primary disciplers. We equip them. |
| **Open source** | No child should be denied Scripture because of money. |

---

## Phase Roadmap

---

### Phase 1 — Scripture Adaptation
**Goal:** All 66 books adapted into child-accessible English following Translation Charter v1.

**Deliverables:**
- Every KJV verse adapted into `little_bible` format
- All verse fields populated: `memory_phrase`, `prayer`, `discussion_question`, `meaning`, `keywords`
- All chapter fields populated: `chapter_summary`, `main_lesson`, `parent_guide`, `application_for_children`, `memory_verse`
- Every chapter passing the Review Checklist before publication

**Priority order:**
1. Proverbs (31 chapters) — pilot
2. John (21 chapters) — Gospel entry point
3. Psalms (150 chapters — selected passages initially)
4. Luke (24 chapters)
5. Genesis (50 chapters — selected passages initially)
6. Romans, Galatians, Ephesians, James, 1 John
7. Remaining NT books
8. Remaining OT books
9. Deuteronomy, Isaiah, Jeremiah (key prophetic sections)
10. Full canonical completion

**Status:** In progress — Proverbs 1 complete.

---

### Phase 2 — Audio
**Goal:** Every verse read aloud by a warm, clear voice. Every prayer spoken. Every memory phrase recorded.

**Features:**
- Professional narration of `little_bible` text for every verse
- Separate narration of `memory_phrase` at slow pace (for memorization)
- Narration of `prayer` for family prayer time
- Background: gentle, non-distracting ambient audio option
- Accessibility: serves children with reading challenges, visual impairments

**Architecture already prepared:** `lib/audio.ts` handles `SpeechSynthesis` as an interim solution. Phase 2 replaces this with recorded audio files at `public/audio/{lang}/{book}/{chapter}/{verse}.mp3`.

---

### Phase 3 — Scripture Memory
**Goal:** Every child who uses Little Bible can memorize Scripture.

**Features:**
- Slow-pace memory phrase playback
- Say-it-together prompts
- Fill-in-the-blank: "Wisdom keeps us ____"
- Tap-the-missing-word games
- Arrange the words: jumbled word ordering
- Memory streak tracking
- Cumulative memory bank: all memorized phrases in one place
- Badge system for memorization milestones

**Content model already prepared:** `memory_phrase` field (≤ 4 words) is designed for this. The short length is not a limitation — it is a feature.

---

### Phase 4 — Family Devotions
**Goal:** Every family can have a daily Scripture devotion together.

**Features:**
- Full Family Mode (Read → Discuss → Pray → Remember → Do It Today)
- Family devotion history
- Family account (multiple child profiles)
- Devotion reminders (optional notification)
- Family streak tracking
- Shared family prayer journal
- Parent notes per chapter
- Export family devotion record (PDF)

**Architecture already prepared:** `FamilyModeReader.tsx` with 5-step flow.

---

### Phase 5 — Discipleship Journeys
**Goal:** Structured tracks that take a child through specific discipleship themes across multiple books.

**Example journeys:**
- **Who is God?** — Genesis 1, Psalm 23, John 1, Revelation 21
- **Jesus loves me** — Matthew, Mark, Luke, John (key passages)
- **Learning to obey** — Proverbs, Ephesians 6, 1 Samuel, Daniel
- **God keeps His promises** — Genesis 12, Psalm 105, Isaiah 53, Revelation 22
- **Praying to God** — Psalms (selected), Matthew 6, Luke 18, Philippians 4
- **Being wise** — Proverbs (full book)

**Features:**
- Journey cards on home screen
- Progress through the journey
- Completion certificates
- Parent view of journey progress
- Custom journey creation (for curriculum developers)

---

### Phase 6 — Multilingual Expansion
**Goal:** Every child in the world can access Little Bible in their heart language.

**Languages (priority order):**
1. Spanish (es) — ~500M speakers
2. French (fr) — ~300M speakers
3. Yoruba (yo) — foundational for West Africa
4. Portuguese (pt) — Brazil + Africa
5. Swahili (sw) — East Africa
6. Mandarin (zh) — China + diaspora
7. Hindi (hi) — India
8. Arabic (ar) — Middle East + North Africa
9. All remaining major languages

**Translation model:**
- English Little Bible text is the source (not KJV) for all translations
- Same field structure, same word limits (approximately)
- Native speaker review required before publication
- Review Checklist applies in the target language

**Architecture already prepared:** Language-first data structure at `public/data/{lang}/`.

---

### Phase 7 — Global Children's Discipleship Platform
**Goal:** Little Bible becomes the world's most comprehensive discipleship resource for children ages 4–7.

**Features:**
- Web platform (current)
- Native iOS and Android apps (Flutter)
- Offline support (full app works without internet)
- Curriculum integration (churches, schools, homeschool co-ops)
- Teacher dashboard (track class progress)
- Church plan (entire congregation using Little Bible together)
- Contributor platform (vetted translators and reviewers can submit content)
- Illustration library (original art for every verse)
- Video library (animated verse explanations)
- Partnership with global missions organizations

---

## Current Platform Status

| Feature | Status |
|---------|--------|
| Child Mode (verse-by-verse, audio-first) | ✓ Built |
| Family Mode (5-step devotional) | ✓ Built |
| Review Mode (KJV comparison, annotations, export) | ✓ Built |
| Progress tracking (seeds, streaks, badges) | ✓ Built |
| PIN protection for Review Mode | ✓ Built |
| Illustration zone (SVG + emoji fallback) | ✓ Built |
| Mode persistence (localStorage) | ✓ Built |
| Chapter completion screen | ✓ Built |
| WisdomBar (homepage progress) | ✓ Built |
| ChapterCard with live progress | ✓ Built |
| Header mode indicator | ✓ Built |
| Proverbs 1 content (33 verses) | ✓ Published (Charter v1 compliant) |
| Audio (SpeechSynthesis) | ✓ Interim — Phase 2 will add recorded audio |
| Scripture memory games | Planned — Phase 3 |
| Multi-book navigation | Pending — content |
| Multi-language | Planned — Phase 6 |
| Native mobile app | Planned — Phase 7 |

---

## Design Principles

These apply to all product development across all phases:

1. **Reverence** — The platform handles God's Word. The design must reflect that. No game-show energy.
2. **Warmth** — Amber, cream, and soft colors. Not clinical, not neon.
3. **Simplicity** — A 4-year-old should be able to use the core features.
4. **Touch-first** — Mobile and tablet are the primary devices for families with young children.
5. **Calm** — Minimal animation. No startling sounds. No overwhelming visual noise.
6. **Accessibility** — Large text, high contrast, audio support, reduced motion option.
7. **Family-scale** — Design for the family unit, not just the individual child.

---

## What Little Bible Will Never Be

- ❌ A gamified distraction from Scripture (games are for memorization, not entertainment)
- ❌ A story Bible that selects only comfortable passages
- ❌ A product that requires a paid subscription to access Scripture
- ❌ A platform that prioritizes engagement metrics over discipleship outcomes
- ❌ A tool that replaces parents as the primary disciplers
- ❌ A closed, proprietary resource unavailable to low-income families
