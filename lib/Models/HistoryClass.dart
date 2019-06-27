import 'package:flutter/material.dart';
import 'package:udhari_2/Models/ExpensesClass.dart';

class History {
  Expenses history;
  String source;

  History({
    @required this.source,
    @required this.history,
  });

  History.fromSnapshot(snapshot) {
    source = snapshot.data['source'];
    history = snapshot.data['history'];
  }

  toJson() {
    return {
      "source": source,
      "history": history,
    };
  }
}
