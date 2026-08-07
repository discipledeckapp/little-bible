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
      // Live stream — updates automatically as background seeding adds chapters.
      body: StreamBuilder<List<BibleChapter>>(
        stream: db.watchLoadedChapters(displayName),
        builder: (context, snap) {
          // Map chapter number → hasLbv (null = not yet seeded).
          final seededMap = <int, bool>{};
          for (final c in snap.data ?? []) {
            // LBV chapters have chapterSummary populated; KJV-only chapters don't.
            seededMap[c.chapter] = c.chapterSummary != null;
          }

          return _ChapterGrid(
            book: book,
            totalChapters: totalChapters,
            seededMap: seededMap,
            isLoading: snap.connectionState == ConnectionState.waiting,
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
    required this.seededMap,
    required this.isLoading,
  });

  final String book;
  final int totalChapters;
  /// chapter number → hasLbv; absent key = not yet seeded.
  final Map<int, bool> seededMap;
  final bool isLoading;

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
        // null = not yet seeded, true = LBV, false = KJV-only
        final hasLbv = seededMap[ch];
        return _ChapterChip(
          book: book,
          chapter: ch,
          hasLbv: hasLbv,
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
  /// null = not seeded yet; true = LBV available; false = KJV-only.
  final bool? hasLbv;

  @override
  Widget build(BuildContext context) {
    final isSeeded   = hasLbv != null;
    final isLbv      = hasLbv == true;

    // Visual states:
    //   gold border + gold text  = LBV available
    //   white bg + dark text     = KJV-only (readable)
    //   dim parchment + muted    = not yet seeded
    final bgColor = isLbv
        ? AppColours.lumiGold.withValues(alpha: 0.10)
        : isSeeded
            ? AppColours.surface
            : AppColours.parchment.withValues(alpha: 0.55);

    final borderColor = isLbv
        ? AppColours.lumiGold.withValues(alpha: 0.55)
        : isSeeded
            ? AppColours.textMuted.withValues(alpha: 0.35)
            : AppColours.textMuted.withValues(alpha: 0.20);

    final textColor = isLbv
        ? AppColours.lumiGold
        : isSeeded
            ? AppColours.textDark
            : AppColours.textMuted;

    return GestureDetector(
      onTap: () {
        if (isSeeded) {
          context.go('/bible/$book/$chapter');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bible content is loading — please try again in a moment.'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isLbv ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            '$chapter',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: isLbv ? FontWeight.w800 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
