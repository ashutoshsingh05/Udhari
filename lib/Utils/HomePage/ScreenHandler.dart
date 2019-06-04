import 'dart:async';
import 'package:flutter/material.dart';

class ScreenHandler {
  ScreenHandler(Widget initialScreen) {
    this.screen = initialScreen;
    changeScreen(this.screen);
  }

  Widget screen;
  StreamController screenController = StreamController<Widget>();
  Sink get screenSink => screenController.sink;
  Stream<Widget> get screenStream => screenController.stream;

  changeScreen(Widget newWidget) {
    screenSink.add(newWidget);
  }
}
