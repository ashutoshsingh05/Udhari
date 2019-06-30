import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/people/v1.dart' show PeopleApi;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' show BaseRequest, Response, StreamedResponse;
import 'package:http/io_client.dart';
import 'dart:async' show Future;

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
    final authHeaders = await _googleSignIn.currentUser.authHeaders;
    final httpClient = GoogleHttpClient(authHeaders);
    String phoneNumber;

    await PeopleApi(httpClient)
        .people
        .get('people/me', requestMask_includeField: "person.phoneNumbers")
        .then((person) {
      print("First Phone Number: ${person.phoneNumbers.first.value}");
      phoneNumber = person.phoneNumbers.first.value;
    }).catchError((e) {
      print("Found Error retrieving phone number: $e");
    });

    await Firestore.instance
        .collection('Users 2.0')
        .document(user.uid)
        .setData({
      "Name": user.displayName,
      "Email": user.email,
      "PhoneNumber": phoneNumber,
      "uid": user.uid,
      "photoUrl": user.photoUrl,
    });
  }
}

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<StreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}
