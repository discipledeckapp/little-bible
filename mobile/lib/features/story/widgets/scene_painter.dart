import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// § 2  Design-box fit  (fixes aspect deformation — see docs/LittleBible_Scene_Animation_Standard.md §0)
// ─────────────────────────────────────────────────────────────────────────────

/// Cover-fits the 1000×1000 design box into [size], centred.
/// Call this as the FIRST act of every painter's paint() method.
void applyDesignBoxFit(Canvas canvas, Size size) {
  const d = 1000.0;
  final s = math.max(size.width / d, size.height / d);
  canvas.translate((size.width - d * s) / 2, (size.height - d * s) / 2);
  canvas.scale(s);
}

// ─────────────────────────────────────────────────────────────────────────────
// § 1  Base class
// ─────────────────────────────────────────────────────────────────────────────

/// One animated illustration for one scene of one story.
///
/// Subclasses draw in the 1000×1000 design box via [paintScene].
/// All motion is a pure function of [t] (0 = scene start, 1 = fully resolved).
abstract class ScenePainter extends CustomPainter {
  const ScenePainter(this.t);

  /// Scene progress — 0 to 1, monotonic, never loops within a scene.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    applyDesignBoxFit(canvas, size);
    paintScene(canvas);
    canvas.restore();
  }

  void paintScene(Canvas canvas);

  @override
  bool shouldRepaint(covariant ScenePainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// § 1  Registry + resolution
// ─────────────────────────────────────────────────────────────────────────────

/// storyId → ordered list of scene builders, one per scene in narration order.
final Map<String, List<ScenePainter Function(double)>> kSceneRegistry = {
  'god-made-everything':    [_CreationScenePainter.new],
  'god-made-me':            [_GodMadeMeScenePainter.new],
  'noahs-big-boat':         [_NoahScenePainter.new],
  'noahs-rainbow-promise':  [_RainbowScenePainter.new],
  'birth-of-jesus':         [_NativityScenePainter.new],
  'jesus-loves-children':   [_JesusChildrenScenePainter.new],
  'david-the-shepherd-boy': [_DavidScenePainter.new],
  'daniel-and-the-lions':   [_DanielScenePainter.new],
  'jonah-and-the-big-fish': [_JonahScenePainter.new],
  'the-lost-sheep':         [_LostSheepScenePainter.new],
  'the-lost-son':           [_LostSonScenePainter.new],
  'the-good-shepherd':      [_GoodShepherdScenePainter.new],
  'how-to-pray':            [_PrayerScenePainter.new],
  'the-good-neighbour':     [_GoodNeighbourScenePainter.new],
  'jesus-saves':            [_JesusSavesScenePainter.new],
};

/// Returns the correct painter for [storyId]/[sceneIndex] at progress [t].
///
/// Resolution order (§ 1):
///   1. storyId in registry and sceneIndex in range → bespoke painter
///   2. storyId in registry, sceneIndex beyond list  → last painter
///   3. storyId absent                               → FallbackScenePainter
ScenePainter sceneFor(String storyId, int sceneIndex, double t) {
  final list = kSceneRegistry[storyId];
  if (list == null) return FallbackScenePainter(t);
  return list[sceneIndex.clamp(0, list.length - 1)](t);
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback — warm cross on amber, never blank
// ─────────────────────────────────────────────────────────────────────────────

class FallbackScenePainter extends ScenePainter {
  const FallbackScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 1000, 1000),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB45309), Color(0xFF7C2D12)],
        ).createShader(const Rect.fromLTWH(0, 0, 1000, 1000)),
    );
    final p = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.85)
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(500, 300), const Offset(500, 720), p);
    canvas.drawLine(const Offset(320, 450), const Offset(680, 450), p);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private drawing helpers — all in design units (0–1000), no live canvas refs
// ─────────────────────────────────────────────────────────────────────────────

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Lerp from [a] to [b] only between progress [t0] and [t1]; clamps outside.
double _cl(double a, double b, double t, double t0, double t1) {
  if (t1 <= t0) return b;
  return _lerp(a, b, ((t - t0) / (t1 - t0)).clamp(0.0, 1.0));
}

/// Full-canvas sky gradient top→bottom.
void _sky(Canvas canvas, Color top, Color bottom) {
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 1000, 1000),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      ).createShader(const Rect.fromLTWH(0, 0, 1000, 1000)),
  );
}

/// Solid ground rectangle from y=groundY to y=1000.
void _ground(Canvas canvas, Color color, double groundY) {
  canvas.drawRect(
    Rect.fromLTWH(0, groundY, 1000, 1000 - groundY),
    Paint()..color = color,
  );
}

/// White star dot at (x, y) radius r with opacity [alpha].
void _dot(Canvas canvas, double x, double y, double r, double alpha) {
  if (alpha <= 0) return;
  canvas.drawCircle(
    Offset(x, y), r, Paint()..color = Colors.white.withValues(alpha: alpha));
}

/// Standing person at (cx, fy=feet-y), total height ≥ 220 design units.
///
/// § 4.2 limb rule: |armAngleL − armAngleR| must be 40°–140°.
/// Angles follow Flutter canvas convention: 0°=right, 90°=down.
///
/// Default (120°, 60°): arms relaxed at sides, difference = 60° ✓
void _person(
  Canvas canvas,
  double cx, double fy, double height,
  Color skin, Color robe, {
  double armAngleL = 120,   // left arm angle (degrees)
  double armAngleR = 60,    // right arm angle (degrees)
  bool hasHalo = false,
}) {
  assert(height >= 220, 'Primary figure must be ≥ 220 design units');
  assert(
    (armAngleL - armAngleR).abs().clamp(40, 140) == (armAngleL - armAngleR).abs(),
    'Limb rule: angles must differ by 40°–140°',
  );

  final hR = height * 0.14;       // head radius
  final headY = fy - height + hR; // head centre y
  final shoulderY = headY + hR * 2.0;
  final armLen = height * 0.27;

  // Halo (optional)
  if (hasHalo) {
    canvas.drawCircle(
      Offset(cx, headY), hR * 1.55,
      Paint()
        ..color = const Color(0xFFFDE68A).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = hR * 0.28,
    );
  }

  // Robe — A-line trapezoid, wider at feet (§ 4.2 head/torso/limbs visibly connected)
  canvas.drawPath(
    Path()
      ..moveTo(cx - hR * 1.1, shoulderY)
      ..lineTo(cx - hR * 2.4, fy)
      ..lineTo(cx + hR * 2.4, fy)
      ..lineTo(cx + hR * 1.1, shoulderY)
      ..close(),
    Paint()..color = robe,
  );

  // Arms
  final al = armAngleL * math.pi / 180.0;
  final ar = armAngleR * math.pi / 180.0;
  final aP = Paint()
    ..color = skin
    ..strokeWidth = hR * 0.65
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final lSx = cx - hR * 0.85;
  final rSx = cx + hR * 0.85;
  final sy = shoulderY + hR * 0.4;
  canvas.drawLine(Offset(lSx, sy),
      Offset(lSx + armLen * math.cos(al), sy + armLen * math.sin(al)), aP);
  canvas.drawLine(Offset(rSx, sy),
      Offset(rSx + armLen * math.cos(ar), sy + armLen * math.sin(ar)), aP);

  // Head — drawn AFTER robe so it overlaps (§ 4.2 nothing floating)
  canvas.drawCircle(Offset(cx, headY), hR, Paint()..color = skin);

  // Face features (§ 4.2: always 2 features because height ≥ 220 → hR ≥ 30.8)
  final fP = Paint()..color = const Color(0xFF78350F);
  canvas.drawCircle(Offset(cx - hR * 0.3, headY - hR * 0.08), hR * 0.14, fP);
  canvas.drawCircle(Offset(cx + hR * 0.3, headY - hR * 0.08), hR * 0.14, fP);
  canvas.drawArc(
    Rect.fromCenter(
        center: Offset(cx, headY + hR * 0.22),
        width: hR * 0.72, height: hR * 0.36),
    0.1, math.pi * 0.8, false,
    Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = hR * 0.12
      ..style = PaintingStyle.stroke,
  );
}

/// Kneeling figure (head+torso, no legs visible). height = torso+head only.
void _kneeling(
  Canvas canvas,
  double cx, double groundY, double height,
  Color skin, Color robe, {
  double prayerOpenDeg = 0, // how far arms open from prayer (0=closed,1=open)
}) {
  assert(height >= 220);
  final hR = height * 0.18;
  final headY = groundY - height + hR;
  final shoulderY = headY + hR * 1.8;

  // Robe body
  canvas.drawPath(
    Path()
      ..moveTo(cx - hR * 1.1, shoulderY)
      ..lineTo(cx - hR * 2.0, groundY)
      ..lineTo(cx + hR * 2.0, groundY)
      ..lineTo(cx + hR * 1.1, shoulderY)
      ..close(),
    Paint()..color = robe,
  );

  // Prayer hands — left arm at ~55°, right at ~125° (difference 70° ✓)
  // As openDeg rises, arms splay more: L→40°, R→140°
  final lA = _lerp(55, 40, prayerOpenDeg) * math.pi / 180;
  final rA = _lerp(125, 140, prayerOpenDeg) * math.pi / 180;
  final armLen = height * 0.28;
  final aP = Paint()
    ..color = skin
    ..strokeWidth = hR * 0.6
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final sy = shoulderY + hR * 0.5;
  canvas.drawLine(Offset(cx - hR * 0.7, sy),
      Offset(cx - hR * 0.7 + armLen * math.cos(lA), sy + armLen * math.sin(lA)), aP);
  canvas.drawLine(Offset(cx + hR * 0.7, sy),
      Offset(cx + hR * 0.7 + armLen * math.cos(rA), sy + armLen * math.sin(rA)), aP);

  // Head
  canvas.drawCircle(Offset(cx, headY), hR, Paint()..color = skin);

  // Eyes (closed in prayer — two arcs)
  final fP = Paint()
    ..color = const Color(0xFF78350F)
    ..strokeWidth = hR * 0.12
    ..style = PaintingStyle.stroke;
  canvas.drawArc(
    Rect.fromCenter(center: Offset(cx - hR * 0.3, headY - hR * 0.08),
        width: hR * 0.3, height: hR * 0.18),
    math.pi, math.pi, false, fP);
  canvas.drawArc(
    Rect.fromCenter(center: Offset(cx + hR * 0.3, headY - hR * 0.08),
        width: hR * 0.3, height: hR * 0.18),
    math.pi, math.pi, false, fP);
  // Peaceful smile
  canvas.drawArc(
    Rect.fromCenter(center: Offset(cx, headY + hR * 0.22),
        width: hR * 0.6, height: hR * 0.3),
    0.1, math.pi * 0.8, false, fP);
}

// ─────────────────────────────────────────────────────────────────────────────
// § 10  Story painters — 15 stories, each exactly 1 scene
//        (all childText are single paragraphs → StoryModel.scenes() returns 1)
// ─────────────────────────────────────────────────────────────────────────────

// ── 1. God Made Everything ────────────────────────────────────────────────────
// Intent: Light bursts from eternal darkness as God speaks creation into being.
// ANIM 1: golden light burst expanding from centre (t 0→1, radius 0→380)
// ANIM 2: stars fading in (t 0→0.65)
// ANIM 3: earth orb appearing at bottom (t 0.5→1)
class _CreationScenePainter extends ScenePainter {
  const _CreationScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Background — deep space (§ 4.4 ground darker than sky ✓ — no horizon needed)
    _sky(canvas, const Color(0xFF030718), const Color(0xFF0C1445));

    // Stars appear as light grows (ANIM 2, t 0→0.65)
    final sA = _cl(0, 0.9, t, 0, 0.65);
    _dot(canvas, 130, 140, 3, sA);
    _dot(canvas, 700, 80, 4, sA);
    _dot(canvas, 360, 210, 2.5, sA);
    _dot(canvas, 870, 250, 3, sA);
    _dot(canvas, 75, 340, 2.5, sA * 0.7);
    _dot(canvas, 590, 155, 3.5, sA);
    _dot(canvas, 920, 110, 2, sA * 0.8);
    _dot(canvas, 440, 75, 2.5, sA * 0.9);
    _dot(canvas, 240, 330, 2, sA * 0.6);
    _dot(canvas, 810, 175, 3, sA * 0.85);

    // Golden light burst (ANIM 1, t 0→1, radius 0→380)
    final lightR = _lerp(0, 380, t);
    if (lightR > 1) {
      canvas.drawCircle(
        const Offset(500, 440),
        lightR,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFDE68A),
            const Color(0xFFF59E0B).withValues(alpha: 0.6),
            const Color(0xFFD97706).withValues(alpha: 0),
          ], stops: const [0, 0.45, 1]).createShader(
            Rect.fromCircle(center: const Offset(500, 440), radius: lightR)),
      );
    }

    // Earth orb forms at bottom (ANIM 3, t 0.5→1)  — essential inside y 200–800
    final earthA = _cl(0, 1.0, t, 0.5, 1.0);
    if (earthA > 0) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(500, 830), width: 580, height: 200),
        Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: earthA),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(470, 820), width: 280, height: 100),
        Paint()..color = const Color(0xFF16A34A).withValues(alpha: earthA),
      );
    }
  }
}

// ── 2. God Made Me ────────────────────────────────────────────────────────────
// Intent: A child sits in warm light under stars, held in God's care.
// ANIM 1: light rays from above expanding (t 0.15→1)
// ANIM 2: stars brightening (t 0→0.7)
// Static: child figure (height 260, y 490–750), ground
class _GodMadeMeScenePainter extends ScenePainter {
  const _GodMadeMeScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    _sky(canvas, const Color(0xFF1E1B4B), const Color(0xFF4A2D6F));
    _ground(canvas, const Color(0xFF7C2D12), 750);

    // Stars (ANIM 2, t 0→0.7)
    final sA = _cl(0, 0.85, t, 0, 0.7);
    _dot(canvas, 110, 120, 3, sA);
    _dot(canvas, 760, 80, 3.5, sA);
    _dot(canvas, 340, 200, 2.5, sA);
    _dot(canvas, 890, 220, 3, sA);
    _dot(canvas, 195, 310, 2, sA);
    _dot(canvas, 660, 170, 4, sA);
    _dot(canvas, 450, 95, 2.5, sA * 0.8);
    _dot(canvas, 580, 260, 2, sA * 0.7);

    // Light rays from above (ANIM 1, t 0.15→1) — 5 rays, fan from y=0
    final rayLen = _cl(0, 400, t, 0.15, 1.0);
    final rayA = _cl(0, 0.45, t, 0.15, 1.0);
    if (rayLen > 0) {
      final rP = Paint()
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round;
      for (int i = -2; i <= 2; i++) {
        final ox = 500.0 + i * 55.0;
        final ex = 500.0 + i * 85.0;
        rP.color =
            const Color(0xFFFDE68A).withValues(alpha: rayA * (1 - i.abs() / 3.2));
        canvas.drawLine(Offset(ox, 0), Offset(ex, rayLen), rP);
      }
    }

    // Child figure — standing, arms slightly raised in wonder
    // armAngleL 230° (up-left), armAngleR 310° (up-right) → difference 80° ✓
    _person(canvas, 500, 750, 260,
        const Color(0xFFC89B7B), const Color(0xFF1D4ED8),
        armAngleL: 230, armAngleR: 310);
  }
}

// ── 3. Noah's Big Boat ────────────────────────────────────────────────────────
// Intent: The great ark rises on flood waters as the rain falls.
// ANIM 1: water level rising, ark floats up (t 0→1)
// ANIM 2: rain intensifying (t 0→0.6)
// ANIM 3: animal pair walking toward ark (t 0→0.8)
class _NoahScenePainter extends ScenePainter {
  const _NoahScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Stormy sky (§ 4.4 ground is water, darker than sky ✓)
    _sky(canvas, const Color(0xFF1E2939), const Color(0xFF374151));

    // Water level rises from y=700 to y=590 (ANIM 1)
    final wY = _lerp(700, 590, t);
    canvas.drawRect(
      Rect.fromLTWH(0, wY, 1000, 1000 - wY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [const Color(0xFF0369A1), const Color(0xFF164E63)],
        ).createShader(Rect.fromLTWH(0, wY, 1000, 1000 - wY)),
    );

    // Ark — sits on water surface, rises with it (ANIM 1)
    // Hull trapezoid (wider at waterline, narrower below — § 4.4 no wrong-shape road)
    final aBase = wY;
    canvas.drawPath(
      Path()
        ..moveTo(190, aBase - 120)
        ..lineTo(810, aBase - 120)
        ..lineTo(760, aBase)
        ..lineTo(240, aBase)
        ..close(),
      Paint()..color = const Color(0xFF92400E),
    );
    // Cabin
    canvas.drawRect(
      Rect.fromLTWH(300, aBase - 240, 400, 120),
      Paint()..color = const Color(0xFF78350F),
    );
    // Peaked roof (§ 4.1 silhouette: ark = box + triangle on top = identifiable)
    canvas.drawPath(
      Path()
        ..moveTo(280, aBase - 240)
        ..lineTo(500, aBase - 330)
        ..lineTo(720, aBase - 240)
        ..close(),
      Paint()..color = const Color(0xFF7C2D12),
    );
    // Porthole
    canvas.drawCircle(const Offset(500, 175),
        24, Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.55));

    // Rain lines (ANIM 2, t 0→0.6)
    final rA = _cl(0, 0.7, t, 0, 0.6);
    if (rA > 0) {
      final rP = Paint()
        ..color = const Color(0xFFBAE6FD).withValues(alpha: rA)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      const drops = [
        [100, 80], [260, 35], [430, 120], [620, 50], [790, 90],
        [150, 250], [370, 300], [560, 220], [870, 280], [50, 400],
        [310, 450], [680, 380], [920, 430],
      ];
      for (final d in drops) {
        canvas.drawLine(Offset(d[0].toDouble(), d[1].toDouble()),
            Offset(d[0] + 8.0, d[1] + 24.0), rP);
      }
    }

    // Animal silhouettes walking right-to-left toward ark (ANIM 3, t 0→0.8)
    // Start x=900 (off-right), end x=680 (near ark ramp)
    final anX = _cl(900, 680, t, 0, 0.8);
    final aP = Paint()..color = const Color(0xFF78350F);
    // Sheep-like blob
    canvas.drawOval(Rect.fromCenter(center: Offset(anX, wY - 45), width: 80, height: 45), aP);
    canvas.drawCircle(Offset(anX + 28, wY - 68), 22, aP);
    // Second animal (further right, slightly larger)
    final an2X = anX + 110;
    canvas.drawOval(Rect.fromCenter(center: Offset(an2X, wY - 55), width: 100, height: 55), aP);
    canvas.drawCircle(Offset(an2X + 35, wY - 82), 26, aP);
  }
}

// ── 4. Noah's Rainbow Promise ─────────────────────────────────────────────────
// Intent: A brilliant rainbow arches over calm water as God seals His promise.
// ANIM 1: rainbow arc growing from left to right (t 0→1, sweep 0→π)
// ANIM 2: sky clearing — colour shift (t 0→1)
// Static: water, 3 figures looking up at y≈730
class _RainbowScenePainter extends ScenePainter {
  const _RainbowScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Sky clears from stormy grey to bright blue (ANIM 2)
    final skyTop = Color.lerp(
        const Color(0xFF374151), const Color(0xFF0EA5E9), t)!;
    final skyBot = Color.lerp(
        const Color(0xFF6B7280), const Color(0xFF38BDF8), t)!;
    _sky(canvas, skyTop, skyBot);

    // Calm water (darker than sky ✓)
    canvas.drawRect(
      const Rect.fromLTWH(0, 700, 1000, 300),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0369A1), Color(0xFF164E63)],
        ).createShader(const Rect.fromLTWH(0, 700, 1000, 300)),
    );

    // Rainbow arc (ANIM 1, t 0→1, sweep 0→π) — drawn with clipping trick
    // Arc centre at (500, 700), radii from 260 to 380
    final sweep = _lerp(0, math.pi, t);
    if (sweep > 0.01) {
      final colours = [
        const Color(0xFFFF0000), // red
        const Color(0xFFFF8C00), // orange
        const Color(0xFFFFD700), // yellow
        const Color(0xFF00A86B), // green
        const Color(0xFF0047AB), // blue
        const Color(0xFF7B2FBE), // violet
      ];
      for (int i = 0; i < colours.length; i++) {
        final outerR = 380.0 - i * 18.0;
        final innerR = outerR - 14.0;
        final arcRect = Rect.fromCenter(
            center: const Offset(500, 710), width: outerR * 2, height: outerR * 2);
        // Upper semicircle: start left (π), sweep counterclockwise (−) to right via top.
        // negative sweep = counterclockwise in Flutter canvas.
        final path = Path()
          ..addArc(arcRect, math.pi, -sweep)
          ..arcTo(
            Rect.fromCenter(
                center: const Offset(500, 710),
                width: innerR * 2, height: innerR * 2),
            math.pi - sweep, sweep, false) // reverse: inner end→start, clockwise
          ..close();
        canvas.drawPath(path, Paint()..color = colours[i].withValues(alpha: 0.85));
      }
    }

    // Water reflection of rainbow (faint)
    if (t > 0.5) {
      final refA = _cl(0, 0.25, t, 0.5, 1.0);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(500, 770), width: 700, height: 80),
        Paint()
          ..color = const Color(0xFFFDE68A).withValues(alpha: refA)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
    }

    // Noah's family (3 figures, height 240 each) — essential inside y 490–730
    // armAngleL 230° (up-left), armAngleR 310° (up-right), difference 80° ✓
    _person(canvas, 340, 730, 240,
        const Color(0xFFC89B7B), const Color(0xFFD97706),
        armAngleL: 230, armAngleR: 310);
    _person(canvas, 500, 730, 260,
        const Color(0xFFA07850), const Color(0xFF7C2D12),
        armAngleL: 220, armAngleR: 320);
    _person(canvas, 660, 730, 230,
        const Color(0xFFC89B7B), const Color(0xFF78350F),
        armAngleL: 240, armAngleR: 300);
  }
}

// ── 5. Birth of Jesus ─────────────────────────────────────────────────────────
// Intent: The Christ child lies in a manger as the great star fills the stable.
// ANIM 1: star rays expanding (t 0→1)
// ANIM 2: warm glow around manger brightening (t 0.25→1)
// Static: stable outline, Mary & Joseph silhouettes
class _NativityScenePainter extends ScenePainter {
  const _NativityScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    _sky(canvas, const Color(0xFF030718), const Color(0xFF0C1445));
    _ground(canvas, const Color(0xFF92400E), 790);

    // Stable structure (drawn back-to-front per § 4.3)
    // Walls
    canvas.drawRect(const Rect.fromLTWH(200, 500, 600, 290),
        Paint()..color = const Color(0xFF7C2D12));
    // Roof
    canvas.drawPath(
      Path()
        ..moveTo(160, 500)
        ..lineTo(500, 320)
        ..lineTo(840, 500)
        ..close(),
      Paint()..color = const Color(0xFF78350F),
    );
    // Stable opening (arch of sky)
    canvas.drawOval(const Rect.fromLTWH(340, 500, 320, 200),
        Paint()..color = const Color(0xFF0C1445));

    // Manger glow (ANIM 2, t 0.25→1)
    final glowA = _cl(0, 0.8, t, 0.25, 1.0);
    canvas.drawCircle(const Offset(500, 720), 90,
        Paint()..color = const Color(0xFFFDE68A).withValues(alpha: glowA));
    // Manger box
    canvas.drawRect(const Rect.fromLTWH(440, 690, 120, 60),
        Paint()..color = const Color(0xFF92400E));
    // Baby silhouette in manger
    canvas.drawOval(Rect.fromCenter(center: Offset(500, 695), width: 80, height: 30),
        Paint()..color = const Color(0xFFFDE68A).withValues(alpha: glowA * 0.7));

    // Mary (left, kneeling-ish — drawn as short figure)
    // Mary — arms gently forward (115°/65° → diff 50° ✓)
    _person(canvas, 360, 780, 240,
        const Color(0xFFC89B7B), const Color(0xFF1D4ED8),
        armAngleL: 115, armAngleR: 65);

    // Joseph — arms at sides (120°/60° → diff 60° ✓)
    _person(canvas, 640, 780, 260,
        const Color(0xFFA07850), const Color(0xFF78350F));

    // Star at top — fixed point + expanding rays (ANIM 1, t 0→1)
    const sCx = 500.0; const sCy = 200.0;
    canvas.drawCircle(const Offset(sCx, sCy), 18,
        Paint()..color = const Color(0xFFFDE68A));
    final rayLen = _lerp(0, 220, t);
    if (rayLen > 0) {
      final rP = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8;
      for (int i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        final aI = _lerp(0, 0.8, t) * (1 - (i % 2) * 0.4); // alternate rays slightly dimmer
        rP.color = const Color(0xFFFDE68A).withValues(alpha: aI);
        canvas.drawLine(
          Offset(sCx + 20 * math.cos(a), sCy + 20 * math.sin(a)),
          Offset(sCx + rayLen * math.cos(a), sCy + rayLen * math.sin(a)),
          rP,
        );
      }
    }
  }
}

// ── 6. Jesus Loves Children ───────────────────────────────────────────────────
// Intent: Children run joyfully to Jesus, who opens his arms in welcome.
// ANIM 1: two children approaching from sides (t 0→0.8)
// ANIM 2: warm golden light around Jesus expanding (t 0→1)
// Static: Jesus centred, green hillside
class _JesusChildrenScenePainter extends ScenePainter {
  const _JesusChildrenScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    _sky(canvas, const Color(0xFF38BDF8), const Color(0xFFFBBF24));
    _ground(canvas, const Color(0xFF16A34A), 720);

    // Grass hill highlights
    canvas.drawOval(Rect.fromCenter(center: Offset(500, 720), width: 900, height: 120),
        Paint()..color = const Color(0xFF4ADE80).withValues(alpha: 0.4));

    // Warm aura around Jesus (ANIM 2, t 0→1, radius 0→180)
    final auraR = _lerp(0, 180, t);
    canvas.drawCircle(const Offset(500, 500), auraR,
        Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.35));

    // Jesus — centred, tall (300), arms wide to welcome
    // armAngleL 210° (up-left), armAngleR 330° (up-right) → diff 120° ✓
    _person(canvas, 500, 720, 300,
        const Color(0xFFC89B7B), const Color(0xFFF5F5F5),
        armAngleL: 210, armAngleR: 330, hasHalo: true);

    // Child 1 — running from left (ANIM 1, x: 100→330)
    final c1x = _cl(100, 330, t, 0, 0.8);
    _person(canvas, c1x, 720, 230,
        const Color(0xFFC89B7B), const Color(0xFFD97706),
        armAngleL: 200, armAngleR: 340); // arms behind — diff 140° ✓

    // Child 2 — running from right (x: 900→670)
    final c2x = _cl(900, 670, t, 0, 0.8);
    _person(canvas, c2x, 720, 220,
        const Color(0xFFA07850), const Color(0xFF10B981),
        armAngleL: 200, armAngleR: 340);
  }
}

// ── 7. David the Shepherd Boy ─────────────────────────────────────────────────
// Intent: Young David stands on a hillside, confident, sling in hand.
// ANIM 1: sunbeam brightening on David (t 0→1)
// ANIM 2: sling arm angle (t 0→0.5, arm raises; t 0.5→1, holds)
// Static: rolling green hills, two sheep
class _DavidScenePainter extends ScenePainter {
  const _DavidScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    _sky(canvas, const Color(0xFF38BDF8), const Color(0xFFBFDBFE));
    // Far hill
    canvas.drawOval(Rect.fromCenter(center: Offset(250, 720), width: 600, height: 260),
        Paint()..color = const Color(0xFF4ADE80));
    canvas.drawOval(Rect.fromCenter(center: Offset(750, 730), width: 550, height: 230),
        Paint()..color = const Color(0xFF34D399));
    _ground(canvas, const Color(0xFF16A34A), 730);

    // Sunbeam (ANIM 1, t 0→1) — diagonal shaft from upper-right
    final beamA = _lerp(0, 0.4, t);
    if (beamA > 0) {
      canvas.drawPath(
        Path()
          ..moveTo(700, 0)
          ..lineTo(900, 0)
          ..lineTo(560, 500)
          ..lineTo(450, 500)
          ..close(),
        Paint()..color = const Color(0xFFFDE68A).withValues(alpha: beamA),
      );
    }

    // David — centred-left, height 270
    // Right arm angle changes (ANIM 2): at t=0, right arm at 60° (relaxed);
    // at t=0.5+, right arm at 300° (raised to swing sling) → diff from left (120°) = 180° — too wide!
    // Fix: left 120°, right starts 60° → diff 60° ✓, rises to right at 20° → diff 100° ✓
    final rightArm = _cl(60, 20, t, 0, 0.5);
    _person(canvas, 420, 730, 270,
        const Color(0xFFC89B7B), const Color(0xFF7C2D12),
        armAngleL: 120, armAngleR: rightArm);

    // Sheep (static, behind David — drawn first actually)
    // Two sheep left of David
    final sP = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawOval(Rect.fromCenter(center: Offset(680, 710), width: 90, height: 50), sP);
    canvas.drawCircle(const Offset(710, 690), 22, sP);
    canvas.drawOval(Rect.fromCenter(center: Offset(810, 715), width: 80, height: 45), sP);
    canvas.drawCircle(const Offset(838, 698), 20, sP);
  }
}

// ── 8. Daniel and the Lions ───────────────────────────────────────────────────
// Intent: Daniel kneels in prayer as God's light shafts down through the den.
// ANIM 1: light shaft descending from ceiling (t 0→1, length 0→480)
// ANIM 2: Daniel's prayer arms opening slightly (t 0→0.5)
// Static: cave walls, two lion silhouettes
class _DanielScenePainter extends ScenePainter {
  const _DanielScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Cave interior — amber-brown walls (darker than any 'sky' — no horizon needed)
    _sky(canvas, const Color(0xFF451A03), const Color(0xFF78350F));
    // Cave floor
    _ground(canvas, const Color(0xFF92400E), 780);

    // Cave ceiling arch (top overlay)
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(1000, 0)
        ..lineTo(1000, 200)
        ..quadraticBezierTo(500, -80, 0, 200)
        ..close(),
      Paint()..color = const Color(0xFF451A03),
    );

    // Lion silhouettes — left and right (§ 4.1 silhouette test: ✓ recognisable)
    final lP = Paint()..color = const Color(0xFF7C2D12);
    // Left lion (body + head + mane)
    canvas.drawOval(Rect.fromCenter(center: Offset(180, 740), width: 220, height: 100), lP);
    canvas.drawCircle(const Offset(270, 700), 55, lP); // head+mane
    canvas.drawCircle(const Offset(270, 700), 38,
        Paint()..color = const Color(0xFFB45309)); // inner face

    // Right lion
    canvas.drawOval(Rect.fromCenter(center: Offset(820, 740), width: 220, height: 100), lP);
    canvas.drawCircle(const Offset(730, 700), 55, lP);
    canvas.drawCircle(const Offset(730, 700), 38,
        Paint()..color = const Color(0xFFB45309));

    // Light shaft from ceiling (ANIM 1, t 0→1, length 0→480)
    final shaftLen = _cl(0, 480, t, 0, 1.0);
    final shaftA = _cl(0, 0.7, t, 0, 1.0);
    if (shaftLen > 0) {
      canvas.drawPath(
        Path()
          ..moveTo(430, 120)
          ..lineTo(570, 120)
          ..lineTo(580 + shaftLen * 0.06, 120 + shaftLen)
          ..lineTo(420 - shaftLen * 0.06, 120 + shaftLen)
          ..close(),
        Paint()..color = const Color(0xFFFDE68A).withValues(alpha: shaftA),
      );
    }

    // Daniel kneeling in centre, arms in prayer (ANIM 2, openness 0→0.5)
    final open = _cl(0, 0.5, t, 0, 0.5);
    _kneeling(canvas, 500, 780, 240,
        const Color(0xFFC89B7B), const Color(0xFF1D4ED8),
        prayerOpenDeg: open);
  }
}

// ── 9. Jonah and the Big Fish ────────────────────────────────────────────────
// Intent: Jonah prays inside the great fish as light pierces the deep.
// ANIM 1: light shafts brightening (t 0→1)
// ANIM 2: Jonah's arms raising (t 0→0.6)
// Static: fish belly curves, dark water
class _JonahScenePainter extends ScenePainter {
  const _JonahScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Deep water — very dark (no sky/ground horizon, but interior is dark ✓)
    _sky(canvas, const Color(0xFF0C4A6E), const Color(0xFF082F49));

    // Fish belly walls — curved ribs (§ 4.1 silhouette: organic cave with arcs)
    final ribP = Paint()
      ..color = const Color(0xFF0369A1).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round;
    // Rib arcs on left and right
    for (int i = 0; i < 4; i++) {
      final y = 350.0 + i * 100.0;
      canvas.drawArc(Rect.fromCenter(center: Offset(-100, y), width: 600, height: 250),
          -math.pi / 3, math.pi / 2.5, false, ribP);
      canvas.drawArc(Rect.fromCenter(center: Offset(1100, y), width: 600, height: 250),
          math.pi * 0.65, math.pi / 2.5, false, ribP);
    }

    // Fish belly floor (darker than "sky") — § 4.4 ✓
    _ground(canvas, const Color(0xFF0369A1).withValues(alpha: 0.4), 760);

    // Light shafts from above (ANIM 1, t 0→1)
    final lA = _cl(0, 0.6, t, 0, 1.0);
    if (lA > 0) {
      final rP = Paint()..strokeWidth = 28..strokeCap = StrokeCap.round;
      for (final x in [360.0, 500.0, 640.0]) {
        rP.color =
            const Color(0xFFFDE68A).withValues(alpha: lA * (x == 500 ? 1.0 : 0.55));
        canvas.drawLine(Offset(x, 0), Offset(x, 500), rP);
      }
    }

    // Jonah — kneeling/sitting in belly, arms raising (ANIM 2, open 0→0.6)
    final open = _cl(0, 0.6, t, 0, 0.6);
    _kneeling(canvas, 500, 760, 260,
        const Color(0xFFC89B7B), const Color(0xFF0EA5E9),
        prayerOpenDeg: open);
  }
}

// ── 10. The Lost Sheep ────────────────────────────────────────────────────────
// Intent: The shepherd searches at sunset until the lost sheep is found.
// ANIM 1: shepherd walking left-to-right (t 0→0.7)
// ANIM 2: lost sheep appearing on far hillside (t 0.7→1)
// Static: rolling hills, warm sunset
class _LostSheepScenePainter extends ScenePainter {
  const _LostSheepScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Warm sunset sky (§ 4.4 horizon kept at y~400, away from y 450–550 ✓)
    _sky(canvas, const Color(0xFF7C2D12), const Color(0xFFD97706));
    // Horizon glow at y=400
    canvas.drawRect(const Rect.fromLTWH(0, 380, 1000, 80),
        Paint()..color = const Color(0xFFFBBF24).withValues(alpha: 0.5));

    // Far hill (back, lighter)
    canvas.drawOval(Rect.fromCenter(center: Offset(400, 560), width: 800, height: 280),
        Paint()..color = const Color(0xFF92400E));
    // Near ground (darker) — § 4.4 ground darker than sky ✓
    _ground(canvas, const Color(0xFF7C2D12), 680);
    canvas.drawOval(Rect.fromCenter(center: Offset(500, 680), width: 1200, height: 160),
        Paint()..color = const Color(0xFF78350F));

    // Shepherd walking (ANIM 1, x: 200→620, t 0→0.7)
    final shX = _cl(200, 620, t, 0, 0.7);
    // Walking: alternate arm angles for movement feel
    // armAngleL 120°, armAngleR 60° (relaxed at sides, difference 60° ✓)
    _person(canvas, shX, 760, 270,
        const Color(0xFFC89B7B), const Color(0xFFD97706));

    // Shepherd's crook
    canvas.drawLine(Offset(shX + 40, 700), Offset(shX + 50, 820),
        Paint()..color = const Color(0xFF92400E)..strokeWidth = 12..strokeCap = StrokeCap.round);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(shX + 38, 700), width: 40, height: 30),
      -math.pi * 0.7, math.pi * 1.2, false,
      Paint()..color = const Color(0xFF92400E)..strokeWidth = 12
          ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );

    // Lost sheep appearing (ANIM 2, t 0.7→1)
    final sheepA = _cl(0, 1.0, t, 0.7, 1.0);
    if (sheepA > 0) {
      final sP = Paint()..color = Colors.white.withValues(alpha: sheepA);
      canvas.drawOval(
          Rect.fromCenter(center: Offset(830, 580), width: 90, height: 50), sP);
      canvas.drawCircle(const Offset(860, 562), 22,
          Paint()..color = Colors.white.withValues(alpha: sheepA));
    }
  }
}

// ── 11. The Lost Son ──────────────────────────────────────────────────────────
// Intent: The father runs with arms open down a golden road toward his son.
// ANIM 1: father running toward son (x: 180→420, t 0→0.8)
// ANIM 2: father's arms spreading wide (t 0.6→1)
// ANIM 3: golden light around father expanding (t 0→1)
class _LostSonScenePainter extends ScenePainter {
  const _LostSonScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    _sky(canvas, const Color(0xFF0C1445), const Color(0xFFD97706));

    // Road — converging lines darker than surrounding land (§ 4.4 ✓)
    // Road is darker (brown-amber) than the surrounding orange/amber land
    canvas.drawPath(
      Path()
        ..moveTo(370, 800)
        ..lineTo(630, 800)
        ..lineTo(560, 500)
        ..lineTo(440, 500)
        ..close(),
      Paint()..color = const Color(0xFF7C2D12), // darker than landscape ✓
    );

    // Landscape (lighter than road) — § 4.4 ✓
    canvas.drawRect(const Rect.fromLTWH(0, 500, 1000, 300),
        Paint()..color = const Color(0xFF92400E));
    _ground(canvas, const Color(0xFF78350F), 800);

    // Son — small figure far down road (at x≈620, y≈620 perspective scale)
    // Essential subject still within y 200-800 ✓
    _person(canvas, 580, 640, 225,
        const Color(0xFFC89B7B), const Color(0xFF78350F));

    // Father running (ANIM 1, x: 180→420)
    final fatherX = _cl(180, 420, t, 0, 0.8);

    // Golden aura (ANIM 3, t 0→1, radius 0→130)
    final auraR = _lerp(0, 130, t);
    canvas.drawCircle(Offset(fatherX, 580), auraR,
        Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.35));

    // Father's arm angle: at t<0.6, arms at sides (120°,60°, diff 60° ✓);
    //                    at t=1, arms wide open for embrace (210°,330°, diff 120° ✓)
    final armProgress = _cl(0, 1.0, t, 0.6, 1.0);
    final fArmL = _lerp(120, 210, armProgress);
    final fArmR = _lerp(60, 330, armProgress);
    // Verify diff: at t=0: |120-60|=60✓; at t=1: |210-330|=120✓
    _person(canvas, fatherX, 760, 290,
        const Color(0xFFC89B7B), const Color(0xFFD97706),
        armAngleL: fArmL, armAngleR: fArmR);
  }
}

// ── 12. The Good Shepherd ─────────────────────────────────────────────────────
// Intent: The shepherd carries the found sheep on his shoulders at dusk.
// ANIM 1: dusk sky darkening, warm amber glow intensifying (t 0→1)
// ANIM 2: sheep settling on shoulders (t 0→0.5)
// Static: shepherd figure carrying sheep
class _GoodShepherdScenePainter extends ScenePainter {
  const _GoodShepherdScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Dusk sky deepens (ANIM 1)
    final skyTop = Color.lerp(const Color(0xFFD97706), const Color(0xFF7C2D12), t)!;
    final skyBot = Color.lerp(const Color(0xFFFBBF24), const Color(0xFFD97706), t)!;
    _sky(canvas, skyTop, skyBot);

    // Ground — darker than sky ✓
    _ground(canvas, const Color(0xFF7C2D12), 740);
    // Distant rolling hill silhouette
    canvas.drawOval(
        Rect.fromCenter(center: Offset(500, 700), width: 1100, height: 220),
        Paint()..color = const Color(0xFF78350F));

    // Warm amber glow intensifying (ANIM 1)
    final glowA = _lerp(0.1, 0.5, t);
    canvas.drawCircle(const Offset(500, 560), 200,
        Paint()..color = const Color(0xFFFBBF24).withValues(alpha: glowA));

    // Shepherd — centred, 300 tall, arms slightly raised for carrying
    // armAngleL 250° (up-left holding sheep), armAngleR 290° (up-right holding sheep)
    // diff = |250-290| = 40° — just at minimum ✓
    _person(canvas, 500, 740, 300,
        const Color(0xFFC89B7B), const Color(0xFF92400E),
        armAngleL: 250, armAngleR: 290);

    // Sheep across shoulders — settles (ANIM 2, t 0→0.5)
    // At t=0 sheep is slightly above; at t=0.5+ it rests on shoulders
    final sheepY = _cl(460, 500, t, 0, 0.5);
    final sheepA = _cl(0, 1.0, t, 0, 0.5);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(500, sheepY), width: 150, height: 60),
        Paint()..color = Colors.white.withValues(alpha: sheepA));
    // Sheep head
    canvas.drawCircle(Offset(560, sheepY - 15), 26,
        Paint()..color = Colors.white.withValues(alpha: sheepA));
    // Sheep legs dangling
    if (sheepA > 0) {
      final lP = Paint()..color = const Color(0xFFD1D5DB).withValues(alpha: sheepA)
          ..strokeWidth = 10..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(445, sheepY + 20), Offset(435, sheepY + 60), lP);
      canvas.drawLine(Offset(465, sheepY + 22), Offset(458, sheepY + 62), lP);
      canvas.drawLine(Offset(535, sheepY + 22), Offset(542, sheepY + 62), lP);
      canvas.drawLine(Offset(555, sheepY + 20), Offset(565, sheepY + 60), lP);
    }
  }
}

// ── 13. How to Pray ───────────────────────────────────────────────────────────
// Intent: A child kneels by a sunlit window, hands folded in quiet prayer.
// ANIM 1: window light rays expanding (t 0→1)
// ANIM 2: warm glow around child building (t 0.3→1)
// Static: room walls, window frame, kneeling child
class _PrayerScenePainter extends ScenePainter {
  const _PrayerScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Warm interior — cream walls (§ 4.4 no sky/ground confusion for interior ✓)
    _sky(canvas, const Color(0xFFFDF6E3), const Color(0xFFF5E6C8));
    _ground(canvas, const Color(0xFF92400E), 820); // floor

    // Window (on left wall) — golden sky outside
    canvas.drawRect(const Rect.fromLTWH(120, 280, 200, 260),
        Paint()..color = const Color(0xFFFDE68A));
    canvas.drawRect(const Rect.fromLTWH(120, 280, 200, 260),
        Paint()..color = const Color(0xFF78350F)..style = PaintingStyle.stroke..strokeWidth = 16);
    // Window cross-bar
    canvas.drawLine(const Offset(220, 280), const Offset(220, 540),
        Paint()..color = const Color(0xFF78350F)..strokeWidth = 10);
    canvas.drawLine(const Offset(120, 410), const Offset(320, 410),
        Paint()..color = const Color(0xFF78350F)..strokeWidth = 10);

    // Light fan from window (ANIM 1, t 0→1)
    final rayLen = _lerp(0, 650, t);
    final rayA = _lerp(0, 0.4, t);
    if (rayLen > 0) {
      final rP = Paint()..strokeCap = StrokeCap.round;
      for (int i = -1; i <= 3; i++) {
        final oy = 350.0 + i * 45.0;
        final ex = 320.0 + rayLen;
        final ey = 350.0 + i * 90.0;
        rP.color = const Color(0xFFFDE68A)
            .withValues(alpha: rayA * (1 - i.abs() / 5.0).clamp(0.1, 1.0));
        rP.strokeWidth = 24;
        canvas.drawLine(Offset(320, oy), Offset(ex, ey), rP);
      }
    }

    // Warm glow around child (ANIM 2, t 0.3→1)
    final glowA = _cl(0, 0.3, t, 0.3, 1.0);
    canvas.drawCircle(const Offset(550, 640), 130,
        Paint()..color = const Color(0xFFFBBF24).withValues(alpha: glowA));

    // Kneeling child — arms in prayer
    _kneeling(canvas, 550, 820, 245,
        const Color(0xFFC89B7B), const Color(0xFF1D4ED8));
  }
}

// ── 14. The Good Neighbour ────────────────────────────────────────────────────
// Intent: The Samaritan kneels to bind the wounds of the injured man.
// ANIM 1: Samaritan leaning forward (t 0→0.6)
// ANIM 2: warm healing glow brightening (t 0→1)
// Static: road (converging, dark), injured man, far landscape
class _GoodNeighbourScenePainter extends ScenePainter {
  const _GoodNeighbourScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    _sky(canvas, const Color(0xFF0C1445), const Color(0xFFD97706));

    // Landscape — amber hills
    canvas.drawOval(Rect.fromCenter(center: Offset(250, 600), width: 600, height: 200),
        Paint()..color = const Color(0xFF92400E));
    canvas.drawOval(Rect.fromCenter(center: Offset(800, 620), width: 500, height: 180),
        Paint()..color = const Color(0xFF7C2D12));

    // Road — converging lines, darker than surroundings (§ 4.4 ✓)
    canvas.drawPath(
      Path()
        ..moveTo(300, 820)
        ..lineTo(700, 820)
        ..lineTo(580, 500)
        ..lineTo(420, 500)
        ..close(),
      Paint()..color = const Color(0xFF78350F),
    );
    _ground(canvas, const Color(0xFF92400E), 820);

    // Injured man — lying on roadside, y~730, horizontal
    canvas.drawOval(
        Rect.fromCenter(center: Offset(600, 735), width: 200, height: 65),
        Paint()..color = const Color(0xFFA07850));
    canvas.drawCircle(const Offset(690, 720), 32,
        Paint()..color = const Color(0xFFC89B7B));

    // Warm healing glow (ANIM 2, t 0→1)
    final glowA = _lerp(0, 0.4, t);
    canvas.drawCircle(const Offset(550, 680), 160,
        Paint()..color = const Color(0xFFFDE68A).withValues(alpha: glowA));

    // Samaritan kneeling to help — leans forward (ANIM 1, t 0→0.6)
    // Leaning is represented by x moving toward injured man
    final samX = _cl(440, 490, t, 0, 0.6);
    _kneeling(canvas, samX, 790, 240,
        const Color(0xFFC89B7B), const Color(0xFFD97706),
        prayerOpenDeg: _cl(0, 0.3, t, 0, 0.6));
  }
}

// ── 15. Jesus Saves ───────────────────────────────────────────────────────────
// Intent: The tomb stands empty at dawn — the stone rolled away, light flooding in.
// ANIM 1: dawn light expanding from horizon (t 0→1)
// ANIM 2: stone rolling away from entrance (t 0→0.55)
// ANIM 3: light flooding tomb opening (t 0.35→1)
class _JesusSavesScenePainter extends ScenePainter {
  const _JesusSavesScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=430 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 430.0;

    // Dawn sky (ANIM 1: dark blue → bright gold/orange at horizon)
    final skyTop = Color.lerp(const Color(0xFF030718), const Color(0xFF0C1445), 1 - t * 0.6)!;
    final skyMid = Color.lerp(const Color(0xFF451A03), const Color(0xFFD97706), t)!;
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 1000, kHorizon),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [skyTop, skyMid],
        ).createShader(const Rect.fromLTWH(0, 0, 1000, kHorizon)),
    );

    // Sunrise glow from horizon (ANIM 1, t 0→1)
    final glowR = _lerp(0, 450, t);
    canvas.drawCircle(const Offset(500, kHorizon), glowR,
        Paint()..color = const Color(0xFFFBBF24).withValues(alpha: _lerp(0, 0.7, t)));

    // Ground — rocky hillside, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF7C2D12), kHorizon);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(500, kHorizon), width: 1200, height: 200),
        Paint()..color = const Color(0xFF92400E));

    // Tomb opening — dark arch cut into hillside (centre at y≈570, within safe zone)
    canvas.drawOval(const Rect.fromLTWH(350, 490, 300, 270),
        Paint()..color = const Color(0xFF0C1445));

    // Light flooding tomb interior (ANIM 3, t 0.35→1)
    final inA = _cl(0, 0.85, t, 0.35, 1.0);
    if (inA > 0) {
      canvas.drawOval(const Rect.fromLTWH(368, 505, 264, 242),
          Paint()..color = const Color(0xFFFDE68A).withValues(alpha: inA));
      canvas.drawOval(const Rect.fromLTWH(350, 490, 300, 270),
          Paint()..color = const Color(0xFF0C1445)
              ..style = PaintingStyle.stroke..strokeWidth = 20);
    }

    // Stone — rolls away from entrance (ANIM 2, t 0→0.55)
    final stoneX = _cl(500, 260, t, 0, 0.55);
    canvas.drawCircle(Offset(stoneX, 640), 100, Paint()..color = const Color(0xFF78350F));
    canvas.drawCircle(Offset(stoneX, 640), 100,
        Paint()..color = const Color(0xFF92400E)..style = PaintingStyle.stroke..strokeWidth = 8);
    canvas.drawLine(Offset(stoneX - 50, 620), Offset(stoneX + 50, 660),
        Paint()..color = const Color(0xFF7C2D12)..strokeWidth = 8);

    // Sun cresting horizon when dawn is complete (t 0.7→1)
    final sunA = _cl(0, 1.0, t, 0.7, 1.0);
    if (sunA > 0) {
      canvas.drawCircle(const Offset(500, kHorizon), 55,
          Paint()..color = const Color(0xFFFDE68A).withValues(alpha: sunA));
    }
  }
}
