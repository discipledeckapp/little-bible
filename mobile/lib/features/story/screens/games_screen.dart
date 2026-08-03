import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/activity_model.dart';
import '../../../core/services/narration_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/profile_provider.dart';
import '../providers/story_provider.dart';
import '../widgets/animated_story_scene.dart';

// ─── Game catalogue ───────────────────────────────────────────────────────────

class _GameMeta {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final Color color;
  // Which age bands see this game
  final List<String> bands;

  const _GameMeta({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.color,
    required this.bands,
  });
}

// 'order' shows as picture game for early+emerging, card sequencing for independent only
const _allGames = [
  _GameMeta(
    id: 'order',
    title: "What's Next?",
    emoji: '🔮',
    description: 'Look at the picture — what happens next?',
    color: Color(0xFF10B981),
    bands: ['early', 'emerging'],
  ),
  _GameMeta(
    id: 'order',
    title: 'Story Order',
    emoji: '🔢',
    description: 'Put the story in the right order!',
    color: Color(0xFF10B981),
    bands: ['independent'],
  ),
  _GameMeta(
    id: 'whose',
    title: 'Who Did That?',
    emoji: '🙋',
    description: 'Match the action to the right person!',
    color: Color(0xFF3B82F6),
    bands: ['early', 'emerging', 'independent'],
  ),
  _GameMeta(
    id: 'fill',
    title: 'Fill the Gap',
    emoji: '✏️',
    description: 'Find the missing word in the verse!',
    color: Color(0xFF8B5CF6),
    bands: ['emerging', 'independent'],
  ),
  _GameMeta(
    id: 'truefalse',
    title: 'True or False?',
    emoji: '🤔',
    description: 'Was it true or false in the story?',
    color: Color(0xFFF59E0B),
    bands: ['emerging', 'independent'],
  ),
  _GameMeta(
    id: 'quiz',
    title: 'Quick Quiz',
    emoji: '🧩',
    description: 'Answer questions about what happened!',
    color: Color(0xFFEF4444),
    bands: ['independent'],
  ),
  _GameMeta(
    id: 'spell',
    title: 'Spell It!',
    emoji: '🔤',
    description: 'Tap the letters to spell the word!',
    color: Color(0xFF0EA5E9),
    bands: ['emerging', 'independent'],
  ),
];

// ─── Root screen ─────────────────────────────────────────────────────────────

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key, required this.storyId});
  final String storyId;

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  String? _activeGame;
  int _totalCorrect = 0;
  int _totalQuestions = 0;
  bool _showCelebration = false;
  bool _showSummary = false;
  int _lastCorrect = 0;
  int _lastTotal = 0;
  String? _lastGameId;
  int _replayKey = 0;

  List<_GameMeta> _availableGames(String ageBand) =>
      _allGames.where((g) => g.bands.contains(ageBand)).toList();

  void _onGameSelected(String gameId) => setState(() => _activeGame = gameId);

  void _onGameDone({required int correct, required int total}) => setState(() {
        _totalCorrect += correct;
        _totalQuestions += total;
        _lastCorrect = correct;
        _lastTotal = total;
        _lastGameId = _activeGame;
        _activeGame = null;
        _showSummary = true;
      });

  void _onCorrect() {
    ref.read(soundServiceProvider).play(SoundEffect.correct);
    setState(() => _showCelebration = true);
    Future.delayed(const Duration(milliseconds: 2000),
        () { if (mounted) setState(() => _showCelebration = false); });
  }

  void _onWrong() => ref.read(soundServiceProvider).play(SoundEffect.incorrect);

  String _feedbackPhrase(bool correct) {
    const ok = ['Well done!', 'Amazing!', 'You got it!', 'Brilliant!', "That's right!"];
    const no = ['Keep trying!', 'Almost!', 'Try again!', "Don't give up!", 'Have a go!'];
    final list = correct ? ok : no;
    final phrase = list[math.Random().nextInt(list.length)];
    ref.read(narrationServiceProvider).speakUi(
      correct ? 'well_done' : 'keep_trying',
      fallback: phrase,
    );
    if (correct) {
      _onCorrect();
    } else {
      _onWrong();
    }
    return phrase;
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(storyActivityProvider(widget.storyId));
    final profileAsync  = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: Stack(
        children: [
          activityAsync.when(
            data: (activity) {
              if (activity == null) {
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => context.go('/story/${widget.storyId}/family'));
                return const _Spinner();
              }
              return profileAsync.when(
                data: (profile) {
                  final band = profile?.ageBand ?? 'emerging';
                  final available = _availableGames(band);
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _showSummary
                        ? _GameSummary(
                            key: ValueKey('summary_$_replayKey'),
                            correct: _lastCorrect,
                            total: _lastTotal,
                            onNext: () => setState(() => _showSummary = false),
                            onReplay: () => setState(() {
                              _showSummary = false;
                              _replayKey++;
                              _activeGame = _lastGameId;
                            }),
                          )
                        : _activeGame == null
                            ? _GameHub(
                                key: ValueKey('hub_$_replayKey'),
                                games: available,
                                totalCorrect: _totalCorrect,
                                totalQuestions: _totalQuestions,
                                storyId: widget.storyId,
                                onSelect: _onGameSelected,
                              )
                            : _buildActiveGame(activity, _activeGame!, band),
                  );
                },
                loading: () => const _Spinner(),
                error: (_, _) => _buildActiveGame(activity, _activeGame ?? 'order', 'emerging'),
              );
            },
            loading: () => const _Spinner(),
            error: (_, _) => _ErrorSkip(storyId: widget.storyId),
          ),

          // Close button
          if (_activeGame != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white70,
                    iconSize: 28,
                    onPressed: () => setState(() { _activeGame = null; _showSummary = false; }),
                  ),
                ),
              ),
            ),

          // Confetti + Lumi dance celebration
          if (_showCelebration) const _CelebrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildActiveGame(ActivityModel activity, String gameId, String band) {
    // Picture game for anyone who isn't a confident reader (9-12 only get text ordering)
    final usePicture = band != 'independent';
    return switch (gameId) {
      'order' when usePicture => _WhatHappensNextGame(
          key: const ValueKey('order_picture'),
          activity: activity,
          onDone: (c, t) => _onGameDone(correct: c, total: t),
          onAnswer: _feedbackPhrase,
        ),
      'order' => _StoryOrderGame(
          key: const ValueKey('order'),
          activity: activity,
          onDone: (c, t) => _onGameDone(correct: c, total: t),
          onAnswer: _feedbackPhrase,
        ),
      'whose' when usePicture => _WhoseTurnEarlyGame(
          key: const ValueKey('whose_picture'),
          activity: activity,
          onDone: (c, t) => _onGameDone(correct: c, total: t),
          onAnswer: _feedbackPhrase,
        ),
      'whose' => _WhoseTurnGame(
          key: const ValueKey('whose'),
          activity: activity,
          onDone: (c, t) => _onGameDone(correct: c, total: t),
          onAnswer: _feedbackPhrase,
        ),
      'fill' => _FillGapGame(
          key: const ValueKey('fill'),
          activity: activity,
          onDone: (c, t) => _onGameDone(correct: c, total: t),
          onAnswer: _feedbackPhrase,
        ),
      'truefalse' => _TrueOrFalseGame(
          key: const ValueKey('torf'),
          activity: activity,
          onDone: (c, t) => _onGameDone(correct: c, total: t),
          onAnswer: _feedbackPhrase,
        ),
      'quiz' => _QuickQuizGame(
          key: const ValueKey('quiz'),
          activity: activity,
          onDone: (c, t) => _onGameDone(correct: c, total: t),
          onAnswer: _feedbackPhrase,
        ),
      'spell' => _SpellingGame(
          key: ValueKey('spell_$_replayKey'),
          activity: activity,
          storyId: widget.storyId,
          onDone: (c, t) => _onGameDone(correct: c, total: t),
          onAnswer: _feedbackPhrase,
        ),
      _ => const _Spinner(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Game Hub — selection screen
// ─────────────────────────────────────────────────────────────────────────────

class _GameHub extends StatelessWidget {
  const _GameHub({
    super.key,
    required this.games,
    required this.storyId,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.onSelect,
  });

  final List<_GameMeta> games;
  final String storyId;
  final int totalCorrect;
  final int totalQuestions;
  final void Function(String gameId) onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: AppColours.textDark, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🎮 Game Time!',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColours.textDark)),
                      Text('Pick a game to play',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              color: AppColours.textMuted)),
                    ],
                  ),
                ),
                if (totalQuestions > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColours.lumiGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalCorrect/$totalQuestions ⭐',
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColours.lumiGold),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Game cards
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: games.length + 1, // +1 for "Done — color it in!" at end
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                if (i == games.length) {
                  return _FinishCard(storyId: storyId);
                }
                final g = games[i];
                return _GameCard(meta: g, onTap: () => onSelect(g.id));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.meta, required this.onTap});
  final _GameMeta meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [meta.color, meta.color.withValues(alpha: 0.75)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: meta.color.withValues(alpha: 0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(meta.emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.title,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meta.description,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinishCard extends StatelessWidget {
  const _FinishCard({required this.storyId});
  final String storyId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/story/$storyId/color'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColours.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColours.lumiGold.withValues(alpha: 0.3), width: 1.5),
        ),
        child: const Row(
          children: [
            Text('🎨', style: TextStyle(fontSize: 32)),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Done playing? Colour the story!',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColours.textDark),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColours.lumiGold, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CELEBRATION OVERLAY — confetti + dancing Lumi
// ─────────────────────────────────────────────────────────────────────────────

class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay();

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Confetti> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _particles = List.generate(60, (i) => _Confetti(rng));
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          for (final p in _particles) { p.tick(); }
          return Stack(
            children: [
              // Confetti
              CustomPaint(
                painter: _ConfettiPainter(_particles),
                size: MediaQuery.of(context).size,
              ),
              // Lumi dancing in centre
              Center(
                child: Transform.scale(
                  scale: 1.0 + 0.12 * math.sin(_ctrl.value * math.pi * 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColours.lumiGold.withValues(alpha: 0.5),
                              blurRadius: 40, spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: CustomPaint(painter: _LumiHappyPainter()),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColours.lumiGold,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColours.lumiGold.withValues(alpha: 0.45),
                              blurRadius: 16, offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Text('🎉 Amazing!',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Confetti {
  double x, y, vx, vy, rotation, rotSpeed, size;
  Color color;

  static const _palette = [
    Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF10B981),
    Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFF472B6),
    Color(0xFFFBBF24), Color(0xFF34D399),
  ];

  _Confetti(math.Random rng)
      : x = rng.nextDouble(),
        y = -0.05 - rng.nextDouble() * 0.5,
        vx = (rng.nextDouble() - 0.5) * 0.006,
        vy = 0.006 + rng.nextDouble() * 0.010,
        rotation = rng.nextDouble() * math.pi * 2,
        rotSpeed = (rng.nextDouble() - 0.5) * 0.15,
        size = 8 + rng.nextDouble() * 10,
        color = _palette[rng.nextInt(_palette.length)];

  void tick() {
    y += vy;
    x += vx;
    vy += 0.0004;
    rotation += rotSpeed;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.y > 1.1) continue;
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.45),
        Paint()..color = p.color,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}

class _LumiHappyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.drawCircle(Offset(cx, cy), r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: const [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFD97706)],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    // Top sheen
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - r * 0.2, cy - r * 0.5), width: r * 0.6, height: r * 0.3),
      Paint()..color = Colors.white.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Happy wide eyes
    final eyeY = cy - r * 0.16;
    final eyeR = r * 0.13;
    for (final ex in [cx - r * 0.28, cx + r * 0.28]) {
      canvas.drawCircle(Offset(ex, eyeY), eyeR, Paint()..color = const Color(0xFF292524));
      canvas.drawCircle(Offset(ex + eyeR * 0.3, eyeY - eyeR * 0.3), eyeR * 0.38, Paint()..color = Colors.white.withValues(alpha: 0.7));
    }

    // Big open smile
    final smilePath = Path()
      ..moveTo(cx - r * 0.3, cy + r * 0.12)
      ..quadraticBezierTo(cx, cy + r * 0.42, cx + r * 0.3, cy + r * 0.12);
    canvas.drawPath(smilePath,
        Paint()
          ..color = const Color(0xFF92400E)
          ..strokeWidth = r * 0.07
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Rosy cheeks
    final blushPaint = Paint()..color = Colors.pink.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(cx - r * 0.38, cy + r * 0.05), r * 0.16, blushPaint);
    canvas.drawCircle(Offset(cx + r * 0.38, cy + r * 0.05), r * 0.16, blushPaint);

    // Leaf
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
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// GAME 1 — Story Order  (works with emoji, no reading required)
// ─────────────────────────────────────────────────────────────────────────────

class _StoryOrderGame extends StatefulWidget {
  const _StoryOrderGame({
    super.key,
    required this.activity,
    required this.onDone,
    required this.onAnswer,
  });
  final ActivityModel activity;
  final void Function(int correct, int total) onDone;
  final String Function(bool correct) onAnswer;

  @override
  State<_StoryOrderGame> createState() => _StoryOrderGameState();
}

class _StoryOrderGameState extends State<_StoryOrderGame> {
  late List<SequenceItem> _shuffled;
  late List<SequenceItem> _placed;
  late final List<SequenceItem> _correct;
  bool _done = false;
  bool _allRight = false;
  int _round = 0;
  int _score = 0;
  static const _totalRounds = 1;

  @override
  void initState() {
    super.initState();
    _correct = List.from(widget.activity.sequence?.sorted ?? []);
    _newRound();
  }

  void _newRound() {
    _shuffled = List.from(_correct)..shuffle(math.Random(DateTime.now().millisecond + _round * 97));
    _placed = [];
    _done = false;
    _allRight = false;
  }

  void _tap(SequenceItem item) {
    if (_done || _placed.contains(item)) return;
    final nextIndex = _placed.length;
    final isRight = _correct.length > nextIndex && _correct[nextIndex].id == item.id;
    setState(() { _placed.add(item); });
    if (!isRight) widget.onAnswer(false);
    if (_placed.length == _correct.length) {
      final allRight = _placed.asMap().entries.every((e) => e.value.id == _correct[e.key].id);
      widget.onAnswer(allRight);
      if (allRight) _score++;
      setState(() { _done = true; _allRight = allRight; });
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        if (_round < _totalRounds - 1) {
          setState(() { _round++; _newRound(); });
        } else {
          widget.onDone(_score, _totalRounds);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _GameScaffold(
      color: const Color(0xFF10B981),
      title: 'Story Order',
      emoji: '🔢',
      child: Column(
        children: [
          const SizedBox(height: 12),
          _ProgressDots(current: _round, total: _totalRounds),
          const SizedBox(height: 16),
          const Text('Tap the pictures in the right order!',
              style: TextStyle(
                  fontFamily: 'Nunito', fontSize: 18,
                  fontWeight: FontWeight.w700, color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),

          // Cards to tap (shuffled)
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.15,
            physics: const NeverScrollableScrollPhysics(),
            children: _shuffled.map((item) {
              final placedIndex = _placed.indexOf(item);
              final placed = placedIndex >= 0;
              final correctAtPos = placed && _correct[placedIndex].id == item.id;
              return GestureDetector(
                onTap: placed || _done ? null : () => _tap(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: placed
                        ? (correctAtPos ? Colors.white.withValues(alpha: 0.9) : Colors.red.shade100)
                        : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: placed
                          ? (correctAtPos ? Colors.white : Colors.red.shade300)
                          : Colors.white.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.emoji, style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 6),
                          Text(item.label,
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: placed && correctAtPos
                                      ? const Color(0xFF065F46)
                                      : Colors.white),
                              textAlign: TextAlign.center,
                              maxLines: 2),
                        ],
                      ),
                      if (placed)
                        Positioned(
                          top: 8, right: 8,
                          child: Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              color: correctAtPos ? const Color(0xFF10B981) : Colors.red.shade400,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${placedIndex + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          if (_done)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                _allRight ? '🎉 Perfect order!' : '🤗 Good try!',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GAME 2 — Whose Turn?
// ─────────────────────────────────────────────────────────────────────────────

class _WhoseTurnGame extends StatefulWidget {
  const _WhoseTurnGame({
    super.key,
    required this.activity,
    required this.onDone,
    required this.onAnswer,
  });
  final ActivityModel activity;
  final void Function(int correct, int total) onDone;
  final String Function(bool correct) onAnswer;

  @override
  State<_WhoseTurnGame> createState() => _WhoseTurnGameState();
}

class _WhoseTurnGameState extends State<_WhoseTurnGame> {
  String? _selected;
  bool _answered = false;
  int _qi = 0;
  int _score = 0;
  late final List<MatchPair> _pairs;
  late final List<({String name, String emoji})> _tiles;

  @override
  void initState() {
    super.initState();
    final pairs = widget.activity.matches?.pairs ?? [];
    if (pairs.isNotEmpty) {
      final pass2 = List<MatchPair>.from(pairs)..shuffle(math.Random());
      _pairs = [...pairs, ...pass2];
      // Tiles: unique options only, stable shuffle for visual consistency
      final tileSource = {...pairs.map((p) => p.left)}.map(
        (name) => pairs.firstWhere((p) => p.left == name)
      ).toList()..shuffle(math.Random(42));
      _tiles = tileSource.map((p) => (name: p.left, emoji: p.leftEmoji)).toList();
    } else {
      _pairs = [];
      _tiles = [(name: 'Jesus', emoji: '✝️'), (name: 'Noah', emoji: '🚢'), (name: 'A Shepherd', emoji: '🐑')];
    }
  }

  String get _actionText => _pairs.isNotEmpty ? _pairs[_qi].right : 'Loved every child he met';
  String get _correctCharacter => _pairs.isNotEmpty ? _pairs[_qi].left : 'Jesus';
  int get _total => _pairs.isNotEmpty ? _pairs.length : 1;

  void _onTap(String name) {
    if (_answered) return;
    final correct = name == _correctCharacter;
    widget.onAnswer(correct);
    if (correct) _score++;
    setState(() { _selected = name; _answered = true; });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_qi < _total - 1) {
        setState(() { _qi++; _selected = null; _answered = false; });
      } else {
        widget.onDone(_score, _total);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _GameScaffold(
      color: const Color(0xFF3B82F6),
      title: 'Who Did That?',
      emoji: '🙋',
      child: Column(
        children: [
          const SizedBox(height: 12),
          _ProgressDots(current: _qi, total: _total),
          const SizedBox(height: 16),
          // Action bubble
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(_qi),
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: Text(
                '"$_actionText"',
                style: const TextStyle(
                    fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w600,
                    color: Colors.white, fontStyle: FontStyle.italic, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Who said or did this?',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _tiles.asMap().entries.map((entry) {
              final tileIdx = entry.key;
              final t = entry.value;
              final isCorrect = _answered && t.name == _correctCharacter;
              final isWrong   = _answered && _selected == t.name && t.name != _correctCharacter;
              return GestureDetector(
                onTap: _answered ? null : () => _onTap(t.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 90,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.white : isWrong ? Colors.red.shade200.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCorrect ? Colors.white : isWrong ? Colors.red.shade300 : Colors.white.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: Column(children: [
                    _CharacterPortrait(name: t.name, size: 60, tileIndex: tileIdx),
                    const SizedBox(height: 8),
                    Text(t.name,
                        style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700,
                            color: isCorrect ? const Color(0xFF1D4ED8) : Colors.white),
                        textAlign: TextAlign.center, maxLines: 2),
                  ]),
                ),
              );
            }).toList(),
          ),
          if (_answered)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                _selected == _correctCharacter ? '🎉 That\'s right!' : '🤗 Keep going!',
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GAME 3 — Fill the Gap
// ─────────────────────────────────────────────────────────────────────────────

// A single question within FillGap.
class _GapQ {
  const _GapQ({required this.words, required this.blankIndex, required this.choices});
  final List<String> words;
  final int blankIndex;
  final List<String> choices;
  String get target => words[blankIndex];
}

// ─────────────────────────────────────────────────────────────────────────────
// EARLY GAME A — What Happens Next?  (ages 3-5, no reading required)
// Shows one scene, child picks the next scene from two picture choices.
// TTS drives all instruction — no text labels on choices.
// ─────────────────────────────────────────────────────────────────────────────

class _WhatHappensNextGame extends ConsumerStatefulWidget {
  const _WhatHappensNextGame({
    super.key,
    required this.activity,
    required this.onDone,
    required this.onAnswer,
  });
  final ActivityModel activity;
  final void Function(int correct, int total) onDone;
  final String Function(bool correct) onAnswer;

  @override
  ConsumerState<_WhatHappensNextGame> createState() => _WhatHappensNextGameState();
}

class _WhatHappensNextGameState extends ConsumerState<_WhatHappensNextGame> {
  late final List<SequenceItem> _items;
  int _qi = 0;
  int _score = 0;
  String? _chosen;
  bool _answered = false;
  late List<SequenceItem> _choices;

  int get _total => _items.length > 1 ? math.min((_items.length - 1) * 2, 6) : 1;
  SequenceItem get _current {
    final base = _items.length > 1 ? _items.length - 1 : 1;
    return _items[_qi % base];
  }
  SequenceItem get _correctNext {
    final base = _items.length > 1 ? _items.length - 1 : 1;
    return _items[math.min((_qi % base) + 1, _items.length - 1)];
  }

  @override
  void initState() {
    super.initState();
    final sorted = widget.activity.sequence?.sorted ?? [];
    _items = sorted.isNotEmpty ? sorted : [
      SequenceItem(id: 'a', order: 0, label: 'Start', emoji: '🌟'),
      SequenceItem(id: 'b', order: 1, label: 'Middle', emoji: '🔍'),
      SequenceItem(id: 'c', order: 2, label: 'End', emoji: '🎉'),
    ];
    _buildChoices();
    _speakPrompt();
  }

  void _buildChoices() {
    final wrong = _items
        .where((i) => i.label != _correctNext.label && i.label != _current.label)
        .toList()
      ..shuffle(math.Random(_qi * 17));
    final wrongItem = wrong.isNotEmpty ? wrong.first : _items.first;
    _choices = [_correctNext, wrongItem]..shuffle(math.Random(_qi * 11));
  }

  Future<void> _speakPrompt() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    // Read scene label then question so non-readers understand without reading labels
    await ref.read(narrationServiceProvider).speakUi(
      'lumi_what_next',
      fallback: '${_current.label}... What happens next?',
    );
  }

  void _onTap(SequenceItem item) {
    if (_answered) return;
    final correct = item.label == _correctNext.label;
    widget.onAnswer(correct);
    if (correct) _score++;
    setState(() { _chosen = item.label; _answered = true; });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (_qi < _total - 1) {
        setState(() { _qi++; _chosen = null; _answered = false; });
        _buildChoices();
        _speakPrompt();
      } else {
        widget.onDone(_score, _total);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _GameScaffold(
      color: const Color(0xFF10B981),
      title: "What's Next?",
      emoji: '🔮',
      child: Column(
        children: [
          const SizedBox(height: 8),
          _ProgressDots(current: _qi, total: _total),
          const SizedBox(height: 16),

          // Current scene — large, visual, labelled (label is for parents; big emoji drives the child)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey('scene_$_qi'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Column(children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(_current.emoji,
                        style: const TextStyle(fontSize: 54)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _current.label,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // Prompt
          const Text(
            'What happens next?',
            style: TextStyle(fontFamily: 'Nunito', fontSize: 20, color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),

          // Two visual choice cards — emoji in illustrated frame + text label
          Row(
            children: _choices.map((item) {
              final isCorrect = _answered && item.label == _correctNext.label;
              final isWrong = _answered && _chosen == item.label && item.label != _correctNext.label;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: _answered ? null : () => _onTap(item),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 16),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.white
                            : isWrong
                                ? Colors.red.shade300.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isCorrect
                              ? Colors.white
                              : isWrong
                                  ? Colors.red.shade400
                                  : Colors.white.withValues(alpha: 0.4),
                          width: 2.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Emoji in a circular illustration frame
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? const Color(0xFFD1FAE5)
                                  : isWrong
                                      ? Colors.red.shade100.withValues(alpha: 0.4)
                                      : Colors.white.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(item.emoji,
                                  style: const TextStyle(fontSize: 44)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Text label — the key to making options interpretable
                          Text(
                            item.label,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isCorrect
                                  ? const Color(0xFF065F46)
                                  : isWrong
                                      ? Colors.red.shade800
                                      : Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isCorrect || isWrong) ...[
                            const SizedBox(height: 6),
                            Icon(
                              isCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: isCorrect
                                  ? const Color(0xFF059669)
                                  : Colors.red.shade400,
                              size: 24,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EARLY GAME B — Who Did That?  (visual/audio only for ages 3-5)
// TTS reads the action. Child taps the emoji character.
// No text labels — pure visual recognition.
// ─────────────────────────────────────────────────────────────────────────────

class _WhoseTurnEarlyGame extends ConsumerStatefulWidget {
  const _WhoseTurnEarlyGame({
    super.key,
    required this.activity,
    required this.onDone,
    required this.onAnswer,
  });
  final ActivityModel activity;
  final void Function(int correct, int total) onDone;
  final String Function(bool correct) onAnswer;

  @override
  ConsumerState<_WhoseTurnEarlyGame> createState() => _WhoseTurnEarlyGameState();
}

class _WhoseTurnEarlyGameState extends ConsumerState<_WhoseTurnEarlyGame> {
  String? _selected;
  bool _answered = false;
  int _qi = 0;
  int _score = 0;
  late final List<MatchPair> _pairs;
  late final List<({String name, String emoji})> _tiles;

  @override
  void initState() {
    super.initState();
    final pairs = widget.activity.matches?.pairs ?? [];
    final pass2early = List<MatchPair>.from(pairs)..shuffle(math.Random());
    _pairs = [...pairs, ...pass2early];
    // Tiles: unique options only, stable shuffle for visual consistency
    final tileSourceEarly = {...pairs.map((p) => p.left)}.map(
      (name) => pairs.firstWhere((p) => p.left == name)
    ).toList()..shuffle(math.Random(42));
    _tiles = tileSourceEarly.map((p) => (name: p.left, emoji: p.leftEmoji)).toList();
    _speakAction();
  }

  int get _total => _pairs.isNotEmpty ? _pairs.length : 1;
  String get _actionText => _pairs.isNotEmpty ? _pairs[_qi].right : '';
  String get _correctCharacter => _pairs.isNotEmpty ? _pairs[_qi].left : '';

  Future<void> _speakAction() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || _actionText.isEmpty) return;
    // Speak the action so child can match without reading
    await ref.read(narrationServiceProvider).speakUi(
      'lumi_who_did_this',
      fallback: _actionText,
    );
  }

  void _onTap(String name) {
    if (_answered) return;
    final correct = name == _correctCharacter;
    widget.onAnswer(correct);
    if (correct) _score++;
    setState(() { _selected = name; _answered = true; });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_qi < _total - 1) {
        setState(() { _qi++; _selected = null; _answered = false; });
        _speakAction();
      } else {
        widget.onDone(_score, _total);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _GameScaffold(
      color: const Color(0xFF3B82F6),
      title: 'Who Did That?',
      emoji: '🙋',
      child: Column(
        children: [
          const SizedBox(height: 8),
          _ProgressDots(current: _qi, total: _total),
          const SizedBox(height: 16),

          // Action — spoken by TTS; shown as text for parents but large enough child ignores it
          GestureDetector(
            onTap: _speakAction, // re-tap to hear again
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey('action_$_qi'),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: Column(children: [
                  const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    '"$_actionText"',
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text('Tap to hear again', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, color: Colors.white.withValues(alpha: 0.55))),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Who did this?',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 20, color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _tiles.asMap().entries.map((entry) {
              final tileIdx = entry.key;
              final t = entry.value;
              final isCorrect = _answered && t.name == _correctCharacter;
              final isWrong = _answered && _selected == t.name && t.name != _correctCharacter;
              return GestureDetector(
                onTap: _answered ? null : () => _onTap(t.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 100,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.white : isWrong ? Colors.red.shade300.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isCorrect ? Colors.white : isWrong ? Colors.red.shade400 : Colors.white.withValues(alpha: 0.4),
                      width: 2.5,
                    ),
                  ),
                  child: Column(children: [
                    _CharacterPortrait(name: t.name, size: 68, tileIndex: tileIdx),
                    const SizedBox(height: 6),
                    Text(
                      t.name,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isCorrect ? const Color(0xFF1D4ED8) : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    if (isCorrect)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(Icons.check_circle_rounded, color: const Color(0xFF1D4ED8), size: 20),
                      )
                    else if (isWrong)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(Icons.cancel_rounded, color: Colors.red.shade400, size: 20),
                      ),
                  ]),
                ),
              );
            }).toList(),
          ),
          if (_answered)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                _selected == _correctCharacter ? '🎉 Yes!' : '🤗 Try again!',
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GAME 3 — Fill the Gap
// ─────────────────────────────────────────────────────────────────────────────

class _FillGapGame extends StatefulWidget {
  const _FillGapGame({
    super.key,
    required this.activity,
    required this.onDone,
    required this.onAnswer,
  });
  final ActivityModel activity;
  final void Function(int correct, int total) onDone;
  final String Function(bool correct) onAnswer;

  @override
  State<_FillGapGame> createState() => _FillGapGameState();
}

class _FillGapGameState extends State<_FillGapGame>
    with SingleTickerProviderStateMixin {
  String? _selected;
  bool _answered = false;
  int _qi = 0;
  int _score = 0;
  late final List<_GapQ> _questions;
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);
    final base = _buildQuestions();
    final pass2 = List<_GapQ>.from(base)..shuffle(math.Random());
    _questions = [...base, ...pass2];
  }

  List<_GapQ> _buildQuestions() {
    final mb = widget.activity.memoryBuilder;
    if (mb == null || mb.phraseWords.isEmpty) {
      return [_GapQ(words: ['God', 'is', 'love'], blankIndex: 2, choices: ['love', 'fear', 'doubt'])];
    }

    final phrase = mb.phraseWords;
    final pool = mb.verseWords.toSet().toList();

    // Pick up to 3 content-word positions (length >= 3) spread across the phrase.
    final candidates = <int>[];
    for (int i = 0; i < phrase.length; i++) {
      if (phrase[i].length >= 3) candidates.add(i);
    }
    // Space them out: pick first, middle, last of candidates list.
    final indices = <int>{};
    if (candidates.isNotEmpty) {
      indices.add(candidates.first);
      if (candidates.length > 2) indices.add(candidates[candidates.length ~/ 2]);
      if (candidates.length > 1) indices.add(candidates.last);
    }
    if (indices.isEmpty) indices.add(phrase.length - 1);

    return indices.map((bi) {
      final target = phrase[bi];
      final distractors = pool
          .where((w) => w.toLowerCase() != target.toLowerCase() && w.length >= 3)
          .toSet()
          .toList()
        ..shuffle(math.Random(bi * 13));
      final choices = [target, ...distractors.take(2)]..shuffle(math.Random(bi * 7));
      return _GapQ(words: phrase, blankIndex: bi, choices: choices);
    }).toList();
  }

  _GapQ get _q => _questions[_qi];

  void _onTap(String word) {
    if (_answered) return;
    final correct = word == _q.target;
    widget.onAnswer(correct);
    if (correct) _score++;
    setState(() { _selected = word; _answered = true; });
    if (!correct) _shakeCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_qi < _questions.length - 1) {
        setState(() { _qi++; _selected = null; _answered = false; });
        _shakeCtrl.reset();
      } else {
        widget.onDone(_score, _questions.length);
      }
    });
  }

  @override
  void dispose() { _shakeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final q = _q;
    return _GameScaffold(
      color: const Color(0xFF8B5CF6),
      title: 'Fill the Gap',
      emoji: '✏️',
      child: Column(
        children: [
          const SizedBox(height: 12),
          _ProgressDots(current: _qi, total: _questions.length),
          const SizedBox(height: 16),
          const Text('Find the missing word!',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _shakeAnim,
            builder: (_, child) => Transform.translate(offset: Offset(_shakeAnim.value, 0), child: child!),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(_qi),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8, runSpacing: 8,
                  children: List.generate(q.words.length, (i) {
                    if (i == q.blankIndex) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        constraints: const BoxConstraints(minWidth: 80),
                        decoration: BoxDecoration(
                          color: !_answered ? Colors.white : (_selected == q.target ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          _selected ?? '___',
                          style: TextStyle(
                            fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w800,
                            color: !_answered ? const Color(0xFF8B5CF6) : (_selected == q.target ? const Color(0xFF065F46) : Colors.red.shade700),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(q.words[i],
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (!_answered)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Wrap(
                key: ValueKey('choices_$_qi'),
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: q.choices.map((w) => GestureDetector(
                  onTap: () => _onTap(w),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Text(w, style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6))),
                  ),
                )).toList(),
              ),
            )
          else
            Text(
              _selected == q.target ? '🎉 You got it!' : '🤗 Almost there!',
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GAME 4 — True or False
// ─────────────────────────────────────────────────────────────────────────────

class _TorFQ { final String text; final bool isTrue; const _TorFQ({required this.text, required this.isTrue}); }

class _TrueOrFalseGame extends StatefulWidget {
  const _TrueOrFalseGame({
    super.key,
    required this.activity,
    required this.onDone,
    required this.onAnswer,
  });
  final ActivityModel activity;
  final void Function(int score, int total) onDone;
  final String Function(bool correct) onAnswer;

  @override
  State<_TrueOrFalseGame> createState() => _TrueOrFalseGameState();
}

class _TrueOrFalseGameState extends State<_TrueOrFalseGame> {
  int _qi = 0, _score = 0;
  bool _answered = false;
  bool? _chosenTrue;
  late final List<_TorFQ> _questions;

  List<_TorFQ> _buildBase() {
    final items = widget.activity.sequence?.sorted ?? [];
    return items.length >= 4
        ? [
            _TorFQ(text: '"${items[0].label}" happened before "${items[2].label}"', isTrue: true),
            _TorFQ(text: '"${items[3].label}" happened first', isTrue: false),
            _TorFQ(text: '"${items[1].label}" happened before "${items[3].label}"', isTrue: true),
          ]
        : [
            const _TorFQ(text: 'God loves every child.', isTrue: true),
            const _TorFQ(text: 'The Bible is a made-up story.', isTrue: false),
            const _TorFQ(text: 'Jesus always keeps his promises.', isTrue: true),
          ];
  }

  @override
  void initState() {
    super.initState();
    final base = _buildBase();
    final pass2 = List<_TorFQ>.from(base)..shuffle(math.Random());
    _questions = [...base, ...pass2];
  }

  void _onAnswer(bool answerTrue) {
    if (_answered) return;
    final correct = answerTrue == _questions[_qi].isTrue;
    widget.onAnswer(correct);
    setState(() { _answered = true; _chosenTrue = answerTrue; if (correct) _score++; });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_qi < _questions.length - 1) {
        setState(() { _qi++; _answered = false; _chosenTrue = null; });
      } else {
        widget.onDone(_score, _questions.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_qi];
    return _GameScaffold(
      color: const Color(0xFFF59E0B),
      title: 'True or False?',
      emoji: '🤔',
      child: Column(
        children: [
          const SizedBox(height: 12),
          _ProgressDots(current: _qi, total: _questions.length),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(q.text, key: ValueKey(_qi),
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white, height: 1.5),
                  textAlign: TextAlign.center),
            ),
          ),
          const SizedBox(height: 32),
          if (!_answered)
            Row(
              children: [
                Expanded(child: _TorFBtn(label: 'TRUE',  icon: Icons.check_rounded,  color: const Color(0xFF10B981), onTap: () => _onAnswer(true))),
                const SizedBox(width: 16),
                Expanded(child: _TorFBtn(label: 'FALSE', icon: Icons.close_rounded, color: const Color(0xFFEF4444), onTap: () => _onAnswer(false))),
              ],
            )
          else
            Text(
              _chosenTrue == q.isTrue ? '🎉 Correct!' : '🤗 Keep trying!',
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _TorFBtn extends StatelessWidget {
  const _TorFBtn({required this.label, required this.icon, required this.color, required this.onTap});
  final String label; final IconData icon; final Color color; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 36),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontFamily: 'Nunito', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// GAME 5 — Quick Quiz
// ─────────────────────────────────────────────────────────────────────────────

class _QuizQ { final String character; final String correct; final List<String> options; const _QuizQ({required this.character, required this.correct, required this.options}); }

class _QuickQuizGame extends StatefulWidget {
  const _QuickQuizGame({
    super.key,
    required this.activity,
    required this.onDone,
    required this.onAnswer,
  });
  final ActivityModel activity;
  final void Function(int score, int total) onDone;
  final String Function(bool correct) onAnswer;

  @override
  State<_QuickQuizGame> createState() => _QuickQuizGameState();
}

class _QuickQuizGameState extends State<_QuickQuizGame> {
  int _qi = 0, _score = 0;
  bool _answered = false;
  String? _selected;
  late final List<_QuizQ> _questions;
  late final String _questionTemplate;

  @override
  void initState() {
    super.initState();
    _questionTemplate = widget.activity.matches?.questionTemplate ?? 'What did {left} do?';
    final pairs = widget.activity.matches?.pairs;
    if (pairs != null && pairs.length >= 2) {
      final all = pairs.map((p) => p.right).toList();
      final base = pairs.asMap().entries.map((e) {
        final others = all.where((a) => a != e.value.right).toList()..shuffle(math.Random(e.key * 13));
        return _QuizQ(
          character: e.value.left,
          correct: e.value.right,
          options: [e.value.right, ...others.take(2)]..shuffle(math.Random(e.key * 7)),
        );
      }).toList();
      final pass2 = List<_QuizQ>.from(base)..shuffle(math.Random());
      _questions = [...base, ...pass2];
    } else {
      _questions = [
        _QuizQ(character: 'Jesus', correct: 'Loves every child', options: ['Loves every child', 'Built an ark', 'Wrote the law']),
      ];
    }
  }

  void _onTap(String opt) {
    if (_answered) return;
    final correct = opt == _questions[_qi].correct;
    widget.onAnswer(correct);
    setState(() { _answered = true; _selected = opt; if (correct) _score++; });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_qi < _questions.length - 1) {
        setState(() { _qi++; _answered = false; _selected = null; });
      } else {
        widget.onDone(_score, _questions.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_qi];
    return _GameScaffold(
      color: const Color(0xFFEF4444),
      title: 'Quick Quiz',
      emoji: '🧩',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _ProgressDots(current: _qi, total: _questions.length),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              key: ValueKey(_qi),
              _questionTemplate.replaceAll('{left}', q.character),
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          ...q.options.map((opt) {
            final isCorrect = _answered && opt == q.correct;
            final isWrong   = _answered && _selected == opt && opt != q.correct;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: _answered ? null : () => _onTap(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.white
                        : isWrong
                            ? Colors.red.shade800.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect ? Colors.white : (isWrong ? Colors.red.shade200 : Colors.white.withValues(alpha: 0.35)),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(opt,
                            style: TextStyle(
                              fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w600,
                              color: isCorrect ? const Color(0xFFB91C1C) : Colors.white,
                            )),
                      ),
                      if (isCorrect) const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22)
                      else if (isWrong) const Icon(Icons.cancel_rounded, color: Colors.white54, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared scaffold — colorful gradient background with game header
// ─────────────────────────────────────────────────────────────────────────────

class _GameScaffold extends StatelessWidget {
  const _GameScaffold({
    required this.color,
    required this.title,
    required this.emoji,
    required this.child,
  });
  final Color color;
  final String title;
  final String emoji;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // minHeight ensures the gradient fills the full screen even when content
    // is shorter — eliminates the cream scaffold bleed at the bottom.
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, Color.lerp(color, Colors.black, 0.35)!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Row(children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Text(title.toUpperCase(),
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5)),
                ]),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared utility widgets ───────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.current, required this.total});
  final int current; final int total;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'Question ${current + 1} of $total',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.75),
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == current ? 22 : 8, height: 8,
          decoration: BoxDecoration(
            color: i < current
                ? Colors.white.withValues(alpha: 0.6)
                : i == current
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// POST-GAME SUMMARY
// ─────────────────────────────────────────────────────────────────────────────

class _GameSummary extends StatelessWidget {
  const _GameSummary({
    super.key,
    required this.correct,
    required this.total,
    required this.onNext,
    required this.onReplay,
  });

  final int correct;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onReplay;

  int get _stars {
    if (total == 0) return 1;
    final pct = correct / total;
    if (pct >= 0.9) return 3;
    if (pct >= 0.6) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final stars = _stars;
    final label = stars == 3 ? 'Perfect!' : stars == 2 ? 'Great job!' : 'Keep going!';
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    i < stars ? '⭐' : '✩',
                    style: TextStyle(
                      fontSize: 52,
                      color: i < stars ? AppColours.lumiGold : AppColours.textMuted,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColours.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$correct out of $total right!',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColours.textMuted,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Play again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours.lumiGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w800),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('Try another game'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColours.textDark,
                    side: BorderSide(
                        color: AppColours.lumiGold.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontFamily: 'Nunito', fontSize: 17, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GAME 6 — Spell It!   (emergent + independent)
// Child sees the story scene, then taps scrambled letter tiles to spell a word.
// ─────────────────────────────────────────────────────────────────────────────

class _SpellingGame extends StatefulWidget {
  const _SpellingGame({
    super.key,
    required this.activity,
    required this.storyId,
    required this.onDone,
    required this.onAnswer,
  });
  final ActivityModel activity;
  final String storyId;
  final void Function(int correct, int total) onDone;
  final String Function(bool correct) onAnswer;

  @override
  State<_SpellingGame> createState() => _SpellingGameState();
}

class _SpellingGameState extends State<_SpellingGame> {
  int _qi = 0, _score = 0;
  bool _checking = false;
  late final List<String> _words;
  List<String> _typed = [];
  List<String> _pool = [];   // remaining scrambled letters

  @override
  void initState() {
    super.initState();
    _words = _buildWords();
    _loadWord();
  }

  List<String> _buildWords() {
    final mb = widget.activity.memoryBuilder;
    if (mb != null && mb.phraseWords.isNotEmpty) {
      final candidates = mb.phraseWords
          .map((w) => w.toLowerCase().replaceAll(RegExp(r"[^a-z]"), ''))
          .where((w) => w.length >= 3 && w.length <= 7)
          .toSet()
          .toList();
      if (candidates.length >= 2) {
        // Two passes: base order then shuffled for reinforcement
        final pass2 = List<String>.from(candidates)..shuffle(math.Random());
        return [...candidates.take(3), ...pass2.take(3)];
      }
    }
    return ['god', 'love', 'made', 'safe', 'good', 'word'];
  }

  void _loadWord() {
    final letters = _words[_qi].split('');
    // Pre-fill first letter as a gold hint — gives children a starting anchor.
    _typed = [letters.first];
    _pool = List<String>.from(letters.sublist(1))
      ..shuffle(math.Random(_qi * 17));
    setState(() {});
  }

  void _tapTile(int idx) {
    if (_checking || _typed.length >= _words[_qi].length) return;
    final letter = _pool[idx];
    setState(() {
      _pool.removeAt(idx);
      _typed.add(letter);
    });
    if (_typed.length == _words[_qi].length) _check();
  }

  // Backspace: put non-hint letters back in the pool, keep the hint (index 0).
  void _clearTyped() {
    if (_checking || _typed.length <= 1) return;
    final toReturn = _typed.sublist(1);
    setState(() {
      _pool = [...toReturn, ..._pool]..shuffle(math.Random(_qi * 7));
      _typed = [_typed[0]];
    });
  }

  void _check() {
    _checking = true;
    final correct = _typed.join() == _words[_qi];
    widget.onAnswer(correct);
    if (correct) _score++;
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _checking = false;
      if (_qi < _words.length - 1) {
        setState(() => _qi++);
        _loadWord();
      } else {
        widget.onDone(_score, _words.length);
      }
    });
  }

  bool get _isCorrect => _checking && _typed.join() == _words[_qi];

  @override
  Widget build(BuildContext context) {
    final word = _words[_qi];
    return _GameScaffold(
      color: const Color(0xFF0EA5E9),
      title: 'Spell It!',
      emoji: '🔤',
      child: Column(
        children: [
          const SizedBox(height: 8),
          _ProgressDots(current: _qi, total: _words.length),
          const SizedBox(height: 12),
          // Story scene thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: StaticStoryScene(storyId: widget.storyId),
            ),
          ),
          const SizedBox(height: 16),
          // Clue instruction
          Text(
            'Tap the letters to spell the word!',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'The gold letter is a clue  ✨',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.65),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          // Letter slots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(word.length, (i) {
                final isHint = i == 0; // first letter is the pre-filled clue
                final filled = i < _typed.length;
                Color bg;
                Color border;
                Color letterColor;

                if (isHint && !_checking) {
                  bg = const Color(0xFFF59E0B);          // gold hint
                  border = const Color(0xFFF59E0B);
                  letterColor = Colors.white;
                } else if (_checking && filled) {
                  bg = _isCorrect
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEE2E2);
                  border = _isCorrect
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444);
                  letterColor = _isCorrect
                      ? const Color(0xFF065F46)
                      : Colors.red.shade700;
                } else if (filled) {
                  bg = Colors.white;
                  border = Colors.white.withValues(alpha: 0.7);
                  letterColor = const Color(0xFF0369A1);
                } else {
                  bg = Colors.white.withValues(alpha: 0.18);
                  border = Colors.white.withValues(alpha: 0.4);
                  letterColor = Colors.white;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 42,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      filled ? _typed[i].toUpperCase() : '',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: letterColor,
                      ),
                    ),
                  ),
                );
              }),
              // Backspace — only shown when there are non-hint letters to clear
              if (_typed.length > 1 && !_checking)
                GestureDetector(
                  onTap: _clearTyped,
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.backspace_outlined,
                        color: Colors.white70, size: 18),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          // Scrambled letter tiles
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_pool.length, (i) {
              return GestureDetector(
                onTap: () => _tapTile(i),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _pool[i].toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_checking)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                _isCorrect ? '🎉 Spot on!' : '🤗 Try again!',
                style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 22,
                  fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Character portrait — replaces emoji in "Who Did That?" tiles.
// Draws a simple illustrated face + robe for each biblical character.
// ─────────────────────────────────────────────────────────────────────────────

class _CharacterPortrait extends StatelessWidget {
  const _CharacterPortrait({required this.name, this.size = 72.0, this.tileIndex = -1});
  final String name;
  final double size;
  // When ≥ 0, guarantees a distinct fallback palette for unknown names.
  // Pass the tile's position in the option list so no two visible tiles collide.
  final int tileIndex;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size, height: size,
        child: CustomPaint(painter: _PortraitPainter(name: name, tileIndex: tileIndex)),
      );
}

class _PortraitConfig {
  const _PortraitConfig({
    required this.bg, required this.robe, required this.skin,
    required this.hair, this.hasBeard = false, this.hasCrown = false,
    this.hasHalo = false,
  });
  final Color bg, robe, skin, hair;
  final bool hasBeard, hasCrown, hasHalo;
}

_PortraitConfig _configFor(String name, {int tileIndex = -1}) {
  final n = name.toLowerCase();
  if (n.contains('jesus'))    return const _PortraitConfig(bg: Color(0xFFFEF3C7), robe: Color(0xFFE8D5B7), skin: Color(0xFFD4956A), hair: Color(0xFF3B2314), hasBeard: true, hasHalo: true);
  if (n.contains('noah'))     return const _PortraitConfig(bg: Color(0xFFDBEAFE), robe: Color(0xFF7C3AED), skin: Color(0xFFD4956A), hair: Color(0xFF6B7280), hasBeard: true);
  if (n.contains('daniel'))   return const _PortraitConfig(bg: Color(0xFFFEF9C3), robe: Color(0xFF6366F1), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917));
  if (n.contains('david'))    return const _PortraitConfig(bg: Color(0xFFDCFCE7), robe: Color(0xFF16A34A), skin: Color(0xFFD4956A), hair: Color(0xFF92400E));
  if (n.contains('shepherd')) return const _PortraitConfig(bg: Color(0xFFF0FDF4), robe: Color(0xFFD97706), skin: Color(0xFFD4956A), hair: Color(0xFF3B2314), hasBeard: true);
  if (n.contains('jonah'))    return const _PortraitConfig(bg: Color(0xFFCFFAFE), robe: Color(0xFF0EA5E9), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917));
  if (n.contains('moses'))    return const _PortraitConfig(bg: Color(0xFFFEF9C3), robe: Color(0xFFB45309), skin: Color(0xFFD4956A), hair: Color(0xFFD1D5DB), hasBeard: true);
  if (n.contains('mary'))     return const _PortraitConfig(bg: Color(0xFFEDE9FE), robe: Color(0xFF2563EB), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917));
  if (n.contains('angel') || n.contains('god')) return const _PortraitConfig(bg: Color(0xFFFEF3C7), robe: Color(0xFFFFFFFF), skin: Color(0xFFFDE68A), hair: Color(0xFFFCD34D), hasHalo: true);
  if (n.contains('king') || n.contains('pharaoh')) return const _PortraitConfig(bg: Color(0xFFF3E8FF), robe: Color(0xFF7C3AED), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917), hasCrown: true);
  if (n.contains('samaritan') || n.contains('neighbour')) return const _PortraitConfig(bg: Color(0xFFFFEDD5), robe: Color(0xFFEA580C), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917));
  if (n.contains('joseph'))   return const _PortraitConfig(bg: Color(0xFFFFF7ED), robe: Color(0xFFF59E0B), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917));
  if (n.contains('peter') || n.contains('disciple')) return const _PortraitConfig(bg: Color(0xFFEFF6FF), robe: Color(0xFF1D4ED8), skin: Color(0xFFD4956A), hair: Color(0xFF92400E));
  if (n.contains('son') || n.contains('child') || n.contains('boy') || n.contains('girl')) return const _PortraitConfig(bg: Color(0xFFF0FDF4), robe: Color(0xFF34D399), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917));
  if (n.contains('father') || n.contains('father')) return const _PortraitConfig(bg: Color(0xFFFEF9C3), robe: Color(0xFF78350F), skin: Color(0xFFD4956A), hair: Color(0xFF6B7280), hasBeard: true);
  if (n.contains('lion'))     return const _PortraitConfig(bg: Color(0xFFFEF3C7), robe: Color(0xFFD97706), skin: Color(0xFFD4956A), hair: Color(0xFF92400E));

  // Fallback: eight visually distinct palettes.
  // When tileIndex ≥ 0 the caller guarantees uniqueness by position;
  // otherwise fall back to a name hash (may collide for similar-prefix names).
  const fallbacks = [
    _PortraitConfig(bg: Color(0xFFDBEAFE), robe: Color(0xFF1D4ED8), skin: Color(0xFFD4956A), hair: Color(0xFF3B2314)),                           // blue
    _PortraitConfig(bg: Color(0xFFFFF7ED), robe: Color(0xFFEA580C), skin: Color(0xFFD4956A), hair: Color(0xFF92400E)),                           // orange
    _PortraitConfig(bg: Color(0xFFDCFCE7), robe: Color(0xFF15803D), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917)),                           // green
    _PortraitConfig(bg: Color(0xFFF3E8FF), robe: Color(0xFF6D28D9), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917)),                           // purple
    _PortraitConfig(bg: Color(0xFFFEF9C3), robe: Color(0xFFB45309), skin: Color(0xFFD4956A), hair: Color(0xFF3B2314), hasBeard: true),            // amber
    _PortraitConfig(bg: Color(0xFFCFFAFE), robe: Color(0xFF0369A1), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917)),                           // cyan
    _PortraitConfig(bg: Color(0xFFFEF2F2), robe: Color(0xFFDC2626), skin: Color(0xFFD4956A), hair: Color(0xFF1C1917)),                           // red
    _PortraitConfig(bg: Color(0xFFF0FDF4), robe: Color(0xFF065F46), skin: Color(0xFFD4956A), hair: Color(0xFF3B2314), hasBeard: true),            // emerald
  ];
  return fallbacks[tileIndex >= 0 ? tileIndex % fallbacks.length
      : name.codeUnits.fold(0, (int a, int b) => (a * 31 + b) & 0x7FFFFFFF) % fallbacks.length];
}

class _PortraitPainter extends CustomPainter {
  const _PortraitPainter({required this.name, this.tileIndex = -1});
  final String name;
  final int tileIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cfg = _configFor(name, tileIndex: tileIndex);
    final cx = w * 0.5;

    // Clip to circle
    canvas.clipPath(Path()..addOval(Rect.fromLTWH(0, 0, w, h)));

    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = cfg.bg);

    // Halo (Jesus / Angel)
    if (cfg.hasHalo) {
      canvas.drawCircle(Offset(cx, h * 0.38), w * 0.35,
          Paint()..color = const Color(0xFFFCD34D).withValues(alpha: 0.5));
    }

    // Robe / body (lower portion)
    final robePath = Path()
      ..moveTo(cx - w * 0.12, h * 0.68)
      ..lineTo(0, h)
      ..lineTo(w, h)
      ..lineTo(cx + w * 0.12, h * 0.68)
      ..cubicTo(cx + w * 0.08, h * 0.74, cx - w * 0.08, h * 0.74, cx - w * 0.12, h * 0.68);
    canvas.drawPath(robePath, Paint()..color = cfg.robe);
    // Shoulders rounding
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.70), width: w * 0.56, height: h * 0.18), Paint()..color = cfg.robe);

    // Neck
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, h * 0.62), width: w * 0.13, height: h * 0.10), Radius.circular(w * 0.06)),
      Paint()..color = cfg.skin,
    );

    // Hair (behind head)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.36), width: w * 0.50, height: h * 0.52), Paint()..color = cfg.hair);

    // Face
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.38), width: w * 0.42, height: h * 0.44), Paint()..color = cfg.skin);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF1C1917);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.10, h * 0.375), width: w * 0.07, height: h * 0.06), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.10, h * 0.375), width: w * 0.07, height: h * 0.06), eyePaint);
    // Eye shine
    final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(cx - w * 0.08, h * 0.365), w * 0.018, shinePaint);
    canvas.drawCircle(Offset(cx + w * 0.12, h * 0.365), w * 0.018, shinePaint);

    // Smile
    final smilePath = Path()
      ..moveTo(cx - w * 0.10, h * 0.46)
      ..quadraticBezierTo(cx, h * 0.53, cx + w * 0.10, h * 0.46);
    canvas.drawPath(smilePath, Paint()
      ..color = const Color(0xFF7C2D12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round);

    // Beard
    if (cfg.hasBeard) {
      final beardPath = Path()
        ..moveTo(cx - w * 0.18, h * 0.48)
        ..quadraticBezierTo(cx - w * 0.20, h * 0.60, cx, h * 0.65)
        ..quadraticBezierTo(cx + w * 0.20, h * 0.60, cx + w * 0.18, h * 0.48)
        ..quadraticBezierTo(cx, h * 0.52, cx - w * 0.18, h * 0.48);
      canvas.drawPath(beardPath, Paint()..color = cfg.hair);
    }

    // Crown
    if (cfg.hasCrown) {
      final crownPath = Path()
        ..moveTo(cx - w * 0.22, h * 0.16)
        ..lineTo(cx - w * 0.22, h * 0.08)
        ..lineTo(cx - w * 0.10, h * 0.14)
        ..lineTo(cx, h * 0.06)
        ..lineTo(cx + w * 0.10, h * 0.14)
        ..lineTo(cx + w * 0.22, h * 0.08)
        ..lineTo(cx + w * 0.22, h * 0.16)
        ..close();
      canvas.drawPath(crownPath, Paint()..color = const Color(0xFFFCD34D));
    }
  }

  @override
  bool shouldRepaint(_PortraitPainter old) => old.name != name || old.tileIndex != tileIndex;
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: AppColours.lumiGold));
}

class _ErrorSkip extends StatelessWidget {
  const _ErrorSkip({required this.storyId});
  final String storyId;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/story/$storyId/family'));
    return const _Spinner();
  }
}
