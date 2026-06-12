# Little Bible

**God's Word for Little Hearts**

An open-source, child-friendly adaptation of Scripture for ages 4–7, built with Next.js 15, TypeScript, and Tailwind CSS. Content is generated chapter-by-chapter as JSON files — no backend or database required.

---

## Project Purpose

Little Bible adapts the KJV translation into simple, warm language that children ages 4–7 can understand, while preserving the original theological meaning. Each verse provides:

- **Little Bible** — the child-friendly adaptation
- **Meaning** — a one-sentence explanation
- **Memory Phrase** — short, memorable truth
- **Prayer** — a simple child's prayer
- **Discussion Question** — for parent/child conversation
- **Keywords** — for study and search

---

## Running Locally

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

---

## Folder Structure

```
little-bible/
├── app/
│   ├── layout.tsx                   # Root layout + metadata
│   ├── page.tsx                     # Homepage — shows all books & chapters
│   └── [book]/[chapter]/
│       └── page.tsx                 # Chapter reader (Child Mode + Review Mode)
├── components/
│   ├── layout/
│   │   ├── Header.tsx
│   │   └── Footer.tsx
│   ├── home/
│   │   ├── HeroSection.tsx
│   │   ├── StatsBar.tsx
│   │   ├── ChapterCard.tsx
│   │   └── ModeToggle.tsx           # Child / Review mode selector
│   └── reader/
│       ├── ChapterPageClient.tsx    # Client shell — reads mode from localStorage
│       ├── ChildModeReader.tsx      # Child mode: verse-by-verse, big buttons
│       ├── ReviewModeReader.tsx     # Review mode: full text, search, annotations
│       └── VerseCard.tsx            # Individual verse card for review mode
├── lib/
│   ├── content.ts                   # Server-side JSON loader (uses fs)
│   ├── review.ts                    # Client-side review storage (localStorage)
│   └── mode.ts                      # Mode preference storage (localStorage)
├── types/
│   └── index.ts                     # Verse, Chapter, ReviewStatus, AppMode, etc.
└── public/
    └── data/
        └── en/                       # English content (language-first)
            ├── index.json            # List of all books
            └── proverbs/
                ├── index.json        # List of Proverbs chapters
                └── proverbs_chapter_01.json
```

---

## How to Add a New Chapter

1. Create the JSON file following the schema below and save it to:
   ```
   public/data/en/proverbs/proverbs_chapter_02.json
   ```

2. Add an entry to `public/data/en/proverbs/index.json`:
   ```json
   { "book": "Proverbs", "chapter": 2, "file": "proverbs_chapter_02.json" }
   ```

No code changes required — the app picks it up automatically.

---

## How to Add a New Book

1. Create the book folder:
   ```
   public/data/en/genesis/
   ```

2. Add chapter JSON files:
   ```
   public/data/en/genesis/genesis_chapter_01.json
   ```

3. Create `public/data/en/genesis/index.json`:
   ```json
   [{ "book": "Genesis", "chapter": 1, "file": "genesis_chapter_01.json" }]
   ```

4. Add the book to `public/data/en/index.json`:
   ```json
   { "book": "Genesis", "slug": "genesis", "indexFile": "genesis/index.json" }
   ```

No code changes required. The chapter is immediately available at `/genesis/1`.

**Planned books:** Genesis, Exodus, Psalms, Proverbs, Matthew, John, Romans, and more.

---

## How to Add a New Language

Future language content goes under:
```
public/data/yo/   ← Yoruba
public/data/ig/   ← Igbo
public/data/ha/   ← Hausa
public/data/fr/   ← French
public/data/sw/   ← Swahili
```

The `content.ts` loader accepts a `lang` parameter — the routing and UI will be extended when multilingual content is ready.

---

## Chapter JSON Schema

```json
{
  "book": "Proverbs",
  "chapter": 1,
  "chapter_summary": "...",
  "main_lesson": "...",
  "memory_verse": "...",
  "parent_guide": "...",
  "application_for_children": "...",
  "verses": [
    {
      "book": "Proverbs",
      "chapter": 1,
      "verse": 1,
      "kjv": "...",
      "little_bible": "...",
      "meaning": "...",
      "memory_phrase": "...",
      "prayer": "...",
      "discussion_question": "...",
      "keywords": ["wisdom", "king"]
    }
  ]
}
```

---

## Features

### Child Mode
- Verse-by-verse navigation with large, touch-friendly buttons
- "Read to me" button using the browser's SpeechSynthesis API
- Progress bar showing position in the chapter
- Memory phrase and prayer displayed prominently
- Encouragement message ("Great listening! 🌟") after each verse
- Chapter completion celebration screen
- Dot navigation for short chapters (≤12 verses)

### Review Mode
- Full KJV + Little Bible text side-by-side
- Meaning, discussion question, and keywords per verse
- Search across KJV, Little Bible, meaning, and keywords
- Show/hide KJV toggle (for adaptation-only review)
- Annotation system per verse:
  - ✓ Approved
  - ⚠ Needs Review
  - ⚡ Theological Concern
  - 📖 Too Difficult
  - ✏ Rewrite Needed
- Annotations stored in `localStorage` — no server required
- Export review report as `review-proverbs-chapter-1.json`

### Mode Persistence
- Selected mode (Child / Review) is remembered in `localStorage`
- Mode toggle available on both the homepage and chapter pages

---

## Technology Stack

| Layer       | Technology                   |
|-------------|------------------------------|
| Framework   | Next.js 15 (App Router)      |
| Language    | TypeScript                   |
| Styling     | Tailwind CSS v4              |
| Content     | Local JSON files             |
| Storage     | localStorage (review state)  |
| Audio       | Web SpeechSynthesis API      |
| Backend     | None                         |
| Database    | None                         |

---

## Future Architecture

The codebase is designed to be extended without breaking changes:

- **Supabase / PostgreSQL** — replace `lib/content.ts` file reads with API calls
- **API layer** — `lib/content.ts` already models clean data-access functions
- **Flutter app** — `types/index.ts` types map directly to Dart model classes
- **Multilingual** — `public/data/{lang}/` structure is already in place
- **Authentication** — reviewer accounts can be layered on top of the review system
