import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ─── Garden widget ─────────────────────────────────────────────────────────────
//
// Maps 0-6 active days this week to 5 growth stages.
// No wilting, no streaks, no labels — ever.

class GardenWidget extends StatelessWidget {
  const GardenWidget({super.key, required this.activeDaysThisWeek});

  final int activeDaysThisWeek;

  int get _stage {
    if (activeDaysThisWeek <= 0) return 0;
    if (activeDaysThisWeek == 1) return 1;
    if (activeDaysThisWeek <= 3) return 2;
    if (activeDaysThisWeek <= 5) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 80),
      painter: _GardenPainter(stage: _stage),
    );
  }
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _GardenPainter extends CustomPainter {
  const _GardenPainter({required this.stage});
  final int stage;

  @override
  void paint(Canvas canvas, Size s) {
    _drawBackground(canvas, s);
    _drawEarth(canvas, s);
    if (stage >= 1) _drawShoot(canvas, s);
    if (stage >= 2) _drawSmallPlant(canvas, s);
    if (stage >= 3) _drawBloom(canvas, s, count: 1);
    if (stage >= 4) _drawBloom(canvas, s, count: 2);
    if (stage >= 4) _drawGlow(canvas, s);
  }

  void _drawBackground(Canvas canvas, Size s) {
    final rect = Rect.fromLTWH(0, 0, s.width, s.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD8F0FF), // soft sky
          const Color(0xFFB8E4FF),
        ],
      ).createShader(rect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)), paint);
  }

  void _drawEarth(Canvas canvas, Size s) {
    final paint = Paint()..color = const Color(0xFF92600A);
    final path = Path()
      ..moveTo(0, s.height * 0.72)
      ..quadraticBezierTo(
          s.width * 0.3, s.height * 0.65, s.width * 0.6, s.height * 0.70)
      ..quadraticBezierTo(
          s.width * 0.8, s.height * 0.73, s.width, s.height * 0.69)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(path, paint);

    // Top soil stripe (lighter)
    final topSoil = Paint()..color = const Color(0xFFAD7A1A);
    canvas.drawPath(
        Path()
          ..moveTo(0, s.height * 0.72)
          ..quadraticBezierTo(
              s.width * 0.3, s.height * 0.65, s.width * 0.6, s.height * 0.70)
          ..quadraticBezierTo(
              s.width * 0.8, s.height * 0.73, s.width, s.height * 0.69)
          ..lineTo(s.width, s.height * 0.73)
          ..quadraticBezierTo(
              s.width * 0.8, s.height * 0.77, s.width * 0.6, s.height * 0.74)
          ..quadraticBezierTo(
              s.width * 0.3, s.height * 0.69, 0, s.height * 0.76)
          ..close(),
        topSoil);

    // Small stones (stage 0 only — garden not started)
    if (stage == 0) {
      final stone = Paint()..color = const Color(0xFF9CA3AF);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(s.width * 0.25, s.height * 0.78), width: 8, height: 5),
          stone);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(s.width * 0.55, s.height * 0.76), width: 6, height: 4),
          stone);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(s.width * 0.75, s.height * 0.80), width: 9, height: 5),
          stone);
    }
  }

  void _drawShoot(Canvas canvas, Size s) {
    // Thin stem
    final stem = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = s.width * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(s.width * 0.5, s.height * 0.70),
      Offset(s.width * 0.5, s.height * 0.52),
      stem,
    );
    // Tiny leaf bud
    final bud = Paint()..color = const Color(0xFF22C55E);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * 0.5, s.height * 0.50),
            width: s.width * 0.12,
            height: s.height * 0.10),
        bud);
  }

  void _drawSmallPlant(Canvas canvas, Size s) {
    final stemPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = s.width * 0.05
      ..strokeCap = StrokeCap.round;
    // Main stem
    canvas.drawLine(
      Offset(s.width * 0.5, s.height * 0.70),
      Offset(s.width * 0.5, s.height * 0.38),
      stemPaint,
    );

    final leaf = Paint()..color = const Color(0xFF22C55E);
    // Left leaf
    _drawLeaf(canvas, s,
        base: Offset(s.width * 0.5, s.height * 0.58),
        tip: Offset(s.width * 0.28, s.height * 0.50),
        paint: leaf);
    // Right leaf
    _drawLeaf(canvas, s,
        base: Offset(s.width * 0.5, s.height * 0.50),
        tip: Offset(s.width * 0.72, s.height * 0.42),
        paint: leaf);
    // Top bud
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * 0.5, s.height * 0.35),
            width: s.width * 0.14,
            height: s.height * 0.12),
        leaf);
  }

  void _drawBloom(Canvas canvas, Size s, {required int count}) {
    final stemPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = s.width * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(s.width * 0.5, s.height * 0.70),
      Offset(s.width * 0.5, s.height * 0.30),
      stemPaint,
    );

    final leaf = Paint()..color = const Color(0xFF22C55E);
    _drawLeaf(canvas, s,
        base: Offset(s.width * 0.5, s.height * 0.58),
        tip: Offset(s.width * 0.24, s.height * 0.49),
        paint: leaf);
    _drawLeaf(canvas, s,
        base: Offset(s.width * 0.5, s.height * 0.48),
        tip: Offset(s.width * 0.75, s.height * 0.39),
        paint: leaf);

    // Primary flower at top
    _drawFlower(canvas, s, center: Offset(s.width * 0.5, s.height * 0.24));

    if (count >= 2) {
      // Second bloom on a side stem
      final stemSide = Paint()
        ..color = const Color(0xFF16A34A)
        ..strokeWidth = s.width * 0.04
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(s.width * 0.5, s.height * 0.38),
        Offset(s.width * 0.72, s.height * 0.28),
        stemSide,
      );
      _drawFlower(canvas, s,
          center: Offset(s.width * 0.76, s.height * 0.22), radius: 0.10);
    }
  }

  void _drawFlower(Canvas canvas, Size s,
      {required Offset center, double radius = 0.13}) {
    final petal = Paint()..color = AppColours.lumiGold;
    final r = s.width * radius;
    // 6 petals
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final petalCenter =
          Offset(center.dx + r * 0.6 * math.cos(angle), center.dy + r * 0.6 * math.sin(angle));
      canvas.drawOval(
        Rect.fromCenter(center: petalCenter, width: r * 0.8, height: r * 0.5),
        petal,
      );
    }
    // Centre disc
    canvas.drawCircle(
        center,
        r * 0.42,
        Paint()..color = const Color(0xFFFDE68A));
    canvas.drawCircle(
        center,
        r * 0.28,
        Paint()..color = const Color(0xFFF59E0B));
  }

  void _drawGlow(Canvas canvas, Size s) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColours.lumiGold.withValues(alpha: 0.30),
          AppColours.lumiGold.withValues(alpha: 0.0),
        ],
      ).createShader(
          Rect.fromCenter(center: Offset(s.width * 0.5, s.height * 0.24),
              width: s.width * 0.7, height: s.width * 0.7));
    canvas.drawCircle(
        Offset(s.width * 0.5, s.height * 0.24), s.width * 0.35, glow);
  }

  void _drawLeaf(Canvas canvas, Size s,
      {required Offset base, required Offset tip, required Paint paint}) {
    final path = Path();
    final mid = Offset((base.dx + tip.dx) / 2, (base.dy + tip.dy) / 2);
    final perp = Offset(-(tip.dy - base.dy), tip.dx - base.dx);
    final len = math.sqrt(perp.dx * perp.dx + perp.dy * perp.dy);
    final norm = len > 0 ? Offset(perp.dx / len, perp.dy / len) : Offset.zero;
    final ctrl = Offset(mid.dx + norm.dx * s.width * 0.1,
        mid.dy + norm.dy * s.width * 0.1);
    path
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(
          mid.dx - norm.dx * s.width * 0.02,
          mid.dy - norm.dy * s.width * 0.02,
          base.dx, base.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GardenPainter old) => old.stage != stage;
}
