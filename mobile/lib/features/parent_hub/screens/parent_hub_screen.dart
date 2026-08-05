import 'package:dio/dio.dart';
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

class _ParentHubScreenState extends ConsumerState<ParentHubScreen>
    with SingleTickerProviderStateMixin {
  bool _gateChecked = false;
  bool _gatePassed = false;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

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
    if (!passed) { context.go('/'); return; }
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
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Parent Hub',
          style: AppTextStyles.heading.copyWith(color: AppColours.textDark, fontSize: 20),
        ),
        actions: [
          const Icon(Icons.shield_rounded, color: AppColours.lumiGold, size: 20),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColours.lumiGold,
          unselectedLabelColor: AppColours.textMuted,
          indicatorColor: AppColours.lumiGold,
          indicatorWeight: 2,
          labelStyle: AppTextStyles.label.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTextStyles.label.copyWith(fontSize: 13),
          tabs: const [
            Tab(text: 'Children'),
            Tab(text: 'Activity'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Text('No child profile found.',
                  style: AppTextStyles.label.copyWith(color: AppColours.textMuted)),
            );
          }
          return TabBarView(
            controller: _tabs,
            children: [
              _ChildrenTab(activeProfileId: profile.id),
              _ActivityTab(profile: profile),
              _SettingsTab(profile: profile),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Something went wrong')),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 1 — CHILDREN
// ══════════════════════════════════════════════════════════════════════════════

class _ChildrenTab extends ConsumerStatefulWidget {
  const _ChildrenTab({required this.activeProfileId});
  final String activeProfileId;

  @override
  ConsumerState<_ChildrenTab> createState() => _ChildrenTabState();
}

class _ChildrenTabState extends ConsumerState<_ChildrenTab> {
  @override
  Widget build(BuildContext context) {
    final allProfilesAsync = ref.watch(allProfilesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        allProfilesAsync.when(
          data: (profiles) => _ProfileList(
            profiles: profiles,
            activeProfileId: widget.activeProfileId,
          ),
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        _AddChildButton(),
        const SizedBox(height: 24),
        _CoParentCard(),
      ],
    );
  }
}

// ─── Profile list ──────────────────────────────────────────────────────────────

class _ProfileList extends ConsumerWidget {
  const _ProfileList({
    required this.profiles,
    required this.activeProfileId,
  });

  final List<ChildProfile> profiles;
  final String activeProfileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title: 'CHILDREN',
      icon: Icons.people_alt_rounded,
      child: Column(
        children: [
          for (int i = 0; i < profiles.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            _ProfileTile(
              profile: profiles[i],
              isActive: profiles[i].id == activeProfileId,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileTile extends ConsumerWidget {
  const _ProfileTile({required this.profile, required this.isActive});
  final ChildProfile profile;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emoji = _resolveEmoji(profile.avatarId);
    final bandLabel = switch (profile.ageBand) {
      'early' => 'Early Learner · 3–5',
      'emerging' => 'Emerging Reader · 6–8',
      _ => 'Independent Reader · 9–12',
    };

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? AppColours.lumiGold.withValues(alpha: 0.15)
                : AppColours.parchment,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                bandLabel,
                style: AppTextStyles.label.copyWith(
                  color: AppColours.textMuted, fontSize: 12, fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        // Edit button — always shown
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          color: AppColours.textMuted,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
          tooltip: 'Edit',
          onPressed: () => _showEditSheet(context, ref),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColours.lumiGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColours.lumiGold, size: 13),
                const SizedBox(width: 3),
                Text('Active',
                    style: AppTextStyles.label.copyWith(color: AppColours.lumiGold, fontSize: 11)),
              ],
            ),
          )
        else ...[
          TextButton(
            onPressed: () => ref.read(profileRepositoryProvider).switchActive(profile.id),
            style: TextButton.styleFrom(
              foregroundColor: AppColours.sky,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Switch', style: TextStyle(fontSize: 12)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: Colors.red.shade400,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ],
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColours.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditProfileSheet(profile: profile),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text('Delete ${profile.nickname}?'),
            content: const Text(
              'All progress for this profile will be permanently deleted.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
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

// ─── Edit profile bottom sheet ─────────────────────────────────────────────────

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.profile});
  final ChildProfile profile;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nicknameCtrl;
  late String _ageBand;
  late String _avatar;
  bool _saving = false;

  static const _avatarEmojis = ['🦁', '🐑', '🕊️', '🐻', '🌟', '🌈', '🐣', '🦋'];

  @override
  void initState() {
    super.initState();
    _nicknameCtrl = TextEditingController(text: widget.profile.nickname);
    _ageBand = widget.profile.ageBand;
    // Resolve stored avatarId (legacy key or emoji string)
    _avatar = _resolveEmoji(widget.profile.avatarId);
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColours.textMuted.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Edit profile',
              style: AppTextStyles.heading.copyWith(color: AppColours.textDark, fontSize: 18)),
          const SizedBox(height: 20),

          // Nickname
          TextField(
            controller: _nicknameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nickname',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),

          // Age band
          Text('Reading level',
              style: AppTextStyles.label.copyWith(color: AppColours.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          _AgeBandPicker(
            value: _ageBand,
            onChanged: (v) => setState(() => _ageBand = v),
          ),
          const SizedBox(height: 20),

          // Avatar
          Text('Avatar',
              style: AppTextStyles.label.copyWith(color: AppColours.textMuted, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _avatarEmojis.map((e) {
              final selected = e == _avatar;
              return GestureDetector(
                onTap: () => setState(() => _avatar = e),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColours.lumiGold.withValues(alpha: 0.15)
                        : AppColours.parchment,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColours.lumiGold : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColours.textMuted.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColours.lumiGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nicknameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await ref.read(profileRepositoryProvider).editProfile(
      widget.profile.id,
      nickname: name,
      ageBand: _ageBand,
      avatarId: _avatar,
    );
    if (mounted) Navigator.of(context).pop();
  }

  static String _resolveEmoji(String avatarId) => switch (avatarId) {
        'lion' => '🦁',
        'lamb' => '🐑',
        'dove' => '🕊️',
        'bear' => '🐻',
        _ => avatarId,
      };
}

class _AgeBandPicker extends StatelessWidget {
  const _AgeBandPicker({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const bands = [
      ('early', 'Early Learner', '3–5'),
      ('emerging', 'Emerging Reader', '6–8'),
      ('independent', 'Independent Reader', '9–12'),
    ];
    return Row(
      children: bands.map((band) {
        final selected = band.$1 == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(band.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColours.lumiGold.withValues(alpha: 0.12)
                    : AppColours.parchment,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? AppColours.lumiGold.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    band.$2,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(
                      color: selected ? AppColours.lumiGold : AppColours.textDark,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    band.$3,
                    style: AppTextStyles.label.copyWith(
                      color: AppColours.textMuted, fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Add child button ──────────────────────────────────────────────────────────

class _AddChildButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddChildButton> createState() => _AddChildButtonState();
}

class _AddChildButtonState extends ConsumerState<_AddChildButton> {
  bool _showForm = false;
  final _ctrl = TextEditingController();
  String _band = 'early';
  String _avatar = '🦁';
  bool _saving = false;

  static const _avatarEmojis = ['🦁', '🐑', '🕊️', '🐻', '🌟', '🌈', '🐣', '🦋'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showForm) {
      return OutlinedButton.icon(
        icon: const Icon(Icons.person_add_rounded, size: 16),
        label: const Text('Add child'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColours.textDark,
          side: BorderSide(color: AppColours.textMuted.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        onPressed: () => setState(() {
          _showForm = true;
          _ctrl.clear();
          _band = 'early';
          _avatar = '🦁';
        }),
      );
    }

    return _SectionCard(
      title: 'NEW CHILD',
      icon: Icons.person_add_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nickname',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 14),
          Text('Reading level',
              style: AppTextStyles.label.copyWith(color: AppColours.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          _AgeBandPicker(value: _band, onChanged: (v) => setState(() => _band = v)),
          const SizedBox(height: 14),
          Text('Avatar',
              style: AppTextStyles.label.copyWith(color: AppColours.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _avatarEmojis.map((e) {
              final sel = e == _avatar;
              return GestureDetector(
                onTap: () => setState(() => _avatar = e),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: sel ? AppColours.lumiGold.withValues(alpha: 0.15) : AppColours.parchment,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: sel ? AppColours.lumiGold : Colors.transparent, width: 2),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: _saving ? null : () => setState(() => _showForm = false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(backgroundColor: AppColours.lumiGold),
                child: _saving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).createProfile(
          nickname: name, ageBand: _band, avatarEmoji: _avatar);
      if (mounted) setState(() { _showForm = false; _saving = false; });
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ─── Co-parent card ────────────────────────────────────────────────────────────

class _CoParentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'FAMILY ACCESS',
      icon: Icons.people_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your partner can open the Parent Hub using your family PIN. '
            'Share your PIN with them to give them full access to profiles, '
            'activity, and settings.',
            style: AppTextStyles.label.copyWith(
              color: AppColours.textMuted, fontSize: 13, height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            icon: const Icon(Icons.lock_outline_rounded, size: 16),
            label: const Text('View or change PIN'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColours.textDark,
              side: BorderSide(color: AppColours.textMuted.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final gate =
                  ProviderScope.containerOf(context).read(parentGateServiceProvider);
              await gate.setPin('');
              if (context.mounted) await gate.showGate(context);
            },
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 2 — ACTIVITY
// ══════════════════════════════════════════════════════════════════════════════

class _ActivityTab extends ConsumerWidget {
  const _ActivityTab({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        _WeeklySummary(profile: profile),
        const SizedBox(height: 20),
        _ConversationCard(profile: profile),
        const SizedBox(height: 20),
        _VerseSummaryCard(profile: profile),
      ],
    );
  }
}

// ─── Weekly summary ────────────────────────────────────────────────────────────

class _WeeklySummary extends ConsumerWidget {
  const _WeeklySummary({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(storyProgressRepositoryProvider);
    return FutureBuilder<List<StoryProgressData>>(
      future: _completedThisWeek(repo),
      builder: (context, snap) {
        final count = snap.data?.length ?? 0;
        return _SectionCard(
          title: 'THIS WEEK',
          icon: Icons.date_range_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatPill(label: '$count',
                      sublabel: count == 1 ? 'story' : 'stories',
                      color: AppColours.earth),
                  const SizedBox(width: 10),
                  _StatPill(label: '${profile.streakDays}',
                      sublabel: 'days active', color: AppColours.sky),
                  const SizedBox(width: 10),
                  _StatPill(label: '${profile.seeds}',
                      sublabel: 'seeds', color: AppColours.lumiGold),
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

  Future<List<StoryProgressData>> _completedThisWeek(StoryProgressRepository repo) async {
    final all = await repo.allCompletedForProfile(profile.id);
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return all.where((p) {
      final at = p.completedAt;
      return at != null && at.isAfter(weekAgo);
    }).toList();
  }
}

// ─── Conversation starter ──────────────────────────────────────────────────────

class _ConversationCard extends ConsumerWidget {
  const _ConversationCard({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentServiceProvider);
    final repo = ref.read(storyProgressRepositoryProvider);

    return FutureBuilder<StoryModel?>(
      future: _mostRecentStory(content, repo),
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
                    Text(story.title,
                        style: AppTextStyles.label.copyWith(
                            color: AppColours.lumiGold, fontSize: 12, letterSpacing: 0.5)),
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
                            Text('PARENT GUIDE',
                                style: AppTextStyles.label.copyWith(
                                    color: AppColours.lumiGold, fontSize: 10, letterSpacing: 1.5)),
                            const SizedBox(height: 4),
                            Text(story.steps.discuss.parentGuide,
                                style: AppTextStyles.label.copyWith(
                                    color: AppColours.textDark,
                                    fontSize: 13,
                                    height: 1.5,
                                    fontWeight: FontWeight.w400)),
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

  Future<StoryModel?> _mostRecentStory(ContentService c, StoryProgressRepository r) async {
    final completed = await r.allCompletedForProfile(profile.id);
    if (completed.isEmpty) return null;
    completed.sort((a, b) {
      final ta = a.completedAt ?? DateTime(2000);
      final tb = b.completedAt ?? DateTime(2000);
      return tb.compareTo(ta);
    });
    try { return await c.loadStory(completed.first.storyId); } catch (_) { return null; }
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
              'Verses your child practises will appear here.',
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
                        width: 10, height: 10,
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
                      Text(_stageLabel(v.stage),
                          style: AppTextStyles.label.copyWith(
                              color: AppColours.textMuted, fontSize: 11)),
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
            height: 24, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }

  Color _stageColour(String s) => switch (s) {
        'growing_familiar' => AppColours.earth,
        'understood' => AppColours.sky,
        'recalled' => AppColours.lumiGold,
        'recognised' => AppColours.coral,
        _ => AppColours.textMuted,
      };

  String _stageLabel(String s) => switch (s) {
        'growing_familiar' => 'Growing',
        'understood' => 'Understood',
        'recalled' => 'Recalled',
        'recognised' => 'Recognised',
        _ => 'Introduced',
      };
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 3 — SETTINGS
// ══════════════════════════════════════════════════════════════════════════════

class _SettingsTab extends ConsumerStatefulWidget {
  const _SettingsTab({required this.profile});
  final ChildProfile profile;

  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  late bool _autoplay;
  late bool _quietMode;
  late bool _soundEnabled;
  late bool _notifications;
  late bool _reducedMotion;
  late bool _wifiOnly;
  late bool _cloudSync;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _autoplay      = p.autoplayEnabled;
    _quietMode     = p.quietStoryMode;
    _soundEnabled  = p.musicEnabled;
    _notifications = p.notificationsEnabled;
    _reducedMotion = p.reducedMotion;
    _wifiOnly      = p.wifiOnlyDownloads;
    _cloudSync     = p.cloudSyncEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final storiesUsed =
        ref.watch(consumedStoryIdsProvider(widget.profile.id)).valueOrNull?.length ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        // ── Playback ──────────────────────────────────────────────────────────
        _SectionCard(
          title: 'PLAYBACK',
          icon: Icons.play_circle_outline_rounded,
          child: Column(
            children: [
              _ToggleRow(
                label: 'Autoplay narration',
                subtitle: 'Story audio plays automatically when a scene loads',
                value: _autoplay,
                onChanged: (v) async {
                  await ref.read(profileRepositoryProvider)
                      .updateSettings(widget.profile.id, autoplayEnabled: v);
                  if (mounted) setState(() => _autoplay = v);
                },
              ),
              const Divider(height: 24),
              _ToggleRow(
                label: 'Quiet Story Mode',
                subtitle: 'Reduces sound effects during story scenes',
                value: _quietMode,
                onChanged: (v) async {
                  await ref.read(profileRepositoryProvider)
                      .updateSettings(widget.profile.id, quietStoryMode: v);
                  if (mounted) setState(() => _quietMode = v);
                },
              ),
              const Divider(height: 24),
              _ToggleRow(
                label: 'Background music & effects',
                value: _soundEnabled,
                onChanged: _toggleSound,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Accessibility ─────────────────────────────────────────────────────
        _SectionCard(
          title: 'ACCESSIBILITY',
          icon: Icons.accessibility_new_rounded,
          child: Column(
            children: [
              _ToggleRow(
                label: 'Reduce motion & rewards',
                subtitle: 'Turns off animations and confetti effects',
                value: _reducedMotion,
                onChanged: (v) async {
                  await ref.read(profileRepositoryProvider)
                      .updateSettings(widget.profile.id, reducedMotion: v);
                  if (mounted) setState(() => _reducedMotion = v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Reminders ─────────────────────────────────────────────────────────
        _SectionCard(
          title: 'REMINDERS',
          icon: Icons.notifications_none_rounded,
          child: _ToggleRow(
            label: 'Weekly family reminders',
            subtitle: 'A gentle nudge each week to read together',
            value: _notifications,
            onChanged: _toggleNotifications,
          ),
        ),
        const SizedBox(height: 20),

        // ── Content & storage ─────────────────────────────────────────────────
        _SectionCard(
          title: 'CONTENT & STORAGE',
          icon: Icons.storage_rounded,
          child: Column(
            children: [
              _ToggleRow(
                label: 'Wi-Fi only downloads',
                value: _wifiOnly,
                onChanged: (v) async {
                  await ref.read(profileRepositoryProvider)
                      .updateSettings(widget.profile.id, wifiOnlyDownloads: v);
                  if (mounted) setState(() => _wifiOnly = v);
                },
              ),
              const Divider(height: 24),
              _ToggleRow(
                label: 'Cloud backup',
                subtitle: 'Syncs progress (no names, no identifiers)',
                value: _cloudSync,
                onChanged: (v) async {
                  if (v) {
                    final ok = await _showCloudDisclosure(context);
                    if (!ok) return;
                  }
                  await ref.read(profileRepositoryProvider)
                      .updateSettings(widget.profile.id, cloudSyncEnabled: v);
                  if (mounted) setState(() => _cloudSync = v);
                },
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Content access',
                      style: AppTextStyles.label.copyWith(
                          color: AppColours.textDark, fontSize: 14)),
                  Text(
                    widget.profile.isUnlocked
                        ? 'All stories unlocked'
                        : '$storiesUsed of $kFreeStoryAllowance free used',
                    style: AppTextStyles.label.copyWith(
                      color: widget.profile.isUnlocked
                          ? AppColours.earth
                          : AppColours.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Security ──────────────────────────────────────────────────────────
        _SectionCard(
          title: 'SECURITY',
          icon: Icons.lock_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your PIN keeps the Parent Hub private from your child.',
                style: AppTextStyles.label.copyWith(
                    color: AppColours.textMuted, fontSize: 13, height: 1.5,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Change PIN'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColours.textDark,
                  side: BorderSide(color: AppColours.textMuted.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final gate = ref.read(parentGateServiceProvider);
                  await gate.setPin('');
                  if (context.mounted) await gate.showGate(context);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Danger zone ───────────────────────────────────────────────────────
        _SectionCard(
          title: 'DATA & PRIVACY',
          icon: Icons.delete_forever_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Permanently removes all profiles, progress, and sync data from this device.',
                style: AppTextStyles.label.copyWith(
                    color: AppColours.textMuted, fontSize: 13, height: 1.5,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_forever_rounded, size: 16),
                label: const Text('Delete all data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _deleteAllData(context),
              ),
            ],
          ),
        ),
      ],
    );
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
    await ref.read(profileRepositoryProvider)
        .updateSettings(widget.profile.id, notificationsEnabled: enabled);
    if (mounted) setState(() => _notifications = enabled);
  }

  Future<bool> _showCloudDisclosure(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cloud backup'),
          content: const Text(
            'If enabled, Little Bible uploads only a random profile ID, story completion, broad learning topics, verse familiarity stage, and unlock status to Cloudflare D1. Nicknames, drawings, typed answers, voice, location, and device identifiers stay on this device. You can withdraw consent and delete cloud data at any time.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Not now')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('I agree')),
          ],
        ),
      ) ??
      false;

  Future<void> _deleteAllData(BuildContext context) async {
    final ctrl = TextEditingController();
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
                'All profiles, progress, and sync data will be permanently deleted.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text('Type DELETE to confirm:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
              onPressed: ctrl.text == 'DELETE' ? () => Navigator.pop(ctx, true) : null,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete permanently'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Best-effort: delete cloud data for any profiles that had sync enabled.
    final profiles = await ref.read(profileRepositoryProvider).all();
    final syncedIds = profiles
        .where((p) => p.cloudSyncEnabled)
        .map((p) => p.id)
        .toList();
    if (syncedIds.isNotEmpty) {
      try {
        await Dio().delete(
          'https://littlebible.org/api/mobile/account',
          data: {'profileIds': syncedIds},
          options: Options(
            contentType: 'application/json',
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
      } catch (_) {
        // Local deletion proceeds regardless — server-side data expires per
        // the privacy policy if the delete call cannot be delivered.
      }
    }

    final db = ref.read(databaseProvider);
    await db.deleteAllUserData();
    await ref.read(parentGateServiceProvider).setPin('');
    await ref.read(notificationServiceProvider).cancelAll();
    if (context.mounted) context.go('/onboarding');
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

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

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.label.copyWith(
                      color: AppColours.textDark, fontSize: 14)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: AppTextStyles.label.copyWith(
                        color: AppColours.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w400)),
              ],
            ],
          ),
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
          Text(label,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()])),
          Text(sublabel,
              style: AppTextStyles.label.copyWith(
                  color: color.withValues(alpha: 0.8), fontSize: 11)),
        ],
      ),
    );
  }
}
