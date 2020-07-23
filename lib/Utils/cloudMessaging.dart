import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:udhari/Utils/notificationHandler.dart';

class CloudMessaging {
  FirebaseMessaging _firebaseMessaging;
  NotificationHandler _notificationHandler;
  // String _fcmToken;

  // String get getFcmToken => this._fcmToken;

  CloudMessaging.withNotification(NotificationHandler notificationHandler) {
    this._notificationHandler = notificationHandler;
    _firebaseMessaging = FirebaseMessaging();
    _configureMessaging();
    _requestPermission();
  }

  void _configureMessaging() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // print("notification: ${message["notification"]}");
        // print("data :"+message["data"]);
        String _title = "${message["notification"]["title"]}";
        String _body = "${message["notification"]["body"]}";

        _notificationHandler.showNotification(title: _title, body: _body);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        print(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        print(message);
      },
    );
  }

  void _requestPermission() {
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
        provisional: true,
      ),
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future<String> getToken() async {
    String token;
    token = await _firebaseMessaging.getToken();
    return token;
    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    //   Constants.token = token;
    //   this._fcmToken = token;
    //   // print("token: $token");
    // });
  }
}
