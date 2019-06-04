import 'dart:async';
import 'package:flutter/material.dart';

class IconHandler {
  IconHandler(Icon initialicon) {
    this.icon = initialicon;
    changeIcon(this.icon);
  }

  Icon icon;
  StreamController<Icon> iconController = StreamController<Icon>();
  Sink<Icon> get iconSink => iconController.sink;
  Stream<Icon> get iconStream => iconController.stream;

  changeIcon(Icon newicon) {
    iconSink.add(newicon);
  }
}
