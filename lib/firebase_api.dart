import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:tanzmed/ui/apis/constants.dart';
// import 'package:tanzmed/ui/pages/advice/single_chat.dart';

class FirebaseApi {
  // instantiate fcm
  final _firebaseMessage = FirebaseMessaging.instance;
  // initialize firebase
  Future<void> initNotification() async {
    // request permission
    await _firebaseMessage.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // feetch fcm token
    final fcmToken = await _firebaseMessage.getToken();

    // print
    print(fcmToken);

    if (fcmToken != null) {
      // updateFCMToken(fcmToken);
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
      playSound: true,
    );

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('drawable/alert');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        print('Channel ID: ${channel.id}');
        print('Notification Title: ${notification.title}');
        print('Notification Body: ${notification.body}');

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                // icon: 'assets/alert-no.png',
                playSound: true,
                enableVibration: true,
                priority: Priority.high,
                // sound: const RawResourceAndroidNotificationSound('sound'),
              ),
            ));
      }
    });
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  // Future<void> updateFCMToken(String newToken) async {
  //   try {
  //     final response = await apiClient.post(
  //       '/api/chat/device/key',
  //       body: {'user_id': box.read('patient_id'), 'device_key': newToken},
  //     );
  //     if (response.statusCode == 200) {
  //       print('FCM Token updated successfully');
  //     } else {
  //       print('Failed to update FCM Token');
  //     }
  //   } catch (e) {
  //     print('Error updating FCM Token: $e');
  //   }
  // }
}
