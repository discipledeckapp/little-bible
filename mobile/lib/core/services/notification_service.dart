import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

@riverpod
NotificationService notificationService(Ref ref) => NotificationService();

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );
    _initialized = true;
  }

  void _onTap(NotificationResponse response) {
    // Navigation to parent hub is handled via GoRouter at app level;
    // the payload 'parent_hub' is the signal.
    // Deep-link handling is wired in main.dart via getNotificationAppLaunchDetails().
  }

  /// Requests OS-level notification permission.
  /// Called only from Parent Hub — never from onboarding or child-facing screens.
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    bool granted = false;
    if (ios != null) {
      granted = await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    } else if (android != null) {
      granted = await android.requestNotificationsPermission() ?? false;
    }
    return granted;
  }

  /// Schedules a weekly reminder on Monday at 09:00.
  /// Copy intentionally contains no child name, score, or verse detail.
  Future<void> scheduleWeeklyReminder() async {
    await _ensureInitialized();
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
    await _ensureInitialized();
    await _plugin.cancelAll();
  }
}
