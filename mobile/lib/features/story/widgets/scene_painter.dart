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
  'the-first-family':       [_FirstFamilyScenePainter.new],
  'the-very-sad-choice':    [_SadChoiceScenePainter.new],
  'god-promises-a-rescuer': [_RescuerPromiseScenePainter.new],
  'two-brothers':           [_TwoBrothersScenePainter.new],
  'noahs-big-boat':         [_NoahScenePainter.new],
  'noahs-rainbow-promise':  [_RainbowScenePainter.new],
  'the-tall-tower':            [_TallTowerScenePainter.new],
  'god-calls-abraham':         [_AbrahamCallScenePainter.new],
  'stars-in-the-sky':          [_StarsScenePainter.new],
  'the-promised-son':          [_PromisedSonScenePainter.new],
  'god-provides-a-lamb':       [_ProvidesLambScenePainter.new],
  'jacob-learns-grace':        [_JacobScenePainter.new],
  'joseph-and-his-brothers':   [_JosephBrothersScenePainter.new],
  'joseph-forgives-his-family':[_JosephForgivesScenePainter.new],
  'baby-moses-is-kept-safe':   [_BabyMosesScenePainter.new],
  'god-calls-from-the-fire':   [_BurningBushScenePainter.new],
  'let-my-people-go':          [_LetMyPeopleGoScenePainter.new],
  'the-passover-lamb':         [_PassoverScenePainter.new],
  'a-way-through-the-sea':     [_ThroughTheSeaScenePainter.new],
  'bread-in-the-wilderness':   [_MannaScenePainter.new],
  'gods-good-commands':        [_CommandsScenePainter.new],
  'god-lives-with-his-people': [_TabernacleScenePainter.new],
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

  // Neck — bridges head to shoulders so the head never reads as floating (§ 4.2)
  canvas.drawRect(
    Rect.fromLTRB(cx - hR * 0.36, headY + hR * 0.6, cx + hR * 0.36, shoulderY + 2),
    Paint()..color = skin,
  );

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

  // Neck — bridges head to shoulders so the head never reads as floating (§ 4.2)
  canvas.drawRect(
    Rect.fromLTRB(cx - hR * 0.34, headY + hR * 0.6, cx + hR * 0.34, shoulderY + 2),
    Paint()..color = skin,
  );

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

// ── 16. The First Family with God ─────────────────────────────────────────────
// Intent: Two people stand together in God's garden under His life-giving light —
//         nobody here is alone.
// ANIM 1: breath-of-life glow descending and widening (t 0→1)
// ANIM 2: fruit appearing on the garden tree (t 0.35→1)
// ANIM 3: the two figures stepping toward each other (t 0→0.7)
class _FirstFamilyScenePainter extends ScenePainter {
  const _FirstFamilyScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=640 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 640.0;

    _sky(canvas, const Color(0xFF38BDF8), const Color(0xFFFEF3C7));

    // Breath-of-life glow — descends from above and widens (ANIM 1)
    // Radial falloff so it reads as light, not as a pale dome (§ 4.4).
    final glowC = Offset(500, _lerp(110, 290, t));
    final glowR = _lerp(90, 340, t);
    canvas.drawCircle(
      glowC,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE68A).withValues(alpha: _lerp(0.40, 0.62, t)),
            const Color(0xFFFDE68A).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: glowC, radius: glowR)),
    );

    // Ground — garden green, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF14532D), kHorizon);
    // Nearer grass bank, darker still, so ground reads as a receding plane
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1020), width: 1700, height: 640),
      Paint()..color = const Color(0xFF124A28),
    );

    // River running through Eden (Genesis 2:10) — static
    canvas.drawPath(
      Path()
        ..moveTo(0, kHorizon + 34)
        ..quadraticBezierTo(320, kHorizon + 6, 570, kHorizon + 66)
        ..quadraticBezierTo(820, kHorizon + 126, 1000, kHorizon + 84)
        ..lineTo(1000, kHorizon + 148)
        ..quadraticBezierTo(790, kHorizon + 188, 545, kHorizon + 128)
        ..quadraticBezierTo(310, kHorizon + 70, 0, kHorizon + 98)
        ..close(),
      Paint()..color = const Color(0xFF0E7490),
    );

    // Garden tree — trunk + three-lobe canopy (silhouette reads as "tree" § 4.1)
    canvas.drawRect(const Rect.fromLTWH(152, 420, 46, 240),
        Paint()..color = const Color(0xFF78350F));
    final canopy = Paint()..color = const Color(0xFF15803D);
    canvas.drawCircle(const Offset(175, 372), 122, canopy);
    canvas.drawCircle(const Offset(78, 424), 86, canopy);
    canvas.drawCircle(const Offset(272, 424), 86, canopy);

    // Fruit appearing on the tree (ANIM 2, t 0.35→1)
    final fruitA = _cl(0, 1, t, 0.35, 1.0);
    if (fruitA > 0) {
      final fP = Paint()..color = const Color(0xFFDC2626).withValues(alpha: fruitA);
      const fruit = [[112, 352], [212, 328], [162, 440], [258, 396], [72, 442]];
      for (final f in fruit) {
        canvas.drawCircle(Offset(f[0].toDouble(), f[1].toDouble()), 17, fP);
      }
    }

    // The first two people — stepping toward each other (ANIM 3, t 0→0.7)
    // Feet at y=778 so the whole figure survives the widest crop (y 208–792).
    // § 4.2 limb rule: 120°/10° = 110° apart ✓ ; 170°/60° = 110° apart ✓
    _person(canvas, _cl(370, 432, t, 0, 0.7), 778, 286,
        const Color(0xFF8D5524), const Color(0xFF1D4ED8),
        armAngleL: 120, armAngleR: 10);
    _person(canvas, _cl(658, 594, t, 0, 0.7), 778, 270,
        const Color(0xFFC68642), const Color(0xFFBE185D),
        armAngleL: 170, armAngleR: 60);
  }
}

// ── 17. The Very Sad Choice ───────────────────────────────────────────────────
// Intent: Two people turn away from the light and into the shadow of one tree —
//         the garden is still there, but something has gone out of it.
// ANIM 1: the garden's warm light draining away (t 0→1)
// ANIM 2: shadow spreading across the ground from the right (t 0.2→1)
// ANIM 3: the two figures walking away toward the shadow (t 0→0.8)
class _SadChoiceScenePainter extends ScenePainter {
  const _SadChoiceScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=630 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 630.0;

    _sky(canvas, const Color(0xFF312E81), const Color(0xFFC4B5FD));

    // The garden's warm light draining away (ANIM 1, t 0→1)
    const lightC = Offset(320, 210);
    const lightR = 330.0;
    canvas.drawCircle(
      lightC,
      lightR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE68A).withValues(alpha: _lerp(0.55, 0.06, t)),
            const Color(0xFFFDE68A).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: lightC, radius: lightR)),
    );

    // Ground — mid earth, still clearly darker than sky (§ 4.4 ✓).
    // Kept mid-tone so ANIM 2's shadow has something to fall across.
    _ground(canvas, const Color(0xFF6B4B2A), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1030), width: 1700, height: 660),
      Paint()..color = const Color(0xFF5B3F22),
    );

    // The one tree — trunk + canopy, right of centre so the figures have room
    canvas.drawRect(const Rect.fromLTWH(688, 396, 54, 254),
        Paint()..color = const Color(0xFF44291A));
    final canopy = Paint()..color = const Color(0xFF14532D);
    canvas.drawCircle(const Offset(715, 336), 128, canopy);
    canvas.drawCircle(const Offset(616, 392), 86, canopy);
    canvas.drawCircle(const Offset(814, 392), 86, canopy);

    // Fruit on the tree — static, three only, so it reads as "that one tree"
    final fP = Paint()..color = const Color(0xFFB91C1C);
    for (final f in const [[656, 366], [762, 340], [716, 428]]) {
      canvas.drawCircle(Offset(f[0].toDouble(), f[1].toDouble()), 18, fP);
    }

    // The snake — wound down the trunk with a visible head, so it reads as a
    // snake rather than a squiggle. Small, calm, no fangs (§ child safety).
    final snakeP = Paint()
      ..color = const Color(0xFF3F6212)
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(760, 470)
        ..quadraticBezierTo(686, 488, 700, 528)
        ..quadraticBezierTo(716, 566, 668, 586)
        ..quadraticBezierTo(624, 604, 618, 566),
      snakeP,
    );
    canvas.drawCircle(const Offset(618, 560), 15, Paint()..color = const Color(0xFF4D7C0F));
    canvas.drawCircle(const Offset(613, 555), 4, Paint()..color = const Color(0xFF1C1917));

    // Shadow spreading across the ground from the right (ANIM 2, t 0.2→1)
    final shW = _cl(0, 1000, t, 0.2, 1.0);
    if (shW > 0) {
      canvas.drawRect(
        Rect.fromLTWH(1000 - shW, kHorizon, shW, 1000 - kHorizon),
        Paint()..color = const Color(0xFF1C1917).withValues(alpha: 0.5),
      );
    }

    // The two people — walking away from the light (ANIM 3, t 0→0.8)
    // Feet at y≤780 so the whole figure survives the widest crop (y 208–792).
    // § 4.2 limb rule: 115°/65° = 50° apart ✓ ; 125°/55° = 70° apart ✓
    _person(canvas, _cl(470, 396, t, 0, 0.8), 778, 282,
        const Color(0xFF8D5524), const Color(0xFF3730A3),
        armAngleL: 115, armAngleR: 65);
    _person(canvas, _cl(316, 232, t, 0, 0.8), 782, 262,
        const Color(0xFFC68642), const Color(0xFF6D28D9),
        armAngleL: 125, armAngleR: 55);
  }
}

// ── 18. God Promises a Rescuer ────────────────────────────────────────────────
// Intent: One bright star rises over the closed garden gate and lays a path of
//         light on the ground in front of the two who have to leave.
// ANIM 1: the promise star rising and brightening (t 0→0.8)
// ANIM 2: the path of light widening across the ground (t 0.3→1)
// ANIM 3: the surrounding stars fading in (t 0.45→1)
class _RescuerPromiseScenePainter extends ScenePainter {
  const _RescuerPromiseScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=690 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 690.0;

    _sky(canvas, const Color(0xFF0C1445), const Color(0xFF3730A3));

    // The star's position and size (ANIM 1, t 0→0.8)
    final starY = _cl(430, 258, t, 0, 0.8);
    final starR = _cl(24, 52, t, 0, 0.8);
    const starX = 690.0;

    // Surrounding stars fading in (ANIM 3, t 0.45→1)
    final dotA = _cl(0, 0.9, t, 0.45, 1.0);
    const dots = [
      [110, 150, 5], [232, 96, 4], [352, 190, 5], [148, 300, 4],
      [452, 108, 4], [846, 168, 5], [930, 300, 4], [782, 92, 4],
      [60, 420, 4], [560, 250, 4],
    ];
    for (final d in dots) {
      _dot(canvas, d[0].toDouble(), d[1].toDouble(), d[2].toDouble(), dotA);
    }

    // Ground — dark earth outside the garden, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF241A14), kHorizon);

    // Light lying on the ground beneath the star (ANIM 2, t 0.3→1).
    // A flat ellipse, NOT a tapering wedge — a wedge reads as a mountain (§ 4.4).
    final poolW = _cl(0, 900, t, 0.3, 1.0);
    if (poolW > 0) {
      final poolRect = Rect.fromCenter(
          center: const Offset(starX, 860), width: poolW, height: poolW * 0.34);
      canvas.drawOval(
        poolRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: 0.34),
              const Color(0xFFFDE68A).withValues(alpha: 0.0),
            ],
          ).createShader(poolRect),
      );
    }

    // Garden gate — two posts and an arch, closed behind them (§ 4.1 silhouette)
    final stone = Paint()..color = const Color(0xFF44403C);
    canvas.drawRect(const Rect.fromLTWH(112, 402, 56, 288), stone);
    canvas.drawRect(const Rect.fromLTWH(320, 402, 56, 288), stone);
    canvas.drawArc(const Rect.fromLTWH(112, 300, 264, 210), math.pi, math.pi, false,
        Paint()
          ..color = const Color(0xFF44403C)
          ..strokeWidth = 56
          ..style = PaintingStyle.stroke);

    // The star itself — a soft halo plus an eight-point star shape, so it reads
    // as a star and not as a moon (the earlier disc+cross did the latter).
    final haloRect = Rect.fromCircle(center: Offset(starX, starY), radius: starR * 3.2);
    canvas.drawOval(
      haloRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE68A).withValues(alpha: _lerp(0.28, 0.5, t)),
            const Color(0xFFFDE68A).withValues(alpha: 0.0),
          ],
        ).createShader(haloRect),
    );
    final starPath = Path();
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final b = a + math.pi / 8;
      final long = (i.isEven ? starR * 2.5 : starR * 1.7);
      final x1 = starX + long * math.cos(a);
      final y1 = starY + long * math.sin(a);
      final x2 = starX + starR * 0.52 * math.cos(b);
      final y2 = starY + starR * 0.52 * math.sin(b);
      if (i == 0) {
        starPath.moveTo(x1, y1);
      } else {
        starPath.lineTo(x1, y1);
      }
      starPath.lineTo(x2, y2);
    }
    starPath.close();
    canvas.drawPath(starPath, Paint()..color = const Color(0xFFFEF3C7));

    // The two people, leaving the garden but turned toward the promise.
    // Feet at y≤780 so the whole figure survives the widest crop (y 208–792).
    // § 4.2 limb rule: 140°/45° = 95° apart ✓ ; 118°/62° = 56° apart ✓
    _person(canvas, 452, 776, 268, const Color(0xFF8D5524), const Color(0xFF7C2D12),
        armAngleL: 140, armAngleR: 45);
    _person(canvas, 286, 782, 246, const Color(0xFFC68642), const Color(0xFF831843),
        armAngleL: 118, armAngleR: 62);
  }
}

// ── 19. Two Brothers and Jealous Hearts ───────────────────────────────────────
// Intent: Two gifts on two altars — one smoke rises straight up to God, the other
//         drifts low along the ground — and Cain stands between them, deciding.
// ANIM 1: Abel's smoke rising straight upward (t 0→1)
// ANIM 2: Cain's smoke drifting sideways and staying low (t 0→1)
// ANIM 3: God's warm light widening above (t 0.4→1)
class _TwoBrothersScenePainter extends ScenePainter {
  const _TwoBrothersScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=660 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 660.0;

    _sky(canvas, const Color(0xFFFBBF24), const Color(0xFFB45309));

    // God's warm light widening above Abel's altar (ANIM 3, t 0.4→1)
    final lightR = _cl(0, 300, t, 0.4, 1.0);
    if (lightR > 0) {
      final lightRect = Rect.fromCircle(center: const Offset(752, 150), radius: lightR);
      canvas.drawOval(
        lightRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.46),
              const Color(0xFFFEF3C7).withValues(alpha: 0.0),
            ],
          ).createShader(lightRect),
      );
    }

    // Ground — dry field, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF451A03), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1040), width: 1700, height: 680),
      Paint()..color = const Color(0xFF3B1503),
    );

    // Cain's smoke — drifts left and stays low (ANIM 2, t 0→1).
    // Travels away from Cain (who stands at x≈500) so it never crosses his head.
    final cDX = _lerp(0, -172, t);
    final cDY = _lerp(0, -46, t);
    for (int i = 0; i < 5; i++) {
      final f = i / 4.0;
      canvas.drawCircle(
        Offset(268 + cDX * f, 600 + cDY * f),
        18 + f * 20,
        Paint()..color = const Color(0xFF57534E).withValues(alpha: 0.55 - f * 0.34),
      );
    }

    // Abel's smoke — rises straight up to God (ANIM 1, t 0→1)
    final aH = _lerp(0, 388, t);
    for (int i = 0; i < 6; i++) {
      final f = i / 5.0;
      canvas.drawCircle(
        Offset(752, 600 - aH * f),
        16 + f * 24,
        Paint()..color = const Color(0xFFFEF3C7).withValues(alpha: 0.72 - f * 0.44),
      );
    }

    // Two altars — stacked stone blocks (§ 4.1 identifiable silhouette)
    final stone = Paint()..color = const Color(0xFF78716C);
    final stoneDark = Paint()..color = const Color(0xFF57534E);
    // Cain's altar (far left) — sheaves of grain on top
    canvas.drawRect(const Rect.fromLTWH(190, 614, 156, 102), stone);
    canvas.drawRect(const Rect.fromLTWH(170, 694, 196, 40), stoneDark);
    final grain = Paint()
      ..color = const Color(0xFFCA8A04)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(238, 612), const Offset(224, 562), grain);
    canvas.drawLine(const Offset(268, 612), const Offset(268, 556), grain);
    canvas.drawLine(const Offset(298, 612), const Offset(312, 562), grain);
    // Abel's altar (far right) — a lamb on top: body, head, ear and legs
    canvas.drawRect(const Rect.fromLTWH(674, 614, 156, 102), stone);
    canvas.drawRect(const Rect.fromLTWH(654, 694, 196, 40), stoneDark);
    final legP = Paint()
      ..color = const Color(0xFF57534E)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(716, 600), const Offset(716, 616), legP);
    canvas.drawLine(const Offset(766, 600), const Offset(766, 616), legP);
    final wool = Paint()..color = const Color(0xFFFAFAF9);
    canvas.drawOval(const Rect.fromLTWH(694, 546, 116, 58), wool);
    canvas.drawCircle(const Offset(806, 558), 21, wool);
    canvas.drawCircle(const Offset(816, 540), 9, Paint()..color = const Color(0xFFE7E5E4));
    canvas.drawCircle(const Offset(813, 556), 4, Paint()..color = const Color(0xFF44403C));

    // Cain — standing between the two altars, arms down, deciding.
    // Feet at y=778 so the whole figure survives the widest crop (y 208–792).
    // § 4.2 limb rule: 112°/68° = 44° apart ✓
    _person(canvas, 500, 778, 292, const Color(0xFF8D5524), const Color(0xFF7C2D12),
        armAngleL: 112, armAngleR: 68);
  }
}

// ── 20. The Tall Tower ────────────────────────────────────────────────────────
// Intent: However high people stack their bricks, God has to come DOWN to look
//         at it — the tower is tiny under an enormous sky.
// ANIM 1: the tower gaining its upper tiers (t 0→0.6)
// ANIM 2: God's light coming down from above (t 0.35→1)
// ANIM 3: the people scattering outward as their words are mixed (t 0.65→1)
class _TallTowerScenePainter extends ScenePainter {
  const _TallTowerScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=700 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 700.0;

    _sky(canvas, const Color(0xFF60A5FA), const Color(0xFFFEF3C7));

    // God's light coming DOWN from above the tower (ANIM 2, t 0.35→1).
    // Drawn as a soft descending disc, never a wedge (§ 4.4 no wrong-shape road).
    final beamY = _cl(60, 300, t, 0.35, 1.0);
    final beamR = _cl(60, 300, t, 0.35, 1.0);
    if (beamR > 0) {
      final beamRect = Rect.fromCircle(center: Offset(500, beamY), radius: beamR);
      canvas.drawOval(
        beamRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.55),
              const Color(0xFFFEF3C7).withValues(alpha: 0.0),
            ],
          ).createShader(beamRect),
      );
    }

    // Ground — dusty plain, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF92400E), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1060), width: 1700, height: 700),
      Paint()..color = const Color(0xFF7C2D12),
    );

    // Stepped tower — four tiers, the top two arriving with ANIM 1 (t 0→0.6).
    // Each tier is a plain block: the stacked silhouette reads as "tower" (§ 4.1).
    final brick = Paint()..color = const Color(0xFFC2703B);
    final brickDark = Paint()..color = const Color(0xFFA1522B);
    const tiers = [
      [280.0, 620.0, 440.0, 80.0],
      [320.0, 540.0, 360.0, 80.0],
      [360.0, 460.0, 280.0, 80.0],
      [400.0, 380.0, 200.0, 80.0],
    ];
    final builtTiers = _cl(2, 4, t, 0, 0.6);
    for (int i = 0; i < tiers.length; i++) {
      if (i >= builtTiers) break;
      final tier = tiers[i];
      canvas.drawRect(Rect.fromLTWH(tier[0], tier[1], tier[2], tier[3]),
          i.isEven ? brick : brickDark);
      // Brick courses so the block reads as masonry, not a plain box
      final line = Paint()
        ..color = const Color(0xFF7C2D12).withValues(alpha: 0.4)
        ..strokeWidth = 3;
      canvas.drawLine(Offset(tier[0], tier[1] + 40), Offset(tier[0] + tier[2], tier[1] + 40), line);
    }

    // Ramp up the side — a flat parallelogram, not a triangle (§ 4.4)
    canvas.drawPath(
      Path()
        ..moveTo(280, 700)
        ..lineTo(360, 620)
        ..lineTo(400, 620)
        ..lineTo(320, 700)
        ..close(),
      Paint()..color = const Color(0xFF7C2D12),
    );

    // People scattering as their words are mixed up (ANIM 3, t 0.65→1)
    final spread = _cl(0, 300, t, 0.65, 1.0);
    final peopleA = _cl(1.0, 0.45, t, 0.65, 1.0);
    final pP = Paint()..color = const Color(0xFF44290F).withValues(alpha: peopleA);
    for (final dir in const [-1, 1]) {
      for (int i = 0; i < 3; i++) {
        final x = 500 + dir * (110 + i * 70 + spread);
        final y = 748 + i * 22.0;
        canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 26, height: 44), pP);
        canvas.drawCircle(Offset(x, y - 34), 15, pP);
      }
    }
  }
}

// ── 21. God Calls Abraham ─────────────────────────────────────────────────────
// Intent: One family walks out of everything they know, toward a sunrise they
//         cannot see the end of, because God said go.
// ANIM 1: the sun rising over the horizon (t 0→0.8)
// ANIM 2: Abram walking away from the tent, toward the light (t 0→0.8)
// ANIM 3: the flock following behind him (t 0.15→1)
class _AbrahamCallScenePainter extends ScenePainter {
  const _AbrahamCallScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=620 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 620.0;

    _sky(canvas, const Color(0xFFF59E0B), const Color(0xFFFED7AA));

    // Sun rising over the horizon (ANIM 1, t 0→0.8)
    final sunY = _cl(kHorizon + 40, kHorizon - 70, t, 0, 0.8);
    final sunR = _cl(58, 96, t, 0, 0.8);
    final sunRect = Rect.fromCircle(center: Offset(760, sunY), radius: sunR * 2.6);
    canvas.drawOval(
      sunRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFEF3C7).withValues(alpha: 0.55),
            const Color(0xFFFEF3C7).withValues(alpha: 0.0),
          ],
        ).createShader(sunRect),
    );
    canvas.drawCircle(Offset(760, sunY), sunR, Paint()..color = const Color(0xFFFEF3C7));

    // Ground — desert, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF9A5B1E), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1000), width: 1700, height: 620),
      Paint()..color = const Color(0xFF7C4514),
    );

    // The tent being left behind — triangle with a dark doorway (§ 4.1)
    canvas.drawPath(
      Path()
        ..moveTo(120, 640)
        ..lineTo(230, 452)
        ..lineTo(340, 640)
        ..close(),
      Paint()..color = const Color(0xFF7C2D12),
    );
    canvas.drawPath(
      Path()
        ..moveTo(200, 640)
        ..lineTo(230, 540)
        ..lineTo(260, 640)
        ..close(),
      Paint()..color = const Color(0xFF3F1D0A),
    );

    // The flock following behind (ANIM 3, t 0.15→1)
    final flockX = _cl(210, 340, t, 0.15, 1.0);
    final flockP = Paint()..color = const Color(0xFFE7E5E4);
    for (int i = 0; i < 3; i++) {
      final x = flockX + i * 62;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(x, 726 - i * 6), width: 74, height: 46), flockP);
      canvas.drawCircle(Offset(x + 32, 706 - i * 6), 17,
          Paint()..color = const Color(0xFF57534E));
    }

    // Abram walking toward the sunrise (ANIM 2, t 0→0.8)
    // § 4.2 limb rule: 128°/40° = 88° apart ✓ (one arm swinging forward)
    _person(canvas, _cl(400, 570, t, 0, 0.8), 780, 294,
        const Color(0xFF8D5524), const Color(0xFF166534),
        armAngleL: 128, armAngleR: 40);
  }
}

// ── 22. Stars in the Sky ──────────────────────────────────────────────────────
// Intent: One old man stands outside his tent under a sky with more stars than
//         he could ever count, holding nothing but a promise.
// ANIM 1: the stars filling the sky (t 0→0.85)
// ANIM 2: Abram walking out from the tent to look up (t 0→0.6)
// ANIM 3: the tent lamp glowing behind him (t 0.25→1)
class _StarsScenePainter extends ScenePainter {
  const _StarsScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=700 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 700.0;

    _sky(canvas, const Color(0xFF050B2E), const Color(0xFF1E1B4B));

    // Stars filling the sky in three waves (ANIM 1, t 0→0.85).
    // More than a child can count — that is the whole point of the picture.
    const waves = [
      [
        [70, 110, 5], [190, 60, 4], [300, 140, 6], [430, 80, 4], [560, 150, 5],
        [690, 70, 5], [820, 130, 4], [930, 66, 5], [150, 220, 4], [380, 250, 5],
      ],
      [
        [610, 240, 4], [860, 240, 5], [40, 320, 4], [250, 340, 5], [470, 330, 4],
        [720, 350, 5], [950, 330, 4], [120, 420, 4], [340, 440, 5], [890, 430, 4],
      ],
      [
        [560, 430, 4], [660, 470, 3], [40, 500, 3], [230, 520, 4], [430, 540, 3],
        [800, 520, 4], [960, 480, 3], [310, 610, 3], [630, 600, 3], [900, 620, 3],
      ],
    ];
    for (int w = 0; w < waves.length; w++) {
      final a = _cl(0, 0.95, t, w * 0.28, w * 0.28 + 0.3);
      for (final s in waves[w]) {
        _dot(canvas, s[0].toDouble(), s[1].toDouble(), s[2].toDouble(), a);
      }
    }

    // Ground — night desert, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF17120E), kHorizon);

    // The tent, with its lamp glowing inside (ANIM 3, t 0.25→1)
    canvas.drawPath(
      Path()
        ..moveTo(60, 712)
        ..lineTo(200, 488)
        ..lineTo(340, 712)
        ..close(),
      Paint()..color = const Color(0xFF44290F),
    );
    final lampA = _cl(0, 0.9, t, 0.25, 1.0);
    if (lampA > 0) {
      final lampRect = Rect.fromCircle(center: const Offset(200, 660), radius: 96);
      canvas.drawOval(
        lampRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFBBF24).withValues(alpha: lampA * 0.85),
              const Color(0xFFFBBF24).withValues(alpha: 0.0),
            ],
          ).createShader(lampRect),
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(168, 712)
        ..lineTo(200, 596)
        ..lineTo(232, 712)
        ..close(),
      Paint()..color = const Color(0xFF1C1004),
    );

    // Abram walking out to look up (ANIM 2, t 0→0.6)
    // § 4.2 limb rule: 145°/55° = 90° apart ✓ (arms open toward the sky)
    _person(canvas, _cl(400, 560, t, 0, 0.6), 778, 288,
        const Color(0xFF8D5524), const Color(0xFF3730A3),
        armAngleL: 145, armAngleR: 55);
  }
}

// ── 23. The Promised Son ──────────────────────────────────────────────────────
// Intent: Three visitors sit in the shade by the tent, and the impossible
//         promise is spoken out loud where Sarah can hear it.
// ANIM 1: the shade of the great tree spreading (t 0→0.7)
// ANIM 2: Abraham hurrying across to welcome the visitors (t 0→0.7)
// ANIM 3: light at the tent doorway where Sarah is listening (t 0.4→1)
class _PromisedSonScenePainter extends ScenePainter {
  const _PromisedSonScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=660 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 660.0;

    _sky(canvas, const Color(0xFFFCD34D), const Color(0xFFFEF3C7));

    // Ground — sunbaked earth, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFFA16207), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1030), width: 1700, height: 660),
      Paint()..color = const Color(0xFF854D0E),
    );

    // The shade of the great tree spreading over the ground (ANIM 1, t 0→0.7)
    final shadeW = _cl(180, 620, t, 0, 0.7);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(320, 748), width: shadeW, height: shadeW * 0.3),
      Paint()..color = const Color(0xFF422006).withValues(alpha: 0.45),
    );

    // The great tree of Mamre — trunk plus a wide three-lobe canopy
    canvas.drawRect(const Rect.fromLTWH(292, 400, 58, 264),
        Paint()..color = const Color(0xFF78350F));
    final canopy = Paint()..color = const Color(0xFF15803D);
    canvas.drawCircle(const Offset(320, 322), 150, canopy);
    canvas.drawCircle(const Offset(178, 388), 100, canopy);
    canvas.drawCircle(const Offset(464, 388), 100, canopy);

    // The tent, with light at the doorway where Sarah listens (ANIM 3, t 0.4→1)
    canvas.drawPath(
      Path()
        ..moveTo(700, 672)
        ..lineTo(830, 452)
        ..lineTo(960, 672)
        ..close(),
      Paint()..color = const Color(0xFF7C2D12),
    );
    final doorA = _cl(0, 0.85, t, 0.4, 1.0);
    if (doorA > 0) {
      final doorRect = Rect.fromCircle(center: const Offset(830, 616), radius: 90);
      canvas.drawOval(
        doorRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: doorA),
              const Color(0xFFFDE68A).withValues(alpha: 0.0),
            ],
          ).createShader(doorRect),
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(798, 672)
        ..lineTo(830, 552)
        ..lineTo(862, 672)
        ..close(),
      Paint()..color = const Color(0xFF3F1D0A),
    );

    // The three visitors, seated in the shade (static — the still centre)
    const robes = [Color(0xFFF8FAFC), Color(0xFFE2E8F0), Color(0xFFCBD5E1)];
    for (int i = 0; i < 3; i++) {
      final x = 210 + i * 108.0;
      canvas.drawPath(
        Path()
          ..moveTo(x - 34, 592)
          ..lineTo(x - 52, 706)
          ..lineTo(x + 52, 706)
          ..lineTo(x + 34, 592)
          ..close(),
        Paint()..color = robes[i],
      );
      canvas.drawCircle(Offset(x, 556), 36, Paint()..color = const Color(0xFFC68642));
      final eye = Paint()..color = const Color(0xFF78350F);
      canvas.drawCircle(Offset(x - 12, 550), 5, eye);
      canvas.drawCircle(Offset(x + 12, 550), 5, eye);
    }

    // Abraham hurrying across to welcome them (ANIM 2, t 0→0.7)
    // § 4.2 limb rule: 135°/38° = 97° apart ✓ (one arm out in welcome)
    _person(canvas, _cl(700, 566, t, 0, 0.7), 782, 286,
        const Color(0xFF8D5524), const Color(0xFF9F1239),
        armAngleL: 135, armAngleR: 38);
  }
}

// ── 24. God Provides a Lamb ───────────────────────────────────────────────────
// Intent: The altar is empty and a ram stands caught in the thicket — God has
//         provided the offering Himself.
// ANIM 1: a shaft of light reaching down to the ram (t 0→0.7)
// ANIM 2: warm light gathering around the ram (t 0.35→1)
// ANIM 3: Abraham turning toward what God has provided (t 0.2→1)
class _ProvidesLambScenePainter extends ScenePainter {
  const _ProvidesLambScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=640 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 640.0;

    _sky(canvas, const Color(0xFF7DD3FC), const Color(0xFFFEF3C7));

    // A shaft of light reaching down to the ram (ANIM 1, t 0→0.7).
    // Vertical-sided band, not a taper — a taper would read as a mountain (§ 4.4).
    final shaftH = _cl(0, 520, t, 0, 0.7);
    if (shaftH > 0) {
      canvas.drawRect(
        Rect.fromLTWH(674, 80, 132, shaftH),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.12),
              const Color(0xFFFEF3C7).withValues(alpha: 0.5),
            ],
          ).createShader(Rect.fromLTWH(674, 80, 132, shaftH)),
      );
    }

    // Ground — rocky mountain top, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF78350F), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1010), width: 1700, height: 640),
      Paint()..color = const Color(0xFF603010),
    );

    // The empty altar — stacked stone, nothing on it (§ 4.1 silhouette)
    canvas.drawRect(const Rect.fromLTWH(168, 596, 190, 110),
        Paint()..color = const Color(0xFF78716C));
    canvas.drawRect(const Rect.fromLTWH(146, 684, 234, 44),
        Paint()..color = const Color(0xFF57534E));
    // Wood laid on top, unlit
    final wood = Paint()
      ..color = const Color(0xFF92400E)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(194, 588), const Offset(332, 588), wood);
    canvas.drawLine(const Offset(206, 572), const Offset(320, 578), wood);

    // Warm light gathering around the ram (ANIM 2, t 0.35→1)
    final glowR = _cl(0, 190, t, 0.35, 1.0);
    if (glowR > 0) {
      final glowRect = Rect.fromCircle(center: const Offset(740, 596), radius: glowR);
      canvas.drawOval(
        glowRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: 0.55),
              const Color(0xFFFDE68A).withValues(alpha: 0.0),
            ],
          ).createShader(glowRect),
      );
    }

    // The thicket behind the ram — a low tangled bush, drawn light enough to
    // read against the dark ground but never spiky-menacing (§ child safety).
    final bush = Paint()
      ..color = const Color(0xFF5A4632)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final b in const [
      [618, 690, 656, 586], [656, 586, 726, 552], [726, 552, 812, 560],
      [812, 560, 872, 610], [872, 610, 886, 692], [640, 636, 720, 606],
      [790, 600, 866, 634],
    ]) {
      canvas.drawLine(Offset(b[0].toDouble(), b[1].toDouble()),
          Offset(b[2].toDouble(), b[3].toDouble()), bush);
    }

    // The ram — body, head, and the curled horn that names it (§ 4.1)
    final wool = Paint()..color = const Color(0xFFFAFAF9);
    canvas.drawOval(const Rect.fromLTWH(672, 574, 152, 84), wool);
    canvas.drawCircle(const Offset(818, 570), 30, wool);
    final legP = Paint()
      ..color = const Color(0xFF57534E)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(710, 652), const Offset(710, 700), legP);
    canvas.drawLine(const Offset(782, 652), const Offset(782, 700), legP);
    canvas.drawArc(const Rect.fromLTWH(818, 530, 74, 62), -math.pi * 0.9, math.pi * 1.5,
        false,
        Paint()
          ..color = const Color(0xFF57534E)
          ..strokeWidth = 13
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(const Offset(828, 566), 5, Paint()..color = const Color(0xFF44403C));

    // Two thin twigs across the ram's legs only — this is what makes him read as
    // caught, without ever obscuring the animal itself.
    final twig = Paint()
      ..color = const Color(0xFF4A3826)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(668, 682), const Offset(806, 662), twig);
    canvas.drawLine(const Offset(692, 700), const Offset(842, 686), twig);

    // Abraham, turning toward what God has provided (ANIM 3, t 0.2→1)
    // § 4.2 limb rule: 132°/34° = 98° apart ✓ (one arm reaching toward the ram)
    _person(canvas, _cl(452, 522, t, 0.2, 1.0), 782, 290,
        const Color(0xFF8D5524), const Color(0xFF1E3A8A),
        armAngleL: 132, armAngleR: 34);
  }
}

// ── 25. Jacob Learns Grace ────────────────────────────────────────────────────
// Intent: A man who cheated and ran sleeps on bare ground with a stone under his
//         head — and heaven opens right over him.
// ANIM 1: the stairway rising step by step out of the ground (t 0→0.8)
// ANIM 2: light opening at the top of the stairway (t 0.45→1)
// ANIM 3: stars appearing across the night (t 0.2→1)
class _JacobScenePainter extends ScenePainter {
  const _JacobScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=620 — outside forbidden zone y 450–550 (§ 4.4).
    // Kept high enough that the sleeping figure sits inside the widest crop.
    const kHorizon = 620.0;

    _sky(canvas, const Color(0xFF0C1445), const Color(0xFF312E81));

    // Stars appearing (ANIM 3, t 0.2→1)
    final starA = _cl(0, 0.85, t, 0.2, 1.0);
    for (final s in const [
      [80, 120, 5], [210, 210, 4], [120, 330, 4], [330, 96, 4], [880, 140, 5],
      [940, 300, 4], [790, 230, 4], [60, 470, 3], [930, 470, 3], [250, 430, 3],
    ]) {
      _dot(canvas, s[0].toDouble(), s[1].toDouble(), s[2].toDouble(), starA);
    }

    // Light opening at the top of the stairway (ANIM 2, t 0.45→1)
    final openR = _cl(0, 250, t, 0.45, 1.0);
    if (openR > 0) {
      final openRect = Rect.fromCircle(center: const Offset(680, 170), radius: openR);
      canvas.drawOval(
        openRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: 0.6),
              const Color(0xFFFDE68A).withValues(alpha: 0.0),
            ],
          ).createShader(openRect),
      );
    }

    // Ground — bare night earth, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF1C1512), kHorizon);

    // The stairway — steps rising from the ground into the light (ANIM 1, t 0→0.8).
    // Drawn as discrete rungs so it reads as stairs, not as a beam or a hill.
    final steps = _cl(2, 9, t, 0, 0.8);
    for (int i = 0; i < 9; i++) {
      if (i >= steps) break;
      final f = i / 8.0;
      final y = _lerp(610, 220, f);
      final w = _lerp(230, 96, f);
      final x = _lerp(620, 680, f);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: w, height: 20),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.85 - f * 0.25),
      );
    }

    // Jacob asleep on the ground, head on a stone.
    // Lying figure: ~330 design units long, with two face features (§ 4.2).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(160, 676, 310, 96),
        const Radius.circular(46),
      ),
      Paint()..color = const Color(0xFF7C2D12),
    );
    // Stone pillow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(88, 704, 100, 66),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFF57534E),
    );
    // Head resting on it
    canvas.drawCircle(const Offset(176, 688), 50, Paint()..color = const Color(0xFF8D5524));
    // Closed eyes — two small arcs, so he reads as asleep, not unwell
    final eyeP = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
        Rect.fromCenter(center: const Offset(158, 680), width: 22, height: 13),
        math.pi, math.pi, false, eyeP);
    canvas.drawArc(
        Rect.fromCenter(center: const Offset(196, 680), width: 22, height: 13),
        math.pi, math.pi, false, eyeP);
  }
}

// ── 26. Joseph and His Jealous Brothers ───────────────────────────────────────
// Intent: The coloured coat is left behind by the empty well while the caravan
//         carries Joseph away — and a light stays with him even so.
// ANIM 1: the caravan receding toward the horizon (t 0→1)
// ANIM 2: dust drifting across the sand (t 0→1)
// ANIM 3: God's light settling over the well (t 0.5→1)
class _JosephBrothersScenePainter extends ScenePainter {
  const _JosephBrothersScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=430 — outside forbidden zone y 450–550 (§ 4.4).
    // Set high so the coat and the well both sit inside the widest crop.
    const kHorizon = 430.0;

    _sky(canvas, const Color(0xFFFDBA74), const Color(0xFFFEF3C7));

    // Ground — bleached sand, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFFB45309), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 900), width: 1700, height: 700),
      Paint()..color = const Color(0xFF9A4508),
    );

    // The caravan receding toward the horizon (ANIM 1, t 0→1).
    // It shrinks as it goes, which is what makes the distance read.
    final cx = _lerp(520, 860, t);
    final cs = _lerp(1.35, 0.6, t);
    final camel = Paint()..color = const Color(0xFF7C2D12);
    for (int i = 0; i < 3; i++) {
      final x = cx + i * 66 * cs;
      final y = kHorizon - 10 - i * 6;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 78 * cs, height: 42 * cs), camel);
      canvas.drawCircle(Offset(x + 32 * cs, y - 32 * cs), 15 * cs, camel);
      canvas.drawLine(Offset(x + 28 * cs, y - 22 * cs), Offset(x + 32 * cs, y - 32 * cs),
          Paint()
            ..color = const Color(0xFF7C2D12)
            ..strokeWidth = 8 * cs);
    }

    // Dust drifting across the sand (ANIM 2, t 0→1)
    final dustX = _lerp(0, 160, t);
    final dustP = Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.35);
    for (final d in const [[260, 500], [430, 544], [660, 512], [820, 560], [140, 566]]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(d[0] + dustX, d[1].toDouble()), width: 100, height: 26),
        dustP,
      );
    }

    // The empty well — dark mouth in the ground with a stone rim (§ 4.1)
    canvas.drawOval(const Rect.fromLTWH(612, 596, 306, 132),
        Paint()..color = const Color(0xFF78716C));
    canvas.drawOval(const Rect.fromLTWH(644, 614, 242, 98),
        Paint()..color = const Color(0xFF1C1210));

    // God's light settling over it all (ANIM 3, t 0.5→1) — "the Lord was with Joseph"
    final lightR = _cl(0, 300, t, 0.5, 1.0);
    if (lightR > 0) {
      final lightRect = Rect.fromCircle(center: const Offset(762, 640), radius: lightR);
      canvas.drawOval(
        lightRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.42),
              const Color(0xFFFEF3C7).withValues(alpha: 0.0),
            ],
          ).createShader(lightRect),
      );
    }

    // The coat, dropped on the sand — the subject of the picture.
    // ~330 design units wide, with sleeves and stripes so it reads as a coat.
    canvas.drawPath(
      Path()
        ..moveTo(150, 588)
        ..lineTo(118, 654)
        ..lineTo(188, 680)
        ..lineTo(206, 756)
        ..lineTo(438, 756)
        ..lineTo(456, 680)
        ..lineTo(526, 654)
        ..lineTo(494, 588)
        ..lineTo(388, 562)
        ..lineTo(256, 562)
        ..close(),
      Paint()..color = const Color(0xFFF59E0B),
    );
    const stripes = [
      Color(0xFFDC2626), Color(0xFF1D4ED8), Color(0xFF15803D), Color(0xFF7C3AED),
    ];
    for (int i = 0; i < stripes.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(216, 592 + i * 38.0, 212, 20),
        Paint()..color = stripes[i],
      );
    }
  }
}

// ── 27. Joseph Forgives His Family ────────────────────────────────────────────
// Intent: The brother they threw away steps down from power with open arms, and
//         the family that broke is put back together.
// ANIM 1: Joseph stepping down toward his brothers (t 0→0.7)
// ANIM 2: warm light widening between them (t 0.3→1)
// ANIM 3: a brother lifting his head as the fear leaves (t 0.5→1)
class _JosephForgivesScenePainter extends ScenePainter {
  const _JosephForgivesScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=680 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 680.0;

    _sky(canvas, const Color(0xFFFBBF24), const Color(0xFFFDE68A));

    // Hall columns behind — plain shafts, so the place reads as somewhere grand
    final column = Paint()..color = const Color(0xFFD6A85F);
    for (final x in const [60.0, 900.0]) {
      canvas.drawRect(Rect.fromLTWH(x, 150, 76, 530), column);
      canvas.drawRect(Rect.fromLTWH(x - 16, 150, 108, 40), column);
    }

    // Ground — hall floor, darker than the light above (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF7C4514), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1060), width: 1700, height: 700),
      Paint()..color = const Color(0xFF62360F),
    );

    // Grain sacks stacked high — the food that saved them all
    final sack = Paint()..color = const Color(0xFFCA8A04);
    final sackDark = Paint()..color = const Color(0xFFA16207);
    for (int i = 0; i < 3; i++) {
      canvas.drawOval(
          Rect.fromCenter(center: Offset(112 + i * 92, 646), width: 108, height: 130),
          i.isEven ? sack : sackDark);
    }
    canvas.drawOval(
        const Rect.fromLTWH(150, 458, 108, 130), sackDark);

    // Warm light widening between Joseph and his brothers (ANIM 2, t 0.3→1)
    final lightR = _cl(0, 320, t, 0.3, 1.0);
    if (lightR > 0) {
      final lightRect = Rect.fromCircle(center: const Offset(600, 560), radius: lightR);
      canvas.drawOval(
        lightRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.5),
              const Color(0xFFFEF3C7).withValues(alpha: 0.0),
            ],
          ).createShader(lightRect),
      );
    }

    // Two brothers kneeling — one lifts his head as the fear leaves (ANIM 3)
    _kneeling(canvas, 388, 792, 232,
        const Color(0xFF8D5524), const Color(0xFF57534E),
        prayerOpenDeg: _cl(0, 0.8, t, 0.5, 1.0));
    _kneeling(canvas, 224, 800, 224,
        const Color(0xFFC68642), const Color(0xFF44403C));

    // Joseph, stepping down with both arms open (ANIM 1, t 0→0.7)
    // § 4.2 limb rule: 160°/20° = 140° apart ✓ (arms wide in welcome)
    _person(canvas, _cl(760, 654, t, 0, 0.7), 786, 300,
        const Color(0xFF8D5524), const Color(0xFF0F766E),
        armAngleL: 160, armAngleR: 20);
  }
}

// ── 28. Baby Moses Is Kept Safe ───────────────────────────────────────────────
// Intent: A tiny basket rests safe among the tall reeds while a sister watches —
//         God is already protecting the rescuer nobody has met yet.
// ANIM 1: the river current drifting past (t 0→1)
// ANIM 2: the basket settling into the safety of the reeds (t 0→0.7)
// ANIM 3: a protecting light gathering over the basket (t 0.4→1)
class _BabyMosesScenePainter extends ScenePainter {
  const _BabyMosesScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=380 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 380.0;

    _sky(canvas, const Color(0xFF7DD3FC), const Color(0xFFFEF3C7));

    // Far bank — a low band so the river reads as a river, not the sea
    canvas.drawRect(const Rect.fromLTWH(0, kHorizon, 1000, 70),
        Paint()..color = const Color(0xFF4D7C0F));

    // Water — darker than sky (§ 4.4 ✓)
    canvas.drawRect(
      const Rect.fromLTWH(0, kHorizon + 70, 1000, 1000 - kHorizon - 70),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0E7490), Color(0xFF134E4A)],
        ).createShader(const Rect.fromLTWH(0, kHorizon + 70, 1000, 550)),
    );

    // River current drifting past (ANIM 1, t 0→1)
    final flow = _lerp(0, 200, t);
    final rippleP = Paint()
      ..color = const Color(0xFFA5F3FC).withValues(alpha: 0.4)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (final r in const [[80, 520], [340, 570], [620, 540], [860, 600], [200, 650]]) {
      final x = (r[0] + flow) % 1100 - 50;
      canvas.drawLine(Offset(x, r[1].toDouble()), Offset(x + 110, r[1].toDouble()), rippleP);
    }

    // Protecting light gathering over the basket (ANIM 3, t 0.4→1)
    final lightR = _cl(0, 280, t, 0.4, 1.0);
    if (lightR > 0) {
      final lightRect = Rect.fromCircle(center: const Offset(560, 600), radius: lightR);
      canvas.drawOval(
        lightRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.45),
              const Color(0xFFFEF3C7).withValues(alpha: 0.0),
            ],
          ).createShader(lightRect),
      );
    }

    // Tall reeds along the near bank — vertical strokes, the safe hiding place
    final reed = Paint()
      ..color = const Color(0xFF3F6212)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    for (final r in const [
      [40, 700, 60, 430], [110, 730, 96, 460], [180, 700, 210, 440],
      [700, 720, 686, 450], [790, 740, 810, 470], [880, 700, 866, 430],
      [960, 730, 976, 460],
    ]) {
      canvas.drawLine(Offset(r[0].toDouble(), r[1].toDouble()),
          Offset(r[2].toDouble(), r[3].toDouble()), reed);
    }

    // The basket settling into the reeds (ANIM 2, t 0→0.7)
    final bY = _cl(566, 596, t, 0, 0.7);
    // Woven body
    canvas.drawPath(
      Path()
        ..moveTo(430, bY)
        ..lineTo(452, bY + 96)
        ..lineTo(668, bY + 96)
        ..lineTo(690, bY)
        ..close(),
      Paint()..color = const Color(0xFFCA8A04),
    );
    // Weave lines so it reads as woven reeds (§ 4.1)
    final weave = Paint()
      ..color = const Color(0xFF92400E).withValues(alpha: 0.55)
      ..strokeWidth = 5;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(436 + i * 4, bY + i * 24), Offset(684 - i * 4, bY + i * 24), weave);
    }
    // Rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(414, bY - 20, 292, 30), const Radius.circular(14)),
      Paint()..color = const Color(0xFFA16207),
    );
    // The baby's blanket and face, just visible inside
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(496, bY - 46, 128, 34), const Radius.circular(16)),
      Paint()..color = const Color(0xFFFAFAF9),
    );
    canvas.drawCircle(Offset(560, bY - 52), 26, Paint()..color = const Color(0xFF8D5524));
    final eyeP = Paint()..color = const Color(0xFF78350F);
    canvas.drawCircle(Offset(551, bY - 56), 4, eyeP);
    canvas.drawCircle(Offset(569, bY - 56), 4, eyeP);

    // Near bank in the foreground, so Miriam stands on land rather than in the
    // river — without it she reads as wading, which the story never says.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1010), width: 1700, height: 500),
      Paint()..color = const Color(0xFF3F6212),
    );

    // Miriam, watching from among the reeds on the bank
    // § 4.2 limb rule: 126°/54° = 72° apart ✓
    _person(canvas, 218, 776, 268, const Color(0xFFC68642), const Color(0xFF9F1239),
        armAngleL: 126, armAngleR: 54);
  }
}

// ── 29. God Calls from the Fire ───────────────────────────────────────────────
// Intent: A bush is wrapped in flame and every leaf is still green — this is holy
//         ground, and God is speaking out of it.
// ANIM 1: the flames rising around the bush (t 0→1)
// ANIM 2: holy light spreading out from the bush (t 0.3→1)
// ANIM 3: Moses drawing near, then bowing his head (t 0→0.6)
class _BurningBushScenePainter extends ScenePainter {
  const _BurningBushScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=600 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 600.0;

    _sky(canvas, const Color(0xFF92400E), const Color(0xFFFDBA74));

    // Holy light spreading out from the bush (ANIM 2, t 0.3→1)
    final holyR = _cl(0, 420, t, 0.3, 1.0);
    if (holyR > 0) {
      final holyRect = Rect.fromCircle(center: const Offset(690, 480), radius: holyR);
      canvas.drawOval(
        holyRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.5),
              const Color(0xFFFEF3C7).withValues(alpha: 0.0),
            ],
          ).createShader(holyRect),
      );
    }

    // Ground — dry stony mountainside, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF57534E), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 990), width: 1700, height: 620),
      Paint()..color = const Color(0xFF44403C),
    );

    // The flames rising around the bush (ANIM 1, t 0→1).
    // Drawn first so the green leaves sit on top — that is the whole miracle.
    final flameH = _lerp(96, 210, t);
    for (int i = 0; i < 5; i++) {
      final fx = 574 + i * 58.0;
      final h = flameH * (i.isEven ? 1.0 : 0.78);
      canvas.drawPath(
        Path()
          ..moveTo(fx - 34, 596)
          ..quadraticBezierTo(fx - 20, 596 - h * 0.6, fx, 596 - h)
          ..quadraticBezierTo(fx + 20, 596 - h * 0.6, fx + 34, 596)
          ..close(),
        Paint()..color = const Color(0xFFFBBF24).withValues(alpha: 0.9),
      );
      canvas.drawPath(
        Path()
          ..moveTo(fx - 18, 596)
          ..quadraticBezierTo(fx - 10, 596 - h * 0.5, fx, 596 - h * 0.62)
          ..quadraticBezierTo(fx + 10, 596 - h * 0.5, fx + 18, 596)
          ..close(),
        Paint()..color = const Color(0xFFFEF3C7),
      );
    }

    // The bush — every leaf whole and green, sitting inside the fire (§ 4.1)
    final leaf = Paint()..color = const Color(0xFF15803D);
    for (final l in const [
      [690, 512, 122], [612, 552, 86], [768, 552, 86], [652, 486, 66], [730, 486, 66],
    ]) {
      canvas.drawCircle(
          Offset(l[0].toDouble(), l[1].toDouble()), l[2].toDouble() / 2, leaf);
    }
    canvas.drawRect(const Rect.fromLTWH(676, 556, 28, 48),
        Paint()..color = const Color(0xFF44291A));

    // Moses' sandals, set aside on the holy ground
    final sandal = Paint()..color = const Color(0xFF7C2D12);
    canvas.drawOval(const Rect.fromLTWH(398, 726, 62, 30), sandal);
    canvas.drawOval(const Rect.fromLTWH(472, 736, 62, 30), sandal);

    // Moses drawing near with his head bowed (ANIM 3, t 0→0.6)
    // § 4.2 limb rule: 118°/38° = 80° apart ✓ (one hand raised to shield his eyes)
    _person(canvas, _cl(230, 318, t, 0, 0.6), 776, 286,
        const Color(0xFF8D5524), const Color(0xFF1E3A8A),
        armAngleL: 118, armAngleR: 38);
  }
}

// ── 30. Let My People Go ──────────────────────────────────────────────────────
// Intent: One shepherd with a wooden staff stands in a vast throne hall and says
//         God's words to the most powerful king on earth.
// ANIM 1: light breaking between the columns (t 0.25→1)
// ANIM 2: Moses walking forward into the hall (t 0→0.7)
// ANIM 3: Moses' staff lifting as he speaks (t 0.5→1)
class _LetMyPeopleGoScenePainter extends ScenePainter {
  const _LetMyPeopleGoScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon (floor line) at y=660 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 660.0;

    _sky(canvas, const Color(0xFF1E3A8A), const Color(0xFF60A5FA));

    // Light breaking between the columns (ANIM 2 of the palette, ANIM 1 here)
    final beamA = _cl(0, 0.4, t, 0.25, 1.0);
    if (beamA > 0) {
      for (final bx in const [222.0, 560.0]) {
        canvas.drawRect(
          Rect.fromLTWH(bx, 90, 96, kHorizon - 90),
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFEF3C7).withValues(alpha: beamA),
                const Color(0xFFFEF3C7).withValues(alpha: 0.0),
              ],
            ).createShader(Rect.fromLTWH(bx, 90, 96, kHorizon - 90)),
        );
      }
    }

    // Floor — darker than the hall above (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF78350F), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1030), width: 1700, height: 660),
      Paint()..color = const Color(0xFF62290D),
    );

    // Towering painted columns — plain shafts with capitals (§ 4.1)
    final stone = Paint()..color = const Color(0xFFD6A85F);
    final stoneDark = Paint()..color = const Color(0xFFB98B45);
    for (final cx in const [96.0, 356.0, 700.0, 900.0]) {
      canvas.drawRect(Rect.fromLTWH(cx, 150, 98, kHorizon - 150), stone);
      canvas.drawRect(Rect.fromLTWH(cx - 18, 150, 134, 46), stoneDark);
      // A single banded stripe so the column reads as painted, not blank
      canvas.drawRect(Rect.fromLTWH(cx, 400, 98, 26), stoneDark);
    }

    // Pharaoh's throne, raised at the far right — power, seen at a distance
    canvas.drawRect(const Rect.fromLTWH(760, 560, 190, 100),
        Paint()..color = const Color(0xFF854D0E));
    canvas.drawRect(const Rect.fromLTWH(796, 424, 118, 140),
        Paint()..color = const Color(0xFFCA8A04));
    canvas.drawCircle(const Offset(855, 470), 34, Paint()..color = const Color(0xFF8D5524));
    // Crown
    canvas.drawPath(
      Path()
        ..moveTo(821, 442)
        ..lineTo(831, 408)
        ..lineTo(846, 434)
        ..lineTo(861, 404)
        ..lineTo(876, 434)
        ..lineTo(889, 442)
        ..close(),
      Paint()..color = const Color(0xFFFBBF24),
    );

    // Moses walking forward (ANIM 2, t 0→0.7)
    final mX = _cl(196, 330, t, 0, 0.7);
    // § 4.2 limb rule: 120°/44° = 76° apart ✓
    _person(canvas, mX, 780, 296, const Color(0xFF8D5524), const Color(0xFF166534),
        armAngleL: 120, armAngleR: 44);

    // The staff lifting as he speaks (ANIM 3, t 0.5→1)
    final staffTop = _cl(560, 396, t, 0.5, 1.0);
    canvas.drawLine(
      Offset(mX + 96, 772),
      Offset(mX + 96, staffTop),
      Paint()
        ..color = const Color(0xFF7C2D12)
        ..strokeWidth = 17
        ..strokeCap = StrokeCap.round,
    );
  }
}

// ── 31. The Passover Lamb ─────────────────────────────────────────────────────
// Intent: A marked doorway with warm light and a family meal inside — everyone
//         sheltered here is safe.
// ANIM 1: the doorframe being marked, side to side then across the top (t 0→0.6)
// ANIM 2: lamplight strengthening inside the house (t 0.2→1)
// ANIM 3: the night deepening outside (t 0→1)
class _PassoverScenePainter extends ScenePainter {
  const _PassoverScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // The night sky deepening outside (ANIM 3, t 0→1)
    final top = Color.lerp(const Color(0xFF312E81), const Color(0xFF0C1445), t)!;
    final bottom = Color.lerp(const Color(0xFF4338CA), const Color(0xFF1E1B4B), t)!;
    _sky(canvas, top, bottom);

    // Street — darker than the sky (§ 4.4 ✓). Line at y=760, well below 450–550.
    _ground(canvas, const Color(0xFF1C1917), 760);

    // The house wall
    canvas.drawRect(const Rect.fromLTWH(120, 180, 760, 580),
        Paint()..color = const Color(0xFF57534E));
    // A few stone courses so the wall reads as built, not as a flat block
    final course = Paint()
      ..color = const Color(0xFF44403C)
      ..strokeWidth = 5;
    for (int i = 1; i < 5; i++) {
      canvas.drawLine(Offset(120, 180 + i * 116), Offset(880, 180 + i * 116), course);
    }

    // Lamplight strengthening inside the doorway (ANIM 2, t 0.2→1)
    final lampA = _cl(0.25, 1.0, t, 0.2, 1.0);
    canvas.drawRect(
      const Rect.fromLTWH(372, 320, 256, 440),
      Paint()..color = Color.lerp(const Color(0xFF7C2D12),
          const Color(0xFFFDE68A), lampA)!,
    );
    // Warm spill onto the street
    final spillRect = Rect.fromCircle(center: const Offset(500, 760), radius: 300);
    canvas.drawOval(
      spillRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE68A).withValues(alpha: 0.42 * lampA),
            const Color(0xFFFDE68A).withValues(alpha: 0.0),
          ],
        ).createShader(spillRect),
    );

    // The family at the meal inside, in silhouette against the lamplight
    final sil = Paint()..color = const Color(0xFF7C2D12);
    for (final f in const [[430.0, 236.0], [500.0, 262.0], [570.0, 236.0]]) {
      final h = f[1];
      canvas.drawPath(
        Path()
          ..moveTo(f[0] - 30, 760 - h)
          ..lineTo(f[0] - 44, 760)
          ..lineTo(f[0] + 44, 760)
          ..lineTo(f[0] + 30, 760 - h)
          ..close(),
        sil,
      );
      canvas.drawCircle(Offset(f[0], 760 - h - 26), 26, sil);
    }

    // The doorframe, being marked side, side, then across the top (ANIM 1)
    final markP = Paint()..color = const Color(0xFF9F1239);
    final leftH = _cl(0, 440, t, 0, 0.22);
    canvas.drawRect(Rect.fromLTWH(340, 760 - leftH, 34, leftH), markP);
    final rightH = _cl(0, 440, t, 0.22, 0.44);
    canvas.drawRect(Rect.fromLTWH(626, 760 - rightH, 34, rightH), markP);
    final topW = _cl(0, 320, t, 0.44, 0.6);
    canvas.drawRect(Rect.fromLTWH(340, 288, topW, 34), markP);
  }
}

// ── 32. A Way Through the Sea ─────────────────────────────────────────────────
// Intent: Two walls of water stand open with a dry path between them, and God's
//         people walk through on solid ground.
// ANIM 1: the two walls of water rising and parting (t 0→0.6)
// ANIM 2: the people walking through the gap (t 0.3→1)
// ANIM 3: the pillar of fire standing guard behind them (t 0→0.8)
class _ThroughTheSeaScenePainter extends ScenePainter {
  const _ThroughTheSeaScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=360 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 360.0;

    _sky(canvas, const Color(0xFF0C4A6E), const Color(0xFF7DD3FC));

    // Sea bed — the dry path, darker than the sky (§ 4.4 ✓).
    // Sandy, so it clearly reads as dry ground against the blue walls.
    _ground(canvas, const Color(0xFFC08A52), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 940), width: 1700, height: 660),
      Paint()..color = const Color(0xFFA36F3A),
    );

    // The two walls of water rising and parting (ANIM 1, t 0→0.6).
    // Vertical-sided slabs, never tapering wedges (§ 4.4 no mountain read).
    // The gap stays narrower than the walls, or the walls stop reading as walls.
    final gap = _cl(96, 200, t, 0, 0.6);
    final wallTop = _cl(kHorizon + 200, 110, t, 0, 0.6);
    final water = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF22D3EE), Color(0xFF0E7490)],
      ).createShader(const Rect.fromLTWH(0, 130, 1000, 700));
    // Left wall
    canvas.drawRect(Rect.fromLTRB(0, wallTop, 500 - gap, 830), water);
    // Right wall
    canvas.drawRect(Rect.fromLTRB(500 + gap, wallTop, 1000, 830), water);
    // Crests along the inside faces so the walls read as standing water
    final crest = Paint()
      ..color = const Color(0xFFCFFAFE).withValues(alpha: 0.75)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(500 - gap, wallTop), Offset(500 - gap, 830), crest);
    canvas.drawLine(Offset(500 + gap, wallTop), Offset(500 + gap, 830), crest);
    final foam = Paint()..color = const Color(0xFFCFFAFE).withValues(alpha: 0.5);
    for (int i = 0; i < 4; i++) {
      final y = wallTop + 60 + i * 150;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(500 - gap - 60, y), width: 130, height: 44), foam);
      canvas.drawOval(
          Rect.fromCenter(center: Offset(500 + gap + 60, y), width: 130, height: 44), foam);
    }

    // The pillar of fire standing guard behind them (ANIM 3, t 0→0.8).
    // Kept far up the path so it never sits behind the walkers' heads.
    final pillarH = _cl(0, 300, t, 0, 0.8);
    if (pillarH > 0) {
      final pRect = Rect.fromLTWH(462, 470 - pillarH, 76, pillarH);
      canvas.drawRect(
        pRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFBBF24).withValues(alpha: 0.15),
              const Color(0xFFFDE68A).withValues(alpha: 0.85),
            ],
          ).createShader(pRect),
      );
    }

    // God's people walking through the gap (ANIM 2, t 0.3→1).
    // Two smaller figures further up the path first, so the line reads as a
    // crowd receding rather than a huddle.
    _person(canvas, 396, 604, 232, const Color(0xFFC68642), const Color(0xFF1E3A8A),
        armAngleL: 116, armAngleR: 56);
    _person(canvas, 604, 596, 226, const Color(0xFF8D5524), const Color(0xFF166534),
        armAngleL: 130, armAngleR: 50);
    // Front figure: height must never dip below the 220-unit floor _person asserts,
    // so scale from a base that keeps the minimum above it at every t.
    final walkY = _cl(660, 780, t, 0.3, 1.0);
    // § 4.2 limb rule: 124°/48° = 76° apart ✓
    _person(canvas, 500, walkY, 286 * (walkY / 780),
        const Color(0xFF8D5524), const Color(0xFF9F1239),
        armAngleL: 124, armAngleR: 48);
  }
}

// ── 33. Bread in the Wilderness ───────────────────────────────────────────────
// Intent: Morning in the camp, and the whole desert floor is covered in bread
//         that nobody worked for.
// ANIM 1: dawn breaking over the camp (t 0→0.7)
// ANIM 2: the manna appearing across the ground (t 0.2→1)
// ANIM 3: a child crouching to gather it into a basket (t 0.4→1)
class _MannaScenePainter extends ScenePainter {
  const _MannaScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=600 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 600.0;

    // Dawn breaking (ANIM 1, t 0→0.7)
    final skyTop = Color.lerp(const Color(0xFF6D28D9), const Color(0xFF7DD3FC),
        _cl(0, 1, t, 0, 0.7))!;
    final skyLow = Color.lerp(const Color(0xFFB45309), const Color(0xFFFEF3C7),
        _cl(0, 1, t, 0, 0.7))!;
    _sky(canvas, skyTop, skyLow);

    // Sun cresting the horizon
    final sunR = _cl(30, 80, t, 0, 0.7);
    canvas.drawCircle(Offset(800, kHorizon - 20), sunR,
        Paint()..color = const Color(0xFFFEF3C7));

    // Ground — desert floor, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF9A6B32), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 990), width: 1700, height: 620),
      Paint()..color = const Color(0xFF7C531E),
    );

    // The camp — three tents on the skyline (§ 4.1 silhouette)
    final tent = Paint()..color = const Color(0xFFA8A29E);
    final tentDark = Paint()..color = const Color(0xFF78716C);
    for (final tx in const [110.0, 300.0, 900.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(tx - 96, kHorizon + 16)
          ..lineTo(tx, kHorizon - 130)
          ..lineTo(tx + 96, kHorizon + 16)
          ..close(),
        tent,
      );
      canvas.drawPath(
        Path()
          ..moveTo(tx - 26, kHorizon + 16)
          ..lineTo(tx, kHorizon - 60)
          ..lineTo(tx + 26, kHorizon + 16)
          ..close(),
        tentDark,
      );
    }

    // The manna appearing across the ground (ANIM 2, t 0.2→1)
    final mannaA = _cl(0, 1, t, 0.2, 1.0);
    if (mannaA > 0) {
      final mP = Paint()..color = const Color(0xFFFEF3C7).withValues(alpha: mannaA);
      for (int row = 0; row < 6; row++) {
        final y = 640 + row * 56.0;
        final r = 9 + row * 2.5;
        for (int i = 0; i < 11; i++) {
          final x = 40 + i * 92.0 + (row.isEven ? 0 : 46);
          canvas.drawOval(
              Rect.fromCenter(center: Offset(x, y), width: r * 2.4, height: r * 1.5), mP);
        }
      }
    }

    // A child crouching to gather manna into a basket (ANIM 3, t 0.4→1).
    // Drawn here rather than via _kneeling: that helper's prayer-hands cross the
    // chest, which reads as folded arms — wrong for someone reaching down.
    const cx = 470.0;
    const feetY = 782.0;
    const bodyH = 250.0;
    const headR = 44.0;
    const shoulderY = feetY - bodyH + headR * 2.4;
    const skin = Color(0xFF8D5524);
    // Crouched body — a squat A-line, wider and shorter than a standing robe
    canvas.drawPath(
      Path()
        ..moveTo(cx - 50, shoulderY)
        ..lineTo(cx - 96, feetY)
        ..lineTo(cx + 96, feetY)
        ..lineTo(cx + 50, shoulderY)
        ..close(),
      Paint()..color = const Color(0xFF0F766E),
    );
    // Neck, then head, so nothing floats (§ 4.2)
    canvas.drawRect(
      Rect.fromLTRB(cx - 15, feetY - bodyH + headR * 0.6, cx + 15, shoulderY + 2),
      Paint()..color = skin,
    );
    canvas.drawCircle(const Offset(cx, feetY - bodyH + headR), headR,
        Paint()..color = skin);
    final childEye = Paint()..color = const Color(0xFF78350F);
    canvas.drawCircle(const Offset(cx - 14, feetY - bodyH + headR - 4), 6, childEye);
    canvas.drawCircle(const Offset(cx + 14, feetY - bodyH + headR - 4), 6, childEye);
    canvas.drawArc(
      Rect.fromCenter(
          center: const Offset(cx, feetY - bodyH + headR + 16), width: 32, height: 16),
      0.1, math.pi * 0.8, false,
      Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );
    // One arm reaching down toward the ground (ANIM 3, t 0.4→1), the other
    // resting on the knee. § 4.2 limb rule: 78°/136° = 58° apart ✓
    final reach = _cl(78, 96, t, 0.4, 1.0);
    final armP = Paint()
      ..color = skin
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      const Offset(cx + 32, shoulderY + 16),
      Offset(cx + 32 + 116 * math.cos(reach * math.pi / 180),
          shoulderY + 16 + 116 * math.sin(reach * math.pi / 180)),
      armP,
    );
    canvas.drawLine(
      const Offset(cx - 32, shoulderY + 16),
      Offset(cx - 32 + 92 * math.cos(136 * math.pi / 180),
          shoulderY + 16 + 92 * math.sin(136 * math.pi / 180)),
      armP,
    );
    // The basket beside them, filling up
    canvas.drawPath(
      Path()
        ..moveTo(636, 700)
        ..lineTo(652, 776)
        ..lineTo(760, 776)
        ..lineTo(776, 700)
        ..close(),
      Paint()..color = const Color(0xFFCA8A04),
    );
    final fillH = _cl(0, 52, t, 0.5, 1.0);
    if (fillH > 0) {
      canvas.drawRect(Rect.fromLTWH(648, 700 - fillH + 4, 116, fillH),
          Paint()..color = const Color(0xFFFEF3C7));
    }
  }
}

// ── 34. God's Good Commands ───────────────────────────────────────────────────
// Intent: Two stone tablets stand on the mountain, given by the God who had
//         already rescued the camp waiting below.
// ANIM 1: cloud and light gathering on the summit (t 0→0.7)
// ANIM 2: the two tablets rising into place (t 0.25→0.85)
// ANIM 3: writing appearing on the tablets (t 0.6→1)
class _CommandsScenePainter extends ScenePainter {
  const _CommandsScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=620 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 620.0;

    _sky(canvas, const Color(0xFF44403C), const Color(0xFFFDBA74));

    // Cloud and light gathering on the summit (ANIM 1, t 0→0.7)
    final cloudR = _cl(90, 360, t, 0, 0.7);
    final cloudRect = Rect.fromCircle(center: const Offset(500, 250), radius: cloudR);
    canvas.drawOval(
      cloudRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFEF3C7).withValues(alpha: 0.6),
            const Color(0xFFFEF3C7).withValues(alpha: 0.0),
          ],
        ).createShader(cloudRect),
    );

    // Ground — the mountain ledge, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF57534E), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1000), width: 1700, height: 640),
      Paint()..color = const Color(0xFF44403C),
    );

    // The camp far below on the plain — small tents, so the scale reads
    final tent = Paint()..color = const Color(0xFFA8A29E);
    for (final tx in const [90.0, 190.0, 830.0, 930.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(tx - 42, 706)
          ..lineTo(tx, 640)
          ..lineTo(tx + 42, 706)
          ..close(),
        tent,
      );
    }

    // The two tablets rising into place (ANIM 2, t 0.25→0.85)
    final tabY = _cl(700, 400, t, 0.25, 0.85);
    final tabletP = Paint()..color = const Color(0xFFD6D3D1);
    final edgeP = Paint()
      ..color = const Color(0xFF78716C)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    for (final tx in const [352.0, 552.0]) {
      final r = Rect.fromLTWH(tx, tabY, 148, 300);
      final rr = RRect.fromRectAndCorners(r,
          topLeft: const Radius.circular(72), topRight: const Radius.circular(72));
      canvas.drawRRect(rr, tabletP);
      canvas.drawRRect(rr, edgeP);
    }

    // Writing appearing on the tablets (ANIM 3, t 0.6→1)
    final lines = _cl(0, 5, t, 0.6, 1.0);
    final ink = Paint()
      ..color = const Color(0xFF44403C)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      if (i >= lines) break;
      final y = tabY + 122 + i * 34;
      canvas.drawLine(Offset(374, y), Offset(478, y), ink);
      canvas.drawLine(Offset(574, y), Offset(678, y), ink);
    }
  }
}

// ── 35. God Lives with His People ─────────────────────────────────────────────
// Intent: God's tent stands right in the middle of the camp with His cloud
//         resting on it — He did not rescue and leave, He moved in.
// ANIM 1: the camp tents gathering in around the centre (t 0→0.7)
// ANIM 2: the cloud settling onto the tabernacle roof (t 0.2→0.8)
// ANIM 3: God's glory filling the tent (t 0.55→1)
class _TabernacleScenePainter extends ScenePainter {
  const _TabernacleScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=580 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 580.0;

    _sky(canvas, const Color(0xFF312E81), const Color(0xFFFDBA74));

    // Ground — evening desert, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF6B4B2A), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 980), width: 1700, height: 640),
      Paint()..color = const Color(0xFF573C20),
    );

    // The cloud settling onto the roof (ANIM 2, t 0.2→0.8)
    final cloudY = _cl(150, 300, t, 0.2, 0.8);
    final cloudP = Paint()..color = const Color(0xFFE7E5E4).withValues(alpha: 0.9);
    for (final c in const [[500.0, 0.0, 150.0], [396.0, 26.0, 104.0], [604.0, 26.0, 104.0]]) {
      canvas.drawCircle(Offset(c[0], cloudY + c[1]), c[2] / 2 + 22, cloudP);
    }

    // The camp tents gathering in around the centre (ANIM 1, t 0→0.7).
    // They move INWARD, which is what says "God is in the middle".
    final pull = _cl(150, 0, t, 0, 0.7);
    final tent = Paint()..color = const Color(0xFFA8A29E);
    final tentDark = Paint()..color = const Color(0xFF78716C);
    const camp = [
      [96.0, 700.0, 92.0], [252.0, 664.0, 78.0],
      [904.0, 700.0, 92.0], [748.0, 664.0, 78.0],
    ];
    for (final c in camp) {
      final dir = c[0] < 500 ? -1 : 1;
      final tx = c[0] + dir * pull;
      final base = c[1];
      final w = c[2];
      canvas.drawPath(
        Path()
          ..moveTo(tx - w, base)
          ..lineTo(tx, base - w * 1.5)
          ..lineTo(tx + w, base)
          ..close(),
        tent,
      );
      canvas.drawPath(
        Path()
          ..moveTo(tx - w * 0.26, base)
          ..lineTo(tx, base - w * 0.7)
          ..lineTo(tx + w * 0.26, base)
          ..close(),
        tentDark,
      );
    }

    // The tabernacle itself — a curtained tent, right in the middle
    // Courtyard curtain wall
    canvas.drawRect(const Rect.fromLTWH(322, 646, 356, 90),
        Paint()..color = const Color(0xFFFAFAF9));
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(322 + i * 59.0, 646),
        Offset(322 + i * 59.0, 736),
        Paint()
          ..color = const Color(0xFFD6D3D1)
          ..strokeWidth = 5,
      );
    }
    // The tent body — deep blue and purple, as God specified
    canvas.drawRect(const Rect.fromLTWH(388, 470, 224, 180),
        Paint()..color = const Color(0xFF3730A3));
    canvas.drawRect(const Rect.fromLTWH(388, 470, 224, 40),
        Paint()..color = const Color(0xFF6D28D9));
    // Peaked roof so the silhouette reads as a tent (§ 4.1)
    canvas.drawPath(
      Path()
        ..moveTo(360, 470)
        ..lineTo(500, 382)
        ..lineTo(640, 470)
        ..close(),
      Paint()..color = const Color(0xFF9F1239),
    );
    // Entrance curtain
    canvas.drawRect(const Rect.fromLTWH(470, 528, 60, 122),
        Paint()..color = const Color(0xFFCA8A04));

    // God's glory filling the tent (ANIM 3, t 0.55→1)
    final gloryA = _cl(0, 1.0, t, 0.55, 1.0);
    if (gloryA > 0) {
      final gRect = Rect.fromCircle(center: const Offset(500, 520), radius: 260);
      canvas.drawOval(
        gRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.62 * gloryA),
              const Color(0xFFFEF3C7).withValues(alpha: 0.0),
            ],
          ).createShader(gRect),
      );
    }
  }
}
