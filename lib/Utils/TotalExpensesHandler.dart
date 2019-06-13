import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TotalExpense {
  TotalExpense({@required this.user});

  final FirebaseUser user;
  double total = 0;
  var _time = DateTime.now().millisecondsSinceEpoch - 2592000000;

  Future<int> totalExpenses() async {
    QuerySnapshot db = await Firestore.instance
        .collection('Users 2.0')
        .document(user.uid)
        .collection('Expenses')
        .where('epochTime', isGreaterThanOrEqualTo: _time)
        .getDocuments();
    while (db.documents != null) {}
  }
}
