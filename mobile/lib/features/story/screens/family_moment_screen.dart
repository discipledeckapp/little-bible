import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/story_model.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/story_progress_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/story_provider.dart';

class FamilyMomentScreen extends ConsumerWidget {
  const FamilyMomentScreen({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyAsync = ref.watch(storyProvider(storyId));

    return Scaffold(
      backgroundColor: AppColours.cream,
      body: storyAsync.when(
        data: (story) => _FamilyBody(storyId: storyId, story: story),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load story.')),
      ),
    );
  }
}

class _FamilyBody extends ConsumerStatefulWidget {
  const _FamilyBody({required this.storyId, required this.story});

  final String storyId;
  final StoryModel story;

  @override
  ConsumerState<_FamilyBody> createState() => _FamilyBodyState();
}

class _FamilyBodyState extends ConsumerState<_FamilyBody> {
  bool _finishing = false;

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);

    final profile = ref.read(activeProfileProvider).valueOrNull;
    if (profile != null) {
      await ref
          .read(storyProgressRepositoryProvider)
          .markComplete(profile.id, widget.storyId, seedsEarned: 3);
    }

    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppColours.textDark,
              onPressed: () => context.pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),

            const SizedBox(height: 20),

            Text(
              'Family Moment',
              style: AppTextStyles.heading.copyWith(color: AppColours.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              'Talk, pray, and act together.',
              style: AppTextStyles.label.copyWith(color: AppColours.textMuted),
            ),
            const SizedBox(height: 28),

            Expanded(
              child: ListView(
                children: [
                  _MomentCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: AppColours.sky,
                    title: 'Talk Together',
                    content: story.steps.discuss.question,
                    extra: story.steps.discuss.familyQuestion.isNotEmpty
                        ? story.steps.discuss.familyQuestion
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _MomentCard(
                    icon: Icons.favorite_border_rounded,
                    iconColor: AppColours.coral,
                    title: 'Pray Together',
                    content: story.steps.pray.guidedPrayer,
                    extra: story.steps.pray.childPrompt.isNotEmpty
                        ? story.steps.pray.childPrompt
                        : null,
                    extraLabel: 'Child\'s prayer',
                  ),
                  const SizedBox(height: 14),
                  _MomentCard(
                    icon: Icons.directions_run_rounded,
                    iconColor: AppColours.earth,
                    title: 'Do Today',
                    content: story.steps.doToday.action,
                    extra: story.steps.doToday.parentNote.isNotEmpty
                        ? story.steps.doToday.parentNote
                        : null,
                    extraLabel: 'Parent tip',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Finish button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finishing ? null : _finish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColours.lumiGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _finishing
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white,
                        ),
                      )
                    : const Text(
                        'All done!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expandable moment card ───────────────────────────────────────────────────

class _MomentCard extends StatefulWidget {
  const _MomentCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    this.extra,
    this.extraLabel,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final String? extra;
  final String? extraLabel;

  @override
  State<_MomentCard> createState() => _MomentCardState();
}

class _MomentCardState extends State<_MomentCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColours.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.extra != null ? () => setState(() => _expanded = !_expanded) : null,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.label.copyWith(
                        color: AppColours.textDark,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (widget.extra != null)
                    Icon(
                      _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: AppColours.textMuted,
                    ),
                ],
              ),
            ),
          ),

          // Main content (always visible)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Text(
              widget.content,
              style: AppTextStyles.storyBody.copyWith(
                color: AppColours.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Extra content (expandable)
          if (widget.extra != null && _expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.extraLabel != null) ...[
                    Text(
                      widget.extraLabel!.toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: AppColours.textMuted,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.extra!,
                      style: AppTextStyles.storyBody.copyWith(
                        color: AppColours.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
