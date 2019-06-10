import 'dart:async';

import 'package:flutter/material.dart';

class DisplayHandler {
  DisplayHandler(Widget initialWidget) {
    this.currentWidgets = initialWidget;
  }

  Widget currentWidgets;

  StreamController displayControler = StreamController();
  Sink get displaySink => displayControler.sink;
  Stream get displayStream => displayControler.stream;

  void display(Widget newWidget) {
    displaySink.add(newWidget);
  }
}
