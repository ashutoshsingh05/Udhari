import 'dart:async';
import 'package:flutter/material.dart';

class IconHandler {
  IconHandler(Icon initialIcon) {
    this.icon = initialIcon;
    changeIcon(icon);
  }

  Icon icon;
  StreamController iconController = StreamController<Icon>();
  Sink get iconSink => iconController.sink;
  Stream<Icon> get iconStream => iconController.stream;

  changeIcon(Icon newIcon) {
    iconSink.add(newIcon);
  }
}
