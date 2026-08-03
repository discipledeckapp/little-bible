import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/story_progress_repository.dart';
import '../../../core/providers/verse_mastery_repository.dart';
import '../../../core/models/story_model.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/parent_gate_service.dart';
import '../../../core/services/music_service.dart';
import '../../../core/services/sound_service.dart';

class ParentHubScreen extends ConsumerStatefulWidget {
  const ParentHubScreen({super.key});

  @override
  ConsumerState<ParentHubScreen> createState() => _ParentHubScreenState();
}

class _ParentHubScreenState extends ConsumerState<ParentHubScreen> {
  bool _gateChecked = false;
  bool _gatePassed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gateChecked) return;
    _gateChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkGate());
  }

  Future<void> _checkGate() async {
    final passed = await ref.read(parentGateServiceProvider).showGate(context);
    if (!mounted) return;
    if (!passed) {
      context.go('/');
      return;
    }
    setState(() => _gatePassed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_gatePassed) {
      return const Scaffold(
        backgroundColor: AppColours.cream,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: AppColours.cream,
      appBar: AppBar(
        backgroundColor: AppColours.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColours.textDark),
          tooltip: 'Close',
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Parent Hub',
          style: AppTextStyles.heading.copyWith(
            color: AppColours.textDark,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColours.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_rounded, color: AppColours.lumiGold),
            tooltip: 'Parental gate active',
            onPressed: null,
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Text(
                'No child profile found.',
                style: AppTextStyles.label.copyWith(color: AppColours.textMuted),
              ),
            );
          }
          return _HubBody(profile: profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Something went wrong')),
      ),
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────────

class _HubBody extends ConsumerWidget {
  const _HubBody({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        _ProfileCard(profile: profile),
        const SizedBox(height: 20),
        _ProfilesCard(activeProfileId: profile.id),
        const SizedBox(height: 20),
        _WeeklySummary(profile: profile),
        const SizedBox(height: 20),
        _ConversationCard(profile: profile),
        const SizedBox(height: 20),
        _VerseSummaryCard(profile: profile),
        const SizedBox(height: 20),
        _SettingsCard(profile: profile),
        const SizedBox(height: 20),
        _PinManagementCard(),
      ],
    );
  }
}

// ─── Profile chip ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    final bandLabel = switch (profile.ageBand) {
      'early' => 'Early Learner · 3–5',
      'emerging' => 'Emerging Reader · 6–8',
      _ => 'Independent Reader · 9–12',
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColours.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColours.lumiGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care_rounded,
                color: AppColours.lumiGold, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.nickname,
                  style: AppTextStyles.heading.copyWith(
                      color: AppColours.textDark, fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  bandLabel,
                  style: AppTextStyles.label.copyWith(
                      color: AppColours.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${profile.seeds}',
                style: AppTextStyles.heading.copyWith(
                    color: AppColours.lumiGold, fontSize: 20),
              ),
              Text(
                'seeds',
                style: AppTextStyles.label.copyWith(
                    color: AppColours.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Profiles management card ─────────────────────────────────────────────────

class _ProfilesCard extends ConsumerStatefulWidget {
  const _ProfilesCard({required this.activeProfileId});
  final String activeProfileId;

  @override
  ConsumerState<_ProfilesCard> createState() => _ProfilesCardState();
}

class _ProfilesCardState extends ConsumerState<_ProfilesCard> {
  bool _showAddForm = false;
  final _nicknameController = TextEditingController();
  String _selectedAgeBand = 'early';
  String _selectedEmoji = '🦁';
  bool _saving = false;

  static const _avatarEmojis = ['🦁', '🐣', '🌟', '🌈'];

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allProfilesAsync = ref.watch(allProfilesProvider);

    return _SectionCard(
      title: 'PROFILES',
      icon: Icons.people_alt_rounded,
      child: allProfilesAsync.when(
        data: (profiles) => _buildContent(profiles),
        loading: () => const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildContent(List<ChildProfile> profiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < profiles.length; i++) ...[
          if (i > 0) const Divider(height: 16),
          _buildProfileTile(profiles[i]),
        ],
        const SizedBox(height: 16),
        if (!_showAddForm) ...[
          OutlinedButton.icon(
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('Add child'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColours.textDark,
              side: BorderSide(
                color: AppColours.textMuted.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => setState(() {
              _showAddForm = true;
              _nicknameController.clear();
              _selectedAgeBand = 'early';
              _selectedEmoji = '🦁';
            }),
          ),
        ] else ...[
          _buildAddForm(),
        ],
      ],
    );
  }

  Widget _buildProfileTile(ChildProfile profile) {
    final isActive = profile.id == widget.activeProfileId;
    final emoji = _resolveEmoji(profile.avatarId);
    final bandLabel = switch (profile.ageBand) {
      'early' => 'Early · 3–5',
      'emerging' => 'Emerging · 6–8',
      _ => 'Independent · 9–12',
    };

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? AppColours.lumiGold.withValues(alpha: 0.15)
                : AppColours.parchment,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.nickname,
                style: AppTextStyles.label.copyWith(
                  color: AppColours.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                bandLabel,
                style: AppTextStyles.label.copyWith(
                  color: AppColours.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColours.lumiGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColours.lumiGold, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Active',
                  style: AppTextStyles.label.copyWith(
                    color: AppColours.lumiGold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          )
        else ...[
          TextButton(
            onPressed: () async {
              await ref
                  .read(profileRepositoryProvider)
                  .switchActive(profile.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColours.sky,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Switch', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 2),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: Colors.red.shade400,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _confirmDelete(profile),
          ),
        ],
      ],
    );
  }

  Widget _buildAddForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a child',
          style: AppTextStyles.label.copyWith(
            color: AppColours.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        // Nickname field
        TextField(
          controller: _nicknameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nickname',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Age band
        Text(
          'Age band',
          style: AppTextStyles.label.copyWith(
            color: AppColours.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        RadioGroup<String>(
          groupValue: _selectedAgeBand,
          onChanged: (v) {
            if (v != null) setState(() => _selectedAgeBand = v);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final band in ['early', 'emerging', 'independent'])
                RadioListTile<String>(
                  value: band,
                  title: Text(
                    switch (band) {
                      'early' => 'Early Learner (3–5)',
                      'emerging' => 'Emerging Reader (6–8)',
                      _ => 'Independent Reader (9–12)',
                    },
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      color: AppColours.textDark,
                    ),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Avatar emoji picker
        Text(
          'Avatar',
          style: AppTextStyles.label.copyWith(
            color: AppColours.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _avatarEmojis.map((emoji) {
            final selected = emoji == _selectedEmoji;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColours.lumiGold.withValues(alpha: 0.15)
                        : AppColours.parchment,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColours.lumiGold
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Action buttons
        Row(
          children: [
            TextButton(
              onPressed: _saving
                  ? null
                  : () => setState(() => _showAddForm = false),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _saving ? null : _submitAddChild,
              style: FilledButton.styleFrom(
                backgroundColor: AppColours.lumiGold,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitAddChild() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).createProfile(
            nickname: nickname,
            ageBand: _selectedAgeBand,
            avatarEmoji: _selectedEmoji,
          );
      if (mounted) {
        setState(() {
          _showAddForm = false;
          _saving = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete(ChildProfile profile) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text('Delete ${profile.nickname}?'),
            content: const Text(
              'All progress for this profile will be permanently deleted. This cannot be undone.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      await ref.read(profileRepositoryProvider).deleteProfile(profile.id);
    }
  }

  static String _resolveEmoji(String avatarId) => switch (avatarId) {
        'lion' => '🦁',
        'lamb' => '🐑',
        'dove' => '🕊️',
        'bear' => '🐻',
        _ => avatarId,
      };
}

// ─── Weekly summary ───────────────────────────────────────────────────────────

class _WeeklySummary extends ConsumerWidget {
  const _WeeklySummary({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressRepo = ref.read(storyProgressRepositoryProvider);

    return FutureBuilder<List<StoryProgressData>>(
      future: _completedThisWeek(progressRepo),
      builder: (context, snap) {
        final stories = snap.data ?? [];
        final count = stories.length;

        return _SectionCard(
          title: 'THIS WEEK',
          icon: Icons.date_range_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatPill(
                    label: '$count',
                    sublabel: count == 1 ? 'story' : 'stories',
                    color: AppColours.earth,
                  ),
                  const SizedBox(width: 10),
                  _StatPill(
                    label: '${profile.streakDays}',
                    sublabel: 'days active',
                    color: AppColours.sky,
                  ),
                  const SizedBox(width: 10),
                  _StatPill(
                    label: '${profile.seeds}',
                    sublabel: 'seeds',
                    color: AppColours.lumiGold,
                  ),
                ],
              ),
              if (count == 0) ...[
                const SizedBox(height: 14),
                Text(
                  'No stories completed this week yet. Try opening a story together!',
                  style: AppTextStyles.label.copyWith(
                      color: AppColours.textMuted, fontSize: 13, height: 1.5),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<List<StoryProgressData>> _completedThisWeek(
      StoryProgressRepository repo) async {
    final all = await repo.allCompletedForProfile(profile.id);
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return all.where((p) {
      final at = p.completedAt;
      return at != null && at.isAfter(weekAgo);
    }).toList();
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.sublabel,
    required this.color,
  });

  final String label;
  final String sublabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            sublabel,
            style: AppTextStyles.label.copyWith(
                color: color.withValues(alpha: 0.8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── Conversation starter card ────────────────────────────────────────────────

class _ConversationCard extends ConsumerWidget {
  const _ConversationCard({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentServiceProvider);
    final progressRepo = ref.read(storyProgressRepositoryProvider);

    return FutureBuilder<StoryModel?>(
      future: _mostRecentStory(content, progressRepo),
      builder: (context, snap) {
        final story = snap.data;

        return _SectionCard(
          title: 'CONVERSATION STARTER',
          icon: Icons.chat_bubble_outline_rounded,
          child: story == null
              ? Text(
                  'Complete a story to get a conversation prompt for your family.',
                  style: AppTextStyles.label.copyWith(
                      color: AppColours.textMuted, fontSize: 13, height: 1.5),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: AppTextStyles.label.copyWith(
                          color: AppColours.lumiGold, fontSize: 12,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${story.steps.discuss.familyQuestion.isNotEmpty ? story.steps.discuss.familyQuestion : story.steps.discuss.question}"',
                      style: AppTextStyles.storyBody.copyWith(
                          color: AppColours.textDark,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.5),
                    ),
                    if (story.steps.discuss.parentGuide.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColours.lumiGold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PARENT GUIDE',
                              style: AppTextStyles.label.copyWith(
                                  color: AppColours.lumiGold, fontSize: 10,
                                  letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.steps.discuss.parentGuide,
                              style: AppTextStyles.label.copyWith(
                                  color: AppColours.textDark,
                                  fontSize: 13,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }

  Future<StoryModel?> _mostRecentStory(
    ContentService content,
    StoryProgressRepository repo,
  ) async {
    final completed = await repo.allCompletedForProfile(profile.id);
    if (completed.isEmpty) return null;
    completed.sort((a, b) {
      final ta = a.completedAt ?? DateTime(2000);
      final tb = b.completedAt ?? DateTime(2000);
      return tb.compareTo(ta);
    });
    try {
      return await content.loadStory(completed.first.storyId);
    } catch (_) {
      return null;
    }
  }
}

// ─── Verse summary ─────────────────────────────────────────────────────────────

class _VerseSummaryCard extends ConsumerWidget {
  const _VerseSummaryCard({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versesAsync = ref.watch(allVersesForProfileProvider(profile.id));

    return _SectionCard(
      title: 'VERSES',
      icon: Icons.menu_book_rounded,
      child: versesAsync.when(
        data: (verses) {
          if (verses.isEmpty) {
            return Text(
              'Verses practised by your child will appear here.',
              style: AppTextStyles.label.copyWith(
                  color: AppColours.textMuted, fontSize: 13, height: 1.5),
            );
          }
          return Column(
            children: [
              for (final v in verses.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _stageColour(v.stage),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          v.verseRef.isEmpty ? v.verseKey : v.verseRef,
                          style: AppTextStyles.label.copyWith(
                              color: AppColours.textDark, fontSize: 13),
                        ),
                      ),
                      Text(
                        _stageLabel(v.stage),
                        style: AppTextStyles.label.copyWith(
                            color: AppColours.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              if (verses.length > 3)
                Text(
                  '+ ${verses.length - 3} more verse${verses.length - 3 == 1 ? '' : 's'}',
                  style: AppTextStyles.label.copyWith(
                      color: AppColours.textMuted, fontSize: 12),
                ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 24,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }

  Color _stageColour(String stage) => switch (stage) {
        'growing_familiar' => AppColours.earth,
        'understood' => AppColours.sky,
        'recalled' => AppColours.lumiGold,
        'recognised' => AppColours.coral,
        _ => AppColours.textMuted,
      };

  String _stageLabel(String stage) => switch (stage) {
        'growing_familiar' => 'Growing',
        'understood' => 'Understood',
        'recalled' => 'Recalled',
        'recognised' => 'Recognised',
        _ => 'Introduced',
      };
}

// ─── Settings card ─────────────────────────────────────────────────────────────

class _SettingsCard extends ConsumerStatefulWidget {
  const _SettingsCard({required this.profile});
  final ChildProfile profile;

  @override
  ConsumerState<_SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends ConsumerState<_SettingsCard> {
  late bool _soundEnabled;
  late bool _autoplay;
  late bool _quietMode;
  late bool _notificationsEnabled;
  late bool _reducedMotion;
  late bool _wifiOnly;
  late bool _cloudSync;

  @override
  void initState() {
    super.initState();
    _soundEnabled = widget.profile.musicEnabled;
    _autoplay = widget.profile.autoplayEnabled;
    _quietMode = widget.profile.quietStoryMode;
    _notificationsEnabled = widget.profile.notificationsEnabled;
    _reducedMotion = widget.profile.reducedMotion;
    _wifiOnly = widget.profile.wifiOnlyDownloads;
    _cloudSync = widget.profile.cloudSyncEnabled;
  }

  Future<void> _toggleSound(bool enabled) async {
    final music = ref.read(musicServiceProvider);
    final sounds = ref.read(soundServiceProvider);
    await music.setEnabled(enabled);
    sounds.setMuted(!enabled);
    await ref.read(profileRepositoryProvider).updateSettings(
      widget.profile.id,
      musicEnabled: enabled,
      effectsEnabled: enabled,
    );
    if (mounted) setState(() => _soundEnabled = enabled);
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final svc = ref.read(notificationServiceProvider);
    if (enabled) {
      final granted = await svc.requestPermission();
      if (!granted) return;
      await svc.scheduleWeeklyReminder();
    } else {
      await svc.cancelAll();
    }
    await ref.read(profileRepositoryProvider).updateSettings(
      widget.profile.id,
      notificationsEnabled: enabled,
    );
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'SETTINGS',
      icon: Icons.tune_rounded,
      child: Column(
        children: [
          _ToggleRow(
            label: 'Story narration (autoplay)',
            value: _autoplay,
            onChanged: (v) async {
              await ref.read(profileRepositoryProvider).updateSettings(widget.profile.id, autoplayEnabled: v);
              if (mounted) setState(() => _autoplay = v);
            },
          ),
          const Divider(height: 20),
          _ToggleRow(
            label: 'Quiet Story Mode',
            value: _quietMode,
            onChanged: (v) async {
              await ref.read(profileRepositoryProvider).updateSettings(widget.profile.id, quietStoryMode: v);
              if (mounted) setState(() => _quietMode = v);
            },
          ),
          const Divider(height: 20),
          _ToggleRow(
            label: 'Sound effects & background music',
            value: _soundEnabled,
            onChanged: _toggleSound,
          ),
          const Divider(height: 20),
          _ToggleRow(
            label: 'Weekly reminders (parent)',
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          const Divider(height: 20),
          _ToggleRow(
            label: 'Reduce motion and rewards',
            value: _reducedMotion,
            onChanged: (v) async {
              await ref.read(profileRepositoryProvider).updateSettings(widget.profile.id, reducedMotion: v);
              if (mounted) setState(() => _reducedMotion = v);
            },
          ),
          const Divider(height: 20),
          _ToggleRow(
            label: 'Download updates on Wi-Fi only',
            value: _wifiOnly,
            onChanged: (v) async {
              await ref.read(profileRepositoryProvider).updateSettings(widget.profile.id, wifiOnlyDownloads: v);
              if (mounted) setState(() => _wifiOnly = v);
            },
          ),
          const Divider(height: 20),
          _ToggleRow(
            label: 'Cloud backup (parent consent required)',
            value: _cloudSync,
            onChanged: (v) async {
              if (v) {
                final accepted = await _showCloudDisclosure(context);
                if (!accepted) return;
              }
              await ref.read(profileRepositoryProvider).updateSettings(widget.profile.id, cloudSyncEnabled: v);
              if (mounted) setState(() => _cloudSync = v);
            },
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Content access',
                style: AppTextStyles.label.copyWith(
                    color: AppColours.textDark, fontSize: 14),
              ),
              Text(
                widget.profile.isUnlocked ? 'All stories' : 'Free (20 stories)',
                style: AppTextStyles.label.copyWith(
                    color: widget.profile.isUnlocked
                        ? AppColours.earth
                        : AppColours.textMuted,
                    fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _showCloudDisclosure(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cloud backup'),
          content: const Text(
            'If enabled, Little Bible uploads only a random profile ID, story completion, broad learning topics, verse familiarity stage, and unlock status to Cloudflare D1. Nicknames, drawings, typed answers, voice, location, and device identifiers stay on this device. You can withdraw consent and delete cloud data at any time.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('I agree')),
          ],
        ),
      ) ?? false;
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
              color: AppColours.textDark, fontSize: 14),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColours.lumiGold,
        ),
      ],
    );
  }
}

// ─── PIN management + data deletion card ─────────────────────────────────────

class _PinManagementCard extends ConsumerWidget {
  const _PinManagementCard();

  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    // Step 1: confirm with typed "DELETE"
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Delete all data?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your account, all child profiles, all progress records, and all sync data will be permanently deleted. This cannot be undone.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Type DELETE to confirm:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: controller.text == 'DELETE'
                  ? () => Navigator.pop(ctx, true)
                  : null,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete permanently'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Step 2: wipe local data
    final db = ref.read(databaseProvider);
    await db.deleteAllUserData();

    // Step 3: clear secure storage (parent PIN)
    final gate = ref.read(parentGateServiceProvider);
    await gate.setPin('');

    // Step 4: cancel any scheduled notifications
    await ref.read(notificationServiceProvider).cancelAll();

    // Step 5: back to onboarding
    if (context.mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.read(parentGateServiceProvider);

    return _SectionCard(
      title: 'PARENT PIN',
      icon: Icons.lock_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your PIN protects this area from being accessed by your child.',
            style: AppTextStyles.label.copyWith(
                color: AppColours.textMuted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Change PIN'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColours.textDark,
              side: BorderSide(
                color: AppColours.textMuted.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await gate.setPin('');
              if (context.mounted) await gate.showGate(context);
            },
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 14),
          Text(
            'Delete all data',
            style: AppTextStyles.label.copyWith(
                color: AppColours.textDark, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Permanently removes all profiles, progress and sync data from this device.',
            style: AppTextStyles.label.copyWith(
                color: AppColours.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.4),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: const Text('Delete all data'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _deleteAllData(context, ref),
          ),
        ],
      ),
    );
  }
}

// ─── Shared card widget ───────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColours.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColours.lumiGold, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTextStyles.label.copyWith(
                  color: AppColours.textMuted,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
