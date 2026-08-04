import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/bible_canon.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class BookPickerScreen extends StatelessWidget {
  const BookPickerScreen({super.key});

  // eSword-style layout constants
  static const int _cols = 6;
  static const double _hPad = 12.0;
  static const double _vPad = 4.0;
  static const double _spacing = 4.0;
  static const double _headerH = 20.0; // section header text height
  static const double _headerGap = 4.0; // gap between header and grid
  static const double _sectionGap = 8.0; // gap between OT and NT sections

  @override
  Widget build(BuildContext context) {
    final otBooks = kOtBooks; // 39 books
    final ntBooks = kNtBooks; // 27 books

    return Scaffold(
      backgroundColor: AppColours.cream,
      appBar: AppBar(
        backgroundColor: AppColours.cream,
        elevation: 0,
        title: Text(
          'Bible',
          style: AppTextStyles.heading.copyWith(
            color: AppColours.textDark,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/bible/my-verses'),
            icon: const Icon(Icons.bookmark_rounded,
                size: 16, color: AppColours.textMuted),
            label: Text(
              'My Verses',
              style: AppTextStyles.label.copyWith(
                color: AppColours.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availW = constraints.maxWidth;
          final availH = constraints.maxHeight;

          // Chip width: divide available width by columns minus padding & spacing
          final chipW =
              (availW - _hPad * 2 - _spacing * (_cols - 1)) / _cols;

          // Chip height: solve for the height that makes everything fit
          // Total height = overhead + totalRows * chipH + (otRows-1+ntRows-1) * spacing
          // overhead = vPad*2 + headerH*2 + headerGap*2 + sectionGap
          final otRows = (otBooks.length / _cols).ceil(); // 7
          final ntRows = (ntBooks.length / _cols).ceil(); // 5
          final totalRows = otRows + ntRows; // 12
          const overhead = _vPad * 2 +
              _headerH * 2 +
              _headerGap * 2 +
              _sectionGap;
          // spacing rows = (otRows-1) + (ntRows-1) = totalRows - 2
          final chipH = ((availH - overhead - (totalRows - 2) * _spacing) /
                  totalRows)
              .clamp(28.0, 52.0);

          final ratio = chipW / chipH;

          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: _hPad, vertical: _vPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader('OLD TESTAMENT'),
                const SizedBox(height: _headerGap),
                _BookGrid(
                  books: otBooks,
                  childAspectRatio: ratio,
                  cols: _cols,
                  spacing: _spacing,
                ),
                const SizedBox(height: _sectionGap),
                _SectionHeader('NEW TESTAMENT'),
                const SizedBox(height: _headerGap),
                _BookGrid(
                  books: ntBooks,
                  childAspectRatio: ratio,
                  cols: _cols,
                  spacing: _spacing,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColours.surface,
        selectedIndex: 1,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Bible',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_rounded),
            label: 'Parent',
          ),
        ],
        onDestinationSelected: (i) {
          if (i == 0) context.go(AppRoutes.home);
          if (i == 2) context.go(AppRoutes.parentHub);
        },
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        color: AppColours.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        height: 1.0,
      ),
    );
  }
}

// ─── Book grid (one section) ──────────────────────────────────────────────────

class _BookGrid extends StatelessWidget {
  const _BookGrid({
    required this.books,
    required this.childAspectRatio,
    required this.cols,
    required this.spacing,
  });

  final List<BibleBookDef> books;
  final double childAspectRatio;
  final int cols;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: books.length,
      itemBuilder: (_, i) => _BookChip(book: books[i]),
    );
  }
}

// ─── Individual book chip ─────────────────────────────────────────────────────

class _BookChip extends StatelessWidget {
  const _BookChip({required this.book});
  final BibleBookDef book;

  @override
  Widget build(BuildContext context) {
    final hasLbv = bookHasLbv(book.key);

    return GestureDetector(
      onTap: () => context.go('/bible/${book.key}'),
      child: Container(
        decoration: BoxDecoration(
          color: hasLbv
              ? AppColours.lumiGold.withValues(alpha: 0.08)
              : AppColours.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: hasLbv
                ? AppColours.lumiGold.withValues(alpha: 0.65)
                : AppColours.textMuted.withValues(alpha: 0.22),
            width: hasLbv ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            book.abbr,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color:
                  hasLbv ? AppColours.lumiGold : AppColours.textDark,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
