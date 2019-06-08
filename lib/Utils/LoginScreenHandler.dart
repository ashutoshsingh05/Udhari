import 'dart:async';

import 'package:flutter/material.dart';

class LoginScreenHandler {
  LoginScreenHandler(Widget currentWidget) {
    this.currentWidget = currentWidget;
  }

  final cpIndicator = Padding(
    padding: EdgeInsets.symmetric(vertical: 150, horizontal: 40),
    child: CircularProgressIndicator(
      semanticsLabel: "Signing in ... ",
    ),
  );

  Widget currentWidget;

  StreamController<Widget> currentWidgetController = StreamController();
  Sink get currentWidgetSink => currentWidgetController.sink;
  Stream<Widget> get currentWidgetStream => currentWidgetController.stream;

  void showCircularProgressIndicator() {
    currentWidgetSink.add(cpIndicator);
  }

  void hideCircularProgressIndicator() {
    currentWidgetSink.add(this.currentWidget);
  }
}
