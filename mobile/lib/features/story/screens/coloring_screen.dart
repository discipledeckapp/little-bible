import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';

// ─── Free-paint stroke ───────────────────────────────────────────────────────

class _Stroke {
  _Stroke({required this.color, required this.widthFraction}) : points = [];
  final Color color;
  final double widthFraction; // fraction of canvas width
  final List<Offset> points;
}

// Brush thin / medium / thick
const _kBrushFractions = [0.014, 0.034, 0.068];

// ─── Color palette ────────────────────────────────────────────────────────────

const _palette = [
  Color(0xFFFBBF24), // sunny yellow
  Color(0xFFFDE68A), // light yellow
  Color(0xFFF87171), // coral red
  Color(0xFFDC2626), // deep red
  Color(0xFF38BDF8), // sky blue
  Color(0xFF1D4ED8), // deep blue
  Color(0xFF34D399), // grass green
  Color(0xFF16A34A), // forest green
  Color(0xFFA78BFA), // lavender
  Color(0xFF7C3AED), // purple
  Color(0xFFFB923C), // orange
  Color(0xFFF472B6), // pink
  Color(0xFFEC4899), // hot pink
  Color(0xFF92400E), // brown
  Color(0xFFD4B483), // tan
  Color(0xFFFFFFFF), // white
  Color(0xFF6B7280), // grey
  Color(0xFF111827), // black
];

// Child-friendly names spoken aloud when a colour is tapped.
// Keyed by ARGB int (toARGB32()) to avoid Color map-key equality issues.
const _colourNames = <int, String>{
  0xFFFBBF24: 'Yellow',
  0xFFFDE68A: 'Light yellow',
  0xFFF87171: 'Red',
  0xFFDC2626: 'Dark red',
  0xFF38BDF8: 'Light blue',
  0xFF1D4ED8: 'Blue',
  0xFF34D399: 'Light green',
  0xFF16A34A: 'Green',
  0xFFA78BFA: 'Lavender',
  0xFF7C3AED: 'Purple',
  0xFFFB923C: 'Orange',
  0xFFF472B6: 'Pink',
  0xFFEC4899: 'Hot pink',
  0xFF92400E: 'Brown',
  0xFFD4B483: 'Tan',
  0xFFFFFFFF: 'White',
  0xFF6B7280: 'Grey',
  0xFF111827: 'Black',
};

// ─── Region data ──────────────────────────────────────────────────────────────

class _Region {
  final String id;
  final Path Function(Size) pathBuilder;

  const _Region({required this.id, required this.pathBuilder});
}

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────

class ColoringScreen extends ConsumerStatefulWidget {
  const ColoringScreen({super.key, required this.storyId});
  final String storyId;

  @override
  ConsumerState<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends ConsumerState<ColoringScreen>
    with TickerProviderStateMixin {
  Color _selectedColor = _palette[0];
  final Map<String, Color> _filled = {};
  late final List<_Region> _regions;
  final _canvasKey = GlobalKey();
  bool _sharing = false;

  // Free-paint
  final List<_Stroke> _strokes = [];
  _Stroke? _currentStroke;
  int _brushSizeIndex = 1;

  // Sparkle animation per region
  final Map<String, AnimationController> _sparkles = {};

  @override
  void initState() {
    super.initState();
    _regions = _sceneFor(widget.storyId);
  }

  @override
  void dispose() {
    for (final c in _sparkles.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTapCanvas(TapDownDetails details, Size canvasSize) {
    final pos = details.localPosition;
    // Hit-test from top region downward (last drawn = topmost)
    for (final region in _regions.reversed) {
      final path = region.pathBuilder(canvasSize);
      if (path.contains(pos)) {
        _fillRegion(region.id);
        return;
      }
    }
  }

  void _selectColour(Color c) {
    setState(() => _selectedColor = c);
    final name = _colourNames[c.toARGB32()];
    if (name != null) {
      ref.read(ttsServiceProvider).speak(name);
    }
  }

  void _fillRegion(String id) {
    if (_filled[id] == _selectedColor) return;
    setState(() => _filled[id] = _selectedColor);
    ref.read(soundServiceProvider).play(SoundEffect.colorFill);

    // Sparkle animation
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sparkles[id]?.dispose();
    _sparkles[id] = ctrl;
    ctrl.forward();
  }

  void _startStroke(Offset pos) {
    final s = _Stroke(
      color: _selectedColor,
      widthFraction: _kBrushFractions[_brushSizeIndex],
    );
    s.points.add(pos);
    setState(() {
      _strokes.add(s);
      _currentStroke = s;
    });
  }

  void _continueStroke(Offset pos) {
    if (_currentStroke == null) return;
    setState(() => _currentStroke!.points.add(pos));
  }

  void _endStroke() => _currentStroke = null;

  void _undoStroke() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  bool get _allFilled => _regions.every((r) => _filled.containsKey(r.id));

  Future<void> _sharePainting() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final tmp = await getTemporaryDirectory();
      final file = File('${tmp.path}/my_little_bible_painting.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'I coloured a Bible story! 🎨 littlebible.org',
        subject: 'My Little Bible Painting',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Colour It In!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C1917),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.undo_rounded,
                      color: _strokes.isEmpty
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFF78716C),
                    ),
                    tooltip: 'Undo',
                    onPressed: _strokes.isEmpty ? null : _undoStroke,
                  ),
                  IconButton(
                    icon: _sharing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColours.lumiGold))
                        : const Icon(Icons.ios_share_rounded, color: AppColours.lumiGold),
                    tooltip: 'Save & share painting',
                    onPressed: _sharing ? null : _sharePainting,
                  ),
                  TextButton(
                    onPressed: () => context.go('/story/${widget.storyId}/family'),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Canvas + palette ───────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  children: [
                    // Drawing canvas
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size = Size(constraints.maxWidth, constraints.maxHeight);
                          final profileAsync = ref.watch(activeProfileProvider);
                          final nickname = profileAsync.valueOrNull?.nickname ?? '';
                          return RepaintBoundary(
                            key: _canvasKey,
                            child: Column(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTapDown: (d) => _onTapCanvas(d, size),
                                    onPanStart: (d) => _startStroke(d.localPosition),
                                    onPanUpdate: (d) => _continueStroke(d.localPosition),
                                    onPanEnd: (_) => _endStroke(),
                                    child: CustomPaint(
                                      size: Size(constraints.maxWidth, constraints.maxHeight - 36),
                                      painter: _ColoringPainter(
                                        regions: _regions,
                                        filled: Map.from(_filled),
                                        sparkles: Map.fromEntries(
                                          _sparkles.entries.map(
                                            (e) => MapEntry(e.key, e.value.value),
                                          ),
                                        ),
                                        strokes: List.from(_strokes),
                                      ),
                                      child: AnimatedBuilder(
                                        animation: Listenable.merge(
                                          _sparkles.values.toList(),
                                        ),
                                        builder: (_, _) => const SizedBox.expand(),
                                      ),
                                    ),
                                  ),
                                ),
                                // Branded signature strip (included in shared image)
                                Container(
                                  height: 36,
                                  color: const Color(0xFFF0F9FF),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Row(
                                    children: [
                                      Text(
                                        nickname.isNotEmpty ? '🎨 By $nickname' : '🎨 Little Bible',
                                        style: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF78716C),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'littlebible.org',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Crayon palette sidebar
                    _CrayonPalette(
                      colors: _palette,
                      selected: _selectedColor,
                      onSelect: _selectColour,
                      brushSizeIndex: _brushSizeIndex,
                      onBrushSize: (i) => setState(() => _brushSizeIndex = i),
                    ),
                  ],
                ),
              ),
            ),

            // ── All done banner ────────────────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 400),
              crossFadeState: _allFilled
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: _AllDoneBanner(storyId: widget.storyId),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter
// ─────────────────────────────────────────────────────────────────────────────

class _ColoringPainter extends CustomPainter {
  const _ColoringPainter({
    required this.regions,
    required this.filled,
    required this.sparkles,
    required this.strokes,
  });

  final List<_Region> regions;
  final Map<String, Color> filled;
  final Map<String, double> sparkles;
  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    // White backing card with subtle shadow
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );
    canvas.drawRRect(
      card,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      card,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.clipRRect(card);

    // Draw filled regions
    for (final region in regions) {
      final path = region.pathBuilder(size);
      final color = filled[region.id] ?? Colors.white;
      canvas.drawPath(path, Paint()..color = color);

      // Sparkle overlay
      final sv = sparkles[region.id] ?? 0.0;
      if (sv > 0 && sv < 1) {
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: (1 - sv) * 0.6)
            ..blendMode = BlendMode.srcOver,
        );
      }
    }

    // Draw free-paint strokes (below outlines, above fills)
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      strokePaint.color = stroke.color;
      strokePaint.strokeWidth = size.width * stroke.widthFraction;
      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          size.width * stroke.widthFraction / 2,
          Paint()..color = stroke.color,
        );
      } else {
        final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, strokePaint);
      }
    }

    // Draw outlines (always on top so lines always show)
    final outlinePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.016
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    for (final region in regions) {
      canvas.drawPath(region.pathBuilder(size), outlinePaint);
    }
  }

  @override
  bool shouldRepaint(_ColoringPainter old) =>
      old.filled != filled || old.sparkles != sparkles || old.strokes != strokes;
}

// ─────────────────────────────────────────────────────────────────────────────
// Story scenes — 4 illustrated coloring pages
// ─────────────────────────────────────────────────────────────────────────────


List<_Region> _sceneFor(String storyId) {
  switch (storyId) {
    case 'god-made-everything':   return _creationScene();
    case 'god-made-me':           return _godMadeMeScene();
    case 'the-first-family':      return _firstFamilyScene();
    case 'the-very-sad-choice':   return _sadChoiceScene();
    case 'god-promises-a-rescuer':return _rescuerPromiseScene();
    case 'two-brothers':          return _twoBrothersScene();
    case 'the-tall-tower':        return _tallTowerScene();
    case 'god-calls-abraham':     return _abrahamCallScene();
    case 'stars-in-the-sky':      return _starsScene();
    case 'the-promised-son':      return _promisedSonScene();
    case 'god-provides-a-lamb':   return _providesLambScene();
    case 'jacob-learns-grace':    return _jacobScene();
    case 'joseph-and-his-brothers':    return _josephBrothersScene();
    case 'joseph-forgives-his-family': return _josephForgivesScene();
    case 'baby-moses-is-kept-safe':    return _babyMosesScene();
    case 'god-calls-from-the-fire':    return _burningBushScene();
    case 'let-my-people-go':      return _letMyPeopleGoScene();
    case 'the-passover-lamb':     return _passoverScene();
    case 'a-way-through-the-sea': return _throughTheSeaScene();
    case 'bread-in-the-wilderness':    return _mannaScene();
    case 'gods-good-commands':    return _commandsScene();
    case 'god-lives-with-his-people':  return _tabernacleScene();
    case 'noahs-big-boat':        return _noahScene();
    case 'noahs-rainbow-promise': return _rainbowPromiseScene();
    case 'birth-of-jesus':        return _nativityScene();
    case 'jesus-loves-children':  return _jesusScene();
    case 'david-the-shepherd-boy':return _davidScene();
    case 'daniel-and-the-lions':  return _danielScene();
    case 'jonah-and-the-big-fish':return _jonahScene();
    case 'the-lost-sheep':        return _lostSheepScene();
    case 'the-lost-son':          return _lostSonScene();
    case 'the-good-shepherd':     return _shepherdScene();
    case 'how-to-pray':           return _howToPrayScene();
    case 'the-good-neighbour':    return _goodNeighbourScene();
    case 'jesus-saves':           return _jesusSavesScene();
    default:                      return _creationScene();
  }
}

// ── Scene 1: God Made Everything ─────────────────────────────────────────────
// Sky, sun, 8 rays, cloud, grass, tree, bird

List<_Region> _creationScene() => [
      // Sky background
      _Region(
        id: 'sky',
        pathBuilder: (s) => Path()
          ..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.65)),
      ),

      // Grass
      _Region(
        id: 'grass',
        pathBuilder: (s) {
          final p = Path();
          p.moveTo(0, s.height * 0.62);
          p.quadraticBezierTo(
              s.width * 0.25, s.height * 0.55, s.width * 0.5, s.height * 0.60);
          p.quadraticBezierTo(
              s.width * 0.75, s.height * 0.65, s.width, s.height * 0.58);
          p.lineTo(s.width, s.height);
          p.lineTo(0, s.height);
          p.close();
          return p;
        },
      ),

      // Sun rays (single starburst path)
      _Region(
        id: 'rays',
        pathBuilder: (s) {
          final cx = s.width * 0.5;
          final cy = s.height * 0.28;
          final inner = s.width * 0.14;
          final outer = s.width * 0.24;
          final p = Path();
          const points = 8;
          for (int i = 0; i < points * 2; i++) {
            final angle = i * math.pi / points - math.pi / 2;
            final r = i.isEven ? outer : inner;
            final x = cx + r * math.cos(angle);
            final y = cy + r * math.sin(angle);
            if (i == 0) {
              p.moveTo(x, y);
            } else {
              p.lineTo(x, y);
            }
          }
          p.close();
          return p;
        },
      ),

      // Sun circle
      _Region(
        id: 'sun',
        pathBuilder: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.5, s.height * 0.28),
            width: s.width * 0.26,
            height: s.width * 0.26,
          )),
      ),

      // Cloud (3 rounded blobs)
      _Region(
        id: 'cloud',
        pathBuilder: (s) {
          final p = Path();
          p.addOval(Rect.fromCenter(
              center: Offset(s.width * 0.18, s.height * 0.18),
              width: s.width * 0.18, height: s.width * 0.14));
          p.addOval(Rect.fromCenter(
              center: Offset(s.width * 0.27, s.height * 0.14),
              width: s.width * 0.2, height: s.width * 0.18));
          p.addOval(Rect.fromCenter(
              center: Offset(s.width * 0.37, s.height * 0.18),
              width: s.width * 0.18, height: s.width * 0.14));
          return p;
        },
      ),

      // Tree canopy (rounded triangle)
      _Region(
        id: 'tree_top',
        pathBuilder: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.8, s.height * 0.52),
            width: s.width * 0.22,
            height: s.height * 0.22,
          )),
      ),

      // Tree trunk
      _Region(
        id: 'tree_trunk',
        pathBuilder: (s) => Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(s.width * 0.8, s.height * 0.645),
              width: s.width * 0.07,
              height: s.height * 0.09,
            ),
            const Radius.circular(4),
          )),
      ),

      // Flower stem + head at bottom left
      _Region(
        id: 'flower',
        pathBuilder: (s) {
          final p = Path();
          // petals
          for (int i = 0; i < 6; i++) {
            final angle = i * math.pi / 3;
            final cx = s.width * 0.18 + math.cos(angle) * s.width * 0.055;
            final cy = s.height * 0.77 + math.sin(angle) * s.width * 0.055;
            p.addOval(Rect.fromCenter(
              center: Offset(cx, cy),
              width: s.width * 0.065,
              height: s.width * 0.065,
            ));
          }
          // centre
          p.addOval(Rect.fromCenter(
            center: Offset(s.width * 0.18, s.height * 0.77),
            width: s.width * 0.06,
            height: s.width * 0.06,
          ));
          return p;
        },
      ),

      // Bird (simple V shape — two arcs)
      _Region(
        id: 'bird',
        pathBuilder: (s) {
          final p = Path();
          final cx = s.width * 0.72;
          final cy = s.height * 0.13;
          final r = s.width * 0.04;
          // left wing arc
          p.moveTo(cx - r * 1.4, cy);
          p.quadraticBezierTo(cx - r * 0.7, cy - r * 0.7, cx, cy);
          // right wing arc
          p.quadraticBezierTo(cx + r * 0.7, cy - r * 0.7, cx + r * 1.4, cy);
          p.lineTo(cx + r * 1.4, cy + r * 0.3);
          p.lineTo(cx, cy + r * 0.2);
          p.lineTo(cx - r * 1.4, cy + r * 0.3);
          p.close();
          return p;
        },
      ),
    ];

// ── Scene 2: Noah's Big Boat ──────────────────────────────────────────────────
// Sky, rainbow (5 arcs), clouds, water, ark hull, ark cabin, dove

List<_Region> _noahScene() => [
      // Sky
      _Region(
        id: 'sky',
        pathBuilder: (s) =>
            Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.58)),
      ),

      // Rainbow arcs (5 colors, drawn largest to smallest)
      ...List.generate(5, (i) {
        return _Region(
          id: 'rainbow_$i',
          pathBuilder: (s) {
            final cx = s.width * 0.5;
            final cy = s.height * 0.58;
            final outerR = s.width * (0.48 - i * 0.07);
            final innerR = s.width * (0.41 - i * 0.07);
            final p = Path();
            // outer arc
            p.arcTo(
              Rect.fromCenter(center: Offset(cx, cy), width: outerR * 2, height: outerR * 1.6),
              math.pi, math.pi, false,
            );
            // inner arc reversed
            p.arcTo(
              Rect.fromCenter(center: Offset(cx, cy), width: innerR * 2, height: innerR * 1.6),
              0, -math.pi, false,
            );
            p.close();
            return p;
          },
        );
      }),

      // Cloud left
      _Region(
        id: 'cloud_l',
        pathBuilder: (s) {
          final p = Path();
          for (final d in [
            [0.08, 0.1, 0.18, 0.14],
            [0.16, 0.07, 0.2, 0.17],
            [0.25, 0.1, 0.17, 0.14],
          ]) {
            p.addOval(Rect.fromCenter(
              center: Offset(s.width * d[0], s.height * d[1]),
              width: s.width * d[2],
              height: s.width * d[3],
            ));
          }
          return p;
        },
      ),

      // Cloud right
      _Region(
        id: 'cloud_r',
        pathBuilder: (s) {
          final p = Path();
          for (final d in [
            [0.75, 0.1, 0.18, 0.14],
            [0.83, 0.07, 0.2, 0.17],
            [0.92, 0.1, 0.17, 0.14],
          ]) {
            p.addOval(Rect.fromCenter(
              center: Offset(s.width * d[0], s.height * d[1]),
              width: s.width * d[2],
              height: s.width * d[3],
            ));
          }
          return p;
        },
      ),

      // Water
      _Region(
        id: 'water',
        pathBuilder: (s) {
          final p = Path();
          p.moveTo(0, s.height * 0.72);
          for (double x = 0; x <= s.width; x += s.width * 0.15) {
            p.quadraticBezierTo(
              x + s.width * 0.075, s.height * 0.68,
              x + s.width * 0.15, s.height * 0.72,
            );
          }
          p.lineTo(s.width, s.height);
          p.lineTo(0, s.height);
          p.close();
          return p;
        },
      ),

      // Ark hull (rounded trapezoid)
      _Region(
        id: 'hull',
        pathBuilder: (s) => Path()
          ..addRRect(RRect.fromRectAndCorners(
            Rect.fromLTWH(s.width * 0.1, s.height * 0.65, s.width * 0.8, s.height * 0.13),
            bottomLeft: const Radius.circular(20),
            bottomRight: const Radius.circular(20),
          )),
      ),

      // Ark cabin (rectangle)
      _Region(
        id: 'cabin',
        pathBuilder: (s) => Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(s.width * 0.25, s.height * 0.55, s.width * 0.5, s.height * 0.12),
            const Radius.circular(8),
          )),
      ),

      // Cabin roof (triangle)
      _Region(
        id: 'roof',
        pathBuilder: (s) => Path()
          ..moveTo(s.width * 0.22, s.height * 0.56)
          ..lineTo(s.width * 0.5, s.height * 0.46)
          ..lineTo(s.width * 0.78, s.height * 0.56)
          ..close(),
      ),

      // Dove
      _Region(
        id: 'dove',
        pathBuilder: (s) {
          final p = Path();
          final cx = s.width * 0.5;
          final cy = s.height * 0.35;
          final r = s.width * 0.045;
          // body oval
          p.addOval(Rect.fromCenter(
            center: Offset(cx, cy), width: r * 2.5, height: r * 1.6,
          ));
          // head
          p.addOval(Rect.fromCenter(
            center: Offset(cx - r * 0.9, cy - r * 0.5), width: r * 1.2, height: r * 1.2,
          ));
          // wing
          final wing = Path();
          wing.moveTo(cx, cy - r * 0.3);
          wing.quadraticBezierTo(cx + r * 0.3, cy - r * 1.4, cx + r * 1.5, cy - r * 0.6);
          wing.quadraticBezierTo(cx + r * 0.8, cy - r * 0.1, cx, cy - r * 0.3);
          p.addPath(wing, Offset.zero);
          return p;
        },
      ),
    ];

// ── Scene 3: Jesus Loves Children ────────────────────────────────────────────
// Warm background, big heart, 6 stars, rays, hands

List<_Region> _jesusScene() => [
      // Background
      _Region(
        id: 'background',
        pathBuilder: (s) =>
            Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height)),
      ),

      // Rays (sunburst behind heart)
      _Region(
        id: 'rays',
        pathBuilder: (s) {
          final cx = s.width * 0.5;
          final cy = s.height * 0.45;
          final p = Path();
          for (int i = 0; i < 12; i++) {
            final a = i * math.pi / 6 - math.pi / 2;
            // aNext unused — rays use fixed ±0.1 spread instead
            final inner = s.width * 0.18;
            final outer = s.width * 0.46;
            p.moveTo(cx + inner * math.cos(a), cy + inner * math.sin(a));
            p.lineTo(cx + outer * math.cos(a - 0.1), cy + outer * math.sin(a - 0.1));
            p.lineTo(cx + outer * math.cos(a + 0.1), cy + outer * math.sin(a + 0.1));
            p.close();
          }
          return p;
        },
      ),

      // Big heart
      _Region(
        id: 'heart',
        pathBuilder: (s) {
          final cx = s.width * 0.5;
          final cy = s.height * 0.45;
          final r = s.width * 0.32;
          final p = Path();
          p.moveTo(cx, cy + r * 0.5);
          p.cubicTo(cx, cy + r * 0.1, cx - r, cy + r * 0.1,
              cx - r, cy - r * 0.2);
          p.cubicTo(cx - r, cy - r * 0.6, cx - r * 0.4, cy - r * 0.8,
              cx, cy - r * 0.4);
          p.cubicTo(cx + r * 0.4, cy - r * 0.8, cx + r, cy - r * 0.6,
              cx + r, cy - r * 0.2);
          p.cubicTo(cx + r, cy + r * 0.1, cx, cy + r * 0.1, cx, cy + r * 0.5);
          p.close();
          return p;
        },
      ),

      // 6 stars around the heart
      ...List.generate(6, (i) {
        return _Region(
          id: 'star_$i',
          pathBuilder: (s) {
            final cx = s.width * 0.5;
            final cy = s.height * 0.45;
            final angle = i * math.pi / 3 + math.pi / 6;
            final dist = s.width * 0.42;
            final sx = cx + dist * math.cos(angle);
            final sy = cy + dist * math.sin(angle);
            final r = s.width * 0.055;
            final p = Path();
            for (int j = 0; j < 5; j++) {
              final a = j * 2 * math.pi / 5 - math.pi / 2;
              final bA = a + math.pi / 5;
              final x1 = sx + r * math.cos(a);
              final y1 = sy + r * math.sin(a);
              final x2 = sx + r * 0.4 * math.cos(bA);
              final y2 = sy + r * 0.4 * math.sin(bA);
              if (j == 0) {
                p.moveTo(x1, y1);
              } else {
                p.lineTo(x1, y1);
              }
              p.lineTo(x2, y2);
            }
            p.close();
            return p;
          },
        );
      }),

      // Small decorative hearts (bottom)
      _Region(
        id: 'heart_sm_l',
        pathBuilder: (s) => _heartPath(s.width * 0.22, s.height * 0.82, s.width * 0.08),
      ),
      _Region(
        id: 'heart_sm_r',
        pathBuilder: (s) => _heartPath(s.width * 0.78, s.height * 0.82, s.width * 0.08),
      ),
    ];

Path _heartPath(double cx, double cy, double r) {
  final p = Path();
  p.moveTo(cx, cy + r * 0.4);
  p.cubicTo(cx, cy + r * 0.1, cx - r, cy + r * 0.1, cx - r, cy - r * 0.15);
  p.cubicTo(cx - r, cy - r * 0.5, cx - r * 0.3, cy - r * 0.7, cx, cy - r * 0.3);
  p.cubicTo(cx + r * 0.3, cy - r * 0.7, cx + r, cy - r * 0.5, cx + r, cy - r * 0.15);
  p.cubicTo(cx + r, cy + r * 0.1, cx, cy + r * 0.1, cx, cy + r * 0.4);
  p.close();
  return p;
}

// ── Scene 4: The Good Shepherd ────────────────────────────────────────────────
// Sky, far hill, near hill, sheep body, sheep head + legs, shepherd, staff, flowers

List<_Region> _shepherdScene() => [
      // Sky
      _Region(
        id: 'sky',
        pathBuilder: (s) =>
            Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.52)),
      ),

      // Far hill (lighter green)
      _Region(
        id: 'hill_far',
        pathBuilder: (s) {
          final p = Path();
          p.moveTo(0, s.height * 0.52);
          p.quadraticBezierTo(s.width * 0.3, s.height * 0.28, s.width * 0.65, s.height * 0.52);
          p.quadraticBezierTo(s.width * 0.85, s.height * 0.62, s.width, s.height * 0.52);
          p.lineTo(s.width, s.height);
          p.lineTo(0, s.height);
          p.close();
          return p;
        },
      ),

      // Near hill (darker green)
      _Region(
        id: 'hill_near',
        pathBuilder: (s) {
          final p = Path();
          p.moveTo(0, s.height * 0.72);
          p.quadraticBezierTo(s.width * 0.25, s.height * 0.58, s.width * 0.5, s.height * 0.68);
          p.quadraticBezierTo(s.width * 0.75, s.height * 0.78, s.width, s.height * 0.68);
          p.lineTo(s.width, s.height);
          p.lineTo(0, s.height);
          p.close();
          return p;
        },
      ),

      // Shepherd robe — upper (trapezoidal, shoulder-width at top)
      _Region(
        id: 'robe_upper',
        pathBuilder: (s) {
          final p = Path();
          p.moveTo(s.width * 0.59, s.height * 0.43);
          p.lineTo(s.width * 0.57, s.height * 0.58);
          p.lineTo(s.width * 0.74, s.height * 0.58);
          p.lineTo(s.width * 0.72, s.height * 0.43);
          p.quadraticBezierTo(s.width * 0.655, s.height * 0.405, s.width * 0.59, s.height * 0.43);
          p.close();
          return p;
        },
      ),

      // Shepherd robe — lower skirt (wider, flowing)
      _Region(
        id: 'robe_lower',
        pathBuilder: (s) {
          final p = Path();
          p.moveTo(s.width * 0.57, s.height * 0.575);
          p.lineTo(s.width * 0.53, s.height * 0.73);
          p.lineTo(s.width * 0.78, s.height * 0.73);
          p.lineTo(s.width * 0.74, s.height * 0.575);
          p.close();
          return p;
        },
      ),

      // Shepherd head
      _Region(
        id: 'shepherd_head',
        pathBuilder: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.655, s.height * 0.355),
            width: s.width * 0.13,
            height: s.width * 0.14,
          )),
      ),

      // Shepherd hair / head-cloth
      _Region(
        id: 'shepherd_hair',
        pathBuilder: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.655, s.height * 0.325),
            width: s.width * 0.155,
            height: s.width * 0.10,
          )),
      ),

      // Shepherd arm (extended holding staff)
      _Region(
        id: 'shepherd_arm',
        pathBuilder: (s) {
          final p = Path();
          p.moveTo(s.width * 0.72, s.height * 0.47);
          p.quadraticBezierTo(s.width * 0.75, s.height * 0.52, s.width * 0.77, s.height * 0.54);
          p.lineTo(s.width * 0.775, s.height * 0.58);
          p.quadraticBezierTo(s.width * 0.745, s.height * 0.56, s.width * 0.715, s.height * 0.51);
          p.close();
          return p;
        },
      ),

      // Shepherd staff (crook shape)
      _Region(
        id: 'staff',
        pathBuilder: (s) {
          final p = Path();
          // vertical part
          p.addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(s.width * 0.76, s.height * 0.38, s.width * 0.025, s.height * 0.35),
            const Radius.circular(4),
          ));
          // crook (arc)
          p.addArc(
            Rect.fromCenter(
              center: Offset(s.width * 0.76, s.height * 0.38),
              width: s.width * 0.08,
              height: s.width * 0.08,
            ),
            -math.pi / 2, math.pi,
          );
          return p;
        },
      ),

      // Fluffy sheep body (3 overlapping circles)
      _Region(
        id: 'sheep_body',
        pathBuilder: (s) {
          final p = Path();
          for (final d in [
            [0.22, 0.65, 0.22],
            [0.31, 0.61, 0.23],
            [0.40, 0.65, 0.20],
          ]) {
            p.addOval(Rect.fromCenter(
              center: Offset(s.width * d[0], s.height * d[1]),
              width: s.width * d[2],
              height: s.width * d[2],
            ));
          }
          return p;
        },
      ),

      // Sheep head
      _Region(
        id: 'sheep_head',
        pathBuilder: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.14, s.height * 0.63),
            width: s.width * 0.14,
            height: s.width * 0.16,
          )),
      ),

      // Sheep legs (4 rounded rectangles)
      _Region(
        id: 'sheep_legs',
        pathBuilder: (s) {
          final p = Path();
          for (final x in [0.2, 0.28, 0.35, 0.43]) {
            p.addRRect(RRect.fromRectAndRadius(
              Rect.fromLTWH(s.width * x, s.height * 0.73, s.width * 0.04, s.height * 0.09),
              const Radius.circular(4),
            ));
          }
          return p;
        },
      ),

      // 3 small flowers in foreground
      ...List.generate(3, (i) {
        return _Region(
          id: 'flower_$i',
          pathBuilder: (s) {
            final cx = s.width * (0.1 + i * 0.38);
            final cy = s.height * 0.88;
            final r = s.width * 0.038;
            final p = Path();
            for (int j = 0; j < 5; j++) {
              final a = j * 2 * math.pi / 5 - math.pi / 2;
              p.addOval(Rect.fromCenter(
                center: Offset(cx + r * 1.1 * math.cos(a), cy + r * 1.1 * math.sin(a)),
                width: r * 1.2, height: r * 1.2,
              ));
            }
            p.addOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 1.1, height: r * 1.1));
            return p;
          },
        );
      }),
    ];

// ── Scene: God Made Me ───────────────────────────────────────────────────────
// Sky, ground, child figure, sun, cloud, flowers

List<_Region> _godMadeMeScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.62))),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.60);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.56, s.width, s.height * 0.60);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close();
        return p;
      }),
      // Sun top-right
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(center: Offset(s.width * 0.8, s.height * 0.14), width: s.width * 0.22, height: s.width * 0.22))),
      _Region(id: 'rays', pathBuilder: (s) {
        final cx = s.width * 0.8; final cy = s.height * 0.14;
        final p = Path();
        for (int i = 0; i < 8; i++) {
          final a = i * math.pi / 4 - math.pi / 8;
          p.moveTo(cx + s.width * 0.12 * math.cos(a), cy + s.width * 0.12 * math.sin(a));
          p.lineTo(cx + s.width * 0.22 * math.cos(a - 0.12), cy + s.width * 0.22 * math.sin(a - 0.12));
          p.lineTo(cx + s.width * 0.22 * math.cos(a + 0.12), cy + s.width * 0.22 * math.sin(a + 0.12));
          p.close();
        }
        return p;
      }),
      // Cloud top-left
      _Region(id: 'cloud', pathBuilder: (s) {
        final p = Path();
        for (final d in [[0.14, 0.14, 0.18],[0.22, 0.10, 0.2],[0.31, 0.14, 0.17]]) {
          p.addOval(Rect.fromCenter(center: Offset(s.width * d[0], s.height * d[1]), width: s.width * d[2], height: s.width * 0.14));
        }
        return p;
      }),
      // Child body (tunic — trapezoidal, wide shoulders)
      _Region(id: 'body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.42, s.height * 0.455);
        p.lineTo(s.width * 0.38, s.height * 0.71);
        p.lineTo(s.width * 0.62, s.height * 0.71);
        p.lineTo(s.width * 0.58, s.height * 0.455);
        p.quadraticBezierTo(s.width * 0.50, s.height * 0.430, s.width * 0.42, s.height * 0.455);
        p.close();
        return p;
      }),
      // Child head
      _Region(id: 'head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(center: Offset(s.width * 0.5, s.height * 0.36), width: s.width * 0.17, height: s.width * 0.19))),
      // Child hair
      _Region(id: 'hair', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * 0.50, s.height * 0.325),
          width: s.width * 0.19, height: s.width * 0.115))),
      // Arms outstretched
      _Region(id: 'arms', pathBuilder: (s) {
        final p = Path();
        p.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * 0.36, s.height * 0.53), width: s.width * 0.2, height: s.width * 0.04), const Radius.circular(4)));
        p.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * 0.64, s.height * 0.53), width: s.width * 0.2, height: s.width * 0.04), const Radius.circular(4)));
        return p;
      }),
      // Flowers at bottom
      ...List.generate(3, (i) => _Region(id: 'flower_$i', pathBuilder: (s) {
        final cx = s.width * (0.2 + i * 0.3); final cy = s.height * 0.84; final r = s.width * 0.04;
        final p = Path();
        for (int j = 0; j < 5; j++) {
          final a = j * 2 * math.pi / 5 - math.pi / 2;
          p.addOval(Rect.fromCenter(center: Offset(cx + r * 1.2 * math.cos(a), cy + r * 1.2 * math.sin(a)), width: r * 1.3, height: r * 1.3));
        }
        p.addOval(Rect.fromCenter(center: Offset(cx, cy), width: r, height: r));
        return p;
      })),
    ];

// ── Scene: Noah's Rainbow Promise ────────────────────────────────────────────
// Sky, 5-band rainbow, calm water, dove with olive leaf

List<_Region> _rainbowPromiseScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.72))),
      ...List.generate(5, (i) => _Region(id: 'rainbow_$i', pathBuilder: (s) {
        final cx = s.width * 0.5; final cy = s.height * 0.72;
        final oR = s.width * (0.46 - i * 0.07); final iR = s.width * (0.39 - i * 0.07);
        final p = Path();
        p.arcTo(Rect.fromCenter(center: Offset(cx, cy), width: oR * 2, height: oR * 1.5), math.pi, math.pi, false);
        p.arcTo(Rect.fromCenter(center: Offset(cx, cy), width: iR * 2, height: iR * 1.5), 0, -math.pi, false);
        p.close(); return p;
      })),
      _Region(id: 'water', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.72);
        for (double x = 0; x <= s.width; x += s.width * 0.14) {
          p.quadraticBezierTo(x + s.width * 0.07, s.height * 0.68, x + s.width * 0.14, s.height * 0.72);
        }
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      // Dove
      _Region(id: 'dove', pathBuilder: (s) {
        final p = Path(); final cx = s.width * 0.5; final cy = s.height * 0.3; final r = s.width * 0.055;
        p.addOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 2.8, height: r * 1.8));
        p.addOval(Rect.fromCenter(center: Offset(cx - r, cy - r * 0.4), width: r * 1.3, height: r * 1.3));
        final wing = Path()
          ..moveTo(cx + r * 0.2, cy - r * 0.4)
          ..quadraticBezierTo(cx + r * 0.5, cy - r * 1.8, cx + r * 1.8, cy - r * 0.8)
          ..quadraticBezierTo(cx + r, cy - r * 0.2, cx + r * 0.2, cy - r * 0.4);
        p.addPath(wing, Offset.zero); return p;
      }),
      // Olive branch
      _Region(id: 'branch', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.48, s.height * 0.33);
        p.quadraticBezierTo(s.width * 0.44, s.height * 0.38, s.width * 0.38, s.height * 0.40);
        for (int i = 0; i < 3; i++) {
          final lx = s.width * (0.46 - i * 0.04); final ly = s.height * (0.34 + i * 0.025);
          p.addOval(Rect.fromCenter(center: Offset(lx, ly), width: s.width * 0.05, height: s.width * 0.03));
        }
        return p;
      }),
    ];

// ── Scene: Birth of Jesus ─────────────────────────────────────────────────────
// Night sky, big star, manger, baby, ox, donkey

List<_Region> _nativityScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.55))),
      _Region(id: 'ground', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, s.height * 0.55, s.width, s.height * 0.45))),
      // Stars sprinkled
      ...List.generate(7, (i) {
        final positions = [[0.1,0.08],[0.25,0.05],[0.4,0.12],[0.6,0.06],[0.72,0.14],[0.85,0.08],[0.95,0.18]];
        return _Region(id: 'star_$i', pathBuilder: (s) {
          final cx = s.width * positions[i][0]; final cy = s.height * positions[i][1];
          final r = s.width * 0.03;
          final p = Path();
          for (int j = 0; j < 5; j++) {
            final a = j * 2 * math.pi / 5 - math.pi / 2;
            final b = a + math.pi / 5;
            final x1 = cx + r * math.cos(a); final y1 = cy + r * math.sin(a);
            final x2 = cx + r * 0.4 * math.cos(b); final y2 = cy + r * 0.4 * math.sin(b);
            if (j == 0) {
              p.moveTo(x1, y1);
            } else {
              p.lineTo(x1, y1);
            }
            p.lineTo(x2, y2);
          }
          p.close(); return p;
        });
      }),
      // Big star of Bethlehem
      _Region(id: 'big_star', pathBuilder: (s) {
        final cx = s.width * 0.5; final cy = s.height * 0.10; final r = s.width * 0.10;
        final p = Path();
        for (int j = 0; j < 4; j++) {
          final a = j * math.pi / 2 - math.pi / 2;
          final b = a + math.pi / 4;
          final x1 = cx + r * math.cos(a); final y1 = cy + r * math.sin(a);
          final x2 = cx + r * 0.35 * math.cos(b); final y2 = cy + r * 0.35 * math.sin(b);
          if (j == 0) {
            p.moveTo(x1, y1);
          } else {
            p.lineTo(x1, y1);
          }
          p.lineTo(x2, y2);
        }
        p.close();
        // Star rays (vertical + horizontal bars)
        p.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + r * 0.35), width: s.width * 0.02, height: r * 1.2), const Radius.circular(3)));
        return p;
      }),
      // Manger trough
      _Region(id: 'manger', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(s.width * 0.25, s.height * 0.62, s.width * 0.5, s.height * 0.14),
        bottomLeft: const Radius.circular(12), bottomRight: const Radius.circular(12)))),
      // Baby body
      _Region(id: 'baby_body', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width * 0.5, s.height * 0.645), width: s.width * 0.32, height: s.height * 0.07), const Radius.circular(10)))),
      // Baby head
      _Region(id: 'baby_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.38, s.height * 0.615), width: s.width * 0.11, height: s.width * 0.12))),
      // Ox (left)
      _Region(id: 'ox', pathBuilder: (s) {
        final p = Path();
        // body
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.18, s.height * 0.75), width: s.width * 0.28, height: s.height * 0.14));
        // head
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.08, s.height * 0.72), width: s.width * 0.13, height: s.width * 0.12));
        // legs
        for (final x in [0.1, 0.18, 0.24, 0.30]) {
          p.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width * x, s.height * 0.81, s.width * 0.04, s.height * 0.09), const Radius.circular(3)));
        }
        return p;
      }),
      // Donkey (right)
      _Region(id: 'donkey', pathBuilder: (s) {
        final p = Path();
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.82, s.height * 0.75), width: s.width * 0.28, height: s.height * 0.14));
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.92, s.height * 0.71), width: s.width * 0.14, height: s.width * 0.12));
        for (final x in [0.70, 0.76, 0.84, 0.90]) {
          p.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width * x, s.height * 0.81, s.width * 0.04, s.height * 0.09), const Radius.circular(3)));
        }
        // ears
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.895, s.height * 0.645), width: s.width * 0.04, height: s.width * 0.07));
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.935, s.height * 0.645), width: s.width * 0.04, height: s.width * 0.07));
        return p;
      }),
    ];

// ── Scene: David the Shepherd Boy ────────────────────────────────────────────
// Sky, two rolling hills, tree, sun with rays, cloud,
// David seated on rock playing harp, two sheep with detail

List<_Region> _davidScene() => [
      // Sky
      _Region(id: 'sky', pathBuilder: (s) =>
          Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.52))),

      // Far hill
      _Region(id: 'hill_back', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.52);
        p.quadraticBezierTo(s.width * 0.38, s.height * 0.28, s.width * 0.76, s.height * 0.52);
        p.lineTo(s.width, s.height * 0.50);
        p.lineTo(s.width, s.height);
        p.lineTo(0, s.height);
        p.close();
        return p;
      }),

      // Near ground
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.68);
        p.quadraticBezierTo(s.width * 0.28, s.height * 0.60, s.width * 0.58, s.height * 0.66);
        p.quadraticBezierTo(s.width * 0.80, s.height * 0.72, s.width, s.height * 0.66);
        p.lineTo(s.width, s.height);
        p.lineTo(0, s.height);
        p.close();
        return p;
      }),

      // Sun (top right)
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * 0.82, s.height * 0.12),
          width: s.width * 0.20, height: s.width * 0.20))),
      _Region(id: 'rays', pathBuilder: (s) {
        final cx = s.width * 0.82; final cy = s.height * 0.12;
        final p = Path();
        for (int i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          p.moveTo(cx + s.width * 0.12 * math.cos(a), cy + s.width * 0.12 * math.sin(a));
          p.lineTo(cx + s.width * 0.22 * math.cos(a - 0.13), cy + s.width * 0.22 * math.sin(a - 0.13));
          p.lineTo(cx + s.width * 0.22 * math.cos(a + 0.13), cy + s.width * 0.22 * math.sin(a + 0.13));
          p.close();
        }
        return p;
      }),

      // Cloud (top left)
      _Region(id: 'cloud', pathBuilder: (s) {
        final p = Path();
        for (final d in [[0.10, 0.10, 0.17],[0.18, 0.07, 0.19],[0.27, 0.10, 0.16]]) {
          p.addOval(Rect.fromCenter(
              center: Offset(s.width * d[0], s.height * d[1]),
              width: s.width * d[2], height: s.width * 0.13));
        }
        return p;
      }),

      // Tree (far left background)
      _Region(id: 'tree_canopy', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * 0.08, s.height * 0.43),
          width: s.width * 0.16, height: s.height * 0.15))),
      _Region(id: 'tree_trunk', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(s.width * 0.08, s.height * 0.545),
              width: s.width * 0.055, height: s.height * 0.09),
          const Radius.circular(4)))),

      // Rock David sits on
      _Region(id: 'rock', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(s.width * 0.50, s.height * 0.715),
              width: s.width * 0.28, height: s.height * 0.075),
          const Radius.circular(12)))),

      // David's lower robe (seated, spreading over rock)
      _Region(id: 'robe_lower', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.36, s.height * 0.625);
        p.lineTo(s.width * 0.33, s.height * 0.70);
        p.lineTo(s.width * 0.57, s.height * 0.70);
        p.lineTo(s.width * 0.54, s.height * 0.625);
        p.close();
        return p;
      }),

      // David's upper tunic / shoulders
      _Region(id: 'robe_upper', pathBuilder: (s) {
        final p = Path();
        // Slightly wider at shoulders, tapering to waist
        p.moveTo(s.width * 0.37, s.height * 0.47); // left shoulder
        p.lineTo(s.width * 0.36, s.height * 0.625);
        p.lineTo(s.width * 0.54, s.height * 0.625);
        p.lineTo(s.width * 0.54, s.height * 0.47); // right shoulder
        p.quadraticBezierTo(s.width * 0.46, s.height * 0.445, s.width * 0.37, s.height * 0.47);
        p.close();
        return p;
      }),

      // David's left arm reaching toward harp
      _Region(id: 'arm_left', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.38, s.height * 0.50);
        p.quadraticBezierTo(s.width * 0.30, s.height * 0.54, s.width * 0.23, s.height * 0.57);
        p.lineTo(s.width * 0.25, s.height * 0.615);
        p.quadraticBezierTo(s.width * 0.32, s.height * 0.585, s.width * 0.40, s.height * 0.545);
        p.close();
        return p;
      }),

      // David's right arm (holding harp column)
      _Region(id: 'arm_right', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.53, s.height * 0.50);
        p.quadraticBezierTo(s.width * 0.56, s.height * 0.535, s.width * 0.58, s.height * 0.575);
        p.lineTo(s.width * 0.56, s.height * 0.61);
        p.quadraticBezierTo(s.width * 0.54, s.height * 0.57, s.width * 0.51, s.height * 0.535);
        p.close();
        return p;
      }),

      // David's head
      _Region(id: 'head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * 0.46, s.height * 0.38),
          width: s.width * 0.155, height: s.width * 0.175))),

      // David's hair (cap of curls)
      _Region(id: 'hair', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * 0.46, s.height * 0.345),
          width: s.width * 0.175, height: s.width * 0.105))),

      // ── Harp: sound box (resonating body, left vertical pillar) ──
      _Region(id: 'harp_box', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(s.width * 0.155, s.height * 0.50, s.width * 0.065, s.height * 0.215),
          const Radius.circular(8)))),

      // Harp neck (curved top bar from box up and rightward)
      _Region(id: 'harp_neck', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.180, s.height * 0.500);
        p.quadraticBezierTo(s.width * 0.160, s.height * 0.370, s.width * 0.330, s.height * 0.330);
        p.lineTo(s.width * 0.330, s.height * 0.365);
        p.quadraticBezierTo(s.width * 0.195, s.height * 0.400, s.width * 0.215, s.height * 0.500);
        p.close();
        return p;
      }),

      // Harp column/pillar (right side, straight vertical)
      _Region(id: 'harp_pillar', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(s.width * 0.320, s.height * 0.335, s.width * 0.038, s.height * 0.380),
          const Radius.circular(5)))),

      // Harp strings (6 strings as narrow fillable bands)
      ...List.generate(6, (i) {
        return _Region(id: 'string_$i', pathBuilder: (s) {
          final t = i / 5.0;
          // top anchors travel along neck from (0.22, 0.375) to (0.33, 0.345)
          final tx = s.width * (0.220 + t * 0.110);
          final ty = s.height * (0.375 - t * 0.030);
          // bottom anchors travel along sound-box top from (0.165, 0.500) to (0.320, 0.500)
          final bx = s.width * (0.165 + t * 0.155);
          final by = s.height * 0.500;
          // width of each string band
          const bw = 0.014;
          final dx = s.width * bw * 0.5;
          final p = Path();
          p.moveTo(tx - dx, ty);
          p.lineTo(bx - dx, by);
          p.lineTo(bx + dx, by);
          p.lineTo(tx + dx, ty);
          p.close();
          return p;
        });
      }),

      // Sheep 1 — on the far hill (smaller, in distance)
      _Region(id: 'sheep_1', pathBuilder: (s) {
        final ox = s.width * 0.76; final oy = s.height * 0.44;
        final p = Path();
        for (final d in [[-0.065, 0.0, 0.095], [0.010, -0.022, 0.105], [0.085, 0.0, 0.088]]) {
          p.addOval(Rect.fromCenter(
              center: Offset(ox + s.width * d[0], oy + s.height * d[1]),
              width: s.width * d[2], height: s.width * d[2]));
        }
        p.addOval(Rect.fromCenter(
            center: Offset(ox - s.width * 0.145, oy + s.height * 0.005),
            width: s.width * 0.08, height: s.width * 0.088));
        for (final lx in [-0.055, 0.005, 0.055, 0.105]) {
          p.addRRect(RRect.fromRectAndRadius(
              Rect.fromLTWH(ox + s.width * lx, oy + s.height * 0.045,
                  s.width * 0.024, s.height * 0.050),
              const Radius.circular(3)));
        }
        return p;
      }),

      // Sheep 2 — on near ground (larger, foreground)
      _Region(id: 'sheep_2', pathBuilder: (s) {
        final ox = s.width * 0.83; final oy = s.height * 0.595;
        final p = Path();
        for (final d in [[-0.08, 0.0, 0.110], [0.010, -0.030, 0.130], [0.100, 0.0, 0.105]]) {
          p.addOval(Rect.fromCenter(
              center: Offset(ox + s.width * d[0], oy + s.height * d[1]),
              width: s.width * d[2], height: s.width * d[2]));
        }
        p.addOval(Rect.fromCenter(
            center: Offset(ox - s.width * 0.165, oy + s.height * 0.005),
            width: s.width * 0.095, height: s.width * 0.105));
        for (final lx in [-0.06, 0.00, 0.065, 0.115]) {
          p.addRRect(RRect.fromRectAndRadius(
              Rect.fromLTWH(ox + s.width * lx, oy + s.height * 0.065,
                  s.width * 0.028, s.height * 0.065),
              const Radius.circular(3)));
        }
        return p;
      }),

      // Wildflowers in foreground (3 flowers)
      ...List.generate(3, (i) => _Region(id: 'flower_$i', pathBuilder: (s) {
        final cx = s.width * (0.22 + i * 0.23); final cy = s.height * 0.845;
        final r = s.width * 0.030;
        final p = Path();
        for (int j = 0; j < 5; j++) {
          final a = j * 2 * math.pi / 5 - math.pi / 2;
          p.addOval(Rect.fromCenter(
              center: Offset(cx + r * 1.25 * math.cos(a), cy + r * 1.25 * math.sin(a)),
              width: r * 1.3, height: r * 1.3));
        }
        p.addOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 1.0, height: r * 1.0));
        return p;
      })),
    ];

// ── Scene: Daniel and the Lions ──────────────────────────────────────────────
// Dark den, Daniel kneeling in prayer, two large lions, angel glow

List<_Region> _danielScene() => [
      _Region(id: 'den', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height))),
      // Stone arch top
      _Region(id: 'arch', pathBuilder: (s) {
        final p = Path();
        p.addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.08));
        p.addArc(Rect.fromCenter(center: Offset(s.width * 0.5, s.height * 0.08), width: s.width * 0.7, height: s.height * 0.2), math.pi, math.pi);
        return p;
      }),
      // Angel glow (large circle at top center)
      _Region(id: 'angel_glow', pathBuilder: (s) {
        final p = Path();
        for (int i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          p.moveTo(s.width * 0.5 + s.width * 0.08 * math.cos(a), s.height * 0.22 + s.width * 0.08 * math.sin(a));
          p.lineTo(s.width * 0.5 + s.width * 0.22 * math.cos(a - 0.15), s.height * 0.22 + s.width * 0.22 * math.sin(a - 0.15));
          p.lineTo(s.width * 0.5 + s.width * 0.22 * math.cos(a + 0.15), s.height * 0.22 + s.width * 0.22 * math.sin(a + 0.15));
          p.close();
        }
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.5, s.height * 0.22), width: s.width * 0.18, height: s.width * 0.18));
        return p;
      }),
      // Daniel robe upper (trapezoidal)
      _Region(id: 'daniel_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.44, s.height * 0.49);
        p.lineTo(s.width * 0.41, s.height * 0.68);
        p.lineTo(s.width * 0.59, s.height * 0.68);
        p.lineTo(s.width * 0.56, s.height * 0.49);
        p.quadraticBezierTo(s.width * 0.50, s.height * 0.465, s.width * 0.44, s.height * 0.49);
        p.close();
        return p;
      }),
      // Daniel arms (reaching forward in prayer)
      _Region(id: 'daniel_arms', pathBuilder: (s) {
        final p = Path();
        // left arm
        p.moveTo(s.width * 0.44, s.height * 0.52);
        p.quadraticBezierTo(s.width * 0.40, s.height * 0.55, s.width * 0.47, s.height * 0.58);
        p.lineTo(s.width * 0.48, s.height * 0.615);
        p.quadraticBezierTo(s.width * 0.41, s.height * 0.585, s.width * 0.455, s.height * 0.555);
        p.close();
        // right arm
        p.moveTo(s.width * 0.56, s.height * 0.52);
        p.quadraticBezierTo(s.width * 0.60, s.height * 0.55, s.width * 0.53, s.height * 0.58);
        p.lineTo(s.width * 0.52, s.height * 0.615);
        p.quadraticBezierTo(s.width * 0.59, s.height * 0.585, s.width * 0.545, s.height * 0.555);
        p.close();
        return p;
      }),
      _Region(id: 'daniel_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.5, s.height * 0.42), width: s.width * 0.13, height: s.width * 0.14))),
      // Daniel hair
      _Region(id: 'daniel_hair', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * 0.50, s.height * 0.388),
          width: s.width * 0.150, height: s.width * 0.095))),
      // Hands clasped
      _Region(id: 'hands', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.5, s.height * 0.595), width: s.width * 0.10, height: s.width * 0.08))),
      // Left lion (large head + mane)
      _Region(id: 'lion_l_mane', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.18, s.height * 0.65), width: s.width * 0.34, height: s.width * 0.34))),
      _Region(id: 'lion_l_face', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.18, s.height * 0.64), width: s.width * 0.22, height: s.width * 0.22))),
      _Region(id: 'lion_l_body', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.14, s.height * 0.83), width: s.width * 0.26, height: s.height * 0.18))),
      // Right lion
      _Region(id: 'lion_r_mane', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.82, s.height * 0.65), width: s.width * 0.34, height: s.width * 0.34))),
      _Region(id: 'lion_r_face', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.82, s.height * 0.64), width: s.width * 0.22, height: s.width * 0.22))),
      _Region(id: 'lion_r_body', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.86, s.height * 0.83), width: s.width * 0.26, height: s.height * 0.18))),
    ];

// ── Scene: Jonah and the Big Fish ────────────────────────────────────────────
// Ocean, giant fish, Jonah inside, bubbles, waves

List<_Region> _jonahScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.25))),
      _Region(id: 'ocean', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.25);
        for (double x = 0; x <= s.width; x += s.width * 0.18) {
          p.quadraticBezierTo(x + s.width * 0.09, s.height * 0.20, x + s.width * 0.18, s.height * 0.25);
        }
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      // Big fish body
      _Region(id: 'fish_body', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.47, s.height * 0.60), width: s.width * 0.78, height: s.height * 0.42))),
      // Fish tail
      _Region(id: 'fish_tail', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.88, s.height * 0.55);
        p.lineTo(s.width * 1.01, s.height * 0.38);
        p.lineTo(s.width * 0.96, s.height * 0.60);
        p.lineTo(s.width * 1.01, s.height * 0.78);
        p.lineTo(s.width * 0.88, s.height * 0.65);
        p.close(); return p;
      }),
      // Fish mouth (oval opening)
      _Region(id: 'mouth', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.09, s.height * 0.60), width: s.width * 0.10, height: s.height * 0.10))),
      // Fish eye
      _Region(id: 'eye', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.18, s.height * 0.52), width: s.width * 0.07, height: s.width * 0.07))),
      // Jonah inside — seated figure (robe with shoulders visible)
      _Region(id: 'jonah_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.41, s.height * 0.505);
        p.lineTo(s.width * 0.38, s.height * 0.675);
        p.lineTo(s.width * 0.53, s.height * 0.675);
        p.lineTo(s.width * 0.50, s.height * 0.505);
        p.quadraticBezierTo(s.width * 0.455, s.height * 0.482, s.width * 0.41, s.height * 0.505);
        p.close();
        return p;
      }),
      // Jonah arms (raised in prayer)
      _Region(id: 'jonah_arms', pathBuilder: (s) {
        final p = Path();
        p.addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(s.width * 0.355, s.height * 0.52),
                width: s.width * 0.095, height: s.width * 0.030),
            const Radius.circular(4)));
        p.addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(s.width * 0.545, s.height * 0.52),
                width: s.width * 0.095, height: s.width * 0.030),
            const Radius.circular(4)));
        return p;
      }),
      _Region(id: 'jonah_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.455, s.height * 0.45), width: s.width * 0.10, height: s.width * 0.11))),
      // Jonah hair
      _Region(id: 'jonah_hair', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * 0.455, s.height * 0.418),
          width: s.width * 0.115, height: s.width * 0.072))),
      // Bubbles
      ...List.generate(5, (i) => _Region(id: 'bubble_$i', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * (0.15 + i * 0.16), s.height * (0.18 + (i % 2) * 0.04)),
        width: s.width * (0.04 + (i % 3) * 0.02), height: s.width * (0.04 + (i % 3) * 0.02))))),
    ];

// ── Scene: The Lost Sheep ─────────────────────────────────────────────────────
// Hills, shepherd with lantern, flock of sheep (left), lost sheep (right)

List<_Region> _lostSheepScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.50))),
      _Region(id: 'hill_back', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.50);
        p.quadraticBezierTo(s.width * 0.35, s.height * 0.28, s.width * 0.7, s.height * 0.50);
        p.lineTo(s.width, s.height * 0.50); p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      _Region(id: 'hill_front', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.68);
        p.quadraticBezierTo(s.width * 0.25, s.height * 0.56, s.width * 0.55, s.height * 0.66);
        p.quadraticBezierTo(s.width * 0.78, s.height * 0.74, s.width, s.height * 0.66);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      // Flock of 3 sheep (left)
      ...List.generate(3, (i) => _Region(id: 'sheep_flock_$i', pathBuilder: (s) {
        final ox = s.width * (0.10 + i * 0.10); final oy = s.height * (0.58 + i * 0.03);
        final p = Path();
        for (final d in [[-0.07, 0.0, 0.09], [0.0, -0.02, 0.10], [0.07, 0.0, 0.08]]) {
          p.addOval(Rect.fromCenter(center: Offset(ox + s.width * d[0], oy + s.height * d[1]), width: s.width * d[2], height: s.width * d[2]));
        }
        p.addOval(Rect.fromCenter(center: Offset(ox - s.width * 0.14, oy), width: s.width * 0.07, height: s.width * 0.08));
        return p;
      })),
      // Lost sheep (right, alone on far hill)
      _Region(id: 'lost_sheep', pathBuilder: (s) {
        final ox = s.width * 0.82; final oy = s.height * 0.44;
        final p = Path();
        for (final d in [[-0.07, 0.0, 0.10], [0.0, -0.025, 0.12], [0.08, 0.0, 0.09]]) {
          p.addOval(Rect.fromCenter(center: Offset(ox + s.width * d[0], oy + s.height * d[1]), width: s.width * d[2], height: s.width * d[2]));
        }
        p.addOval(Rect.fromCenter(center: Offset(ox - s.width * 0.15, oy + s.height * 0.01), width: s.width * 0.08, height: s.width * 0.09));
        return p;
      }),
      // Shepherd robe (trapezoidal — wide shoulders)
      _Region(id: 'shepherd_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.46, s.height * 0.44);
        p.lineTo(s.width * 0.43, s.height * 0.67);
        p.lineTo(s.width * 0.61, s.height * 0.67);
        p.lineTo(s.width * 0.58, s.height * 0.44);
        p.quadraticBezierTo(s.width * 0.52, s.height * 0.415, s.width * 0.46, s.height * 0.44);
        p.close();
        return p;
      }),
      _Region(id: 'shepherd_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.52, s.height * 0.37), width: s.width * 0.12, height: s.width * 0.13))),
      // Shepherd hair
      _Region(id: 'shepherd_hair', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * 0.52, s.height * 0.338),
          width: s.width * 0.138, height: s.width * 0.088))),
      // Arm holding lantern (right)
      _Region(id: 'shepherd_arm', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.57, s.height * 0.47);
        p.quadraticBezierTo(s.width * 0.61, s.height * 0.50, s.width * 0.63, s.height * 0.52);
        p.lineTo(s.width * 0.625, s.height * 0.555);
        p.quadraticBezierTo(s.width * 0.60, s.height * 0.535, s.width * 0.565, s.height * 0.505);
        p.close();
        return p;
      }),
      // Lantern
      _Region(id: 'lantern', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width * 0.62, s.height * 0.565), width: s.width * 0.07, height: s.width * 0.10), const Radius.circular(4)))),
      // Moon
      _Region(id: 'moon', pathBuilder: (s) {
        final p = Path();
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.8, s.height * 0.12), width: s.width * 0.16, height: s.width * 0.16));
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.85, s.height * 0.10), width: s.width * 0.13, height: s.width * 0.13));
        return p;
      }),
    ];

// ── Scene: The Lost Son ───────────────────────────────────────────────────────
// Road curving to horizon, father with arms out, son walking toward him, trees

List<_Region> _lostSonScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.55))),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.55);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.52, s.width, s.height * 0.55);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      // Winding road
      _Region(id: 'road', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.35, s.height * 0.55);
        p.quadraticBezierTo(s.width * 0.4, s.height * 0.56, s.width * 0.43, s.height * 0.58);
        p.lineTo(s.width * 0.65, s.height);
        p.lineTo(s.width * 0.35, s.height);
        p.quadraticBezierTo(s.width * 0.38, s.height * 0.58, s.width * 0.35, s.height * 0.55);
        p.close(); return p;
      }),
      // Father (left, arms wide open) — robe with proper shoulders
      _Region(id: 'father_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.24, s.height * 0.47);
        p.lineTo(s.width * 0.20, s.height * 0.70);
        p.lineTo(s.width * 0.40, s.height * 0.70);
        p.lineTo(s.width * 0.36, s.height * 0.47);
        p.quadraticBezierTo(s.width * 0.30, s.height * 0.445, s.width * 0.24, s.height * 0.47);
        p.close();
        return p;
      }),
      _Region(id: 'father_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.30, s.height * 0.38), width: s.width * 0.14, height: s.width * 0.16))),
      // Father hair / headwear
      _Region(id: 'father_hair', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.30, s.height * 0.348),
        width: s.width * 0.162, height: s.width * 0.10))),
      _Region(id: 'father_arms', pathBuilder: (s) {
        final p = Path();
        p.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * 0.17, s.height * 0.52), width: s.width * 0.20, height: s.width * 0.04), const Radius.circular(4)));
        p.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * 0.43, s.height * 0.52), width: s.width * 0.20, height: s.width * 0.04), const Radius.circular(4)));
        return p;
      }),
      // Son (right, walking toward father) — robe with shoulders
      _Region(id: 'son_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.63, s.height * 0.52);
        p.lineTo(s.width * 0.60, s.height * 0.72);
        p.lineTo(s.width * 0.76, s.height * 0.72);
        p.lineTo(s.width * 0.73, s.height * 0.52);
        p.quadraticBezierTo(s.width * 0.68, s.height * 0.495, s.width * 0.63, s.height * 0.52);
        p.close();
        return p;
      }),
      _Region(id: 'son_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.68, s.height * 0.43), width: s.width * 0.12, height: s.width * 0.14))),
      // Son hair
      _Region(id: 'son_hair', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.68, s.height * 0.398),
        width: s.width * 0.138, height: s.width * 0.088))),
      // Son arm (reaching toward father)
      _Region(id: 'son_arm', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.63, s.height * 0.55);
        p.quadraticBezierTo(s.width * 0.56, s.height * 0.57, s.width * 0.53, s.height * 0.60);
        p.lineTo(s.width * 0.54, s.height * 0.64);
        p.quadraticBezierTo(s.width * 0.57, s.height * 0.61, s.width * 0.645, s.height * 0.59);
        p.close();
        return p;
      }),
      // Trees (flanking road)
      ...List.generate(2, (i) => _Region(id: 'tree_$i', pathBuilder: (s) {
        final cx = s.width * (0.10 + i * 0.80);
        final p = Path();
        p.addOval(Rect.fromCenter(center: Offset(cx, s.height * 0.42), width: s.width * 0.16, height: s.height * 0.22));
        p.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, s.height * 0.57), width: s.width * 0.05, height: s.height * 0.08), const Radius.circular(3)));
        return p;
      })),
      // Sun
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(center: Offset(s.width * 0.8, s.height * 0.12), width: s.width * 0.18, height: s.width * 0.18))),
    ];

// ── Scene: How to Pray ───────────────────────────────────────────────────────
// Night room, child kneeling at bedside, moon/stars through window

List<_Region> _howToPrayScene() => [
      _Region(id: 'room', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height))),
      // Window (upper right)
      _Region(id: 'window_night', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.60, s.height * 0.06, s.width * 0.30, s.height * 0.30), const Radius.circular(6)))),
      _Region(id: 'window_frame', pathBuilder: (s) {
        final p = Path();
        // vertical bar
        p.addRect(Rect.fromLTWH(s.width * 0.74, s.height * 0.06, s.width * 0.025, s.height * 0.30));
        // horizontal bar
        p.addRect(Rect.fromLTWH(s.width * 0.60, s.height * 0.195, s.width * 0.30, s.width * 0.02));
        return p;
      }),
      // Moon through window
      _Region(id: 'moon', pathBuilder: (s) {
        final p = Path();
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.69, s.height * 0.14), width: s.width * 0.12, height: s.width * 0.12));
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.73, s.height * 0.13), width: s.width * 0.10, height: s.width * 0.10));
        return p;
      }),
      // Stars through window
      ...List.generate(3, (i) => _Region(id: 'star_$i', pathBuilder: (s) {
        final cx = s.width * (0.65 + i * 0.09); final cy = s.height * (0.28 + (i % 2) * 0.04);
        final r = s.width * 0.02; final p = Path();
        for (int j = 0; j < 5; j++) {
          final a = j * 2 * math.pi / 5 - math.pi / 2;
          final b = a + math.pi / 5;
          final x1 = cx + r * math.cos(a); final y1 = cy + r * math.sin(a);
          final x2 = cx + r * 0.4 * math.cos(b); final y2 = cy + r * 0.4 * math.sin(b);
          if (j == 0) {
            p.moveTo(x1, y1);
          } else {
            p.lineTo(x1, y1);
          }
          p.lineTo(x2, y2);
        }
        p.close(); return p;
      })),
      // Bed/nightstand
      _Region(id: 'bed', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.12, s.height * 0.60, s.width * 0.52, s.height * 0.20), const Radius.circular(8)))),
      // Child body (kneeling pyjamas — trapezoidal upper, wide lower)
      _Region(id: 'child_body_upper', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.29, s.height * 0.50);
        p.lineTo(s.width * 0.27, s.height * 0.610);
        p.lineTo(s.width * 0.43, s.height * 0.610);
        p.lineTo(s.width * 0.41, s.height * 0.50);
        p.quadraticBezierTo(s.width * 0.35, s.height * 0.478, s.width * 0.29, s.height * 0.50);
        p.close();
        return p;
      }),
      // Kneeling legs (rounded rectangle)
      _Region(id: 'child_legs', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(s.width * 0.25, s.height * 0.608, s.width * 0.20, s.height * 0.09),
          const Radius.circular(10)))),
      _Region(id: 'child_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.35, s.height * 0.42), width: s.width * 0.14, height: s.width * 0.16))),
      // Child hair
      _Region(id: 'child_hair', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * 0.35, s.height * 0.385),
          width: s.width * 0.162, height: s.width * 0.10))),
      // Clasped hands on bed edge
      _Region(id: 'hands', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.35, s.height * 0.620), width: s.width * 0.10, height: s.width * 0.07))),
    ];

// ── Scene: The Good Neighbour ─────────────────────────────────────────────────
// Winding road, person helping another, donkey, trees, warm sky

List<_Region> _goodNeighbourScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.50))),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.50);
        p.lineTo(s.width, s.height * 0.50); p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      // Road (diagonal strip)
      _Region(id: 'road', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.20, s.height * 0.50);
        p.lineTo(s.width * 0.50, s.height * 0.50);
        p.lineTo(s.width * 0.80, s.height);
        p.lineTo(s.width * 0.50, s.height);
        p.close(); return p;
      }),
      // Injured person (lying on road, horizontal)
      _Region(id: 'injured_body', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width * 0.52, s.height * 0.68), width: s.width * 0.36, height: s.height * 0.06), const Radius.circular(8)))),
      _Region(id: 'injured_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.36, s.height * 0.67), width: s.width * 0.10, height: s.width * 0.10))),
      // Good Samaritan (bending over)
      _Region(id: 'helper_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.55, s.height * 0.53);
        p.quadraticBezierTo(s.width * 0.58, s.height * 0.58, s.width * 0.52, s.height * 0.64);
        p.lineTo(s.width * 0.62, s.height * 0.67);
        p.lineTo(s.width * 0.65, s.height * 0.57);
        p.close(); return p;
      }),
      _Region(id: 'helper_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.57, s.height * 0.48), width: s.width * 0.12, height: s.width * 0.13))),
      // Donkey (right side)
      _Region(id: 'donkey', pathBuilder: (s) {
        final p = Path();
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.82, s.height * 0.64), width: s.width * 0.26, height: s.height * 0.12));
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.94, s.height * 0.60), width: s.width * 0.12, height: s.width * 0.12));
        for (final lx in [0.74, 0.80, 0.86, 0.92]) {
          p.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width * lx, s.height * 0.69, s.width * 0.035, s.height * 0.08), const Radius.circular(3)));
        }
        return p;
      }),
      // Trees flanking road
      ...List.generate(2, (i) => _Region(id: 'tree_$i', pathBuilder: (s) {
        final cx = s.width * (0.10 + i * 0.75);
        final p = Path();
        p.addOval(Rect.fromCenter(center: Offset(cx, s.height * 0.38), width: s.width * 0.18, height: s.height * 0.20));
        p.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, s.height * 0.52), width: s.width * 0.05, height: s.height * 0.08), const Radius.circular(3)));
        return p;
      })),
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(center: Offset(s.width * 0.8, s.height * 0.13), width: s.width * 0.18, height: s.width * 0.18))),
    ];

// ── Scene: Jesus Saves ────────────────────────────────────────────────────────
// Sunset sky, cross on a hill with rays, hearts below

List<_Region> _jesusSavesScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.68))),
      _Region(id: 'hill', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.78);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.44, s.width, s.height * 0.78);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      // Light rays from cross (behind)
      _Region(id: 'rays', pathBuilder: (s) {
        final cx = s.width * 0.5; final cy = s.height * 0.38;
        final p = Path();
        for (int i = 0; i < 10; i++) {
          final a = i * 2 * math.pi / 10 - math.pi / 2;
          p.moveTo(cx + s.width * 0.06 * math.cos(a), cy + s.width * 0.06 * math.sin(a));
          p.lineTo(cx + s.width * 0.50 * math.cos(a - 0.14), cy + s.width * 0.50 * math.sin(a - 0.14));
          p.lineTo(cx + s.width * 0.50 * math.cos(a + 0.14), cy + s.width * 0.50 * math.sin(a + 0.14));
          p.close();
        }
        return p;
      }),
      // Cross (vertical + horizontal bars)
      _Region(id: 'cross_v', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width * 0.50, s.height * 0.45), width: s.width * 0.08, height: s.height * 0.40), const Radius.circular(5)))),
      _Region(id: 'cross_h', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width * 0.50, s.height * 0.36), width: s.width * 0.30, height: s.width * 0.08), const Radius.circular(5)))),
      // Hearts scattered below (5 hearts)
      ...List.generate(5, (i) {
        final positions = [[0.12, 0.84], [0.28, 0.88], [0.50, 0.82], [0.70, 0.87], [0.88, 0.83]];
        return _Region(id: 'heart_$i', pathBuilder: (s) =>
            _heartPath(s.width * positions[i][0], s.height * positions[i][1], s.width * (0.06 + (i % 2) * 0.02)));
      }),
      // Sun/glow behind cross
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.50, s.height * 0.38), width: s.width * 0.18, height: s.width * 0.18))),
    ];

// ── Scene 16: The First Family with God ──────────────────────────────────────
// Sky, sun, cloud, grass, river, tree (trunk + canopy), 3 fruit, two people

List<_Region> _firstFamilyScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.62))),
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.82, s.height * 0.14), width: s.width * 0.18, height: s.width * 0.18))),
      _Region(id: 'cloud', pathBuilder: (s) {
        final p = Path();
        for (final d in [[0.14, 0.13, 0.18, 0.13], [0.24, 0.10, 0.20, 0.16], [0.34, 0.13, 0.16, 0.12]]) {
          p.addOval(Rect.fromCenter(
            center: Offset(s.width * d[0], s.height * d[1]),
            width: s.width * d[2], height: s.width * d[3]));
        }
        return p;
      }),
      _Region(id: 'grass', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.62);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.59, s.width, s.height * 0.62);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      // River of Eden winding across the garden
      _Region(id: 'river', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.70);
        p.quadraticBezierTo(s.width * 0.32, s.height * 0.66, s.width * 0.58, s.height * 0.73);
        p.quadraticBezierTo(s.width * 0.82, s.height * 0.79, s.width, s.height * 0.74);
        p.lineTo(s.width, s.height * 0.82);
        p.quadraticBezierTo(s.width * 0.78, s.height * 0.87, s.width * 0.55, s.height * 0.81);
        p.quadraticBezierTo(s.width * 0.30, s.height * 0.75, 0, s.height * 0.78);
        p.close(); return p;
      }),
      _Region(id: 'trunk', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width * 0.16, s.height * 0.52),
            width: s.width * 0.05, height: s.height * 0.24), const Radius.circular(4)))),
      _Region(id: 'canopy', pathBuilder: (s) {
        final p = Path();
        for (final d in [[0.16, 0.32, 0.26], [0.07, 0.38, 0.18], [0.26, 0.38, 0.18]]) {
          p.addOval(Rect.fromCenter(
            center: Offset(s.width * d[0], s.height * d[1]),
            width: s.width * d[2], height: s.width * d[2]));
        }
        return p;
      }),
      ...List.generate(3, (i) {
        const pos = [[0.10, 0.31], [0.21, 0.29], [0.16, 0.41]];
        return _Region(id: 'fruit_$i', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * pos[i][0], s.height * pos[i][1]),
          width: s.width * 0.05, height: s.width * 0.05)));
      }),
      // The man (left) — robe with shoulders, arm reaching right
      _Region(id: 'man_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.42, s.height * 0.51);
        p.lineTo(s.width * 0.38, s.height * 0.76);
        p.lineTo(s.width * 0.56, s.height * 0.76);
        p.lineTo(s.width * 0.52, s.height * 0.51);
        p.quadraticBezierTo(s.width * 0.47, s.height * 0.485, s.width * 0.42, s.height * 0.51);
        p.close(); return p;
      }),
      _Region(id: 'man_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.47, s.height * 0.42), width: s.width * 0.13, height: s.width * 0.15))),
      // The woman (right) — robe with shoulders, arm reaching left
      _Region(id: 'woman_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.62, s.height * 0.53);
        p.lineTo(s.width * 0.59, s.height * 0.77);
        p.lineTo(s.width * 0.76, s.height * 0.77);
        p.lineTo(s.width * 0.73, s.height * 0.53);
        p.quadraticBezierTo(s.width * 0.68, s.height * 0.505, s.width * 0.62, s.height * 0.53);
        p.close(); return p;
      }),
      _Region(id: 'woman_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.675, s.height * 0.44), width: s.width * 0.12, height: s.width * 0.14))),
      // Joined hands between them
      _Region(id: 'hands', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width * 0.57, s.height * 0.60),
            width: s.width * 0.13, height: s.width * 0.04), const Radius.circular(6)))),
    ];

// ── Scene 17: The Very Sad Choice ────────────────────────────────────────────
// Evening sky, moon, ground, tree (trunk + canopy), 3 fruit, snake, two people

List<_Region> _sadChoiceScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.64))),
      _Region(id: 'moon', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.16, s.height * 0.14), width: s.width * 0.14, height: s.width * 0.14))),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.64);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.61, s.width, s.height * 0.64);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      _Region(id: 'trunk', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width * 0.70, s.height * 0.52),
            width: s.width * 0.06, height: s.height * 0.26), const Radius.circular(4)))),
      _Region(id: 'canopy', pathBuilder: (s) {
        final p = Path();
        for (final d in [[0.70, 0.30, 0.30], [0.59, 0.37, 0.20], [0.81, 0.37, 0.20]]) {
          p.addOval(Rect.fromCenter(
            center: Offset(s.width * d[0], s.height * d[1]),
            width: s.width * d[2], height: s.width * d[2]));
        }
        return p;
      }),
      ...List.generate(3, (i) {
        const pos = [[0.62, 0.31], [0.77, 0.28], [0.70, 0.41]];
        return _Region(id: 'fruit_$i', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
          center: Offset(s.width * pos[i][0], s.height * pos[i][1]),
          width: s.width * 0.055, height: s.width * 0.055)));
      }),
      // Snake along the branch — an S-shaped ribbon
      _Region(id: 'snake', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.57, s.height * 0.455);
        p.quadraticBezierTo(s.width * 0.64, s.height * 0.425, s.width * 0.70, s.height * 0.465);
        p.quadraticBezierTo(s.width * 0.76, s.height * 0.505, s.width * 0.83, s.height * 0.465);
        p.lineTo(s.width * 0.83, s.height * 0.495);
        p.quadraticBezierTo(s.width * 0.76, s.height * 0.535, s.width * 0.70, s.height * 0.495);
        p.quadraticBezierTo(s.width * 0.64, s.height * 0.455, s.width * 0.57, s.height * 0.485);
        p.close(); return p;
      }),
      // Two people walking away toward the left
      _Region(id: 'first_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.34, s.height * 0.54);
        p.lineTo(s.width * 0.30, s.height * 0.79);
        p.lineTo(s.width * 0.48, s.height * 0.79);
        p.lineTo(s.width * 0.44, s.height * 0.54);
        p.quadraticBezierTo(s.width * 0.39, s.height * 0.515, s.width * 0.34, s.height * 0.54);
        p.close(); return p;
      }),
      _Region(id: 'first_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.39, s.height * 0.455), width: s.width * 0.13, height: s.width * 0.15))),
      _Region(id: 'second_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.15, s.height * 0.57);
        p.lineTo(s.width * 0.12, s.height * 0.80);
        p.lineTo(s.width * 0.28, s.height * 0.80);
        p.lineTo(s.width * 0.25, s.height * 0.57);
        p.quadraticBezierTo(s.width * 0.20, s.height * 0.545, s.width * 0.15, s.height * 0.57);
        p.close(); return p;
      }),
      _Region(id: 'second_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.20, s.height * 0.49), width: s.width * 0.115, height: s.width * 0.135))),
    ];

// ── Scene 18: God Promises a Rescuer ─────────────────────────────────────────
// Night sky, big promise star, 4 small stars, ground, path of light,
// garden gate (2 posts + arch), two people

List<_Region> _rescuerPromiseScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.70))),
      _Region(id: 'ground', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(0, s.height * 0.70, s.width, s.height * 0.30))),
      // Path of light spilling from the star down to the viewer
      _Region(id: 'light_path', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.64, s.height * 0.70);
        p.lineTo(s.width * 0.74, s.height * 0.70);
        p.lineTo(s.width * 0.94, s.height);
        p.lineTo(s.width * 0.44, s.height);
        p.close(); return p;
      }),
      // Big promise star (5-pointed)
      _Region(id: 'star', pathBuilder: (s) => _starPath(
          s.width * 0.69, s.height * 0.26, s.width * 0.14)),
      ...List.generate(4, (i) {
        const pos = [[0.12, 0.14], [0.30, 0.09], [0.44, 0.22], [0.90, 0.34]];
        return _Region(id: 'star_sm_$i', pathBuilder: (s) => _starPath(
            s.width * pos[i][0], s.height * pos[i][1], s.width * 0.045));
      }),
      // Garden gate — left post, right post, arch
      _Region(id: 'gate_post_l', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(
        s.width * 0.10, s.height * 0.40, s.width * 0.055, s.height * 0.30))),
      _Region(id: 'gate_post_r', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(
        s.width * 0.315, s.height * 0.40, s.width * 0.055, s.height * 0.30))),
      _Region(id: 'gate_arch', pathBuilder: (s) {
        final p = Path();
        final cx = s.width * 0.24;
        final outer = s.width * 0.135;
        final inner = s.width * 0.08;
        p.arcTo(Rect.fromCenter(center: Offset(cx, s.height * 0.40),
            width: outer * 2, height: s.height * 0.22), math.pi, math.pi, false);
        p.arcTo(Rect.fromCenter(center: Offset(cx, s.height * 0.40),
            width: inner * 2, height: s.height * 0.13), 0, -math.pi, false);
        p.close(); return p;
      }),
      // Two people leaving the garden, turned toward the star
      _Region(id: 'first_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.41, s.height * 0.58);
        p.lineTo(s.width * 0.37, s.height * 0.85);
        p.lineTo(s.width * 0.55, s.height * 0.85);
        p.lineTo(s.width * 0.51, s.height * 0.58);
        p.quadraticBezierTo(s.width * 0.46, s.height * 0.555, s.width * 0.41, s.height * 0.58);
        p.close(); return p;
      }),
      _Region(id: 'first_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.46, s.height * 0.495), width: s.width * 0.13, height: s.width * 0.15))),
      _Region(id: 'second_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.22, s.height * 0.61);
        p.lineTo(s.width * 0.19, s.height * 0.86);
        p.lineTo(s.width * 0.35, s.height * 0.86);
        p.lineTo(s.width * 0.32, s.height * 0.61);
        p.quadraticBezierTo(s.width * 0.27, s.height * 0.585, s.width * 0.22, s.height * 0.61);
        p.close(); return p;
      }),
      _Region(id: 'second_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.27, s.height * 0.535), width: s.width * 0.115, height: s.width * 0.135))),
    ];

// ── Scene 19: Two Brothers and Jealous Hearts ────────────────────────────────
// Evening sky, sun, ground, two altars, grain sheaf, lamb, two smoke trails,
// Cain standing apart

List<_Region> _twoBrothersScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.66))),
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.69, s.height * 0.13), width: s.width * 0.20, height: s.width * 0.20))),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.66);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.63, s.width, s.height * 0.66);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      // Abel's smoke — rises straight up
      _Region(id: 'smoke_up', pathBuilder: (s) {
        final p = Path();
        for (int i = 0; i < 4; i++) {
          p.addOval(Rect.fromCenter(
            center: Offset(s.width * 0.69, s.height * (0.56 - i * 0.11)),
            width: s.width * (0.05 + i * 0.022), height: s.width * (0.05 + i * 0.022)));
        }
        return p;
      }),
      // Cain's smoke — drifts sideways and stays low
      _Region(id: 'smoke_low', pathBuilder: (s) {
        final p = Path();
        for (int i = 0; i < 4; i++) {
          p.addOval(Rect.fromCenter(
            center: Offset(s.width * (0.35 - i * 0.055), s.height * (0.575 - i * 0.022)),
            width: s.width * (0.05 + i * 0.018), height: s.width * (0.05 + i * 0.018)));
        }
        return p;
      }),
      // Cain's altar (left) + its grain offering
      _Region(id: 'altar_l', pathBuilder: (s) {
        final p = Path();
        p.addRect(Rect.fromLTWH(s.width * 0.28, s.height * 0.62, s.width * 0.16, s.height * 0.11));
        p.addRect(Rect.fromLTWH(s.width * 0.26, s.height * 0.72, s.width * 0.20, s.height * 0.05));
        return p;
      }),
      _Region(id: 'grain', pathBuilder: (s) {
        final p = Path();
        for (final dx in [-0.035, 0.0, 0.035]) {
          p.addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(s.width * (0.36 + dx), s.height * 0.585),
                width: s.width * 0.022, height: s.height * 0.075),
            const Radius.circular(6)));
        }
        return p;
      }),
      // Abel's altar (right) + its lamb offering
      _Region(id: 'altar_r', pathBuilder: (s) {
        final p = Path();
        p.addRect(Rect.fromLTWH(s.width * 0.61, s.height * 0.62, s.width * 0.16, s.height * 0.11));
        p.addRect(Rect.fromLTWH(s.width * 0.59, s.height * 0.72, s.width * 0.20, s.height * 0.05));
        return p;
      }),
      _Region(id: 'lamb', pathBuilder: (s) {
        final p = Path();
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.675, s.height * 0.585),
            width: s.width * 0.12, height: s.width * 0.07));
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.735, s.height * 0.573),
            width: s.width * 0.05, height: s.width * 0.05));
        return p;
      }),
      // Cain, standing apart on the left
      _Region(id: 'cain_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.08, s.height * 0.55);
        p.lineTo(s.width * 0.04, s.height * 0.82);
        p.lineTo(s.width * 0.22, s.height * 0.82);
        p.lineTo(s.width * 0.18, s.height * 0.55);
        p.quadraticBezierTo(s.width * 0.13, s.height * 0.525, s.width * 0.08, s.height * 0.55);
        p.close(); return p;
      }),
      _Region(id: 'cain_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.13, s.height * 0.465), width: s.width * 0.13, height: s.width * 0.15))),
    ];

// ── Scene 20: The Tall Tower ─────────────────────────────────────────────────
// Sky, sun, ground, four stacked tower tiers, ramp, 3 tiny builders

List<_Region> _tallTowerScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.72))),
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.83, s.height * 0.13), width: s.width * 0.16, height: s.width * 0.16))),
      _Region(id: 'ground', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(0, s.height * 0.72, s.width, s.height * 0.28))),
      ...List.generate(4, (i) {
        const tiers = [
          [0.28, 0.62, 0.44], [0.32, 0.54, 0.36], [0.36, 0.46, 0.28], [0.40, 0.38, 0.20],
        ];
        return _Region(id: 'tier_$i', pathBuilder: (s) => Path()
          ..addRect(Rect.fromLTWH(s.width * tiers[i][0], s.height * tiers[i][1],
              s.width * tiers[i][2], s.height * 0.08)));
      }),
      _Region(id: 'ramp', pathBuilder: (s) => Path()
        ..moveTo(s.width * 0.28, s.height * 0.72)
        ..lineTo(s.width * 0.36, s.height * 0.62)
        ..lineTo(s.width * 0.42, s.height * 0.62)
        ..lineTo(s.width * 0.34, s.height * 0.72)
        ..close()),
      ...List.generate(3, (i) {
        const pos = [0.14, 0.72, 0.86];
        return _Region(id: 'builder_$i', pathBuilder: (s) {
          final p = Path();
          final cx = s.width * pos[i];
          p.addOval(Rect.fromCenter(center: Offset(cx, s.height * 0.80),
              width: s.width * 0.05, height: s.height * 0.09));
          p.addOval(Rect.fromCenter(center: Offset(cx, s.height * 0.735),
              width: s.width * 0.045, height: s.width * 0.045));
          return p;
        });
      }),
    ];

// ── Scene 21: God Calls Abraham ──────────────────────────────────────────────
// Sky, rising sun, ground, tent, tent door, Abram (body + head), 3 sheep

List<_Region> _abrahamCallScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.62))),
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.76, s.height * 0.48), width: s.width * 0.20, height: s.width * 0.20))),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.62);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.595, s.width, s.height * 0.62);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      _Region(id: 'tent', pathBuilder: (s) => Path()
        ..moveTo(s.width * 0.06, s.height * 0.64)
        ..lineTo(s.width * 0.17, s.height * 0.40)
        ..lineTo(s.width * 0.28, s.height * 0.64)
        ..close()),
      _Region(id: 'tent_door', pathBuilder: (s) => Path()
        ..moveTo(s.width * 0.14, s.height * 0.64)
        ..lineTo(s.width * 0.17, s.height * 0.51)
        ..lineTo(s.width * 0.20, s.height * 0.64)
        ..close()),
      ...List.generate(3, (i) => _Region(id: 'sheep_$i', pathBuilder: (s) {
        final p = Path();
        final cx = s.width * (0.24 + i * 0.075);
        final cy = s.height * (0.755 - i * 0.012);
        p.addOval(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.085, height: s.width * 0.055));
        p.addOval(Rect.fromCenter(center: Offset(cx + s.width * 0.038, cy - s.width * 0.022),
            width: s.width * 0.04, height: s.width * 0.04));
        return p;
      })),
      _Region(id: 'abram_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.53, s.height * 0.52);
        p.lineTo(s.width * 0.49, s.height * 0.79);
        p.lineTo(s.width * 0.67, s.height * 0.79);
        p.lineTo(s.width * 0.63, s.height * 0.52);
        p.quadraticBezierTo(s.width * 0.58, s.height * 0.495, s.width * 0.53, s.height * 0.52);
        p.close(); return p;
      }),
      _Region(id: 'abram_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.58, s.height * 0.435), width: s.width * 0.13, height: s.width * 0.15))),
      _Region(id: 'abram_arm', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width * 0.70, s.height * 0.585),
            width: s.width * 0.17, height: s.width * 0.04), const Radius.circular(6)))),
    ];

// ── Scene 22: Stars in the Sky ───────────────────────────────────────────────
// Night sky, 8 stars, ground, tent, lamp, Abram (body + head + raised arms)

List<_Region> _starsScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.72))),
      ...List.generate(8, (i) {
        const pos = [
          [0.08, 0.12], [0.24, 0.06], [0.40, 0.16], [0.56, 0.08],
          [0.72, 0.18], [0.88, 0.10], [0.16, 0.30], [0.92, 0.36],
        ];
        return _Region(id: 'star_$i', pathBuilder: (s) => _starPath(
            s.width * pos[i][0], s.height * pos[i][1], s.width * (0.04 + (i % 3) * 0.012)));
      }),
      _Region(id: 'ground', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(0, s.height * 0.72, s.width, s.height * 0.28))),
      _Region(id: 'tent', pathBuilder: (s) => Path()
        ..moveTo(s.width * 0.04, s.height * 0.74)
        ..lineTo(s.width * 0.16, s.height * 0.46)
        ..lineTo(s.width * 0.28, s.height * 0.74)
        ..close()),
      _Region(id: 'lamp', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.16, s.height * 0.665), width: s.width * 0.07, height: s.width * 0.09))),
      _Region(id: 'abram_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.51, s.height * 0.54);
        p.lineTo(s.width * 0.47, s.height * 0.80);
        p.lineTo(s.width * 0.65, s.height * 0.80);
        p.lineTo(s.width * 0.61, s.height * 0.54);
        p.quadraticBezierTo(s.width * 0.56, s.height * 0.515, s.width * 0.51, s.height * 0.54);
        p.close(); return p;
      }),
      _Region(id: 'abram_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.56, s.height * 0.455), width: s.width * 0.13, height: s.width * 0.15))),
      _Region(id: 'abram_arms', pathBuilder: (s) {
        final p = Path();
        p.addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(s.width * 0.44, s.height * 0.585),
              width: s.width * 0.16, height: s.width * 0.04), const Radius.circular(6)));
        p.addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(s.width * 0.68, s.height * 0.585),
              width: s.width * 0.16, height: s.width * 0.04), const Radius.circular(6)));
        return p;
      }),
    ];

// ── Scene 23: The Promised Son ───────────────────────────────────────────────
// Sky, ground, great tree (trunk + canopy), tent, tent door, 3 visitors, baby

List<_Region> _promisedSonScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.66))),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.66);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.635, s.width, s.height * 0.66);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      _Region(id: 'trunk', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width * 0.31, s.height * 0.53),
            width: s.width * 0.06, height: s.height * 0.26), const Radius.circular(4)))),
      _Region(id: 'canopy', pathBuilder: (s) {
        final p = Path();
        for (final d in [[0.31, 0.29, 0.34], [0.17, 0.37, 0.22], [0.45, 0.37, 0.22]]) {
          p.addOval(Rect.fromCenter(
            center: Offset(s.width * d[0], s.height * d[1]),
            width: s.width * d[2], height: s.width * d[2]));
        }
        return p;
      }),
      _Region(id: 'tent', pathBuilder: (s) => Path()
        ..moveTo(s.width * 0.70, s.height * 0.68)
        ..lineTo(s.width * 0.83, s.height * 0.44)
        ..lineTo(s.width * 0.96, s.height * 0.68)
        ..close()),
      _Region(id: 'tent_door', pathBuilder: (s) => Path()
        ..moveTo(s.width * 0.80, s.height * 0.68)
        ..lineTo(s.width * 0.83, s.height * 0.55)
        ..lineTo(s.width * 0.86, s.height * 0.68)
        ..close()),
      ...List.generate(3, (i) => _Region(id: 'visitor_$i', pathBuilder: (s) {
        final p = Path();
        final cx = s.width * (0.21 + i * 0.11);
        p.moveTo(cx - s.width * 0.035, s.height * 0.60);
        p.lineTo(cx - s.width * 0.052, s.height * 0.72);
        p.lineTo(cx + s.width * 0.052, s.height * 0.72);
        p.lineTo(cx + s.width * 0.035, s.height * 0.60);
        p.close();
        p.addOval(Rect.fromCenter(center: Offset(cx, s.height * 0.555),
            width: s.width * 0.075, height: s.width * 0.085));
        return p;
      })),
      // Isaac, the promised baby, wrapped at the tent door
      _Region(id: 'baby', pathBuilder: (s) {
        final p = Path();
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.83, s.height * 0.79),
            width: s.width * 0.10, height: s.width * 0.07));
        p.addOval(Rect.fromCenter(center: Offset(s.width * 0.875, s.height * 0.775),
            width: s.width * 0.05, height: s.width * 0.05));
        return p;
      }),
    ];

// ── Scene 24: God Provides a Lamb ────────────────────────────────────────────
// Sky, sun, mountain ground, altar, wood, thicket, ram (body + head + horn), Abraham

List<_Region> _providesLambScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.64))),
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.74, s.height * 0.14), width: s.width * 0.17, height: s.width * 0.17))),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.68);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.60, s.width, s.height * 0.68);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      _Region(id: 'altar', pathBuilder: (s) {
        final p = Path();
        p.addRect(Rect.fromLTWH(s.width * 0.17, s.height * 0.60, s.width * 0.19, s.height * 0.11));
        p.addRect(Rect.fromLTWH(s.width * 0.15, s.height * 0.70, s.width * 0.23, s.height * 0.045));
        return p;
      }),
      _Region(id: 'wood', pathBuilder: (s) {
        final p = Path();
        for (int i = 0; i < 2; i++) {
          p.addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(s.width * 0.265, s.height * (0.583 - i * 0.018)),
                width: s.width * 0.14, height: s.height * 0.014),
            const Radius.circular(5)));
        }
        return p;
      }),
      _Region(id: 'thicket', pathBuilder: (s) {
        final p = Path();
        for (final b in const [
          [0.66, 0.66, 0.70, 0.60], [0.70, 0.60, 0.76, 0.575],
          [0.76, 0.575, 0.83, 0.605], [0.83, 0.605, 0.855, 0.665],
        ]) {
          p.moveTo(s.width * b[0], s.height * b[1]);
          p.lineTo(s.width * b[2], s.height * b[3]);
          p.lineTo(s.width * b[2], s.height * b[3] + s.height * 0.014);
          p.lineTo(s.width * b[0], s.height * b[1] + s.height * 0.014);
          p.close();
        }
        return p;
      }),
      _Region(id: 'ram_body', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.748, s.height * 0.615), width: s.width * 0.155, height: s.width * 0.085))),
      _Region(id: 'ram_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.822, s.height * 0.593), width: s.width * 0.062, height: s.width * 0.062))),
      _Region(id: 'ram_horn', pathBuilder: (s) {
        final p = Path();
        final cx = s.width * 0.852;
        final cy = s.height * 0.565;
        final r = s.width * 0.038;
        p.addOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 1.7));
        p.addOval(Rect.fromCenter(center: Offset(cx, cy), width: r, height: r * 0.9));
        p.fillType = PathFillType.evenOdd;
        return p;
      }),
      _Region(id: 'abraham_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.47, s.height * 0.54);
        p.lineTo(s.width * 0.43, s.height * 0.80);
        p.lineTo(s.width * 0.61, s.height * 0.80);
        p.lineTo(s.width * 0.57, s.height * 0.54);
        p.quadraticBezierTo(s.width * 0.52, s.height * 0.515, s.width * 0.47, s.height * 0.54);
        p.close(); return p;
      }),
      _Region(id: 'abraham_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.52, s.height * 0.455), width: s.width * 0.13, height: s.width * 0.15))),
    ];

// ── Scene 25: Jacob Learns Grace ─────────────────────────────────────────────
// Night sky, 5 stars, ground, 6 stairway steps, stone pillow, Jacob (body + head)

List<_Region> _jacobScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.72))),
      ...List.generate(5, (i) {
        const pos = [[0.08, 0.12], [0.22, 0.24], [0.12, 0.38], [0.90, 0.14], [0.94, 0.34]];
        return _Region(id: 'star_$i', pathBuilder: (s) => _starPath(
            s.width * pos[i][0], s.height * pos[i][1], s.width * 0.04));
      }),
      _Region(id: 'ground', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(0, s.height * 0.72, s.width, s.height * 0.28))),
      ...List.generate(6, (i) {
        final f = i / 5.0;
        return _Region(id: 'step_$i', pathBuilder: (s) => Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(s.width * (0.56 + 0.08 * f), s.height * (0.70 - 0.48 * f)),
              width: s.width * (0.23 - 0.13 * f),
              height: s.height * 0.028),
            const Radius.circular(5))));
      }),
      _Region(id: 'pillow', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.08, s.height * 0.83, s.width * 0.10, s.height * 0.07),
        const Radius.circular(8)))),
      _Region(id: 'jacob_body', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.15, s.height * 0.80, s.width * 0.30, s.height * 0.10),
        Radius.circular(s.height * 0.05)))),
      _Region(id: 'jacob_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.17, s.height * 0.815), width: s.width * 0.095, height: s.width * 0.095))),
    ];

// ── Scene 26: Joseph and His Jealous Brothers ────────────────────────────────
// Sky, sun, sand, well rim, well mouth, 3 camels, coat, 4 coat stripes

List<_Region> _josephBrothersScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.58))),
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.20, s.height * 0.14), width: s.width * 0.16, height: s.width * 0.16))),
      _Region(id: 'sand', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.58);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.555, s.width, s.height * 0.58);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      ...List.generate(3, (i) => _Region(id: 'camel_$i', pathBuilder: (s) {
        final p = Path();
        final cx = s.width * (0.62 + i * 0.11);
        final cy = s.height * (0.545 - i * 0.008);
        p.addOval(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.08, height: s.width * 0.045));
        p.addOval(Rect.fromCenter(center: Offset(cx + s.width * 0.033, cy - s.width * 0.032),
            width: s.width * 0.03, height: s.width * 0.03));
        return p;
      })),
      _Region(id: 'well_rim', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.75, s.height * 0.755), width: s.width * 0.30, height: s.height * 0.13))),
      _Region(id: 'well_mouth', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.75, s.height * 0.765), width: s.width * 0.235, height: s.height * 0.095))),
      _Region(id: 'coat', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.15, s.height * 0.70);
        p.lineTo(s.width * 0.12, s.height * 0.76);
        p.lineTo(s.width * 0.19, s.height * 0.785);
        p.lineTo(s.width * 0.20, s.height * 0.855);
        p.lineTo(s.width * 0.42, s.height * 0.855);
        p.lineTo(s.width * 0.44, s.height * 0.785);
        p.lineTo(s.width * 0.51, s.height * 0.76);
        p.lineTo(s.width * 0.48, s.height * 0.70);
        p.lineTo(s.width * 0.38, s.height * 0.676);
        p.lineTo(s.width * 0.25, s.height * 0.676);
        p.close(); return p;
      }),
      ...List.generate(4, (i) => _Region(id: 'stripe_$i', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.212, s.height * (0.704 + i * 0.034),
            s.width * 0.202, s.height * 0.018)))),
    ];

// ── Scene 27: Joseph Forgives His Family ─────────────────────────────────────
// Warm hall, 2 columns, floor, 3 grain sacks, Joseph (body + head + open arms),
// 2 kneeling brothers

List<_Region> _josephForgivesScene() => [
      _Region(id: 'hall', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.68))),
      ...List.generate(2, (i) => _Region(id: 'column_$i', pathBuilder: (s) {
        final x = s.width * (i == 0 ? 0.05 : 0.88);
        final p = Path();
        p.addRect(Rect.fromLTWH(x, s.height * 0.15, s.width * 0.075, s.height * 0.53));
        p.addRect(Rect.fromLTWH(x - s.width * 0.016, s.height * 0.15, s.width * 0.107, s.height * 0.05));
        return p;
      })),
      _Region(id: 'floor', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(0, s.height * 0.68, s.width, s.height * 0.32))),
      ...List.generate(3, (i) => _Region(id: 'sack_$i', pathBuilder: (s) => Path()
        ..addOval(Rect.fromCenter(
          center: Offset(s.width * (0.13 + i * 0.085), s.height * 0.635),
          width: s.width * 0.10, height: s.height * 0.14)))),
      // Two brothers kneeling
      ...List.generate(2, (i) => _Region(id: 'brother_$i', pathBuilder: (s) {
        final cx = s.width * (0.24 + i * 0.15);
        final p = Path();
        p.moveTo(cx - s.width * 0.045, s.height * 0.655);
        p.lineTo(cx - s.width * 0.065, s.height * 0.80);
        p.lineTo(cx + s.width * 0.065, s.height * 0.80);
        p.lineTo(cx + s.width * 0.045, s.height * 0.655);
        p.close();
        p.addOval(Rect.fromCenter(center: Offset(cx, s.height * 0.60),
            width: s.width * 0.085, height: s.width * 0.095));
        return p;
      })),
      _Region(id: 'joseph_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.60, s.height * 0.52);
        p.lineTo(s.width * 0.56, s.height * 0.80);
        p.lineTo(s.width * 0.76, s.height * 0.80);
        p.lineTo(s.width * 0.72, s.height * 0.52);
        p.quadraticBezierTo(s.width * 0.66, s.height * 0.493, s.width * 0.60, s.height * 0.52);
        p.close(); return p;
      }),
      _Region(id: 'joseph_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.66, s.height * 0.43), width: s.width * 0.14, height: s.width * 0.16))),
      _Region(id: 'joseph_arms', pathBuilder: (s) {
        final p = Path();
        p.addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(s.width * 0.52, s.height * 0.575),
              width: s.width * 0.19, height: s.width * 0.042), const Radius.circular(6)));
        p.addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(s.width * 0.80, s.height * 0.575),
              width: s.width * 0.19, height: s.width * 0.042), const Radius.circular(6)));
        return p;
      }),
    ];

// ── Scene 28: Baby Moses Is Kept Safe ────────────────────────────────────────
// Sky, far bank, water, 6 reeds, basket, basket rim, blanket, baby head, Miriam

List<_Region> _babyMosesScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.38))),
      _Region(id: 'far_bank', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(0, s.height * 0.38, s.width, s.height * 0.07))),
      _Region(id: 'water', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(0, s.height * 0.45, s.width, s.height * 0.55))),
      ...List.generate(6, (i) {
        const pos = [0.04, 0.11, 0.18, 0.72, 0.82, 0.94];
        return _Region(id: 'reed_$i', pathBuilder: (s) {
          final x = s.width * pos[i];
          return Path()
            ..moveTo(x - s.width * 0.012, s.height * 0.74)
            ..lineTo(x, s.height * 0.44)
            ..lineTo(x + s.width * 0.012, s.height * 0.74)
            ..close();
        });
      }),
      _Region(id: 'basket', pathBuilder: (s) => Path()
        ..moveTo(s.width * 0.43, s.height * 0.60)
        ..lineTo(s.width * 0.452, s.height * 0.70)
        ..lineTo(s.width * 0.668, s.height * 0.70)
        ..lineTo(s.width * 0.69, s.height * 0.60)
        ..close()),
      _Region(id: 'basket_rim', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.414, s.height * 0.575, s.width * 0.292, s.height * 0.032),
        const Radius.circular(12)))),
      _Region(id: 'blanket', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.496, s.height * 0.545, s.width * 0.128, s.height * 0.035),
        const Radius.circular(14)))),
      _Region(id: 'baby_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.56, s.height * 0.528), width: s.width * 0.055, height: s.width * 0.055))),
      _Region(id: 'miriam_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.175, s.height * 0.545);
        p.lineTo(s.width * 0.14, s.height * 0.78);
        p.lineTo(s.width * 0.30, s.height * 0.78);
        p.lineTo(s.width * 0.265, s.height * 0.545);
        p.quadraticBezierTo(s.width * 0.22, s.height * 0.522, s.width * 0.175, s.height * 0.545);
        p.close(); return p;
      }),
      _Region(id: 'miriam_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.22, s.height * 0.465), width: s.width * 0.12, height: s.width * 0.14))),
    ];

// ── Scene 29: God Calls from the Fire ────────────────────────────────────────
// Sky, ground, 5 flames, bush canopy, bush trunk, 2 sandals, Moses (body + head)

List<_Region> _burningBushScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.60))),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.60);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.575, s.width, s.height * 0.60);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      ...List.generate(5, (i) => _Region(id: 'flame_$i', pathBuilder: (s) {
        final fx = s.width * (0.574 + i * 0.058);
        final h = s.height * (i.isEven ? 0.21 : 0.16);
        final p = Path();
        p.moveTo(fx - s.width * 0.034, s.height * 0.596);
        p.quadraticBezierTo(fx - s.width * 0.02, s.height * 0.596 - h * 0.6, fx, s.height * 0.596 - h);
        p.quadraticBezierTo(fx + s.width * 0.02, s.height * 0.596 - h * 0.6, fx + s.width * 0.034, s.height * 0.596);
        p.close(); return p;
      })),
      _Region(id: 'bush_trunk', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.676, s.height * 0.556, s.width * 0.028, s.height * 0.048))),
      _Region(id: 'bush', pathBuilder: (s) {
        final p = Path();
        for (final l in [[0.69, 0.512, 0.122], [0.612, 0.552, 0.086], [0.768, 0.552, 0.086],
                         [0.652, 0.486, 0.066], [0.73, 0.486, 0.066]]) {
          p.addOval(Rect.fromCenter(center: Offset(s.width * l[0], s.height * l[1]),
              width: s.width * l[2], height: s.width * l[2]));
        }
        return p;
      }),
      _Region(id: 'sandals', pathBuilder: (s) {
        final p = Path();
        p.addOval(Rect.fromLTWH(s.width * 0.398, s.height * 0.726, s.width * 0.062, s.height * 0.030));
        p.addOval(Rect.fromLTWH(s.width * 0.472, s.height * 0.736, s.width * 0.062, s.height * 0.030));
        return p;
      }),
      _Region(id: 'moses_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.27, s.height * 0.545);
        p.lineTo(s.width * 0.235, s.height * 0.78);
        p.lineTo(s.width * 0.40, s.height * 0.78);
        p.lineTo(s.width * 0.365, s.height * 0.545);
        p.quadraticBezierTo(s.width * 0.318, s.height * 0.52, s.width * 0.27, s.height * 0.545);
        p.close(); return p;
      }),
      _Region(id: 'moses_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.318, s.height * 0.462), width: s.width * 0.13, height: s.width * 0.15))),
    ];

// ── Scene 30: Let My People Go ───────────────────────────────────────────────
// Hall, floor, 4 columns, throne, Pharaoh head, crown, Moses (body + head), staff

List<_Region> _letMyPeopleGoScene() => [
      _Region(id: 'hall', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.66))),
      _Region(id: 'floor', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(0, s.height * 0.66, s.width, s.height * 0.34))),
      ...List.generate(4, (i) {
        const pos = [0.096, 0.356, 0.70, 0.90];
        return _Region(id: 'column_$i', pathBuilder: (s) {
          final p = Path();
          p.addRect(Rect.fromLTWH(s.width * pos[i], s.height * 0.15, s.width * 0.098, s.height * 0.51));
          p.addRect(Rect.fromLTWH(s.width * pos[i] - s.width * 0.018, s.height * 0.15,
              s.width * 0.134, s.height * 0.046));
          return p;
        });
      }),
      _Region(id: 'throne', pathBuilder: (s) {
        final p = Path();
        p.addRect(Rect.fromLTWH(s.width * 0.76, s.height * 0.56, s.width * 0.19, s.height * 0.10));
        p.addRect(Rect.fromLTWH(s.width * 0.796, s.height * 0.424, s.width * 0.118, s.height * 0.14));
        return p;
      }),
      _Region(id: 'pharaoh_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.855, s.height * 0.47), width: s.width * 0.068, height: s.width * 0.068))),
      _Region(id: 'crown', pathBuilder: (s) => Path()
        ..moveTo(s.width * 0.821, s.height * 0.442)
        ..lineTo(s.width * 0.831, s.height * 0.408)
        ..lineTo(s.width * 0.846, s.height * 0.434)
        ..lineTo(s.width * 0.861, s.height * 0.404)
        ..lineTo(s.width * 0.876, s.height * 0.434)
        ..lineTo(s.width * 0.889, s.height * 0.442)
        ..close()),
      _Region(id: 'moses_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.285, s.height * 0.53);
        p.lineTo(s.width * 0.25, s.height * 0.78);
        p.lineTo(s.width * 0.415, s.height * 0.78);
        p.lineTo(s.width * 0.38, s.height * 0.53);
        p.quadraticBezierTo(s.width * 0.332, s.height * 0.505, s.width * 0.285, s.height * 0.53);
        p.close(); return p;
      }),
      _Region(id: 'moses_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.332, s.height * 0.445), width: s.width * 0.13, height: s.width * 0.15))),
      _Region(id: 'staff', pathBuilder: (s) => Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.418, s.height * 0.396, s.width * 0.018, s.height * 0.38),
        const Radius.circular(8)))),
    ];

// ── Scene 31: The Passover Lamb ──────────────────────────────────────────────
// Night sky, street, wall, doorway light, 3 family silhouettes, 3 doorframe marks

List<_Region> _passoverScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.76))),
      _Region(id: 'street', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(0, s.height * 0.76, s.width, s.height * 0.24))),
      _Region(id: 'wall', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.12, s.height * 0.18, s.width * 0.76, s.height * 0.58))),
      _Region(id: 'doorway', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.372, s.height * 0.32, s.width * 0.256, s.height * 0.44))),
      ...List.generate(3, (i) {
        const pos = [[0.43, 0.236], [0.50, 0.262], [0.57, 0.236]];
        return _Region(id: 'family_$i', pathBuilder: (s) {
          final cx = s.width * pos[i][0];
          final h = s.height * pos[i][1];
          final p = Path();
          p.moveTo(cx - s.width * 0.030, s.height * 0.76 - h);
          p.lineTo(cx - s.width * 0.044, s.height * 0.76);
          p.lineTo(cx + s.width * 0.044, s.height * 0.76);
          p.lineTo(cx + s.width * 0.030, s.height * 0.76 - h);
          p.close();
          p.addOval(Rect.fromCenter(center: Offset(cx, s.height * 0.76 - h - s.width * 0.026),
              width: s.width * 0.052, height: s.width * 0.052));
          return p;
        });
      }),
      _Region(id: 'mark_left', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.340, s.height * 0.32, s.width * 0.034, s.height * 0.44))),
      _Region(id: 'mark_right', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.626, s.height * 0.32, s.width * 0.034, s.height * 0.44))),
      _Region(id: 'mark_top', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.340, s.height * 0.288, s.width * 0.320, s.height * 0.034))),
    ];

// ── Scene 32: A Way Through the Sea ──────────────────────────────────────────
// Sky, sea bed, 2 water walls, pillar of fire, 3 people walking through

List<_Region> _throughTheSeaScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.36))),
      _Region(id: 'seabed', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(0, s.height * 0.36, s.width, s.height * 0.64))),
      _Region(id: 'wall_left', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTRB(0, s.height * 0.13, s.width * 0.20, s.height * 0.83))),
      _Region(id: 'wall_right', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTRB(s.width * 0.80, s.height * 0.13, s.width, s.height * 0.83))),
      _Region(id: 'foam_left', pathBuilder: (s) {
        final p = Path();
        for (int i = 0; i < 3; i++) {
          p.addOval(Rect.fromCenter(center: Offset(s.width * 0.16, s.height * (0.25 + i * 0.19)),
              width: s.width * 0.13, height: s.height * 0.055));
        }
        return p;
      }),
      _Region(id: 'foam_right', pathBuilder: (s) {
        final p = Path();
        for (int i = 0; i < 3; i++) {
          p.addOval(Rect.fromCenter(center: Offset(s.width * 0.84, s.height * (0.25 + i * 0.19)),
              width: s.width * 0.13, height: s.height * 0.055));
        }
        return p;
      }),
      _Region(id: 'pillar_of_fire', pathBuilder: (s) => Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(s.width * 0.452, s.height * 0.35, s.width * 0.096, s.height * 0.48),
          const Radius.circular(14)))),
      // Three travellers, largest at the front
      ...List.generate(3, (i) {
        const cfg = [[0.50, 0.772, 0.145], [0.424, 0.64, 0.116], [0.578, 0.62, 0.112]];
        return _Region(id: 'walker_$i', pathBuilder: (s) {
          final cx = s.width * cfg[i][0];
          final fy = s.height * cfg[i][1];
          final w = s.width * cfg[i][2];
          final p = Path();
          p.moveTo(cx - w * 0.36, fy - w * 1.5);
          p.lineTo(cx - w * 0.62, fy);
          p.lineTo(cx + w * 0.62, fy);
          p.lineTo(cx + w * 0.36, fy - w * 1.5);
          p.close();
          p.addOval(Rect.fromCenter(center: Offset(cx, fy - w * 1.86),
              width: w * 0.82, height: w * 0.92));
          return p;
        });
      }),
    ];

// ── Scene 33: Bread in the Wilderness ────────────────────────────────────────
// Sky, sun, ground, 3 tents, 12 manna flakes, basket, kneeling child

List<_Region> _mannaScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.60))),
      _Region(id: 'sun', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.80, s.height * 0.58), width: s.width * 0.16, height: s.width * 0.16))),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.60);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.578, s.width, s.height * 0.60);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      ...List.generate(3, (i) {
        const pos = [0.11, 0.30, 0.90];
        return _Region(id: 'tent_$i', pathBuilder: (s) => Path()
          ..moveTo(s.width * pos[i] - s.width * 0.096, s.height * 0.616)
          ..lineTo(s.width * pos[i], s.height * 0.47)
          ..lineTo(s.width * pos[i] + s.width * 0.096, s.height * 0.616)
          ..close());
      }),
      ...List.generate(4, (row) => _Region(id: 'manna_$row', pathBuilder: (s) {
        final p = Path();
        final y = s.height * (0.66 + row * 0.065);
        final r = s.width * (0.014 + row * 0.004);
        for (int i = 0; i < 7; i++) {
          final x = s.width * (0.06 + i * 0.145) + (row.isEven ? 0 : s.width * 0.07);
          p.addOval(Rect.fromCenter(center: Offset(x, y), width: r * 2.4, height: r * 1.5));
        }
        return p;
      })),
      _Region(id: 'child_body', pathBuilder: (s) {
        final p = Path();
        p.moveTo(s.width * 0.435, s.height * 0.655);
        p.lineTo(s.width * 0.41, s.height * 0.80);
        p.lineTo(s.width * 0.55, s.height * 0.80);
        p.lineTo(s.width * 0.525, s.height * 0.655);
        p.close(); return p;
      }),
      _Region(id: 'child_head', pathBuilder: (s) => Path()..addOval(Rect.fromCenter(
        center: Offset(s.width * 0.48, s.height * 0.60), width: s.width * 0.10, height: s.width * 0.11))),
      _Region(id: 'basket', pathBuilder: (s) => Path()
        ..moveTo(s.width * 0.636, s.height * 0.70)
        ..lineTo(s.width * 0.652, s.height * 0.776)
        ..lineTo(s.width * 0.76, s.height * 0.776)
        ..lineTo(s.width * 0.776, s.height * 0.70)
        ..close()),
    ];

// ── Scene 34: God's Good Commands ────────────────────────────────────────────
// Sky, cloud, mountain ledge, 4 camp tents, 2 tablets, 5 writing lines

List<_Region> _commandsScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.62))),
      _Region(id: 'cloud', pathBuilder: (s) {
        final p = Path();
        for (final d in [[0.50, 0.20, 0.30], [0.36, 0.25, 0.20], [0.64, 0.25, 0.20]]) {
          p.addOval(Rect.fromCenter(center: Offset(s.width * d[0], s.height * d[1]),
              width: s.width * d[2], height: s.width * d[2] * 0.7));
        }
        return p;
      }),
      _Region(id: 'ledge', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.62);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.60, s.width, s.height * 0.62);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      ...List.generate(4, (i) {
        const pos = [0.09, 0.19, 0.83, 0.93];
        return _Region(id: 'camp_$i', pathBuilder: (s) => Path()
          ..moveTo(s.width * pos[i] - s.width * 0.042, s.height * 0.706)
          ..lineTo(s.width * pos[i], s.height * 0.64)
          ..lineTo(s.width * pos[i] + s.width * 0.042, s.height * 0.706)
          ..close());
      }),
      ...List.generate(2, (i) {
        const pos = [0.352, 0.552];
        return _Region(id: 'tablet_$i', pathBuilder: (s) => Path()..addRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(s.width * pos[i], s.height * 0.40, s.width * 0.148, s.height * 0.30),
            topLeft: Radius.circular(s.width * 0.072),
            topRight: Radius.circular(s.width * 0.072))));
      }),
      ...List.generate(5, (i) => _Region(id: 'writing_$i', pathBuilder: (s) {
        final p = Path();
        final y = s.height * (0.522 + i * 0.034);
        p.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(s.width * 0.374, y, s.width * 0.104, s.height * 0.012),
          const Radius.circular(5)));
        p.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(s.width * 0.574, y, s.width * 0.104, s.height * 0.012),
          const Radius.circular(5)));
        return p;
      })),
    ];

// ── Scene 35: God Lives with His People ──────────────────────────────────────
// Sky, cloud, ground, 4 camp tents, courtyard, tent body, roof, entrance curtain

List<_Region> _tabernacleScene() => [
      _Region(id: 'sky', pathBuilder: (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.58))),
      _Region(id: 'cloud', pathBuilder: (s) {
        final p = Path();
        for (final d in [[0.50, 0.30, 0.34], [0.396, 0.326, 0.24], [0.604, 0.326, 0.24]]) {
          p.addOval(Rect.fromCenter(center: Offset(s.width * d[0], s.height * d[1]),
              width: s.width * d[2], height: s.width * d[2] * 0.68));
        }
        return p;
      }),
      _Region(id: 'ground', pathBuilder: (s) {
        final p = Path();
        p.moveTo(0, s.height * 0.58);
        p.quadraticBezierTo(s.width * 0.5, s.height * 0.558, s.width, s.height * 0.58);
        p.lineTo(s.width, s.height); p.lineTo(0, s.height); p.close(); return p;
      }),
      ...List.generate(4, (i) {
        const cfg = [[0.096, 0.70, 0.092], [0.252, 0.664, 0.078],
                     [0.904, 0.70, 0.092], [0.748, 0.664, 0.078]];
        return _Region(id: 'camp_$i', pathBuilder: (s) => Path()
          ..moveTo(s.width * (cfg[i][0] - cfg[i][2]), s.height * cfg[i][1])
          ..lineTo(s.width * cfg[i][0], s.height * cfg[i][1] - s.width * cfg[i][2] * 1.5)
          ..lineTo(s.width * (cfg[i][0] + cfg[i][2]), s.height * cfg[i][1])
          ..close());
      }),
      _Region(id: 'courtyard', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.322, s.height * 0.646, s.width * 0.356, s.height * 0.09))),
      _Region(id: 'tent_body', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.388, s.height * 0.47, s.width * 0.224, s.height * 0.18))),
      _Region(id: 'tent_band', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.388, s.height * 0.47, s.width * 0.224, s.height * 0.04))),
      _Region(id: 'roof', pathBuilder: (s) => Path()
        ..moveTo(s.width * 0.36, s.height * 0.47)
        ..lineTo(s.width * 0.50, s.height * 0.382)
        ..lineTo(s.width * 0.64, s.height * 0.47)
        ..close()),
      _Region(id: 'entrance', pathBuilder: (s) => Path()
        ..addRect(Rect.fromLTWH(s.width * 0.47, s.height * 0.528, s.width * 0.06, s.height * 0.122))),
    ];

/// Five-pointed star path centred at (cx, cy) with outer radius r.
Path _starPath(double cx, double cy, double r) {
  final p = Path();
  for (int i = 0; i < 5; i++) {
    final a = i * 2 * math.pi / 5 - math.pi / 2;
    final b = a + math.pi / 5;
    final x1 = cx + r * math.cos(a);
    final y1 = cy + r * math.sin(a);
    final x2 = cx + r * 0.42 * math.cos(b);
    final y2 = cy + r * 0.42 * math.sin(b);
    if (i == 0) {
      p.moveTo(x1, y1);
    } else {
      p.lineTo(x1, y1);
    }
    p.lineTo(x2, y2);
  }
  p.close();
  return p;
}

// ─────────────────────────────────────────────────────────────────────────────
// Crayon palette sidebar
// ─────────────────────────────────────────────────────────────────────────────

class _CrayonPalette extends StatelessWidget {
  const _CrayonPalette({
    required this.colors,
    required this.selected,
    required this.onSelect,
    required this.brushSizeIndex,
    required this.onBrushSize,
  });

  final List<Color> colors;
  final Color selected;
  final void Function(Color) onSelect;
  final int brushSizeIndex;
  final void Function(int) onBrushSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      // Fill the full row height so Expanded works correctly
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          // Brush size selector
          ...List.generate(3, (i) {
            final isSelected = i == brushSizeIndex;
            final dotSize = 6.0 + i * 5.0; // 6, 11, 16
            return GestureDetector(
              onTap: () => onBrushSize(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 40,
                height: 22,
                alignment: Alignment.center,
                decoration: isSelected
                    ? BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF374151)
                        : const Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          // Color swatches — scrollable so landscape mode never overflows
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: colors
                    .map((c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: _CrayonSwatch(
                            color: c,
                            selected: c == selected,
                            onTap: () => onSelect(c),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrayonSwatch extends StatelessWidget {
  const _CrayonSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        width: selected ? 36 : 30,
        height: selected ? 36 : 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4)],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// All-done celebration banner
// ─────────────────────────────────────────────────────────────────────────────

class _AllDoneBanner extends StatelessWidget {
  const _AllDoneBanner({required this.storyId});
  final String storyId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColours.lumiGold,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColours.lumiGold.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Beautiful! Your masterpiece is done!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/story/$storyId/family'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Next',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
