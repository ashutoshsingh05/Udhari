import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:udhari_2/Utils/LoginScreenHandler.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginScreenHandler screen;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    Widget loginScreen = Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/google.png"),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Text(
              "Sign In to sync your data across all your devices",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          MaterialButton(
            height: 40,
            color: Colors.white,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                color: Colors.white,
                width: 0,
              ),
            ),
            onPressed: () {
              screen.showCircularProgressIndicator();
              _handleGoogleSignIn().then((FirebaseUser user) {
                print(
                    "Signed in ${user.displayName} with E mail ${user.email}");
              }).catchError((e) {
                print("Error signin in: $e");
                screen.hideCircularProgressIndicator();
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage("assets/google.png"),
                  backgroundColor: Colors.transparent,
                  maxRadius: 12,
                ),
                SizedBox(
                  width: 7,
                ),
                Text("Sign In with Google")
              ],
            ),
          ),
        ],
      ),
    );

    screen = LoginScreenHandler(loginScreen);
    return StreamBuilder(
      initialData: loginScreen,
      stream: screen.currentWidgetStream,
      builder: (BuildContext context, snapshot) {
        return snapshot.data;
      },
    );
  }

  Future<FirebaseUser> _handleGoogleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return user;
  }
}
