import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udhari/Screens/HomePageScreens/dashboard.dart';
import 'package:udhari/Screens/HomePageScreens/history.dart';
import 'package:udhari/Screens/HomePageScreens/trips.dart';
import 'package:udhari/Screens/HomePageScreens/udhari.dart';

@deprecated
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
        changeScreen(Dashboard());
        break;
      case 1:
        changeScreen(Udhari());
        break;
      case 2:
        changeScreen(Trips());
        break;
      case 3:
        changeScreen(History());
        break;
    }
  }

  void close() {
    screenSink.close();
    screenController.close();
  }
}
