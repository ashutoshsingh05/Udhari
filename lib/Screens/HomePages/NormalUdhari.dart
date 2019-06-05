import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NormalUdhari extends StatefulWidget {
  NormalUdhari({this.user});

  final FirebaseUser user;

  @override
  _NormalUdhariState createState() => _NormalUdhariState();
}

class _NormalUdhariState extends State<NormalUdhari> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("NormalUdhari"),
      ),
    );
  }
}
