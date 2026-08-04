import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/unlock_service.dart';
import '../../../core/services/parent_gate_service.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
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
      context.pop();
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
    final service = ref.watch(unlockServiceProvider);

    // Navigate back automatically on successful purchase.
    ref.listen(unlockServiceProvider, (prev, next) {
      if (next.state.status == UnlockStatus.purchased && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All stories unlocked!'),
            backgroundColor: AppColours.earth,
          ),
        );
        context.pop();
      }
    });

    final isLoading = service.state.status == UnlockStatus.loading;
    final price = service.state.localPrice;
    final errorMsg = service.state.errorMessage;
    final unavailable = service.state.status == UnlockStatus.unavailable;

    return UnlockContent(
      price: price,
      isLoading: isLoading,
      unavailable: unavailable,
      errorMessage: errorMsg,
      onClose: () => context.pop(),
      onPurchase: () => ref.read(unlockServiceProvider).purchase(),
      onRestore: () => ref.read(unlockServiceProvider).restore(),
    );
  }
}

/// The paywall's presentation, with no providers, navigation or StoreKit.
///
/// Split out of [UnlockScreen] so it can be rendered on its own — the App Store
/// Connect in-app-purchase review screenshot is generated from this exact
/// widget, so the image Apple reviews cannot drift from the real paywall.
class UnlockContent extends StatelessWidget {
  const UnlockContent({
    super.key,
    this.price,
    this.isLoading = false,
    this.unavailable = false,
    this.errorMessage,
    this.onClose,
    this.onPurchase,
    this.onRestore,
  });

  final String? price;
  final bool isLoading;
  final bool unavailable;
  final String? errorMessage;
  final VoidCallback? onClose;
  final VoidCallback? onPurchase;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final errorMsg = errorMessage;
    return Scaffold(
      backgroundColor: AppColours.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppColours.textDark,
                  onPressed: onClose,
                ),
              ),
              const SizedBox(height: 12),

              // Hero illustration
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(colors: [
                    Color(0xFFFEF3C7),
                    Color(0xFFFDE68A),
                  ]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: AppColours.lumiGold, size: 56),
              ),
              const SizedBox(height: 28),

              Text(
                'Unlock the Complete Little Bible',
                style: AppTextStyles.heading.copyWith(
                    color: AppColours.textDark, fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'One non-consumable purchase unlocks the complete age-appropriate library on this store account.',
                style: AppTextStyles.storyBody.copyWith(
                    color: AppColours.textMuted, height: 1.6, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Feature list
              ..._features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColours.lumiGold.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(f.icon,
                              color: AppColours.lumiGold, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(f.label,
                              style: AppTextStyles.label.copyWith(
                                  color: AppColours.textDark, fontSize: 14)),
                        ),
                      ],
                    ),
                  )),

              if (errorMsg != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMsg,
                  style: AppTextStyles.label
                      .copyWith(color: AppColours.coral, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const Spacer(),

              if (unavailable)
                Text(
                  'In-app purchases are not available on this device.',
                  style: AppTextStyles.label
                      .copyWith(color: AppColours.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                )
              else ...[
                // Purchase CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : onPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColours.lumiGold,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColours.lumiGold.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            price != null
                                ? 'Unlock All Stories — $price'
                                : 'Unlock All Stories',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : onRestore,
                  child: Text(
                    'Restore purchase',
                    style: AppTextStyles.label
                        .copyWith(color: AppColours.textMuted, fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static const _features = [
    _Feature(Icons.book_rounded, 'All Bible stories — Noah, David, Daniel & more'),
    _Feature(Icons.extension_rounded, 'Verse games that build memory gently'),
    _Feature(Icons.color_lens_rounded, 'Illustrated colouring activities for every story'),
    _Feature(Icons.family_restroom_rounded, 'Family discussion & prayer guides'),
  ];
}

class _Feature {
  const _Feature(this.icon, this.label);
  final IconData icon;
  final String label;
}
