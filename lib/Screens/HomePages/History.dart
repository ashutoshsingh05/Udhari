import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class History extends StatefulWidget {
  History({@required this.user});

  final FirebaseUser user;

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("History"),
      ),
    );
  }
}
