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
  'twelve-spies':              [_TwelveSpiesScenePainter.new],
  'joshua-and-the-walls':      [_JerichoScenePainter.new],
  'deborah-leads-gods-people': [_DeborahScenePainter.new],
  'gideons-tiny-army':         [_GideonScenePainter.new],
  'ruth-finds-a-home':         [_RuthScenePainter.new],
  'samuel-listens-to-god':     [_SamuelScenePainter.new],
  'saul-the-king':             [_SaulScenePainter.new],
  'david-and-the-giant':           [_DavidGiantScenePainter.new],
  'davids-sin-and-gods-mercy':     [_DavidMercyScenePainter.new],
  'gods-forever-king-promise':     [_ForeverKingScenePainter.new],
  'solomon-asks-for-wisdom':       [_SolomonScenePainter.new],
  'elijah-and-the-only-true-god':  [_ElijahScenePainter.new],
  'the-prophets-promise-new-hearts': [_NewHeartsScenePainter.new],
  'an-angel-visits-mary':      [_AngelMaryScenePainter.new],
  'birth-of-jesus':         [_NativityScenePainter.new],
  'visitors-worship-the-king': [_MagiScenePainter.new],
  'jesus-grows-and-obeys':     [_JesusGrowsScenePainter.new],
  'jesus-is-baptised':         [_BaptismScenePainter.new],
  'jesus-says-no-to-tempter':  [_TemptationScenePainter.new],
  'jesus-calls-his-helpers':   [_CallHelpersScenePainter.new],
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
  // World 7 — The Compassionate King (#49–51)
  'jesus-calms-the-storm':          [_CalmsStormScenePainter.new],
  'jesus-heals-and-forgives':       [_HealsForgivesScenePainter.new],
  'jesus-feeds-the-crowd':          [_FeedsCrowdScenePainter.new],
  // World 8 — Jesus Saves (#57–63)
  'jesus-raises-lazarus':           [_LazarusScenePainter.new],
  'the-king-rides-in':              [_KingRidesInScenePainter.new],
  'servant-king-washes-feet':       [_WashesFeetScenePainter.new],
  'the-last-supper':                [_LastSupperScenePainter.new],
  'jesus-prays-in-garden':          [_GethsemaneScenePainter.new],
  'jesus-dies-for-sinners':         [_CrucifixionScenePainter.new],
  'jesus-is-alive':                 [_RisenScenePainter.new],
  // World 9 — Spirit-Filled Family (#65–72)
  'jesus-returns-to-his-father':    [_AscensionScenePainter.new],
  'the-holy-spirit-comes':          [_PentecostScenePainter.new],
  'a-new-sharing-family':           [_SharingFamilyScenePainter.new],
  'stephen-sees-jesus':             [_StephenScenePainter.new],
  'saul-meets-the-risen-jesus':     [_SaulRoadScenePainter.new],
  'peter-welcomes-cornelius':       [_CorneliusScenePainter.new],
  'paul-and-silas-in-prison':       [_PrisonSongScenePainter.new],
  'the-spirit-grows-good-fruit':    [_GoodFruitScenePainter.new],
  // World 10 — The King Makes All Things New (#73–80)
  'gods-armour-for-hard-days':      [_ArmourScenePainter.new],
  'when-anger-knocks':              [_AngerScenePainter.new],
  'when-i-feel-alone':              [_AloneScenePainter.new],
  'when-life-feels-unfair':         [_UnfairScenePainter.new],
  'when-someone-we-love-dies':      [_GriefScenePainter.new],
  'jesus-will-come-again':          [_ComeAgainScenePainter.new],
  'the-king-judges':                [_JudgeScenePainter.new],
  'god-makes-everything-new':       [_EverythingNewScenePainter.new],
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
  // Arms must stop just SHORT of the centre line, or they cross and the figure
  // reads as a big X on the chest. Reach to centre is (hR * 0.7) / cos(55°)
  // ≈ height * 0.22, so 0.19 brings the hands close together without crossing.
  final armLen = height * 0.19;
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

// ── 36. Twelve Spies and Two Trusting Hearts ──────────────────────────────────
// Intent: Two men carry one enormous bunch of grapes out of a good land while the
//         other ten hang back — same land, same fruit, two different hearts.
// ANIM 1: the good land greening up behind them (t 0→0.7)
// ANIM 2: the two carriers walking forward with the grapes (t 0→0.8)
// ANIM 3: the ten hesitating, drifting backward (t 0.3→1)
class _TwelveSpiesScenePainter extends ScenePainter {
  const _TwelveSpiesScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=400 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 400.0;

    _sky(canvas, const Color(0xFF60A5FA), const Color(0xFFFEF3C7));

    // The good land greening up behind them (ANIM 1, t 0→0.7)
    final green = Color.lerp(const Color(0xFF7C6A2E), const Color(0xFF15803D),
        _cl(0, 1, t, 0, 0.7))!;
    _ground(canvas, green, kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 900), width: 1700, height: 700),
      Paint()..color = Color.lerp(green, const Color(0xFF14532D), 0.45)!,
    );

    // Vine rows on the hillside, so the land reads as fruitful
    final vine = Paint()
      ..color = const Color(0xFF166534)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      final y = 430 + i * 26.0;
      canvas.drawLine(Offset(60 + i * 14, y), Offset(940 - i * 14, y), vine);
    }

    // The ten, hanging back at the right and drifting away (ANIM 3, t 0.3→1)
    final backX = _cl(0, 90, t, 0.3, 1.0);
    final tenP = Paint()..color = const Color(0xFF44403C).withValues(alpha: 0.85);
    for (int i = 0; i < 5; i++) {
      final x = 792 + (i % 3) * 62 + backX;
      final y = 606 + (i % 2) * 30.0;
      canvas.drawPath(
        Path()
          ..moveTo(x - 22, y)
          ..lineTo(x - 34, y + 84)
          ..lineTo(x + 34, y + 84)
          ..lineTo(x + 22, y)
          ..close(),
        tenP,
      );
      canvas.drawCircle(Offset(x, y - 22), 24, tenP);
    }

    // The two carriers walking forward with the grapes (ANIM 2, t 0→0.8)
    final cx = _cl(300, 400, t, 0, 0.8);
    // The carrying pole across both their shoulders
    canvas.drawLine(
      Offset(cx - 150, 560),
      Offset(cx + 150, 560),
      Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round,
    );
    // The enormous grape cluster hanging from the middle of the pole
    final grape = Paint()..color = const Color(0xFF6B21A8);
    const rows = [
      [0.0, 600.0, 4], [0.0, 648.0, 3], [0.0, 692.0, 2], [0.0, 732.0, 1],
    ];
    for (final r in rows) {
      final n = r[2] as int;
      final y = r[1] as double;
      for (int i = 0; i < n; i++) {
        final gx = cx + (i - (n - 1) / 2) * 50;
        canvas.drawCircle(Offset(gx, y), 27, grape);
      }
    }
    // § 4.2 limb rule: 250°/300° = 50° apart ✓ (both arms up, holding the pole)
    _person(canvas, cx - 176, 800, 282,
        const Color(0xFF8D5524), const Color(0xFF1D4ED8),
        armAngleL: 250, armAngleR: 300);
    _person(canvas, cx + 176, 800, 276,
        const Color(0xFFC68642), const Color(0xFF166534),
        armAngleL: 250, armAngleR: 300);
  }
}

// ── 37. Joshua and the Strong Walls ───────────────────────────────────────────
// Intent: A great walled city stands shut, God's people circle it in silence,
//         and then the wall simply falls.
// ANIM 1: the marching line moving round the wall (t 0→0.75)
// ANIM 2: the wall cracking, then falling (t 0.75→1)
// ANIM 3: dust rising as it comes down (t 0.8→1)
class _JerichoScenePainter extends ScenePainter {
  const _JerichoScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=600 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 600.0;

    _sky(canvas, const Color(0xFF38BDF8), const Color(0xFFFEF3C7));

    // Ground — dusty plain, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFFB98B45), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 1000), width: 1700, height: 660),
      Paint()..color = const Color(0xFF9A6F31),
    );

    // The wall — falls flat at the very end (ANIM 2, t 0.75→1).
    // Height collapses to almost nothing; that IS the story.
    final fall = _cl(0, 1, t, 0.75, 1.0);
    final wallTop = _lerp(300, 566, fall);
    final stone = Paint()..color = const Color(0xFFE7E5E4);
    final stoneDark = Paint()..color = const Color(0xFFC5C1BB);
    canvas.drawRect(Rect.fromLTRB(210, wallTop, 790, kHorizon), stone);
    // Battlements along the top, only while the wall still stands
    if (fall < 0.85) {
      for (int i = 0; i < 7; i++) {
        canvas.drawRect(
            Rect.fromLTWH(224 + i * 82, wallTop - 26, 46, 26), stoneDark);
      }
    }
    // Stone courses
    final course = Paint()
      ..color = const Color(0xFFA8A29E)
      ..strokeWidth = 4;
    for (int i = 1; i < 5; i++) {
      final y = wallTop + (kHorizon - wallTop) * i / 5;
      canvas.drawLine(Offset(210, y), Offset(790, y), course);
    }
    // Shut gate, while the wall stands
    if (fall < 0.6) {
      canvas.drawRect(
          Rect.fromLTRB(452, kHorizon - 108, 548, kHorizon),
          Paint()..color = const Color(0xFF57534E));
    }
    // Cracks appearing just before it goes
    if (fall > 0.15 && fall < 0.9) {
      final crack = Paint()
        ..color = const Color(0xFF78716C)
        ..strokeWidth = 6;
      canvas.drawLine(const Offset(340, 320), const Offset(378, 560), crack);
      canvas.drawLine(const Offset(620, 330), const Offset(586, 560), crack);
    }

    // Fallen stone blocks, so the wall reads as HAVING FALLEN rather than as
    // having simply vanished. Without these, t=1 looks like an empty plain.
    if (fall > 0.4) {
      final rubbleA = _cl(0, 1.0, t, 0.82, 1.0);
      if (rubbleA > 0) {
        final rP = Paint()..color = const Color(0xFFD6D3D1).withValues(alpha: rubbleA);
        final rEdge = Paint()
          ..color = const Color(0xFFA8A29E).withValues(alpha: rubbleA)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;
        const blocks = [
          [176.0, 566.0, 92.0, 40.0], [292.0, 588.0, 76.0, 34.0],
          [402.0, 570.0, 104.0, 38.0], [536.0, 592.0, 86.0, 32.0],
          [648.0, 566.0, 96.0, 42.0], [772.0, 590.0, 72.0, 34.0],
          [240.0, 620.0, 118.0, 36.0], [606.0, 624.0, 110.0, 34.0],
        ];
        for (final b in blocks) {
          final r = Rect.fromLTWH(b[0], b[1], b[2], b[3]);
          canvas.drawRect(r, rP);
          canvas.drawRect(r, rEdge);
        }
      }
    }

    // Dust rising as the wall comes down (ANIM 3, t 0.8→1).
    // Kept low and thin so it never reads as a bank of clouds.
    final dustA = _cl(0, 0.4, t, 0.8, 1.0);
    if (dustA > 0) {
      final dP = Paint()..color = const Color(0xFFE7E5E4).withValues(alpha: dustA);
      for (final d in const [[260, 578, 150], [500, 566, 190], [740, 578, 160]]) {
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(d[0].toDouble(), d[1].toDouble()),
              width: d[2].toDouble(),
              height: d[2].toDouble() * 0.32),
          dP,
        );
      }
    }

    // The marching line circling the city (ANIM 1, t 0→0.75).
    // They walk left-to-right across the front of the wall.
    final marchX = _cl(-40, 240, t, 0, 0.75);
    final walker = Paint()..color = const Color(0xFF7C2D12);
    for (int i = 0; i < 6; i++) {
      final x = marchX + i * 116;
      if (x < -60 || x > 1060) continue;
      canvas.drawPath(
        Path()
          ..moveTo(x - 20, 704)
          ..lineTo(x - 30, 782)
          ..lineTo(x + 30, 782)
          ..lineTo(x + 20, 704)
          ..close(),
        walker,
      );
      canvas.drawCircle(Offset(x, 682), 22, walker);
      // Rams-horn trumpet, raised
      canvas.drawLine(
        Offset(x + 16, 690),
        Offset(x + 52, 664),
        Paint()
          ..color = const Color(0xFFCA8A04)
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

// ── 38. Deborah Leads God's People ────────────────────────────────────────────
// Intent: A wise woman sits under her palm tree and people come from everywhere
//         to hear what God says.
// ANIM 1: the palm fronds opening out overhead (t 0→0.7)
// ANIM 2: people arriving and gathering to listen (t 0.2→1)
// ANIM 3: warm light settling over the place she sits (t 0.45→1)
class _DeborahScenePainter extends ScenePainter {
  const _DeborahScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=380 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 380.0;

    _sky(canvas, const Color(0xFF7DD3FC), const Color(0xFFFEF3C7));

    // Distant hills, so the hillside setting reads
    canvas.drawPath(
      Path()
        ..moveTo(0, kHorizon)
        ..quadraticBezierTo(240, kHorizon - 90, 480, kHorizon)
        ..quadraticBezierTo(720, kHorizon - 70, 1000, kHorizon)
        ..lineTo(1000, kHorizon + 40)
        ..lineTo(0, kHorizon + 40)
        ..close(),
      Paint()..color = const Color(0xFF4D7C0F),
    );

    // Ground — grassy hillside, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF3F6212), kHorizon + 30);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 880), width: 1700, height: 700),
      Paint()..color = const Color(0xFF365314),
    );

    // Warm light over where she sits (ANIM 3, t 0.45→1)
    final lightR = _cl(0, 300, t, 0.45, 1.0);
    if (lightR > 0) {
      final lRect = Rect.fromCircle(center: const Offset(360, 580), radius: lightR);
      canvas.drawOval(
        lRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.42),
              const Color(0xFFFEF3C7).withValues(alpha: 0.0),
            ],
          ).createShader(lRect),
      );
    }

    // The palm — trunk, then fronds opening overhead (ANIM 1, t 0→0.7).
    // Set well to Deborah's left: directly behind her the trunk reads as
    // growing out of her head.
    canvas.drawPath(
      Path()
        ..moveTo(122, 700)
        ..quadraticBezierTo(142, 520, 150, 340)
        ..lineTo(186, 344)
        ..quadraticBezierTo(174, 524, 158, 700)
        ..close(),
      Paint()..color = const Color(0xFF78350F),
    );
    final spread = _cl(0.35, 1.0, t, 0, 0.7);
    final frond = Paint()
      ..color = const Color(0xFF15803D)
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    for (final a in const [-150.0, -118.0, -84.0, -50.0, -18.0]) {
      final rad = a * math.pi / 180;
      final len = 210 * spread;
      canvas.drawLine(
        const Offset(168, 340),
        Offset(168 + len * math.cos(rad), 340 + len * math.sin(rad) * 0.75),
        frond,
      );
    }
    // Dates clustered at the crown
    final date = Paint()..color = const Color(0xFFB45309);
    for (final d in const [[150, 356], [182, 350], [166, 372]]) {
      canvas.drawCircle(Offset(d[0].toDouble(), d[1].toDouble()), 12, date);
    }

    // People arriving to listen (ANIM 2, t 0.2→1) — they come IN toward her
    final comeIn = _cl(220, 0, t, 0.2, 1.0);
    final listener = Paint()..color = const Color(0xFF44290F);
    for (int i = 0; i < 4; i++) {
      final x = 640 + i * 92 + comeIn;
      final y = 690 + (i % 2) * 34.0;
      canvas.drawPath(
        Path()
          ..moveTo(x - 24, y)
          ..lineTo(x - 36, y + 88)
          ..lineTo(x + 36, y + 88)
          ..lineTo(x + 24, y)
          ..close(),
        listener,
      );
      canvas.drawCircle(Offset(x, y - 24), 26, listener);
    }

    // Deborah, seated in the shade of the palm — the still centre of the picture.
    // § 4.2 limb rule: 40°/140° = 100° apart ✓ (hands out as she teaches)
    _kneeling(canvas, 372, 782, 262,
        const Color(0xFFC68642), const Color(0xFF9F1239),
        prayerOpenDeg: 1.0);
  }
}

// ── 39. Gideon's Tiny Army ────────────────────────────────────────────────────
// Intent: A handful of people on a dark hill hold clay jars full of light above a
//         valley packed with an enemy camp — few and small, and that is the point.
// ANIM 1: the enemy campfires filling the valley below (t 0→0.6)
// ANIM 2: the three hundred's lamps blazing out as the jars break (t 0.55→1)
// ANIM 3: stars appearing overhead (t 0.2→1)
class _GideonScenePainter extends ScenePainter {
  const _GideonScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=420 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 420.0;

    _sky(canvas, const Color(0xFF0C1445), const Color(0xFF312E81));

    // Stars appearing overhead (ANIM 3, t 0.2→1)
    final starA = _cl(0, 0.85, t, 0.2, 1.0);
    for (final s in const [
      [70, 90, 5], [200, 150, 4], [330, 80, 4], [470, 140, 5], [610, 90, 4],
      [750, 150, 4], [880, 86, 5], [950, 200, 4], [130, 240, 4], [400, 260, 3],
    ]) {
      _dot(canvas, s[0].toDouble(), s[1].toDouble(), s[2].toDouble(), starA);
    }

    // The valley floor — darker than the sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF1C1917), kHorizon);

    // The enemy camp filling the valley below (ANIM 1, t 0→0.6).
    // Rows of tiny tents and campfires — the "too many to count" side.
    final campA = _cl(0, 1, t, 0, 0.6);
    if (campA > 0) {
      final tentP = Paint()..color = const Color(0xFF44403C).withValues(alpha: campA);
      final fireP = Paint()..color = const Color(0xFFB45309).withValues(alpha: campA * 0.9);
      for (int row = 0; row < 3; row++) {
        final y = 448 + row * 46.0;
        final w = 26 + row * 6.0;
        for (int i = 0; i < 12; i++) {
          final x = 30 + i * 84.0 + (row.isOdd ? 42 : 0);
          canvas.drawPath(
            Path()
              ..moveTo(x - w, y + w * 0.7)
              ..lineTo(x, y - w * 0.7)
              ..lineTo(x + w, y + w * 0.7)
              ..close(),
            tentP,
          );
          if (i.isEven) {
            canvas.drawCircle(Offset(x + 42, y + w * 0.7), 6 + row * 1.5, fireP);
          }
        }
      }
    }

    // The near hillside the three hundred stand on — darker still
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 900), width: 1800, height: 560),
      Paint()..color = const Color(0xFF120F0D),
    );

    // The lamps blazing out as the jars break (ANIM 2, t 0.55→1)
    final blaze = _cl(0.18, 1.0, t, 0.55, 1.0);
    for (final jx in const [180.0, 380.0, 620.0, 820.0]) {
      final jRect = Rect.fromCircle(center: Offset(jx, 660), radius: 150 * blaze);
      canvas.drawOval(
        jRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFBBF24).withValues(alpha: 0.75 * blaze),
              const Color(0xFFFBBF24).withValues(alpha: 0.0),
            ],
          ).createShader(jRect),
      );
      // The clay jar itself, held up
      canvas.drawPath(
        Path()
          ..moveTo(jx - 30, 636)
          ..lineTo(jx - 38, 700)
          ..lineTo(jx + 38, 700)
          ..lineTo(jx + 30, 636)
          ..close(),
        Paint()..color = const Color(0xFF92400E),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(jx - 36, 622, 72, 22), const Radius.circular(8)),
        Paint()..color = const Color(0xFFA16207),
      );
      // Torchlight escaping the mouth of the jar once it is broken
      if (blaze > 0.5) {
        canvas.drawCircle(Offset(jx, 626), 16 * blaze,
            Paint()..color = const Color(0xFFFEF3C7));
      }
    }

    // Gideon, standing among the three hundred with his jar raised.
    // § 4.2 limb rule: 254°/300° = 46° apart ✓ (both arms up, holding it high)
    _person(canvas, 500, 786, 284, const Color(0xFF8D5524), const Color(0xFF7C2D12),
        armAngleL: 254, armAngleR: 300);
  }
}

// ── 40. Ruth Finds a Home ─────────────────────────────────────────────────────
// Intent: A young woman gathers the leftover grain at the edge of a wide golden
//         field, and the owner of the field has noticed her.
// ANIM 1: the barley field ripening across the whole picture (t 0→0.7)
// ANIM 2: Ruth's armful of gathered grain growing (t 0.25→1)
// ANIM 3: Boaz crossing the field toward her (t 0.4→1)
class _RuthScenePainter extends ScenePainter {
  const _RuthScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=360 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 360.0;

    _sky(canvas, const Color(0xFF7DD3FC), const Color(0xFFFEF3C7));

    // The field ripening — green through to full harvest gold (ANIM 1, t 0→0.7)
    final ripe = _cl(0, 1, t, 0, 0.7);
    final fieldColour = Color.lerp(const Color(0xFF65A30D), const Color(0xFFCA8A04), ripe)!;
    _ground(canvas, fieldColour, kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 880), width: 1700, height: 720),
      Paint()..color = Color.lerp(fieldColour, const Color(0xFF854D0E), 0.35)!,
    );

    // Standing barley — rows of upright stalks, taller toward the front.
    // Deliberately darker than the field: at full ripeness a gold stalk on gold
    // ground is invisible.
    final stalk = Paint()
      ..color = Color.lerp(const Color(0xFF365314), const Color(0xFF713F12), ripe)!
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    for (int row = 0; row < 4; row++) {
      final baseY = 430 + row * 52.0;
      final h = 34 + row * 12.0;
      for (int i = 0; i < 16; i++) {
        final x = 24 + i * 64.0 + (row.isOdd ? 32 : 0);
        canvas.drawLine(Offset(x, baseY), Offset(x + 4, baseY - h), stalk);
      }
    }

    // Boaz crossing the field toward her (ANIM 3, t 0.4→1)
    final boazX = _cl(880, 726, t, 0.4, 1.0);
    // § 4.2 limb rule: 132°/44° = 88° apart ✓ (one hand out in greeting)
    _person(canvas, boazX, 748, 250, const Color(0xFF8D5524), const Color(0xFF0F766E),
        armAngleL: 132, armAngleR: 44);

    // Ruth, bent over gathering the leftover grain — the subject of the picture.
    // § 4.2 limb rule: 56°/124° = 68° apart ✓ (both arms down, gathering)
    _kneeling(canvas, 360, 800, 268,
        const Color(0xFFC68642), const Color(0xFF9F1239),
        prayerOpenDeg: 0.15);

    // Her gathered armful growing (ANIM 2, t 0.25→1).
    // Sits low and to the side, as if resting on the ground beside her — held at
    // chest height it read as a hand fan rather than gathered grain.
    final bundle = _cl(0, 1, t, 0.25, 1.0);
    if (bundle > 0) {
      final sheaf = Paint()
        ..color = const Color(0xFFFDE68A)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      final n = (3 + bundle * 5).round();
      for (int i = 0; i < n; i++) {
        // Fan upward from a tied base, spanning -120° to -60° (a standing sheaf)
        final a = (-124 + i * 8.5) * math.pi / 180;
        canvas.drawLine(
          const Offset(520, 782),
          Offset(520 + 96 * math.cos(a), 782 + 96 * math.sin(a)),
          sheaf,
        );
      }
      // Tie around the base of the sheaf
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(492, 752, 58, 20), const Radius.circular(9)),
        Paint()..color = const Color(0xFF92400E),
      );
    }
  }
}

// ── 41. Samuel Listens to God ─────────────────────────────────────────────────
// Intent: A boy sits up in the dark beside the one lamp still burning, and
//         answers the voice that called his name.
// ANIM 1: the lamp flame steadying and brightening (t 0→0.6)
// ANIM 2: Samuel sitting up from his mat to listen (t 0.2→0.8)
// ANIM 3: God's light gathering in the room around him (t 0.5→1)
class _SamuelScenePainter extends ScenePainter {
  const _SamuelScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Interior night scene. Floor line at y=700 — outside y 450–550 (§ 4.4).
    const kFloor = 700.0;

    _sky(canvas, const Color(0xFF0C1445), const Color(0xFF312E81));

    // God's light gathering in the room (ANIM 3, t 0.5→1)
    final holyR = _cl(0, 420, t, 0.5, 1.0);
    if (holyR > 0) {
      final hRect = Rect.fromCircle(center: const Offset(560, 420), radius: holyR);
      canvas.drawOval(
        hRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.34),
              const Color(0xFFFEF3C7).withValues(alpha: 0.0),
            ],
          ).createShader(hRect),
      );
    }

    // Floor — darker than the room above (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF1C1512), kFloor);

    // Stone wall behind, with courses so the room reads as built
    canvas.drawRect(const Rect.fromLTWH(0, 180, 1000, 520),
        Paint()..color = const Color(0xFF292524).withValues(alpha: 0.75));
    final course = Paint()
      ..color = const Color(0xFF1C1917)
      ..strokeWidth = 5;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, 180 + i * 130), Offset(1000, 180 + i * 130), course);
    }

    // The lamp on its stand — flame steadying and brightening (ANIM 1, t 0→0.6)
    final flameH = _cl(18, 44, t, 0, 0.6);
    final lampA = _cl(0.4, 1.0, t, 0, 0.6);
    canvas.drawRect(const Rect.fromLTWH(176, 560, 26, 140),
        Paint()..color = const Color(0xFF57534E));
    canvas.drawRect(const Rect.fromLTWH(140, 690, 98, 20),
        Paint()..color = const Color(0xFF44403C));
    canvas.drawOval(const Rect.fromLTWH(146, 528, 86, 40),
        Paint()..color = const Color(0xFF92400E));
    // Flame
    canvas.drawPath(
      Path()
        ..moveTo(176, 532)
        ..quadraticBezierTo(184, 532 - flameH * 0.6, 189, 532 - flameH)
        ..quadraticBezierTo(194, 532 - flameH * 0.6, 202, 532)
        ..close(),
      Paint()..color = const Color(0xFFFBBF24).withValues(alpha: lampA),
    );
    // Lamp glow
    final gRect = Rect.fromCircle(center: const Offset(189, 540), radius: 190);
    canvas.drawOval(
      gRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFBBF24).withValues(alpha: 0.42 * lampA),
            const Color(0xFFFBBF24).withValues(alpha: 0.0),
          ],
        ).createShader(gRect),
    );

    // The sleeping mat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(400, 736, 460, 44), const Radius.circular(16)),
      Paint()..color = const Color(0xFF7C2D12),
    );

    // Samuel sitting up from the mat to listen (ANIM 2, t 0.2→0.8).
    // Rising is expressed as the seated figure getting taller.
    final sitH = _cl(228, 288, t, 0.2, 0.8);
    // § 4.2 limb rule: 55°/125° at rest → 40°/140° open = 70°→100° apart ✓
    _kneeling(canvas, 600, 760, sitH,
        const Color(0xFF8D5524), const Color(0xFF1E3A8A),
        prayerOpenDeg: _cl(0, 0.7, t, 0.2, 0.8));
  }
}

// ── 42. Saul: The King Who Would Not Listen ───────────────────────────────────
// Intent: A crowned king stands alone on a bare hilltop holding a torn piece of
//         robe while the prophet walks away — obedience halfway is not obedience.
// ANIM 1: the sky greying over as the day turns (t 0→0.7)
// ANIM 2: Samuel walking away down the slope (t 0.3→1)
// ANIM 3: the kept sheep appearing behind Saul — the part he did not obey (t 0.45→1)
class _SaulScenePainter extends ScenePainter {
  const _SaulScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=580 — outside forbidden zone y 450–550 (§ 4.4).
    const kHorizon = 580.0;

    // The sky greying over (ANIM 1, t 0→0.7)
    final fade = _cl(0, 1, t, 0, 0.7);
    _sky(
      canvas,
      Color.lerp(const Color(0xFF64748B), const Color(0xFF475569), fade)!,
      Color.lerp(const Color(0xFFFDE68A), const Color(0xFF94A3B8), fade)!,
    );

    // Ground — bare windswept hilltop, darker than sky (§ 4.4 ✓)
    _ground(canvas, const Color(0xFF57534E), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 940), width: 1800, height: 720),
      Paint()..color = const Color(0xFF44403C),
    );

    // The kept sheep behind him — the part he did not obey (ANIM 3, t 0.45→1)
    final sheepA = _cl(0, 1.0, t, 0.45, 1.0);
    if (sheepA > 0) {
      final wool = Paint()..color = const Color(0xFFE7E5E4).withValues(alpha: sheepA);
      final face = Paint()..color = const Color(0xFF78716C).withValues(alpha: sheepA);
      for (final s in const [[726.0, 648.0, 1.0], [846.0, 676.0, 0.86], [640.0, 690.0, 0.8]]) {
        final sx = s[0];
        final sy = s[1];
        final k = s[2];
        canvas.drawOval(
            Rect.fromCenter(center: Offset(sx, sy), width: 116 * k, height: 68 * k), wool);
        canvas.drawCircle(Offset(sx + 56 * k, sy - 16 * k), 22 * k, face);
      }
    }

    // Samuel walking away down the slope (ANIM 2, t 0.3→1) — smaller as he goes.
    // Base height must keep the SMALLEST value above _person's 220-unit floor:
    // 280 × 0.82 = 229.6 ✓  (262 × 0.82 = 215 would trip the assert).
    final samX = _cl(300, 120, t, 0.3, 1.0);
    final samScale = _cl(1.0, 0.82, t, 0.3, 1.0);
    // § 4.2 limb rule: 118°/62° = 56° apart ✓
    // Robe must NOT be 0xFF44403C — that is the exact ground colour, which made
    // his body vanish and left a floating head and arms.
    _person(canvas, samX, 760, 280 * samScale,
        const Color(0xFFC68642), const Color(0xFF9CA3AF),
        armAngleL: 118, armAngleR: 62);

    // Saul, alone and turned half away, still crowned.
    // § 4.2 limb rule: 112°/40° = 72° apart ✓ (one hand holding the torn robe)
    _person(canvas, 560, 782, 300, const Color(0xFF8D5524), const Color(0xFF7E7A73),
        armAngleL: 112, armAngleR: 40);
    // The crown — dull gold, still on his head
    canvas.drawPath(
      Path()
        ..moveTo(518, 528)
        ..lineTo(526, 486)
        ..lineTo(544, 516)
        ..lineTo(560, 480)
        ..lineTo(576, 516)
        ..lineTo(594, 486)
        ..lineTo(602, 528)
        ..close(),
      Paint()..color = const Color(0xFFB08D3A),
    );
    // The torn scrap of robe in his hand
    canvas.drawPath(
      Path()
        ..moveTo(640, 636)
        ..lineTo(704, 660)
        ..lineTo(684, 700)
        ..lineTo(664, 676)
        ..lineTo(648, 692)
        ..close(),
      Paint()..color = const Color(0xFF9CA3AF),
    );
  }
}

// ── 43. David and the Giant ───────────────────────────────────────────────────
// Intent: one small boy walks out alone into the valley for everyone else, and
//         the giant nobody could beat comes down.

class _DavidGiantScenePainter extends ScenePainter {
  const _DavidGiantScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=600 — outside the forbidden 450–550 band (§ 4.4).
    const kHorizon = 600.0;

    _sky(canvas, const Color(0xFFF3C77B), const Color(0xFFFDE9C4));

    // Two hills of watching armies, drawn as flat-topped bands (never wedges —
    // a tapering wedge on the ground reads as a mountain, § 4.4).
    _ground(canvas, const Color(0xFFB98A4E), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 660), width: 720, height: 190),
      Paint()..color = const Color(0xFFA97C45),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(950, 664), width: 760, height: 200),
      Paint()..color = const Color(0xFFA97C45),
    );
    // Valley floor — darker than the hills so the gap between them reads.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 950), width: 1500, height: 640),
      Paint()..color = const Color(0xFF8C6538),
    );

    // ANIM 3 — the watching armies stand up along both ridges (t 0.55→1).
    final crowdA = _cl(0.0, 1.0, t, 0.55, 1.0);
    if (crowdA > 0) {
      final cp = Paint()..color = const Color(0xFF6B4E2A).withValues(alpha: crowdA);
      for (final s in const [
        [58.0, 600.0], [116.0, 594.0], [174.0, 600.0], [232.0, 592.0],
        [806.0, 596.0], [864.0, 590.0], [922.0, 596.0], [978.0, 588.0],
      ]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(s[0], s[1] - 26), width: 26, height: 62),
            const Radius.circular(13),
          ),
          cp,
        );
      }
    }

    // ANIM 2 — the giant tips over, rotating about his feet (t 0.62→1).
    // Non-graphic: he simply lies down. Rotation stops at 84°, so he is flat.
    final fall = _cl(0.0, 1.0, t, 0.62, 1.0);
    canvas.save();
    // The lift is not decoration. Rotating about the feet alone leaves the whole
    // fallen figure lying in y 660–790, which the 411×240 header crop (visible
    // band y 208–792) slices through, and puts his dark armour flat on the dark
    // valley floor — together that read as an indistinct heap of blocks. Lifting
    // him 74 units brings the body up into the safe zone where it is fully seen.
    canvas.translate(786, 772 - fall * 74);
    // Negative = he falls leftward, into the open valley floor. Rotating the
    // other way swings a 460-unit figure out past x=1240, off the design box.
    canvas.rotate(-fall * 80 * math.pi / 180);
    canvas.translate(-786, -772);
    _giant(canvas);
    canvas.restore();

    // David — small on purpose, but still ≥ 220 units so he reads as a person.
    // § 4.2 limb rule: 235°/100° = 135° apart ✓ (sling arm swung up and back,
    // other arm hanging). 196° was almost horizontal and read as a pole.
    // Feet at y=772 ≤ 782, so he survives the 411×240 header crop (§ 4.4).
    _person(canvas, 250, 772, 230, const Color(0xFF8D5524), const Color(0xFFB45309),
        armAngleL: 235, armAngleR: 100);

    // ANIM 1 — the stone flies along an arc from David's sling to the giant
    // (t 0.12→0.6), then stops being drawn once the giant starts to fall.
    final flight = _cl(0.0, 1.0, t, 0.12, 0.6);
    if (flight > 0 && fall < 0.06) {
      final sx = _lerp(300, 742, flight);
      // Parabola: rises to the apex at flight=0.5, comes back down.
      final sy = _lerp(628, 596, flight) - 96 * math.sin(flight * math.pi);
      canvas.drawCircle(Offset(sx, sy), 15, Paint()..color = const Color(0xFF57534E));
    }

    // The five smooth stones at David's feet — the detail children reach for.
    final stone = Paint()..color = const Color(0xFF78716C);
    for (final s in const [[150.0, 786.0], [186.0, 794.0], [124.0, 800.0]]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(s[0], s[1]), width: 30, height: 20), stone);
    }
  }

  /// The giant — bespoke, because he is far taller than _person is built for.
  void _giant(Canvas canvas) {
    const gx = 786.0;   // centre x
    const fy = 772.0;   // feet y (≤ 782, § 4.4)
    const h = 460.0;    // total height — roughly double David's
    const hR = h * 0.11;
    const headY = fy - h + hR;
    const shoulderY = headY + hR * 2.0;

    // Neck, so the head never floats (§ 4.2)
    canvas.drawRect(
      const Rect.fromLTRB(gx - 20, headY + 24, gx + 20, shoulderY + 2),
      Paint()..color = const Color(0xFF7C6A55),
    );
    // Two separate LEGS, not a robe. This is what makes the fallen giant read as
    // a figure: any single wide trapezoid — banded, plated, or plain — becomes a
    // rectangular slab once it is rotated 84° to lie down, and the eye calls it a
    // crate. A torso with two legs coming off it stays a body at any angle.
    const hipY = shoulderY + 166;
    final legP = Paint()..color = const Color(0xFF5E5138);
    for (final s in const [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(gx + s * 30, hipY);
      canvas.rotate(s * 0.16);   // slightly splayed
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, (fy - hipY) / 2), width: 54, height: fy - hipY),
          const Radius.circular(20)),
        legP,
      );
      canvas.restore();
    }
    // Armoured torso — narrower than it is long, so it never squares up.
    canvas.drawPath(
      Path()
        ..moveTo(gx - hR * 1.6, shoulderY)
        ..lineTo(gx - hR * 1.35, hipY + 14)
        ..lineTo(gx + hR * 1.35, hipY + 14)
        ..lineTo(gx + hR * 1.6, shoulderY)
        ..close(),
      Paint()..color = const Color(0xFF6B5B3E),
    );
    // Chest plate + belt give the torso a top and a middle.
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(gx, shoulderY + 64), width: hR * 2.0, height: hR * 2.2),
      Paint()..color = const Color(0xFF8A7550),
    );
    canvas.drawRect(
      const Rect.fromLTRB(gx - hR * 1.42, hipY - 22, gx + hR * 1.42, hipY + 6),
      Paint()..color = const Color(0xFF4E4231),
    );
    // Arms — § 4.2 limb rule: 118°/50° = 68° apart ✓
    final arm = Paint()
      ..color = const Color(0xFF7C6A55)
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const sy = shoulderY + 20;
    const armLen = h * 0.26;
    canvas.drawLine(const Offset(gx - 42, sy),
        Offset(gx - 42 + armLen * math.cos(118 * math.pi / 180),
               sy + armLen * math.sin(118 * math.pi / 180)), arm);
    canvas.drawLine(const Offset(gx + 42, sy),
        Offset(gx + 42 + armLen * math.cos(50 * math.pi / 180),
               sy + armLen * math.sin(50 * math.pi / 180)), arm);
    // Spear in the lowered hand
    canvas.drawLine(const Offset(gx + 128, sy - 40), const Offset(gx + 160, fy),
        Paint()
          ..color = const Color(0xFF57534E)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round);
    // Head + helmet
    canvas.drawCircle(const Offset(gx, headY), hR, Paint()..color = const Color(0xFF7C6A55));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(gx, headY - 4), radius: hR + 8),
      math.pi, math.pi, false,
      Paint()..color = const Color(0xFF8A7550),
    );
    // Two face features, because he is > 300 units tall (§ 4.2)
    final fP = Paint()..color = const Color(0xFF3F2E1B);
    canvas.drawCircle(const Offset(gx - 16, headY + 2), 7, fP);
    canvas.drawCircle(const Offset(gx + 16, headY + 2), 7, fP);
    canvas.drawLine(const Offset(gx - 16, headY + 26), const Offset(gx + 16, headY + 26),
        Paint()
          ..color = const Color(0xFF3F2E1B)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round);
  }
}

// ── 44. David's Sin and God's Mercy ───────────────────────────────────────────
// Intent: a king who has stopped hiding kneels in the dark, and the prophet who
//         found him out reaches towards him instead of pointing at him.

class _DavidMercyScenePainter extends ScenePainter {
  const _DavidMercyScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon (roof line) at y=620 — outside the forbidden 450–550 band (§ 4.4).
    const kRoof = 620.0;

    _sky(canvas, const Color(0xFF13223D), const Color(0xFF2C4468));

    // Quiet stars, so t=0 is already a composed night picture (§ 4.5).
    for (final s in const [
      [128.0, 176.0, 5.0], [268.0, 118.0, 4.0], [404.0, 208.0, 3.5],
      [612.0, 142.0, 4.5], [762.0, 226.0, 3.5], [896.0, 152.0, 5.0],
      [188.0, 296.0, 3.0], [706.0, 322.0, 3.0],
    ]) {
      _dot(canvas, s[0], s[1], s[2], 0.75);
    }

    // The palace roof — darker than the sky (§ 4.4)
    _ground(canvas, const Color(0xFF0E1A2E), kRoof);
    canvas.drawRect(
      const Rect.fromLTWH(0, kRoof, 1000, 26),
      Paint()..color = const Color(0xFF1C2C4A),
    );

    // ANIM 1 — mercy arrives as a warm glow over the kneeling king (t 0.3→1).
    // RadialGradient, never a flat-alpha circle (that reads as a pale dome, § 4.4).
    final glow = _cl(0.0, 1.0, t, 0.3, 1.0);
    if (glow > 0) {
      canvas.drawCircle(
        const Offset(392, 560), 330,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: 0.50 * glow),
              const Color(0xFFFDE68A).withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: const Offset(392, 560), radius: 330)),
      );
    }

    // The king, kneeling. _kneeling's arms come together at the chest, which is
    // exactly right here. Height 300 ≥ 220 ✓.
    _kneeling(canvas, 392, 782, 300, const Color(0xFF8D5524), const Color(0xFF6D28D9));

    // His crown, set down on the roof beside him rather than on his head —
    // he is not being king in this moment, he is being forgiven.
    canvas.drawPath(
      Path()
        ..moveTo(178, 776)
        ..lineTo(186, 736)
        ..lineTo(204, 764)
        ..lineTo(220, 730)
        ..lineTo(236, 764)
        ..lineTo(254, 736)
        ..lineTo(262, 776)
        ..close(),
      Paint()..color = const Color(0xFFB08D3A),
    );

    // Nathan, standing quietly, one hand extended towards David — kindness, not
    // an accusation. § 4.2 limb rule: 152°/60° = 92° apart ✓
    // 168° was near-horizontal and read as a plank floating across the sky;
    // angling it down means the hand reaches towards the kneeling king instead.
    // Robe 0xFF9CA3AF is deliberately NOT the roof colour, or the body vanishes.
    _person(canvas, 726, 782, 296, const Color(0xFFC68642), const Color(0xFF9CA3AF),
        armAngleL: 152, armAngleR: 60);

    // ANIM 2 — the little oil lamp brightens as the night goes on (t 0→0.65).
    final lamp = _cl(0.35, 1.0, t, 0.0, 0.65);
    canvas.drawOval(
      const Rect.fromLTWH(838, 742, 92, 42),
      Paint()..color = const Color(0xFF78350F),
    );
    canvas.drawCircle(
      const Offset(884, 730), 46,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFEF3C7).withValues(alpha: 0.95 * lamp),
            const Color(0xFFF59E0B).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: const Offset(884, 730), radius: 46)),
    );
  }
}

// ── 45. God's Forever-King Promise ────────────────────────────────────────────
// Intent: David offered God a house, and God answered with a crown of light
//         among the stars — a King whose reign simply never ends.

class _ForeverKingScenePainter extends ScenePainter {
  const _ForeverKingScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Floor line at y=640 — outside the forbidden 450–550 band (§ 4.4).
    const kFloor = 640.0;

    _sky(canvas, const Color(0xFF1E1B4B), const Color(0xFF4C1D95));

    // ANIM 1 — the stars come out, near ones first (t 0→0.55).
    // Starts at 0.3, not 0: at zero the whole upper two thirds of the frame was a
    // flat purple field, so t=0 was not a composed picture (§ 4.5).
    final starA = _cl(0.3, 1.0, t, 0.0, 0.55);
    for (final s in const [
      [96.0, 210.0, 4.5], [214.0, 132.0, 5.5], [318.0, 244.0, 3.5],
      [452.0, 158.0, 4.0], [560.0, 262.0, 3.5], [672.0, 130.0, 5.0],
      [788.0, 240.0, 4.0], [906.0, 164.0, 5.5], [148.0, 330.0, 3.0],
      [852.0, 342.0, 3.0], [386.0, 344.0, 2.5], [618.0, 356.0, 2.5],
    ]) {
      _dot(canvas, s[0], s[1], s[2], 0.9 * starA);
    }

    // ANIM 2 — the forever crown forms among the stars (t 0.35→1).
    final crownA = _cl(0.0, 1.0, t, 0.35, 1.0);
    if (crownA > 0) {
      canvas.drawCircle(
        const Offset(500, 268), 240,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: 0.42 * crownA),
              const Color(0xFFFDE68A).withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: const Offset(500, 268), radius: 240)),
      );
      canvas.drawPath(
        Path()
          ..moveTo(392, 322)
          ..lineTo(404, 214)
          ..lineTo(446, 288)
          ..lineTo(500, 190)
          ..lineTo(554, 288)
          ..lineTo(596, 214)
          ..lineTo(608, 322)
          ..close(),
        Paint()..color = const Color(0xFFFBBF24).withValues(alpha: crownA),
      );
      canvas.drawRect(
        Rect.fromLTWH(392, 322, 216, 26),
        Paint()..color = const Color(0xFFD97706).withValues(alpha: crownA),
      );
    }

    // The cedar floor — darker than the sky (§ 4.4), with plank lines.
    _ground(canvas, const Color(0xFF4A2E14), kFloor);
    final plank = Paint()
      ..color = const Color(0xFF3A2410)
      ..strokeWidth = 6;
    for (var y = 690.0; y < 1000; y += 74) {
      canvas.drawLine(Offset(0, y), Offset(1000, y), plank);
    }

    // David, sat down on the floor because he could not think what to say.
    // _kneeling gives the seated posture and the hands-together wonder.
    // Height 292 ≥ 220 ✓.
    _kneeling(canvas, 500, 780, 292, const Color(0xFF8D5524), const Color(0xFF9333EA));

    // ANIM 3 — the tent of the Ark, still standing behind him (t 0→0.7), which is
    // the thing that started the whole conversation, so it belongs in the picture
    // from the first frame rather than fading in later.
    final tentA = _cl(0.45, 1.0, t, 0.0, 0.7);
    if (tentA > 0) {
      canvas.drawPath(
        Path()
          ..moveTo(838, 640)
          ..lineTo(946, 780)
          ..lineTo(730, 780)
          ..close(),
        Paint()..color = const Color(0xFFA8A29E).withValues(alpha: 0.9 * tentA),
      );
      canvas.drawRect(
        Rect.fromLTWH(812, 724, 52, 56),
        Paint()..color = const Color(0xFFD4A017).withValues(alpha: tentA),
      );
    }
  }
}

// ── 46. Solomon Asks for Wisdom ───────────────────────────────────────────────
// Intent: a very young king on a throne much too big for him asks for a
//         listening heart, and leaves the gold he could have had untouched.

class _SolomonScenePainter extends ScenePainter {
  const _SolomonScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Floor line at y=612 — outside the forbidden 450–550 band (§ 4.4).
    const kFloor = 612.0;

    _sky(canvas, const Color(0xFF0E7490), const Color(0xFF7DD3D8));

    // Hall pillars behind the throne — vertical bands, never tapering wedges.
    final pillar = Paint()..color = const Color(0xFF115E67);
    for (final px in const [118.0, 262.0, 738.0, 882.0]) {
      canvas.drawRect(Rect.fromLTWH(px - 34, 214, 68, kFloor - 214), pillar);
      canvas.drawRect(Rect.fromLTWH(px - 46, 200, 92, 22), pillar);
    }

    // Floor — darker than the sky (§ 4.4)
    _ground(canvas, const Color(0xFF0B4A52), kFloor);

    // ANIM 1 — dawn light comes down the hall onto the throne (t 0→0.6).
    // RadialGradient, never a flat-alpha disc (§ 4.4).
    // Alpha stays low: this glow and the wisdom halo below both land on the
    // centre of the frame, and at 0.55 they combined to bleach Solomon's face
    // into a featureless orange blur.
    final dawn = _cl(0.10, 1.0, t, 0.0, 0.6);
    canvas.drawCircle(
      const Offset(500, 430), 400,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFEF3C7).withValues(alpha: 0.30 * dawn),
            const Color(0xFFFEF3C7).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: const Offset(500, 430), radius: 400)),
    );

    // The throne — deliberately far too big for the boy sitting in it, and dark,
    // so his warm skin and teal robe read against it. A mid-orange throne put a
    // warm figure on a warm ground and he disappeared into the chair.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(372, 336, 256, 446), const Radius.circular(28)),
      Paint()..color = const Color(0xFF3F1D08),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(396, 364, 208, 300), const Radius.circular(20)),
      Paint()..color = const Color(0xFF5A2C0C),
    );
    // Throne arms, so the shape reads as a chair rather than a doorway.
    for (final ax in const [348.0, 604.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(ax, 596, 48, 168), const Radius.circular(16)),
        Paint()..color = const Color(0xFF4A2410),
      );
    }

    // ANIM 2 — wisdom settles on him (t 0.45→1). Drawn BEFORE the figure, so it
    // glows out from behind his head. Painted on top it veiled his face and rubbed
    // the features out, which is the one thing this picture cannot afford.
    final wisdom = _cl(0.0, 1.0, t, 0.45, 1.0);
    if (wisdom > 0) {
      canvas.drawCircle(
        const Offset(500, 528), 190,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: 0.72 * wisdom),
              const Color(0xFFFDE68A).withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: const Offset(500, 528), radius: 190)),
      );
    }

    // Solomon — small in a big chair. _kneeling reads as seated, and its
    // hands-together posture is the asking in this picture. 268 ≥ 220 ✓.
    _kneeling(canvas, 500, 764, 268, const Color(0xFF8D5524), const Color(0xFF0D9488));

    // ANIM 3 — the things he did NOT ask for, set aside on the floor and
    // slowly dimming (t 0.4→1): a chest of gold and a spare crown.
    final unasked = _cl(1.0, 0.42, t, 0.4, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(120, 690, 176, 92), const Radius.circular(12)),
      Paint()..color = const Color(0xFF6B3A10).withValues(alpha: unasked),
    );
    canvas.drawRect(
      Rect.fromLTWH(120, 690, 176, 22),
      Paint()..color = const Color(0xFFD4A017).withValues(alpha: unasked),
    );
    for (final c in const [[156.0, 730.0], [200.0, 748.0], [246.0, 728.0]]) {
      canvas.drawCircle(Offset(c[0], c[1]), 15,
          Paint()..color = const Color(0xFFFBBF24).withValues(alpha: unasked));
    }
    canvas.drawPath(
      Path()
        ..moveTo(716, 780)
        ..lineTo(724, 736)
        ..lineTo(744, 766)
        ..lineTo(762, 730)
        ..lineTo(780, 766)
        ..lineTo(800, 736)
        ..lineTo(808, 780)
        ..close(),
      Paint()..color = const Color(0xFFB08D3A).withValues(alpha: unasked),
    );
  }
}

// ── 47. Elijah and the Only True God ──────────────────────────────────────────
// Intent: the altar is soaking wet and fire falls on it anyway, so nobody can
//         say it was a trick — the Lord is the one who answers.

class _ElijahScenePainter extends ScenePainter {
  const _ElijahScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Mountain top at y=624 — outside the forbidden 450–550 band (§ 4.4).
    const kTop = 624.0;

    // ANIM 1 — the dark sky opens over the altar as the fire comes (t 0.4→0.8).
    final open = _cl(0.0, 1.0, t, 0.4, 0.8);
    _sky(
      canvas,
      Color.lerp(const Color(0xFF292524), const Color(0xFF7C2D12), open)!,
      Color.lerp(const Color(0xFF57534E), const Color(0xFFC2410C), open)!,
    );

    // Bare rock, darker than the sky (§ 4.4)
    _ground(canvas, const Color(0xFF3F3A35), kTop);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 960), width: 1700, height: 700),
      Paint()..color = const Color(0xFF2E2A26),
    );

    // The trench, full of water — poured on before any fire fell.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 764), width: 470, height: 58),
      Paint()..color = const Color(0xFF1E3A5F),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 758), width: 400, height: 34),
      Paint()..color = const Color(0xFF2563EB),
    );

    // The altar — twelve stones, one per tribe, stacked in courses.
    final stone = Paint()..color = const Color(0xFF6B6259);
    final mortar = Paint()..color = const Color(0xFF574F47);
    for (var row = 0; row < 3; row++) {
      final ry = 726.0 - row * 46;
      final cols = 4 - (row == 2 ? 1 : 0);
      final w = cols * 74.0;
      for (var c = 0; c < cols; c++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(500 - w / 2 + c * 74 + 3, ry, 68, 40),
            const Radius.circular(6)),
          row.isEven ? stone : mortar,
        );
      }
    }
    // Wood on top, soaked through
    canvas.drawRect(
      const Rect.fromLTWH(414, 606, 172, 20),
      Paint()..color = const Color(0xFF44280F),
    );

    // ANIM 2 — fire falls from heaven onto the wet altar (t 0.48→1).
    final fire = _cl(0.0, 1.0, t, 0.48, 1.0);
    if (fire > 0) {
      // The column, coming down out of the opened sky. It must fade out towards
      // the top and stay narrow: a solid-alpha straight-edged wedge from y=200
      // down to the altar reads as a tent pitched on the mountain, not as fire.
      canvas.drawPath(
        Path()
          ..moveTo(486, 214)
          ..lineTo(514, 214)
          ..lineTo(500 + 54 * fire, 606)
          ..lineTo(500 - 54 * fire, 606)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: 0.0),
              const Color(0xFFFBBF24).withValues(alpha: 0.72 * fire),
            ],
          ).createShader(const Rect.fromLTWH(430, 214, 140, 392)),
      );
      // Flames sitting on the altar itself
      for (final f in const [[440.0, 1.0], [500.0, 1.32], [560.0, 0.94]]) {
        final fx = f[0];
        final k = f[1] * fire;
        canvas.drawPath(
          Path()
            ..moveTo(fx - 30 * k, 606)
            ..quadraticBezierTo(fx - 20 * k, 606 - 78 * k, fx, 606 - 128 * k)
            ..quadraticBezierTo(fx + 20 * k, 606 - 78 * k, fx + 30 * k, 606)
            ..close(),
          Paint()..color = const Color(0xFFFBBF24).withValues(alpha: 0.95),
        );
        canvas.drawPath(
          Path()
            ..moveTo(fx - 15 * k, 606)
            ..quadraticBezierTo(fx - 9 * k, 606 - 44 * k, fx, 606 - 74 * k)
            ..quadraticBezierTo(fx + 9 * k, 606 - 44 * k, fx + 15 * k, 606)
            ..close(),
          Paint()..color = const Color(0xFFFEF3C7).withValues(alpha: 0.95),
        );
      }
    }

    // Elijah, arms lifted in the short quiet prayer that got answered.
    // § 4.2 limb rule: 232°/308° = 76° apart ✓ (both arms up and outward).
    // Feet at y=778 ≤ 782 (§ 4.4).
    _person(canvas, 214, 778, 288, const Color(0xFF8D5524), const Color(0xFF1D4ED8),
        armAngleL: 232, armAngleR: 308);

    // ANIM 3 — the watching people go down on their faces (t 0.66→1).
    final bow = _cl(0.0, 1.0, t, 0.66, 1.0);
    final bp = Paint()..color = const Color(0xFF57534E);
    final bh = Paint()..color = const Color(0xFF8D5524);
    for (final b in const [[788.0, 762.0], [858.0, 776.0], [924.0, 758.0]]) {
      // Upright at bow=0, folded low at bow=1. A bare flattened oval reads as a
      // boulder, so the head stays a separate circle that slides down and
      // forward as they go down — that keeps them reading as people.
      final w = _lerp(46, 92, bow);
      final h = _lerp(112, 46, bow);
      final cy = b[1] + (112 - h) / 2;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(b[0], cy), width: w, height: h), bp);
      canvas.drawCircle(
        Offset(b[0] - _lerp(0, 44, bow), cy - _lerp(46, 6, bow)),
        _lerp(21, 18, bow), bh);
    }
  }
}

// ── 48. The Prophets Promise New Hearts ───────────────────────────────────────
// Intent: God's own hands take away the heart of stone and put a living, growing
//         one in its place — the swap nobody could do for themselves.

class _NewHeartsScenePainter extends ScenePainter {
  const _NewHeartsScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Horizon at y=592 — outside the forbidden 450–550 band (§ 4.4).
    const kHorizon = 592.0;

    // ANIM 1 — dawn breaks behind the long wait (t 0→0.5).
    final dawn = _cl(0.0, 1.0, t, 0.0, 0.5);
    _sky(
      canvas,
      Color.lerp(const Color(0xFF334155), const Color(0xFF0F766E), dawn)!,
      Color.lerp(const Color(0xFF64748B), const Color(0xFFFDE68A), dawn)!,
    );

    // The ruined city on the skyline, going green at the edges — the people who
    // had lost everything are exactly who the promise was made to.
    final ruin = Paint()..color = const Color(0xFF44403C);
    for (final r in const [[92.0, 118.0, 470.0], [214.0, 86.0, 508.0], [318.0, 64.0, 528.0]]) {
      canvas.drawRect(Rect.fromLTWH(r[0], r[2], r[1], kHorizon - r[2]), ruin);
    }

    // Ground — darker than the sky (§ 4.4)
    _ground(canvas, const Color(0xFF14532D), kHorizon);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 940), width: 1700, height: 740),
      Paint()..color = const Color(0xFF166534),
    );

    // Two open hands, cupped, holding the heart up — God does the swapping.
    //
    // Drawing order matters: palms, then the heart, then the FINGERTIPS on top.
    // A single dome-shaped path with vertical lines scored into it (the obvious
    // first attempt) reads as a loaf of bread, and leaves the heart floating
    // above it rather than held. Sleeve cuffs at the wrists are what actually
    // tell you these are arms.
    _palms(canvas);

    // ANIM 2 — the heart of stone turns into a living one (t 0.25→0.85).
    final alive = _cl(0.0, 1.0, t, 0.25, 0.85);
    canvas.drawPath(
      _heart(500, 512, 128),
      Paint()..color = Color.lerp(const Color(0xFF78716C), const Color(0xFFDC2626), alive)!,
    );
    // The cracked-stone lines fade out as it comes alive.
    if (alive < 1) {
      final crack = Paint()
        ..color = const Color(0xFF4B4540).withValues(alpha: 1 - alive)
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(454, 456), const Offset(494, 538), crack);
      canvas.drawLine(const Offset(494, 538), const Offset(556, 498), crack);
    }

    // ANIM 3 — a green shoot grows up through it (t 0.5→1).
    final grow = _cl(0.0, 1.0, t, 0.5, 1.0);
    if (grow > 0) {
      final stemTop = _lerp(496, 330, grow);
      canvas.drawLine(
        const Offset(500, 540), Offset(500, stemTop),
        Paint()
          ..color = const Color(0xFF15803D)
          ..strokeWidth = 15
          ..strokeCap = StrokeCap.round,
      );
      final leaf = Paint()..color = const Color(0xFF22C55E);
      final ls = grow.clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(444, stemTop + 58), width: 108 * ls, height: 50 * ls),
        leaf,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(560, stemTop + 22), width: 96 * ls, height: 46 * ls),
        leaf,
      );
    }

    // The fingertips, drawn last so they close over the heart's lower edge.
    _fingers(canvas);
  }

  /// Sleeve cuffs and palms of both cradling hands.
  void _palms(Canvas canvas) {
    final skin = Paint()..color = const Color(0xFFC68642);
    final cuff = Paint()..color = const Color(0xFF1E3A5F);
    for (final s in const [-1.0, 1.0]) {
      final px = 500 + s * 158;
      // Sleeve at the wrist — the cue that says "arm", not "loaf".
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(px + s * 26, 762), width: 128, height: 76),
          const Radius.circular(20)),
        cuff,
      );
      // Palm
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, 686), width: 168, height: 190), skin);
      // Thumb, on the inner side, angled up towards the heart
      canvas.save();
      canvas.translate(px + s * -58, 640);
      canvas.rotate(s * 0.42);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 44, height: 118),
          const Radius.circular(22)),
        skin,
      );
      canvas.restore();
    }
  }

  /// Four fingers per hand, fanning up and inward to close over the heart.
  void _fingers(Canvas canvas) {
    final skin = Paint()..color = const Color(0xFFC68642);
    final crease = Paint()
      ..color = const Color(0xFFA8672F)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    for (final s in const [-1.0, 1.0]) {
      final px = 500 + s * 158;
      for (var i = 0; i < 4; i++) {
        final fx = px + s * (52 - i * 34);
        final len = 126.0 + i * 14;
        canvas.save();
        canvas.translate(fx, 612);
        canvas.rotate(s * (0.30 - i * 0.07));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(0, -len / 2 + 30), width: 40, height: len),
            const Radius.circular(20)),
          skin,
        );
        // One knuckle crease per finger, so they separate visually
        canvas.drawLine(
          Offset(-14, -len + 68), Offset(14, -len + 68), crease);
        canvas.restore();
      }
    }
  }

  /// Heart path centred at (cx, cy) with half-width [r].
  Path _heart(double cx, double cy, double r) {
    return Path()
      ..moveTo(cx, cy + r * 0.82)
      ..cubicTo(cx - r * 1.55, cy - r * 0.12, cx - r * 0.68, cy - r * 1.12, cx, cy - r * 0.34)
      ..cubicTo(cx + r * 0.68, cy - r * 1.12, cx + r * 1.55, cy - r * 0.12, cx, cy + r * 0.82)
      ..close();
  }
}

// ── 49. An Angel Visits Mary ──────────────────────────────────────────────────
// Intent: an ordinary girl in a plain little room is told the most important
//         thing anybody has ever been told, and she is not afraid.

class _AngelMaryScenePainter extends ScenePainter {
  const _AngelMaryScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Floor line at y=636 — outside the forbidden 450–550 band (§ 4.4).
    const kFloor = 636.0;

    _sky(canvas, const Color(0xFF4C1D95), const Color(0xFF7E5BBF));

    // Back wall of the room, and a low window with dawn behind it.
    _ground(canvas, const Color(0xFF3B1E70), kFloor);
    canvas.drawRect(
      const Rect.fromLTWH(96, 300, 172, 200),
      Paint()..color = const Color(0xFF2A1550),
    );
    canvas.drawRect(
      const Rect.fromLTWH(110, 314, 144, 172),
      Paint()..color = const Color(0xFFFDE68A),
    );
    // Window bars — so it reads as a window, not a glowing panel.
    final bar = Paint()
      ..color = const Color(0xFF2A1550)
      ..strokeWidth = 10;
    canvas.drawLine(const Offset(182, 314), const Offset(182, 486), bar);
    canvas.drawLine(const Offset(110, 400), const Offset(254, 400), bar);

    // ANIM 1 — light floods the doorway where the angel stands (t 0→0.55).
    final glow = _cl(0.22, 1.0, t, 0.0, 0.55);
    canvas.drawCircle(
      const Offset(768, 500), 330,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFEF3C7).withValues(alpha: 0.80 * glow),
            const Color(0xFFFEF3C7).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: const Offset(768, 500), radius: 330)),
    );

    // ANIM 2 — wings open behind the angel (t 0.2→0.8). Drawn BEFORE the figure
    // so they read as being behind it.
    final wing = _cl(0.0, 1.0, t, 0.2, 0.8);
    if (wing > 0) {
      final wp = Paint()..color = const Color(0xFFFFFBEB).withValues(alpha: 0.55 * wing);
      for (final s in const [-1.0, 1.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(768 + s * 44, 560)
            ..quadraticBezierTo(
                768 + s * (120 + 130 * wing), 400,
                768 + s * (72 + 96 * wing), 664)
            ..close(),
          wp,
        );
      }
    }

    // The angel — a tall figure of light in the doorway. Pale against the dark
    // wall, so the silhouette reads without needing a detailed face.
    // § 4.2 limb rule: 158°/64° = 94° apart ✓ (one hand raised in greeting)
    _person(canvas, 768, 780, 340, const Color(0xFFFFF7E0), const Color(0xFFFDE68A),
        armAngleL: 158, armAngleR: 64, hasHalo: true);

    // Mary — turning towards the light, hands open. Smaller on purpose: the news
    // is the big thing in this picture, not her.
    // § 4.2 limb rule: 232°/300° = 68° apart ✓ (both hands open and lifted)
    _person(canvas, 336, 780, 292, const Color(0xFF8D5524), const Color(0xFF9333EA),
        armAngleL: 232, armAngleR: 300);
  }
}

// ── 50. Visitors Worship the King ─────────────────────────────────────────────
// Intent: rich important men who came from far away are down on the floor in an
//         ordinary house, because the child in it is the King of everybody.

class _MagiScenePainter extends ScenePainter {
  const _MagiScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Ground line at y=660 — outside the forbidden 450–550 band (§ 4.4).
    const kGround = 660.0;

    _sky(canvas, const Color(0xFF11224A), const Color(0xFF35508A));

    // ANIM 1 — the star brightens over the house (t 0→0.5). Starts at 0.35 so
    // t=0 is already a composed night picture (§ 4.5).
    // Alpha kept low: at 0.62 the halo swallowed the star shape inside it and the
    // whole thing read as one white blob. The star must stay the brighter thing.
    final starA = _cl(0.35, 1.0, t, 0.0, 0.5);
    canvas.drawCircle(
      const Offset(322, 236), 210,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE68A).withValues(alpha: 0.34 * starA),
            const Color(0xFFFDE68A).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: const Offset(322, 236), radius: 210)),
    );
    // Four-point star with long thin arms, so it does not read as a plain moon.
    canvas.drawPath(
      Path()
        ..moveTo(322, 128)..lineTo(338, 220)..lineTo(430, 236)..lineTo(338, 252)
        ..lineTo(322, 344)..lineTo(306, 252)..lineTo(214, 236)..lineTo(306, 220)
        ..close(),
      Paint()..color = const Color(0xFFFFFBEB).withValues(alpha: starA),
    );

    // Ground — darker than the sky (§ 4.4)
    _ground(canvas, const Color(0xFF3A2A18), kGround);

    // The ordinary house — flat-roofed and plain. No palace.
    canvas.drawRect(
      const Rect.fromLTWH(196, 400, 300, 260),
      Paint()..color = const Color(0xFF6B5433),
    );
    canvas.drawRect(
      const Rect.fromLTWH(178, 380, 336, 26),
      Paint()..color = const Color(0xFF54401F),
    );
    // Doorway, lit from inside
    canvas.drawRect(
      const Rect.fromLTWH(286, 452, 120, 208),
      Paint()..color = const Color(0xFFFDE68A),
    );

    // Mary in the doorway holding the child.
    // § 4.2 limb rule: 118°/56° = 62° apart ✓ (both arms cradling)
    _person(canvas, 346, 660, 252, const Color(0xFF8D5524), const Color(0xFF1E40AF),
        armAngleL: 118, armAngleR: 56);
    // The child, held — a warm bundle clearly in front of her robe.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(346, 556), width: 88, height: 60),
      Paint()..color = const Color(0xFFFFF7E0),
    );
    canvas.drawCircle(const Offset(376, 548), 21, Paint()..color = const Color(0xFF8D5524));

    // ANIM 2 — the three visitors go down on their knees (t 0.35→1).
    //
    // They KNEEL UPRIGHT with bowed heads; they do not go flat. Flattening the
    // body to a wide oval and sliding the head off to one side turned all three
    // into beetles lying on their backs. A tall-ish body with the head still on
    // top of it, tipped forward, is the only version that reads as a person
    // bowing at this size.
    final kneel = _cl(0.0, 1.0, t, 0.35, 1.0);
    const robes = [Color(0xFF7F1D1D), Color(0xFF065F46), Color(0xFF5B21B6)];
    for (var i = 0; i < 3; i++) {
      final bx = 620.0 + i * 128;
      // 212→132, not 212→150. At 150 the sink was too shallow to register at the
      // rendered size and all three still read as standing figures, which loses
      // the one beat the story is built on — they KNELT.
      final bodyH = _lerp(212, 132, kneel);   // sinks down, stays a body
      final bodyW = _lerp(94, 116, kneel);    // widens a little as the robe settles
      final byTop = 782 - bodyH;
      // Robe — an A-line skirt, wider at the ground, so it reads as a kneeling robe
      canvas.drawPath(
        Path()
          ..moveTo(bx - bodyW * 0.34, byTop)
          ..lineTo(bx - bodyW * 0.62, 782)
          ..lineTo(bx + bodyW * 0.62, 782)
          ..lineTo(bx + bodyW * 0.34, byTop)
          ..close(),
        Paint()..color = robes[i],
      );
      // Neck, so the head never floats (§ 4.2)
      canvas.drawRect(
        Rect.fromLTRB(bx - 11, byTop - 20, bx + 11, byTop + 4),
        Paint()..color = const Color(0xFFC68642),
      );
      // Head — on top of the body, tipped forward towards the house as they bow
      // Forward tip kept to 14, not 26: any further and the head slides off the
      // end of the neck drawn above it and starts to float (§ 4.2).
      canvas.drawCircle(
        // Head tips further forward (26, was 14) — a bowed head is the other half
        // of what makes kneeling legible once the body has sunk.
        Offset(bx - _lerp(0, 26, kneel), byTop - 44 + _lerp(0, 26, kneel)),
        30, Paint()..color = const Color(0xFFC68642));
    }

    // ANIM 3 — the treasure boxes come open on the ground (t 0.6→1).
    final open = _cl(0.0, 1.0, t, 0.6, 1.0);
    if (open > 0) {
      for (var i = 0; i < 3; i++) {
        final gx = 600.0 + i * 128;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(gx, 762, 76, 34), const Radius.circular(8)),
          Paint()..color = const Color(0xFF4A3418),
        );
        // Lid, hinging open. Capped at 0.55 rad: swung further it stands up as a
        // long diagonal bar across the kneeling figure behind it and reads as a
        // walking stick rather than a lid.
        canvas.save();
        canvas.translate(gx, 762);
        canvas.rotate(-open * 0.55);
        canvas.drawRect(
          const Rect.fromLTWH(0, -12, 76, 12),
          Paint()..color = const Color(0xFF6B4E24),
        );
        canvas.restore();
        canvas.drawCircle(
          Offset(gx + 38, 764), 13 * open,
          Paint()..color = const Color(0xFFFBBF24).withValues(alpha: open));
      }
    }
  }
}

// ── 51. Jesus Grows and Obeys ─────────────────────────────────────────────────
// Intent: a boy sits among the cleverest men in the country and holds His own —
//         and then goes home to an ordinary life and obeys.

class _JesusGrowsScenePainter extends ScenePainter {
  const _JesusGrowsScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Courtyard floor at y=624 — outside the forbidden 450–550 band (§ 4.4).
    const kFloor = 624.0;

    _sky(canvas, const Color(0xFF0F766E), const Color(0xFF99E2DC));

    // Temple courtyard wall behind, with two pillars — vertical bands, never
    // tapering wedges (§ 4.4).
    canvas.drawRect(
      const Rect.fromLTWH(0, 214, 1000, kFloor - 214),
      Paint()..color = const Color(0xFFC9A46A),
    );
    final pillar = Paint()..color = const Color(0xFFB08A50);
    for (final px in const [128.0, 872.0]) {
      canvas.drawRect(Rect.fromLTWH(px - 40, 214, 80, kFloor - 214), pillar);
      canvas.drawRect(Rect.fromLTWH(px - 52, 200, 104, 24), pillar);
    }
    // Floor — darker than the wall above it
    _ground(canvas, const Color(0xFF8A6A3C), kFloor);

    // ANIM 1 — warm light moves across the courtyard stone (t 0→0.6).
    final light = _cl(0.2, 1.0, t, 0.0, 0.6);
    canvas.drawCircle(
      const Offset(500, 470), 380,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFEF3C7).withValues(alpha: 0.34 * light),
            const Color(0xFFFEF3C7).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: const Offset(500, 470), radius: 380)),
    );

    // The seated teachers — bearded, on the floor, on both sides of the boy.
    // Drawn as seated bodies with separate heads and beards so they read as men.
    const seats = [
      [214.0, Color(0xFF6D28D9)], [332.0, Color(0xFF7F1D1D)],
      [668.0, Color(0xFF1E40AF)], [786.0, Color(0xFF065F46)],
    ];
    for (final s in seats) {
      final sx = s[0] as double;
      final robe = s[1] as Color;
      canvas.drawPath(
        Path()
          ..moveTo(sx - 46, 660)
          ..lineTo(sx - 66, 782)
          ..lineTo(sx + 66, 782)
          ..lineTo(sx + 46, 660)
          ..close(),
        Paint()..color = robe,
      );
      canvas.drawRect(
        Rect.fromLTRB(sx - 13, 634, sx + 13, 662),
        Paint()..color = const Color(0xFFC68642),
      );
      canvas.drawCircle(Offset(sx, 612), 34, Paint()..color = const Color(0xFFC68642));
      // Beard — a narrow wedge hanging BELOW the chin. An oval centred on the
      // chin reads as a bib or a napkin, not as a beard, and made four grown men
      // look like toddlers at a table.
      canvas.drawPath(
        Path()
          ..moveTo(sx - 22, 630)
          ..quadraticBezierTo(sx - 16, 686, sx, 694)
          ..quadraticBezierTo(sx + 16, 686, sx + 22, 630)
          ..close(),
        Paint()..color = const Color(0xFFD6D3D1),
      );
    }

    // ANIM 2 — the teachers' scrolls come open on their laps (t 0.3→0.85).
    final scroll = _cl(0.0, 1.0, t, 0.3, 0.85);
    if (scroll > 0) {
      for (final s in seats) {
        final sx = s[0] as double;
        final w = 100 * scroll;
        // Sheet…
        canvas.drawRect(
          Rect.fromCenter(center: Offset(sx, 730), width: w, height: 32),
          Paint()..color = const Color(0xFFFEF3C7).withValues(alpha: scroll),
        );
        // …plus a rolled rod at each end, which is what makes it a scroll rather
        // than a white badge pinned to the chest.
        for (final e in [-1.0, 1.0]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(sx + e * w / 2, 730), width: 16, height: 42),
            Paint()..color = const Color(0xFF92400E).withValues(alpha: scroll),
          );
        }
      }
    }

    // Jesus, twelve years old, sitting on the step between them and leaning in.
    // _kneeling gives the seated posture. Height 262 ≥ 220 ✓.
    _kneeling(canvas, 500, 782, 262, const Color(0xFF8D5524), const Color(0xFF0D9488));

    // ANIM 3 — understanding grows around Him as He answers (t 0.5→1).
    final wonder = _cl(0.0, 1.0, t, 0.5, 1.0);
    if (wonder > 0) {
      canvas.drawCircle(
        const Offset(500, 568), 150,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: 0.46 * wonder),
              const Color(0xFFFDE68A).withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: const Offset(500, 568), radius: 150)),
      );
    }
  }
}

// ── 52. Jesus Is Baptised ─────────────────────────────────────────────────────
// Intent: the Son stands in the river, the Spirit comes down as a dove, and the
//         Father speaks from the opened sky — all three, all at once.

class _BaptismScenePainter extends ScenePainter {
  const _BaptismScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Waterline at y=606 — outside the forbidden 450–550 band (§ 4.4).
    const kWater = 606.0;

    _sky(canvas, const Color(0xFF0369A1), const Color(0xFFBAE6FD));

    // ANIM 1 — the sky opens, and light comes down the middle (t 0.15→0.7).
    final opened = _cl(0.0, 1.0, t, 0.15, 0.7);
    if (opened > 0) {
      // Parted cloud on both sides of the opening. Kept low and rounded — two big
      // ovals crossing the top edge read as a cave mouth or an awning rather than
      // as cloud, so they sit lower and narrower than the first attempt.
      final cloud = Paint()..color = const Color(0xFF8FB6D0);
      for (final s in const [-1.0, 1.0]) {
        final cx = 500 + s * (230 + 120 * opened);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 258), width: 380, height: 108), cloud);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - s * 96, 286), width: 250, height: 84),
          cloud);
      }
      // The shaft of light, fading out at the top so it does not read as a tent
      canvas.drawPath(
        Path()
          ..moveTo(452, 214)
          ..lineTo(548, 214)
          ..lineTo(500 + 112 * opened, kWater)
          ..lineTo(500 - 112 * opened, kWater)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.0),
              const Color(0xFFFDE68A).withValues(alpha: 0.56 * opened),
            ],
          ).createShader(const Rect.fromLTWH(380, 214, 240, 392)),
      );
    }

    // The river — darker than the sky (§ 4.4), with a paler near band.
    _ground(canvas, const Color(0xFF1D4E7C), kWater);
    canvas.drawRect(
      const Rect.fromLTWH(0, 700, 1000, 100),
      Paint()..color = const Color(0xFF2563EB),
    );
    // Reeds on the near bank, so the figures are not standing on flat colour
    final reed = Paint()
      ..color = const Color(0xFF14532D)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    for (final rx in const [58.0, 92.0, 128.0, 906.0, 942.0, 972.0]) {
      canvas.drawLine(Offset(rx, 800), Offset(rx + 12, 664), reed);
    }

    // John, standing in the water beside Jesus, one hand still raised.
    // § 4.2 limb rule: 214°/78° = 136° apart ✓
    _person(canvas, 706, 778, 288, const Color(0xFFC68642), const Color(0xFF78350F),
        armAngleL: 214, armAngleR: 78);

    // Jesus, coming up out of the water, arms lowered and open.
    // § 4.2 limb rule: 142°/38° = 104° apart ✓
    _person(canvas, 420, 782, 306, const Color(0xFF8D5524), const Color(0xFFE7E5E4),
        armAngleL: 142, armAngleR: 38, hasHalo: true);

    // Water ring where He is standing, so He reads as IN the river, not on it.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(420, 764), width: 260, height: 54),
      Paint()
        ..color = const Color(0xFF93C5FD)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke,
    );

    // ANIM 2 — the dove descends onto Jesus (t 0.4→1).
    final dove = _cl(0.0, 1.0, t, 0.4, 1.0);
    if (dove > 0) {
      // Stops at y=402, not 452. Jesus's head centre is y≈519 with radius 43, so
      // its top edge is y≈476 — a dove body ending at 474 sat on his head like a
      // hat. It must still be descending, with clear air beneath it.
      final dy = _lerp(258, 402, dove);
      final dp = Paint()..color = Colors.white;
      // Body
      canvas.drawOval(
        Rect.fromCenter(center: Offset(420, dy), width: 76, height: 44), dp);
      // Head
      canvas.drawCircle(Offset(452, dy - 20), 19, dp);
      // Wings — raised at the start of the descent, lowered as it lands, so the
      // two wings always differ clearly in angle (§ 4.2 seesaw rule).
      final lift = 1.0 - dove;
      for (final s in const [-1.0, 1.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(420, dy - 6)
            ..quadraticBezierTo(
                420 + s * 62, dy - 30 - 44 * lift,
                420 + s * 96, dy + 10 - 30 * lift)
            ..close(),
          dp,
        );
      }
      // Tail
      canvas.drawPath(
        Path()
          ..moveTo(392, dy + 4)
          ..lineTo(352, dy + 26)
          ..lineTo(392, dy + 22)
          ..close(),
        dp,
      );
    }
  }
}

// ── 53. Jesus Says No to the Tempter ──────────────────────────────────────────
// Intent: Jesus stands firm and refuses in an empty desert — the tempter is only
//         a shadow, because all he can do is ask.

class _TemptationScenePainter extends ScenePainter {
  const _TemptationScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Ridge line at y=618 — outside the forbidden 450–550 band (§ 4.4).
    const kRidge = 618.0;

    _sky(canvas, const Color(0xFFD9B77E), const Color(0xFFF6E3BE));

    // Distant heat haze — flat bands, never tapering wedges (§ 4.4)
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(180, 646), width: 900, height: 150),
      Paint()..color = const Color(0xFFC8A472),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(880, 654), width: 820, height: 160),
      Paint()..color = const Color(0xFFC8A472),
    );

    // The rocky ridge — darker than the sky (§ 4.4)
    _ground(canvas, const Color(0xFF9A7845), kRidge);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 950), width: 1700, height: 660),
      Paint()..color = const Color(0xFF7C5E33),
    );
    // Scattered stones — the ones He was asked to turn into bread
    final stone = Paint()..color = const Color(0xFF6B5232);
    for (final s in const [[196.0, 742.0, 1.0], [268.0, 776.0, 0.8], [140.0, 790.0, 0.7]]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s[0], s[1]), width: 74 * s[2], height: 46 * s[2]),
        stone);
    }

    // ANIM 1 — the tempter's shadow stretches out and then RETREATS as Jesus
    // refuses (t 0→0.55 out, 0.6→1 back). He is never given a face or a body:
    // he can only ask, and this picture must not make him the subject.
    final reach = _cl(0.0, 1.0, t, 0.0, 0.55);
    final retreat = _cl(0.0, 1.0, t, 0.6, 1.0);
    final shadowLen = _lerp(300.0, 90.0, retreat) * _lerp(0.45, 1.0, reach);
    canvas.drawPath(
      Path()
        ..moveTo(596, 782)
        ..quadraticBezierTo(
            596 + shadowLen * 0.6, 742, 596 + shadowLen, 786)
        ..quadraticBezierTo(
            596 + shadowLen * 0.6, 800, 596, 796)
        ..close(),
      Paint()..color = const Color(0xFF57431F).withValues(alpha: 0.5),
    );

    // Jesus — standing firm, one hand raised flat in refusal.
    // § 4.2 limb rule: |95 − (−40)| = 135° apart ✓ (left arm down, right hand up).
    // The assert does RAW subtraction, not modular arithmetic, so "up" must be
    // written as −40, not 320: |95 − 320| = 225 trips it.
    // Feet at y=780 ≤ 782, so nothing is cropped on the header (§ 4.4).
    _person(canvas, 452, 780, 320, const Color(0xFF8D5524), const Color(0xFF7C2D12),
        armAngleL: 95, armAngleR: -40);

    // ANIM 2 — the raised hand brightens as He answers with God's words
    // (t 0.35→1). The light is on the refusal, not on the tempter.
    final refuse = _cl(0.0, 1.0, t, 0.35, 1.0);
    if (refuse > 0) {
      // Centred on where the raised hand actually lands: right shoulder is at
      // x≈482, y≈612, and the arm is 320×0.27=86 long at −40°, so the hand is
      // at roughly (548, 557). Putting the glow at y=470 left it hanging in the
      // air well above the hand it was meant to be lighting.
      canvas.drawCircle(
        const Offset(550, 554), 108,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFFBEB).withValues(alpha: 0.70 * refuse),
              const Color(0xFFFFFBEB).withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: const Offset(550, 554), radius: 108)),
      );
    }

    // ANIM 3 — angels come and look after Him at the very end (t 0.78→1).
    // Bare radial glows read as lens flare or a second sun, so each one gets a
    // body, a head and a pair of wings. It only takes a silhouette to stop a
    // patch of light being mistaken for weather.
    final angels = _cl(0.0, 1.0, t, 0.78, 1.0);
    if (angels > 0) {
      for (final a in const [[788.0, 596.0, 1.0], [896.0, 640.0, 0.82]]) {
        final ax = a[0];
        final ay = a[1];
        final k = a[2];
        canvas.drawCircle(
          Offset(ax, ay), 96 * k,
          Paint()
            ..shader = RadialGradient(
              colors: [
                const Color(0xFFFFFBEB).withValues(alpha: 0.42 * angels),
                const Color(0xFFFFFBEB).withValues(alpha: 0.0),
              ],
            ).createShader(Rect.fromCircle(center: Offset(ax, ay), radius: 96 * k)),
        );
        final body = Paint()..color = Colors.white.withValues(alpha: 0.92 * angels);
        // Wings first, so they sit behind the body
        for (final s in const [-1.0, 1.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(ax, ay + 6 * k)
              ..quadraticBezierTo(
                  ax + s * 74 * k, ay - 62 * k, ax + s * 46 * k, ay + 40 * k)
              ..close(),
            Paint()..color = Colors.white.withValues(alpha: 0.62 * angels),
          );
        }
        // Robe
        canvas.drawPath(
          Path()
            ..moveTo(ax - 20 * k, ay - 6 * k)
            ..lineTo(ax - 34 * k, ay + 86 * k)
            ..lineTo(ax + 34 * k, ay + 86 * k)
            ..lineTo(ax + 20 * k, ay - 6 * k)
            ..close(),
          body,
        );
        canvas.drawCircle(Offset(ax, ay - 28 * k), 22 * k, body);
      }
    }
  }
}

// ── 54. Jesus Calls His Helpers ───────────────────────────────────────────────
// Intent: Jesus walks up to working men at the water's edge and invites them —
//         and the nets they have just put down are still lying there.

class _CallHelpersScenePainter extends ScenePainter {
  const _CallHelpersScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    // Waterline at y=430... no — horizon at y=596, outside 450–550 (§ 4.4).
    const kShore = 596.0;

    _sky(canvas, const Color(0xFFF6C98B), const Color(0xFFFDEFD6));

    // ANIM 1 — dawn comes up over the lake (t 0→0.5).
    final dawn = _cl(0.3, 1.0, t, 0.0, 0.5);
    canvas.drawCircle(
      const Offset(820, 470), 250,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF3C4).withValues(alpha: 0.85 * dawn),
            const Color(0xFFFFF3C4).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: const Offset(820, 470), radius: 250)),
    );

    // The lake — darker than the sky (§ 4.4)
    _ground(canvas, const Color(0xFF1D6FA8), kShore);
    // Light on the water
    final shimmer = Paint()..color = const Color(0xFF7FC2E8);
    for (final r in const [[640.0, 0.9], [686.0, 0.6], [730.0, 0.35]]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(820, r[0]), width: 340 * r[1], height: 14),
        shimmer);
    }
    // The near shingle bank — so the figures stand ON something, not in the lake
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 900), width: 1600, height: 300),
      Paint()..color = const Color(0xFFC2A06A),
    );

    // The boat, pulled up on the shingle.
    canvas.drawPath(
      Path()
        ..moveTo(700, 700)
        ..quadraticBezierTo(820, 776, 952, 700)
        ..lineTo(936, 686)
        ..quadraticBezierTo(820, 748, 716, 686)
        ..close(),
      Paint()..color = const Color(0xFF6B4423),
    );
    canvas.drawLine(const Offset(826, 700), const Offset(826, 592),
        Paint()
          ..color = const Color(0xFF6B4423)
          ..strokeWidth = 11);

    // Jesus on the shore, one hand extended in invitation.
    // § 4.2 limb rule: 156°/58° = 98° apart ✓
    _person(canvas, 214, 780, 316, const Color(0xFF8D5524), const Color(0xFFB45309),
        armAngleL: 156, armAngleR: 58, hasHalo: true);

    // The two fishermen, turning to look at Him.
    // § 4.2 limb rule: 128°/44° = 84° apart ✓ and 118°/56° = 62° apart ✓
    _person(canvas, 468, 776, 268, const Color(0xFFC68642), const Color(0xFF0F766E),
        armAngleL: 128, armAngleR: 44);
    _person(canvas, 596, 782, 254, const Color(0xFF8D5524), const Color(0xFF1E40AF),
        armAngleL: 118, armAngleR: 56);

    // ANIM 2 — the net they were holding sags and comes down (t 0.3→1).
    // The mesh is 60 units tall and the 411×240 header crop only shows down to
    // y=792, so netTop must stay ≤ 720. At 764 the whole net fell off the bottom
    // and all that was left on screen was a row of white spikes like teeth.
    final drop = _cl(0.0, 1.0, t, 0.3, 1.0);
    final netTop = _lerp(650.0, 718.0, drop);
    final netP = Paint()
      ..color = const Color(0xFFF5F5F4).withValues(alpha: 0.95)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    // The net sits on the OPEN SHINGLE between Jesus (robe edge ≈ x 280) and the
    // first fisherman (robe edge ≈ x 408). There is no usable gap between the two
    // fishermen — their centres are only 128 apart and their robes are ~120 wide —
    // so a net drawn there lay across both of them and read as a patterned apron.
    // Out here it reads as what it is: the net they put down and walked away from.
    const netL = 300.0;
    const netR = 376.0;
    for (var i = 0; i <= 3; i++) {
      final x = _lerp(netL, netR, i / 3);
      canvas.drawLine(Offset(x, netTop), Offset(x - 14, netTop + 60), netP);
      canvas.drawLine(Offset(x - 14, netTop), Offset(x, netTop + 60), netP);
    }
    canvas.drawLine(Offset(netL - 8, netTop), Offset(netR + 8, netTop), netP);
    canvas.drawLine(Offset(netL - 20, netTop + 60), Offset(netR - 4, netTop + 60), netP);

    // ANIM 3 — footprints appear on the shingle where they went after Him
    // (t 0.62→1), so "they left their nets and followed" is visible.
    // Kept at y ≤ 776: at 806 every print was below the header crop's y=792 edge
    // and the whole animation was invisible in the shipped aspect ratio (§ 4.4).
    final steps = _cl(0.0, 1.0, t, 0.62, 1.0);
    if (steps > 0) {
      for (var i = 0; i < 4; i++) {
        final a = ((steps * 4) - i).clamp(0.0, 1.0);
        if (a <= 0) continue;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(392 - i * 46.0, 762 + (i.isEven ? 0 : 14)),
            width: 36, height: 21),
          Paint()..color = const Color(0xFF8A6533).withValues(alpha: 0.9 * a),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// World 7 — The Compassionate King (#49–51)
// ═══════════════════════════════════════════════════════════════════════════

// ── 49. Jesus Calms the Storm ─────────────────────────────────────────────────
// Intent: the wind and the waves go flat because a man in the boat told them to.
class _CalmsStormScenePainter extends ScenePainter {
  const _CalmsStormScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kSea = 620.0; // outside the forbidden 450–550 band (§ 4.4)
    final calm = _cl(0.0, 1.0, t, 0.25, 1.0);

    // ANIM 1 — the sky clears from storm-grey to morning.
    _sky(canvas,
        Color.lerp(const Color(0xFF1F2937), const Color(0xFF2563EB), calm)!,
        Color.lerp(const Color(0xFF4B5563), const Color(0xFF93C5FD), calm)!);

    // Storm cloud thins out rather than vanishing, so t=1 still reads as sky.
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(360, 210), width: 700, height: _lerp(230, 96, calm)),
      Paint()..color = const Color(0xFF374151).withValues(alpha: _lerp(0.85, 0.18, calm)),
    );

    // Sea — darker than the sky (§ 4.4)
    _ground(canvas, const Color(0xFF0C4A6E), kSea);

    // ANIM 2 — the waves flatten. Amplitude collapses towards a level sea.
    final amp = _lerp(86.0, 6.0, calm);
    for (var band = 0; band < 3; band++) {
      final baseY = kSea + 30.0 + band * 62;
      final path = Path()..moveTo(0, baseY);
      for (var x = 0.0; x <= 1000; x += 50) {
        path.lineTo(x, baseY - amp * math.sin((x / 1000) * math.pi * 3 + band));
      }
      path.lineTo(1000, 1000);
      path.lineTo(0, 1000);
      path.close();
      canvas.drawPath(
        path,
        Paint()..color = [
          const Color(0xFF075985),
          const Color(0xFF0369A1),
          const Color(0xFF0284C7),
        ][band],
      );
    }

    // The boat — rides lower and steadier as the sea calms.
    final tilt = _lerp(0.20, 0.0, calm);
    canvas.save();
    canvas.translate(500, 690);
    canvas.rotate(tilt);
    canvas.translate(-500, -690);
    canvas.drawPath(
      Path()
        ..moveTo(300, 660)
        ..lineTo(700, 660)
        ..quadraticBezierTo(620, 782, 500, 782)
        ..quadraticBezierTo(380, 782, 300, 660)
        ..close(),
      Paint()..color = const Color(0xFF78350F),
    );
    canvas.drawRect(const Rect.fromLTWH(492, 470, 16, 190),
        Paint()..color = const Color(0xFF57534E));
    // Jesus standing in the boat, one hand raised to the storm.
    // § 4.2 limb rule: 250°/95° = 155° — too wide, so 240°/110° = 130° ✓
    _person(canvas, 500, 662, 260, const Color(0xFF8D5524), const Color(0xFFF5F5F4),
        armAngleL: 240, armAngleR: 110, hasHalo: true);
    canvas.restore();

    // ANIM 3 — light breaks through onto the boat once it is calm.
    if (calm > 0) {
      canvas.drawCircle(
        const Offset(500, 430), 300,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFEF3C7).withValues(alpha: 0.42 * calm),
            const Color(0xFFFEF3C7).withValues(alpha: 0.0),
          ]).createShader(Rect.fromCircle(center: const Offset(500, 430), radius: 300)),
      );
    }
  }
}

// ── 50. Jesus Heals and Forgives ──────────────────────────────────────────────
// Intent: friends open a roof to get one man to Jesus, and he walks out carrying
//         the mat he was carried in on.
class _HealsForgivesScenePainter extends ScenePainter {
  const _HealsForgivesScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kFloor = 640.0;
    _sky(canvas, const Color(0xFF92400E), const Color(0xFFFDE68A));

    // Room walls — vertical bands, never tapering wedges (§ 4.4)
    canvas.drawRect(const Rect.fromLTWH(0, 200, 1000, 440),
        Paint()..color = const Color(0xFFD6C39B));
    // The hole in the roof, with daylight coming through it.
    canvas.drawRect(const Rect.fromLTWH(330, 200, 300, 44),
        Paint()..color = const Color(0xFF7C4A1E));
    canvas.drawRect(const Rect.fromLTWH(376, 200, 208, 40),
        Paint()..color = const Color(0xFFFEF3C7));
    canvas.drawCircle(
      const Offset(480, 300), 260,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.55),
          const Color(0xFFFEF3C7).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(480, 300), radius: 260)),
    );

    _ground(canvas, const Color(0xFF8A6A3C), kFloor);

    // ANIM 1 — the mat comes down on its ropes (t 0→0.55).
    final drop = _cl(0.0, 1.0, t, 0.0, 0.55);
    // ANIM 2 — then the man stands up, carrying it (t 0.6→1).
    final rise = _cl(0.0, 1.0, t, 0.6, 1.0);

    if (rise < 1) {
      final matY = _lerp(300.0, 636.0, drop);
      final rope = Paint()
        ..color = const Color(0xFF57534E)
        ..strokeWidth = 6;
      canvas.drawLine(Offset(400, 244), Offset(400, matY), rope);
      canvas.drawLine(Offset(560, 244), Offset(560, matY), rope);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(368, matY, 224, 30), const Radius.circular(10)),
        Paint()..color = const Color(0xFFB45309).withValues(alpha: 1 - rise),
      );
    }

    // Jesus, standing, one hand out towards the man.
    // § 4.2 limb rule: 150°/62° = 88° ✓
    _person(canvas, 760, 782, 300, const Color(0xFF8D5524), const Color(0xFFF5F5F4),
        armAngleL: 150, armAngleR: 62, hasHalo: true);

    // The healed man, standing with his mat rolled under one arm.
    if (rise > 0) {
      // § 4.2 limb rule: 128°/54° = 74° ✓
      _person(canvas, 320, 782, 250 * rise + 0.001, const Color(0xFFC68642),
          const Color(0xFF1D4ED8), armAngleL: 128, armAngleR: 54);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(196, 640, 120, 26), const Radius.circular(10)),
        Paint()..color = const Color(0xFFB45309).withValues(alpha: rise),
      );
    }
  }
}

// ── 51. Jesus Feeds the Crowd ─────────────────────────────────────────────────
// Intent: one child's lunch becomes food for everybody, with baskets left over.
class _FeedsCrowdScenePainter extends ScenePainter {
  const _FeedsCrowdScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kHill = 596.0;
    _sky(canvas, const Color(0xFF60A5FA), const Color(0xFFDBEAFE));
    _ground(canvas, const Color(0xFF4D7C0F), kHill);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 960), width: 1700, height: 720),
      Paint()..color = const Color(0xFF3F6212),
    );

    // ANIM 1 — the seated crowd fills the hillside (t 0→0.5).
    final crowd = _cl(0.0, 1.0, t, 0.0, 0.5);
    for (var i = 0; i < 12; i++) {
      final a = ((crowd * 12) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final cx = 70.0 + (i % 6) * 165;
      final cy = 618.0 + (i ~/ 6) * 52;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 74, height: 44),
        Paint()..color = const Color(0xFF365314).withValues(alpha: a),
      );
      canvas.drawCircle(Offset(cx, cy - 30), 17,
          Paint()..color = const Color(0xFF8D5524).withValues(alpha: a));
    }

    // The boy with the lunch — small, but ≥ 220 units so he reads as a person.
    // § 4.2 limb rule: 200°/78° = 122° ✓ (both arms holding the basket up)
    _person(canvas, 220, 780, 232, const Color(0xFF8D5524), const Color(0xFFB45309),
        armAngleL: 200, armAngleR: 78);

    // ANIM 2 — the twelve baskets fill up, left to right (t 0.35→1).
    final fill = _cl(0.0, 1.0, t, 0.35, 1.0);
    for (var i = 0; i < 6; i++) {
      final a = ((fill * 6) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final bx = 470.0 + i * 88;
      canvas.drawPath(
        Path()
          ..moveTo(bx - 40, 720)
          ..lineTo(bx + 40, 720)
          ..lineTo(bx + 28, 782)
          ..lineTo(bx - 28, 782)
          ..close(),
        Paint()..color = const Color(0xFF92400E).withValues(alpha: a),
      );
      // Loaves heaped above the rim
      canvas.drawOval(
        Rect.fromCenter(center: Offset(bx, 712), width: 76 * a, height: 34 * a),
        Paint()..color = const Color(0xFFD9A441).withValues(alpha: a),
      );
    }

    // ANIM 3 — warm light over the whole hillside as the food multiplies.
    canvas.drawCircle(
      const Offset(620, 560), 380,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.34 * fill),
          const Color(0xFFFEF3C7).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(620, 560), radius: 380)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// World 8 — Jesus Saves (#57–63)
// ═══════════════════════════════════════════════════════════════════════════

// ── 57. Jesus Raises Lazarus ──────────────────────────────────────────────────
// Intent: a dead man walks out of a tomb because Jesus called his name.
class _LazarusScenePainter extends ScenePainter {
  const _LazarusScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kGround = 610.0;
    _sky(canvas, const Color(0xFF475569), const Color(0xFFCBD5E1));
    _ground(canvas, const Color(0xFF57534E), kGround);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 950), width: 1700, height: 700),
      Paint()..color = const Color(0xFF44403C),
    );

    // The rock face and tomb mouth.
    canvas.drawRect(const Rect.fromLTWH(560, 300, 440, 310),
        Paint()..color = const Color(0xFF6B6259));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(650, 396, 200, 214), const Radius.circular(96)),
      Paint()..color = const Color(0xFF1C1917),
    );

    // ANIM 1 — the round stone rolls clear of the mouth (t 0→0.4).
    final roll = _cl(0.0, 1.0, t, 0.0, 0.4);
    canvas.save();
    canvas.translate(_lerp(750, 520, roll), 560);
    canvas.rotate(-roll * 3.2);
    canvas.drawCircle(Offset.zero, 92, Paint()..color = const Color(0xFF78716C));
    canvas.drawLine(const Offset(-92, 0), const Offset(92, 0),
        Paint()
          ..color = const Color(0xFF57534E)
          ..strokeWidth = 8);
    canvas.restore();

    // ANIM 2 — Lazarus, wrapped in cloths, comes out of the dark (t 0.45→1).
    final out = _cl(0.0, 1.0, t, 0.45, 1.0);
    if (out > 0) {
      final lx = _lerp(750.0, 700.0, out);
      // Body first — wrapped, so a plain banded column reads correctly here.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(lx - 46, 470, 92, 312), const Radius.circular(30)),
        Paint()..color = const Color(0xFFEDE9E2).withValues(alpha: out),
      );
      final band = Paint()
        ..color = const Color(0xFFCFC8BC).withValues(alpha: out)
        ..strokeWidth = 7;
      for (var y = 512.0; y < 770; y += 46) {
        canvas.drawLine(Offset(lx - 46, y), Offset(lx + 46, y), band);
      }
      canvas.drawCircle(Offset(lx, 452), 44,
          Paint()..color = const Color(0xFFEDE9E2).withValues(alpha: out));
    }

    // Jesus calling him out. § 4.2 limb rule: 236°/108° = 128° ✓
    _person(canvas, 230, 782, 300, const Color(0xFF8D5524), const Color(0xFFF5F5F4),
        armAngleL: 236, armAngleR: 108, hasHalo: true);

    // ANIM 3 — light grows out of the tomb mouth as life returns.
    canvas.drawCircle(
      const Offset(750, 500), 250,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.40 * out),
          const Color(0xFFFEF3C7).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(750, 500), radius: 250)),
    );
  }
}

// ── 58. The King Rides into Jerusalem ─────────────────────────────────────────
// Intent: the King everyone cheered for arrived on a donkey, not a war horse.
class _KingRidesInScenePainter extends ScenePainter {
  const _KingRidesInScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kRoad = 640.0;
    _sky(canvas, const Color(0xFF38BDF8), const Color(0xFFFDE68A));

    // City wall on the skyline.
    canvas.drawRect(const Rect.fromLTWH(600, 380, 400, 260),
        Paint()..color = const Color(0xFFD6C39B));
    for (var i = 0; i < 5; i++) {
      canvas.drawRect(Rect.fromLTWH(608 + i * 80, 356, 46, 26),
          Paint()..color = const Color(0xFFD6C39B));
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(740, 470, 120, 170), const Radius.circular(58)),
      Paint()..color = const Color(0xFF7C4A1E),
    );

    _ground(canvas, const Color(0xFFA97C45), kRoad);

    // ANIM 1 — palm branches are laid down along the road (t 0.15→0.8).
    final palms = _cl(0.0, 1.0, t, 0.15, 0.8);
    for (var i = 0; i < 5; i++) {
      final a = ((palms * 5) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final px = 110.0 + i * 168;
      final leaf = Paint()
        ..color = const Color(0xFF15803D).withValues(alpha: a)
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round;
      // A spine plus fronds fanning off it. The previous version used 9px marks
      // over an 18px spread, which at render size read as tufts of grass.
      canvas.drawLine(Offset(px - 74, 744), Offset(px + 74, 758), leaf);
      for (var k = -3; k <= 3; k++) {
        final sx = px + k * 24.0;
        canvas.drawLine(Offset(sx, 750), Offset(sx + 18, 706), leaf);
        canvas.drawLine(Offset(sx, 752), Offset(sx - 14, 782), leaf);
      }
    }

    // The donkey — a body, a head and four legs, so it never reads as a crate.
    const dx = 420.0;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(dx, 636), width: 300, height: 132),
      Paint()..color = const Color(0xFF9CA3AF),
    );
    final leg = Paint()
      ..color = const Color(0xFF6B7280)
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    for (final lx in const [dx - 96.0, dx - 44.0, dx + 44.0, dx + 96.0]) {
      canvas.drawLine(Offset(lx, 660), Offset(lx, 754), leg);
    }
    // Neck FIRST, so the head can never read as detached (§ 4.2 nothing floating).
    canvas.drawPath(
      Path()
        ..moveTo(dx + 100, 620)
        ..lineTo(dx + 132, 548)
        ..lineTo(dx + 176, 560)
        ..lineTo(dx + 148, 640)
        ..close(),
      Paint()..color = const Color(0xFF9CA3AF),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(dx + 168, 534), width: 122, height: 76),
      Paint()..color = const Color(0xFF9CA3AF),
    );
    // Ear and eye, so it reads as a donkey's head and not a grey egg.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(dx + 130, 486), width: 26, height: 62),
      Paint()..color = const Color(0xFF9CA3AF),
    );
    canvas.drawCircle(const Offset(dx + 186, 524), 11,
        Paint()..color = const Color(0xFF3F3A35));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(dx + 222, 546), width: 30, height: 22),
      Paint()..color = const Color(0xFF6B7280),
    );

    // Jesus riding. _kneeling gives a seated posture; 244 ≥ 220 ✓
    _kneeling(canvas, dx - 10, 604, 244, const Color(0xFF8D5524),
        const Color(0xFFF5F5F4));

    // ANIM 2 — the welcoming crowd rises along the roadside (t 0.4→1).
    final crowd = _cl(0.0, 1.0, t, 0.4, 1.0);
    for (var i = 0; i < 4; i++) {
      final a = ((crowd * 4) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final cx = 700.0 + i * 82;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 22, 640, 44, 118), const Radius.circular(20)),
        Paint()..color = const Color(0xFF6D28D9).withValues(alpha: a),
      );
      canvas.drawCircle(Offset(cx, 624), 22,
          Paint()..color = const Color(0xFF8D5524).withValues(alpha: a));
    }
  }
}

// ── 59. The Servant King Washes Feet ──────────────────────────────────────────
// Intent: the King of everything is the one kneeling on the floor with the towel.
class _WashesFeetScenePainter extends ScenePainter {
  const _WashesFeetScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kFloor = 600.0;
    _sky(canvas, const Color(0xFF3F2A14), const Color(0xFF7C4A1E));
    _ground(canvas, const Color(0xFF2E1D0C), kFloor);

    // ANIM 1 — the lamp brightens the room (t 0→0.6).
    final lamp = _cl(0.4, 1.0, t, 0.0, 0.6);
    canvas.drawCircle(
      const Offset(500, 430), 420,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFDE68A).withValues(alpha: 0.40 * lamp),
          const Color(0xFFFDE68A).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(500, 430), radius: 420)),
    );

    // The seated friend, feet forward.
    _kneeling(canvas, 760, 700, 262, const Color(0xFFC68642), const Color(0xFF1D4ED8));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(660, 730), width: 118, height: 46),
      Paint()..color = const Color(0xFFC68642),
    );

    // The basin, with water in it.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(560, 748), width: 180, height: 64),
      Paint()..color = const Color(0xFF9CA3AF),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(560, 742), width: 146, height: 44),
      Paint()..color = const Color(0xFF2563EB),
    );

    // Jesus kneeling with the towel. 268 ≥ 220 ✓
    _kneeling(canvas, 320, 782, 268, const Color(0xFF8D5524), const Color(0xFFE7E5E4));
    // The towel over his waist — the detail that names the story.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(250, 690, 148, 40), const Radius.circular(10)),
      Paint()..color = const Color(0xFFFEF3C7),
    );

    // ANIM 2 — water pours from his hands into the basin (t 0.35→1).
    final pour = _cl(0.0, 1.0, t, 0.35, 1.0);
    if (pour > 0) {
      canvas.drawPath(
        Path()
          ..moveTo(452, 700)
          ..lineTo(468, 700)
          ..lineTo(506, _lerp(700.0, 742.0, pour))
          ..lineTo(486, _lerp(700.0, 742.0, pour))
          ..close(),
        Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.9 * pour),
      );
    }
  }
}

// ── 60. The Last Supper ───────────────────────────────────────────────────────
// Intent: bread broken and a cup lifted — the meal that had always pointed here.
class _LastSupperScenePainter extends ScenePainter {
  const _LastSupperScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kTable = 620.0;
    _sky(canvas, const Color(0xFF3F2A14), const Color(0xFF7C4A1E));

    // ANIM 1 — lamplight rises over the table (t 0→0.5).
    final lamp = _cl(0.35, 1.0, t, 0.0, 0.5);
    canvas.drawCircle(
      const Offset(500, 470), 400,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFDE68A).withValues(alpha: 0.46 * lamp),
          const Color(0xFFFDE68A).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(500, 470), radius: 400)),
    );

    // Friends seated behind the table, in shadow.
    for (var i = 0; i < 4; i++) {
      final cx = 190.0 + i * 208;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 46, 400, 92, 220), const Radius.circular(30)),
        Paint()..color = const Color(0xFF3F2109),
      );
      canvas.drawCircle(Offset(cx, 386), 40,
          Paint()..color = const Color(0xFF9C6B3C));
    }

    // The table — darker than the sky above it (§ 4.4)
    _ground(canvas, const Color(0xFF5B3212), kTable);
    canvas.drawRect(const Rect.fromLTWH(0, kTable, 1000, 22),
        Paint()..color = const Color(0xFF7C4A1E));

    // ANIM 2 — the loaf breaks into two halves that draw apart (t 0.3→0.8).
    final broken = _cl(0.0, 1.0, t, 0.3, 0.8);
    final gap = _lerp(0.0, 86.0, broken);
    final bread = Paint()..color = const Color(0xFFD9A441);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(410 - gap, 690), width: 132, height: 76), bread);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(410 + gap, 690), width: 132, height: 76), bread);
    // A crumb line between them, so the break itself is visible.
    if (broken > 0.3) {
      canvas.drawCircle(const Offset(410, 700), 7,
          Paint()..color = const Color(0xFFB07C22));
    }

    // ANIM 3 — the cup lifts off the table (t 0.55→1).
    final lift = _cl(0.0, 1.0, t, 0.55, 1.0);
    final cupY = _lerp(700.0, 620.0, lift);
    canvas.drawPath(
      Path()
        ..moveTo(690, cupY - 46)
        ..lineTo(790, cupY - 46)
        ..lineTo(768, cupY + 24)
        ..lineTo(712, cupY + 24)
        ..close(),
      Paint()..color = const Color(0xFF9CA3AF),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(740, cupY - 42), width: 96, height: 26),
      Paint()..color = const Color(0xFF991B1B),
    );
    canvas.drawRect(Rect.fromLTWH(730, cupY + 24, 20, 34),
        Paint()..color = const Color(0xFF9CA3AF));
  }
}

// ── 61. Jesus Prays in the Garden ─────────────────────────────────────────────
// Intent: he knelt in the dark and told his Father the truth, and still said yes.
class _GethsemaneScenePainter extends ScenePainter {
  const _GethsemaneScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kGround = 626.0;
    _sky(canvas, const Color(0xFF0B1220), const Color(0xFF1E3A2F));

    // Quiet stars, so t=0 is already composed (§ 4.5)
    for (final s in const [
      [110.0, 168.0, 4.0], [268.0, 122.0, 3.5], [430.0, 200.0, 3.0],
      [640.0, 140.0, 4.0], [812.0, 210.0, 3.5], [910.0, 132.0, 4.5],
    ]) {
      _dot(canvas, s[0], s[1], s[2], 0.7);
    }

    _ground(canvas, const Color(0xFF14261C), kGround);

    // Olive trees — trunks plus canopies, kept off the centre line.
    for (final tx in const [130.0, 300.0, 830.0]) {
      canvas.drawRect(Rect.fromLTWH(tx - 16, 430, 32, 200),
          Paint()..color = const Color(0xFF3F2A14));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(tx, 410), width: 220, height: 150),
        Paint()..color = const Color(0xFF1F3D2B),
      );
    }

    // ANIM 1 — moonlight opens through the branches onto him (t 0.2→1).
    final moon = _cl(0.0, 1.0, t, 0.2, 1.0);
    canvas.drawCircle(
      const Offset(560, 380), 330,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFE2E8F0).withValues(alpha: 0.40 * moon),
          const Color(0xFFE2E8F0).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(560, 380), radius: 330)),
    );

    // ANIM 2 — the three friends settle down asleep (t 0.3→0.9).
    final sleep = _cl(0.0, 1.0, t, 0.3, 0.9);
    for (var i = 0; i < 3; i++) {
      final sx = 810.0 + i * 62;
      final h = _lerp(96.0, 42.0, sleep);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(sx, 770 - h / 2), width: _lerp(48, 92, sleep), height: h),
        Paint()..color = const Color(0xFF3F3A35),
      );
      canvas.drawCircle(
          Offset(sx - _lerp(0, 40, sleep), 770 - h + _lerp(6, 18, sleep)),
          18, Paint()..color = const Color(0xFF7C5230));
    }

    // Jesus kneeling. 300 ≥ 220 ✓
    _kneeling(canvas, 500, 782, 300, const Color(0xFF8D5524), const Color(0xFFE7E5E4));
  }
}

// ── 62. Jesus Dies for Sinners ────────────────────────────────────────────────
// Intent: seen from far off and held with restraint — the work is finished, and
//         light is already breaking. No wounds, no figures in detail (§ safety).
class _CrucifixionScenePainter extends ScenePainter {
  const _CrucifixionScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kHill = 660.0;

    // ANIM 1 — the sky darkens at midday, then light breaks at the end.
    final dark = _cl(0.0, 1.0, t, 0.0, 0.55);
    final dawn = _cl(0.0, 1.0, t, 0.6, 1.0);
    _sky(
      canvas,
      Color.lerp(Color.lerp(const Color(0xFF93C5FD), const Color(0xFF1C1917), dark)!,
          const Color(0xFF78350F), dawn)!,
      Color.lerp(Color.lerp(const Color(0xFFFDE68A), const Color(0xFF44403C), dark)!,
          const Color(0xFFFBBF24), dawn)!,
    );

    // ANIM 2 — a shaft of gold opens through the cloud (t 0.6→1).
    if (dawn > 0) {
      canvas.drawPath(
        Path()
          ..moveTo(470, 200)
          ..lineTo(530, 200)
          ..lineTo(660, kHill)
          ..lineTo(340, kHill)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: 0.0),
              const Color(0xFFFDE68A).withValues(alpha: 0.34 * dawn),
            ],
          ).createShader(const Rect.fromLTWH(340, 200, 320, 460)),
      );
    }

    // The hill — darker than the sky (§ 4.4)
    _ground(canvas, const Color(0xFF3F3A35), kHill);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 980), width: 1800, height: 760),
      Paint()..color = const Color(0xFF2E2A26),
    );

    // Three crosses in silhouette on the ridge — distant, plain, no figures.
    void cross(double cx, double h, double w) {
      final p = Paint()..color = const Color(0xFF1C1917);
      canvas.drawRect(Rect.fromLTWH(cx - w / 2, kHill - h, w, h), p);
      canvas.drawRect(
          Rect.fromLTWH(cx - h * 0.20, kHill - h * 0.74, h * 0.40, w), p);
    }
    cross(300, 168, 20);
    cross(500, 232, 26);
    cross(700, 168, 20);

    // ANIM 3 — the temple curtain tears, from the top down (t 0.65→1).
    // Drawn as an inset panel at the side so it reads as a separate thing that
    // happened at the same moment, not as part of the hill.
    final tear = _cl(0.0, 1.0, t, 0.65, 1.0);
    if (tear > 0) {
      const cx = 878.0;
      canvas.drawRect(const Rect.fromLTWH(cx - 82, 250, 164, 300),
          Paint()..color = const Color(0xFF7C2D12).withValues(alpha: 0.92));
      canvas.drawPath(
        Path()
          ..moveTo(cx, 250)
          ..lineTo(cx + 16, 250 + 300 * tear)
          ..lineTo(cx - 16, 250 + 300 * tear)
          ..close(),
        Paint()..color = const Color(0xFFFEF3C7),
      );
    }
  }
}

// ── 63. Jesus Is Alive ────────────────────────────────────────────────────────
// Intent: the stone is aside, the cloths are folded, and the sun is up.
class _RisenScenePainter extends ScenePainter {
  const _RisenScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kGround = 618.0;

    // ANIM 1 — sunrise floods the garden (t 0→0.6).
    final dawn = _cl(0.0, 1.0, t, 0.0, 0.6);
    _sky(canvas,
        Color.lerp(const Color(0xFF1E293B), const Color(0xFF0EA5E9), dawn)!,
        Color.lerp(const Color(0xFF475569), const Color(0xFFFDE68A), dawn)!);

    canvas.drawCircle(
      const Offset(760, 330), 320,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.70 * dawn),
          const Color(0xFFFEF3C7).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(760, 330), radius: 320)),
    );

    // Grass — darker than the sky (§ 4.4)
    _ground(canvas, const Color(0xFF3F6212), kGround);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 960), width: 1700, height: 700),
      Paint()..color = const Color(0xFF4D7C0F),
    );

    // The rock face with the tomb standing open.
    canvas.drawRect(const Rect.fromLTWH(120, 250, 460, 368),
        Paint()..color = const Color(0xFF6B6259));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(240, 350, 216, 268), const Radius.circular(104)),
      Paint()..color = const Color(0xFF1C1917),
    );

    // ANIM 2 — the great stone rolls aside (t 0.1→0.5).
    final roll = _cl(0.0, 1.0, t, 0.1, 0.5);
    canvas.save();
    canvas.translate(_lerp(348, 620, roll), 566);
    canvas.rotate(roll * 3.4);
    canvas.drawCircle(Offset.zero, 98, Paint()..color = const Color(0xFF78716C));
    canvas.drawLine(const Offset(-98, 0), const Offset(98, 0),
        Paint()
          ..color = const Color(0xFF57534E)
          ..strokeWidth = 9);
    canvas.restore();

    // ANIM 3 — the folded cloths appear in the empty tomb (t 0.55→1).
    // Nobody in a hurry folds cloths, so they are drawn as neat stacked bands.
    final cloths = _cl(0.0, 1.0, t, 0.55, 1.0);
    if (cloths > 0) {
      for (var i = 0; i < 3; i++) {
        final a = ((cloths * 3) - i).clamp(0.0, 1.0);
        if (a <= 0) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(288, 540.0 + i * 26, 120, 20),
              const Radius.circular(8)),
          Paint()..color = const Color(0xFFF5F5F4).withValues(alpha: a),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// World 9 — Spirit-Filled Family (#65–72)
// ═══════════════════════════════════════════════════════════════════════════

// ── 65. Jesus Returns to His Father ───────────────────────────────────────────
// Intent: he goes up while still blessing them, and two angels turn them round.
class _AscensionScenePainter extends ScenePainter {
  const _AscensionScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kHill = 640.0;
    _sky(canvas, const Color(0xFF2563EB), const Color(0xFFDBEAFE));
    _ground(canvas, const Color(0xFF3F6212), kHill);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 960), width: 1700, height: 700),
      Paint()..color = const Color(0xFF4D7C0F),
    );

    // ANIM 1 — Jesus rises and a cloud takes him (t 0.15→0.85).
    final rise = _cl(0.0, 1.0, t, 0.15, 0.85);
    final jy = _lerp(700.0, 430.0, rise);
    final fade = (1.0 - _cl(0.0, 1.0, t, 0.6, 0.95)).clamp(0.0, 1.0);
    if (fade > 0) {
      canvas.saveLayer(const Rect.fromLTWH(0, 0, 1000, 1000),
          Paint()..color = Colors.white.withValues(alpha: fade));
      // Arms raised in blessing. § 4.2 limb rule: 236°/304° = 68° ✓
      _person(canvas, 500, jy, 260, const Color(0xFF8D5524),
          const Color(0xFFF5F5F4), armAngleL: 236, armAngleR: 304, hasHalo: true);
      canvas.restore();
    }
    // The cloud that receives him — grows as he goes.
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(500, 372), width: 520 * rise, height: 190 * rise),
      Paint()..color = Colors.white.withValues(alpha: 0.92 * rise),
    );

    // ANIM 2 — two angels arrive beside the watchers (t 0.55→1).
    final ang = _cl(0.0, 1.0, t, 0.55, 1.0);
    for (final ax in const [706.0, 840.0]) {
      if (ang <= 0) break;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(ax - 34, 606, 68, 176), const Radius.circular(26)),
        Paint()..color = Colors.white.withValues(alpha: 0.95 * ang),
      );
      canvas.drawCircle(Offset(ax, 588), 32,
          Paint()..color = const Color(0xFFFDE68A).withValues(alpha: ang));
    }

    // The watchers, heads back. § 4.2 limb rule: 250°/100° = 150° is too wide;
    // 232°/104° = 128° ✓
    _person(canvas, 190, 782, 250, const Color(0xFF8D5524), const Color(0xFF1D4ED8),
        armAngleL: 232, armAngleR: 104);
    _person(canvas, 340, 782, 236, const Color(0xFFC68642), const Color(0xFF0F766E),
        armAngleL: 226, armAngleR: 110);
  }
}

// ── 66. The Holy Spirit Comes ─────────────────────────────────────────────────
// Intent: wind and flames fill a room, and the people inside start to speak.
class _PentecostScenePainter extends ScenePainter {
  const _PentecostScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kFloor = 640.0;
    _sky(canvas, const Color(0xFF7C2D12), const Color(0xFFB45309));
    canvas.drawRect(const Rect.fromLTWH(0, 200, 1000, 440),
        Paint()..color = const Color(0xFF7C4A1E));
    _ground(canvas, const Color(0xFF44280F), kFloor);

    // ANIM 1 — the room fills with light as the Spirit comes (t 0.1→0.7).
    final fill = _cl(0.0, 1.0, t, 0.1, 0.7);
    canvas.drawCircle(
      const Offset(500, 430), 460,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFDE68A).withValues(alpha: 0.52 * fill),
          const Color(0xFFFDE68A).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(500, 430), radius: 460)),
    );

    // The gathered church — five figures, shoulder to shoulder.
    for (var i = 0; i < 5; i++) {
      final cx = 180.0 + i * 160;
      canvas.drawPath(
        Path()
          ..moveTo(cx - 40, 560)
          ..lineTo(cx - 62, 782)
          ..lineTo(cx + 62, 782)
          ..lineTo(cx + 40, 560)
          ..close(),
        Paint()..color = [
          const Color(0xFF1D4ED8),
          const Color(0xFF0F766E),
          const Color(0xFF6D28D9),
          const Color(0xFF991B1B),
          const Color(0xFF115E59),
        ][i],
      );
      // Arms and a face. Without them a coloured trapezoid under a circle under
      // a flame reads unmistakably as a CANDLE, which is what this scene did.
      final arm = Paint()
        ..color = const Color(0xFF8D5524)
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx - 34, 586), Offset(cx - 74, 660), arm);
      canvas.drawLine(Offset(cx + 34, 586), Offset(cx + 74, 660), arm);
      canvas.drawCircle(Offset(cx, 522), 42,
          Paint()..color = const Color(0xFF8D5524));
      final face = Paint()..color = const Color(0xFF44280F);
      canvas.drawCircle(Offset(cx - 14, 516), 5.5, face);
      canvas.drawCircle(Offset(cx + 14, 516), 5.5, face);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, 532), width: 28, height: 16),
        0.15, math.pi * 0.7, false,
        Paint()
          ..color = const Color(0xFF44280F)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );

      // ANIM 2 — a flame settles above each head, one after another (t 0.3→1).
      final a = ((_cl(0.0, 1.0, t, 0.3, 1.0) * 5) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      canvas.drawPath(
        Path()
          ..moveTo(cx - 20 * a, 462)
          ..quadraticBezierTo(cx - 13 * a, 462 - 52 * a, cx, 462 - 86 * a)
          ..quadraticBezierTo(cx + 13 * a, 462 - 52 * a, cx + 20 * a, 462)
          ..close(),
        Paint()..color = const Color(0xFFFBBF24),
      );
      canvas.drawPath(
        Path()
          ..moveTo(cx - 9 * a, 462)
          ..quadraticBezierTo(cx - 6 * a, 462 - 28 * a, cx, 462 - 48 * a)
          ..quadraticBezierTo(cx + 6 * a, 462 - 28 * a, cx + 9 * a, 462)
          ..close(),
        Paint()..color = const Color(0xFFFEF3C7),
      );
    }
  }
}

// ── 67. A New Sharing Family ──────────────────────────────────────────────────
// Intent: a table with room at it — people eating, praying and sharing together.
class _SharingFamilyScenePainter extends ScenePainter {
  const _SharingFamilyScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kFloor = 636.0;
    _sky(canvas, const Color(0xFFB45309), const Color(0xFFFDE68A));
    _ground(canvas, const Color(0xFF7C4A1E), kFloor);

    // The long table.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(90, 646, 820, 40), const Radius.circular(12)),
      Paint()..color = const Color(0xFF92400E),
    );

    // ANIM 1 — people gather round it, from both ends inwards (t 0→0.6).
    final gather = _cl(0.0, 1.0, t, 0.0, 0.6);
    const seats = [150.0, 290.0, 430.0, 570.0, 710.0, 850.0];
    const robes = [
      Color(0xFF1D4ED8), Color(0xFF0F766E), Color(0xFF6D28D9),
      Color(0xFF991B1B), Color(0xFF115E59), Color(0xFFB45309),
    ];
    for (var i = 0; i < seats.length; i++) {
      final a = ((gather * 6) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      canvas.drawPath(
        Path()
          ..moveTo(seats[i] - 34, 470)
          ..lineTo(seats[i] - 52, 646)
          ..lineTo(seats[i] + 52, 646)
          ..lineTo(seats[i] + 34, 470)
          ..close(),
        Paint()..color = robes[i].withValues(alpha: a),
      );
      canvas.drawCircle(Offset(seats[i], 434), 38,
          Paint()..color = const Color(0xFF8D5524).withValues(alpha: a));
    }

    // ANIM 2 — bread is passed along the table (t 0.4→1).
    final pass = _cl(0.0, 1.0, t, 0.4, 1.0);
    for (var i = 0; i < 5; i++) {
      final a = ((pass * 5) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(200.0 + i * 150, 640), width: 92 * a, height: 34 * a),
        Paint()..color = const Color(0xFFD9A441),
      );
    }

    // ANIM 3 — an empty place at the near end, kept open (t 0.6→1).
    final open = _cl(0.0, 1.0, t, 0.6, 1.0);
    if (open > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(430, 706, 140, 66), const Radius.circular(14)),
        Paint()
          ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.85 * open)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7,
      );
    }
  }
}

// ── 68. Stephen Sees Jesus ────────────────────────────────────────────────────
// Intent: heaven opens and he looks up — the picture stays on what he SAW.
class _StephenScenePainter extends ScenePainter {
  const _StephenScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kGround = 646.0;

    // ANIM 1 — heaven opens above him (t 0.15→1).
    final open = _cl(0.0, 1.0, t, 0.15, 1.0);
    _sky(canvas,
        Color.lerp(const Color(0xFF334155), const Color(0xFF1D4ED8), open)!,
        Color.lerp(const Color(0xFF64748B), const Color(0xFFBFDBFE), open)!);

    canvas.drawCircle(
      const Offset(500, 300), _lerp(120.0, 400.0, open),
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.80 * open),
          const Color(0xFFFEF3C7).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(
            center: const Offset(500, 300), radius: _lerp(120.0, 400.0, open))),
    );

    // ANIM 2 — a standing figure of light appears in the opening (t 0.5→1).
    final seen = _cl(0.0, 1.0, t, 0.5, 1.0);
    if (seen > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(456, 210, 88, 210), const Radius.circular(34)),
        Paint()..color = Colors.white.withValues(alpha: 0.92 * seen),
      );
      canvas.drawCircle(const Offset(500, 196), 40,
          Paint()..color = const Color(0xFFFEF3C7).withValues(alpha: seen));
    }

    _ground(canvas, const Color(0xFF57534E), kGround);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 970), width: 1700, height: 700),
      Paint()..color = const Color(0xFF44403C),
    );

    // Stephen, looking up, arms open. § 4.2 limb rule: 244°/296° = 52° ✓
    _person(canvas, 500, 782, 286, const Color(0xFF8D5524), const Color(0xFF0F766E),
        armAngleL: 244, armAngleR: 296);
  }
}

// ── 69. Saul Meets the Risen Jesus ────────────────────────────────────────────
// Intent: a light stops him on the road and he goes down — not improved, remade.
class _SaulRoadScenePainter extends ScenePainter {
  const _SaulRoadScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kRoad = 632.0;
    final flash = _cl(0.0, 1.0, t, 0.2, 0.7);

    _sky(canvas,
        Color.lerp(const Color(0xFF0369A1), const Color(0xFFFDE68A), flash)!,
        Color.lerp(const Color(0xFF7DD3FC), const Color(0xFFFEF9C3), flash)!);

    _ground(canvas, const Color(0xFFA97C45), kRoad);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 960), width: 1700, height: 700),
      Paint()..color = const Color(0xFF8C6538),
    );

    // ANIM 1 — the light from heaven, growing until it fills the road.
    canvas.drawCircle(
      const Offset(660, 330), _lerp(60.0, 460.0, flash),
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.92 * flash),
          const Color(0xFFFDE68A).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(
            center: const Offset(660, 330), radius: _lerp(60.0, 460.0, flash))),
    );

    // ANIM 2 — Saul goes from striding to face down on the road (t 0.35→1).
    final down = _cl(0.0, 1.0, t, 0.35, 1.0);
    if (down < 0.55) {
      // Still upright. § 4.2 limb rule: 226°/96° = 130° ✓ (shielding his eyes)
      _person(canvas, 300, 782, 296, const Color(0xFF8D5524),
          const Color(0xFF4B5563), armAngleL: 226, armAngleR: 96);
    } else {
      // On the ground — a body plus a separate head, so it reads as a person
      // and not as a rock (the same defect that hit Elijah's bowing crowd).
      final k = ((down - 0.55) / 0.45).clamp(0.0, 1.0);
      // A prone PERSON, not a flattened oval. Squashing an ellipse produces the
      // same defect that made Elijah's bowing crowd read as boulders — here it
      // came out as a puddle with a ball beside it. A torso with a visible arm
      // and two legs stays a body however low it lies.
      canvas.save();
      canvas.translate(330, 742);
      canvas.rotate(_lerp(-1.35, -0.12, k)); // upright → lying along the road
      final robe = Paint()..color = const Color(0xFF4B5563);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-46, -150, 92, 190), const Radius.circular(34)),
        robe,
      );
      // Legs, slightly apart so they read as two.
      final limb = Paint()
        ..color = robe.color
        ..strokeWidth = 30
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-18, 34), const Offset(-26, 116), limb);
      canvas.drawLine(const Offset(20, 34), const Offset(34, 114), limb);
      // The arm reaching out ahead of him.
      canvas.drawLine(const Offset(-34, -120), const Offset(-104, -168),
          Paint()
            ..color = const Color(0xFF8D5524)
            ..strokeWidth = 24
            ..strokeCap = StrokeCap.round);
      canvas.drawCircle(const Offset(0, -178), 38,
          Paint()..color = const Color(0xFF8D5524));
      canvas.restore();
    }

    // ANIM 3 — his companions stand back, unable to help (t 0.5→1).
    final back = _cl(0.0, 1.0, t, 0.5, 1.0);
    for (var i = 0; i < 2; i++) {
      if (back <= 0) break;
      final cx = 840.0 + i * 78;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 26, 636, 52, 146), const Radius.circular(22)),
        Paint()..color = const Color(0xFF57534E).withValues(alpha: back),
      );
      canvas.drawCircle(Offset(cx, 618), 26,
          Paint()..color = const Color(0xFF7C5230).withValues(alpha: back));
    }
  }
}

// ── 70. Peter Welcomes Cornelius ──────────────────────────────────────────────
// Intent: two men who were never meant to meet, clasping hands in a doorway.
class _CorneliusScenePainter extends ScenePainter {
  const _CorneliusScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kFloor = 636.0;
    _sky(canvas, const Color(0xFF0E7490), const Color(0xFFA5F3FC));

    canvas.drawRect(const Rect.fromLTWH(240, 220, 520, 416),
        Paint()..color = const Color(0xFFD6C39B));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(320, 300, 360, 336), const Radius.circular(150)),
      Paint()..color = const Color(0xFF7C4A1E),
    );
    _ground(canvas, const Color(0xFF115E59), kFloor);

    // ANIM 1 — sunlight comes through the open door (t 0→0.55).
    final light = _cl(0.25, 1.0, t, 0.0, 0.55);
    canvas.drawCircle(
      const Offset(500, 470), 330,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.48 * light),
          const Color(0xFFFEF3C7).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(500, 470), radius: 330)),
    );

    // ANIM 2 — the household gathers behind them (t 0.3→1).
    final house = _cl(0.0, 1.0, t, 0.3, 1.0);
    for (var i = 0; i < 4; i++) {
      final a = ((house * 4) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final cx = 380.0 + i * 82;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 26, 486, 52, 150), const Radius.circular(22)),
        Paint()..color = const Color(0xFF0F766E).withValues(alpha: 0.9 * a),
      );
      canvas.drawCircle(Offset(cx, 468), 26,
          Paint()..color = const Color(0xFFC68642).withValues(alpha: a));
    }

    // Peter, the fisherman, reaching right. § 4.2 limb rule: 152°/34° = 118° ✓
    _person(canvas, 250, 782, 296, const Color(0xFF8D5524), const Color(0xFF92400E),
        armAngleL: 152, armAngleR: 34);
    // Cornelius, the officer, reaching left. § 4.2 limb rule: 146°/28° = 118° ✓
    _person(canvas, 762, 782, 296, const Color(0xFFC68642), const Color(0xFF991B1B),
        armAngleL: 146, armAngleR: 28);

    // ANIM 3 — their hands meet in the middle (t 0.6→1).
    final clasp = _cl(0.0, 1.0, t, 0.6, 1.0);
    if (clasp > 0) {
      canvas.drawCircle(const Offset(506, 640), 30 * clasp,
          Paint()..color = const Color(0xFFC68642));
      canvas.drawCircle(const Offset(506, 640), 30 * clasp,
          Paint()
            ..color = const Color(0xFFFDE68A).withValues(alpha: 0.8 * clasp)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6);
    }
  }
}

// ── 71. Paul and Silas Sing in Prison ─────────────────────────────────────────
// Intent: two men singing in a dark cell, and the prisoners next door listening.
class _PrisonSongScenePainter extends ScenePainter {
  const _PrisonSongScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kFloor = 640.0;
    _sky(canvas, const Color(0xFF1E1B4B), const Color(0xFF312E81));
    canvas.drawRect(const Rect.fromLTWH(0, 200, 1000, 440),
        Paint()..color = const Color(0xFF262261));
    _ground(canvas, const Color(0xFF15133B), kFloor);

    final bar = Paint()
      ..color = const Color(0xFF0B0A26)
      ..strokeWidth = 14;
    for (var x = 620.0; x <= 980; x += 60) {
      canvas.drawLine(Offset(x, 300), Offset(x, kFloor), bar);
    }

    // ANIM 1 — light grows around them as they sing (t 0.1→0.8).
    final song = _cl(0.0, 1.0, t, 0.1, 0.8);
    canvas.drawCircle(
      const Offset(320, 500), 360,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFDE68A).withValues(alpha: 0.44 * song),
          const Color(0xFFFDE68A).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(320, 500), radius: 360)),
    );

    // § 4.2 limb rule: 240°/300° = 60° ✓
    _person(canvas, 220, 782, 274, const Color(0xFF8D5524), const Color(0xFF0F766E),
        armAngleL: 240, armAngleR: 300);
    _person(canvas, 420, 782, 262, const Color(0xFFC68642), const Color(0xFF1D4ED8),
        armAngleL: 244, armAngleR: 296);

    // ANIM 2 — notes rise from them (t 0.3→1).
    final notes = _cl(0.0, 1.0, t, 0.3, 1.0);
    for (var i = 0; i < 4; i++) {
      final a = ((notes * 4) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final nx = 300.0 + i * 60;
      final ny = _lerp(470.0, 300.0, a);
      canvas.drawCircle(Offset(nx, ny), 13,
          Paint()..color = const Color(0xFFFDE68A).withValues(alpha: a));
      canvas.drawLine(Offset(nx + 12, ny), Offset(nx + 12, ny - 36),
          Paint()
            ..color = const Color(0xFFFDE68A).withValues(alpha: a)
            ..strokeWidth = 5);
    }

    // ANIM 3 — the prisoners next door turn to listen (t 0.5→1).
    final listen = _cl(0.0, 1.0, t, 0.5, 1.0);
    for (var i = 0; i < 2; i++) {
      if (listen <= 0) break;
      final cx = 720.0 + i * 130;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 30, 604, 60, 178), const Radius.circular(24)),
        Paint()..color = const Color(0xFF3F3A35).withValues(alpha: listen),
      );
      canvas.drawCircle(Offset(cx - 14 * listen, 586), 28,
          Paint()..color = const Color(0xFF7C5230).withValues(alpha: listen));
    }
  }
}

// ── 72. The Spirit Grows Good Fruit ───────────────────────────────────────────
// Intent: a branch joined to the vine, heavy with fruit it never strained for.
class _GoodFruitScenePainter extends ScenePainter {
  const _GoodFruitScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kGround = 700.0;
    _sky(canvas, const Color(0xFF0F766E), const Color(0xFFD9F99D));
    _ground(canvas, const Color(0xFF3F6212), kGround);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(96, 260, 108, 440), const Radius.circular(20)),
      Paint()..color = const Color(0xFF57340F),
    );

    // ANIM 1 — the branch grows out from the trunk (t 0→0.5).
    final grow = _cl(0.15, 1.0, t, 0.0, 0.5);
    final branch = Path()..moveTo(190, 400);
    branch.quadraticBezierTo(
        _lerp(300, 560, grow), 330, _lerp(320, 900, grow), 420);
    canvas.drawPath(
      branch,
      Paint()
        ..color = const Color(0xFF3F2A14)
        ..strokeWidth = 30
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // ANIM 2 — leaves open along it (t 0.3→0.8).
    final leaf = _cl(0.0, 1.0, t, 0.3, 0.8);
    for (var i = 0; i < 5; i++) {
      final a = ((leaf * 5) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final lx = 300.0 + i * 140;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(lx, 372 - (i.isEven ? 46 : -46)),
            width: 118 * a, height: 60 * a),
        Paint()..color = const Color(0xFF22C55E),
      );
    }

    // ANIM 3 — the fruit fills out, quietly, last of all (t 0.5→1).
    final fruit = _cl(0.0, 1.0, t, 0.5, 1.0);
    for (var i = 0; i < 4; i++) {
      final a = ((fruit * 4) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final fx = 360.0 + i * 160;
      canvas.drawCircle(Offset(fx, 486), 40 * a,
          Paint()..color = const Color(0xFFDC2626));
      canvas.drawLine(Offset(fx, 448), Offset(fx, 424),
          Paint()
            ..color = const Color(0xFF15803D).withValues(alpha: a)
            ..strokeWidth = 7);
    }

    // A child reaching up to the branch — joined to the vine, not straining.
    // Drawn with _person so it is unmistakably a child: a bare arm plus a
    // circle on top read as a lollipop, not a person.
    // § 4.2 limb rule: 268°/44° = 224° is out of range, so 262°/128° = 134° ✓
    _person(canvas, 520, 782, 268, const Color(0xFF8D5524),
        const Color(0xFF1D4ED8), armAngleL: 262, armAngleR: 128);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// World 10 — The King Makes All Things New (#73–80)
// ═══════════════════════════════════════════════════════════════════════════

// ── 73. God's Armour for Hard Days ────────────────────────────────────────────
// Intent: the armour is GOD's, laid out and given — not a checklist to achieve.
class _ArmourScenePainter extends ScenePainter {
  const _ArmourScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kFloor = 660.0;
    _sky(canvas, const Color(0xFF334155), const Color(0xFF94A3B8));
    _ground(canvas, const Color(0xFF1E293B), kFloor);

    // ANIM 1 — light comes up behind the armour (t 0→0.6).
    final light = _cl(0.2, 1.0, t, 0.0, 0.6);
    canvas.drawCircle(
      const Offset(500, 440), 400,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFDE68A).withValues(alpha: 0.40 * light),
          const Color(0xFFFDE68A).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(500, 440), radius: 400)),
    );

    // ANIM 2 — the pieces are set out, one at a time (t 0.1→0.9).
    final laid = _cl(0.0, 1.0, t, 0.1, 0.9);
    double a(int i) => ((laid * 5) - i).clamp(0.0, 1.0);

    // Helmet
    if (a(0) > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(500, 330), radius: 70),
        math.pi, math.pi, false,
        Paint()..color = const Color(0xFFB08D3A).withValues(alpha: a(0)),
      );
      canvas.drawRect(Rect.fromLTWH(430, 326, 140, 20),
          Paint()..color = const Color(0xFF8A7550).withValues(alpha: a(0)));
    }
    // Breastplate
    if (a(1) > 0) {
      canvas.drawPath(
        Path()
          ..moveTo(420, 372)
          ..lineTo(580, 372)
          ..lineTo(556, 540)
          ..lineTo(444, 540)
          ..close(),
        Paint()..color = const Color(0xFF9CA3AF).withValues(alpha: a(1)),
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(500, 440), width: 96, height: 110),
        Paint()..color = const Color(0xFFCBD5E1).withValues(alpha: a(1)),
      );
    }
    // Belt
    if (a(2) > 0) {
      canvas.drawRect(Rect.fromLTWH(438, 540, 124, 26),
          Paint()..color = const Color(0xFF57340F).withValues(alpha: a(2)));
    }
    // Shield of faith, to one side
    if (a(3) > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(160, 400, 190, 250), const Radius.circular(60)),
        Paint()..color = const Color(0xFF1D4ED8).withValues(alpha: a(3)),
      );
      canvas.drawCircle(const Offset(255, 525), 40,
          Paint()..color = const Color(0xFFFDE68A).withValues(alpha: a(3)));
    }
    // Sword of the Spirit, to the other
    if (a(4) > 0) {
      canvas.drawRect(Rect.fromLTWH(742, 336, 26, 260),
          Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: a(4)));
      canvas.drawRect(Rect.fromLTWH(704, 596, 102, 22),
          Paint()..color = const Color(0xFFB08D3A).withValues(alpha: a(4)));
      canvas.drawRect(Rect.fromLTWH(742, 618, 26, 62),
          Paint()..color = const Color(0xFF57340F).withValues(alpha: a(4)));
    }

    // Boots on the floor, standing ready.
    for (final bx in const [452.0, 528.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(bx - 26, 660, 52, 96), const Radius.circular(14)),
        Paint()..color = const Color(0xFF57340F),
      );
    }
  }
}

// ── 74. When Anger Knocks ─────────────────────────────────────────────────────
// Intent: anger arrives at the door; you get to choose what you do with it.
class _AngerScenePainter extends ScenePainter {
  const _AngerScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kFloor = 640.0;

    // ANIM 1 — the hot red glow cools as the child slows down (t 0.3→1).
    final cool = _cl(0.0, 1.0, t, 0.3, 1.0);
    _sky(canvas,
        Color.lerp(const Color(0xFF7F1D1D), const Color(0xFF2C4568), cool)!,
        Color.lerp(const Color(0xFFF87171), const Color(0xFFA9C4E0), cool)!);

    canvas.drawRect(const Rect.fromLTWH(0, 200, 1000, 440),
        Paint()..color = Color.lerp(
            const Color(0xFF991B1B), const Color(0xFF3E5C86), cool)!);
    _ground(canvas, const Color(0xFF3F2A14), kFloor);

    // The door anger knocks on — closed, and staying closed.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(620, 300, 280, 340), const Radius.circular(18)),
      Paint()..color = const Color(0xFF57340F),
    );
    canvas.drawCircle(const Offset(660, 470), 16,
        Paint()..color = const Color(0xFFB08D3A));

    // ANIM 2 — three knocks flash on the door and fade (t 0→0.5).
    final knock = _cl(0.0, 1.0, t, 0.0, 0.5);
    for (var i = 0; i < 3; i++) {
      final k = ((knock * 3) - i).clamp(0.0, 1.0);
      if (k <= 0) continue;
      canvas.drawCircle(
        Offset(760, 380.0 + i * 70), 26 * k,
        Paint()
          ..color = const Color(0xFFFBBF24).withValues(alpha: (1 - cool) * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
    }

    // The child, breathing and choosing. Arms come down as they calm.
    // § 4.2 limb rule at t=0: 214°/116° = 98° ✓; at t=1: 130°/56° = 74° ✓
    _person(canvas, 300, 782, 300, const Color(0xFF8D5524), const Color(0xFF0F766E),
        armAngleL: _lerp(214, 130, cool), armAngleR: _lerp(116, 56, cool));

    // ANIM 3 — a calm breath, drawn as widening rings (t 0.5→1).
    final breath = _cl(0.0, 1.0, t, 0.5, 1.0);
    if (breath > 0) {
      for (var i = 1; i <= 3; i++) {
        canvas.drawCircle(
          const Offset(300, 430), 40.0 * i * breath,
          Paint()
            ..color = const Color(0xFFBFDBFE)
                .withValues(alpha: 0.30 * breath / i)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5,
        );
      }
    }
  }
}

// ── 75. When I Feel Alone ─────────────────────────────────────────────────────
// Intent: the room is big and dark and God is right there in it with them.
class _AloneScenePainter extends ScenePainter {
  const _AloneScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kFloor = 646.0;
    _sky(canvas, const Color(0xFF0B1220), const Color(0xFF1E293B));
    canvas.drawRect(const Rect.fromLTWH(0, 200, 1000, 446),
        Paint()..color = const Color(0xFF111C2E));
    _ground(canvas, const Color(0xFF0A1120), kFloor);

    // A window with a few stars — so t=0 is a composed picture (§ 4.5)
    canvas.drawRect(const Rect.fromLTWH(700, 280, 210, 220),
        Paint()..color = const Color(0xFF1E3A5F));
    for (final s in const [[750.0, 330.0], [830.0, 380.0], [786.0, 440.0]]) {
      _dot(canvas, s[0], s[1], 4, 0.85);
    }

    // ANIM 1 — a warm presence grows around the child (t 0.2→1).
    final near = _cl(0.0, 1.0, t, 0.2, 1.0);
    canvas.drawCircle(
      const Offset(360, 560), 380,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFDE68A).withValues(alpha: 0.42 * near),
          const Color(0xFFFDE68A).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(360, 560), radius: 380)),
    );

    // The child, sitting with knees up. 274 ≥ 220 ✓
    _kneeling(canvas, 360, 782, 274, const Color(0xFF8D5524), const Color(0xFF6D28D9));

    // ANIM 2 — a small lamp beside them brightens (t 0→0.6).
    final lamp = _cl(0.3, 1.0, t, 0.0, 0.6);
    canvas.drawOval(
      const Rect.fromLTWH(560, 742, 96, 40),
      Paint()..color = const Color(0xFF78350F),
    );
    canvas.drawCircle(
      const Offset(608, 728), 48,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.95 * lamp),
          const Color(0xFFF59E0B).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(608, 728), radius: 48)),
    );
  }
}

// ── 76. When Life Feels Unfair ────────────────────────────────────────────────
// Intent: uneven scales, and a child taking the unfair thing to God instead of
//         carrying it. Lament is allowed.
class _UnfairScenePainter extends ScenePainter {
  const _UnfairScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kGround = 656.0;
    _sky(canvas, const Color(0xFF3F3A66), const Color(0xFF8B94C4));
    _ground(canvas, const Color(0xFF2A2647), kGround);

    // The scales — the beam tilts, which is the whole point.
    canvas.drawRect(const Rect.fromLTWH(492, 300, 18, 356),
        Paint()..color = const Color(0xFF57534E));

    // ANIM 1 — the beam tips further out of true (t 0→0.5), then levels as it
    // is handed over (t 0.55→1).
    final tip = _cl(0.0, 1.0, t, 0.0, 0.5);
    final level = _cl(0.0, 1.0, t, 0.55, 1.0);
    final angle = _lerp(_lerp(0.0, 0.30, tip), 0.0, level);
    canvas.save();
    canvas.translate(500, 310);
    canvas.rotate(angle);
    canvas.drawRect(const Rect.fromLTRB(-220, -8, 220, 8),
        Paint()..color = const Color(0xFF78716C));
    for (final px in const [-200.0, 200.0]) {
      canvas.drawLine(Offset(px, 8), Offset(px, 70),
          Paint()
            ..color = const Color(0xFF78716C)
            ..strokeWidth = 5);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(px, 84), width: 130, height: 74),
        0, math.pi, false,
        Paint()..color = const Color(0xFF9CA3AF),
      );
    }
    canvas.restore();

    // ANIM 2 — light opens above once it is handed to God (t 0.5→1).
    if (level > 0) {
      canvas.drawCircle(
        const Offset(500, 250), 300,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFDE68A).withValues(alpha: 0.40 * level),
            const Color(0xFFFDE68A).withValues(alpha: 0.0),
          ]).createShader(Rect.fromCircle(center: const Offset(500, 250), radius: 300)),
      );
    }

    // The child, arms up, handing it over.
    // § 4.2 limb rule: 238°/302° = 64° ✓
    _person(canvas, 210, 782, 288, const Color(0xFF8D5524), const Color(0xFF1D4ED8),
        armAngleL: 238, armAngleR: 302);
  }
}

// ── 77. When Someone We Love Dies ─────────────────────────────────────────────
// Intent: Jesus crying at a friend's grave. Tenderness, honesty, nothing
//         frightening — and one break of gold in the cloud (§ safety).
class _GriefScenePainter extends ScenePainter {
  const _GriefScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kGround = 636.0;

    // ANIM 1 — one warm break opens in a grey sky. It never becomes bright; the
    // story does not pretend the sadness has gone.
    final hope = _cl(0.0, 1.0, t, 0.35, 1.0);
    _sky(canvas,
        Color.lerp(const Color(0xFF64748B), const Color(0xFF7C8CA8), hope)!,
        Color.lerp(const Color(0xFFCBD5E1), const Color(0xFFFDE68A), hope * 0.7)!);

    // A soft break, not a shape. A flat-alpha oval this large read as a beige
    // blob pasted on the sky (§ 4.4 — always a RadialGradient for glows).
    canvas.drawCircle(
      const Offset(720, 330), 300,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.46 * hope),
          const Color(0xFFFEF3C7).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(720, 330), radius: 300)),
    );

    _ground(canvas, const Color(0xFF4B5563), kGround);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 960), width: 1700, height: 700),
      Paint()..color = const Color(0xFF3F4652),
    );

    // The tomb — plain, closed, off to one side. Not the subject.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(700, 430, 250, 210), const Radius.circular(16)),
      Paint()..color = const Color(0xFF6B7280),
    );
    canvas.drawCircle(const Offset(790, 560), 74,
        Paint()..color = const Color(0xFF4B5563));

    // Jesus, standing, one hand on the stone, the other down. Weeping.
    // § 4.2 limb rule: 44°/128° = 84° ✓
    _person(canvas, 470, 782, 300, const Color(0xFF8D5524), const Color(0xFFE7E5E4),
        armAngleL: 128, armAngleR: 44);

    // ANIM 2 — tears. Small, slow, and deliberately present at t=1.
    // ONE tear, on the cheek and just clear of the face silhouette.
    // Head centre is y=524, r=42, so the head occupies y 482–566: a tear placed
    // inside that band lands on the eyes (pale blue irises) and a pair placed
    // just under it reads as a blue collar. A single teardrop tracking down the
    // side of the face is the only version that reads as crying.
    final tears = _cl(0.0, 1.0, t, 0.25, 1.0);
    if (tears > 0) {
      final ty = _lerp(516.0, 604.0, tears);
      canvas.drawPath(
        Path()
          ..moveTo(436, ty - 15)
          ..quadraticBezierTo(447, ty, 436, ty + 12)
          ..quadraticBezierTo(425, ty, 436, ty - 15)
          ..close(),
        Paint()..color = const Color(0xFF60A5FA),
      );
    }

    // ANIM 3 — a friend kneels beside, and a hand rests on her (t 0.45→1).
    final beside = _cl(0.0, 1.0, t, 0.45, 1.0);
    if (beside > 0) {
      canvas.saveLayer(const Rect.fromLTWH(0, 0, 1000, 1000),
          Paint()..color = Colors.white.withValues(alpha: beside));
      _kneeling(canvas, 210, 782, 250, const Color(0xFFC68642),
          const Color(0xFF6D28D9));
      canvas.restore();
    }
  }
}

// ── 78. Jesus Will Come Again ─────────────────────────────────────────────────
// Intent: they are staring up, and the angels point them back down the hill.
class _ComeAgainScenePainter extends ScenePainter {
  const _ComeAgainScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kHill = 654.0;
    _sky(canvas, const Color(0xFF0369A1), const Color(0xFFBFDBFE));
    _ground(canvas, const Color(0xFF3F6212), kHill);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 970), width: 1700, height: 700),
      Paint()..color = const Color(0xFF4D7C0F),
    );

    // A distant town at the foot of the hill — where the job is.
    for (final b in const [[70.0, 60.0], [140.0, 44.0], [196.0, 52.0]]) {
      canvas.drawRect(Rect.fromLTWH(b[0], kHill - b[1], 54, b[1]),
          Paint()..color = const Color(0xFFB08D6A));
    }

    // ANIM 1 — a bright break opens in the cloud where He went (t 0→0.6).
    final open = _cl(0.15, 1.0, t, 0.0, 0.6);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(560, 280), width: 460, height: 200),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      const Offset(560, 280), 210 * open,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.85 * open),
          const Color(0xFFFEF3C7).withValues(alpha: 0.0),
        ]).createShader(
            Rect.fromCircle(center: const Offset(560, 280), radius: 210 * open)),
    );

    // The watchers. § 4.2 limb rule: 232°/104° = 128° ✓
    _person(canvas, 320, 782, 272, const Color(0xFF8D5524), const Color(0xFF1D4ED8),
        armAngleL: 232, armAngleR: 104);
    _person(canvas, 470, 782, 258, const Color(0xFFC68642), const Color(0xFF0F766E),
        armAngleL: 228, armAngleR: 108);

    // ANIM 2 — two angels appear and gesture back down the hill (t 0.4→1).
    final ang = _cl(0.0, 1.0, t, 0.4, 1.0);
    for (final ax in const [720.0, 858.0]) {
      if (ang <= 0) break;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(ax - 34, 596, 68, 186), const Radius.circular(28)),
        Paint()..color = Colors.white.withValues(alpha: 0.95 * ang),
      );
      canvas.drawCircle(Offset(ax, 574), 33,
          Paint()..color = const Color(0xFFFDE68A).withValues(alpha: ang));
      // The pointing arm — aimed downhill, at the town, not at the sky.
      canvas.drawLine(
        Offset(ax - 30, 650),
        Offset(ax - 30 - 70 * ang, 700),
        Paint()
          ..color = const Color(0xFFFDE68A).withValues(alpha: ang)
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

// ── 79. The King Judges and Raises the Dead ───────────────────────────────────
// Intent: a throne of warm light and an open book. The Judge is the one who
//         died for us, so this reads as justice and relief, never as terror.
class _JudgeScenePainter extends ScenePainter {
  const _JudgeScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kPlain = 668.0;

    // ANIM 1 — dawn comes up behind the throne (t 0→0.6).
    final dawn = _cl(0.15, 1.0, t, 0.0, 0.6);
    _sky(canvas,
        Color.lerp(const Color(0xFF1E3A5F), const Color(0xFF1D4ED8), dawn)!,
        Color.lerp(const Color(0xFF64748B), const Color(0xFFFDE68A), dawn)!);

    canvas.drawCircle(
      const Offset(500, 380), 400,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFDE68A).withValues(alpha: 0.55 * dawn),
          const Color(0xFFFDE68A).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(500, 380), radius: 400)),
    );

    _ground(canvas, const Color(0xFF1E293B), kPlain);

    // The throne, simple and central.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(390, 300, 220, 368), const Radius.circular(26)),
      Paint()..color = const Color(0xFFB08D3A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(414, 330, 172, 250), const Radius.circular(18)),
      Paint()..color = const Color(0xFFFDE68A),
    );

    // ANIM 2 — the great book opens in front of it (t 0.3→0.85).
    final book = _cl(0.0, 1.0, t, 0.3, 0.85);
    if (book > 0) {
      final w = 260.0 * book;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(500 - w / 2, 600, w, 74), const Radius.circular(10)),
        Paint()..color = const Color(0xFFF5F5F4),
      );
      canvas.drawLine(const Offset(500, 600), const Offset(500, 674),
          Paint()
            ..color = const Color(0xFFCBD5E1)
            ..strokeWidth = 5);
    }

    // ANIM 3 — people rise, standing quietly in the light (t 0.45→1).
    final rise = _cl(0.0, 1.0, t, 0.45, 1.0);
    for (var i = 0; i < 6; i++) {
      final a = ((rise * 6) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final cx = i < 3 ? 90.0 + i * 86 : 700.0 + (i - 3) * 86;
      final h = 150.0 * a;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 26, 782 - h, 52, h), const Radius.circular(22)),
        Paint()..color = const Color(0xFF475569).withValues(alpha: a),
      );
      if (a > 0.5) {
        canvas.drawCircle(Offset(cx, 782 - h - 18), 24,
            Paint()..color = const Color(0xFF8D5524).withValues(alpha: a));
      }
    }
  }
}

// ── 80. God Makes Everything New ──────────────────────────────────────────────
// Intent: the story ends where it began — a world being made, and this one can
//         never be spoiled. Capstone of all eighty stories.
class _EverythingNewScenePainter extends ScenePainter {
  const _EverythingNewScenePainter(super.t);

  @override
  void paintScene(Canvas canvas) {
    const kGround = 622.0;

    // ANIM 1 — the whole world warms and greens (t 0→0.6).
    final made = _cl(0.1, 1.0, t, 0.0, 0.6);
    _sky(canvas,
        Color.lerp(const Color(0xFF334155), const Color(0xFF0891B2), made)!,
        Color.lerp(const Color(0xFF94A3B8), const Color(0xFFFEF3C7), made)!);

    _ground(canvas,
        Color.lerp(const Color(0xFF44403C), const Color(0xFF15803D), made)!, kGround);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 950), width: 1700, height: 700),
      Paint()..color = Color.lerp(
          const Color(0xFF3F3A35), const Color(0xFF22C55E), made)!,
    );

    // The city, with its gates standing open.
    canvas.drawRect(const Rect.fromLTWH(330, 330, 340, 292),
        Paint()..color = const Color(0xFFFDE68A));
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(Rect.fromLTWH(338 + i * 86, 296, 52, 36),
          Paint()..color = const Color(0xFFFBBF24));
    }
    // The open gate — a dark opening that reads as a way IN.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(452, 470, 96, 152), const Radius.circular(46)),
      Paint()..color = const Color(0xFF0E7490),
    );

    // ANIM 2 — the river runs out from the city (t 0.3→1).
    final river = _cl(0.0, 1.0, t, 0.3, 1.0);
    if (river > 0) {
      canvas.drawPath(
        Path()
          ..moveTo(470, 622)
          ..lineTo(530, 622)
          ..lineTo(500 + 300 * river, 800)
          ..lineTo(500 - 300 * river, 800)
          ..close(),
        Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.92),
      );
    }

    // ANIM 3 — fruit trees line the river (t 0.5→1).
    final trees = _cl(0.0, 1.0, t, 0.5, 1.0);
    for (var i = 0; i < 4; i++) {
      final a = ((trees * 4) - i).clamp(0.0, 1.0);
      if (a <= 0) continue;
      for (final side in const [-1.0, 1.0]) {
        final tx = 500 + side * (220.0 + i * 88);
        canvas.drawRect(Rect.fromLTWH(tx - 11, 660, 22, 100),
            Paint()..color = const Color(0xFF57340F).withValues(alpha: a));
        canvas.drawCircle(Offset(tx, 640), 54 * a,
            Paint()..color = const Color(0xFF16A34A));
        canvas.drawCircle(Offset(tx - 18, 630), 11 * a,
            Paint()..color = const Color(0xFFDC2626));
        canvas.drawCircle(Offset(tx + 20, 648), 11 * a,
            Paint()..color = const Color(0xFFDC2626));
      }
    }

    // Light coming from the city itself — no sun needed there.
    canvas.drawCircle(
      const Offset(500, 420), 380,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.40 * made),
          const Color(0xFFFEF3C7).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: const Offset(500, 420), radius: 380)),
    );
  }
}
