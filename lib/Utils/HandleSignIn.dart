import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udhari_2/Screens/Intro.dart';
import 'package:udhari_2/Screens/SplashScreen.dart';
import 'package:udhari_2/Screens/HomePage.dart';

class HandleSignIn extends StatefulWidget {
  @override
  _HandleSignInState createState() => _HandleSignInState();
}

class _HandleSignInState extends State<HandleSignIn> {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none) {
          return SplashScreen();
        } else {
          if (snapshot.hasData) {
            return new HomePage(user: snapshot.data);
          }
          return new Intro();
        }
      },
    );
  }
}
