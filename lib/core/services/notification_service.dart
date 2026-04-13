import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles local-only notifications (no remote push).
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initializationSettings);
    _initialized = true;
  }

  Future<void> showSimpleNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await init();
    }

    const androidDetails = AndroidNotificationDetails(
      'my_wallet_app_channel',
      'My Wallet App',
      channelDescription: 'Local notifications for My Wallet App',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(id, title, body, notificationDetails);
  }

  /// You can extend this with scheduled notifications if needed later.
}