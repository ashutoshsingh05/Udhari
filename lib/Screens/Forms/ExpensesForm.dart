import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpensesForm extends StatefulWidget {
  ExpensesForm({@required this.user});

  final FirebaseUser user;

  @override
  _ExpensesFormState createState() => _ExpensesFormState();
}

class _ExpensesFormState extends State<ExpensesForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
