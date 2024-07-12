import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

  // 최초 설정
  static Future<void> init() async {
    // 사용은 안 하는 Android 기본 세팅
    const AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings('mipmap/ic_launcher');

    // iOS 기본 세팅
    const DarwinInitializationSettings iOSInitializationSettings = const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 두 설정 결합
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    // 결합된 설정 적용
    await flutterLocalNotificationPlugin.initialize(initializationSettings);
  }

  // 알림 허용 요청
  static requestNotificationPermission() {
    flutterLocalNotificationPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> showNotification(String notificationTitle, String notificationBody) async {
    // 안드로이드 알림 보여지는 디테일한 형식 (iOS는 기본으로 설정되어있음)
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: false,
    );

    // 두 디테일 결합
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );

    await flutterLocalNotificationPlugin.show(
      0,
      notificationTitle,
      notificationBody,
      notificationDetails,
    );
  }

  static Future<void> scheduleNotification(String notificationTitle, String notificationBody, TZDateTime scheduledTime) async {
    // 안드로이드 알림 보여지는 디테일한 형식 (iOS는 기본으로 설정되어있음)
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: false,
    );

    // 두 디테일 결합
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );

    await flutterLocalNotificationPlugin.zonedSchedule(
      0,
      notificationTitle,
      notificationBody,
      scheduledTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, // For iOS 10 or before.
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}