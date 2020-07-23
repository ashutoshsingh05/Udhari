import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserClass {
  String name;
  String phoneNumber;
  String lastSeen;
  String joinedOn;
  String photoUrl;
  String uid;
  String fcmToken;

  UserClass({
    @required this.name,
    @required this.phoneNumber,
    @required this.lastSeen,
    @required this.joinedOn,
    @required this.photoUrl,
    @required this.uid,
    @required this.fcmToken,
  });

  UserClass.fromSnapshot(DocumentSnapshot snapshot) {
    this.name = snapshot.data["name"];
    this.phoneNumber = snapshot.data["phoneNumber"];
    this.lastSeen = snapshot.data["lastSeen"];
    this.joinedOn = snapshot.data["joinedOn"];
    this.photoUrl = snapshot.data["photoUrl"];
    this.uid = snapshot.data["uid"];
    this.fcmToken = snapshot.data["fcmToken"];
  }

  Map<String,dynamic>toJson() {
    return {
      "name": this.name,
      "phoneNumber": this.phoneNumber,
      "lastSeen": this.lastSeen,
      "joinedOn": this.joinedOn,
      "photoUrl": this.photoUrl,
      "uid": this.uid,
      "fcmToken":this.fcmToken,
    };
  }
}
