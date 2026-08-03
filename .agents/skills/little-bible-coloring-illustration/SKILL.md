---
name: little-bible-coloring-illustration
description: Design and implement coloring-page illustrations for the Little Bible app. Each story gets one coloring scene made of tap-fillable (and free-paint-strokeable) regions. Use for adding a new coloring scene, improving an existing one, or auditing quality across scenes.
---

# Little Bible Coloring Illustration Standard

## What a coloring scene is

A coloring scene is one Flutter `CustomPainter` function (`List<_Region> _storyIdScene()`) registered in `_sceneFor()` inside `mobile/lib/features/story/screens/coloring_screen.dart`.

Each `_Region` has:
- A unique `id` (string, snake_case, scope-local to its scene)
- A `pathBuilder: (Size s) => Path` that produces the fill/outline shape at any canvas size

The painter fills regions the child has tapped or painted, then draws all outlines on top.

---

## Design principles

### 1. Children's book quality — not stick figures
Every human figure must look like an illustrated character, not a geometric primitive.

**Prohibited:**
- Pure isoceles triangles as body shapes
- A single circle as a head with no hair/headwear
- Rectangles for arms with no shoulder origin
- No separation between upper body and lower garment

**Required:**
- Trapezoidal or shaped torso (wider at shoulders, tapering to waist/hem)
- Head oval with a separate `*_hair` or `*_headwear` region sitting on top
- Arms as at least one separate region, originating from the shoulder width
- Visible clothing separation (upper tunic + lower skirt/robe where appropriate)

### 2. Scene composition
Every scene must have:
- A background fill covering the full canvas (sky, room, water, etc.)
- At least one landscape layer (ground/hills or floor)
- The primary subject occupying roughly the centre-third of the canvas
- 2–4 supporting elements (trees, animals, stars, flowers, objects)

A scene that is just figures floating on a blank background is incomplete.

### 3. Region count
- Minimum 8 regions per scene
- Maximum 28 regions (more than 28 becomes overwhelming for a child to fill)
- Every region must be large enough to tap with a fingertip: no region with a bounding box narrower than `size.width * 0.04` in both axes

### 4. Proportions in the 1.0 coordinate space
All positions are expressed as fractions of `Size s` (no literals).

Typical figure proportions (fraction of canvas width `s.width`):
| Part | Width | Height |
|---|---|---|
| Adult head | 0.12–0.16 | 0.14–0.18 |
| Child head | 0.14–0.17 | 0.16–0.19 |
| Hair cap | head_w + 0.02–0.04 | 0.08–0.12 |
| Shoulders span | 0.18–0.26 | — |
| Robe upper (h) | — | 0.14–0.20 |
| Robe lower (h) | — | 0.12–0.18 |
| Arm length | 0.14–0.22 | 0.03–0.05 (radius) |
| Sheep wool blob | 0.09–0.13 | same |
| Sheep head | 0.07–0.10 | 0.08–0.11 |
| Sheep leg | 0.025–0.035 w | 0.05–0.07 h |

### 5. Human figure drawing pattern

```dart
// GOOD — trapezoidal robe with neckline curve
_Region(id: 'robe_upper', pathBuilder: (s) {
  final p = Path();
  p.moveTo(s.width * leftShoulder, s.height * top);
  p.lineTo(s.width * leftHem,      s.height * bottom);
  p.lineTo(s.width * rightHem,     s.height * bottom);
  p.lineTo(s.width * rightShoulder,s.height * top);
  p.quadraticBezierTo(s.width * cx, s.height * (top - 0.025), s.width * leftShoulder, s.height * top);
  p.close();
  return p;
}),
// Hair — wider than head, sits on top half of head oval
_Region(id: 'hair', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
  center: Offset(s.width * cx, s.height * (headCy - headH * 0.15)),
  width: s.width * (headW + 0.025),
  height: s.width * 0.10))),
```

### 6. Sheep drawing pattern (3 wool puffs + head + 4 legs)

```dart
_Region(id: 'sheep_N', pathBuilder: (s) {
  final ox = s.width * X; final oy = s.height * Y;
  final p = Path();
  // 3 wool puffs: left, centre (raised), right
  for (final d in [[-0.08, 0.0, 0.11], [0.01, -0.03, 0.13], [0.10, 0.0, 0.10]]) {
    p.addOval(Rect.fromCenter(
      center: Offset(ox + s.width * d[0], oy + s.height * d[1]),
      width: s.width * d[2], height: s.width * d[2]));
  }
  // head (left of body, slightly forward)
  p.addOval(Rect.fromCenter(
    center: Offset(ox - s.width * 0.17, oy + s.height * 0.01),
    width: s.width * 0.095, height: s.width * 0.105));
  // 4 legs
  for (final lx in [-0.06, 0.00, 0.065, 0.115]) {
    p.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(ox + s.width * lx, oy + s.height * 0.065,
          s.width * 0.028, s.height * 0.065),
      const Radius.circular(3)));
  }
  return p;
}),
```

Foreground sheep: wool puffs at ≈0.11–0.13 width. Background sheep (distance): ≈0.09–0.11 width.

### 7. Harp drawing pattern

```dart
// Sound box (left vertical body)
_Region(id: 'harp_box',    ...addRRect at (left, mid, width 0.065, height 0.215)...),
// Neck (curved bar from top of box to upper right)
_Region(id: 'harp_neck',   ...Path moveTo top-of-box, quadratic to neck-tip, close...),
// Column/pillar (straight right side)
_Region(id: 'harp_pillar', ...addRRect at (right, top, width 0.038, height 0.38)...),
// Strings (6 narrow bands from neck down to box)
...List.generate(6, (i) => _Region(id: 'string_$i', pathBuilder: (s) {
  final t = i / 5.0;
  // interpolate top anchor along neck, bottom anchor along box-top
  ...
})),
```

---

## Adding a new coloring scene

1. Write a `List<_Region> _<storyId using underscores>Scene()` function below the last scene.
2. Register it in `_sceneFor()`:
   ```dart
   case '<story-id-with-dashes>': return _<storyId>Scene();
   ```
3. Add an entry to `_descriptionFor()`:
   ```dart
   '<story-id>': '<one short phrase describing the illustration, 4–7 words>',
   ```
4. Run through the quality checklist below before committing.

---

## Quality checklist (run before every commit)

- [ ] Every human figure has: head oval + hair region + shaped torso (not a triangle) + at least one arm region
- [ ] Every sheep has: 3 wool puffs + head + 4 leg rectangles
- [ ] Scene has a background region covering 100% of canvas
- [ ] Scene has at least one landscape layer (hill, ground, floor, water)
- [ ] Region count is between 8 and 28
- [ ] No region has a bounding box narrower than `s.width * 0.04` in both dimensions
- [ ] All positions use `s.width * fraction` and `s.height * fraction` — no literals
- [ ] `flutter analyze` clean
- [ ] `flutter build apk --debug` succeeds
- [ ] Coloring screen renders correctly on device (tap to fill, pan to paint, undo works)

---

## Existing scenes (15 total, as of 2026-08)

| Story ID | Scene function | Notes |
|---|---|---|
| god-made-everything | `_creationScene()` | Sun, cloud, tree, bird, flower |
| god-made-me | `_godMadeMeScene()` | Child with arms out, sun, cloud |
| noahs-big-boat | `_noahScene()` | Rainbow, ark, dove |
| noahs-rainbow-promise | `_rainbowPromiseScene()` | Rainbow, dove with branch |
| birth-of-jesus | `_nativityScene()` | Star of Bethlehem, manger, ox, donkey |
| jesus-loves-children | `_jesusScene()` | Big heart with rays and stars |
| david-the-shepherd-boy | `_davidScene()` | David with harp, 2 sheep, hills |
| daniel-and-the-lions | `_danielScene()` | Stone den, angel glow, 2 lions |
| jonah-and-the-big-fish | `_jonahScene()` | Giant fish, Jonah inside |
| the-lost-sheep | `_lostSheepScene()` | Shepherd with lantern, flock + lost sheep |
| the-lost-son | `_lostSonScene()` | Father arms wide, son returning |
| the-good-shepherd | `_shepherdScene()` | Shepherd with staff, fluffy sheep |
| how-to-pray | `_howToPrayScene()` | Child kneeling at bed, window/moon |
| the-good-neighbour | `_goodNeighbourScene()` | Samaritan bending over injured man, donkey |
| jesus-saves | `_jesusSavesScene()` | Cross on hill with rays, hearts |

---

## Free-paint interaction model (do not change)

The screen supports both:
- **Tap-to-fill**: tapping a region fills it with the selected colour
- **Pan-to-paint**: dragging draws free brush strokes of variable width (3 sizes)
- **Undo**: removes the last free-paint stroke

Stroke widths are set by `_kBrushFractions = [0.014, 0.034, 0.068]` (fraction of canvas width). Do not modify these without testing across screen sizes.
