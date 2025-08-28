import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'settings_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;
  static const String _tz = 'Asia/Ho_Chi_Minh';

  Future<void> init() async {
    if (_initialized) return;
    print('🔔 NotificationService: Khởi tạo (awesome_notifications)...');

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'daily_channel',
          channelName: 'Daily Reminders',
          channelDescription: 'Nhắc Daily Challenge và streak',
          importance: NotificationImportance.Max,
          defaultColor: const Color(0xFF2196F3),
          ledColor: const Color(0xFFFFFFFF),
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: 'test_scheduled_channel',
          channelName: 'Test Scheduled Notifications',
          channelDescription: 'Test scheduled notifications',
          importance: NotificationImportance.Max,
          defaultColor: const Color(0xFF4CAF50),
          ledColor: const Color(0xFFFFFFFF),
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: 'test_channel',
          channelName: 'Test Notifications',
          channelDescription: 'Test notifications',
          importance: NotificationImportance.Max,
          defaultColor: const Color(0xFFFFC107),
          ledColor: const Color(0xFFFFFFFF),
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
        ),
      ],
      debug: false,
    );

    bool allowed = await AwesomeNotifications().isNotificationAllowed();
    print('🔔 NotificationService: isNotificationAllowed = $allowed');
    if (!allowed) {
      allowed = await AwesomeNotifications().requestPermissionToSendNotifications();
      print('🔔 NotificationService: requestPermission -> $allowed');
    }

    _initialized = true;
    print('🔔 NotificationService: Khởi tạo thành công (awesome_notifications)');
  }

  Future<void> scheduleDailyReminders() async {
    print('🔔 NotificationService: Bắt đầu lập lịch thông báo (awesome)');

    if (!await SettingsService().isNotificationsEnabled()) {
      print('🔔 NotificationService: Thông báo bị tắt, hủy tất cả');
      await cancelAll();
      return;
    }

    print('🔔 NotificationService: Thông báo được bật, lập lịch...');
    await cancelAll();

    await _scheduleDaily(
      id: 1001,
      hour: 15,
      minute: 40,
      title: 'Daily Challenge đang chờ bạn!',
      body: 'Vào chơi để duy trì streak hôm nay nhé.',
      channelKey: 'daily_channel',
    );

    await _scheduleDaily(
      id: 1002,
      hour: 15,
      minute: 41,
      title: 'Sắp mất streak!',
      body: 'Bạn còn 28 phút để hoàn thành thử thách hôm nay.',
      channelKey: 'daily_channel',
    );

    print('🔔 NotificationService: Hoàn thành lập lịch thông báo');
    await checkScheduledNotifications();
  }

  Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAllSchedules();
    await AwesomeNotifications().cancelAll();
  }

  Future<void> showTestNotification() async {
    print('🔔 NotificationService: Hiển thị test notification (awesome)');
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999,
          channelKey: 'test_channel',
          title: 'Test Notification',
          body: 'Đây là test notification từ app!',
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
        ),
      );
      print('🔔 NotificationService: Test notification thành công');
    } catch (e) {
      print('🔔 NotificationService: Lỗi test notification: $e');
    }
  }

  Future<void> showTestScheduledNotification() async {
    print('🔔 NotificationService: Lập lịch test notification trong 10 giây (awesome)');
    try {
      final DateTime fireDate = DateTime.now().add(const Duration(seconds: 10));
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 998,
          channelKey: 'test_scheduled_channel',
          title: 'Test Scheduled Notification',
          body: 'Đây là test notification được lập lịch!',
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: fireDate,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );
      print('🔔 NotificationService: Lập lịch test notification thành công cho ' + fireDate.toString());
    } catch (e) {
      print('🔔 NotificationService: Lỗi lập lịch test notification: $e');
    }
  }

  Future<void> checkScheduledNotifications() async {
    print('🔔 NotificationService: Kiểm tra notification đã lập lịch (awesome)...');
    try {
      final List<NotificationModel> pending = await AwesomeNotifications().listScheduledNotifications();
      print('🔔 NotificationService: Có ${pending.length} notification đang chờ');
      for (final n in pending) {
        print('🔔 NotificationService: ID: ${n.content?.id}, Title: ${n.content?.title}');
      }
    } catch (e) {
      print('🔔 NotificationService: Lỗi kiểm tra: $e');
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelKey,
  }) async {
    print('🔔 NotificationService: Lập lịch ID $id lúc $hour:$minute (awesome)');
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
          title: title,
          body: body,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          hour: hour,
          minute: minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
      print('🔔 NotificationService: Lập lịch thành công cho ID $id');
    } catch (e) {
      print('🔔 NotificationService: Lỗi lập lịch ID $id: $e');
    }
  }
}
