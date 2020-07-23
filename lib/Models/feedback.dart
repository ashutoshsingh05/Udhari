import 'package:flutter/material.dart';

class AppFeedback {
  String title;
  String message;
  DateTime dateTime;
  String phoneNumber;

  AppFeedback({
    @required this.title,
    @required this.message,
    @required this.dateTime,
    @required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": this.title,
      "message": this.message,
      "dateTime": this.dateTime,
      "phoneNumber": this.phoneNumber,
    };
  }
}
