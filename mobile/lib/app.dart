import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/services/content_update_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';

class LittleBibleApp extends ConsumerStatefulWidget {
  const LittleBibleApp({super.key});

  @override
  ConsumerState<LittleBibleApp> createState() => _LittleBibleAppState();
}

class _LittleBibleAppState extends ConsumerState<LittleBibleApp>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _notificationSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _wireNotifications());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Fire-and-forget — both services are no-ops when nothing to do.
    ref.read(contentUpdateServiceProvider).checkManifest();
    ref.read(syncServiceProvider).drain();
  }

  Future<void> _wireNotifications() async {
    final svc = ref.read(notificationServiceProvider);

    // Foreground taps
    _notificationSub = svc.tapPayloads.listen(_handleNotificationPayload);

    // Cold-launch: app opened via notification tap.
    final launchPayload = await svc.getLaunchPayload();
    if (launchPayload != null && mounted) {
      // Allow splash → home navigation to settle before pushing.
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) _handleNotificationPayload(launchPayload);
    }
  }

  void _handleNotificationPayload(String payload) {
    if (!mounted) return;
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    if (payload == 'parent_hub') {
      GoRouter.of(ctx).push(AppRoutes.parentHub);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Little Bible',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
