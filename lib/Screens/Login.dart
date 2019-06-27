import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  OverlayEntry _overlayEntry;

  @override
  void initState() {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.4),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/user.phonenumbers.read',
      // 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Padding(
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
              Overlay.of(context).insert(_overlayEntry);
              _handleGoogleSignIn().then((FirebaseUser user) {
                print(
                    "Signed in ${user.displayName} with E mail ${user.email}");
                _setBasicData(user);
                _overlayEntry.remove();
              }).catchError((e) {
                _overlayEntry.remove();
                print("Error signin in: $e");
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
  }

  Future<FirebaseUser> _handleGoogleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    return user;
  }

  void _setBasicData(FirebaseUser user) async {
    await Firestore.instance
        .collection('Users 2.0')
        .document(user.uid)
        .setData({
      "Name": user.displayName,
      "Email": user.email,
      "PhoneNumber": user.phoneNumber,
      "uid": user.uid,
      "photoUrl":user.photoUrl,
    });
  }
}
