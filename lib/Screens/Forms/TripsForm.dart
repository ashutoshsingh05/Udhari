import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripsForm extends StatefulWidget {
  TripsForm({@required this.user});

  final FirebaseUser user;

  @override
  _TripsFormState createState() => _TripsFormState();
}

class _TripsFormState extends State<TripsForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
