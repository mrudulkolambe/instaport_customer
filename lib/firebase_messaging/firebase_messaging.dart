import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingAPI {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AndroidNotificationChannel _androidChannel = const AndroidNotificationChannel(
    "high_importance_channel",
    "High Importance Notifications",
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );
  late DarwinNotificationDetails _iosNotificationDetails = const DarwinNotificationDetails(
    interruptionLevel: InterruptionLevel.critical,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  void localNotificationsApp(RemoteNotification? notification) {
    if (notification != null) {
      _localNotifications.show(
        0,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            channelShowBadge: true,
          ),
          iOS: _iosNotificationDetails,
        ),
      );
    }
  }

  Future<void> initPushNotifications() async {
    try {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          localNotificationsApp(notification);
        }
      });

      FirebaseMessaging.instance.getInitialMessage().then((value) {
        print("Initial message: $value");
      });
    } catch (e) {
      print("Error initializing push notifications: $e");
    }
  }

  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
        const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

    await _localNotifications.initialize(initializationSettings);

    _iosNotificationDetails = const DarwinNotificationDetails();

    final platform = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<String?> initNotifications() async {
    try {
      await _firebaseMessaging.requestPermission();
      final fcmToken = await _firebaseMessaging.getToken();
      print("FCM Token: $fcmToken");
      initPushNotifications();
      initLocalNotifications();
      return fcmToken;
    } catch (e) {
      print("Error initializing notifications: $e");
      return null;
    }
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print("Handling background message: ${message.notification}");
    // Handle background message logic here
  }
}
