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
  var firestore; // empty variable, I don't know what to do with it.
  @override
  Widget build(BuildContext context) {
    // return new StreamBuilder<FirebaseUser>(
    //   stream: FirebaseAuth.instance.onAuthStateChanged,
    //   builder: (BuildContext context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting ||
    //         snapshot.connectionState == ConnectionState.none) {
    //       return SplashScreen();
    //     } else {
    //       if (snapshot.hasData) {
    //         return new Dashboard(firestore: firestore, uuid: snapshot.data.uid);
    //       }
    //       return new Intro();
    //     }
    //   },
    // );
    return HomePage();
  }
}
