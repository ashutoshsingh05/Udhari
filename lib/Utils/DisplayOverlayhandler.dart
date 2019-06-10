import 'dart:async';

import 'package:flutter/material.dart';

class DisplayHandler {
  DisplayHandler(Widget initialWidget) {
    this.currentWidgets = initialWidget;
  }

  Widget currentWidgets;

  StreamController displayController = StreamController();
  Sink get displaySink => displayController.sink;
  Stream get displayStream => displayController.stream;

  void display(Widget newWidget) {
    displaySink.add(newWidget);
  }

  void close() {
    displaySink.close();
    displayController.close();
  }
}
