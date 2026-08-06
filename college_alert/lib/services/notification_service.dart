import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // The Firebase Notifications composer can target this topic. Notifications
    // received while the Android app is in the background are displayed by FCM.
    await messaging.subscribeToTopic('all_students');
  }
}
