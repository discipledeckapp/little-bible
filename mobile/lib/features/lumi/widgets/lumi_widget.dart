import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/narration_provider.dart';
import '../../../core/services/parent_gate_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../lumi_state.dart';
import 'package:go_router/go_router.dart';

export '../lumi_state.dart';

// ─── Lumi widget ──────────────────────────────────────────────────────────────
// Tapping speaks a greeting. Long-pressing (2s) triggers the parent gate.

class LumiWidget extends ConsumerStatefulWidget {
  const LumiWidget({
    super.key,
    this.state = LumiState.idle,
    this.size = 120,
    this.onTap,
  });

  final LumiState state;
  final double size;
  final VoidCallback? onTap;

  @override
  ConsumerState<LumiWidget> createState() => _LumiWidgetState();
}

class _LumiWidgetState extends ConsumerState<LumiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkCtrl;
  Timer? _blinkTimer;
  bool _blinkStarted = false;
  bool _blinking = false;
  bool _longPressActive = false;
  double _longPressProgress = 0;

  // Parallel lists: Edge TTS asset key + on-device TTS fallback text.
  static const _tapKeys = [
    'lumi_open_story',
    'lumi_idle_prompt',
    'lumi_welcome_back',
    'lumi_games_intro',
    'lumi_colour_intro',
  ];
  static const _tapFallbacks = [
    'Shall we open a story?',
    'Tap a story to begin!',
    'Welcome back! Which story shall we read?',
    'Time to play! Which game do you want?',
    'Now let\'s colour the picture!',
  ];

  @override
  void initState() {
    super.initState();
    // A duration is required for forward() to run at all.
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addListener(() {
        if (_blinkCtrl.value > 0.45 && _blinkCtrl.value < 0.55 && !_blinking) {
          setState(() => _blinking = true);
        } else if ((_blinkCtrl.value < 0.45 || _blinkCtrl.value > 0.55) && _blinking) {
          setState(() => _blinking = false);
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Blinking is motion, so honour the reduce-motion setting — and it needs
    // MediaQuery, which is not available in initState.
    if (_blinkStarted || MediaQuery.of(context).disableAnimations) return;
    _blinkStarted = true;
    _scheduleBlink();
  }

  void _scheduleBlink() async {
    if (!mounted) return;
    _blinkTimer = Timer(
      Duration(seconds: 3 + math.Random().nextInt(4)),
      () async {
        if (!mounted) return;
        await _blinkCtrl.forward(from: 0);
        if (!mounted) return;
        _blinkCtrl.reset();
        _scheduleBlink();
      },
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _blinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    final i = math.Random().nextInt(_tapKeys.length);
    await ref.read(narrationServiceProvider)
        .speakUi(_tapKeys[i], fallback: _tapFallbacks[i]);
  }

  Future<void> _onLongPress() async {
    setState(() { _longPressActive = false; _longPressProgress = 0; });
    final gate = ref.read(parentGateServiceProvider);
    final ok = await gate.showGate(context);
    if (ok && mounted) context.go(AppRoutes.parentHub);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget face = CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _LumiFacePainter(
        state: widget.state,
        blinking: _blinking,
      ),
    );

    // The halo is painted inside _LumiFacePainter so it stays centred on the
    // body rather than on the widget box — the body no longer fills the canvas,
    // because the sprout needs headroom above it.
    Widget body = SizedBox(
      width: widget.size,
      height: widget.size,
      child: face,
    );

    // Idle bob animation
    if (!reduceMotion) {
      body = body
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -8, duration: 1800.ms, curve: Curves.easeInOut)
          .then()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.04, 1.04),
            duration: 900.ms,
            curve: Curves.easeInOut,
          );
    }

    return GestureDetector(
      onTap: _onTap,
      onLongPressStart: (_) {
        setState(() { _longPressActive = true; });
      },
      onLongPressEnd: (_) {
        setState(() { _longPressActive = false; _longPressProgress = 0; });
      },
      onLongPress: _onLongPress,
      child: Semantics(
        label: 'Lumi — tap to hear a greeting, hold for parent settings',
        button: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            body,
            if (_longPressActive)
              SizedBox(
                width: widget.size + 16,
                height: widget.size + 16,
                child: CircularProgressIndicator(
                  value: _longPressProgress,
                  color: AppColours.lumiGold,
                  strokeWidth: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Lumi face painter ────────────────────────────────────────────────────────
//
// Lumi is a seed of light — see docs/LittleBible_Brand_Identity.md.
//
// Geometry is a direct port of mobile/assets/brand/lumi-app-icon.svg, expressed
// as fractions of the canvas so the in-app character and the app icon are the
// same character. If you change one, change both.
//
// The body is a TEARDROP, not a circle. That is load-bearing: a gold sphere
// with green leaves on top reads as a clementine no matter what else you do to
// it. Tapering to a point where the sprout emerges is what makes it a seed.
//
// Canvas layout (fractions of width/height):
//   body    y 0.311 → 0.861, widest 0.262 either side of centre at y 0.640
//   sprout  y 0.165 → 0.332 — this is why the body sits low in the box
//   halo    centre (0.500, 0.596) radius 0.410

class _LumiFacePainter extends CustomPainter {
  const _LumiFacePainter({required this.state, required this.blinking});

  final LumiState state;
  final bool blinking;

  // Sprout greens — shared with the icon vector.
  static const _stemGreen  = Color(0xFF10B981);
  static const _leafLight  = Color(0xFF4ADE80);
  static const _leafGreen  = Color(0xFF34D399);
  static const _bodyMid    = Color(0xFFFBBF24);
  static const _bodyLight  = Color(0xFFFDE68A);
  static const _bodyEdge   = Color(0xFFD97706);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // `r` is the feature scale: the body's half-width at its widest. Every
    // feature is sized relative to it, so Lumi stays in proportion at any size.
    final r = w * 0.262;
    final cx = w * 0.5;
    final cy = h * 0.640; // the widest point — the face sits here

    _drawHalo(canvas, size);
    _drawSprout(canvas, size);

    // ── Body ──────────────────────────────────────────────────────────────────
    final bodyPath = _teardropPath(size);
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: const [_bodyLight, AppColours.lumiGold, _bodyEdge],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(bodyPath.getBounds());
    canvas.drawPath(bodyPath, bodyPaint);

    // Highlight — flat ellipses in the taper, kept clear of the eyes so their
    // edge never cuts across the face.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.454, h * 0.527),
        width: w * 0.234,
        height: h * 0.160,
      ),
      Paint()..color = _bodyMid.withValues(alpha: 0.75),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.422, h * 0.493),
        width: w * 0.121,
        height: h * 0.082,
      ),
      Paint()..color = _bodyLight.withValues(alpha: 0.70),
    );

    // ── Eyes ──────────────────────────────────────────────────────────────────
    // Solid dark discs: the highest-contrast reading of a face, and identical
    // to the icon so Lumi is recognisable from the home screen at any size.
    final eyeR = r * 0.179;
    _drawEye(canvas, Offset(cx - r * 0.403, cy), eyeR);
    _drawEye(canvas, Offset(cx + r * 0.403, cy), eyeR);

    // ── Mouth ─────────────────────────────────────────────────────────────────
    final mouthY = cy + r * 0.437;
    final mouthPaint = Paint()
      ..color = AppColours.deepEarth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = r * 0.112;

    switch (state) {
      case LumiState.idle:
      case LumiState.wonder:
        _drawSmile(canvas, cx, mouthY, r * 0.410, r * 0.157, mouthPaint);
      case LumiState.celebrate:
        _drawSmile(canvas, cx, mouthY - r * 0.06, r * 0.50, r * 0.25, mouthPaint);
        final blush = Paint()..color = AppColours.coral.withValues(alpha: 0.28);
        canvas.drawCircle(Offset(cx - r * 0.62, mouthY - r * 0.16), r * 0.22, blush);
        canvas.drawCircle(Offset(cx + r * 0.62, mouthY - r * 0.16), r * 0.22, blush);
      case LumiState.thinking:
        canvas.drawLine(
          Offset(cx - r * 0.26, mouthY),
          Offset(cx + r * 0.26, mouthY + r * 0.09),
          mouthPaint,
        );
        canvas.drawCircle(
          Offset(cx + r * 0.80, cy - r * 0.66),
          r * 0.09,
          Paint()..color = AppColours.deepEarth.withValues(alpha: 0.6),
        );
      case LumiState.encourage:
        _drawSmile(canvas, cx + r * 0.06, mouthY, r * 0.36, r * 0.12, mouthPaint);
    }
  }

  // ── Body silhouette ─────────────────────────────────────────────────────────
  // Teardrop: a soft point at the top where the sprout emerges, widening to a
  // round base. Control points mirror lumi-app-icon.svg exactly.
  Path _teardropPath(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.500, h * 0.3105)
      ..cubicTo(w * 0.6230, h * 0.3633, w * 0.7617, h * 0.5039, w * 0.7617, h * 0.6396)
      ..cubicTo(w * 0.7617, h * 0.7695, w * 0.6445, h * 0.8613, w * 0.500, h * 0.8613)
      ..cubicTo(w * 0.3555, h * 0.8613, w * 0.2383, h * 0.7695, w * 0.2383, h * 0.6396)
      ..cubicTo(w * 0.2383, h * 0.5039, w * 0.3770, h * 0.3633, w * 0.500, h * 0.3105)
      ..close();
  }

  // ── Halo ────────────────────────────────────────────────────────────────────
  // A radial gradient rather than a blurred shadow: it downscales cleanly and
  // costs no save-layer.
  void _drawHalo(Canvas canvas, Size size) {
    final centre = Offset(size.width * 0.5, size.height * 0.596);
    final radius = size.width * 0.410;
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColours.lumiGold.withValues(alpha: 0.24),
            AppColours.lumiGold.withValues(alpha: 0.0),
          ],
          stops: const [0.5, 1.0],
        ).createShader(Rect.fromCircle(center: centre, radius: radius)),
    );
  }

  // ── Sprout ──────────────────────────────────────────────────────────────────
  // Two symmetric cotyledon leaves on a short stem. Deliberately NOT a single
  // side-stalk — that silhouette reads as fruit rather than a seed.
  void _drawSprout(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stem — runs from above the leaves down into the body, which draws over it.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.484, h * 0.2246, w * 0.516, h * 0.332),
        Radius.circular(w * 0.016),
      ),
      Paint()..color = _stemGreen,
    );

    _drawLeaf(canvas, Offset(w * 0.3848, h * 0.2324), w * 0.109, h * 0.0537,
        -math.pi / 6, _leafLight);
    _drawLeaf(canvas, Offset(w * 0.6152, h * 0.2324), w * 0.109, h * 0.0537,
        math.pi / 6, _leafGreen);
  }

  void _drawLeaf(Canvas canvas, Offset centre, double rx, double ry,
      double rotation, Color colour) {
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(rotation);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      Paint()..color = colour,
    );
    canvas.restore();
  }

  // ── Face parts ──────────────────────────────────────────────────────────────
  void _drawEye(Canvas canvas, Offset centre, double radius) {
    // Blinking squishes the disc to a slit rather than hiding it, so the eye
    // never disappears mid-frame.
    final eyePaint = Paint()..color = AppColours.deepEarth;
    final height = blinking ? radius * 0.18 : radius;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: centre,
          width: radius * 2,
          height: height * 2,
        ),
        Radius.circular(radius),
      ),
      eyePaint,
    );

    if (blinking) return;

    canvas.drawCircle(
      Offset(centre.dx + radius * 0.3125, centre.dy - radius * 0.333),
      radius * 0.333,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
  }

  void _drawSmile(Canvas canvas, double cx, double cy, double halfW, double depth,
      Paint paint) {
    final path = Path()
      ..moveTo(cx - halfW, cy)
      ..quadraticBezierTo(cx, cy + depth * 2, cx + halfW, cy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LumiFacePainter old) =>
      old.state != state || old.blinking != blinking;
}
