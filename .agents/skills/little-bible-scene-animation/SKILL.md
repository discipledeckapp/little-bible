---
name: little-bible-scene-animation
description: Draw and animate story scene illustrations for the Little Bible Flutter app as CustomPainter vector art — per-narration-scene, driven by narration position, in a fixed design box. Use for any new story illustration, any animation of an existing one, and any migration of a legacy story_cover painter. Never edits story text, content JSON, or completion records.
---

# Little Bible Scene Animation

## Required inputs

Read completely before drawing anything:

1. `docs/LittleBible_Scene_Animation_Standard.md` — binding. The §7 checklist is mandatory.
2. `docs/LittleBible_Brand_Identity.md` §3 — palette.
3. `CLAUDE.md` — design principles: reverence, warmth, calm, accessibility.
4. `mobile/assets/stories/<story-id>.json` — `title`, `mainTruth`, `bibleRef`, `illustrationPrompt`, `steps.read.childText`.
5. `mobile/lib/features/lumi/widgets/lumi_widget.dart` — reference for how a compliant painter is written.

## Ownership boundary

- Edit only scene painters, the scene registry, and their golden tests.
- Never edit story JSON, narration text, audio, `docs/content-completion.json`, or another story's painters.
- Scene splitting is a content change. Flag it; do not perform it.

## Sequence

1. Determine scene count via `StoryModel.scenes()` semantics — `steps.read.childText` split on blank lines. One illustration per scene, exactly.
2. For each scene write one sentence naming what the child must understand from that picture. Compose to that sentence only.
3. Run the silhouette test on the composition before adding colour.
4. Implement as `ScenePainter` in the 1000×1000 design box, design units only, all motion a pure function of `t`.
5. Register in `kSceneRegistry` in narration order.
6. Drive `t` from narration position. Render `t = 1.0` under `MediaQuery.disableAnimations`.
7. Golden-test every scene at 411×240 and 136×108, at `t` = 0.0, 0.5, 1.0.
8. **Open and inspect every PNG.** Fix and regenerate until each reads correctly.
9. `flutter analyze` clean; existing goldens still pass.

## Prohibited shortcuts

Do not use emoji or raster art. Do not use live-canvas fractions (`w * .32`, `h * .44`) — this is the defect that deformed every legacy painter. Do not animate more than three elements per scene, loop figure or face motion, or exceed the motion budget. Do not depict the face of God the Father. Do not draw a light filled trapezoid as a road. Do not give two limbs from one origin a direction difference outside 40°–140°.

Do not report completion because tests passed. The standard requires the rendered images to have been looked at.

## Report

Per scene: the one-sentence intent, the animated elements with their `t` ranges, the §7 checklist with every box ticked or explicitly justified, and anything unsatisfied with the reason.
