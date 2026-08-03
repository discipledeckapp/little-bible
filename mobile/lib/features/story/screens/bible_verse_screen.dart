import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/story_model.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/verse_mastery_repository.dart';
import '../../../core/services/narration_provider.dart';
import '../../../core/services/narration_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../lumi/widgets/lumi_widget.dart';
import '../providers/story_provider.dart';
import '../widgets/highlight_text.dart';

/// Reads the story's Bible passage aloud, one verse at a time.
///
/// This is the screen the whole product exists for, so it is built on two rules:
///
///  1. **It reads itself.** The audience cannot read. Narration starts on
///     arrival and on every advance — the child never has to find a button to
///     hear God's Word.
///  2. **There is no shortcut to the reward.** Back goes back; the only way to
///     the games is to finish. An escape hatch that lands on games teaches a
///     child to skip Scripture to reach the fun part.
class BibleVerseScreen extends ConsumerStatefulWidget {
  const BibleVerseScreen({super.key, required this.storyId});
  final String storyId;

  @override
  ConsumerState<BibleVerseScreen> createState() => _BibleVerseScreenState();
}

/// Seeds granted once, for reading the whole passage. Reading Scripture has to
/// be worth at least as much as playing a game about it.
const _kSeedsForReading = 3;

class _BibleVerseScreenState extends ConsumerState<BibleVerseScreen>
    with SingleTickerProviderStateMixin {
  int _verseIndex = 0;
  bool _speaking = false;
  bool _heardCurrent = false;
  int? _highlightStart;
  int? _highlightEnd;

  final Set<int> _introduced = {};
  bool _autoStarted = false;
  bool _rewarded = false;
  bool _redirected = false;

  late final AnimationController _pageCtrl;
  late final Animation<double> _fadeAnim;

  // Captured in initState so dispose() never touches `ref` — reading a provider
  // during teardown can throw once the container is disposed.
  late final NarrationService _narration;

  @override
  void initState() {
    super.initState();
    _narration = ref.read(narrationServiceProvider);
    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageCtrl.forward();
  }

  @override
  void dispose() {
    _narration.stop();
    _pageCtrl.dispose();
    super.dispose();
  }

  String _textOf(StoryVerse v) =>
      v.littleBible.isNotEmpty ? v.littleBible : v.kjv;

  String _verseKey(String ref) =>
      ref.toLowerCase().replaceAll(' ', '-').replaceAll(':', '-');

  // ── Narration ───────────────────────────────────────────────────────────────

  Future<void> _read(List<StoryVerse> verses) async {
    final verse = verses[_verseIndex];
    final index = _verseIndex;

    setState(() {
      _speaking = true;
      _highlightStart = null;
      _highlightEnd = null;
    });

    await _narration.speakStoryVerse(
      storyId: widget.storyId,
      verseIndex: index,
      fallbackText: _textOf(verse),
      onWord: (_, start, end) {
        // Guard against callbacks arriving after the child has moved on.
        if (mounted && _verseIndex == index) {
          setState(() {
            _highlightStart = start;
            _highlightEnd = end;
          });
        }
      },
      onDone: () {
        if (mounted && _verseIndex == index) {
          setState(() {
            _speaking = false;
            _heardCurrent = true;
            _highlightStart = null;
            _highlightEnd = null;
          });
        }
      },
    );
  }

  /// Tapping the speaker (or Lumi) stops if playing, re-reads if not.
  Future<void> _toggleRead(List<StoryVerse> verses) async {
    if (_speaking) {
      await _narration.stop();
      if (!mounted) return;
      setState(() {
        _speaking = false;
        // Choosing to stop counts as heard — never leave the child unable to
        // move on because narration did not run to completion.
        _heardCurrent = true;
        _highlightStart = null;
        _highlightEnd = null;
      });
      return;
    }
    await _read(verses);
  }

  // ── Progress ────────────────────────────────────────────────────────────────

  Future<void> _introduceVerse(StoryVerse verse, int index) async {
    if (_introduced.contains(index)) return;
    _introduced.add(index);
    final profile = ref.read(activeProfileProvider).valueOrNull;
    if (profile == null || verse.ref.isEmpty) return;
    await ref.read(verseMasteryRepositoryProvider).introduce(
          profile.id,
          _verseKey(verse.ref),
          verseRef: verse.ref,
          storyId: widget.storyId,
        );
  }

  Future<void> _reward() async {
    if (_rewarded) return;
    _rewarded = true;
    final profile = ref.read(activeProfileProvider).valueOrNull;
    if (profile == null) return;
    await ref
        .read(profileRepositoryProvider)
        .addSeeds(profile.id, _kSeedsForReading);
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  Future<void> _next(List<StoryVerse> verses) async {
    await _narration.stop();
    if (!mounted) return;

    if (_verseIndex < verses.length - 1) {
      ref.read(soundServiceProvider).play(SoundEffect.pageAdvance);
      _pageCtrl.reset();
      setState(() {
        _verseIndex++;
        _speaking = false;
        _heardCurrent = false;
        _highlightStart = null;
        _highlightEnd = null;
      });
      _pageCtrl.forward();
      await _read(verses);
    } else {
      await _reward();
      if (mounted) context.go('/story/${widget.storyId}/games');
    }
  }

  /// Back goes back — to the previous verse, or out to the story. It never
  /// jumps forward to the games.
  Future<void> _back() async {
    await _narration.stop();
    if (!mounted) return;

    if (_verseIndex > 0) {
      _pageCtrl.reset();
      setState(() {
        _verseIndex--;
        _speaking = false;
        _heardCurrent = false;
        _highlightStart = null;
        _highlightEnd = null;
      });
      _pageCtrl.forward();
      final verses =
          ref.read(storyProvider(widget.storyId)).valueOrNull?.steps.read.verses;
      if (verses != null && verses.isNotEmpty) await _read(verses);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(storyProvider(widget.storyId));
    final profile = ref.watch(activeProfileProvider).valueOrNull;

    return storyAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (story) {
        final verses = story.steps.read.verses;

        if (verses.isEmpty) {
          if (!_redirected) {
            _redirected = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/story/${widget.storyId}/games');
            });
          }
          return const Scaffold(body: SizedBox.shrink());
        }

        // Start reading as soon as the passage is available, and record the
        // verse as introduced so it enters spaced repetition.
        if (!_autoStarted) {
          _autoStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _read(verses);
            _introduceVerse(verses[_verseIndex], _verseIndex);
          });
        } else {
          _introduceVerse(verses[_verseIndex], _verseIndex);
        }

        final verse = verses[_verseIndex];
        final isLast = _verseIndex >= verses.length - 1;
        final band = profile?.ageBand ?? 'emerging';

        return Scaffold(
          backgroundColor: AppColours.warmCream,
          body: SafeArea(
            child: Column(
              children: [
                _Header(
                  current: _verseIndex,
                  total: verses.length,
                  onBack: _back,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _VerseBody(
                        verse: verse,
                        text: _textOf(verse),
                        band: band,
                        speaking: _speaking,
                        highlightStart: _highlightStart,
                        highlightEnd: _highlightEnd,
                        isLast: isLast,
                        onSpeak: () => _toggleRead(verses),
                      ),
                    ),
                  ),
                ),
                _Footer(
                  isLast: isLast,
                  ready: _heardCurrent,
                  onNext: () => _next(verses),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.current,
    required this.total,
    required this.onBack,
  });

  final int current;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          // 60×60: Material's 48dp floor is an adult minimum; small children
          // need more.
          Semantics(
            label: 'Go back',
            button: true,
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColours.lumiGold.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: AppColours.deepEarth, size: 22),
                ),
              ),
            ),
          ),
          const Spacer(),
          const Icon(Icons.menu_book_rounded,
              color: AppColours.lumiGold, size: 18),
          const SizedBox(width: 6),
          Text(
            'Bible Time',
            style: AppTextStyles.label.copyWith(
              color: AppColours.deepEarth,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Dots, not "2 / 4" — the audience is pre-numeracy.
          SizedBox(
            width: 60,
            child: Center(
              child: _Dots(current: current, total: total),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();
    return Semantics(
      label: 'Verse ${current + 1} of $total',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final active = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: active ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i <= current
                  ? AppColours.lumiGold
                  : AppColours.lumiGold.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Verse body ───────────────────────────────────────────────────────────────

class _VerseBody extends StatelessWidget {
  const _VerseBody({
    required this.verse,
    required this.text,
    required this.band,
    required this.speaking,
    required this.highlightStart,
    required this.highlightEnd,
    required this.isLast,
    required this.onSpeak,
  });

  final StoryVerse verse;
  final String text;
  final String band;
  final bool speaking;
  final int? highlightStart;
  final int? highlightEnd;
  final bool isLast;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    // Pre-readers get centred text because it reads as a picture. Readers get
    // left-aligned text: a ragged left edge breaks line-tracking for someone
    // still learning to follow a line.
    final isPreReader = band == 'early';
    final align = isPreReader ? TextAlign.center : TextAlign.start;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment:
            isPreReader ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Lumi reads to the child, so the child is not alone with a wall of
          // text. Tapping repeats the verse.
          Center(
            child: LumiWidget(
              state: speaking ? LumiState.wonder : LumiState.encourage,
              size: 124,
              onTap: onSpeak,
            ),
          ),
          const SizedBox(height: 4),

          // Reference — kept for the parent reading alongside; deliberately the
          // quietest thing on the screen.
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColours.lumiGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                verse.ref,
                style: AppTextStyles.label.copyWith(
                  color: AppColours.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // The verse — the hero of the screen.
          HighlightText(
            text: text,
            highlightStart: highlightStart,
            highlightEnd: highlightEnd,
            textAlign: align,
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: isPreReader ? 25 : 22,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3B2A1A),
              height: 1.65,
            ),
          ),
          const SizedBox(height: 24),

          // Secondary now that narration is automatic — this is "again", not
          // "start".
          Align(
            alignment: isPreReader ? Alignment.center : Alignment.centerLeft,
            child: Semantics(
              label: speaking ? 'Stop reading' : 'Hear this verse again',
              button: true,
              child: GestureDetector(
                onTap: onSpeak,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: speaking
                        ? AppColours.lumiGold.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColours.lumiGold.withValues(alpha: 0.55),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        speaking
                            ? Icons.stop_rounded
                            : Icons.volume_up_rounded,
                        color: AppColours.deepEarth,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        speaking ? 'Stop' : 'Again',
                        style: AppTextStyles.label.copyWith(
                          color: AppColours.deepEarth,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({
    required this.isLast,
    required this.ready,
    required this.onNext,
  });

  final bool isLast;

  /// True once the child has heard this verse. Advance stays tappable either
  /// way — a disabled control just reads as broken at this age — but it is
  /// visually quiet until the verse has been heard, so the loud thing on screen
  /// is never "skip".
  final bool ready;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
      child: Semantics(
        label: isLast ? 'Play games' : 'Next verse',
        button: true,
        child: SizedBox(
          width: double.infinity,
          height: 62,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: ready ? 1.0 : 0.55,
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon: Icon(
                isLast ? Icons.extension_rounded : Icons.arrow_forward_rounded,
                size: 22,
              ),
              label: Text(isLast ? 'Play Games!' : 'Next verse'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ready ? AppColours.lumiGold : AppColours.lumiGoldLight,
                foregroundColor:
                    ready ? Colors.white : AppColours.deepEarth,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
