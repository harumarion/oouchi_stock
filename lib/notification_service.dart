import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// ローカル通知を管理するサービス
class NotificationService {
  /// 通知プラグイン
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// プラグインを初期化する
  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    tz.initializeTimeZones();
  }

  /// 次回通知時刻を計算する
  tz.TZDateTime _nextInstance(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// 毎週決まった時間に通知をスケジュールする
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    int weekday = DateTime.friday,
    int hour = 18,
    int minute = 0,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstance(weekday, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails('buy_list', 'Buy List'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
}
