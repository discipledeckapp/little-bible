import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'core/services/content_update_service.dart';
import 'core/services/music_service.dart';
import 'app.dart';

/// Background task entry point — iOS BGAppRefreshTask + Android WorkManager.
///
/// Must be a top-level function. The pragma ensures it survives Dart tree-shaking
/// / obfuscation (required for Flutter 3.1+).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'org.littlebible.sync') {
      WidgetsFlutterBinding.ensureInitialized();
      final container = ProviderContainer();
      try {
        await container.read(contentUpdateServiceProvider).checkManifest();
      } catch (e) {
        debugPrint('Background sync error: $e');
      } finally {
        container.dispose();
      }
    }
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Register background content-sync task.
  // ExistingWorkPolicy.keep means subsequent launches don't reschedule if one
  // is already enqueued — safe to call on every launch.
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'org.littlebible.sync',
    'org.littlebible.sync',
    frequency: const Duration(hours: 12),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  final container = ProviderContainer();
  await container.read(musicServiceProvider).init();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const LittleBibleApp(),
  ));
}
