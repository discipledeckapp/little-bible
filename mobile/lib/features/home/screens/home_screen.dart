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
import '../../../core/services/narration_provider.dart';
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
        // 2-item child nav — Parent Hub is behind Lumi long-press, not here
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
          ],
          onDestinationSelected: (i) {
            setState(() => _selectedNav = i);
            if (i == 1) context.go(AppRoutes.bibleNav);
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

    return storiesAsync.when(
      data: (stories) => _Layout(
        profile: profile,
        stories: stories,
        completedIds: completedIds,
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
  });

  final ChildProfile profile;
  final List<StoryModel> stories;
  final Set<String> completedIds;

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

  /// Returns the world index containing the next uncompleted story.
  int _worldIndexFor(List<StoryModel> stories, Set<String> completedIds) {
    final nextIndex = stories.indexWhere((s) => !completedIds.contains(s.id));
    if (nextIndex == -1) return 0;
    final nextId = stories[nextIndex].id;
    for (int i = 0; i < _kWorlds.length; i++) {
      if (_kWorlds[i].slots.any((s) => s.id == nextId)) return i;
    }
    return 0;
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
        : (nextIndex >= _kFreeStoryCount && !profile.isUnlocked);

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
            allStories: stories,
            completedIds: completedIds,
            profileUnlocked: profile.isUnlocked,
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

// ─── First free story count ──────────────────────────────────────────────────

const _kFreeStoryCount = 20;

// ─── Story slot: available (has content) or coming soon ──────────────────────

class _StorySlot {
  final String id;
  final String title;
  final String emoji;
  final bool comingSoon;

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
      _StorySlot('the-first-family',       'The First Family with God',          emoji: '🌿', comingSoon: true),
      _StorySlot('the-very-sad-choice',    'The Very Sad Choice',               emoji: '🍎', comingSoon: true),
      _StorySlot('god-promises-a-rescuer', 'God Promises a Rescuer',            emoji: '⭐', comingSoon: true),
      _StorySlot('two-brothers',           'Two Brothers and Jealous Hearts',   emoji: '😢', comingSoon: true),
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
      _StorySlot('the-tall-tower',              'The Tall Tower',                  emoji: '🗼', comingSoon: true),
      _StorySlot('god-calls-abraham',            'God Calls Abraham',               emoji: '🌟', comingSoon: true),
      _StorySlot('stars-in-the-sky',             'Stars in the Sky',                emoji: '🌌', comingSoon: true),
      _StorySlot('the-promised-son',             'The Promised Son',                emoji: '👶', comingSoon: true),
      _StorySlot('god-provides-a-lamb',          'God Provides a Lamb',             emoji: '🐑', comingSoon: true),
      _StorySlot('jacob-learns-grace',           'Jacob Learns Grace',              emoji: '🙏', comingSoon: true),
      _StorySlot('joseph-and-his-brothers',      'Joseph and His Jealous Brothers', emoji: '🌈', comingSoon: true),
      _StorySlot('joseph-forgives-his-family',   'Joseph Forgives His Family',      emoji: '🤗', comingSoon: true),
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
      _StorySlot('baby-moses-is-kept-safe',      'Baby Moses Is Kept Safe',        emoji: '🧺', comingSoon: true),
      _StorySlot('god-calls-from-the-fire',      'God Calls from the Fire',        emoji: '🔥', comingSoon: true),
      _StorySlot('let-my-people-go',             'Let My People Go',               emoji: '🏛️', comingSoon: true),
      _StorySlot('the-passover-lamb',            'The Passover Lamb',              emoji: '🐑', comingSoon: true),
      _StorySlot('a-way-through-the-sea',        'A Way Through the Sea',          emoji: '🌊', comingSoon: true),
      _StorySlot('bread-in-the-wilderness',      'Bread in the Wilderness',        emoji: '🍞', comingSoon: true),
      _StorySlot('gods-good-commands',           'God\'s Good Commands',           emoji: '📜', comingSoon: true),
      _StorySlot('god-lives-with-his-people',    'God Lives with His People',      emoji: '🕍', comingSoon: true),
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
      _StorySlot('twelve-spies',                 'Twelve Spies and Two Trusting Hearts', emoji: '🕵️', comingSoon: true),
      _StorySlot('joshua-and-the-walls',         'Joshua and the Strong Walls',          emoji: '🏰', comingSoon: true),
      _StorySlot('deborah-leads-gods-people',    'Deborah Leads God\'s People',          emoji: '⚔️', comingSoon: true),
      _StorySlot('gideons-tiny-army',            'Gideon\'s Tiny Army',                  emoji: '🏹', comingSoon: true),
      _StorySlot('ruth-finds-a-home',            'Ruth Finds a Home',                    emoji: '🌾', comingSoon: true),
      _StorySlot('samuel-listens-to-god',        'Samuel Listens to God',                emoji: '👂', comingSoon: true),
      _StorySlot('saul-the-king',                'Saul: The King Who Would Not Listen',  emoji: '👑', comingSoon: true),
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
      _StorySlot('david-and-the-giant',          'David and the Giant',             emoji: '🪨', comingSoon: true),
      _StorySlot('davids-sin-and-gods-mercy',    'David\'s Sin and God\'s Mercy',   emoji: '💧', comingSoon: true),
      _StorySlot('gods-forever-king-promise',    'God\'s Forever-King Promise',     emoji: '👑', comingSoon: true),
      _StorySlot('solomon-asks-for-wisdom',      'Solomon Asks for Wisdom',         emoji: '📚', comingSoon: true),
      _StorySlot('elijah-and-the-true-god',      'Elijah and the Only True God',    emoji: '🔥', comingSoon: true),
      _StorySlot('jonah-and-the-big-fish',       'Jonah and the Big Fish',          emoji: '🐋'),
      _StorySlot('daniel-and-the-lions',         'Daniel and the Lions',            emoji: '🦁'),
      _StorySlot('prophets-promise-new-hearts',  'The Prophets Promise New Hearts', emoji: '💚', comingSoon: true),
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
      _StorySlot('an-angel-visits-mary',         'An Angel Visits Mary',            emoji: '🕊️', comingSoon: true),
      _StorySlot('birth-of-jesus',               'Birth of Jesus',                  emoji: '⭐'),
      _StorySlot('visitors-worship-the-king',    'Visitors Worship the King',       emoji: '👑', comingSoon: true),
      _StorySlot('jesus-grows-and-obeys',        'Jesus Grows and Obeys',           emoji: '🌱', comingSoon: true),
      _StorySlot('jesus-is-baptised',            'Jesus Is Baptised',               emoji: '💧', comingSoon: true),
      _StorySlot('jesus-says-no-to-tempter',     'Jesus Says No to the Tempter',    emoji: '🚫', comingSoon: true),
      _StorySlot('jesus-calls-his-helpers',      'Jesus Calls His Helpers',         emoji: '🎣', comingSoon: true),
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
      _StorySlot('jesus-calms-the-storm',        'Jesus Calms the Storm',           emoji: '🌊', comingSoon: true),
      _StorySlot('jesus-heals-and-forgives',     'Jesus Heals and Forgives',        emoji: '❤️', comingSoon: true),
      _StorySlot('jesus-feeds-the-crowd',        'Jesus Feeds the Crowd',           emoji: '🍞', comingSoon: true),
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
      _StorySlot('jesus-raises-lazarus',         'Jesus Raises Lazarus',            emoji: '🌹', comingSoon: true),
      _StorySlot('the-king-rides-in',            'The King Rides into Jerusalem',   emoji: '🌴', comingSoon: true),
      _StorySlot('servant-king-washes-feet',     'The Servant King Washes Feet',   emoji: '🪣', comingSoon: true),
      _StorySlot('the-last-supper',              'The Last Supper',                 emoji: '🍷', comingSoon: true),
      _StorySlot('jesus-prays-in-garden',        'Jesus Prays in the Garden',       emoji: '🌿', comingSoon: true),
      _StorySlot('jesus-dies-for-sinners',       'Jesus Dies for Sinners',          emoji: '✝️', comingSoon: true),
      _StorySlot('jesus-is-alive',               'Jesus Is Alive',                  emoji: '🌅', comingSoon: true),
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
      _StorySlot('jesus-returns-to-his-father', 'Jesus Returns to His Father',      emoji: '☁️', comingSoon: true),
      _StorySlot('the-holy-spirit-comes',       'The Holy Spirit Comes',            emoji: '🔥', comingSoon: true),
      _StorySlot('a-new-sharing-family',        'A New Sharing Family',             emoji: '🫂', comingSoon: true),
      _StorySlot('stephen-sees-jesus',          'Stephen Sees Jesus',               emoji: '👁️', comingSoon: true),
      _StorySlot('saul-meets-the-risen-jesus',  'Saul Meets the Risen Jesus',       emoji: '⚡', comingSoon: true),
      _StorySlot('peter-welcomes-cornelius',    'Peter Welcomes Cornelius',         emoji: '🤝', comingSoon: true),
      _StorySlot('paul-and-silas-in-prison',    'Paul and Silas Sing in Prison',    emoji: '🎵', comingSoon: true),
      _StorySlot('the-spirit-grows-good-fruit', 'The Spirit Grows Good Fruit',      emoji: '🍎', comingSoon: true),
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
      _StorySlot('gods-armour-for-hard-days',   'God\'s Armour for Hard Days',     emoji: '🛡️', comingSoon: true),
      _StorySlot('when-anger-knocks',           'When Anger Knocks',               emoji: '😤', comingSoon: true),
      _StorySlot('when-i-feel-alone',           'When I Feel Alone',               emoji: '💙', comingSoon: true),
      _StorySlot('when-life-feels-unfair',      'When Life Feels Unfair',          emoji: '⚖️', comingSoon: true),
      _StorySlot('when-someone-we-love-dies',   'When Someone We Love Dies',       emoji: '🕊️', comingSoon: true),
      _StorySlot('jesus-will-come-again',       'Jesus Will Come Again',           emoji: '☁️', comingSoon: true),
      _StorySlot('the-king-judges',             'The King Judges and Raises the Dead', emoji: '⚖️', comingSoon: true),
      _StorySlot('god-makes-everything-new',    'God Makes Everything New',        emoji: '🌈', comingSoon: true),
    ],
  ),
];

// ─── World selector chip bar ──────────────────────────────────────────────────

class _WorldChipBar extends StatelessWidget {
  const _WorldChipBar({required this.selectedIndex, required this.onSelect});
  final int selectedIndex;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _kWorlds.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final world = _kWorlds[i];
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: selected
                    ? world.color
                    : AppColours.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? world.color
                      : const Color(0xFFE7E5E4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(world.emoji,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    world.shortTitle,
                    style: AppTextStyles.label.copyWith(
                      color: selected
                          ? Colors.white
                          : AppColours.textMuted,
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
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
    required this.allStories,
    required this.completedIds,
    required this.profileUnlocked,
  });

  final _WorldDef world;
  final List<StoryModel> allStories;
  final Set<String> completedIds;
  final bool profileUnlocked;

  @override
  Widget build(BuildContext context) {
    final slots = world.slots;
    final totalSlots = slots.length;

    // Available (built) slots only — for progress tracking
    final availableSlots = slots.where((s) => !s.comingSoon).toList();
    final completedCount =
        availableSlots.where((s) => completedIds.contains(s.id)).length;
    final worldDone = availableSlots.isNotEmpty &&
        completedCount == availableSlots.length;

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
                            : availableSlots.isEmpty
                                ? 'Coming Soon'
                                : '$completedCount / ${availableSlots.length}',
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
            final paywallLocked = !profileUnlocked &&
                allStories.indexOf(story) >= _kFreeStoryCount;
            final isLocked = !prevDone || paywallLocked;

            return _MapTile(
              story: story,
              isCompleted: isCompleted,
              isLocked: isLocked,
              isPaywallLocked: paywallLocked,
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

class _MapTile extends StatelessWidget {
  const _MapTile({
    required this.story,
    required this.isCompleted,
    required this.isLocked,
    required this.isPaywallLocked,
    required this.isLast,
    required this.accentColor,
  });

  final StoryModel story;
  final bool isCompleted;
  final bool isLocked;
  final bool isPaywallLocked;
  final bool isLast;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
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
