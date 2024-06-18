import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fp_ppb/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/service/auth_service.dart';

class FirebaseMessage {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _auth = AuthService();

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();

    print('Token: $fCMToken');
    if (fCMToken != null) {
      await FirebaseFirestore.instance.collection('users').doc(_auth.getCurrentUser()!.uid).update({
        'fcmToken': fCMToken,
      });
    }
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed('/transactions', arguments: message);
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
