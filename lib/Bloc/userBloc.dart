import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';
import 'package:udhari/Models/feedback.dart';
import 'package:udhari/Utils/globals.dart';

class UserBloc extends Bloc {
  FirebaseUser _user;

  String name;
  String photoUrl;
  String phoneNumber;
  String uid;
  String lastSeen;
  String joinedOn;
  String _fcmToken;

  set setName(String name) {
    this.name = name;
    print("Got name: " + this.name);
  }

  String get getFcmToken => this._fcmToken;

  UserBloc(String fcmToken){
    this._fcmToken = fcmToken;
  }

  FirebaseUser get firebaseUser => _user;

  /// Setter for [_user] upon first login.
  /// This is to trigger a private function [_addUserProfileRecord]
  /// to add the profile of user to Firestore database
  set setFirebaseUserOnLogin(FirebaseUser user) {
    this._user = user;
    this.phoneNumber = user.phoneNumber.substring(user.phoneNumber.length - 10);
    this.photoUrl = Globals.phoneToPhotoUrl(this.phoneNumber);
    this.uid = user.uid;
    this.joinedOn =
        DateFormat("EEEE, MMMM d, yyyy 'at' h:mma").format(DateTime.now());
    this.lastSeen =
        DateFormat("EEEE, MMMM d, yyyy 'at' h:mma").format(DateTime.now());

    _addUserProfileRecord();
  }

  /// Setter for [_user] upon app startup when user is already loggin in.
  /// This is to trigger a private function [_updateLastSeen]
  /// to update the lastseen on Firestore database
  set setFirebaseUserOnStartUp(FirebaseUser user) {
    this._user = user;
    this.phoneNumber = user.phoneNumber.substring(user.phoneNumber.length - 10);
    this.photoUrl = Globals.phoneToPhotoUrl(this.phoneNumber);
    this.uid = user.uid;
    this.joinedOn = Globals.dateTimeFormat.format(DateTime.now());
    this.lastSeen = Globals.dateTimeFormat.format(DateTime.now());
    // Later used inside Globals
    Globals.phoneNumber = this.phoneNumber;
    _updateLastSeen();
  }

  void _addUserProfileRecord() async {
    if (this._user == null) {
      print("Firebase User not received, cannot add profile record");
    } else {
      await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("users")
          .document(this.phoneNumber)
          .setData(toJson())
          .then((onValue) {
        print("LOGGED USER to DATABASE ${this.phoneNumber}");
      });
    }
  }

  void _updateLastSeen() async {
    if (this._user == null) {
      print("Firebase User not received, cannot update last seen");
    } else {
      lastSeen = Globals.dateTimeFormat.format(DateTime.now());

      await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("users")
          .document(this.phoneNumber)
          .updateData({
        "lastSeen": this.lastSeen,
      }).then((onValue) {
        print("UPDATED LAST SEEN ${this.lastSeen}");
      }).catchError((onError) {
        print("ERROR UPDATING last seen: $onError");
      });
    }
  }

  Map<String, String> toJson() {
    return {
      "name": this.name,
      "phoneNumber": this.phoneNumber,
      "photoUrl": this.photoUrl,
      "uid": this.uid,
      "lastSeen": this.lastSeen,
      "joinedOn": this.joinedOn,
      "fcmToken":this._fcmToken
    };
  }

  Future<int> provideFeedback(AppFeedback feedback) async {
    DocumentReference doc = Firestore.instance
        // .collection("Users 3.0")
        // .document("data")
        .collection("feedbacks")
        .document(feedback.dateTime.millisecondsSinceEpoch.toString());
    int code = await doc.setData(feedback.toJson()).then((value) {
      print("Feedback sent");
      return 0;
    }).catchError((onError) {
      print("Error sending feedback: $onError");
      return -1;
    });
    return code;
  }

  void logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {}
}
