import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udhari_2/Screens/HomePageScreens/Dashboard.dart';
import 'package:udhari_2/Screens/HomePageScreens/History.dart';
import 'package:udhari_2/Screens/HomePageScreens/NormalUdhari.dart';
import 'package:udhari_2/Screens/HomePageScreens/Trips.dart';

class ScreenHandler {
  ScreenHandler(Widget initialScreen, FirebaseUser user) {
    this.screen = initialScreen;
    this.user = user;
    changeScreen(this.screen);
  }

  Widget screen;
  FirebaseUser user;
  StreamController screenController = StreamController<Widget>();
  Sink get screenSink => screenController.sink;
  Stream<Widget> get screenStream => screenController.stream;

  void changeScreen(Widget newScreen) {
    screenSink.add(newScreen);
  }

  set setScreen(int index) {
    switch (index) {
      case 0:
        changeScreen(Dashboard(user: this.user));
        break;
      case 1:
        changeScreen(NormalUdhari(user: this.user));
        break;
      case 2:
        changeScreen(Trips(user: this.user));
        break;
      case 3:
        changeScreen(History(user: this.user));
        break;
    }
  }

  void close() {
    screenSink.close();
    screenController.close();
  }
}
