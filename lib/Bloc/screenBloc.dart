import 'dart:async';

import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Screens/HomePageScreens/dashboard.dart';
import 'package:udhari/Screens/HomePageScreens/trips.dart';
import 'package:udhari/Screens/HomePageScreens/udhari.dart';

class ScreenBloc extends Bloc {
  //only for tesing
  int _index = 0;
  dynamic _currentScreen;

  int get getIndex => _index;
  dynamic get getCurrentScreen => _currentScreen;

  ScreenBloc() {
    // so that initial data sent to the stream is not NULL
    // _screenStateSink.add(Dashboard());
    // only for testing, uncomment when done
    _currentScreen = Dashboard();
    _screenEventStream.listen(_mapEventToState);
  }

  StreamController<Widget> _screenStateController =
      StreamController<Widget>.broadcast();
  Stream<Widget> get screenStateStream => _screenStateController.stream;
  StreamSink<Widget> get _screenStateSink => _screenStateController.sink;

  StreamController<int> _screenEventController = StreamController<int>();
  Stream<int> get _screenEventStream => _screenEventController.stream;
  StreamSink<int> get screenEventSink => _screenEventController.sink;

  void _mapEventToState(int index) {
    this._index = index;
    switch (index) {
      case 0:
        _screenStateSink.add(Dashboard());
        _currentScreen = Dashboard();
        print("EVENT goto DASHBOARD");
        break;
      case 1:
        _screenStateSink.add(Udhari());
        _currentScreen = Udhari();
        print("EVENT goto UDHARI");

        break;
      // case 2:
      //   _screenStateSink.add(BillSplit());
      //   _currentScreen = BillSplit();
      //   print("EVENT goto BILLSPLIT");

      //   break;
      case 2:
        _screenStateSink.add(Trips());
        _currentScreen = Trips();
        print("EVENT goto TRIPS");

        break;
      default:
        _screenStateSink.add(Dashboard());
        _currentScreen = Dashboard();
        print("DEFAULT EVENT goto DASHBOARD");
    }
  }

  @override
  void dispose() {
    _screenEventController.close();
    _screenStateController.close();
  }
}
