import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/bible_content_loader.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lumiCtrl;
  late final AnimationController _titleCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _bubblesCtrl;

  late final Animation<double> _lumiScale;
  late final Animation<double> _lumiOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _taglineOpacity;
  Timer? _startTimer;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();

    _lumiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _bubblesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _lumiScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lumiCtrl, curve: Curves.elasticOut),
    );
    _lumiOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _lumiCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut),
    );

    _startTimer = Timer(
      const Duration(milliseconds: 200),
      _playSequence,
    );
  }

  Future<void> _playSequence() async {
    try {
      await _lumiCtrl.forward();
      await _titleCtrl.forward();
      await _taglineCtrl.forward();
      if (!mounted) return;
      // Seed Bible content after animations complete; non-blocking if already seeded.
      await ref.read(bibleContentLoaderProvider).seed();
      if (!mounted) return;
      _navigateTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) context.go('/');
      });
    } on TickerCanceled {
      // Expected when a test or lifecycle change disposes the splash screen.
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _navigateTimer?.cancel();
    _lumiCtrl.dispose();
    _titleCtrl.dispose();
    _taglineCtrl.dispose();
    _bubblesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.cream,
      body: Stack(
        children: [
          // Ambient drifting bubbles
          AnimatedBuilder(
            animation: _bubblesCtrl,
            builder: (_, _) => CustomPaint(
              painter: _SplashBubblePainter(_bubblesCtrl.value),
              size: MediaQuery.of(context).size,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lumi face — elastic pop-in
                ScaleTransition(
                  scale: _lumiScale,
                  child: FadeTransition(
                    opacity: _lumiOpacity,
                    child: const _SplashLumi(),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleOpacity,
                    child: Text(
                      'Little Bible',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColours.lumiGold,
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: Text(
                    "God's Word for Little Hearts",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.textMuted,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lumi on the splash (larger, glowing) ────────────────────────────────────

class _SplashLumi extends StatelessWidget {
  const _SplashLumi();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColours.lumiGold.withValues(alpha: 0.35),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _LumiSplashPainter(),
      ),
    );
  }
}

class _LumiSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Body — warm amber radial gradient
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: const [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFD97706)],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );

    // Top sheen
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - r * 0.2, cy - r * 0.5), width: r * 0.6, height: r * 0.3),
      Paint()..color = Colors.white.withValues(alpha: 0.28)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Eyes
    final eyeY = cy - r * 0.12;
    final eyeRadius = r * 0.13;
    final pupilR = eyeRadius * 0.52;
    for (final ex in [cx - r * 0.28, cx + r * 0.28]) {
      canvas.drawCircle(Offset(ex, eyeY), eyeRadius, Paint()..color = const Color(0xFF292524));
      canvas.drawCircle(Offset(ex + pupilR * 0.3, eyeY - pupilR * 0.3), pupilR * 0.4, Paint()..color = Colors.white.withValues(alpha: 0.7));
    }

    // Smile
    final smilePath = Path()
      ..moveTo(cx - r * 0.22, cy + r * 0.14)
      ..quadraticBezierTo(cx, cy + r * 0.34, cx + r * 0.22, cy + r * 0.14);
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF92400E)
        ..strokeWidth = r * 0.06
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Leaf on top
    final leafPaint = Paint()..color = const Color(0xFF16A34A);
    final leaf1 = Path()
      ..moveTo(cx, cy - r * 0.85)
      ..cubicTo(cx - r * 0.15, cy - r * 1.1, cx - r * 0.3, cy - r * 0.95, cx, cy - r * 0.78);
    final leaf2 = Path()
      ..moveTo(cx, cy - r * 0.85)
      ..cubicTo(cx + r * 0.15, cy - r * 1.1, cx + r * 0.3, cy - r * 0.95, cx, cy - r * 0.78);
    canvas.drawPath(leaf1, leafPaint);
    canvas.drawPath(leaf2, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Ambient floating bubbles ─────────────────────────────────────────────────

class _SplashBubblePainter extends CustomPainter {
  _SplashBubblePainter(this.t);
  final double t;

  static final _bubbles = [
    (0.15, 0.25, 6.0, 0.0),
    (0.82, 0.18, 9.0, 0.4),
    (0.72, 0.72, 5.0, 0.7),
    (0.25, 0.78, 8.0, 0.2),
    (0.90, 0.50, 7.0, 0.9),
    (0.05, 0.55, 5.5, 0.5),
    (0.50, 0.90, 6.5, 0.3),
    (0.60, 0.12, 7.5, 0.8),
  ];

  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()..color = AppColours.lumiGold.withValues(alpha: 0.18);
    for (final (bx, by, br, phase) in _bubbles) {
      final angle = (t + phase) * 2 * pi;
      final dx = cos(angle) * 10;
      final dy = sin(angle * 1.3) * 8;
      canvas.drawCircle(
        Offset(s.width * bx + dx, s.height * by + dy),
        br,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SplashBubblePainter old) => old.t != t;
}
