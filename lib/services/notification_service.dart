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

    // Lập lịch thông báo hàng ngày
    await _scheduleDaily(
      id: 1001,
      hour: 19,
      minute: 0,
      title: 'Daily Challenge đang chờ bạn!',
      body: 'Vào chơi để duy trì streak hôm nay nhé.',
      channelKey: 'daily_channel',
    );

    await _scheduleDaily(
      id: 1002,
      hour: 22,
      minute: 0,
      title: 'Sắp mất streak!',
      body: 'Bạn còn 2 giờ để hoàn thành thử thách hôm nay.',
      channelKey: 'daily_channel',
    );



    print('🔔 NotificationService: Hoàn thành lập lịch thông báo');
  }

  Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAllSchedules();
    await AwesomeNotifications().cancelAll();
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
      // Tính thời gian cụ thể cho notification
      final now = DateTime.now();
      DateTime fireDate = DateTime(now.year, now.month, now.day, hour, minute);
      
      // Nếu thời gian đã qua hôm nay, đặt cho ngày mai
      if (fireDate.isBefore(now)) {
        fireDate = fireDate.add(const Duration(days: 1));
      }
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
          title: title,
          body: body,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: fireDate,
          preciseAlarm: true,
          allowWhileIdle: true,
          repeats: true,
        ),
      );
      print('🔔 NotificationService: Lập lịch thành công cho ID $id');
    } catch (e) {
      print('🔔 NotificationService: Lỗi lập lịch ID $id: $e');
    }
  }
}
