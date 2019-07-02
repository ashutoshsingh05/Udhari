import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:googleapis/people/v1.dart' show PeopleApi;
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' show BaseRequest, Response, StreamedResponse;
// import 'package:http/io_client.dart';
// import 'dart:async' show Future;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  OverlayEntry _overlayEntry;
  FirebaseAuth _auth;
  TextEditingController _phoneNumberController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _countryCode = "+91";

  @override
  void initState() {
    _auth = FirebaseAuth.instance;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Enter your 10 digit mobile number below and relax.\n\n We will verify it automatically for you!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 10),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _phoneNumberController,
                maxLength: 10,
                keyboardType: TextInputType.phone,
                // onChanged: (String newVal) {},
                inputFormatters: [
                  WhitelistingTextInputFormatter(
                    RegExp("[0-9]"),
                  ),
                ],
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter your phone number";
                  }
                  if (value.length != 10) {
                    return "Please enter 10 digits";
                  }
                },
                onFieldSubmitted: (_) {
                  if (_formKey.currentState.validate()) {
                    Overlay.of(context).insert(_overlayEntry);
                    _verifyPhoneNumber();
                  }
                },
                decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 0,
                    ),
                  ),
                  hintText: "10-digit mobile number",
                  prefixIcon: CountryCodePicker(
                    initialSelection: "+91",
                    favorite: ["+91"],
                    showFlag: true,
                    onChanged: (code) {
                      _countryCode = code.dialCode;
                    },
                  ),
                ),
              ),
            ),
          ),
          MaterialButton(
            height: 40,
            minWidth: 150,
            color: Colors.white,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                color: Colors.white,
                width: 0,
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                Overlay.of(context).insert(_overlayEntry);
                await _verifyPhoneNumber();
              }
            },
            child: Text("Sign In"),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPhoneNumber() async {
    print("Phone: ${_countryCode + _phoneNumberController.text}");
    await _auth.verifyPhoneNumber(
      phoneNumber: _countryCode + _phoneNumberController.text,
      codeSent: (String verficationID, [int resendcodeTimeout]) {
        print("Code Sent to device");
      },
      timeout: Duration(seconds: 60),
      verificationFailed: (AuthException exception) {
        print("Verification Failed: $exception");
        _overlayEntry.remove();
        Fluttertoast.showToast(
          msg: "Error occured. Please try again later",
          backgroundColor: Colors.grey,
          gravity: ToastGravity.BOTTOM,
        );
      },
      verificationCompleted: (AuthCredential credentials) async {
        print("Verification Complete");
        await _auth.signInWithCredential(credentials).then((user) async {
          _overlayEntry.remove();
          await _setBasicData(user);
          Fluttertoast.showToast(
            msg: "Successfully Signed in",
            backgroundColor: Colors.grey,
            gravity: ToastGravity.BOTTOM,
          );
        });
      },
      codeAutoRetrievalTimeout: (String verificaionID) {
        _overlayEntry.remove();
      },
    );
  }

  Future<void> _setBasicData(FirebaseUser user) async {
    UserUpdateInfo userInfo = UserUpdateInfo();
    userInfo.displayName = _phoneNumberController.text;
    userInfo.photoUrl =
        "https://api.adorable.io/avatars/100/${user.phoneNumber}.png";
    print("UserInfoUpdated: ${userInfo}");
    await user.updateProfile(userInfo).then((_) {
      print("Profile updated ");
    }).catchError((e) {
      print("Error updating profile: $e");
    });
    // await user.reload();
    await Firestore.instance
        .collection('Users 2.0')
        .document(user.phoneNumber)
        .setData({
      "Name": user.displayName,
      "PhoneNumber": user.phoneNumber,
      "uid": user.uid,
      "photoUrl": user.photoUrl,
    });
  }
}
