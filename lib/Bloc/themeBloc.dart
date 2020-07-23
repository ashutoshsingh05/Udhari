import 'dart:async';

import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Bloc/themeEvents.dart';
import 'package:udhari/Utils/globals.dart';

class ThemeBloc extends Bloc {
  ThemeData themeData = ThemeData.dark();

  ThemeData get initialTheme => this.themeData;

  StreamController<SwitchTheme> _themeEventController =
      StreamController<SwitchTheme>.broadcast();
  StreamSink<SwitchTheme> get themeEventSink => _themeEventController.sink;
  Stream<SwitchTheme> get _themeEventStream => _themeEventController.stream;

  StreamController<ThemeData> _themeStateController =
      StreamController<ThemeData>.broadcast();
  StreamSink<ThemeData> get _themeStateSink => _themeStateController.sink;
  Stream<ThemeData> get themeStateStream => _themeStateController.stream;

  ThemeBloc() {
    _themeEventStream.listen(_mapEventToFunction);
    themeData = Globals.pref?.getBool(Globals.isDark) ?? true
        ? ThemeData.dark()
        : ThemeData.light();
  }

  void _mapEventToFunction(SwitchTheme event) {
    if (Theme.of(event.context).brightness == Brightness.light) {
      themeData = ThemeData.dark();
      _themeStateSink.add(themeData);
      Globals.pref.setBool(Globals.isDark, true);
    } else {
      themeData = ThemeData.light();
      _themeStateSink.add(themeData);
      Globals.pref.setBool(Globals.isDark, false);
    }
  }

  @override
  void dispose() {
    _themeEventController.close();
    _themeStateController.close();
  }
}
