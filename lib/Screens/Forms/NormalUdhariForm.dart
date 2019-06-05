import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NormalUdhariForm extends StatefulWidget {
  NormalUdhariForm({@required this.user});

  final FirebaseUser user;

  @override
  _NormalUdhariFormState createState() => _NormalUdhariFormState();
}

class _NormalUdhariFormState extends State<NormalUdhariForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}