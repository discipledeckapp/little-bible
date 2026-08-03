 # Little Bible — User Stories, System Design & Test Plan
**Mobile-First · Cloudflare Infrastructure · Offline-First**

> Child-development and store-compliance baseline reviewed 1 August 2026. Re-check Apple App Review, App Store Connect, Google Play Families, Data Safety, billing and account-specific testing requirements immediately before submission; current policy text and console results override estimates in this plan.

---

## Sprint History

### Sprint 1 (Complete)
Navigation shell, Drift schema v1, GoRouter routes, onboarding 3-step flow, home screen skeleton, Lumi placeholder.

### Sprint 2 (Complete)
Full story flow: Home → StoryPlayer (end-of-story choice panel) → KeyVerse → Games (4 Phase 1 games) → ColorIn → FamilyMoment → Home. VerseMastery tracking introduced. Garden CustomPainter. Bible Nav "My Verses". Portrait-only orientation locked.

### Sprint 3 (Complete — 2026-08-01)

**Implemented features:**
- Story completion badges on home cards (green checkmark circle, Khan Academy Kids style)
- "Hear the story again" button on end panel; `_hearAgain()` resets scene index
- Games back button (X icon, top-right, `context.pop()`)
- Games feedback variety: `onAnswer → String` callback, 5 correct + 5 wrong phrases, phrase spoken via `speakUi`
- Story completion tracking: `markComplete()` on last scene; `watchCompletedStoryIds()` stream

**Architecture decisions locked in Sprint 3:**
- **Subscription model**: First 20 stories (`_kFreeStoryCount = 20`) free with ALL features — story narration, Key Verse, all Phase 1 games, ColorIn, Family Moment. Stories 21+ locked at home-screen card level via `/unlock` routed through Parent Hub. No in-story feature gating of any kind.
- **Audio pipeline**: Story scenes use pre-generated Edge TTS MP3s (`en-US-AriaNeural`, rate `-10%`, pitch `+5Hz`) via `NarrationService`. Verse screen uses `flutter_tts` (device TTS) for word-by-word highlighting via `setProgressHandler` — this is intentional, cannot be replaced by MP3 playback. Android routes through `AudioContextAndroid(usageType: AndroidUsageType.media)`; iOS uses `AVAudioSessionCategory.playback`.
- **TTS race condition fix**: `TtsService._ready` future (result of `_init()`) is awaited before every `speak()` call.
- **LBV memory verse policy**: All story JSON `steps.remember.memoryVerse` uses simplified LBV text, never KJV. Memory verse MP3s regenerated to match via `scripts/generate_story_audio.py`.
- **`_initScene()` guards**: Detects `status == 'completed'` and shows end panel immediately — handles returning from games/verse sub-routes without replaying narration.

### Sprint 4 (Active — 2026-08-02)
IAP (US-15 + US-16) · Parent Hub (US-13) · Push notifications (US-14b) · GDPR deletion (US-14c) · Cloud sync · SoundService CC0 audio files

---

# Part 1 — System Design

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                           │
│                                                                  │
│   ┌─────────────┐  ┌─────────────────┐  ┌──────────────────┐   │
│   │  UI Layer   │  │  Feature Layer  │  │  Shared Services │   │
│   │ Widgets/Rive│  │  Riverpod/GoRtr │  │ Content/TTS/Sync │   │
│   └─────────────┘  └─────────────────┘  └──────────────────┘   │
│                              │                                   │
│   ┌──────────────────────────▼──────────────────────────────┐   │
│   │              Drift SQLite  (local source of truth)      │   │
│   │  verses · stories · activities · child_profiles         │   │
│   │  story_progress · verse_familiarity · sync_queue        │   │
│   └─────────────────────────────────────────────────────────┘   │
└──────────────────────────────┬───────────────────────────────────┘
                               │  online only — never blocks reads
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│             Cloudflare Workers  (Next.js via OpenNext)           │
│                                                                  │
│  /api/mobile/auth        /api/mobile/progress                   │
│  /api/mobile/manifest    /api/mobile/content                    │
│  /api/mobile/unlock      /admin/*                               │
└──────┬──────────────────┬──────────────┬──────────────┬─────────┘
       │                  │              │              │
       ▼                  ▼              ▼              ▼
  ┌─────────┐      ┌──────────┐   ┌──────────┐  ┌───────────────┐
  │   D1    │      │    R2    │   │    KV    │  │  Analytics    │
  │ SQLite  │      │  Object  │   │ Key-Val  │  │  Engine (CF)  │
  │ (data)  │      │ Storage  │   │ (cache)  │  │  (events)     │
  └─────────┘      └──────────┘   └──────────┘  └───────────────┘
```

---

## Offline-First Data Architecture

The fundamental rule: **every read in the app is always local. The network is never in the critical path.**

Data splits into two categories with different strategies:

### Content Data (read-only from the app's perspective)

Bible text, stories, activities, and game content. This data changes only when new content is published. The app never writes to it.

**Strategy — bundle first, download incrementally:**

```
App install
  → bundle contains: 10–12 launch stories · launch activities · curated age-approved verses
                     Genesis/Psalms/Proverbs/Daniel/Ruth/Esther in WEB
                     LBV adapted verses (current)
                     Total: ~18 MB

First launch (online)
  → GET /api/mobile/manifest
  → compare local content_versions table with server response
  → queue background downloads for any new/updated content
  → download to R2-sourced URLs, insert into local Drift DB

Subsequent sessions (offline or online)
  → all content reads from local Drift
  → no network call during active session
  → manifest check only on app foreground, non-blocking
```

**ContentService resolution chain:**

```
ContentService.getVerse(book, chapter, verse)
  1. SELECT FROM verses WHERE book=? AND chapter=? AND verse=? AND source='little-bible'
  2. Found  → ResolvedVerse { text, isAdapted: true,  source: 'little-bible' }
  3. Missing → SELECT FROM verses WHERE book=? AND chapter=? AND verse=? AND source='web'
  4. Found  → ResolvedVerse { text, isAdapted: false, source: 'web' }
  5. Missing → ResolvedVerse { text: '[verse not yet available]', isAdapted: false }
```

### Progress and Child Data (local by default; parent-controlled sync)

Child nickname, age band, avatar, completions, weekly rhythm, verse practice and drawings are stored locally by default. The app must work without an account. A parent may explicitly enable cloud backup and reports from behind the parental gate after a just-in-time disclosure and any legally required verifiable parental consent. The child nickname and drawings never leave the device; cloud records use a random profile ID and the coarsest data needed for the enabled feature.

**Strategy — local first, queue-based sync:**

```
Child completes story
  → INSERT INTO story_progress (profileId, storyId, completionState, completedAt)
  → UPDATE child_profiles SET gardenGrowth=..., weeklyRhythm=...
  → if parent-enabled sync: INSERT INTO sync_queue with random profileId and minimised payload
  → UI updates immediately — zero network dependency

SyncService (background, fires on: app foreground + online event)
  → SELECT FROM sync_queue WHERE syncedAt IS NULL ORDER BY createdAt
  → POST /api/mobile/progress { entries: [...] }
  → on 200: UPDATE sync_queue SET syncedAt=now() for those IDs
  → on failure: leave in queue, exponential backoff, retry next cycle

Conflict resolution (if same consented profile is used on two devices)
  → server merges: take MAX(gardenGrowth), merge weekly rhythm, UNION(completedStories)
  → progress only ever increases — no conflict possible for the core data
```

**Data minimisation rules:**
- Never transmit child nickname, exact birth date, drawings, typed answers, voice, free-form text, contact data, advertising IDs, precise location, or stable device identifiers.
- Analytics events use a rotating, non-account-linked install token and coarse age band; no event stream may reconstruct an identifiable child's history.
- Diagnostics scrub IP address, headers, URLs, breadcrumbs, user objects, local paths, entered text, profile IDs and email before transmission.
- Maintain a versioned data inventory recording each field, purpose, legal basis/consent, processor, retention, deletion path, Apple privacy-label classification and Google Data Safety classification.
- Cloud sync defaults off. Consent withdrawal stops future upload and deletes previously synced child data.

---

## Cloudflare Infrastructure & Free Tiers

All infrastructure runs on Cloudflare. No third-party database, no external compute.

| Service | What it stores / does | Free limit | Paid cost | Hits limit at |
|---|---|---|---|---|
| **Workers** | API, Next.js app | 100K req/day | $5/mo for 10M req | ~1,200 DAU |
| **D1** | Users, progress, donations, events | 5 GB · 5M reads/day · 100K writes/day | $0.001/100K writes | ~50K DAU |
| **R2** | Story JSON, audio files, illustrations | 10 GB · 10M ops/mo | $0.015/GB stored | 100+ GB content |
| **KV** | Content manifests, hot story cache | 100K reads/day · 1K writes/day | $0.50/million reads | ~1,200 DAU |
| **Analytics Engine** | Custom events (replaces third-party analytics) | 100K writes/day | $0.25/million | ~3M events/day |
| **Queues** | Async background jobs (IAP webhooks, email) | 1M messages/mo | $0.40/million | ~30K transactions |

**Key insight on R2:** zero egress fees. Audio files and content JSON served from R2 cost nothing to transfer. This is the critical advantage over S3 for a content-heavy app.

**At 10,000 DAU:**
- Workers: ~30K requests/day (well within free)
- D1: ~10K writes/day (within free)
- KV: ~10K reads/day (within free)
- **Monthly cost: ~$5 Workers paid plan only**

**At 100,000 DAU:**
- Workers: 300K requests/day → $5/month paid
- D1 writes: ~100K/day → ~$1/month
- Analytics Engine: ~3M events/day → ~$22/month
- **Monthly cost: ~$30 total**

### Additional Free Tools

| Tool | Purpose | Free limit |
|---|---|---|
| **ZeptoMail** | Transactional email (welcome, parent reports) — already wired in via `ZEPTOMAIL_TOKEN` | 6,000 emails/month free (Lite plan) |
| **GitHub Actions** | CI/CD (build, test, deploy) | 2,000 min/month; macOS runners burn ~25 min/build → cache Flutter SDK to stay within limits |
| **Sentry (provisional)** | Error tracking only after a privacy/SDK review. Release configuration must disable default PII and scrub identifiers, child/profile data, entered text, URLs, headers, breadcrumbs and IP addresses. No diagnostics vendor is inherently COPPA-safe. | Verify current plan before launch |
| **flutter_tts** | Platform-native TTS (AVSpeechSynthesizer / Android TTS). Used **only** for Key Verse word-by-word highlighting via `setProgressHandler` — device TTS is required here because MP3 playback cannot provide word timing callbacks. Story scenes and memory verse use pre-generated Edge TTS MP3s instead. | Free, unlimited |
| **edge-tts** (Python, `scripts/generate_story_audio.py`) | Generates bundled MP3s for story scenes + memory verse. Voice: `en-US-AriaNeural`, rate `-10%`, pitch `+5Hz`. Run once per story before each ship. Files land at `assets/audio/stories/{storyId}/scene_{n}.mp3` and `memory_verse.mp3`. | Free, offline gen |
| **Google Sign-In SDK** | Parent authentication (not used by children) | Free |

---

## Scaling Design Decisions

**Why offline-first reduces infrastructure cost dramatically:**
A child completing a 15-minute session makes exactly 2-3 API calls total — one manifest check on open, one progress sync on close, one auth check if needed. Compare this to a server-dependent app making 20-30 calls per session. Offline-first gives a 10× reduction in server load at the same user count.

**Content delivery via R2:**
Story JSON and audio files live in R2. Workers never stream large content — they return signed R2 URLs (or public R2 URLs for bundled content). CF's global network serves R2 from the edge closest to the user. No CDN cost.

**D1 read scaling:**
D1 now supports read replication. Progress reads (parent hub, analytics) go to replicas. Progress writes go to primary. Content reads never hit D1 — they come from the local Drift instance or from R2 downloads.

**Analytics Engine vs third-party:**
CF Analytics Engine replaces Mixpanel/Amplitude for custom events. It runs on the same infrastructure, costs fractions of a cent at scale, and keeps all user data within Cloudflare (important for the app's privacy positioning as a children's product under COPPA/GDPR-K).

---

## Drift Migration Strategy

Every release that changes the schema must ship a numbered migration. Establish this from day one — failure to do so corrupts local DBs on update.

```dart
// In AppDatabase class:
@DriftDatabase(tables: [...], daos: [...])
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 2; // increment with every schema change

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async { await m.createAll(); },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Example: added verse_familiarity.last_practiced column in v1.1
        await m.addColumn(verseMastery, verseMastery.lastPracticed);
      }
    },
  );
}
```

Rule: every PR that adds a Drift table or column must also increment `schemaVersion` and add the corresponding `onUpgrade` branch. Reviewed as part of code review — not optional.

---

## Bundle Size Budget

The "~18MB" claim requires validation. Tracked budget before first build:

| Asset | Estimated size |
|---|---|
| Flutter engine (release, arm64+arm) | ~7 MB |
| Lumi Rive animation file (all states) | ~3–5 MB |
| NT in WEB as JSON (260 chapters, ~7,900 verses) | ~2.5 MB |
| Priority OT (Gen/Ps/Prov/Dan/Ruth/Esther) | ~1.5 MB |
| 10–12 launch stories × all text tiers (JSON) | ~0.6–0.8 MB |
| 50 activity files | ~0.5 MB |
| UI images, icons, avatar assets | ~2 MB |
| **Total estimate** | **~20–27 MB** |

ScenePuzzle and HiddenObject illustrations are the variable. Keep all bundled images as WebP at 80% quality, max 512×512px. Any illustration set that pushes the bundle above 35MB must be moved to on-demand R2 download. Audit the bundle with `flutter build apk --analyze-size` before v1.0 submission.

---

## Lumi Character Spec

Lumi is a small, round, glowing creature — not gendered. Four animation states in the Rive file:

| State | Trigger | What Lumi does |
|---|---|---|
| `idle` | Home screen, no interaction for >3s | Gentle bob, occasional blink, soft glow pulse |
| `celebrate` | Meaningful session or collection milestone | Warm glow and gentle movement; not tied to perfection, prayer or chance |
| `thinking` | Game loads, verse loads (brief delay) | Tilts head, squints gently, small question mark floats |
| `encourage` | Wrong answer, game abandoned | Moves closer to screen, warm glow, no negative expression |

**Role boundary:** Lumi is a fictional learning guide, never a spiritual authority. Lumi must never speak as God or Jesus, say "God told me", claim private revelation for a child, pronounce forgiveness/salvation/divine approval, imply that correct answers please God, or replace Scripture, parents, pastors or church community. Dialogue referring to divine speech must quote and label its Scripture source accurately.

**Voice:** platform TTS at `pitch: 1.1, rate: 0.82` — slightly warm but not cartoonishly high. Verify this feels right by testing on a 4-year-old before locking it in. The specific values in each story's TTS call should use these constants, not inline numbers.

**When Lumi speaks unprompted:**
- App opens → greets child by name ("Hi Noah! Ready for a story?")
- Story complete → offers a brief predictable garden acknowledgement
- Idle >60s on home screen → gentle prompt ("Shall we open a story?")
- Weekly learning milestone → gentle acknowledgement without spiritual or comparative language

**When Lumi is silent:**
- During parent hub (Lumi not visible)
- During admin interface (Lumi not present)
- While the child is typing (VerseTyping game)

---

## Illustration Standard

Every visual element in the app that depicts a story scene, character, or activity must be produced as Flutter `CustomPainter` vector art. Emoji, system icons, and raster stock illustrations are not permitted in story covers, coloring scenes, or any screen that represents a biblical story visually.

**Story covers (home screen cards and story player header):**
- Each story has a unique `CustomPainter` cover illustration dispatched by `storyId`
- Uses the full card/header `Size` so it scales to any device without resampling
- Colors drawn from the app design token palette (lumiGold, sky, earth, coral) — warm, child-friendly, never photorealistic
- Must depict the story's key setting or central moment, not a generic background
- New stories added to the content library must ship with a matching `CustomPainter` cover class

**Coloring scene illustrations:**
- Each story's coloring scene is a named set of `_Region` objects with normalized `Path` definitions
- Bold black outlines (strokeWidth ≈ 1.8% of canvas width) matching printed coloring book weight
- All regions large enough for a child's finger tap (minimum ~4% of canvas area)
- No raster images, no emoji characters used as fill content

**Rule:** if a designer or developer reaches for an emoji to represent a story moment, that is a signal a CustomPainter illustration is needed instead.

---

## Sound Design Spec

Sound is as important as visuals for under-8s. Every sound is independently mutable by the parent. TTS and background audio have separate volume controls. Default: background audio at 40% of device volume, TTS at 100%.

| Moment | Sound | Characteristics |
|---|---|---|
| App open | Soft chime, 0.8s | Warm, not startling — precedes Lumi's greeting |
| Story scene advance | Soft page-turn whoosh, 0.3s | Tactile feel without interrupting narration |
| Correct answer | Rising two-note tone, 0.4s | Distinct from scene advance; not the same sound each time — rotate 3 variants |
| Incorrect answer | Gentle low bounce, 0.3s | Not a buzzer; soft and recoverable-feeling |
| Story complete | Three-note ascending chime + Lumi's celebrate voice line | Full moment — child should stop and look |
| Garden grows (meaningful session) | Single warm bell, 0.5s | Predictable acknowledgement; no consecutive-day requirement |
| Story wonder detail | Magical shimmer, 1s | Deliberately authored for relevant content; never random or tied to a reward multiplier |
| Bible verse word highlight | No sound | Keep verse reading quiet so TTS voice is the focus |
| Prayer pause | Soft ambient hum, 8–10s | The only moment the app has deliberate silence + ambient; helps child feel the pause is intentional |

**ColorIn game sounds:**
- Region fill: soft "crayon stroke" whoosh, 0.2s (same family as page-turn, slightly rougher texture)
- All regions filled: rising three-note chime (same as story complete variant B) — reuse the same asset

**Background ambient (story player only):**
Stories have an optional `ambientTrack` field: `nature` / `gentle_wind` / `water` / `none`. Plays at 30% volume, loops, fades out on scene end. Not present in game or verse screens. All ambient audio is bundled, never streamed.

**Free audio sources (all sounds must use one of these — no paid libraries):**
- [Freesound.org](https://freesound.org) — Creative Commons; filter by CC0 or CC-BY; download WAV, convert to OGG for Android / CAF for iOS
- [OpenGameArt.org](https://opengameart.org) — CC0 SFX packs suitable for children's apps
- [Pixabay Sound Effects](https://pixabay.com/sound-effects/) — CC0, no attribution required
- Flutter `audioplayers` package (already in pubspec or add: `audioplayers: ^6.x`) for one-shot SFX; keep a `SoundService` wrapper so all playback is controllable by the parent mute setting
- All sounds must be reviewed before use: no scary tones, no aggressive buzzer-style rejects, no sounds that could startle a child under 3 years old

**Implementation:**
Add a `SoundService` (similar to `TtsService`) with:
- `playEffect(SoundEffect effect)` — plays a bundled OGG/CAF asset
- `setMuted(bool)` — respects parent sound-off toggle
- `setVolume(double)` — 0.0–1.0; defaults: SFX at 1.0, ambient at 0.3
- Sounds live in `assets/sounds/` — committed as OGG (Android) + CAF (iOS) pairs
- `SoundEffect` enum: `appOpen, pageAdvance, correct, incorrect, storyComplete, gardenGrows, wonder, prayerPause, colorFill, colorComplete`

---

## Orientation

The app is **portrait-only** (`portraitUp` + `portraitDown`). This is locked at startup via `SystemChrome.setPreferredOrientations` before `runApp`. Landscape orientation is never supported — the coloring canvas, story player, and verse screen are all designed for portrait aspect ratios. This must also be declared in `AndroidManifest.xml` (`screenOrientation="portrait"`) and `Info.plist` (only `UIInterfaceOrientationPortrait` and `UIInterfaceOrientationPortraitUpsideDown` listed).

---

## Colour & Accessibility

Text and interactive elements must meet WCAG AA at minimum. Commit these ratios before any UI is built — retroactive changes cost 2× the design time.

| Token | Hex | Min background | Contrast ratio | Use |
|---|---|---|---|---|
| `--lumi-gold` | `#F59E0B` | `#FFFBF5` (off-white bg) | 3.1:1 | Large text only (≥18sp Bold); never for body text |
| `--sky` | `#38BDF8` | `#1E3A5F` (dark surface) | 4.7:1 | Chapter visited state; large icon fills |
| `--earth` | `#15803D` | `#F0FDF4` (light surface) | 5.9:1 | Correct-answer highlight |
| `--coral` | `#F87171` | `#FFFBF5` | 3.2:1 | Decorative only; never the sole signal on interactive elements |
| Body text | `#1C1917` | `#FFFBF5` | 17.5:1 | All story and verse body text |
| Body text dark | `#F5F5F4` | `#1C1917` | 15.8:1 | Dark mode body text |

**Additional rules:**
- Colour is never the only differentiator. Every state that uses colour also uses an icon, label, or animation.
- Touch targets: minimum 48×48dp for any interactive element. Games with small targets (FlipMatch cards) must add at least 8dp padding around each tap area.
- Motion: all animations respect `MediaQuery.reducedMotion`. If true, substitute cross-fades for spring/bounce animations; Lumi switches from animated Rive to a static pose.

---

## Garden Visualiser Spec

The flexible weekly learning rhythm is represented by a cumulative garden—never a streak, countdown or attendance score.

**Location:** bottom-left corner of the home screen, 80×80dp. Tapping expands to a full-screen garden view (animated, no back button needed — auto-dismisses after 4s).

**States:**

| Days active this week | Garden state |
|---|---|
| 0 | The child's existing garden at its current cumulative state; no loss or "dry" signal |
| 1 | Small green shoot |
| 2–3 | Small plant with leaves |
| 4–5 | Flowering plant, one bloom |
| 6–7 | Full flowering plant, two blooms, glowing |

**Inactivity:** nothing wilts, disappears, dries out or resets. The app makes no comment about absence and resumes with a normal welcome.

**Weekly transition:** the cumulative garden remains intact. Parent Hub may archive a neutral weekly activity card, but the child sees no reset, deadline or lost opportunity.

---

## Child Development & Curriculum Quality Gates

Every story package must declare one observable learning objective and align its story, key verse, discussion, prayer and activity to that objective. A package is incomplete if it tests only factual recall.

| Band | Typical experience | Session target | Activity design | Content access |
|---|---|---:|---|---|
| **Early Learner (3–5)** | Adult-supported or independently explored pre-reader experience | 5–8 min | Spoken instructions, 2 picture choices, matching, sequencing, movement and replay | Small curated story/verse library; no sensitive passages |
| **Emerging Reader (6–8)** | Audio-supported early reading | 8–12 min | 2–3 choices, short phrases, sequencing, emotion, cause/effect and simple application | Expanded curated library with gentle context |
| **Independent Reader (9–12)** | Independent reading and reflection | 10–15 min | Recall plus interpretation, perspective, application and spaced verse practice | Broader reviewed library; sensitive content still gated or contextualised |

**Required pedagogy and wellbeing rules:**
- Instructions are replayable and demonstrated before first use.
- No task depends only on reading, colour, sound, fine motor precision or timed performance.
- Correct feedback identifies effort or strategy; incorrect feedback supplies a clue or replays relevant content without shame, loss or punitive animation.
- Verse familiarity grows through recognition, supported recall, independent recall, meaning in the child's words and story connection on a flexible spaced schedule.
- Rewards never imply spiritual worth, obedience to God or parental approval; missed days never remove progress.
- Stories involving death, violence, fear, abuse, sexual material, self-harm or complex doctrine require documented child-development and theological review before assignment to an age band.
- Formative testing requires parent consent and must not record a child's image, voice, name or free-form response unless a separate research-data protocol explicitly covers it.

**Genre-aware structure requirement (enforced at content authoring):**
Every content package declares its biblical genre and uses the matching template:
- **Narrative:** setting → tension → divine/human response → meaning.
- **Wisdom:** question → insight → example → practice.
- **Lament:** pain → honest prayer → remembrance → hope without forced resolution.
- **Teaching/epistle:** historical context → core truth → example → reflection.
- **Parable:** setting → surprise or reversal → meaning → open reflection.
- **Poetry/prophecy:** image → context → theological claim → wonder, lament or hope.

The admin rejects a package only when required beats for its selected genre are missing. Application may be action, wonder, lament, trust, rest or an honest question; it must not force every passage into "What should I do?"

**Sensitivity classification (required for every launch story and later content package before publication):**
Every story must carry a `sensitivityTier` field:

| Tier | Meaning | Access |
|---|---|---|
| `general` | Suitable for all age bands without additional context | Default child library |
| `guided` | Contains mild peril, death of an animal, fearful situation, or strong emotion | Emerging Reader+ by default; Early Learner with parental gate |
| `parental_presence` | Contains human death, near-harm of a child, or morally complex outcomes | Independent Reader+ by default; never autoplay; parent hub flagged |

Known stories requiring minimum `guided` or `parental_presence` review before v1.0: Abraham and Isaac, Noah's Flood, the Passover, Elijah's depression, Daniel in lions' den, David and Goliath (aftermath), the Crucifixion. These are not blocked — they are some of Scripture's most important stories. They require correct classification and age-gating.

**Doctrinal review checklist (held to by Theological Reviewers):**
Every story and LBV adaptation must be checked against these five failure modes:
1. **Grace-as-reward error** — does the story imply God loves us because we were good, or acts because we obeyed? Correct: God acts from his own character and covenant.
2. **Hero or forced-pointer error** — does the story make a human character the saviour, or force an unsupported Christ-symbol into every detail? Preserve the passage's original context, locate it honestly in the whole biblical story, and make only warranted Christian canonical connections.
3. **Mechanical prayer error** — does the story imply prayer is a formula for getting what we want? Correct: prayer is relational conversation, outcome is God's wisdom.
4. **Resurrection omission** — does any Jesus story end at death or on a problem without the resurrection or God's faithfulness? Correct: the New Testament's answer is always the risen Christ.
5. **Oversimplified suffering** — does the story imply that suffering is always a result of sin, or that faith always prevents hard things? Correct: Job, Lamentations, and the Psalms of lament are canonical.

**Flexible spaced practice schedule:**
When a verse is introduced it enters `VerseFamiliarity.stage = 'introduced'`. Dates are defaults that adapt when a child requests help or demonstrates confident recall and meaning:

| Stage | Triggered by | nextReviewDate |
|---|---|---|
| `introduced` | Key Verse screen displayed | +1–3 days |
| `recognised` | Selects/recognises with support | +3–5 days |
| `recalled` | Recalls independently | +7–14 days |
| `understood` | Explains meaning or story connection | +14–30 days |
| `growing_familiar` | Repeated recall plus understanding | Optional future practice; never declared permanently mastered |

The home screen shows a "Verse to practice today" card when any verse's `nextReviewDate ≤ today`. This is the app's primary spaced repetition driver — not a new screen, just a card on the existing home screen.

**Authored wonder moments:**
Wonder details are deliberately attached to relevant stories and appear at a predictable narrative point, independent of correctness. They may add visual or audio variety but never award currency, multipliers, rare prizes or variable-ratio reinforcement.

**Theological identity and governance:**
- Publish a concise statement covering the Trinity, Scripture, grace and salvation, Jesus' incarnation/death/resurrection, prayer, church, and the handling of disputed doctrines.
- Maintain an issues guide for baptism/communion, creation interpretations, spiritual gifts, end-times material, church language and denominationally disputed passages.
- A material content package requires approval from a biblical/theological reviewer, a children's ministry or Christian-education reviewer, and a safeguarding reviewer; no person may author and finally approve the same package.
- Reviews retain comments, version history, approver identity and rollback capability. The original-context reading, whole-Bible connection and child-level application are separate review fields.

---

## CI/CD & Release Pipeline

```
GitHub repository
  ├── main branch     → Cloudflare Pages deploy (web + Workers, automatic)
  ├── feature branches → PR build check (flutter test + vitest)
  └── release/x.y.z   → triggers mobile release pipeline

Mobile release pipeline (GitHub Actions)
  ├── iOS
  │   ├── flutter build ipa --release
  │   ├── Sign with Apple Distribution cert + provisioning profile (stored in GH Secrets)
  │   ├── xcrun altool → upload IPA to App Store Connect
  │   └── TestFlight external group notified automatically
  │
  └── Android
      ├── flutter build appbundle --release
      ├── Sign with upload keystore (stored in GH Secrets)
      └── fastlane supply → upload AAB to Play Console internal track
```

**What requires a new app release vs OTA:**

| Change | Requires app release? |
|---|---|
| New story / activity | No — content manifest update via R2/KV |
| New LBV verse adaptations | No — manifest update |
| Bug fix in existing game | Yes |
| New game type | Yes |
| New screen or navigation change | Yes |
| IAP product change | Yes |
| New Bible book bundle | No (download-on-demand) |

The offline-first + OTA content design means most content work ships without an App Store review cycle.

---

## MVP Scope — v1.0 vs Later

Without a scope boundary the build never ships. This table defines v1.0.

| Feature | v1.0 | v1.1 | v1.2+ |
|---|---|---|---|
| Stories (10–12 launch stories, all 3 text tiers and full review) | ✓ | | |
| Remaining reviewed stories (incremental content releases) | | ✓ | |
| Games — two activity families per age band | ✓ | | |
| Games — ColorIn (tap-to-fill illustrated coloring, crayon palette, per-story scenes) | ✓ | | |
| Games — Phase 2 (FlipMatch, WordScramble, ScenePuzzle, MoodBoard, VoiceEcho, WordFind) | | ✓ | |
| Games — Phase 2 (SpotTheDifference, WhatHappensNext) | | | ✓ |
| Games — Phase 3 (TapToBeat, VerseTyping, DrawAndTell, ShakeToReveal, HiddenObject) | | | ✓ |
| Cumulative garden + flexible weekly rhythm (no loss/reset) | ✓ | | |
| Optional non-competitive collection milestones | | ✓ | |
| Age-curated Bible navigation; full Bible only in gated Parent Mode | ✓ | | |
| Verse sharing (share card) | | ✓ | |
| Bible mode — LBV overlay for adapted verses | ✓ | | |
| Deep links (`littlebible://genesis/1/1`) | | ✓ | |
| Parent hub (weekly summary, progress per child) | ✓ | | |
| Parent conversation guidance | ✓ | | |
| Parent email digest | | | ✓ |
| Parent-controlled notifications | | | ✓ |
| Multiple child profiles | ✓ | | |
| One-time IAP unlock | ✓ | | |
| Offline-first (full bundled content) | ✓ | | |
| OTA content updates | ✓ | | |
| Lumi character (4 states) | ✓ | | |
| Admin: minimum content review/publish workflow | ✓ | | |
| Advanced analytics dashboard | | ✓ | |
| Admin: LBV licensing | | | ✓ |
| Data deletion (GDPR/COPPA) | ✓ | | |
| Resume story (continue where left off) | ✓ | | |
| Non-overlapping tiers (Early 3–5 / Emerging 6–8 / Independent 9–12) | ✓ | | |
| Parent gate + local-first consent flow | ✓ | | |
| Content sensitivity classification for every story/chapter/OTA package | ✓ | | |

**MVP principle:** pastoral and developmental quality outrank catalogue size. Ship 10–12 excellent stories and two proven activity families per band. Sharing, push, advanced analytics, licensing and the remaining story catalogue are not launch-critical. A feature enters v1.0 only when it strengthens the story → Scripture → conversation/prayer experience.

---

# Part 2 — User Stories

## Domain 0: Home Screen

---

### US-00: Home Screen Layout
**As a** child, **I want to** see a welcoming, visually clear screen when the app opens **so that** I always know what to do next without needing to read labels.

**Acceptance Criteria:**
- [ ] Given an Early Learner opens the app, then the child surface contains at most two prominent content actions: "Continue/Today's Story" and one alternative story; garden detail and verse practice appear after a session, not as competing home-screen cards
- [ ] Given an Emerging or Independent Reader opens the app, then the home screen may additionally show one due verse-practice card and one current collection row, while preserving a single obvious primary action
- [ ] Given the Early Learner tier (3–5), when the home screen renders, then each story card has a distinct illustration, a visible speaker/replay control, and an audio label; understanding never depends on colour or reading
- [ ] Given the Emerging Reader (6–8) or Independent Reader (9–12) tier, when the home screen renders, then story cards show the illustration and story title in Nunito SemiBold
- [ ] Given Lumi idle for >60 seconds with no interaction, when the timer fires, then Lumi speaks "Shall we open a story?" and gently points toward the story row — once only per session
- [ ] Given the parent hub entry, when a user long-presses Lumi for 2 seconds, then `ParentGateService` requires the parent-set PIN or verified parent authentication; successful verification expires after 5 minutes or immediately when the app backgrounds
- [ ] Given any purchase, restore, external link, system share sheet, sign-in, sync/consent setting, notification setting, profile edit, data export or deletion action, then it cannot proceed until the same parental gate succeeds
- [ ] Given a brand-new profile with no completed stories, when the home screen renders for the first time (first-run), then: no empty grid is shown; Lumi is mid-animation pointing at the first story card; the first card pulses gently with a warm glow; all other cards are visible but visually receded (80% opacity) — the child has one obvious next action
- [ ] Given the home screen's story section, when it renders, then stories are grouped by `collection` (e.g. "Meet Jesus", "God Keeps Promises") with the current collection's next unfinished story shown first as a featured card; the child sees a path, not a library grid
- [ ] Given a verse whose `nextReviewDate ≤ today`, when the older-tier home screen renders, then one optional "Verse to practise" card may appear; it never displaces Continue and is not shown as overdue
- [ ] Given the garden visualiser, when the home screen renders, then the garden widget appears bottom-left at 80×80dp; tapping expands to the full garden view which auto-dismisses after 4 seconds

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Widget | Home screen renders all 4 zones; Lumi widget is present; bottom nav has 2 icons | `flutter_test` |
| Widget | Early tier cards expose spoken labels and do not rely on text or colour; older-tier titles are visible | `flutter_test` |
| Security | Every adult action is blocked before gate success; gate expires on timeout/background; attempts are rate-limited | `flutter_test` + integration test |
| Integration | Open app; Lumi greets by name; idle 60s; Lumi speaks prompt once | `integration_test` |
| Manual | 3-year-old tester navigates to a story using only illustrations — observe without guidance | Usability test |

---

## Domain 1: Onboarding

---

### US-01: Child Profile Setup
**As a** parent, **I want to** create a local profile with a nickname, age band, and avatar **so that** the app tailors difficulty without requiring my child's identity.

**Acceptance Criteria:**
- [ ] Given first app launch, when onboarding starts, then it clearly identifies the setup as an adult task, establishes the parental gate, and asks for an optional nickname, one non-overlapping age band (Early 3–5 / Emerging 6–8 / Independent 9–12), and avatar
- [ ] Given no parent account, when setup completes, then all core stories, games and local progress work without sign-in or cloud sync
- [ ] Given name entered and age group selected, when I tap "Let's go", then a child profile is created in local Drift DB and the home screen loads with Lumi greeting the child by name
- [ ] Given profile creation, when the app is closed and reopened, then the child's profile persists and Lumi greets them by name without repeating onboarding
- [ ] Given a parent with multiple children, when they add a second child from parent hub, then a second profile is created and switchable via a profile selector on the home screen
- [ ] Given age band set to Early, when a child opens a story, then `littleText` scenes and spoken two-choice picture activities are used; written True/False and FillTheGap are not shown
- [ ] Given profile created for the first time, when the home screen loads, then Lumi runs a first-run sequence: speaks "Hi [name]! I'm Lumi. Let me show you our first story." and animates to tap the first unlocked story card — this runs once only, never on subsequent sessions
- [ ] Given Bible navigation opened, when the library renders, then only content approved for that age band is reachable; complete 66-book navigation is available only in Parent Mode behind the parental gate
- [ ] Given a parent enables cloud backup or reports, when the toggle is selected, then a just-in-time disclosure lists every uploaded data category, purpose, processor and retention period before consent; declining leaves the complete offline experience available

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `ChildProfileRepository.create()` writes correct Drift record | `flutter_test` + `mocktail` |
| Unit | `GameService.pick()` returns only age-appropriate types for each tier | `flutter_test` |
| Widget | Onboarding flow completes in 3 screens, avatar grid renders all 4 options | `flutter_test` |
| Widget | First-run flag `profile.hasSeenIntro = false` triggers Lumi intro sequence; subsequent open skips it | `flutter_test` |
| Integration | Profile persists across app restart; Lumi greeting uses saved name | `integration_test` |
| Manual | Early Learner navigates to an approved story using illustrations/audio without reading | Family usability study |

---

### US-02: Free Tier Access
**As a** new user, **I want to** access the first collection of stories and basic games for free **so that** I can evaluate the app before deciding to unlock everything.

**Acceptance Criteria:**
- [ ] Given a new profile has no unlock, then the child surface presents a complete free collection without filling the library with attractive locked cards; most paid content is discoverable only in gated Parent Hub
- [ ] Given free tier, when the child enters Bible mode, then only the free passages approved for that age band are navigable; sensitive or unreviewed passages are absent rather than displayed as tempting locks
- [ ] Given a new profile, then the first 20 stories are fully free with ALL features — story narration, Key Verse with word highlighting, all Phase 1 games (FillTheGap, TrueOrFalse, QuickQuiz, WhoseTurn), ColorIn, and Family Moment; stories 21+ show a locked card on the home screen and route to `/unlock` through the Parent Hub gate only
- [ ] Given the rare child-visible collection boundary is selected, then neutral copy says "More family stories are in Parent Hub" once per session, without Lumi, urgency, repeated prompting or direct purchase action

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `UnlockService.isUnlocked()` returns false for new profile, true after unlock | `flutter_test` |
| Widget | Child surface is not dominated by locked cards and neutral boundary copy appears at most once per session | `flutter_test` |
| Integration | Free user completes 7 stories; 8th story remains child-safe and routes purchase information through the parent gate | `integration_test` |
| Manual | Verify locked books cannot be navigated and the child experience contains no purchase pressure | Tester checklist |

---

## Domain 2: Story Experience

---

### US-03: Story Playback with TTS
**As a** child, **I want to** hear Lumi tell me a Bible story scene by scene **so that** I can follow along even if I cannot read yet.

**Acceptance Criteria:**
- [ ] Given a story opens, then narration follows the per-profile autoplay setting; visible Play/Pause, Replay, Next, Back and "Stop for now" controls are always available and progress is preserved on exit
- [ ] Given a parent disables autoplay or enables Quiet Story Mode, then no narration, automatic scene advance, ambient track or post-story game starts without a deliberate tap
- [ ] Given Lumi finishes reading a scene, when auto-advance is on, then the next scene loads after a 1.5-second pause; when off, a large "next" area is displayed
- [ ] Given the final scene completes, then a calm choice offers "Hear the Bible verse", "Talk together" and "Stop for now"; no automatic transition or mandatory funnel occurs
- [ ] Given no internet connection, when a child opens any bundled story, then playback works identically to online — TTS is platform-native and content is local

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `TtsService.speak(text, pitch, rate)` calls `flutter_tts` with correct params | `flutter_test` + mock `flutter_tts` |
| Unit | `StoryService.getScenesForProfile(storyId, ageGroup)` returns correct text tier | `flutter_test` |
| Widget | Scene text renders at Nunito 20sp SemiBold; pause/resume button responds to tap | `flutter_test` |
| Integration | Full story plays through all scenes and transitions to Key Verse screen | `integration_test` |
| Device | TTS works in airplane mode on iOS (AVSpeech) and Android (TTS engine) | Manual — physical device |

---

### US-04: The Key Verse Moment
**As a** child, **I want to** see and hear Scripture connected to the story **so that** I learn the difference between a Bible translation, a child-level adaptation and a retelling.

**Acceptance Criteria:**
- [ ] Given story scenes complete, when Key Verse screen loads, then before the verse is displayed, one line of narrative context is shown and read by Lumi (e.g. "Jesus was talking to a man who came to visit at night because he was scared of what people would think. He said…") — this comes from the story's `verseContext` JSON field and is required for every story; no story ships without it
- [ ] Given the context line read, when the verse appears, then the LBV adapted verse is displayed in Nunito Bold 22sp if it exists; otherwise WEB verse is shown in Georgia Regular 20sp with a subtle "World English Bible" label
- [ ] Given verse displayed, when the screen loads, then Lumi reads the full verse at `rate: 0.75`; each word highlights in `--lumi-gold` as it is spoken
- [ ] Given verse read, when the child taps the verse text, then Lumi reads the verse again from the beginning
- [ ] Given Key Verse screen, when the Bible reference (e.g. "Genesis 1:1") is tapped, then the app navigates to that verse in Bible navigation mode
- [ ] Given Scripture is displayed, then the source label explicitly identifies "World English Bible translation" or "Little Bible child-level adaptation"; a memory phrase is labelled "Remember in simple words" and is never presented as a direct quotation
- [ ] Given Lumi introduces divine speech, then it either reads the labelled Scripture text or says "The Bible says" with its reference; Lumi never paraphrases with "God told me/us/you"
- [ ] Given the Key Verse moment completes, when no `VerseFamiliarity` record exists, then it is created as `introduced` with a flexible 1–3 day review window; display alone never advances later recall/understanding stages

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `ContentService.getVerse()` returns LBV verse when adapted, WEB when not | `flutter_test` |
| Unit | Word-highlight timing is synchronised to `flutter_tts` word boundary callbacks | `flutter_test` |
| Widget | LBV verse renders Nunito Bold; WEB fallback renders Georgia italic; correct label shown | `flutter_test` |
| Integration | Tapping verse reference navigates to correct book/chapter/verse in Bible mode | `integration_test` |
| Manual | Verify word highlight tracks spoken word correctly on both iOS and Android | Physical device |

---

### US-03b: Resume Story
**As a** child, **I want to** continue a story I did not finish **so that** I do not have to start over every time.

**Acceptance Criteria:**
- [ ] Given a child who left a story mid-session, when the home screen renders next session, then a "Continue" card appears at the top — above the story row — showing the story's cover illustration and the scene number they stopped at (e.g. scene 3 of 5)
- [ ] Given Continue is tapped, then the story resumes at the exact scene and honours that profile's autoplay/Quiet Story Mode setting
- [ ] Given a child who completed a story, when the home screen renders, then there is no Continue card for that story; it shows the completed state (gold ring on the cover) in the story row
- [ ] Given the app closed during the Key Verse screen or game, when it reopens, then the Continue card reflects that state; tapping resumes at Key Verse or game, not the first scene

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `StoryProgressRepository.getInProgress(profileId)` returns last scene index | `flutter_test` |
| Widget | Continue card renders above story row when `inProgressStory` is non-null | `flutter_test` |
| Integration | Start story at scene 2; close app; reopen; verify Continue card shows scene 2; tap; verify resumes there | `integration_test` |
| Integration | Complete story; reopen; verify no Continue card; story shows gold ring | `integration_test` |

---

### US-03c: The Family Moment (Discuss Step)
**As a** child, **I want to** be invited to share what I learned with someone I love **so that** the story becomes a real conversation, not just something I watched.

**Acceptance Criteria:**
- [ ] Given the story or optional game ends, then one uncluttered family screen offers "Talk together", "Pray together", "Quiet moment" and "Finish"; each is optional and none affects rewards or completion
- [ ] Given a discussion prompt is chosen, then Lumi invites rather than commands: "You could talk about this with someone you trust"; no "I'm back" confirmation is required and no conversation is tracked
- [ ] Given prayer is chosen, then a parent/child may select a short written prayer, an open prompt, or silence; the pause may be skipped immediately, has no minimum duration, is never measured, and Lumi does not automatically say "Amen" on the child's behalf
- [ ] Given a prayer prompt is authored, then it may express gratitude, confession, petition, lament, trust or silence; it never promises a desired outcome or presents prayer as a formula
- [ ] Given the doToday zone, when displayed, then Lumi reads the `doToday` action as an invitation ("This week, you could…"), not a task or assignment; no completion is tracked — it is purely for the family
- [ ] Given the child taps "Finish" at any point after the story, then the session is marked complete and one predictable, score-independent garden acknowledgement may play

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | Prayer choice records no duration, transcript, completion or reward data | `flutter_test` |
| Widget | Prayer, silence, discussion and Finish are immediately selectable/skippable | `flutter_test` |
| Integration | Complete story → optionally choose/skip Family Moment → Finish → Drift `completedAt` is set identically | `integration_test` |
| Manual | Observe whether children and parents understand each option as an invitation rather than a requirement | Family usability study |

---

### US-03d: Verse Familiarity — Flexible Spaced Practice
**As a** child, **I want to** be reminded to practice a verse at the right moment **so that** I actually remember it weeks later, not just right after hearing it.

**Acceptance Criteria:**
- [ ] Given a verse whose `nextReviewDate ≤ today`, when the home screen loads, then a "Verse to practice" card appears with the verse reference and a small Lumi "thinking" thumbnail; tapping opens a single-question practice session for that verse
- [ ] Given verse practice, then `VerseFamiliarity.stage` reflects recognition, recall and meaning—not correctness alone—and no currency is awarded for spiritual text practice
- [ ] Given the child requests help or answers incorrectly, then Lumi replays context and offers support; the next practice date remains flexible and the child sees no failure/overdue state
- [ ] Given `stage = 'growing_familiar'`, then the verse remains in "My Verses" and can be revisited voluntarily; the app never claims permanent mastery of Scripture
- [ ] Given multiple verses due for review on the same day, when the home screen renders, then only one review card is shown per session — the oldest due verse; subsequent verses appear on subsequent sessions

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `SpacedRepetitionService.advance(stage)` returns correct next stage and date per schedule | `flutter_test` |
| Unit | Incorrect answer does not regress stage; `nextReviewDate` set to `today + 1` | `flutter_test` |
| Unit | Multiple verses due: only oldest is surfaced | `flutter_test` |
| Integration | Complete Key Verse screen → verify `VerseFamiliarity` is `introduced` with a valid flexible review window | `integration_test` |
| Integration | Mock date to `nextReviewDate`; verify review card appears on home screen | `integration_test` |

---

## Domain 3: Games

---

### US-05: Phase 1 Games (TrueOrFalse, FillTheGap, QuickQuiz, WhoseTurn)
**As a** child, **I want to** play a quick game about the story I just heard **so that** I remember what I learned.

**Acceptance Criteria:**
- [ ] Given Key Verse screen complete, when the game screen loads, then `GameService.pick()` selects a game type appropriate for the child's age tier that has not been used in the immediately preceding session
- [ ] Given any game, when a correct answer is tapped, then gentle haptic, icon, animation and spoken feedback confirm it; colour is never the only signal and praise describes effort or strategy rather than worth
- [ ] Given any game, when an incorrect answer is tapped, then Lumi gives an informational hint such as "Let's listen to that part again" and replays the relevant clue; no red-only state, punitive shake, deduction, shame or failure sound is used
- [ ] Given a child who has answered the same question incorrectly 3 times, when the 3rd wrong tap occurs, then Lumi gently reveals the correct answer ("The answer is [X]! That's a tricky one."), marks the question as "seen", and moves to the next question — the game never loops infinitely on a single question
- [ ] Given the active age band, when `GameService.pick()` selects a game, then it only picks from the games permitted for that tier per the table below — QuickQuiz (9 simultaneous options) is never shown to Early Learners as it exceeds their working memory capacity

**Game availability by age tier (v1.0):**

| Game | Early (3–5) | Emerging (6–8) | Independent (9–12) |
|---|---|---|---|
| TrueOrFalse | Spoken + 2 picture choices only | Full written True/False | Full |
| FillTheGap | 1 word missing, 2 large picture options | 1 word missing, 3 text options | 1 word, 3 text options |
| QuickQuiz | **Not available** — cognitive overload | 2 choices per question, 2 questions | 3 choices, 3 questions |
| WhoseTurn | Character portrait only (no spoken quote) | Quote + 3 portraits | Quote + 4 portraits |

- [ ] Given **TrueOrFalse** for Emerging or Independent Readers, when the game loads, then 3 spoken and written statements appear sequentially with labelled icon choices; for Early Learners the equivalent task uses one spoken question with two picture choices — no written text required
- [ ] Given **FillTheGap**, when the game loads, then the verse displays with one word replaced by `___`; options are shown as large buttons; correct word fills in with an animation; Early Learners see 2 picture-based options, not 3 text options
- [ ] Given **QuickQuiz** for Emerging Readers, when the game loads, then 2 questions appear one at a time with 2 answer options each; for Independent Readers, 3 questions with 3 options each
- [ ] Given **WhoseTurn**, when the game loads, then a quote from the story is spoken by Lumi and 3–4 character portraits are shown; child taps the character who said it; Early Learners see portraits only (no written quote)
- [ ] Given any story activity set, then it includes a declared learning objective and at least one task addressing sequencing, meaning, emotion/perspective or real-life application — not recall alone
- [ ] Given verse responses, then familiarity advances only from evidence across recall and meaning; one response never establishes mastery

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `GameService.pick()` never returns same type twice in a row | `flutter_test` |
| Unit | Completion acknowledgement is independent of score; no perfect-score or random reward multiplier exists | `flutter_test` |
| Widget | All 4 Phase 1 game UIs render with correct data from activity JSON | `flutter_test` |
| Widget | Multimodal success feedback fires; incorrect response gives a clue without punitive motion or colour-only meaning | `flutter_test` |
| Integration | Complete launch activity families; verify completion/help evidence is stored without score-based child ranking | `integration_test` |
| Manual | Test all 4 types in airplane mode; verify no network call is made | Physical device + Charles Proxy |

---

### US-05b: ColorIn — Tap-to-Fill Illustrated Coloring
**As a** child, **I want to** colour in an illustrated scene from the story I just heard **so that** I engage creatively with Scripture and the story stays with me.

**Specification:**
ColorIn is a structured tap-to-fill activity placed immediately after the Phase 1 games and before the Family Moment. It is modelled on the quality and style of *Lucas & Friends* and similar faith-based children's animation apps: bold outlines, large clean fill regions, a warm crayon palette, and sparkle feedback on each filled region.

**Implementation:**
- Each story has one illustrated coloring scene authored as a set of named `_Region` objects, each with a normalized `Path` built relative to the canvas `Size`
- The scene is rendered by `CustomPainter` — never raster images — so it scales perfectly to all screen sizes
- A crayon palette sidebar offers 8 colours drawn from the app's design tokens plus warm naturals: `lumiGold, coral, sky, earth, lavender, orange, pink, brown`
- Tapping the canvas hit-tests regions in reverse draw order (topmost first) using `path.contains(offset)`
- Filling a region triggers a 500ms sparkle animation overlay (`AnimationController`)
- When all regions are filled, an "All done!" banner slides in with a "Next" button → Family Moment screen
- A "Done" button in the header skips coloring at any point → Family Moment screen (no penalty)
- Coloring state is session-local and never persisted or scored

**Illustration quality standard:**
- Bold black outlines (`strokeWidth` = ~1.8% of canvas width) — same visual weight as printed colouring books
- Large, clearly bounded regions — no region smaller than ~4% of canvas area; small detail elements (bird, flower centre) may be a single tap-region even if tiny
- Scenes must tell the story visually: a viewer who has not heard the story should still recognise its key figures and setting from the illustration alone
- **No emoji anywhere in the coloring scene** — all illustration is CustomPainter vector art

**Acceptance Criteria:**
- [ ] Given a story's game flow completes, when the screen transitions to ColorIn, then the story's unique illustrated scene is shown with bold outlines and all regions unfilled
- [ ] Given the child taps a region, then it fills with the selected crayon colour and a sparkle animation plays; the palette is always visible
- [ ] Given all regions filled, when the "Next" banner appears, then tapping it navigates to the Family Moment screen
- [ ] Given the child taps "Done" at any point, then the app navigates immediately to the Family Moment screen — coloring is always optional
- [ ] Given reduced motion is enabled, then sparkle animations are replaced with an instant fill; the banner appears without slide animation
- [ ] Given any screen size, then the illustration scales correctly with no overflow or clipping, because all paths are normalized to `Size` fractions

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Widget | All regions of a story scene are reachable by tap (no dead zones); palette swatch switches selected colour | `flutter_test` |
| Widget | `_allFilled` triggers `AnimatedCrossFade` to reveal banner; "Done" header button navigates without filling | `flutter_test` |
| Integration | Complete coloring → Family Moment → home; verify `markComplete` called exactly once | `integration_test` |
| Manual | Verify illustration quality at standard and large font-scale settings on 5.5" and 6.7" phones | Physical device |

---

### US-06: Phase 2 Games (FlipMatch, WordScramble, ScenePuzzle, MoodBoard, VoiceEcho, SpotTheDifference, WhatHappensNext, WordFind)
**As a** child, **I want to** play different types of games across different sessions **so that** the app stays fresh and I keep coming back.

**Acceptance Criteria:**
- [ ] Given **FlipMatch**, when the game loads, then a 4×3 card grid is shown face-down; tapping two cards flips them; a match stays revealed highlighted in `--lumi-gold`; mismatches flip back after 1 second
- [ ] Given **ScenePuzzle**, when the game loads for an Early Learner, then 4 puzzle pieces are shown; for an Independent Reader, 12 pieces; pieces snap into place when dragged near the correct position
- [ ] Given **WordScramble**, when the game loads, then the key verse words are shown in shuffled order as draggable tiles; child drags tiles into the correct order; completed verse plays TTS
- [ ] Given **MoodBoard**, when the game loads, then "How did [character] feel?" is displayed with 4–6 emotion face options; any selection triggers a Lumi response unique to that emotion choice
- [ ] Given **VoiceEcho**, when the game loads, then Lumi speaks a short phrase (up to 6 words); a large "Echo it!" button appears; child taps to confirm they repeated it; no speech recognition required — confirmation is self-reported
- [ ] Given **WordFind**, when the game loads, then a letter grid is displayed (8×8 for Emerging, 10×10 for Independent); child swipes to highlight words and completion is conveyed with icon, animation and colour

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | FlipMatch card shuffle produces unique randomised layouts each session | `flutter_test` |
| Unit | ScenePuzzle piece count matches age tier rule | `flutter_test` |
| Widget | FlipMatch flip animation completes in <300ms; mismatch pair flips back after 1000ms | `flutter_test` (pump timers) |
| Widget | WordScramble drag-and-drop accepts drops within 20dp of target slot | `flutter_test` |
| Integration | Complete one of each Phase 2 game type; verify `activity_records` written correctly | `integration_test` |
| Performance | ScenePuzzle drag is 60fps on iPhone SE 2nd gen | Xcode Instruments / Flutter DevTools |

---

### US-07: Phase 3 Games (TapToBeat, VerseTyping, DrawAndTell, ShakeToReveal, HiddenObject)
**As an** Independent Reader (9–12), **I want to** engage with harder verse-memorisation games **so that** I retain and understand Scripture, not just repeat it once.

**Acceptance Criteria:**
- [ ] Given **VerseTyping**, when the game loads for an Independent Reader, then the verse reference is shown and a soft keyboard appears; correctness uses icons, text and optional colour, and errors receive a hint without character-by-character red marking
- [ ] Given **TapToBeat**, when Lumi begins reciting the verse, then a visual beat indicator pulses; child taps the screen in rhythm; each tap highlights the current word; final tap triggers the celebration state
- [ ] Given **DrawAndTell**, when the game loads, then a blank canvas appears with 4 colour pens (`--lumi-gold`, `--sky`, `--earth`, `--coral`) and an eraser; child draws freely; "Done" saves the drawing locally and Lumi responds with a pre-written affirming line from the story
- [ ] Given **ShakeToReveal**, when the game loads, then a verse is displayed with all words hidden as `_ _ _`; each device shake (threshold: >2.5 m/s² delta) reveals the next word with a spring animation
- [ ] Given **HiddenObject**, when the game loads, then a detailed story illustration is shown with 5 named items to find; child taps to find each; found items glow in `--lumi-gold`; completion at 5/5 triggers celebration

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `ShakeDetector` fires callback when `Accelerometer` delta exceeds threshold | `flutter_test` + mock sensors |
| Unit | `DrawingCanvas` saves bitmap to local storage path, does not write to network | `flutter_test` |
| Widget | VerseTyping validates input character-by-character; backspace clears previous | `flutter_test` |
| Integration | VerseTyping result updates `VerseFamiliarity` evidence without assigning permanent mastery from one completion | `integration_test` |
| Device | ShakeToReveal responds to physical shake on both iOS and Android | Physical device |
| Manual | DrawAndTell: verify drawing persists after navigating away and returning | Physical device |

---

## Domain 4: Bible Navigation

**Child-safety rule:** every story, chapter, verse range and OTA content package must be classified before publication for violence, death, fear, abuse, sexual content, self-harm, complex theology and developmental suitability. Early Learners receive a small curated library; Emerging Readers receive an expanded curated library with gentle context; Independent Readers receive a broader reviewed library. Parent Mode may expose the complete Bible after a parental gate. The app's store age-rating declarations must reflect the most intense content reachable in child mode.

---

### US-08: Book → Chapter → Verse Navigation
**As a** child or parent, **I want to** navigate to any book, chapter, and verse in 3 taps **so that** the app works as a real Bible, not just a storybook.

**Acceptance Criteria:**
- [ ] Given child Bible mode opens, then only passages approved for the active age band are listed; given gated Parent Mode opens, all 66 books may be listed and grouped by section with clear sensitivity context
- [ ] Given a book tapped, when the chapter grid loads, then all chapters for that book are shown as numbered buttons; visited chapters are filled in `--sky`; unvisited are outlined only
- [ ] Given a chapter tapped, when the verse grid loads, then all verses are shown as numbered buttons; verses with LBV adapted text are filled in `--lumi-gold`; WEB-only verses are white — this makes partial LBV coverage visible and desirable
- [ ] Given a verse is opened, then it displays with its translation/adaptation label and follows the profile autoplay setting; visible Play/Replay controls are always available
- [ ] Given a verse in the reader, when the "Share" button is tapped, then a verse card image is generated (verse text + reference + "Little Bible" branding) and the system share sheet is opened
- [ ] Given offline, when a child navigates to any chapter in the bundled books (NT + priority OT), then the verses load from local Drift with no network request

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `BibleRepository.getBooks(ageBand, parentMode)` never returns content above the active suitability level | `flutter_test` |
| Unit | `ContentService.getVerse()` resolves LBV before WEB; returns `isAdapted` flag correctly | `flutter_test` |
| Widget | Child library renders only curated passages; Parent Mode can render all 66 books after gate success | `flutter_test` |
| Widget | Verse grid shows `--lumi-gold` for adapted, white for WEB-only — correct for Genesis 1 | `flutter_test` |
| Integration | Navigate Genesis → Chapter 1 → Verse 1: resolves LBV text, Lumi reads, swipe goes to verse 2 | `integration_test` |
| Integration | Navigate to a non-bundled OT book offline: graceful message, no crash | `integration_test` |
| Performance | Verse grid for Psalm 119 (176 verses) renders in <200ms on target device floor | Flutter DevTools |

---

### US-09: Deep Link Navigation
**As a** parent, **I want to** send my child a link directly to a Bible verse **so that** I can direct their reading without being there.

**Acceptance Criteria:**
- [ ] Given a link `littlebible://genesis/1/1` opened on the device, when the app handles it, then the app navigates directly to Genesis Chapter 1 Verse 1 in the verse reader, bypassing the home screen
- [ ] Given a link `https://littlebible.org/genesis/1/1` opened in a browser, when the app is installed, then iOS/Android universal link handling opens the app at that verse
- [ ] Given a child-context deep link targets paid or unsuitable content, then the app returns to the age-approved library with neutral copy; purchase information exists only in gated Parent Hub
- [ ] Given the app is not installed and a web link is opened, when the browser loads `littlebible.org/genesis/1/1`, then the page shows the verse preview (title + first verse teaser) with app download links

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `GoRouter` route pattern parses `littlebible://genesis/1/1` to `{book, chapter, verse}` | `flutter_test` |
| Integration | Open deep link when app is in background; verify correct verse screen renders | `integration_test` |
| Integration | Open a child-context link to paid/unsuitable content; verify neutral return to the approved library with no purchase prompt | `integration_test` |
| Manual | Universal links work on both iOS (Associated Domains) and Android (App Links) | Physical device — both platforms |

---

## Domain 5: Progress & Rewards

---

### US-10: Cumulative Garden and Weekly Rhythm
**As a** child, **I want to** grow a garden through a flexible weekly learning rhythm **so that** practice feels encouraging without punishment for missed days.

**Acceptance Criteria:**
- [ ] Given a story, reflection or optional game is completed, then one predictable garden-growth acknowledgement appears; it does not vary by score, speed, prayer, consecutive attendance or chance
- [ ] Given a child completes a story or reflection, then the garden grows; progress is based on up to 3 learning days per week and never requires consecutive-day attendance
- [ ] Given a child misses any number of days, then no flower wilts, disappears or resets and Lumi makes no guilt-based comment; the next session begins with a normal welcome
- [ ] Given cumulative participation reaches an optional collection milestone, then a simple new plant/scene becomes available; no leaderboard, rarity pressure, perfect-score bonus or sibling comparison is used
- [ ] Given 3 learning days are completed in a week, then a quiet garden milestone appears; an optional parent notification uses privacy-safe copy without child name or score

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `GardenGrowthService.recordMeaningfulSession()` adds one bounded growth unit independent of score and never removes units | `flutter_test` |
| Unit | `WeeklyRhythmService.recordLearningDay()` counts at most one learning day per date and caps the weekly goal at 3 | `flutter_test` |
| Unit | Any missed-day interval preserves all garden progress and emits no loss state | `flutter_test` |
| Widget | Predictable garden acknowledgement plays once and respects reduced-motion settings | `flutter_test` |
| Integration | Complete learning on 3 non-consecutive days; verify weekly milestone and persistent garden progress | `integration_test` |
| Integration | Reach a collection milestone through varied activities; verify no score/perfection field affects it | `integration_test` |

---

## Domain 6: Offline

---

### US-11: Full Offline Operation
**As a** child, **I want to** use the app without internet **so that** I can read Bible stories anywhere — on a plane, in a car, or in a home without reliable Wi-Fi.

**Acceptance Criteria:**
- [ ] Given the app is installed, when offline, then all 10–12 launch stories, launch activity families, curated verses, optional TTS and local progress work without a first online launch or account
- [ ] Given offline, when a child completes a story, then progress is written to local Drift and queued in `sync_queue`; no error is shown; the complete screen displays normally
- [ ] Given reconnection after offline session, when the app comes to foreground, then `SyncService` drains the `sync_queue` in the background; no user action required; a subtle "Progress saved" toast appears only if >1 session was pending
- [ ] Given new content available on the server, when the device reconnects and the manifest is checked, then new stories download silently in the background; a "2 new stories are ready!" banner appears after download completes — never during an active session
- [ ] Given a child attempting to access a non-bundled book (OT beyond the bundled set) offline, when the chapter grid loads, then chapters show a download-required indicator; tapping shows "Connect to Wi-Fi to download [Book Name]" — no crash, no blank screen

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `SyncService.drain()` is a no-op when `sync_queue` is empty | `flutter_test` |
| Unit | `ContentUpdateService.checkManifest()` does nothing when offline (network error caught silently) | `flutter_test` + mock Dio |
| Integration | Enable airplane mode mid-session; complete story; reconnect; verify `sync_queue` entry is sent and marked `syncedAt` | `integration_test` |
| Integration | Clear local DB; open app offline; verify bundled content loads from assets | `integration_test` |
| Device | Full regression: complete 3 stories end-to-end in airplane mode on physical iOS + Android device | Manual — physical devices |
| Network | Use Charles Proxy to confirm zero API calls during active offline session | Charles Proxy |

---

### US-12: Content Updates
**As a** parent, **I want** new stories to appear in the app automatically **so that** my child always has fresh content without needing to manually update the app.

**Acceptance Criteria:**
- [ ] Given the app connects to the internet, when `ContentUpdateService.checkManifest()` runs, then it compares the local `content_version` with `/api/mobile/manifest`; if versions differ, download begins
- [ ] Given a content download in progress, when a child is actively in a story session, then the download does not interrupt the session — it queues behind the active session
- [ ] Given a download completing, when the new story JSON is fully written to Drift, then the home screen's story grid updates to show the new story without requiring an app restart
- [ ] Given a download failing (partial), when the app checks the manifest next time, then the incomplete content is detected and re-downloaded cleanly

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `ManifestDiff.compute(local, remote)` returns correct list of new/updated story IDs | `flutter_test` |
| Unit | `ContentDownloader.download(storyId)` rolls back Drift write on partial failure | `flutter_test` |
| Integration | Mock manifest response with 1 new story; verify Drift row inserted and story appears in UI | `integration_test` + mock server |
| Integration | Kill app mid-download; reopen; verify re-download completes cleanly | `integration_test` |

---

## Domain 7: Parent Hub

---

### US-13: Parent Weekly Summary
**As a** parent, **I want to** see what my child has been doing in the app **so that** I can encourage them and stay connected to their learning.

**Acceptance Criteria:**
- [ ] Given Parent Hub opens through `ParentGateService`, then the primary weekly card shows: what the child heard, one open-ended conversation prompt, one misconception to listen for, one short optional family prayer, one optional family action and any sensitive-content context; frequency metrics are secondary
- [ ] Given progress is shown, then it uses stories explored and broad learning topics without score, rank, streak, spiritual-worth inference or sibling comparison by default
- [ ] Given multiple children on one account, when the parent hub loads, then each child's summary is shown separately with a tab or scroll per child
- [ ] Given parent hub, when "Share this week" is tapped, then a second parental-gate check precedes a preview; the default card omits child name, score and detailed history, and the system share sheet opens only after explicit confirmation
- [ ] Given parent backend sync is active, when the parent hub loads, then it reflects the most recent synced progress; a "Last synced X minutes ago" label is shown; stale data (>24 hours) shows a "Sync pending" indicator
- [ ] Given Parent Hub settings, then the parent can configure per profile: content preview/approval, sensitivity threshold, complete-Bible access, maximum session reminder, autoplay, TTS speed, Quiet Story Mode, ambient/music/effects, reduced rewards/motion, notifications, Wi-Fi-only downloads, cloud sync, sharing and profile deletion
- [ ] Given multiple children use one device, then the selector uses neutral avatars, exposes no score/activity comparison, preserves per-profile accessibility/content settings, and permits an optional child PIN only for older children
- [ ] Given a parent deletes one child profile, then only that profile's local and consented cloud data is deleted; the parent account and sibling profiles remain intact

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `ParentReportService.weekSummary(profileId)` produces formation guidance and secondary non-comparative activity context | `flutter_test` |
| Widget | Weekly summary renders correctly with 0 stories (new child) and with 7 stories | `flutter_test` |
| Integration | Complete stories; verify Parent Hub displays correct topics, conversation prompt, prayer and family action without scores | `integration_test` |
| Manual | Share card generates correctly on both iOS and Android share sheet | Physical device |

---

### US-14: Parent Email Digest
**As a** parent, **I want to** receive a weekly email summary of my child's activity **so that** I know what they are learning even when I am not checking the app.

**Acceptance Criteria:**
- [ ] Given a verified parent has explicitly enabled sync and email digest, when the scheduled digest runs, then it uses the child's parent-chosen nickname only if separately enabled; otherwise it says "your learner" and reports broad topics and weekly rhythm rather than granular scores
- [ ] Given multiple children on one account, when the digest sends, then all children's summaries are in a single email — not one email per child
- [ ] Given a parent who has not signed in with Google (offline-only usage), when the digest would send, then no email is sent — no error, no silent failure
- [ ] Given a parent who opts out in settings, when the digest would send, then no email is sent and the opt-out preference persists across app reinstalls (stored in backend, not just locally)

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `DigestWorker` Cloudflare Cron trigger fires at correct time and skips profiles with no email | Vitest + CF Workers test env |
| Unit | ZeptoMail `sendEmail()` is NOT called if parent has opted out (`User.wantsEmail = false`) | Vitest |
| Integration | Create test account, complete 2 stories, trigger digest manually; verify email received with correct data | Manual + ZeptoMail test token |
| Integration | Opt out in app; trigger digest; verify ZeptoMail `sendEmail()` is not called | `integration_test` + mock API |

---

### US-14b: Push Notifications
**As a** parent, **I want to** receive a push notification when my child hits a milestone **so that** I can celebrate with them even when I am not watching.

**Acceptance Criteria:**
- [ ] Given onboarding completes, then notification permission is not requested automatically; a parent may enable it later from gated Parent Hub after a plain-language explanation
- [ ] Given notification permission granted, when a weekly learning milestone occurs, then lock-screen copy contains no child name, score, verse history or sensitive detail (for example, "A learning milestone is ready to celebrate")
- [ ] Given notification permission is granted, then only parent-chosen weekly reminders or important account/content notices may fire; game rewards do not trigger push notifications
- [ ] Given a parent who has denied notification permission, when any milestone fires, then the notification is silently skipped — no retry, no in-app nag
- [ ] Given a parent who opts out of notifications in app settings, when any milestone fires, then `User.wantsNotifications = false` prevents the push — preference persists via backend sync
- [ ] Given the notification tapped by the parent, when the app opens, then it navigates directly to the parent hub for the relevant child — not the home screen

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `NotificationService.requestPermission()` fires at correct point in onboarding, not during child play | `flutter_test` |
| Unit | Milestone trigger with `wantsNotifications = false`: `NotificationService.send()` not called | `flutter_test` |
| Integration | Complete weekly rhythm; verify optional privacy-safe parent notification fires | `integration_test` + `flutter_local_notifications` |
| Manual | Tap notification; verify navigates to parent hub, not home | Physical device |
| Manual | Deny permission at OS level; complete weekly rhythm; verify no notification or nag | Physical device |

---

### US-14c: Data Deletion & Account Export (GDPR/COPPA)
**As a** parent, **I want to** delete my account and all associated data permanently **so that** I can exercise my legal rights and my child's rights under COPPA and GDPR.

**Acceptance Criteria:**
- [ ] Given a parent in account settings, when "Delete account and all data" is tapped, then a confirmation modal explains exactly what will be deleted: "Your account, all child profiles, all progress records, and all sync data will be permanently deleted. This cannot be undone." — requires typing "DELETE" to confirm
- [ ] Given confirmation submitted, when the deletion runs, then: all D1 records for `User`, `Account`, `Session`, `UserProgress`, `ActivityRecord`, `MemoryVerseProgress`, `AnalyticsEvent` for this user are deleted; local Drift DB is wiped; the app returns to the onboarding screen
- [ ] Given a parent withdraws cloud-sync consent without deleting the local profile, then uploads stop immediately, previously synced child data is deleted, and the offline experience continues
- [ ] Given deletion requested, when it processes, then a ZeptoMail confirmation email is sent to the parent's email: "Your Little Bible account and all associated data have been permanently deleted."
- [ ] Given a parent emailing support to request data deletion (for users who cannot access the app), when the request is received, then an admin can trigger deletion from the admin app's user management screen — the deletion runs the same code path as the in-app flow
- [ ] Given an `ANALYTICS_VIEWER`-only admin, when they view user management, then the delete button is not visible — only `SUPER_ADMIN` can trigger manual deletions

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | Deletion endpoint deletes all D1 rows for the user in a single transaction | Vitest |
| Unit | Deletion wipes local Drift and clears `SecureStorage` auth tokens | `flutter_test` |
| Integration | Create account → complete 3 stories → delete account → verify all D1 rows gone → verify local DB empty | `integration_test` + CF Workers local dev |
| Integration | Admin-triggered deletion from user management: same D1 rows deleted | CF Workers local dev |
| Manual | After deletion, app opens to onboarding screen with no traces of previous profile | Physical device |

---

## Domain 8: Unlock (IAP)

---

### US-15: One-Time Unlock via IAP
**As a** parent, **I want to** make one clearly priced, one-time purchase to unlock the complete age-appropriate library **so that** the commercial exchange is transparent and restorable.

**Acceptance Criteria:**
- [ ] Given a locked item routes a parent to Parent Hub, when `ParentGateService` succeeds, then the screen is titled "Unlock the Complete Little Bible" and shows one fixed local price, what is included, that it is a non-consumable one-time purchase, and a visible "Restore Purchase" action
- [ ] Given "Purchase" is tapped, when the platform billing flow launches, then Apple In-App Purchase or Google Play Billing is used and no payment data is handled by the app
- [ ] Given IAP completing successfully, when the receipt is validated, then `UnlockService.unlock()` is called immediately, `child_profiles.isUnlocked` is set to true in local Drift, and all locked content becomes accessible without app restart
- [ ] Given "Restore purchases" tapped, when `in_app_purchase.restorePurchases()` completes, then any prior purchase is recognised and the unlock is applied — critical for device changes and reinstalls
- [ ] Given IAP completion, when the app is offline at time of IAP success, then the unlock is applied locally first; the backend sync is queued and sent on next connection
- [ ] Given the app is reviewed or license-tested, then store sandbox/license-test facilities or a server entitlement on a dedicated review account are used; the production app contains no public promo code, license key or app-owned paid-content bypass
- [ ] Given optional tips are introduced later, then they are separate consumable IAP products that confer no content, reward, advantage or child-facing recognition

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `UnlockService.unlock()` sets `isUnlocked = true` in Drift and enqueues `SyncEntry { operation: 'unlock' }` | `flutter_test` |
| Unit | `UnlockService.isUnlocked()` reads from local Drift only — never calls network | `flutter_test` |
| Widget | Unlock screen is inaccessible before parent-gate success and renders one clear non-consumable product and restore action | `flutter_test` |
| Integration | Mock successful IAP; verify `isUnlocked` set; verify previously locked story is now accessible | `integration_test` + mock `in_app_purchase` |
| Integration | Mock restore flow; verify prior purchase restores correctly | `integration_test` + mock `in_app_purchase` |
| Manual | End-to-end real IAP on TestFlight ($0.99 test product); verify full unlock on iOS | TestFlight |
| Manual | End-to-end real IAP on Play internal track; verify on Android | Play internal track |

---

### US-16: IAP Receipt Validation (Backend)
**As a** system, **I want to** validate IAP receipts server-side **so that** the unlock cannot be bypassed by intercepting local calls.

**Acceptance Criteria:**
- [ ] Given an iOS IAP success, when the app sends signed transaction data to `/api/mobile/unlock`, then the Worker validates it with current StoreKit 2/App Store Server API mechanisms, verifies bundle ID, product ID, environment, ownership and revocation state, and grants only `com.littlebible.unlock`
- [ ] Given a Google Play purchase, when the purchase token is sent to `/api/mobile/unlock`, then the Worker validates with Google Play Developer API before setting `User.unlocked = true` in D1
- [ ] Given a validation failure (tampered receipt), when the Worker receives it, then it returns 403 and logs the attempt in `AdminAuditLog`
- [ ] Given unlock confirmed, when the Worker writes to D1, then the response includes a signed token the app stores for restore flows on new devices

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | Worker calls Apple API with receipt; mock Apple 200 → sets D1 `User.unlocked = true` | Vitest + CF Workers test env |
| Unit | Mock Apple rejection → returns 403, logs audit entry | Vitest |
| Unit | Worker calls Google Play API with purchase token; mock success/failure paths | Vitest |
| Security | Replay the same non-consumable transaction for a different account; verify idempotent handling and no duplicate/cross-account entitlement | Manual + Postman |
| Security | Send a malformed receipt; verify 403 with no sensitive data in error response | Manual + Postman |

---

## Domain 9: Admin — Dashboard & Analytics

---

### US-17: Admin Dashboard
**As an** admin, **I want to** see the key health metrics of the platform on a single screen **so that** I know immediately whether Little Bible is healthy and growing.

**Acceptance Criteria:**
- [ ] Given admin loads `/admin`, then safeguarding/content-review status, crash health, deletion/consent failures and pending reviews appear before commercial metrics; only privacy-thresholded aggregates are shown
- [ ] Given pending content reviews > 0, when the dashboard loads, then a highlighted alert count links directly to the review queue — it is never buried
- [ ] Given the sync queue depth exceeding 1,000 unsynced entries, when the dashboard loads, then a warning indicator is shown with a link to the system health view
- [ ] Given an `ANALYTICS_VIEWER` role, when they access `/admin`, then they see the dashboard and analytics sections only; content management and user management tabs are hidden

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | Dashboard API `/api/admin/dashboard` returns correct aggregated metrics from D1 | Vitest |
| Unit | ANALYTICS_VIEWER role cannot access `/api/admin/users` — returns 403 | Vitest |
| Integration | Seed 100 analytics events; verify dashboard sparklines reflect correct counts | CF Workers local dev + D1 |
| Manual | Verify role-based tab visibility for each of the 6 admin roles | Manual — create test accounts per role |

---

### US-18: Content Performance Analytics
**As a** content editor, **I want to** see which stories children complete and which games they abandon **so that** I know what to improve.

**Acceptance Criteria:**
- [ ] Given privacy-thresholded analytics are available, then they show aggregate starts, voluntary completions, help requests and exits; no child-level timeline, average child score, religious-engagement ranking or identifiable cohort is created
- [ ] Given the game abandonment table, when it loads, then it shows each game type with: times started, times completed, abandonment rate — sorted by abandonment rate descending; types above 40% abandonment are highlighted as needing investigation
- [ ] Given a session journey is displayed, then optional choices are not treated as funnel failures: stopping after a story, skipping a game or declining prayer is a valid completion state
- [ ] Given any chart, when a data point is hovered (desktop) or tapped (mobile), then an exact figure tooltip appears
- [ ] Given filtering by date range, when a 7-day, 30-day, or custom range is selected, then all charts update to reflect only that period

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `/api/admin/analytics/stories` groups and aggregates `AnalyticsEvent` rows correctly | Vitest |
| Unit | `/api/admin/analytics/journey` treats valid optional exits separately from errors and abandonment | Vitest |
| Integration | Insert privacy-safe aggregate events; verify valid optional exits are separated from errors and small cohorts are suppressed | CF Workers local dev |
| Manual | Test date range filter: verify 7-day chart matches 7 days of known data | Manual |

---

## Domain 10: Admin — Content Management

---

### US-19: Story Creation & Review Workflow
**As a** content editor, **I want to** create and submit a new story for theological review **so that** content is checked before children see it.

**Acceptance Criteria:**
- [ ] Given a content editor selects "New content", then the form first requires genre, original-context summary, whole-Bible connection, doctrinal/disputed-issue flags, learning objective and sensitivity tier; it then shows the genre-specific beats plus read, discuss, optional prayer, remember and family-action fields
- [ ] Given a form field violating Translation Charter rules (word too long, forbidden vocabulary), when the field loses focus, then an inline validation error appears with the specific rule violated and a suggested correction
- [ ] Given the story form complete, when "Submit for review" is clicked, then a `ContentReview` record is created with `status: 'in-review'`, and all accounts with `THEOLOGICAL_REVIEWER` role receive an email notification
- [ ] Given a reviewer opens content, then source translation, LBV adaptation, retelling and memory phrase are distinctly labelled alongside original-context, canonical-connection, age/sensitivity and disputed-doctrine fields; approval or revision requires a comment
- [ ] Given content is materially changed, then author, theological reviewer, Christian-education reviewer and safeguarding reviewer are distinct where required; final publication needs recorded approvals and produces an auditable version with rollback before R2/KV publication

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `TranslationChartValidator.validate(field, value)` returns correct errors for known violations | Vitest |
| Unit | Story publish writes to R2 and invalidates KV manifest key | Vitest + R2/KV mocks |
| Integration | Create story → submit → reviewer approves → publish; verify it appears in `/api/mobile/manifest` response | CF Workers local dev |
| Integration | Submit story with forbidden word; verify error shown; verify record NOT created in DB | CF Workers local dev |
| Manual | Full workflow end-to-end with three accounts (editor, reviewer, manager) | Manual — 3 test accounts |

---

### US-20: LBV Verse Editor
**As a** content editor, **I want to** adapt individual Bible verses to LBV standard within the admin app **so that** the Bible navigation mode serves child-appropriate language chapter by chapter.

**Acceptance Criteria:**
- [ ] Given a chapter opened in the LBV editor, when it loads, then every verse is shown in a 3-column layout: KJV text | current LBV adaptation (editable textarea) | WEB text (read-only reference); adapted verses are highlighted in `--lumi-gold`
- [ ] Given an adaptation typed, when the textarea loses focus, then inline validation runs: word count vs limit, forbidden vocabulary check, doctrinal flags; errors are shown inline without blocking save
- [ ] Given "Save draft" clicked, when saved, then the adaptation is stored with `status: draft` — not yet visible to app users
- [ ] Given a draft submitted for review, when a `THEOLOGICAL_REVIEWER` approves, then the verse is published to the `verses` table in D1 with `source: 'little-bible'` and `isAdapted: true`; it appears in the mobile app at the next manifest check

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | Verse adaptation save writes to D1 with correct `source`, `isAdapted`, `status` fields | Vitest |
| Unit | Publish updates D1 `verses` row AND invalidates mobile content manifest in KV | Vitest |
| Integration | Adapt Genesis 1:1 → submit → approve → verify mobile `ContentService.getVerse()` returns LBV text | CF Workers local dev + Flutter integration test |
| Manual | Adapt 10 verses in one session; verify all save correctly; verify reviewer notification sent | Manual |

---

## Domain 11: Admin — LBV Licensing

---

### US-21: Publisher API Key Management
**As a** super admin, **I want to** issue and manage API keys for licensed Bible apps **so that** they can integrate the LBV text according to their license agreement.

**Acceptance Criteria:**
- [ ] Given super admin on the licensing page, when "Create key" is clicked, then inputs are: licensee name, license tier (Ministry / Publisher / Print), expiry date (required), and canary variant seed (auto-generated, overridable); the key is generated and shown once — it cannot be retrieved again
- [ ] Given an active key, when the usage table loads, then it shows: requests this month, unique stories accessed, rate limit hits, last used timestamp
- [ ] Given "Revoke" clicked on an active key, when confirmed, then the key is immediately invalid (CF KV cache cleared for that key), the action is logged in `AdminAuditLog` with admin ID and timestamp, and the licensee receives an email notification
- [ ] Given a request using a licensed key, when the key is valid, then the content response includes the licensee's unique canary variant text (one subtle phrasing difference per story, consistent per key)

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | Revoked key returns 403 within 1 second of revocation (KV cache cleared, not just DB) | Vitest + KV mock |
| Unit | Canary variant is deterministic for a given `(keyId, storyId)` pair — same key always gets same variant | Vitest |
| Integration | Create key → make request → verify canary variant in response; revoke → make request → verify 403 | CF Workers local dev |
| Security | Attempt to use a valid key from a different tier to access publisher-only content — verify 403 | Postman |

---

## Domain 12: System & Infrastructure

---

### US-22: Progress Sync Reliability
**As the** system, **I want** mobile progress sync to be reliable even on poor connections **so that** children's progress is never lost.

**Acceptance Criteria:**
- [ ] Given a progress sync POST to `/api/mobile/progress`, when the Worker receives it, then it performs an upsert (not insert) for each progress record — duplicate submissions from retrying clients are idempotent
- [ ] Given the sync POST timing out (>10 seconds), when the app detects the timeout, then it retries with exponential backoff: 30s, 2m, 10m, 30m; the entry remains in `sync_queue` until `syncedAt` is set
- [ ] Given sync failing for >24 hours, when the app foregrounds, then a subtle "Progress not yet saved to cloud" indicator is shown in the parent hub — not to the child
- [ ] Given batch sync of 50+ queued entries (very long offline period), when the POST is made, then the Worker processes the batch in a single D1 transaction to avoid partial writes
- [ ] Given iOS, when `SyncService` is initialised, then it registers a `BGAppRefreshTask` with identifier `org.littlebible.sync`; iOS will schedule the task at system-appropriate intervals (typically every 15 min when conditions allow) — **do not rely on a foreground-only "online event" trigger for iOS**, as apps in the suspended state receive no network events without this registration
- [ ] Given Android, when the app enters the background, then `WorkManager` schedules a `OneTimeWorkRequest` with `NetworkType.CONNECTED` constraint to drain the sync queue — this replaces any foreground-only sync trigger

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | Sending duplicate progress entry twice: D1 upsert produces one record, not two | Vitest |
| Unit | Exponential backoff timer fires at correct intervals | `flutter_test` (fake timers) |
| Integration | Send 100 queued entries in one batch; verify all 100 written atomically to D1 | Vitest + D1 local |
| Network | Simulate 50% packet loss with Charles Proxy; verify sync completes eventually, no data lost | Charles Proxy + physical device |
| Load | 10,000 concurrent sync requests to Worker; verify D1 write throughput within limits | k6 load test |

---

### US-23: Content Delivery via R2
**As the** system, **I want** story content and audio files served from CF R2 **so that** there are no egress fees and content loads fast globally.

**Acceptance Criteria:**
- [ ] Given a mobile client downloading a new story, when `ContentUpdateService` fetches it, then the request goes to a signed R2 URL (served via CF Worker), not a Workers response body — Workers never stream large content payloads
- [ ] Given audio files for pre-generated TTS stored in R2, when a `VerseReaderScreen` requests audio, then it streams from the R2 URL with CF's edge caching active (Cache-Control: public, max-age=31536000)
- [ ] Given content in R2, when the story JSON is updated (new version published), then the old R2 URL returns a 404 and the new URL is reflected in the KV manifest within 30 seconds
- [ ] Given CF Workers serving the manifest, when a KV write occurs, then the Workers response reflects the update within 60 seconds (KV eventual consistency SLA)

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Unit | `ContentDeliveryService.getStoryUrl(storyId)` returns R2-origin URL, not a Workers data URL | Vitest |
| Unit | Published story updates KV manifest key atomically with R2 upload | Vitest + R2/KV mocks |
| Integration | Upload story to R2; publish manifest; fetch manifest; verify URL resolves to correct content | CF Workers local dev |
| Performance | 1,000 concurrent R2 reads; verify p95 latency < 200ms | k6 |

---

## Domain 13: App Release — iOS & Android

---

### US-24: iOS Build Pipeline (GitHub Actions)
**As a** developer, **I want** every push to a `release/*` branch to automatically build and upload a signed IPA to TestFlight **so that** testers always have the latest build without manual Xcode intervention.

**Acceptance Criteria:**
- [ ] Given a push to `release/x.y.z`, when the `ios-release.yml` workflow triggers, then it runs `flutter test`, then `flutter build ipa --release --export-options-plist ExportOptions.plist`, signs with the Distribution certificate stored in GitHub Secrets, and uploads via `xcrun altool` — all within 25 minutes
- [ ] Given a signing failure (expired cert, missing provisioning profile), when the workflow runs, then it fails with a clear error message naming the specific missing secret; the IPA is never uploaded
- [ ] Given a successful upload, when App Store Connect receives it, then the build appears in TestFlight's "Processing" state within 10 minutes and is automatically added to the `internal-testers` group once processing completes
- [ ] Given any `flutter test` failure, when the workflow runs, then the build step is skipped — a broken build never reaches TestFlight

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Pipeline | Push to `release/1.0.0`; verify workflow runs and IPA appears in TestFlight | GitHub Actions + App Store Connect |
| Pipeline | Break a unit test; push to release branch; verify workflow halts before build | GitHub Actions |
| Pipeline | Expire test cert in Secrets; push; verify clear failure message, no partial upload | GitHub Actions |
| Manual | Confirm internal testers receive TestFlight notification email within 30 min | TestFlight — internal group |

---

### US-25: Android Build Pipeline (GitHub Actions)
**As a** developer, **I want** every push to a `release/*` branch to automatically build and upload a signed AAB to the Play Console internal testing track **so that** Android testers can sideload the latest build immediately.

**Acceptance Criteria:**
- [ ] Given a push to `release/x.y.z`, when the `android-release.yml` workflow triggers, then it runs `flutter test`, then `flutter build appbundle --release`, signs the AAB with the upload keystore stored in GitHub Secrets (`KEYSTORE_JKS_BASE64`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD`), and uploads via `fastlane supply` to the `internal` track
- [ ] Given a successful upload, when Play Console receives it, then the build is available to internal testers within 5 minutes (no review required for internal track)
- [ ] Given `versionCode` not incremented before the push, when `fastlane supply` uploads, then it fails with an explicit error — Play Console rejects duplicate version codes
- [ ] Given the `internal` track upload succeeding, when a `CURRICULUM_MANAGER` (or developer) manually promotes it in Play Console, then it moves to `closed testing` track, then `open testing`, then `production` — each promotion is a manual step, not automated

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Pipeline | Push to `release/1.0.0`; verify AAB appears on Play Console internal track | GitHub Actions + Play Console |
| Pipeline | Push with duplicate versionCode; verify `fastlane supply` fails before upload | GitHub Actions |
| Pipeline | Break a unit test; verify workflow halts before build | GitHub Actions |
| Manual | Internal tester downloads from Play Console internal track on Android device | Physical Android device |

---

### US-26: App Store Connect Setup & Kids Category
**As a** developer, **I want** the iOS app configured correctly in App Store Connect — especially for the Kids category — **so that** Apple's review team approves the submission and the app reaches the correct audience.

**Acceptance Criteria:**
- [ ] Given App Store Connect app record created, when metadata is configured, then an accurate primary category (Books or Education) is selected separately from the Made for Kids age category; the team accepts that Kids Category obligations continue for subsequent updates
- [ ] Given the Kids category selected, when the privacy policy URL is set, then it points to `https://littlebible.org/privacy` — required for all Kids category apps; Apple rejects without it
- [ ] Given the privacy nutrition label, when completed from the versioned data inventory, then it accurately declares parent email/account identifiers, purchases, product interaction/progress, analytics and diagnostics that leave the device, including third-party SDK practices; no tracking or data sale is used
- [ ] Given the age-rating questionnaire, when completed against the final reachable content, then violence, death, fear, mature themes, sharing, purchases and controls are answered accurately; the team accepts Apple's calculated regional ratings instead of pre-asserting 4+
- [ ] Given Made for Kids is selected, when the age range is chosen, then it matches the final design and is approved as an effectively enduring product decision before first submission
- [ ] Given Apple review needs access, when review notes are submitted, then dedicated non-personal review credentials and sandbox/server entitlement are supplied; no employee's personal Google account is shared
- [ ] Given screenshots are uploaded, then the current required display sizes shown in App Store Connect at submission time are supplied and represent the real child experience, parental gate and purchase disclosure

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Manual | Verify privacy policy URL resolves correctly from App Store Connect link | Browser |
| Manual | Reconcile the final content-sensitivity inventory with every age-rating answer and document the resulting regional ratings | App Store Connect |
| Manual | Validate screenshots against the device-size requirements currently displayed in App Store Connect | App Store Connect + Preview |
| Manual | Provide demo account credentials to Apple review team in review notes | App Store Connect |

---

### US-27: Play Store Setup & Families Policies
**As a** developer, **I want** the Android app and Play Console declarations to satisfy current Families policies **so that** children receive a safe experience and the listing is accurate.

**Acceptance Criteria:**
- [ ] Given Play Console setup, when Target Audience and Content is completed, then every genuinely designed-for age group spanning 3–12 is selected and the app, listing and IARC answers support those selections; eligibility for Teacher Approved is optional and never promised
- [ ] Given the Families declaration, then no advertising SDK is included; AAID and prohibited identifiers are not accessed or transmitted; permissions and every SDK are audited for child-directed use; adult actions protect purchases, sharing, external links and account/settings areas
- [ ] Given Data Safety is completed, then name/nickname (if transmitted), parent account data, purchase history, app interactions/progress, analytics and diagnostics are declared from the versioned data inventory, including all processors
- [ ] Given the Play Store listing, when it is completed, then the short description is ≤80 characters, the full description explains the age range and parent control model, and at least 2 screenshots show the child experience and 1 shows the parent hub
- [ ] Given the content rating for the app, when submitted, then it declares no user-generated content (drawings via DrawAndTell are stored locally, not shared to any community)
- [ ] Given the listing is drafted, then keywords are accurate and natural; search rank is monitored as a business metric, not stated as a guaranteed acceptance criterion

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Manual | Walk the current Families policies, Target Audience, Data Safety and SDK inventory against the exact release AAB | Manual checklist + Play SDK Index |
| Manual | Install release build from Play internal track; confirm no third-party SDK network calls | Charles Proxy + release build |
| Manual | Compare every Play Console declaration with observed release-build network traffic and stored data | Manual + proxy + backend audit |

---

### US-28: TestFlight Beta Programme (iOS)
**As a** developer, **I want** to run a structured TestFlight beta before App Store submission **so that** real families find issues before the public launch.

**Acceptance Criteria:**
- [ ] Given the first stable build uploaded, when the internal testing phase begins, then the internal group (up to 25 testers: developers, content editors, theological reviewers) has access within 30 minutes of processing; no App Store review required for internal group
- [ ] Given internal testing passing, when external beta begins, then up to 200 external testers (parents with children aged 3–12 from the target audience) are invited via TestFlight public link; Apple reviews external builds (typically 1–2 days)
- [ ] Given an external tester reports a crash, when the privacy-reviewed, scrubbed diagnostics event is received, then it is triaged within 24 hours; no child/profile data is attached
- [ ] Given external beta running for 2 weeks minimum, when the beta exit criteria are met, then the build is submitted for App Store review; exit criteria: zero P0 crashes in last 7 days, IAP flow verified by 5+ testers, offline mode verified on 3+ device models
- [ ] Given beta testers, when they test IAP, then Apple's Sandbox environment is used — no real charges; testers must have a Sandbox Apple ID configured

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Manual | Invite 5 internal testers; verify they can install and complete a full story | TestFlight |
| Manual | Simulate a crash; verify the selected diagnostics service symbolicates it and transmits none of the prohibited test identifiers or content | Privacy-reviewed diagnostics service |
| Manual | IAP in Sandbox: complete purchase flow with Sandbox Apple ID; verify unlock granted | TestFlight + Sandbox |
| Manual | Test offline mode: install on device, enable airplane mode, complete 3 stories end-to-end | Physical device |

---

### US-29: App Store Production Release (iOS)
**As a** developer, **I want** to submit the app for App Store review and release to production with a phased rollout **so that** any issues surfacing in the real world affect a small percentage of users first.

**Acceptance Criteria:**
- [ ] Given beta exit criteria met, when submitted, then privacy answers, dedicated review credentials, IAP and content-rating answers are complete; export-compliance answers are determined from actual TLS/platform cryptography and current Apple guidance rather than assuming "No"
- [ ] Given App Store review approved (typically 1–3 business days), when the release is set to phased rollout, then the rollout schedule is: Day 1 → 1%, Day 3 → 5%, Day 7 → 10%, Day 14 → 25%, Day 21 → 50%, Day 28 → 100%
- [ ] Given a P0 crash rate >1% is detected by the privacy-reviewed diagnostics service, then the release is paused and fixed before resuming
- [ ] Given version 1.0 is live, then its selected primary category and Made for Kids age category display as configured; discoverability keywords are monitored without promising a search position
- [ ] Given the 1.0 release live, when version 1.1 is ready (new stories or fixes), then the pipeline in US-24 produces the build, it is uploaded, and App Store review is submitted — the phased rollout repeats for each release

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Manual | Complete App Store Connect submission checklist item by item before clicking Submit | App Store Connect |
| Manual | Monitor privacy-reviewed crash-free sessions daily during phased rollout; pause if <99% | Diagnostics dashboard |
| Manual | Search App Store for "little bible" 48 hours after release; verify app is indexed | App Store on device |
| Manual | Verify phased rollout percentage updates on schedule in App Store Connect | App Store Connect |

---

### US-30: Play Store Production Release (Android)
**As a** developer, **I want** to promote the Android app from closed testing to production with a staged rollout **so that** the same risk mitigation applied on iOS applies on Android.

**Acceptance Criteria:**
- [ ] Given the developer account is a personal account created after 13 November 2023, then production access is requested only after at least 12 testers remain opted into closed testing continuously for at least 14 days; otherwise the current requirements shown for that account are documented and followed
- [ ] Given open testing stable, when promoted to `production`, then the rollout percentage is set to 10%; Play Console's Android Vitals dashboard is monitored for crash rate and ANR rate — target: crash rate <1%
- [ ] Given the staged rollout at 10%, when crash rate and ANR rate are both below 1% for 48 hours, then the rollout is increased to 50%, then 100% — each step requires manual promotion in Play Console
- [ ] Given Play Console's pre-launch report, when the APK is first uploaded to internal testing, then the automated test report (runs on Firebase Test Lab device farm, free for Play Console apps) must show no critical issues before advancing to closed testing
- [ ] Given version 1.0 at 100% rollout, when version 1.1 is ready, then the pipeline in US-25 uploads the new AAB and the same track progression repeats: internal → closed → open → production (with staged rollout)

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Manual | Verify Play Console pre-launch report passes for all default device configurations | Play Console |
| Manual | Confirm the account-specific closed-test requirement is met and meaningful feedback from representative families is documented | Play Console |
| Manual | Monitor crash rate and ANR rate at 10% rollout for 48 hours | Play Console Android Vitals |
| Manual | Test install from Play Store on fresh Android device (not sideloaded) after 100% rollout | Physical Android device |

---

### US-31: Iterative Release Versioning
**As a** developer, **I want** a clear versioning and release cadence **so that** users receive updates predictably and the team knows what triggers a new App Store submission vs an OTA content update.

**Acceptance Criteria:**
- [ ] Given versioning scheme `MAJOR.MINOR.PATCH`, when a new release is planned, then: PATCH = bug fix (no new features); MINOR = new game type, screen, or feature; MAJOR = architectural overhaul or complete redesign; content updates (new stories, LBV verses) do NOT increment any version number
- [ ] Given new story content published via the admin app to R2/KV, when a child opens the app, then the new story appears within 60 seconds of going online — no App Store submission, no user-triggered update
- [ ] Given a PATCH release needed, when the release branch is cut, then the iOS `CFBundleShortVersionString` and Android `versionName` are both updated in `pubspec.yaml`; `flutter_launcher_icons` rebuilds icons if changed; `versionCode` (Android) and `CFBundleVersion` (iOS) auto-increment via the CI pipeline
- [ ] Given version 1.0.0 released, when the planned release cadence is followed, then: content OTA updates happen as content is approved (no cadence); PATCH releases target every 2 weeks if bugs found; MINOR releases target every 6–8 weeks aligned to feature milestones

**Test Plan:**

| Type | Scenario | Tool |
|---|---|---|
| Manual | Publish a new story via admin; open app on device; verify story appears without app update | Physical device + Admin app |
| Pipeline | Verify `versionCode` auto-increments on each release branch push | GitHub Actions output |
| Manual | Install 1.0.0; publish new story via admin; verify story appears in 1.0.0 without updating the app | Physical device |

---

# Part 3 — Test Plan Summary

## Testing Layers

| Layer | Tool | Scope |
|---|---|---|
| **Unit** | `flutter_test` + `mocktail` | Services, repositories, business logic — no UI, no network |
| **Widget** | `flutter_test` (WidgetTester) | Individual screens and components, mocked providers |
| **Integration** | `integration_test` + real Drift | Full feature flows end-to-end within the app, real local DB |
| **API** | Vitest + CF Workers test env | Worker request handlers, D1/R2/KV operations |
| **Device** | Manual — physical devices | Touch, haptics, TTS, accelerometer, IAP, offline |
| **Performance** | Flutter DevTools + Xcode Instruments | Frame rate, Drift query times, memory |
| **Load** | k6 | Worker + D1 under concurrent load |
| **Security** | Manual + Postman | Auth bypass, receipt tampering, role escalation |

## Device Test Matrix

| Device | OS | Priority | Covers |
|---|---|---|---|
| iPhone SE 2nd gen | iOS 16+ | P0 | Performance floor — smallest supported iPhone |
| iPhone 15 | iOS 17+ | P0 | Latest iOS |
| Samsung A14 | Android 13 | P0 | Performance floor — mid-range Android |
| Samsung S24 | Android 14 | P1 | Latest Android |
| iPad (9th gen) | iPadOS 16+ | P1 | Tablet layout |
| Pixel 7 | Android 14 | P1 | Stock Android reference |

## Coverage Targets

| Layer | Target | Rationale |
|---|---|---|
| Services (unit) | 90%+ | Core logic — garden growth, sync, consent and content resolution |
| Game logic (unit) | 85%+ | Score, rotation, age-gating |
| Screens (widget) | 70%+ | Happy path + key error states |
| API handlers (unit) | 85%+ | Auth, progress, unlock, content delivery |
| Critical paths (integration) | 100% | Offline operation, IAP, sync, Bible navigation |

## Pre-Launch Checklist

**App quality:**
- [ ] All user stories in v1.0 scope pass their integration tests (see MVP scope table)
- [ ] Full offline regression on iPhone SE 2nd gen and Samsung A14
- [ ] 60fps on iPhone SE 2nd gen throughout story + game flow
- [ ] Screen reader (VoiceOver / TalkBack) passes on story player and key verse screen
- [ ] Colour contrast verified for all token pairs (Colour & Accessibility table)
- [ ] `MediaQuery.reducedMotion` tested — all animations replaced with cross-fades, Lumi static pose
- [ ] Every interactive target ≥48×48dp; instructions replayable; meaning never depends only on colour, sound, reading, or fine motor precision
- [ ] Sound design audit: all 9 sound moments play correctly; parent mute toggles TTS and ambient independently
- [ ] 100 queued entries sync without data loss after 24-hour offline period
- [ ] BGAppRefreshTask (iOS) and WorkManager (Android) sync tested after 15+ min background
- [ ] Bundle size audit: `flutter build apk --analyze-size` reviewed; total ≤35MB
- [ ] Diagnostics SDK child-privacy review completed; PII scrubbing verified in release traffic
- [ ] Formative usability testing completed with at least 5 children in each age band (3–5, 6–8, 9–12), varied reading levels, neurodivergent/disabled participants, different church backgrounds and families with unreliable connectivity, under documented parent consent
- [ ] Testing assesses independent navigation, comprehension, emotional response, session stopping, optional prayer/discussion understanding and parent trust—not completion alone
- [ ] Autoplay, Quiet Story Mode, Replay/Next/Back/Stop controls and optional post-story paths tested for every age band
- [ ] No random reward, multiplier, perfect-score bonus, leaderboard, streak loss, garden wilt/reset or prayer-linked reward exists in release code/content
- [ ] Parent Hub per-profile controls tested: content approval/sensitivity, full-Bible access, session reminder, autoplay/TTS/audio, reduced rewards/motion, notifications, Wi-Fi downloads, sync, sharing and profile deletion
- [ ] Shared-device profile selection reveals no sibling score/activity comparison and preserves independent accessibility/content settings

**Content quality (all 10–12 launch stories before v1.0; same gate applies to every later OTA package):**
- [ ] Every story has `sensitivityTier` set (`general` / `guided` / `parental_presence`)
- [ ] Every story has a `verseContext` field (one sentence of narrative context for the key verse)
- [ ] Every package declares genre and passes its genre-specific structure requirements
- [ ] Theological checklist, statement of faith and disputed-issues guide applied; original context, canonical connection and child application reviewed separately
- [ ] Biblical/theological, Christian-education and safeguarding approvals recorded with separation of author/final approver and rollback-ready version history
- [ ] Lumi role-boundary audit passes: no divine first-person speech, private revelation, spiritual pronouncement, God-approval-for-performance language or substitution for parents/pastors/church
- [ ] Translation, child adaptation, retelling and memory phrase are visibly and audibly distinguished; no adaptation is called a direct quotation from God
- [ ] Prayer options include multiple biblical modes, are immediately skippable, unmeasured and unrewarded, and never promise outcomes
- [ ] Stories classified `guided` or `parental_presence` are correctly age-gated in the app
- [ ] Flexible practice schedule: `VerseFamiliarity.nextReviewDate` and all five familiarity stages tested without claiming permanent mastery

**Compliance:**
- [ ] Versioned data inventory matches app code, D1/Analytics Engine schemas, vendors, retention, privacy policy, Apple privacy label and Play Data Safety responses
- [ ] Core child experience works without account or sync; cloud sync defaults off; just-in-time parent disclosure and legally required verifiable consent are tested before any child data upload
- [ ] Child nickname and drawings remain local; transmitted progress uses random IDs and minimised fields; prohibited identifiers are absent from release network traffic
- [ ] Parental gate protects purchases, restore, links, sharing, sign-in, consent/settings, profiles, export and deletion; timeout, background expiry, rate limiting and recovery are tested
- [ ] Data deletion flow tested end-to-end: all D1 rows confirmed deleted, local DB wiped
- [ ] App Store privacy nutrition label matches actual data collection
- [ ] Current Google Play Families, Target Audience, Data Safety, SDK and IARC declarations complete and accurate; upcoming policies effective before release are included
- [ ] Content sensitivity inventory complete; every child-reachable story/chapter/OTA package is approved for its band and consistent with both stores' rating answers
- [ ] Privacy policy live at `https://littlebible.org/privacy` before any submission

**iOS release:**
- [ ] IAP product `com.littlebible.unlock` created and approved in App Store Connect
- [ ] TestFlight internal testing: all P0 tests pass (US-28 exit criteria)
- [ ] TestFlight external beta: 200 testers, 2-week minimum, zero P0 crashes in last 7 days
- [ ] App Store submission: demo account provided, phased rollout enabled (start at 1%)
- [ ] App Store listing: screenshots for 6.7", 6.1", 5.5"; keywords include "little bible", "bible for kids"

**Android release:**
- [ ] Play Console pre-launch report: no critical issues on Firebase Test Lab
- [ ] If applicable to the developer account: at least 12 closed testers continuously opted in for at least 14 days before requesting production access
- [ ] Open testing, if used: representative family feedback reviewed and crash rate <1% before production promotion
- [ ] Production: staged rollout at 10% → 50% → 100%; Android Vitals monitored at each step
- [ ] Keystore backup: upload keystore stored in at least 2 secure locations (loss = cannot update app)

---

*Little Bible · User Stories & System Design · August 2026*
*Cloudflare Workers · D1 · R2 · KV · Analytics Engine · Flutter*
