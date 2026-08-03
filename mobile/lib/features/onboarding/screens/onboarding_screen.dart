import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/router/app_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;

  // Step 1 state
  String? _ageBand;

  // Step 2 state
  final _nicknameController = TextEditingController();
  String _avatarId = 'lion';

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.cream,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _StepAgeBand(
          key: const ValueKey(0),
          selected: _ageBand,
          onSelect: (band) => setState(() => _ageBand = band),
          onNext: () => setState(() => _step = 1),
        ),
      1 => _StepNicknameAvatar(
          key: const ValueKey(1),
          controller: _nicknameController,
          avatarId: _avatarId,
          onAvatarSelect: (id) => setState(() => _avatarId = id),
          onNext: () => setState(() => _step = 2),
          onBack: () => setState(() => _step = 0),
        ),
      _ => _StepConfirm(
          key: const ValueKey(2),
          nickname: _nicknameController.text.trim(),
          ageBand: _ageBand ?? 'emerging',
          avatarId: _avatarId,
          onBack: () => setState(() => _step = 1),
          onGo: _createProfile,
        ),
    };
  }

  Future<void> _createProfile() async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.create(
      nickname:  _nicknameController.text.trim().isEmpty
          ? 'Friend'
          : _nicknameController.text.trim(),
      ageBand:  _ageBand ?? 'emerging',
      avatarId: _avatarId,
    );
    if (mounted) context.go(AppRoutes.home);
  }
}

// ─── Step 1: Age band ─────────────────────────────────────────────────────────

class _StepAgeBand extends StatelessWidget {
  const _StepAgeBand({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  static const _bands = [
    ('early', 'Early Reader', '3–5', '🌱'),
    ('emerging', 'Emerging Reader', '6–8', '🌿'),
    ('independent', 'Independent Reader', '9–12', '🌳'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, parent!",
            style: AppTextStyles.heading.copyWith(color: AppColours.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            "Tell us about your child so we can tailor the experience.",
            style: AppTextStyles.label.copyWith(color: AppColours.textMuted),
          ),
          const SizedBox(height: 32),
          for (final (band, label, ages, emoji) in _bands) ...[
            _BandCard(
              emoji: emoji,
              label: label,
              ages: ages,
              selected: selected == band,
              onTap: () => onSelect(band),
            ),
            const SizedBox(height: 12),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: selected == null ? null : onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColours.lumiGold,
                foregroundColor: AppColours.textDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('Next', style: AppTextStyles.label),
            ),
          ),
        ],
      ),
    );
  }
}

class _BandCard extends StatelessWidget {
  const _BandCard({
    required this.emoji,
    required this.label,
    required this.ages,
    required this.selected,
    required this.onTap,
  });

  final String emoji, label, ages;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColours.lumiGold.withValues(alpha: 0.15) : AppColours.surface,
          border: Border.all(
            color: selected ? AppColours.lumiGold : AppColours.textMuted.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label.copyWith(color: AppColours.textDark)),
                Text(ages, style: AppTextStyles.label.copyWith(color: AppColours.textMuted, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (selected) const Icon(Icons.check_circle_rounded, color: AppColours.lumiGold),
          ],
        ),
      ),
    );
  }
}

// ─── Step 2: Nickname + avatar ────────────────────────────────────────────────

class _StepNicknameAvatar extends StatelessWidget {
  const _StepNicknameAvatar({
    super.key,
    required this.controller,
    required this.avatarId,
    required this.onAvatarSelect,
    required this.onNext,
    required this.onBack,
  });

  final TextEditingController controller;
  final String avatarId;
  final ValueChanged<String> onAvatarSelect;
  final VoidCallback onNext, onBack;

  static const _avatars = [
    ('lion', '🦁'),
    ('lamb', '🐑'),
    ('dove', '🕊️'),
    ('bear', '🐻'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What's their name?",
              style: AppTextStyles.heading.copyWith(color: AppColours.textDark)),
          const SizedBox(height: 8),
          Text("Nickname is optional — tap Skip if you prefer.",
              style: AppTextStyles.label.copyWith(color: AppColours.textMuted)),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: 'e.g. Noah',
              hintStyle: AppTextStyles.label.copyWith(color: AppColours.textMuted),
              filled: true,
              fillColor: AppColours.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColours.textMuted.withValues(alpha: 0.3)),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text("Pick an avatar",
              style: AppTextStyles.label.copyWith(color: AppColours.textDark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: _avatars.map((e) {
              final (id, emoji) = e;
              final selected = avatarId == id;
              return GestureDetector(
                onTap: () => onAvatarSelect(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: selected ? AppColours.lumiGold.withValues(alpha: 0.15) : AppColours.surface,
                    border: Border.all(
                      color: selected ? AppColours.lumiGold : AppColours.textMuted.withValues(alpha: 0.3),
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(
                onPressed: onBack,
                child: Text('Back', style: AppTextStyles.label.copyWith(color: AppColours.textMuted)),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColours.lumiGold,
                  foregroundColor: AppColours.textDark,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Next', style: AppTextStyles.label),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Confirm ──────────────────────────────────────────────────────────

class _StepConfirm extends StatelessWidget {
  const _StepConfirm({
    super.key,
    required this.nickname,
    required this.ageBand,
    required this.avatarId,
    required this.onBack,
    required this.onGo,
  });

  final String nickname, ageBand, avatarId;
  final VoidCallback onBack;
  final VoidCallback onGo;

  static const _avatarEmoji = {
    'lion': '🦁', 'lamb': '🐑', 'dove': '🕊️', 'bear': '🐻',
  };
  static const _bandLabel = {
    'early': 'Early Reader (3–5)', 'emerging': 'Emerging Reader (6–8)',
    'independent': 'Independent Reader (9–12)',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(_avatarEmoji[avatarId] ?? '🦁', style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(
            nickname.isEmpty ? 'Friend' : nickname,
            style: AppTextStyles.heading.copyWith(color: AppColours.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            _bandLabel[ageBand] ?? ageBand,
            style: AppTextStyles.label.copyWith(color: AppColours.textMuted),
          ),
          const Spacer(),
          Text(
            "God's Word for little hearts.",
            textAlign: TextAlign.center,
            style: AppTextStyles.verseAdapted.copyWith(
              color: AppColours.earth,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onGo,
              style: FilledButton.styleFrom(
                backgroundColor: AppColours.lumiGold,
                foregroundColor: AppColours.textDark,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("Let's go! 🌟", style: AppTextStyles.label.copyWith(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onBack,
            child: Text('Back', style: AppTextStyles.label.copyWith(color: AppColours.textMuted)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
