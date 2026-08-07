import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/verse_mastery_repository.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/story_provider.dart';
import '../widgets/highlight_text.dart';

class KeyVerseScreen extends ConsumerStatefulWidget {
  const KeyVerseScreen({super.key, required this.storyId});

  final String storyId;

  @override
  ConsumerState<KeyVerseScreen> createState() => _KeyVerseScreenState();
}

class _KeyVerseScreenState extends ConsumerState<KeyVerseScreen> {
  int? _highlightStart;
  int? _highlightEnd;
  bool _spokenOnce = false;
  bool _introduced = false;

  @override
  void dispose() {
    ref.read(ttsServiceProvider).stop();
    ref.read(ttsServiceProvider).resetRate();
    super.dispose();
  }

  String _toVerseKey(String verseRef) =>
      verseRef.toLowerCase().replaceAll(' ', '-').replaceAll(':', '-');

  Future<void> _introduceVerse(String verseRef, String verseText) async {
    if (_introduced) return;
    _introduced = true;
    final profile = ref.read(activeProfileProvider).valueOrNull;
    if (profile == null) return;
    await ref.read(verseMasteryRepositoryProvider).introduce(
          profile.id,
          _toVerseKey(verseRef),
          verseRef: verseRef,
          storyId: widget.storyId,
        );
  }

  Future<void> _readVerse(String verse) async {
    final tts = ref.read(ttsServiceProvider);
    await tts.speakWithHighlight(
      verse,
      rate: TtsService.verseRate,
      onWord: (word, start, end) {
        if (mounted) setState(() { _highlightStart = start; _highlightEnd = end; });
      },
      onDone: () {
        if (mounted) setState(() { _highlightStart = null; _highlightEnd = null; });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(storyProvider(widget.storyId));

    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF3),
      body: storyAsync.when(
        data: (story) {
          final verse = story.steps.remember.memoryVerse;
          final ref_ = story.steps.remember.ref;
          final phrase = story.steps.remember.memoryPhrase;

          // Auto-read on first data arrival + record verse familiarity
          if (!_spokenOnce) {
            _spokenOnce = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _readVerse(verse);
              _introduceVerse(ref_, verse);
            });
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button row
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppColours.textDark,
                      onPressed: () {
                        ref.read(ttsServiceProvider).stop();
                        context.pop();
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section label
                  Text(
                    'REMEMBER THIS',
                    style: AppTextStyles.label.copyWith(
                      color: AppColours.lumiGold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Narrative context for the key verse — parent-facing, so the
                  // verse is never read stripped of its original setting.
                  if (story.verseContext.isNotEmpty) ...[
                    Text(
                      story.verseContext,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label.copyWith(
                        color: AppColours.textMuted,
                        fontSize: 13,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else
                    const SizedBox(height: 16),

                  // Verse card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColours.lumiGold.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Highlighted verse text
                        HighlightText(
                          text: verse,
                          highlightStart: _highlightStart,
                          highlightEnd: _highlightEnd,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ref_,
                          style: AppTextStyles.label.copyWith(
                            color: AppColours.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'From: ${story.title}',
                          style: AppTextStyles.label.copyWith(
                            color: AppColours.textMuted.withValues(alpha: 0.65),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Memory phrase hint
                  if (phrase.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColours.lumiGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded,
                              color: AppColours.lumiGold, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              phrase,
                              style: AppTextStyles.label.copyWith(
                                color: AppColours.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Replay button
                  TextButton.icon(
                    onPressed: () => _readVerse(verse),
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                    label: const Text('Hear it again'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColours.sky,
                    ),
                  ),

                  const Spacer(),

                  // Games CTA — included for all free-tier stories
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(ttsServiceProvider).stop();
                        context.go('/story/${widget.storyId}/games');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColours.lumiGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Play Games!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load verse.')),
      ),
    );
  }
}
