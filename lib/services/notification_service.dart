import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'settings_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flnp = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit, macOS: iosInit);

    await _flnp.initialize(initSettings);
    _initialized = true;
  }

  Future<void> scheduleDailyReminders() async {
    if (!await SettingsService().isNotificationsEnabled()) {
      await cancelAll();
      return;
    }

    await cancelAll();

    // Nhắc Daily Challenge lúc 19:00
    await _scheduleDaily(
      id: 1001,
      hour: 19,
      minute: 0,
      title: 'Daily Challenge đang chờ bạn!',
      body: 'Vào chơi để duy trì streak hôm nay nhé.',
    );

    // Cảnh báo mất streak trước 2 giờ (giả sử reset lúc 00:00)
    await _scheduleDaily(
      id: 1002,
      hour: 22,
      minute: 0,
      title: 'Sắp mất streak!',
      body: 'Bạn còn 2 giờ để hoàn thành thử thách hôm nay.',
    );
  }

  Future<void> cancelAll() async {
    await _flnp.cancelAll();
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_channel',
      'Daily Reminders',
      channelDescription: 'Nhắc Daily Challenge và streak',
      importance: Importance.high,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails, macOS: iosDetails);

    await _flnp.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
