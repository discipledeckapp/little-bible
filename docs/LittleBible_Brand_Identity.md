# Little Bible — Brand Identity

**Status:** v1 · adopted 2026-08-02
**Owner:** Oluwaseyi Adelaju

This document settles which mark goes where, and what Lumi is. Read it before
touching any logo, icon, or mascot artwork.

---

## 1. Lumi is a seed of light

> "Now the parable is this: The seed is the word of God." — Luke 8:11 (KJV)
> "Thy word is a lamp unto my feet, and a light unto my path." — Psalm 119:105 (KJV)

**Lumi is a glowing seed of God's Word that grows as the child grows.**

That single sentence is the definition. It exists because the character had
drifted into three different things at once — a seed on the web, a plain glowing
ball in the app, and a piece of fruit on the app icon. One character, one
metaphor, everywhere.

The metaphor earns two things the brand already relies on:

- **Light** justifies the gold body, the halo, the sparkles, and the name
  (*lumen*).
- **Seed** justifies the sprout, the growth stages, and the child's garden.

### Non-negotiables

| Rule | Why |
|---|---|
| The body is a **teardrop**, tapering to a soft point where the sprout emerges. Never a circle. | A gold sphere with green leaves on top reads as a clementine. This was the single biggest defect in the first app icon. The silhouette is what carries the metaphor — not the colour and not the leaves. |
| The sprout is **two symmetric cotyledon leaves** on a short stem. | A single leaf on a side-stalk is the silhouette of fruit. |
| Lumi always has **eyes and a mouth**, and always faces the viewer. | Lumi is a companion, not an ornament. A shape without a face cannot build a relationship with a 4-year-old. |
| Lumi is **vector art** — SVG on the web, `CustomPainter` in Flutter. Never an emoji, never a bitmap. | Consistent with the project-wide rule that all illustration is vector. |
| Lumi's growth stages only ever move **forward**. Nothing wilts, nothing resets. | Shame is not a discipleship mechanic. |

### Growth stages

Lumi grows with the child: **seed → sprout → sapling → young tree → tree of
life**. Web artwork for each stage lives in `public/brand/lumi/`. The stage a
child sees is earned and never taken away.

---

## 2. Two marks, two jobs

There are two permanent marks. They are not alternatives, and neither replaces
the other.

### The brand mark — book and cross

`components/brand/LogoMark.tsx` · `public/brand/logo/*.svg`

An open book beneath a cross, on a deep amber gradient square.

**Its job is trust, and its audience is the parent.** It answers "is this a
real, faithful Bible product?" — the question an adult asks before installing
anything for their child.

Use it for:

- the website header and footer
- the favicon
- App Store / Play Store listing pages, feature graphics, screenshots
- publisher identity, share cards, printables, anything institutional

### The mascot — Lumi

`public/brand/lumi/*.svg` · `mobile/lib/features/lumi/widgets/lumi_widget.dart`

**Its job is relationship and progress, and its audience is the child.** It
answers "is this mine, and am I growing?"

Use it for:

- the app icon
- everything inside the app
- the web hero
- growth, reward, and celebration moments

### Where each one wins

A child aged 4–7 cannot read, and picks an app by silhouette. That is why the
**app icon is Lumi** and not the book mark. A parent evaluates in the store
listing, which is why the **book mark owns the listing** around it. Putting both
on one surface weakens both — an icon carries exactly one idea.

**Never put the book-and-cross mark on the app icon.**

---

## 3. Colour

Both marks share one background gradient, which is what makes them read as a
family rather than two unrelated logos:

| Token | Hex | Use |
|---|---|---|
| Deep earth | `#7C2D12` | Gradient start; Android adaptive icon background |
| Mid amber | `#B45309` | Gradient middle |
| Amber | `#D97706` | Gradient end; Lumi body edge |
| Lumi gold | `#F59E0B` | Lumi body |
| Warm gold | `#FBBF24` | Lumi highlight |
| Pale gold | `#FDE68A` | Lumi specular highlight |
| Bible brown | `#78350F` | Lumi's eyes and mouth |
| Stem green | `#10B981` | Sprout stem |
| Leaf green | `#34D399` / `#4ADE80` | Cotyledon leaves |
| Cream | `#FFFBF5` | App and page background |

---

## 4. App icon

**Vector source:** `mobile/assets/brand/lumi-app-icon.svg` (full-bleed) and
`mobile/assets/brand/lumi-adaptive-foreground.svg` (Android adaptive
foreground). These are the artwork. Every PNG in `ios/` and `android/` is build
output.

To change the icon:

```bash
cd mobile
node tool/render_icons.mjs      # SVG → assets/brand/*.png
dart run flutter_launcher_icons # PNG → every iOS and Android size
flutter test test/widget/lumi_widget_golden_test.dart
```

Never hand-edit the generated PNGs, and never edit one SVG without the other —
the two files share geometry on purpose.

### Constraints the artwork must respect

- **Flat fills on the character.** The icon renders as small as 20×20pt
  (`Icon-App-20x20@1x.png`). Radial gradients and blur filters collapse into a
  muddy blob at that size. The only gradients allowed are the background and the
  halo, both large soft areas that downscale cleanly.
- **No transparency in the iOS icon.** iOS composites alpha onto black or white;
  a transparent source produced an orange circle floating on a white square in
  the first version. `remove_alpha_ios: true` plus an opaque source handles it.
- **The adaptive foreground must clear the safe zone.** Android shows only the
  central 66% of the 108dp canvas, and the generated `ic_launcher.xml` adds a
  16% inset on top of that. The foreground SVG compensates with a `scale(1.05)`
  so the artwork lands at roughly 76% of the visible mask. Do the compensation
  in the SVG, not by editing the generated XML, so re-running the tool cannot
  silently break it.
- **The adaptive background must contrast with Lumi.** It is `#7C2D12`. It was
  briefly `#F59E0B` — the same amber as Lumi's body — which made the character
  vanish into its own background on the launcher.

---

## 5. In-app Lumi

`mobile/lib/features/lumi/widgets/lumi_widget.dart`

`_LumiFacePainter` is a direct port of the icon vector, with every coordinate
expressed as a fraction of the canvas. **If you change the icon SVG, change the
painter, and vice versa.** `test/widget/lumi_widget_golden_test.dart` is the
guard — it renders all five expressions and fails on any geometry drift.

Lumi's body occupies about 52% of the widget box; the rest is headroom for the
sprout and halo. Size call sites accordingly.

### Behaviour

- **Expressions:** `idle`, `celebrate`, `thinking`, `encourage`, `wonder`.
- **Always tappable.** Lumi is the largest, brightest thing on the home screen;
  a 4-year-old will press it. It must respond every time.
- **Blinking and the idle bob are motion** and are both suppressed under
  `MediaQuery.disableAnimations`.
- **Calm, not game-show.** Slow bob, soft glow, no confetti, no startling
  sounds. See the design principles in `CLAUDE.md`.
