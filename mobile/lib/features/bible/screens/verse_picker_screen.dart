import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/bible_canon.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Grid of verse numbers for one chapter.
///
/// Sits between the chapter grid and the reader. Tapping a chapter used to drop
/// straight into verse 1 with no way to choose, which meant reaching verse 20 of
/// Proverbs 3 took twenty swipes.
class VersePickerScreen extends ConsumerStatefulWidget {
  const VersePickerScreen({
    super.key,
    required this.book,
    required this.chapter,
  });

  final String book;
  final int chapter;

  @override
  ConsumerState<VersePickerScreen> createState() => _VersePickerScreenState();
}

class _VersePickerScreenState extends ConsumerState<VersePickerScreen> {
  /// Verse numbers present in this chapter, ascending.
  List<int> _verseNumbers = const [];
  bool _loading = true;

  String get _displayBook =>
      bookDefByKey(widget.book)?.displayName ?? widget.book;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// DB first, bundled asset as the fallback — the same order the reader uses,
  /// so the picker never shows fewer verses than the reader can scroll through.
  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    var numbers = (await db.getChapterVerses(_displayBook, widget.chapter))
        .map((v) => v.verse)
        .toList();

    if (numbers.isEmpty) numbers = await _verseNumbersFromAsset();

    numbers = numbers.toSet().toList()..sort();
    if (!mounted) return;
    setState(() {
      _verseNumbers = numbers;
      _loading = false;
    });
  }

  Future<List<int>> _verseNumbersFromAsset() async {
    final bookKey = widget.book.toLowerCase();
    final chPadded = widget.chapter.toString().padLeft(2, '0');
    final path = 'assets/bible/en/$bookKey/${bookKey}_chapter_$chPadded.json';
    try {
      final map = jsonDecode(await rootBundle.loadString(path))
          as Map<String, dynamic>;
      final verses = (map['verses'] as List<dynamic>? ?? const []);
      return verses
          .map((v) => (v as Map<String, dynamic>)['verse'] as int?)
          .whereType<int>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.cream,
      appBar: AppBar(
        backgroundColor: AppColours.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColours.textDark),
          onPressed: () => context.go('/bible/${widget.book}'),
        ),
        title: Text(
          '$_displayBook ${widget.chapter}',
          style: AppTextStyles.heading.copyWith(
            color: AppColours.textDark,
            fontSize: 20,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _verseNumbers.isEmpty
              // No verse list available — don't strand the child on a dead end.
              ? _EmptyState(
                  onReadAnyway: () =>
                      context.go('/bible/${widget.book}/${widget.chapter}/1'),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                      child: Row(
                        children: [
                          Text(
                            'Choose a verse',
                            style: AppTextStyles.label.copyWith(
                              color: AppColours.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          // "Start at 1" keeps the old one-tap behaviour for
                          // anyone who just wants to read the chapter through.
                          TextButton(
                            onPressed: () => context.go(
                                '/bible/${widget.book}/${widget.chapter}/1'),
                            child: Text(
                              'Read from start',
                              style: AppTextStyles.label.copyWith(
                                color: AppColours.lumiGold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: _verseNumbers.length,
                        itemBuilder: (context, i) {
                          final verse = _verseNumbers[i];
                          return _VerseTile(
                            verse: verse,
                            onTap: () => context.go(
                                '/bible/${widget.book}/${widget.chapter}/$verse'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _VerseTile extends StatelessWidget {
  const _VerseTile({required this.verse, required this.onTap});

  final int verse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColours.warmCream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColours.lumiGold.withValues(alpha: 0.55)),
        ),
        alignment: Alignment.center,
        child: Text(
          '$verse',
          style: AppTextStyles.label.copyWith(
            color: AppColours.lumiGold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReadAnyway});

  final VoidCallback onReadAnyway;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This chapter is still loading.',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                color: AppColours.textMuted,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onReadAnyway,
              child: Text(
                'Open it anyway',
                style: AppTextStyles.label.copyWith(
                  color: AppColours.lumiGold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
