import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TotalExpense {
  TotalExpense({@required this.user});

  final FirebaseUser user;
  double total = 0;
  String _time;
  TextStyle _style = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  StreamController<Text> expenseStreamController = StreamController<Text>();
  Sink get expenseSink => expenseStreamController.sink;
  Stream<Text> get expenseStream => expenseStreamController.stream;

  void updateExpenses() async {
    _time = (DateTime.now().millisecondsSinceEpoch - 2592000000).toString();
    QuerySnapshot db = await Firestore.instance
        .collection('Users 2.0')
        .document(user.uid)
        .collection('Expenses')
        .where('epochTime', isGreaterThanOrEqualTo: _time)
        .getDocuments();

    int length = db.documents.length.toInt();

    if (length > 0) {
      for (int i = 0; i < length; i++) {
        total += db.documents[i].data['amount'];
      }
      print("total: $total");
      expenseSink.add(Text("₹$total", style: _style));
      print("Added $total to sink");
    } else {
      print("total: $total");
      expenseSink.add(Text("₹0", style: _style));
      print("Added $total to sink");
    }
  }

  void dispose() {
    // expenseStreamController.close();
  }
}
