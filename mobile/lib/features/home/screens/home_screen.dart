import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/story_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/verse_mastery_repository.dart';
import '../../../core/providers/story_progress_repository.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/narration_provider.dart';
import '../../../core/services/parent_gate_service.dart';
import '../../../core/router/app_router.dart';
import '../../lumi/widgets/lumi_widget.dart';
import '../../story/providers/story_provider.dart';
import '../../story/widgets/story_cover.dart';
import '../widgets/garden_painter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _idleTimer;
  bool _greetingPlayed = false;
  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playGreeting());
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  Future<void> _playGreeting() async {
    if (_greetingPlayed) return;
    final profile = ref.read(activeProfileProvider).valueOrNull;
    if (profile == null) return;
    _greetingPlayed = true;

    final narration = ref.read(narrationServiceProvider);
    final hour = DateTime.now().hour;
    final key = hour < 12
        ? 'lumi_greeting_morning'
        : hour < 18
            ? 'lumi_greeting_afternoon'
            : 'lumi_greeting_evening';
    await narration.speakUi(key, fallback: "Hi! Ready for a story?");

    if (!profile.hasSeenIntro) {
      await ref.read(profileRepositoryProvider).markIntroSeen(profile.id);
    }
    _resetIdleTimer();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 60), () {
      if (mounted) {
        ref.read(narrationServiceProvider)
            .speakUi('lumi_open_story', fallback: "Shall we open a story?");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(activeProfileProvider);

    return GestureDetector(
      onTap: _resetIdleTimer,
      child: Scaffold(
        backgroundColor: AppColours.cream,
        body: SafeArea(
          child: profileAsync.when(
            data: (profile) => profile == null
                ? const SizedBox.shrink()
                : _HomeBody(profile: profile),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => const Center(child: Text('Something went wrong')),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: AppColours.surface,
          selectedIndex: _selectedNav,
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
            setState(() => _selectedNav = i);
            if (i == 1) context.go(AppRoutes.bibleNav);
            if (i == 2) context.go(AppRoutes.parentHub);
          },
        ),
      ),
    );
  }
}

// ─── Home body ────────────────────────────────────────────────────────────────

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(allStoriesProvider);
    final completedIds =
        ref.watch(completedStoryIdsProvider(profile.id)).valueOrNull ??
            const <String>{};
    // Free-allowance meter: every story this child has opened, any status.
    final consumedIds =
        ref.watch(consumedStoryIdsProvider(profile.id)).valueOrNull ??
            const <String>{};

    return storiesAsync.when(
      data: (stories) => _Layout(
        profile: profile,
        stories: stories,
        completedIds: completedIds,
        consumedIds: consumedIds,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => const SizedBox.shrink(),
    );
  }
}

// ─── Main layout ──────────────────────────────────────────────────────────────

class _Layout extends StatefulWidget {
  const _Layout({
    required this.profile,
    required this.stories,
    required this.completedIds,
    required this.consumedIds,
  });

  final ChildProfile profile;
  final List<StoryModel> stories;
  final Set<String> completedIds;
  final Set<String> consumedIds;

  @override
  State<_Layout> createState() => _LayoutState();
}

class _LayoutState extends State<_Layout> {
  late int _selectedWorld;

  @override
  void initState() {
    super.initState();
    _selectedWorld = _worldIndexFor(widget.stories, widget.completedIds);
  }

  @override
  void didUpdateWidget(_Layout old) {
    super.didUpdateWidget(old);
    if (old.completedIds != widget.completedIds) {
      final newWorld = _worldIndexFor(widget.stories, widget.completedIds);
      // Auto-advance when the child moves into a later world; never go back.
      if (newWorld > _selectedWorld) {
        setState(() => _selectedWorld = newWorld);
      }
    }
  }

  /// Returns the world index containing the next uncompleted PLAYABLE story.
  int _worldIndexFor(List<StoryModel> stories, Set<String> completedIds) {
    // Walk worlds in order; find the first one that has an uncompleted, playable slot.
    for (int i = 0; i < _kWorlds.length; i++) {
      final world = _kWorlds[i];
      for (final slot in world.slots) {
        if (slot.comingSoon) continue;
        if (!stories.any((s) => s.id == slot.id)) continue; // no JSON yet
        if (!completedIds.contains(slot.id)) return i;
      }
    }
    return _kWorlds.length - 1; // all done — stay on last world
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final stories = widget.stories;
    final completedIds = widget.completedIds;

    final nextIndex = stories.indexWhere((s) => !completedIds.contains(s.id));
    final allDone = nextIndex == -1 && stories.isNotEmpty;
    // Never recycle a completed story as "UP NEXT" — show null when all done.
    final nextStory = (stories.isEmpty || allDone) ? null : stories[nextIndex];
    final isNextLocked = nextStory == null
        ? false
        : storyPaywallLocked(
            storyId: nextStory.id,
            profileUnlocked: profile.isUnlocked,
            consumedIds: widget.consumedIds,
          );

    final avatarEmoji = _avatarEmoji(profile.avatarId);

    return CustomScrollView(
      slivers: [
        // ── Header: greeting + avatar + garden ──────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar bubble
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColours.lumiGoldLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColours.lumiGold.withValues(alpha: 0.4),
                        width: 2),
                  ),
                  child: Center(
                    child: Text(avatarEmoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${profile.nickname}!',
                        style: AppTextStyles.heading.copyWith(
                            color: AppColours.textDark, fontSize: 22),
                      ),
                      Text(
                        _dayGreeting(),
                        style: AppTextStyles.label.copyWith(
                            color: AppColours.textMuted,
                            fontWeight: FontWeight.w400,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Profile chip + garden
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ProfileAvatarChip(profile: profile),
                    const SizedBox(height: 4),
                    GardenWidget(activeDaysThisWeek: profile.streakDays),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Lumi + ambient bubbles ────────────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 172,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const _AmbientBubbles(),
                LumiWidget(
                  state: allDone
                      ? LumiState.celebrate
                      : LumiState.idle,
                  // Lumi's body is ~52% of this box; the rest is headroom for
                  // the sprout and halo. 160 puts the body at ~84px.
                  size: 160,
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 2)),
        SliverToBoxAdapter(
          child: Center(
            child: Text(
              'Tap Lumi anytime!',
              style: AppTextStyles.label.copyWith(
                  color: AppColours.textMuted.withValues(alpha: 0.6),
                  fontSize: 11),
            ),
          ),
        ),

        // ── Verse practice card (if due) ──────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const SliverToBoxAdapter(child: _VersePracticeCard()),

        // ── Featured "next story" card ─────────────────────────────────────
        // ── "All caught up" banner when every story is done ──────────────────
        if (allDone) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF3CD), Color(0xFFFFE082)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('You\'ve read everything!',
                              style: AppTextStyles.heading.copyWith(
                                  fontSize: 15,
                                  color: const Color(0xFF92400E))),
                          const SizedBox(height: 2),
                          Text('More stories coming soon.',
                              style: AppTextStyles.label.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFB45309))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        // ── Featured "next story" card ─────────────────────────────────────
        if (nextStory != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Text(
                completedIds.isEmpty ? 'START HERE' : 'UP NEXT',
                style: AppTextStyles.label.copyWith(
                  color: AppColours.textMuted,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _FeaturedStoryCard(
                story: nextStory,
                locked: isNextLocked,
                isCompleted: false,
              ),
            ),
          ),
        ],

        // ── Curriculum world map ───────────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
            child: Text(
              'YOUR JOURNEY',
              style: AppTextStyles.label.copyWith(
                color: AppColours.textMuted,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        // World selector chip bar
        SliverToBoxAdapter(
          child: _WorldChipBar(
            selectedIndex: _selectedWorld,
            onSelect: (i) => setState(() => _selectedWorld = i),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Single selected world
        SliverToBoxAdapter(
          child: _WorldSection(
            world: _kWorlds[_selectedWorld],
            worldIndex: _selectedWorld,
            allStories: stories,
            completedIds: completedIds,
            consumedIds: widget.consumedIds,
            profileUnlocked: profile.isUnlocked,
            ageBand: profile.ageBand,
            allowGuided: profile.allowGuidedStories,
            onNextWorld: _selectedWorld < _kWorlds.length - 1
                ? () => setState(() => _selectedWorld++)
                : null,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  String _dayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  String _avatarEmoji(String avatarId) => switch (avatarId) {
        'lion' => '🦁',
        'lamb' => '🐑',
        'dove' => '🕊️',
        'bear' => '🐻',
        // New profiles store emoji strings directly.
        _ => avatarId,
      };
}

// ─── Profile avatar chip (top-right, read-only indicator) ────────────────────

class _ProfileAvatarChip extends StatelessWidget {
  const _ProfileAvatarChip({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    final emoji = _resolveEmoji(profile.avatarId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColours.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColours.lumiGold.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13, height: 1.2)),
          const SizedBox(width: 4),
          Text(
            profile.nickname,
            style: AppTextStyles.label.copyWith(
              color: AppColours.textDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static String _resolveEmoji(String avatarId) => switch (avatarId) {
        'lion' => '🦁',
        'lamb' => '🐑',
        'dove' => '🕊️',
        'bear' => '🐻',
        _ => avatarId,
      };
}

// The free allowance lives in story_progress_repository.dart as
// `kFreeStoryAllowance` + `storyPaywallLocked`. It is consumption-based — any 20
// stories the child opens are free — so it must never be reintroduced here as a
// positional "first N in curriculum order" check.

// ─── Story slot: available (has content) or coming soon ──────────────────────

class _StorySlot {
  final String id;
  final String title;
  final String emoji;
  final bool comingSoon;

  // `comingSoon` currently has no callers: all 80 curriculum stories are built.
  // It is kept deliberately — it is how a slot is placed on the map before its
  // JSON exists, which is exactly what the next content phase will need.
  // ignore: unused_element_parameter
  const _StorySlot(this.id, this.title, {this.emoji = '📖', this.comingSoon = false});
}

StoryModel? _findStory(List<StoryModel> stories, String id) {
  final matches = stories.where((s) => s.id == id);
  return matches.isEmpty ? null : matches.first;
}

// ─── Discipleship curriculum worlds ──────────────────────────────────────────

class _WorldDef {
  const _WorldDef({
    required this.title,
    required this.shortTitle,
    required this.emoji,
    required this.color,
    required this.description,
    required this.slots,
  });
  final String title;
  final String shortTitle; // 1-2 words for chip bar
  final String emoji;
  final Color color;
  final String description;
  final List<_StorySlot> slots;
}

const _kWorlds = [
  // ── World 1: In the Beginning (#1–8) ────────────────────────────────────
  _WorldDef(
    title: 'In the Beginning',
    shortTitle: 'Beginning',
    emoji: '🌟',
    color: Color(0xFF0EA5E9),
    description: 'God made the world — and you!',
    slots: [
      _StorySlot('god-made-everything',   'God Made Everything',               emoji: '🌍'),
      _StorySlot('god-made-me',            'God Made Me',                       emoji: '🧒'),
      _StorySlot('the-first-family',       'The First Family with God',          emoji: '🌿'),
      _StorySlot('the-very-sad-choice',    'The Very Sad Choice',               emoji: '🍎'),
      _StorySlot('god-promises-a-rescuer', 'God Promises a Rescuer',            emoji: '⭐'),
      _StorySlot('two-brothers',           'Two Brothers and Jealous Hearts',   emoji: '🌾'),
      _StorySlot('noahs-big-boat',         'Noah\'s Big Boat',                  emoji: '🚢'),
      _StorySlot('noahs-rainbow-promise',  'Noah\'s Rainbow Promise',           emoji: '🌈'),
    ],
  ),

  // ── World 2: Promise Family (#9–16) — all coming soon ───────────────────
  _WorldDef(
    title: 'Promise Family',
    shortTitle: 'Promise',
    emoji: '🌌',
    color: Color(0xFF8B5CF6),
    description: 'Abraham, Isaac, Jacob, Joseph — faith and covenant',
    slots: [
      _StorySlot('the-tall-tower',              'The Tall Tower',                  emoji: '🗼'),
      _StorySlot('god-calls-abraham',            'God Calls Abraham',               emoji: '🐫'),
      _StorySlot('stars-in-the-sky',             'Stars in the Sky',                emoji: '✨'),
      _StorySlot('the-promised-son',             'The Promised Son',                emoji: '👶'),
      _StorySlot('god-provides-a-lamb',          'God Provides a Lamb',             emoji: '🐏'),
      _StorySlot('jacob-learns-grace',           'Jacob Learns Grace',              emoji: '🪜'),
      _StorySlot('joseph-and-his-brothers',      'Joseph and His Jealous Brothers', emoji: '🧥'),
      _StorySlot('joseph-forgives-his-family',   'Joseph Forgives His Family',      emoji: '🤗'),
    ],
  ),

  // ── World 3: God Rescues a People (#17–24) — all coming soon ────────────
  _WorldDef(
    title: 'God Rescues a People',
    shortTitle: 'Rescue',
    emoji: '🔥',
    color: Color(0xFFF97316),
    description: 'Moses, the Exodus, the Law, and the Tabernacle',
    slots: [
      _StorySlot('baby-moses-is-kept-safe',      'Baby Moses Is Kept Safe',        emoji: '🧺'),
      _StorySlot('god-calls-from-the-fire',      'God Calls from the Fire',        emoji: '🔥'),
      _StorySlot('let-my-people-go',             'Let My People Go',               emoji: '🏛️'),
      _StorySlot('the-passover-lamb',            'The Passover Lamb',              emoji: '🚪'),
      _StorySlot('a-way-through-the-sea',        'A Way Through the Sea',          emoji: '🌊'),
      _StorySlot('bread-in-the-wilderness',      'Bread in the Wilderness',        emoji: '🍞'),
      _StorySlot('gods-good-commands',           'God\'s Good Commands',           emoji: '📜'),
      _StorySlot('god-lives-with-his-people',    'God Lives with His People',      emoji: '🕍'),
    ],
  ),

  // ── World 4: A Land Needing a King (#25–32) ──────────────────────────────
  _WorldDef(
    title: 'A Land Needing a King',
    shortTitle: 'Kingdom',
    emoji: '🏰',
    color: Color(0xFF10B981),
    description: 'Joshua, Judges, Samuel — before David',
    slots: [
      _StorySlot('twelve-spies',                 'Twelve Spies and Two Trusting Hearts', emoji: '🍇'),
      _StorySlot('joshua-and-the-walls',         'Joshua and the Strong Walls',          emoji: '🏰'),
      _StorySlot('deborah-leads-gods-people',    'Deborah Leads God\'s People',          emoji: '🌴'),
      _StorySlot('gideons-tiny-army',            'Gideon\'s Tiny Army',                  emoji: '🏺'),
      _StorySlot('ruth-finds-a-home',            'Ruth Finds a Home',                    emoji: '🌾'),
      _StorySlot('samuel-listens-to-god',        'Samuel Listens to God',                emoji: '🕯️'),
      _StorySlot('saul-the-king',                'Saul: The King Who Would Not Listen',  emoji: '👑'),
      _StorySlot('david-the-shepherd-boy',       'David the Shepherd Boy',               emoji: '🎸'),
    ],
  ),

  // ── World 5: Heroes of Faith (#33–40) ───────────────────────────────────
  _WorldDef(
    title: 'Heroes of Faith',
    shortTitle: 'Heroes',
    emoji: '🦁',
    color: Color(0xFF059669),
    description: 'David, Jonah, Daniel and the prophets',
    slots: [
      _StorySlot('david-and-the-giant',              'David and the Giant',             emoji: '🪨'),
      _StorySlot('davids-sin-and-gods-mercy',        'David\'s Sin and God\'s Mercy',   emoji: '💧'),
      _StorySlot('gods-forever-king-promise',        'God\'s Forever-King Promise',     emoji: '👑'),
      _StorySlot('solomon-asks-for-wisdom',          'Solomon Asks for Wisdom',         emoji: '📚'),
      _StorySlot('elijah-and-the-only-true-god',     'Elijah and the Only True God',    emoji: '🔥'),
      _StorySlot('jonah-and-the-big-fish',           'Jonah and the Big Fish',          emoji: '🐋'),
      _StorySlot('daniel-and-the-lions',             'Daniel and the Lions',            emoji: '🦁'),
      _StorySlot('the-prophets-promise-new-hearts',  'The Prophets Promise New Hearts', emoji: '💚'),
    ],
  ),

  // ── World 6: Jesus Is Here (#41–48) ─────────────────────────────────────
  _WorldDef(
    title: 'Jesus Is Here',
    shortTitle: 'Jesus Born',
    emoji: '⭐',
    color: Color(0xFFF59E0B),
    description: "God's Son came to love and save us",
    slots: [
      _StorySlot('an-angel-visits-mary',         'An Angel Visits Mary',            emoji: '🕊️'),
      _StorySlot('birth-of-jesus',               'Birth of Jesus',                  emoji: '⭐'),
      _StorySlot('visitors-worship-the-king',    'Visitors Worship the King',       emoji: '👑'),
      _StorySlot('jesus-grows-and-obeys',        'Jesus Grows and Obeys',           emoji: '🌱'),
      _StorySlot('jesus-is-baptised',            'Jesus Is Baptised',               emoji: '💧'),
      _StorySlot('jesus-says-no-to-tempter',     'Jesus Says No to the Tempter',    emoji: '🚫'),
      _StorySlot('jesus-calls-his-helpers',      'Jesus Calls His Helpers',         emoji: '🎣'),
      _StorySlot('jesus-loves-children',         'Jesus Loves Children',            emoji: '❤️'),
    ],
  ),

  // ── World 7: The Compassionate King (#49–56) ─────────────────────────────
  _WorldDef(
    title: 'The Compassionate King',
    shortTitle: 'Teaching',
    emoji: '🕊️',
    color: Color(0xFF6366F1),
    description: 'Jesus teaches and shows God\'s love',
    slots: [
      _StorySlot('jesus-calms-the-storm',        'Jesus Calms the Storm',           emoji: '🌊'),
      _StorySlot('jesus-heals-and-forgives',     'Jesus Heals and Forgives',        emoji: '❤️'),
      _StorySlot('jesus-feeds-the-crowd',        'Jesus Feeds the Crowd',           emoji: '🍞'),
      _StorySlot('the-good-neighbour',           'The Good Neighbour',              emoji: '🤝'),
      _StorySlot('the-lost-sheep',               'The Lost Sheep',                  emoji: '🐑'),
      _StorySlot('the-lost-son',                 'The Lost Son',                    emoji: '👐'),
      _StorySlot('how-to-pray',                  'How to Pray',                     emoji: '🙏'),
      _StorySlot('the-good-shepherd',            'The Good Shepherd',               emoji: '🐑'),
    ],
  ),

  // ── World 8: Jesus Saves (#57–64) ────────────────────────────────────────
  _WorldDef(
    title: 'Jesus Saves',
    shortTitle: 'The Cross',
    emoji: '✝️',
    color: Color(0xFFEF4444),
    description: 'The most important story ever told',
    slots: [
      _StorySlot('jesus-raises-lazarus',         'Jesus Raises Lazarus',            emoji: '🌹'),
      _StorySlot('the-king-rides-in',            'The King Rides into Jerusalem',   emoji: '🌴'),
      _StorySlot('servant-king-washes-feet',     'The Servant King Washes Feet',   emoji: '🪣'),
      _StorySlot('the-last-supper',              'The Last Supper',                 emoji: '🍷'),
      _StorySlot('jesus-prays-in-garden',        'Jesus Prays in the Garden',       emoji: '🌿'),
      _StorySlot('jesus-dies-for-sinners',       'Jesus Dies for Sinners',          emoji: '✝️'),
      _StorySlot('jesus-is-alive',               'Jesus Is Alive',                  emoji: '🌅'),
      _StorySlot('jesus-saves',                  'Jesus Saves',                     emoji: '✝️'),
    ],
  ),

  // ── World 9: Spirit-Filled Family (#65–72) — all coming soon ────────────
  _WorldDef(
    title: 'Spirit-Filled Family',
    shortTitle: 'The Spirit',
    emoji: '🔥',
    color: Color(0xFF0EA5E9),
    description: 'Pentecost through the fruit of the Spirit',
    slots: [
      _StorySlot('jesus-returns-to-his-father', 'Jesus Returns to His Father',      emoji: '☁️'),
      _StorySlot('the-holy-spirit-comes',       'The Holy Spirit Comes',            emoji: '🔥'),
      _StorySlot('a-new-sharing-family',        'A New Sharing Family',             emoji: '🫂'),
      _StorySlot('stephen-sees-jesus',          'Stephen Sees Jesus',               emoji: '👁️'),
      _StorySlot('saul-meets-the-risen-jesus',  'Saul Meets the Risen Jesus',       emoji: '⚡'),
      _StorySlot('peter-welcomes-cornelius',    'Peter Welcomes Cornelius',         emoji: '🤝'),
      _StorySlot('paul-and-silas-in-prison',    'Paul and Silas Sing in Prison',    emoji: '🎵'),
      _StorySlot('the-spirit-grows-good-fruit', 'The Spirit Grows Good Fruit',      emoji: '🍎'),
    ],
  ),

  // ── World 10: The King Makes All Things New (#73–80) — all coming soon ──
  _WorldDef(
    title: 'The King Makes All Things New',
    shortTitle: 'New World',
    emoji: '🌈',
    color: Color(0xFF7C3AED),
    description: 'Hope, perseverance, and the new creation',
    slots: [
      _StorySlot('gods-armour-for-hard-days',   'God\'s Armour for Hard Days',     emoji: '🛡️'),
      _StorySlot('when-anger-knocks',           'When Anger Knocks',               emoji: '😤'),
      _StorySlot('when-i-feel-alone',           'When I Feel Alone',               emoji: '💙'),
      _StorySlot('when-life-feels-unfair',      'When Life Feels Unfair',          emoji: '⚖️'),
      _StorySlot('when-someone-we-love-dies',   'When Someone We Love Dies',       emoji: '🕊️'),
      _StorySlot('jesus-will-come-again',       'Jesus Will Come Again',           emoji: '☁️'),
      _StorySlot('the-king-judges',             'The King Judges and Raises the Dead', emoji: '⚖️'),
      _StorySlot('god-makes-everything-new',    'God Makes Everything New',        emoji: '🌈'),
    ],
  ),
];

// ─── World selector chip bar ──────────────────────────────────────────────────

class _WorldChipBar extends StatefulWidget {
  const _WorldChipBar({required this.selectedIndex, required this.onSelect});
  final int selectedIndex;
  final void Function(int) onSelect;

  @override
  State<_WorldChipBar> createState() => _WorldChipBarState();
}

class _WorldChipBarState extends State<_WorldChipBar> {
  final ScrollController _scroll = ScrollController();

  @override
  void didUpdateWidget(_WorldChipBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      // Scroll the selected chip into view with a slight offset.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        final chipW = 120.0; // approx per chip + gap
        final target = (widget.selectedIndex * chipW)
            .clamp(0.0, _scroll.position.maxScrollExtent);
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _kWorlds.length,
        separatorBuilder: (_, $) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final world = _kWorlds[i];
          final selected = i == widget.selectedIndex;
          return GestureDetector(
            onTap: () => widget.onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? world.color : AppColours.surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: selected ? world.color : const Color(0xFFE7E5E4),
                  width: selected ? 0 : 1.5,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: world.color.withValues(alpha: 0.30), blurRadius: 10, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(world.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    world.shortTitle,
                    style: AppTextStyles.label.copyWith(
                      color: selected ? Colors.white : AppColours.textMuted,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Featured story card (large, glowing, prominent) ─────────────────────────

class _FeaturedStoryCard extends StatelessWidget {
  const _FeaturedStoryCard({
    required this.story,
    required this.locked,
    required this.isCompleted,
  });

  final StoryModel story;
  final bool locked;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked
          ? () => context.push(AppRoutes.unlock)
          : () => context.go('/story/${story.id}'),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColours.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: story.coverColor.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            if (!locked && !isCompleted)
              BoxShadow(
                color: AppColours.lumiGold.withValues(alpha: 0.18),
                blurRadius: 36,
                spreadRadius: 2,
              ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Cover illustration — full width
            Positioned.fill(
              child: StoryCover(storyId: story.id, size: double.infinity),
            ),
            // Gradient overlay for legibility
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Text overlay (bottom)
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (story.collection.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColours.lumiGold.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        story.collection
                            .replaceAll('-', ' ')
                            .toUpperCase(),
                        style: AppTextStyles.label.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            letterSpacing: 1.2),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    story.title,
                    style: AppTextStyles.heading.copyWith(
                        color: Colors.white, fontSize: 20),
                  ),
                  if (story.subtitle.isNotEmpty)
                    Text(
                      story.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                ],
              ),
            ),
            // Lock badge
            if (locked)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            // Completed badge
            if (isCompleted && !locked)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColours.earth,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 15),
                ),
              ),
            // "Start" / "Continue" pill
            if (!locked)
              Positioned(
                top: 14,
                right: isCompleted ? 52 : 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColours.lumiGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCompleted ? 'Read again' : 'Start',
                    style: AppTextStyles.label.copyWith(
                      color: isCompleted
                          ? AppColours.textDark
                          : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Verse practice card (shown when nextReviewDate ≤ today) ─────────────────

class _VersePracticeCard extends ConsumerWidget {
  const _VersePracticeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);
    final profile = profileAsync.valueOrNull;
    if (profile == null) return const SizedBox.shrink();

    return FutureBuilder<VerseMasteryData?>(
      future: ref.read(verseMasteryRepositoryProvider).oldestDueVerse(profile.id),
      builder: (context, snap) {
        final due = snap.data;
        if (due == null || due.storyId.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: GestureDetector(
            onTap: () => context.go('/practice/${due.storyId}'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColours.lumiGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColours.lumiGold.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColours.lumiGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: AppColours.lumiGold, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VERSE TO PRACTISE',
                          style: AppTextStyles.label.copyWith(
                            color: AppColours.lumiGold,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          due.verseRef.isEmpty
                              ? 'A verse from your stories'
                              : due.verseRef,
                          style: AppTextStyles.label.copyWith(
                            color: AppColours.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColours.lumiGold, size: 22),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Ambient floating bubbles (mirrors the web hero dots) ────────────────────

class _AmbientBubbles extends StatefulWidget {
  const _AmbientBubbles();

  @override
  State<_AmbientBubbles> createState() => _AmbientBubblesState();
}

class _AmbientBubblesState extends State<_AmbientBubbles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Fixed random positions (fraction of container width/height)
  // Each bubble: (x, y, radius, phase offset for independent drift)
  static const _bubbles = [
    (0.15, 0.55, 5.0,  0.0),
    (0.82, 0.35, 7.0,  0.4),
    (0.25, 0.20, 4.0,  0.7),
    (0.68, 0.70, 6.0,  0.2),
    (0.50, 0.10, 3.5,  0.9),
    (0.90, 0.60, 4.5,  0.5),
    (0.08, 0.75, 6.5,  0.1),
    (0.38, 0.82, 4.0,  0.6),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return const SizedBox.expand();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _BubblePainter(_ctrl.value, _bubbles),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter(this.t, this.bubbles);
  final double t;
  final List<(double, double, double, double)> bubbles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (bx, by, br, phase) in bubbles) {
      final driftY = math.sin((t + phase) * 2 * math.pi) * 5;
      final driftX = math.cos((t + phase) * math.pi) * 2.5;
      final opacity = 0.12 + 0.08 * math.sin((t + phase) * 2 * math.pi);

      final paint = Paint()
        ..color = AppColours.lumiGold.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(size.width * bx + driftX, size.height * by + driftY),
        br,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.t != t;
}

// ─── Curriculum world section ─────────────────────────────────────────────────

class _WorldSection extends StatelessWidget {
  const _WorldSection({
    required this.world,
    required this.worldIndex,
    required this.allStories,
    required this.completedIds,
    required this.consumedIds,
    required this.profileUnlocked,
    required this.ageBand,
    required this.allowGuided,
    this.onNextWorld,
  });

  final _WorldDef world;
  final int worldIndex;
  final List<StoryModel> allStories;
  final Set<String> completedIds;
  final Set<String> consumedIds;
  final bool profileUnlocked;

  /// 'early' | 'emerging' | 'independent' — decides which stories ask for a
  /// grown-up before they open.
  final String ageBand;

  /// Parent has approved guided stories for this child in the Parent Hub.
  final bool allowGuided;
  final VoidCallback? onNextWorld;

  @override
  Widget build(BuildContext context) {
    final slots = world.slots;
    final totalSlots = slots.length;

    // Playable = not flagged comingSoon AND has a loaded story JSON.
    final playableSlots = slots
        .where((s) => !s.comingSoon && allStories.any((st) => st.id == s.id))
        .toList();
    final completedCount =
        playableSlots.where((s) => completedIds.contains(s.id)).length;
    final worldDone =
        playableSlots.isNotEmpty && completedCount == playableSlots.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── World header banner ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: world.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: world.color.withValues(alpha: 0.28)),
            ),
            child: Row(
              children: [
                Text(world.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        world.title,
                        style: AppTextStyles.label.copyWith(
                          color: AppColours.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        world.description,
                        style: AppTextStyles.label.copyWith(
                          color: AppColours.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: worldDone ? world.color : AppColours.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: worldDone
                          ? world.color
                          : world.color.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (worldDone) ...[
                        const Icon(Icons.check_rounded,
                            color: Colors.white, size: 11),
                        const SizedBox(width: 3),
                      ],
                      Text(
                        worldDone
                            ? 'Done'
                            : playableSlots.isEmpty
                                ? 'Coming Soon'
                                : '$completedCount / ${playableSlots.length}',
                        style: AppTextStyles.label.copyWith(
                          color: worldDone ? Colors.white : world.color,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── World complete CTA ──────────────────────────────────────────
          if (worldDone && onNextWorld != null) ...[
            const SizedBox(height: 16),
            _WorldCompleteBanner(
              world: world,
              onNextWorld: onNextWorld!,
            ),
          ],

          // ── Story path tiles (available + coming soon) ─────────────────
          ...List.generate(totalSlots, (i) {
            final slot = slots[i];
            final isLast = i == totalSlots - 1;

            if (slot.comingSoon) {
              return _ComingSoonTile(
                slot: slot,
                isLast: isLast,
                accentColor: world.color,
              );
            }

            final story = _findStory(allStories, slot.id);
            if (story == null) {
              // Slot is marked available but story JSON not loaded yet
              return _ComingSoonTile(
                slot: slot,
                isLast: isLast,
                accentColor: world.color,
              );
            }

            final isCompleted = completedIds.contains(story.id);

            // Sequential lock: find nearest previous available-and-loaded slot
            String? prevAvailId;
            for (int j = i - 1; j >= 0; j--) {
              final prev = slots[j];
              if (!prev.comingSoon &&
                  allStories.any((a) => a.id == prev.id)) {
                prevAvailId = prev.id;
                break;
              }
            }
            final prevDone =
                prevAvailId == null || completedIds.contains(prevAvailId);
            final paywallLocked = storyPaywallLocked(
              storyId: story.id,
              profileUnlocked: profileUnlocked,
              consumedIds: consumedIds,
            );
            final isLocked = !prevDone || paywallLocked;

            return _MapTile(
              story: story,
              isCompleted: isCompleted,
              isLocked: isLocked,
              isPaywallLocked: paywallLocked,
              needsGrownUp: storyNeedsGrownUp(
                tier: story.sensitivityTier,
                ageBand: ageBand,
                allowGuided: allowGuided,
              ),
              isLast: isLast,
              accentColor: world.color,
            );
          }),
        ],
      ),
    );
  }
}

// ─── Single map tile (path node + story card) ─────────────────────────────────

class _MapTile extends ConsumerWidget {
  const _MapTile({
    required this.story,
    required this.isCompleted,
    required this.isLocked,
    required this.isPaywallLocked,
    required this.needsGrownUp,
    required this.isLast,
    required this.accentColor,
  });

  final StoryModel story;
  final bool isCompleted;
  final bool isLocked;
  final bool isPaywallLocked;

  /// This story's sensitivity tier is above the child's band, so it asks for a
  /// grown-up before opening. It is still shown — never silently removed.
  final bool needsGrownUp;
  final bool isLast;
  final Color accentColor;

  /// Explains why a grown-up is wanted, then asks for the parent PIN.
  ///
  /// This is the path that used to not exist: content above the child's band was
  /// dropped from the feed entirely, so a parent was never asked and had no way
  /// to let their child in. Now they are told what the story covers and can
  /// decide.
  Future<void> _openWithGrownUp(BuildContext context, WidgetRef ref) async {
    final proceed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GrownUpSheet(story: story),
    );
    if (proceed != true || !context.mounted) return;

    final ok = await ref.read(parentGateServiceProvider).showGate(context);
    if (!ok || !context.mounted) return;
    context.go('/story/${story.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNext = !isCompleted && !isLocked;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Path column: vertical line + circle node ─────────────────
          SizedBox(
            width: 36,
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Circle node
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? accentColor
                        : isNext
                            ? AppColours.lumiGold.withValues(alpha: 0.12)
                            : AppColours.parchment,
                    border: Border.all(
                      color: isCompleted
                          ? accentColor
                          : isNext
                              ? AppColours.lumiGold
                              : const Color(0xFFD6D3D1),
                      width: isNext ? 2 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 13)
                        : isLocked
                            ? Icon(Icons.lock_rounded,
                                color: AppColours.textSubtle
                                    .withValues(alpha: 0.6),
                                size: 11)
                            : Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColours.lumiGold,
                                ),
                              ),
                  ),
                ),
                // Connecting path line down to next tile
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: isCompleted
                            ? accentColor.withValues(alpha: 0.35)
                            : const Color(0xFFE7E5E4),
                      ),
                    ),
                  ),
                if (!isLast) const SizedBox(height: 0),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Story card ───────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: isLocked
                  ? (isPaywallLocked
                      ? () => context.push(AppRoutes.unlock)
                      : null)
                  : needsGrownUp
                      ? () => _openWithGrownUp(context, ref)
                      : () => context.go('/story/${story.id}'),
              child: Opacity(
                opacity: isLocked && !isPaywallLocked ? 0.42 : 1.0,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 6,
                    bottom: isLast ? 0 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColours.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: isNext
                        ? Border.all(
                            color:
                                AppColours.lumiGold.withValues(alpha: 0.5),
                            width: 1.5)
                        : Border.all(
                            color: const Color(0xFFE7E5E4)),
                    boxShadow: isNext
                        ? [
                            BoxShadow(
                              color: AppColours.lumiGold
                                  .withValues(alpha: 0.14),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: Row(
                    children: [
                      // Story cover thumbnail
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: SizedBox(
                          width: 68,
                          height: 68,
                          child: StoryCover(storyId: story.id, size: 68),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title + reference
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.title,
                              style: AppTextStyles.cardTitle.copyWith(
                                color: isLocked
                                    ? AppColours.textSubtle
                                    : AppColours.textDark,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (story.bibleRef.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                story.bibleRef,
                                style: AppTextStyles.label.copyWith(
                                  color: AppColours.textSubtle,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            // Says WHY this one is different. Without it, a
                            // gated story is indistinguishable from an unbuilt
                            // one, which is how a third of the curriculum came
                            // to look like missing content.
                            if (needsGrownUp) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColours.coral.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people_rounded,
                                        size: 10, color: AppColours.coral),
                                    const SizedBox(width: 3),
                                    Text(
                                      'With a grown-up',
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColours.coral,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // State indicator
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: isCompleted
                            ? Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14),
                              )
                            : isPaywallLocked
                                ? const Icon(Icons.lock_rounded,
                                    color: AppColours.textSubtle,
                                    size: 18)
                                : isLocked
                                    ? const SizedBox.shrink()
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 11, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: AppColours.lumiGold,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Start',
                                          style:
                                              AppTextStyles.label.copyWith(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── World complete banner ───────────────────────────────────────────────────

class _WorldCompleteBanner extends StatelessWidget {
  const _WorldCompleteBanner({
    required this.world,
    required this.onNextWorld,
  });

  final _WorldDef world;
  final VoidCallback onNextWorld;

  @override
  Widget build(BuildContext context) {
    final nextIndex = _kWorlds.indexOf(world) + 1;
    final nextWorld = nextIndex < _kWorlds.length ? _kWorlds[nextIndex] : null;

    return GestureDetector(
      onTap: onNextWorld,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              world.color.withValues(alpha: 0.15),
              nextWorld != null
                  ? nextWorld.color.withValues(alpha: 0.15)
                  : world.color.withValues(alpha: 0.08),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: world.color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            // Trophy emoji + starburst
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: world.color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'World complete! 🎉',
                    style: AppTextStyles.label.copyWith(
                      color: world.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nextWorld != null
                        ? 'Ready for ${nextWorld.emoji} ${nextWorld.title}?'
                        : 'You\'ve finished the journey!',
                    style: AppTextStyles.label.copyWith(
                      color: AppColours.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: world.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Coming soon placeholder tile ────────────────────────────────────────────

class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile({
    required this.slot,
    required this.isLast,
    required this.accentColor,
  });

  final _StorySlot slot;
  final bool isLast;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Path column ──────────────────────────────────────────────
          SizedBox(
            width: 36,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColours.parchment,
                    border: Border.all(
                        color: const Color(0xFFD6D3D1), width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      '…',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFFA8A29E)),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                          width: 2, color: const Color(0xFFE7E5E4)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Placeholder card ─────────────────────────────────────────
          Expanded(
            child: Opacity(
              opacity: 0.52,
              child: Container(
                margin: EdgeInsets.only(
                  top: 6,
                  bottom: isLast ? 0 : 10,
                ),
                decoration: BoxDecoration(
                  color: AppColours.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7E5E4)),
                ),
                child: Row(
                  children: [
                    // Emoji thumbnail
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F4),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Text(slot.emoji,
                            style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        slot.title,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColours.textSubtle,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFD6D3D1)),
                        ),
                        child: Text(
                          'Soon',
                          style: AppTextStyles.label.copyWith(
                            color: AppColours.textSubtle,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grown-up sheet ───────────────────────────────────────────────────────────

/// Shown when a child taps a story whose sensitivity tier is above their age
/// band. It names what the story deals with and offers to open it together,
/// behind the parent PIN.
///
/// The app used to just remove these stories from the feed. A parent never saw
/// them, was never asked, and had no way to say yes — so a third of the
/// curriculum was unreachable without anybody knowing why.
class _GrownUpSheet extends StatelessWidget {
  const _GrownUpSheet({required this.story});

  final StoryModel story;

  bool get _isHeaviest => story.sensitivityTier == 'parental_presence';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColours.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E5E4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Icon(Icons.favorite_rounded,
                      color: AppColours.coral, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Read this one together',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColours.textDark,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                story.title,
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColours.textMuted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isHeaviest
                    ? 'This story deals with something hard, and it is written to '
                        'be read with a grown-up beside you. There is a guide for '
                        'them inside.'
                    : 'This story has a part in it that is easier to understand '
                        'with a grown-up nearby. There is a guide for them inside.',
                style: AppTextStyles.label.copyWith(
                  color: AppColours.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColours.lumiGold,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Fetch a grown-up',
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Not now',
                    style: AppTextStyles.label.copyWith(
                      color: AppColours.textSubtle,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Grown-ups can turn this off for every story in Parent Hub.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: AppColours.textSubtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
