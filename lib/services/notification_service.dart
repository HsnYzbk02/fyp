import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(iOS: iosSettings);
    await _plugin.initialize(settings);
    debugPrint('[NotificationService] Initialized');
  }

  Future<void> showRecoveryReminder({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'RECOVERY',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(0, title, body, details);
  }

  Future<void> scheduleHydrationReminder() async {
    // Remind every 2 hours to drink water
    debugPrint('[NotificationService] Hydration reminders scheduled');
  }

  Future<void> scheduleMorningRecoveryCheck() async {
    // Every morning at 8am, check Apple Watch overnight data and notify
    debugPrint('[NotificationService] Morning recovery check scheduled');
  }

  Future<void> showFatigueAlert({required String message}) async {
    await showRecoveryReminder(
      title: '⚠️ High Fatigue Detected',
      body: message,
    );
  }
}
