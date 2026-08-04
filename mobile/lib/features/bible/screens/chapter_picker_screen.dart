import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/bible_canon.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/theme/app_theme.dart';

class ChapterPickerScreen extends ConsumerWidget {
  const ChapterPickerScreen({super.key, required this.book});

  final String book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final bookDef = bookDefByKey(book);
    final displayName = bookDef?.displayName ?? _fallbackDisplay(book);
    final totalChapters = bookDef?.chapterCount ?? 1;

    return Scaffold(
      backgroundColor: AppColours.cream,
      appBar: AppBar(
        backgroundColor: AppColours.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColours.textDark),
          onPressed: () => context.go('/bible'),
        ),
        title: Text(
          displayName,
          style: AppTextStyles.heading.copyWith(
            color: AppColours.textDark,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<List<BibleChapter>>(
        future: db.getLoadedChapters(displayName),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Build the set of chapter numbers that have LBV content
          final loadedNums = <int>{
            for (final c in snap.data ?? []) c.chapter,
          };

          return _ChapterGrid(
            book: book,
            totalChapters: totalChapters,
            loadedChapters: loadedNums,
          );
        },
      ),
    );
  }

  static String _fallbackDisplay(String key) {
    if (key.isEmpty) return key;
    return key[0].toUpperCase() + key.substring(1);
  }
}

// ─── Chapter grid ─────────────────────────────────────────────────────────────

class _ChapterGrid extends StatelessWidget {
  const _ChapterGrid({
    required this.book,
    required this.totalChapters,
    required this.loadedChapters,
  });

  final String book;
  final int totalChapters;
  final Set<int> loadedChapters;

  static const double _spacing = 5.0;
  static const int _cols = 6;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _cols,
        crossAxisSpacing: _spacing,
        mainAxisSpacing: _spacing,
        childAspectRatio: 1.0,
      ),
      itemCount: totalChapters,
      itemBuilder: (context, i) {
        final ch = i + 1;
        return _ChapterChip(
          book: book,
          chapter: ch,
          hasLbv: loadedChapters.contains(ch),
        );
      },
    );
  }
}

// ─── Individual chapter chip ──────────────────────────────────────────────────

class _ChapterChip extends StatelessWidget {
  const _ChapterChip({
    required this.book,
    required this.chapter,
    required this.hasLbv,
  });

  final String book;
  final int chapter;
  final bool hasLbv;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (hasLbv) {
          context.go('/bible/$book/$chapter');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Little Bible Version coming soon! KJV text will be added next.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: hasLbv
              ? AppColours.lumiGold.withValues(alpha: 0.10)
              : AppColours.parchment.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasLbv
                ? AppColours.lumiGold.withValues(alpha: 0.55)
                : AppColours.textMuted.withValues(alpha: 0.20),
            width: hasLbv ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            '$chapter',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight:
                  hasLbv ? FontWeight.w800 : FontWeight.w500,
              color: hasLbv
                  ? AppColours.lumiGold
                  : AppColours.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
