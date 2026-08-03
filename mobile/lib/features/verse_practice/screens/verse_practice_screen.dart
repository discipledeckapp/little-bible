import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/verse_mastery_repository.dart';
import '../../../core/services/narration_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../story/providers/story_provider.dart';

// ─── Stop words ──────────────────────────────────────────────────────────────

const _stopWords = {
  'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
  'of', 'with', 'by', 'from', 'is', 'was', 'are', 'were', 'be', 'been',
  'has', 'have', 'had', 'did', 'do', 'does', 'not', 'no', 'it', 'he',
  'she', 'they', 'we', 'i', 'his', 'her', 'their', 'our', 'my', 'your',
  'its', 'so', 'as', 'if', 'that', 'this', 'then', 'all', 'said', 'when',
  'him', 'them', 'who', 'what', 'will', 'can', 'may', 'just', 'like',
};

// ─── Data class for a single fill-the-gap round ──────────────────────────────

class _Round {
  final String verseWithBlank; // verse text, target word replaced by ___
  final String answer;
  final List<String> options; // shuffled [answer, distractor, distractor]

  const _Round({
    required this.verseWithBlank,
    required this.answer,
    required this.options,
  });
}

List<_Round> _buildRounds(String verse) {
  // Strip punctuation for matching, but keep original for display replacement
  final words = verse.split(RegExp(r'\s+'));
  final keyIndices = <int>[];

  for (var i = 0; i < words.length; i++) {
    final clean = words[i].replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
    if (clean.length >= 4 && !_stopWords.contains(clean)) {
      keyIndices.add(i);
    }
  }

  if (keyIndices.isEmpty) return [];

  // Pick up to 3 evenly-spread indices
  final picks = <int>[];
  if (keyIndices.length == 1) {
    picks.add(keyIndices[0]);
  } else if (keyIndices.length == 2) {
    picks.addAll(keyIndices.take(2));
  } else {
    picks.add(keyIndices.first);
    picks.add(keyIndices[keyIndices.length ~/ 2]);
    picks.add(keyIndices.last);
  }

  final rng = Random(verse.hashCode);
  // Fallback distractors when the verse doesn't have enough key words
  const fallbacks = ['strong', 'water', 'stone', 'light', 'heart', 'trust', 'praise'];

  return picks.map((targetIdx) {
    final targetWord = words[targetIdx];
    final clean = targetWord.replaceAll(RegExp(r'[^\w]'), '');

    // Build the blanked verse
    final blanked = [...words];
    blanked[targetIdx] = '___';
    final verseWithBlank = blanked.join(' ');

    // Distractors: other key words from the same verse (different clean form)
    final others = keyIndices
        .where((i) => i != targetIdx)
        .map((i) => words[i].replaceAll(RegExp(r'[^\w]'), ''))
        .where((w) => w.toLowerCase() != clean.toLowerCase())
        .toSet()
        .toList();

    while (others.length < 2) {
      final f = fallbacks[rng.nextInt(fallbacks.length)];
      if (!others.contains(f) && f.toLowerCase() != clean.toLowerCase()) {
        others.add(f);
      }
    }

    final distractors = (others..shuffle(rng)).take(2).toList();
    final opts = [clean, ...distractors]..shuffle(rng);

    return _Round(
      verseWithBlank: verseWithBlank,
      answer: clean,
      options: opts,
    );
  }).toList();
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class VersePracticeScreen extends ConsumerStatefulWidget {
  const VersePracticeScreen({super.key, required this.storyId});
  final String storyId;

  @override
  ConsumerState<VersePracticeScreen> createState() =>
      _VersePracticeScreenState();
}

class _VersePracticeScreenState extends ConsumerState<VersePracticeScreen> {
  int _roundIndex = 0;
  int _correct = 0;
  String? _selected;
  bool _answered = false;
  bool _done = false;
  List<_Round> _rounds = [];
  String _verseKey = '';
  bool _loaded = false;

  @override
  void dispose() {
    ref.read(narrationServiceProvider).stop();
    super.dispose();
  }

  String _toVerseKey(String ref) =>
      ref.toLowerCase().replaceAll(' ', '-').replaceAll(':', '-');

  void _onLoad(String verse, String verseRef) {
    if (_loaded) return;
    _loaded = true;
    _verseKey = _toVerseKey(verseRef);
    _rounds = _buildRounds(verse);
    // Defer setState + TTS out of build() to avoid setState-during-build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        ref.read(narrationServiceProvider).speakUi(
          'find_the_missing_word',
          fallback: 'Find the missing word!',
        );
      }
    });
  }

  void _pick(String word) {
    if (_answered) return;
    final correct = word == _rounds[_roundIndex].answer;
    if (correct) {
      _correct++;
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _selected = word;
      _answered = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_roundIndex + 1 < _rounds.length) {
        setState(() {
          _roundIndex++;
          _selected = null;
          _answered = false;
        });
      } else {
        _finish();
      }
    });
  }

  Future<void> _finish() async {
    final profile = ref.read(activeProfileProvider).valueOrNull;
    if (profile != null && _verseKey.isNotEmpty) {
      final repo = ref.read(verseMasteryRepositoryProvider);
      if (_correct >= (_rounds.length / 2).ceil()) {
        await repo.advance(profile.id, _verseKey);
      } else {
        await repo.softFail(profile.id, _verseKey);
      }
    }
    if (mounted) setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(storyProvider(widget.storyId));

    return Scaffold(
      backgroundColor: AppColours.cream,
      body: SafeArea(
        child: storyAsync.when(
          data: (story) {
            final verse = story.steps.remember.memoryVerse;
            final verseRef = story.steps.remember.ref;
            _onLoad(verse, verseRef);

            if (!_loaded || _rounds.isEmpty) {
              return _EmptyState(verseRef: verseRef, verse: verse);
            }
            if (_done) {
              return _ResultPanel(
                correct: _correct,
                total: _rounds.length,
                onHome: () => context.go('/'),
              );
            }
            return _RoundView(
              round: _rounds[_roundIndex],
              roundIndex: _roundIndex,
              totalRounds: _rounds.length,
              selected: _selected,
              answered: _answered,
              onPick: _pick,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('Could not load verse.')),
        ),
      ),
    );
  }
}

// ─── Round view ──────────────────────────────────────────────────────────────

class _RoundView extends StatelessWidget {
  const _RoundView({
    required this.round,
    required this.roundIndex,
    required this.totalRounds,
    required this.selected,
    required this.answered,
    required this.onPick,
  });

  final _Round round;
  final int roundIndex;
  final int totalRounds;
  final String? selected;
  final bool answered;
  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress dots
          Row(
            children: List.generate(totalRounds, (i) {
              Color c;
              if (i < roundIndex) {
                c = AppColours.lumiGold;
              } else if (i == roundIndex) {
                c = AppColours.sky;
              } else {
                c = AppColours.textMuted.withValues(alpha: 0.3);
              }
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              );
            }),
          ),
          const SizedBox(height: 32),

          Text(
            'Find the missing word',
            style: AppTextStyles.label.copyWith(
              color: AppColours.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Verse card with blank
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColours.lumiGold.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _BlankText(verseWithBlank: round.verseWithBlank),
          ),

          const SizedBox(height: 36),

          // Options
          ...round.options.map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _OptionButton(
                  word: opt,
                  answer: round.answer,
                  selected: selected,
                  answered: answered,
                  onTap: () => onPick(opt),
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Verse text with blank rendered in gold ──────────────────────────────────

class _BlankText extends StatelessWidget {
  const _BlankText({required this.verseWithBlank});
  final String verseWithBlank;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.verseAdapted.copyWith(
      color: AppColours.textDark,
      fontSize: 20,
      height: 1.65,
    );
    final parts = verseWithBlank.split('___');
    if (parts.length < 2) {
      return Text(verseWithBlank, style: base, textAlign: TextAlign.center);
    }
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: ' _______ ',
            style: base.copyWith(
              color: AppColours.lumiGold,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColours.lumiGold,
            ),
          ),
          TextSpan(text: parts[1]),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ─── Option button ────────────────────────────────────────────────────────────

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.word,
    required this.answer,
    required this.selected,
    required this.answered,
    required this.onTap,
  });

  final String word;
  final String answer;
  final String? selected;
  final bool answered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color border = AppColours.textMuted.withValues(alpha: 0.2);
    Color text = AppColours.textDark;

    if (answered) {
      if (word == answer) {
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFF16A34A);
        text = const Color(0xFF166534);
      } else if (word == selected) {
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFEF4444);
        text = const Color(0xFF991B1B);
      }
    }

    return GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Text(
          word,
          textAlign: TextAlign.center,
          style: AppTextStyles.label.copyWith(
            color: text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Result panel ────────────────────────────────────────────────────────────

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.correct,
    required this.total,
    required this.onHome,
  });

  final int correct;
  final int total;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? correct / total : 0.0;
    final String message;
    final String emoji;
    if (pct >= 0.8) {
      message = 'You know it well!';
      emoji = '🌟';
    } else if (pct >= 0.5) {
      message = 'Great try! Keep practising.';
      emoji = '👍';
    } else {
      message = 'Keep going — you\'ll get it!';
      emoji = '💪';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 60, 32, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading.copyWith(
              color: AppColours.textDark,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$correct out of $total',
            style: AppTextStyles.label.copyWith(
              color: AppColours.textMuted,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColours.lumiGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state (verse has no blanking candidates) ──────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.verseRef, required this.verse});
  final String verseRef;
  final String verse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  verse,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.verseAdapted.copyWith(
                    color: AppColours.textDark,
                    fontSize: 20,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  verseRef,
                  style: AppTextStyles.label.copyWith(
                    color: AppColours.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColours.lumiGold,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text('Back to Home',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
