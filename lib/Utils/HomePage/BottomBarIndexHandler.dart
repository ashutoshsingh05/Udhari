import 'dart:async';
import 'package:flutter/material.dart';

class BottomBarIndexHandler {
  BottomBarIndexHandler(int index) {
    this.index = index;
    changeIndex(index);
  }

  int index;
  StreamController indexController = StreamController<int>();
  Sink get indexSink => indexController.sink;
  Stream<Icon> get indexStream => indexController.stream;

  changeIndex(int newIcon) {
    indexSink.add(newIcon);
  }
}
