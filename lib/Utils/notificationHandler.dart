import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  FlutterLocalNotificationsPlugin notification;
  AndroidInitializationSettings androidSetting;
  IOSInitializationSettings iOSSetting;
  InitializationSettings initializationSettings;

  NotificationHandler() {
    notification = FlutterLocalNotificationsPlugin();
    androidSetting = AndroidInitializationSettings('@mipmap/launcher_icon');
    iOSSetting = IOSInitializationSettings(
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(androidSetting, iOSSetting);
    _initialize();
  }

  @deprecated
  AndroidNotificationDetails _androidNotificationDetails() {
    return AndroidNotificationDetails(
      '0',
      'Order',
      'Order related notifications',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
    );
  }

  @deprecated
  IOSNotificationDetails _iOSNotificationDetails() {
    return IOSNotificationDetails();
  }

  void showNotification({
    @required String title,
    @required String body,
    // @required platformChannelSpecifics,
  }) {
    notification.show(
      0,
      "$title",
      "$body",
      _getChannelSpecific(),
    );
  }

  NotificationDetails _getChannelSpecific() {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '0',
      'Reminders',
      'Reminders related to udhari',
      importance: Importance.High,
      priority: Priority.High,
      ticker: 'ticker',
      category: "reminder",
      // sound: RawResourceAndroidNotificationSound("alarm_clock"),
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    return notificationDetails;
  }

  void _initialize() async {
    await notification.initialize(
      initializationSettings,
      onSelectNotification: _onSelectNotification,
    );
  }

  Future _onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    //TODO: iOS notifcation implementation
  }
}

