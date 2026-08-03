import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/verse_mastery_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class BibleNavScreen extends ConsumerWidget {
  const BibleNavScreen({super.key, this.book, this.chapter, this.verse});

  final String? book;
  final int? chapter;
  final int? verse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);
    final profile = profileAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColours.cream,
      appBar: AppBar(
        backgroundColor: AppColours.cream,
        elevation: 0,
        title: Text(
          'My Verses',
          style: AppTextStyles.heading
              .copyWith(color: AppColours.textDark, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: AppColours.textDark),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : _VerseList(profileId: profile.id),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColours.surface,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_rounded), label: 'Bible'),
        ],
        onDestinationSelected: (i) {
          if (i == 0) context.go(AppRoutes.home);
        },
        selectedIndex: 1,
      ),
    );
  }
}

// ─── Verse list ───────────────────────────────────────────────────────────────

class _VerseList extends ConsumerWidget {
  const _VerseList({required this.profileId});
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref
        .watch(verseMasteryRepositoryProvider)
        .watchAllVerses(profileId);

    return StreamBuilder<List<VerseMasteryData>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final verses = snap.data ?? [];

        if (verses.isEmpty) {
          return _EmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          itemCount: verses.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _VerseRow(item: verses[i]),
        );
      },
    );
  }
}

// ─── Individual verse row ────────────────────────────────────────────────────

class _VerseRow extends StatelessWidget {
  const _VerseRow({required this.item});
  final VerseMasteryData item;

  static const _stageLabels = {
    'introduced': 'New',
    'recognised': 'Learning',
    'recalled': 'Growing',
    'understood': 'Known',
    'growing_familiar': 'Familiar',
  };

  static const _stageColors = {
    'introduced': Color(0xFF3B82F6),
    'recognised': Color(0xFF22C55E),
    'recalled': Color(0xFFF59E0B),
    'understood': Color(0xFF8B5CF6),
    'growing_familiar': Color(0xFFEAB308),
  };

  bool get _isDue =>
      item.nextReviewDate.isBefore(DateTime.now()) ||
      item.nextReviewDate.difference(DateTime.now()).inHours < 1;

  @override
  Widget build(BuildContext context) {
    final stageLabel = _stageLabels[item.stage] ?? item.stage;
    final stageColor =
        _stageColors[item.stage] ?? AppColours.textMuted;
    final displayRef =
        item.verseRef.isNotEmpty ? item.verseRef : item.verseKey;

    return GestureDetector(
      onTap: item.storyId.isNotEmpty
          ? () => context.go(
              _isDue ? '/practice/${item.storyId}' : '/story/${item.storyId}/verse')
          : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Book icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: stageColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.menu_book_rounded, color: stageColor, size: 20),
            ),
            const SizedBox(width: 14),

            // Verse ref + due indicator
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayRef,
                    style: AppTextStyles.label.copyWith(
                      color: AppColours.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: stageColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          stageLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: stageColor,
                          ),
                        ),
                      ),
                      if (_isDue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColours.lumiGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Practise now',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColours.lumiGold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            if (item.storyId.isNotEmpty)
              Icon(Icons.chevron_right_rounded,
                  color: AppColours.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_rounded,
                color: AppColours.textMuted.withValues(alpha: 0.4), size: 72),
            const SizedBox(height: 20),
            Text(
              'Your verses will appear here',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading.copyWith(
                color: AppColours.textDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Read a story to start collecting Bible verses!',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                color: AppColours.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
