import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

@riverpod
NotificationService notificationService(Ref ref) {
  final svc = NotificationService();
  ref.onDispose(svc.dispose);
  return svc;
}

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// True once we know the platform has no notification implementation
  /// registered, so every later call can no-op instead of throwing again.
  bool _unavailable = false;

  final _tapController = StreamController<String>.broadcast();

  /// Emits notification tap payloads while the app is running.
  Stream<String> get tapPayloads => _tapController.stream;

  /// Returns true when the plugin is ready to use.
  ///
  /// Notifications are a nice-to-have, so a platform that cannot provide them
  /// must never take the app down with it. Where no implementation is
  /// registered — widget tests, and any unsupported platform — the plugin throws
  /// a `LateInitializationError` from deep inside the platform interface, and
  /// because this runs from `initState` an uncaught throw there kills the whole
  /// app at launch.
  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    if (_unavailable) return false;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    try {
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onTap,
      );
    } catch (_) {
      _unavailable = true;
      return false;
    }
    _initialized = true;
    return true;
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _tapController.add(payload);
    }
  }

  /// Returns the tap payload of the notification that cold-launched this app,
  /// or null if the app was not opened via a notification.
  Future<String?> getLaunchPayload() async {
    if (!await _ensureInitialized()) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  /// Requests OS-level notification permission.
  /// Called only from Parent Hub — never from onboarding or child-facing screens.
  Future<bool> requestPermission() async {
    if (!await _ensureInitialized()) return false;
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    bool granted = false;
    if (ios != null) {
      granted =
          await ios.requestPermissions(alert: true, badge: true, sound: true) ??
              false;
    } else if (android != null) {
      granted = await android.requestNotificationsPermission() ?? false;
    }
    return granted;
  }

  /// Schedules a repeating weekly reminder.
  Future<void> scheduleWeeklyReminder() async {
    if (!await _ensureInitialized()) return;
    await _plugin.periodicallyShow(
      0,
      'Little Bible',
      'A great time to explore a Bible story together!',
      RepeatInterval.weekly,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_reminder',
          'Weekly Reminders',
          channelDescription:
              'Optional weekly nudge to open a story with your child.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'parent_hub',
    );
  }

  Future<void> cancelAll() async {
    if (!await _ensureInitialized()) return;
    await _plugin.cancelAll();
  }

  void dispose() {
    _tapController.close();
  }
}
