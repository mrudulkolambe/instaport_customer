import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    "high_importance_channel",
    "High Importance Notifications",
    description: "This channel is used for important notifcation",
    importance: Importance.max,
    showBadge: true,
  );

  final _localnotifications = FlutterLocalNotificationsPlugin();

  void localNotificationsApp(RemoteNotification? notification) {
    if (notification != null) {
      _localnotifications.show(
        0,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
          priority: Priority.max,
          visibility: NotificationVisibility.public,
          importance: Importance.max,
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: "@drawable/ic_launcher",
          enableVibration: true,
          playSound: true,
        )),
      );
    }
  }

  Future initPushNotifications() async {
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;
        localNotificationsApp(notification);
      });
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((value) => print("test message and its value: $value"));
    } catch (e) {
      print(e);
    }
  }

  Future initLocalnotifications() async {
    const android = AndroidInitializationSettings("@drawable/ic_launcher");
    const settings = InitializationSettings(android: android);
    await _localnotifications.initialize(settings);
    final platform = _localnotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<String?> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print("fcmToken $fcmToken");
    initPushNotifications();
    initLocalnotifications();
    return fcmToken;
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print(message.notification);
  }
  // FirebaseMessaging
}
