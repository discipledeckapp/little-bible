# Little Bible — Scene Illustration & Animation Standard

**Status:** v1 · adopted 2026-08-03
**Applies to:** every story illustration in the app — the 15 already built and every one built from now on.
**Owner:** Oluwaseyi Adelaju

This standard governs how story scenes are drawn and animated. It exists because
the first generation of illustrations failed in three repeatable ways, and the
rules below are written to make each of those failures impossible rather than
unlikely.

Read this file completely before drawing or animating any scene.

---

## 0. What went wrong, and what each rule is protecting against

These are the actual observed defects. Every rule in this document traces back
to one of them.

| Defect | What it looked like | Rule that prevents it |
|---|---|---|
| **Aspect deformation.** Painters authored for a 1:1.2 portrait canvas were rendered into boxes of 136×108, 411×240, and one passing `double.infinity`. Vertical collapsed to ~49%. | Figures squashed into abstract wedges. | §2 Fixed design box |
| **Collinear limbs.** "Arms wide open" were two lines from one origin, one angled up-left and one down-right — nearly a straight line. | A father welcoming his son rendered as **a seesaw plank through his head**. | §4.2 Limb rule |
| **Ground shape misread.** A perspective road drawn as a filled trapezoid, narrow at top and wide at bottom, in an amber *lighter* than the sky. | The road read as **a mountain**, on top of the figures. | §4.4 Ground rule |

None of these were caught before shipping because nobody rendered the painter
and looked at it. §7 makes that step mandatory.

---

## 1. Architecture

One animated illustration per narration scene.

### Scene count

Scene count comes from `StoryModel.scenes(ageBand)`, which splits
`steps.read.childText` (or `.text` for the `independent` band) on blank lines:

```dart
raw.split('\n\n').where((s) => s.trim().isNotEmpty).toList()
```

**The number of illustrations for a story always equals the number of scenes
that method returns.** Never more, never fewer.

As of adoption, all 15 stories have a single unbroken paragraph and therefore
exactly **one** scene each. If you are animating a story whose narrative has
three or more obvious beats but whose `childText` is one paragraph, deliver the
single illustration the contract requires and **flag it to the content owner**.
Splitting narration into scenes is a content change governed by
`docs/LittleBible_Content_Standard_v2.md` and is not the illustrator's call.

### The painter contract

```dart
/// One animated illustration for one scene of one story.
///
/// Implementations draw in the 1000×1000 design box (see §2) and must be pure:
/// no timers, no state, no I/O. All motion is a function of `t`.
abstract class ScenePainter extends CustomPainter {
  const ScenePainter(this.t);

  /// Scene progress. 0 = scene start, 1 = scene fully resolved.
  /// Monotonic within a scene. Never loops, never reverses.
  final double t;

  @override
  bool shouldRepaint(covariant ScenePainter old) => old.t != t;
}
```

### Registry

```dart
/// storyId → one builder per scene, in narration order.
const Map<String, List<ScenePainter Function(double t)>> kSceneRegistry = {
  'the-lost-son': [ /* scene 0 */, /* scene 1 */, ... ],
};
```

Resolution rules, in order:

1. Story present and `sceneIndex` in range → use that builder.
2. Story present, `sceneIndex` beyond the list → use the **last** builder.
3. Story absent → use `FallbackScenePainter`.

Rule 3 is what makes this safe for stories that do not exist yet: a new story
ships with a working, non-broken illustration on day one and gets bespoke art
later. **Never let a missing registry entry crash or render blank.**

### Static uses

The home cards are not animated. They render **scene 0 at `t = 1.0`** — the
resolved frame. This keeps cards composed and costs nothing per frame.

---

## 2. The design box (fixes aspect deformation)

**Every scene painter draws into a virtual 1000 × 1000 canvas, in design
coordinates, and never reads `size` for layout.**

The widget applies the fit transform. The painter's first act is:

```dart
@override
void paint(Canvas canvas, Size size) {
  canvas.save();
  applyDesignBoxFit(canvas, size); // cover-fit 1000×1000 → size, centred
  paintScene(canvas);              // draw in 0..1000 coordinates only
  canvas.restore();
}
```

### Safe zone

The illustration is rendered into boxes as wide as 1.71:1 and as tall as 1:1.2.
Under a cover-fit, that means the visible region changes considerably.

- **Essential subject matter** — faces, figures, the thing the sentence is
  about — must sit inside the central band **y 200 → 800**, full width.
- **Nothing essential** in the outer 15% on any edge.
- Sky, ground, and ambient texture may extend to the full 0–1000 box and are
  expected to be cropped.

If the story's meaning is lost when the top and bottom 20% are cropped, the
composition is wrong. Recompose; do not special-case the aspect.

### Prohibited

- Reading `size.width` / `size.height` for anything except the fit transform.
- Any coordinate expressed as a fraction of the live canvas (`w * .32`, `h * .44`).
  This is the exact pattern that produced the deformation. Use design units
  (`320`, `440`).

---

## 3. Animation rules

The product's design principles require **calm** (`CLAUDE.md`): "Minimal
animation. No startling effects." Animation here serves comprehension, not
spectacle. A 4-year-old is listening to Scripture; the picture supports the
words and must never compete with them.

### Timing

- `t` is driven by **narration position**, not a fixed timer:
  `t = (elapsed / sceneNarrationDuration).clamp(0, 1)`.
- The picture **resolves on the sentence's meaning**: at `t = 1` it shows the
  outcome the narration has just finished describing.
- `t` is monotonic. No looping, no reversing, no bouncing within a scene.

### Budget

| Limit | Value |
|---|---|
| Animated elements per scene | **max 3** |
| Travel speed | ≤ 250 design units per second |
| Scale change on any element | ≤ 1.15× |
| Rotation on any element | ≤ 15° |
| Ambient loop amplitude (clouds, water, light) | ≤ 20 design units |
| Ambient loop period | ≥ 4 s |

Ambient loops are the only permitted looping motion, and only for background
texture — never a figure, never a face.

### Reduce motion

When `MediaQuery.of(context).disableAnimations` is true, render at **`t = 1.0`**.
Never mid-motion, never blank, never a different composition. The reduced-motion
user sees the same resolved picture everyone else ends on.

### Prohibited outright

Flashing or strobing; anything faster than the budget above; motion that
continues after narration stops; particle bursts during narration (celebration
belongs in the games screen, not the story); motion that draws the eye away from
text while text is being read.

---

## 4. Art rules

These make figures readable at phone size. They are not stylistic preferences —
each one is a defect that shipped.

### 4.1 Silhouette test

Fill every shape in the scene solid black. **The scene must still be
identifiable.** If the silhouette is ambiguous, the composition fails. Run this
before adding colour or detail.

### 4.2 Figures and limbs

- A person is built from **at least four parts**: head, torso, and two limbs.
- **Two limbs sharing an origin must differ in direction by 40°–140°.** Outside
  that range they render as one straight bar. This is the seesaw defect: arms at
  ~172° apart became a plank.
- Arms raised in welcome, praise, or surprise angle **upward on both sides** —
  a V or Y, never one up and one down.
- The primary figure is **at least 220 design units tall** (22% of the box).
  Smaller than that and a person is not legible on a phone.
- Any figure taller than 300 units carries **at least two face features**
  (eyes and mouth).
- Head, torso, and limbs must **visibly connect** — overlap them. No floating
  heads.

### 4.3 Depth order

Draw back to front: sky → distant landscape → ground plane → background figures
→ primary figures → foreground → light effects. Never draw the ground plane
after a figure standing on it.

### 4.4 Ground, roads, and horizons

- Figures stand **on** the ground plane: the feet overlap it. Nothing floats.
- A receding road or path is drawn with **converging edge lines**, or as a
  filled shape that is **darker than both the sky and the land beside it**. A
  light filled trapezoid that is narrow at the top reads as a mountain — this is
  exactly what happened to The Lost Son's road.
- Keep the horizon out of the vertical centre (y 450–550); it flattens the
  composition and is the first thing lost to cropping.

### 4.5 Contrast and colour

- Primary subject against its immediate background: **contrast ratio ≥ 3:1**.
- Palette comes from `docs/LittleBible_Brand_Identity.md` §3. Warm, not neon.
- Never encode meaning in colour alone.
- `maskFilter` blur is permitted only for light and glow, never for a subject
  edge — it costs a save-layer and reads as smudge at small sizes.

### 4.6 Medium

Vector only — `CustomPainter`, consistent with the project-wide decision that
all illustration is vector art. **No emoji in any story scene or cover.** No
raster images. Rive is permitted only where §8 allows it.

---

## 5. Reverence

Story illustrations depict Scripture. The design principles in `CLAUDE.md`
require reverence: "No game-show energy."

- Never caricature, never make a joke of a person in Scripture.
- Do not depict the face of God the Father. Represent Him as light.
- Jesus is depicted with dignity and warmth, never comically.
- Judgment, death, and sin are not softened, but are shown without gore, terror,
  or peril framed as excitement.
- No animation makes suffering look playful.

---

## 6. Performance

- Painters are **pure functions of `t`**. No state, no timers, no `async`, no
  asset loading inside `paint()`.
- Build `Path`, `Paint`, gradient and shader objects for static geometry as
  `static final`, outside `paint()`.
- Budget: **≤ 60 draw calls** and **≤ 1 save-layer** per scene.
- `shouldRepaint` compares `t` only.
- One `AnimationController` per story player, never one per painter.

---

## 7. Mandatory verification

**A scene is not done until it has been rendered and looked at.** Every defect
in §0 would have been caught by this step.

For each scene, produce goldens at **both extreme aspects** and **three points
in time**:

| Aspect | Why |
|---|---|
| 411 × 240 | Story player header — the widest real box |
| 136 × 108 | Home story card — the smallest real box |

| `t` | Why |
|---|---|
| 0.0 | Scene start reads as a composed picture, not a half-drawn one |
| 0.5 | No collapsed or collinear geometry mid-motion |
| 1.0 | Resolved frame; also what reduced-motion and the home card show |

Add the goldens to `mobile/test/widget/goldens/` via a test in the shape of
`test/widget/lumi_widget_golden_test.dart`, then **open the PNGs**. Rendering
them and not inspecting them is not verification.

### Checklist — every item, every scene

- [ ] Silhouette test passed (§4.1)
- [ ] Limbs sharing an origin differ by 40°–140° (§4.2)
- [ ] Primary figure ≥ 220 units tall; ≥ 2 face features if > 300 (§4.2)
- [ ] Head/torso/limbs visibly connected; nothing floating (§4.2, §4.4)
- [ ] Ground plane darker than sky, or drawn with converging lines (§4.4)
- [ ] Essential subject inside y 200–800; nothing essential in outer 15% (§2)
- [ ] No live-canvas fractions anywhere in the painter (§2)
- [ ] ≤ 3 animated elements; within the motion budget (§3)
- [ ] `t = 1` is the resolved frame matching the sentence (§3)
- [ ] Reduced motion renders `t = 1` (§3)
- [ ] Contrast ≥ 3:1 on the primary subject (§4.5)
- [ ] ≤ 60 draw calls, ≤ 1 save-layer, no state in `paint()` (§6)
- [ ] Goldens rendered at both aspects × three `t` values, **and inspected** (§7)
- [ ] `flutter analyze` clean; existing goldens still pass
- [ ] Registry entry added; scene count equals `scenes()` length (§1)

---

## 8. When to use Rive instead

`rive: ^0.13.17` is already a dependency and `assets/rive/` is empty. Rive is
permitted **only** for a small number of hero moments where character
performance carries theological weight — the father's embrace, the resurrection.

Rules: a Rive scene must have a `CustomPainter` fallback registered for it; it
must respect §3's reduce-motion rule; it must not be the only way a story's
meaning is conveyed. Do not author Rive for ordinary scenes — the maintenance
and bundle cost is not justified, and `CustomPainter` already satisfies this
standard.

---

## 9. The prompt

Use this verbatim for any story, built or unbuilt. Replace `{{STORY_ID}}`.

---

> **Task: animate the story illustrations for `{{STORY_ID}}` in the Little Bible Flutter app.**
>
> **Read first, completely:**
> 1. `docs/LittleBible_Scene_Animation_Standard.md` — binding. Every rule and the whole §7 checklist applies.
> 2. `docs/LittleBible_Brand_Identity.md` §3 for the palette.
> 3. `CLAUDE.md` design principles — reverence, warmth, calm, accessibility.
> 4. `mobile/assets/stories/{{STORY_ID}}.json` — in particular `title`, `mainTruth`, `bibleRef`, `illustrationPrompt`, and `steps.read.childText`.
> 5. `mobile/lib/features/story/widgets/story_cover.dart` for the existing painter, and `mobile/lib/features/lumi/widgets/lumi_widget.dart` as the reference for how a painter should be written.
>
> **Do:**
> 1. Determine the scene count with `StoryModel.scenes()` semantics — split `steps.read.childText` on blank lines. Deliver exactly one illustration per scene. If the narrative has three or more clear beats but the text is a single paragraph, deliver the one illustration required and flag the scene split to the content owner. Do not edit story text.
> 2. For each scene, write one sentence naming what the child must understand from that picture, then compose to that sentence and nothing else.
> 3. Implement each scene as a `ScenePainter` subclass drawing in the 1000×1000 design box, in design units, with all motion a pure function of `t`. Obey §4's art rules — they encode real shipped defects.
> 4. Register the scenes in `kSceneRegistry` in narration order.
> 5. Drive `t` from narration position; render `t = 1.0` under `MediaQuery.disableAnimations`.
> 6. Write a golden test producing every scene at 411×240 and 136×108, at `t` = 0.0, 0.5, 1.0. Run it, then **open and inspect every PNG**. Fix what looks wrong and regenerate. Do not report the work complete on the basis of tests passing alone — the images must have been looked at.
> 7. Run `flutter analyze`, and confirm existing goldens still pass.
>
> **Do not:** use emoji or raster art; use live-canvas fractions (`w * .32`); animate more than three elements per scene; loop figure or face motion; exceed the §3 motion budget; depict the Father's face; edit story JSON, content, or another story's painters.
>
> **Report:** for each scene — the one-sentence intent, the animated elements and their `t` ranges, the §7 checklist with each box ticked or explicitly justified, and anything you could not satisfy and why.

---

## 10. Retroactive application

Per the project rule that standards apply retroactively, all 15 existing story
painters are non-compliant: they use live-canvas fractions and were never
rendered at their real aspects. They are to be migrated to this standard.

Migration order follows the curriculum: `god-made-everything`, `god-made-me`,
`noahs-big-boat`, `noahs-rainbow-promise`, `birth-of-jesus`,
`jesus-loves-children`, `david-the-shepherd-boy`, `daniel-and-the-lions`,
`jonah-and-the-big-fish`, `the-lost-sheep`, `the-lost-son`,
`the-good-shepherd`, `how-to-pray`, `the-good-neighbour`, `jesus-saves`.

`the-lost-son` is the known-worst case and is the recommended reference
implementation to build first, out of curriculum order.
