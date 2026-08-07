import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/story_model.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/story_progress_repository.dart';
import '../../../core/services/content_session.dart';
import '../../../core/services/narration_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/story_provider.dart';
import '../widgets/animated_story_scene.dart';

class StoryPlayerScreen extends ConsumerStatefulWidget {
  const StoryPlayerScreen({super.key, required this.storyId});

  final String storyId;

  @override
  ConsumerState<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends ConsumerState<StoryPlayerScreen>
    with SingleTickerProviderStateMixin {
  int _sceneIndex = 0;
  bool _isPlaying = false;
  bool _initialized = false;
  bool _showEndPanel = false;

  // Scene animation controller — t driven by narration position (§ 3).
  // 10 s covers a typical narration scene; snaps to 1.0 on onDone.
  late final AnimationController _sceneAnim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  // Cached so _hearAgain() can restart without re-reading providers
  StoryModel? _story;
  ChildProfile? _profile;

  @override
  void initState() {
    super.initState();
    // Holds off content downloads for the duration of the session, so a
    // download can never compete with narration playback (US-12).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(storySessionActiveProvider.notifier).begin();
    });
  }

  @override
  void dispose() {
    _sceneAnim.dispose();
    ref.read(narrationServiceProvider).stop();
    ref.read(storySessionActiveProvider.notifier).end();
    super.dispose();
  }

  Future<void> _initScene(StoryModel story, ChildProfile profile) async {
    _story = story;
    _profile = profile;

    final progress = await ref
        .read(storyProgressRepositoryProvider)
        .getProgress(profile.id, widget.storyId);

    if (!mounted) return;

    // Resume from last position for in-progress stories.
    // Completed stories restart from scene 0 so narration always begins immediately.
    if (progress != null && progress.status != 'completed') {
      final scenes = story.scenes(profile.ageBand);
      final idx = progress.lastSceneIndex.clamp(0, scenes.length - 1);
      setState(() => _sceneIndex = idx);
    }

    if (profile.autoplayEnabled && !profile.quietStoryMode) {
      _speakScene(story, profile);
    }
  }

  void _hearAgain() {
    if (_story == null || _profile == null) return;
    ref.read(narrationServiceProvider).stop();
    setState(() {
      _sceneIndex = 0;
      _showEndPanel = false;
      _isPlaying = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _speakScene(_story!, _profile!);
    });
  }

  Future<void> _markComplete(String profileId) async {
    await ref
        .read(storyProgressRepositoryProvider)
        .markComplete(profileId, widget.storyId);
  }

  void _speakScene(StoryModel story, ChildProfile profile) {
    final scenes = story.scenes(profile.ageBand);
    if (_sceneIndex >= scenes.length) return;
    final isLast = _sceneIndex >= scenes.length - 1;
    final sceneText = scenes[_sceneIndex];
    final sceneIdx = _sceneIndex;
    setState(() => _isPlaying = true);

    // Start scene animation from 0 (§ 3 — t driven by narration position).
    if (profile.reducedMotion) {
      _sceneAnim.value = 1;
    } else {
      _sceneAnim.forward(from: 0);
    }

    ref.read(narrationServiceProvider).speakScene(
      storyId: widget.storyId,
      sceneIndex: sceneIdx,
      fallbackText: sceneText,
      onDone: () {
        if (!mounted) return;
        // Snap to fully-resolved frame (§ 3 — t = 1 is the outcome).
        _sceneAnim.animateTo(1.0, duration: const Duration(milliseconds: 400));
        setState(() {
          _isPlaying = false;
          if (isLast) _showEndPanel = true;
        });
        if (isLast) {
          final p = ref.read(activeProfileProvider).valueOrNull;
          if (p != null) _markComplete(p.id);
        }
      },
    );
  }

  Future<void> _togglePlay(StoryModel story, ChildProfile profile) async {
    if (_isPlaying) {
      await ref.read(narrationServiceProvider).stop();
      setState(() => _isPlaying = false);
    } else {
      _speakScene(story, profile);
    }
  }

  Future<void> _prev(StoryModel story, ChildProfile profile) async {
    if (_sceneIndex <= 0) return;
    await ref.read(narrationServiceProvider).stop();
    _sceneAnim.value = 0;
    setState(() {
      _sceneIndex--;
      _isPlaying = false;
      _showEndPanel = false;
    });
    if (profile.autoplayEnabled && !profile.quietStoryMode) {
      _speakScene(story, profile);
    }
  }

  Future<void> _next(StoryModel story, ChildProfile profile) async {
    final scenes = story.scenes(profile.ageBand);
    await ref.read(narrationServiceProvider).stop();

    await ref
        .read(storyProgressRepositoryProvider)
        .saveScene(profile.id, widget.storyId, _sceneIndex);

    if (_sceneIndex >= scenes.length - 1) {
      _sceneAnim.animateTo(1.0, duration: const Duration(milliseconds: 400));
      setState(() => _showEndPanel = true);
      _markComplete(profile.id);
      ref.read(soundServiceProvider).play(SoundEffect.storyComplete);
      return;
    }

    ref.read(soundServiceProvider).play(SoundEffect.pageAdvance);
    setState(() {
      _sceneIndex++;
      _isPlaying = false;
    });
    if (profile.autoplayEnabled && !profile.quietStoryMode) {
      _speakScene(story, profile);
    }
  }

  Future<void> _stopForNow() async {
    await ref.read(narrationServiceProvider).stop();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(storyProvider(widget.storyId));
    final profileAsync = ref.watch(activeProfileProvider);

    final story = storyAsync.valueOrNull;
    final profile = profileAsync.valueOrNull;
    if (story != null && profile != null && !_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _initScene(story, profile));
    }

    return Scaffold(
      backgroundColor: AppColours.cream,
      body: storyAsync.when(
        data: (story) => profileAsync.when(
          data: (profile) =>
              profile != null ? _buildPlayer(story, profile) : const _CentredSpinner(),
          loading: () => const _CentredSpinner(),
          error: (_, _) => const _ErrorBody(),
        ),
        loading: () => const _CentredSpinner(),
        error: (_, _) => const _ErrorBody(),
      ),
    );
  }

  Widget _buildPlayer(StoryModel story, ChildProfile profile) {
    final scenes = story.scenes(profile.ageBand);
    final total = scenes.length;
    final text = _sceneIndex < total ? scenes[_sceneIndex] : '';
    final isLast = _sceneIndex >= total - 1;

    final size = MediaQuery.sizeOf(context);
    // On phones (~360–430dp wide) scene is 260px. On tablets it grows to 40%
    // of screen height, capped at 420px so the text area stays generous.
    final sceneHeight = (size.height * 0.32).clamp(240.0, 420.0);
    // Side padding scales with width: phone 28dp, wide tablet up to 48dp.
    final sidePad = (size.width * 0.07).clamp(24.0, 48.0);
    // Body font scales from 22sp (phone) up to 26sp (large tablet).
    final bodySize = (size.shortestSide / 18).clamp(22.0, 26.0);
    // On wide screens centre the content in a max-width column.
    final maxW = size.width > 600 ? 560.0 : double.infinity;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: maxW,
        child: Column(
      children: [
        // ── Cover header ─────────────────────────────────────────────────
        Stack(
          children: [
            SizedBox(
              height: sceneHeight,
              width: double.infinity,
              child: AnimatedStoryScene(
                storyId: widget.storyId,
                sceneIndex: _sceneIndex,
                animation: _sceneAnim,
              ),
            ),
            // Tall gradient so scene elements never bleed behind the title.
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: sceneHeight * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColours.cream.withValues(alpha: 0.55),
                      AppColours.cream,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: Colors.white,
                  onPressed: () async {
                    await ref.read(narrationServiceProvider).stop();
                    if (mounted) context.pop();
                  },
                ),
              ),
            ),
          ],
        ),

        // ── Title ─────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(sidePad, 18, sidePad, 6),
          child: Text(
            story.title,
            style: AppTextStyles.heading.copyWith(
              color: AppColours.textDark,
              fontSize: (size.shortestSide / 14).clamp(26.0, 34.0),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // ── Scene indicator ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              total,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _sceneIndex ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _sceneIndex
                      ? AppColours.lumiGold
                      : AppColours.lumiGold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),

        // ── Story text OR end-of-story panel — both own the Expanded slot ──
        if (_showEndPanel)
          Expanded(
            child: _EndPanel(
              storyId: widget.storyId,
              onStopForNow: _stopForNow,
              onHearAgain: _hearAgain,
            ),
          )
        else ...[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(sidePad, 16, sidePad, 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  text,
                  key: ValueKey(_sceneIndex),
                  style: AppTextStyles.storyBody.copyWith(
                    color: AppColours.textDark,
                    fontSize: bodySize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: Icons.arrow_back_rounded,
                    enabled: _sceneIndex > 0,
                    onTap: () => _prev(story, profile),
                  ),
                  _PlayButton(
                    isPlaying: _isPlaying,
                    onTap: () => _togglePlay(story, profile),
                  ),
                  _ControlButton(
                    icon: isLast
                        ? Icons.menu_book_rounded
                        : Icons.arrow_forward_rounded,
                    enabled: true,
                    onTap: () => _next(story, profile),
                    highlight: isLast,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
        ),
      ),
    );
  }
}

// ─── End-of-story choice panel ────────────────────────────────────────────────

class _EndPanel extends StatelessWidget {
  const _EndPanel({
    required this.storyId,
    required this.onStopForNow,
    required this.onHearAgain,
  });

  final String storyId;
  final VoidCallback onStopForNow;
  final VoidCallback onHearAgain;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 38)),
            const SizedBox(height: 4),
            Text(
              "What's next?",
              style: AppTextStyles.heading.copyWith(
                fontSize: 24,
                color: AppColours.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Primary — Play Games
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/story/$storyId/games'),
                icon: const Icon(Icons.extension_rounded, size: 22),
                label: const Text('Play Games!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColours.lumiGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Secondary grid — 2 × 2
            Row(children: [
              Expanded(
                child: _NextTile(
                  icon: Icons.menu_book_rounded,
                  label: 'Bible passage',
                  color: AppColours.sky,
                  onTap: () => context.go('/story/$storyId/bible'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NextTile(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Learn the verse',
                  color: AppColours.prayerPurple,
                  onTap: () => context.go('/story/$storyId/verse'),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: _NextTile(
                  icon: Icons.people_outline_rounded,
                  label: 'Talk together',
                  color: AppColours.growthGreen,
                  onTap: () => context.go('/story/$storyId/family'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NextTile(
                  icon: Icons.palette_outlined,
                  label: 'Colour it!',
                  color: AppColours.coral,
                  onTap: () => context.go('/story/$storyId/color'),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // Tertiary links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: onHearAgain,
                  icon: const Icon(Icons.replay_rounded, size: 15),
                  label: const Text('Hear again'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColours.textMuted,
                    textStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(' · ',
                    style: TextStyle(
                        color: AppColours.textMuted, fontSize: 16)),
                TextButton(
                  onPressed: onStopForNow,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColours.textMuted,
                    textStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                    ),
                  ),
                  child: const Text('Stop for now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NextTile extends StatelessWidget {
  const _NextTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.28), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: AppColours.textDark,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Controls ─────────────────────────────────────────────────────────────────

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isPlaying, required this.onTap});
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColours.lumiGold,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColours.lumiGold.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.highlight = false,
  });
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: highlight
              ? AppColours.earth
              : (enabled
                  ? AppColours.surface
                  : AppColours.surface.withValues(alpha: 0.4)),
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]
              : null,
        ),
        child: Icon(
          icon,
          color: highlight
              ? Colors.white
              : (enabled ? AppColours.textDark : AppColours.textMuted),
          size: 24,
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _CentredSpinner extends StatelessWidget {
  const _CentredSpinner();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();
  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          'Oops, could not load the story.',
          style: AppTextStyles.storyBody.copyWith(color: AppColours.textMuted),
        ),
      );
}
