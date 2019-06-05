import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Trips extends StatefulWidget {
  Trips({@required this.user});

  final FirebaseUser user;

  @override
  _TripsState createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Trips"),
      ),
    );
  }
}
