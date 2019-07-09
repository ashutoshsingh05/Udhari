import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  OverlayEntry _overlayEntry;

  FirebaseAuth _auth;
  FirebaseUser user;
  UserUpdateInfo userInfo;

  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _displayNameController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode _numberNode = FocusNode();

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
    userInfo = UserUpdateInfo();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Enter your 10 digit mobile number below and relax.\n\nWe will verify it automatically for you!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    autocorrect: true,
                    controller: _displayNameController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    maxLength: 30,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return "Please Enter your name";
                      }
                      if (value.length < 3) {
                        return "Too short. Consider using your full name";
                      }
                    },
                    inputFormatters: [
                      WhitelistingTextInputFormatter(
                        RegExp("[a-zA-Z\ ]"),
                      ),
                    ],
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        color: Colors.white,
                      ),
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
                      hintText: "Your name",
                      prefixIcon: Icon(Icons.person),
                    ),
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_numberNode);
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _phoneNumberController,
                    focusNode: _numberNode,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
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
                ],
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
      timeout: Duration(seconds: 30),
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
        print("Phone Verification Complete");
        await _auth.signInWithCredential(credentials).then((user) {
          _setBasicData(user);
          _overlayEntry.remove();
          Fluttertoast.showToast(
            msg: "Successfully Signed in",
            backgroundColor: Colors.grey,
            gravity: ToastGravity.BOTTOM,
          );
        });
      },
      codeAutoRetrievalTimeout: (String verificaionID) {
        print("Timed out");
        _overlayEntry.remove();
      },
    );
  }

  Future<void> _setBasicData(FirebaseUser user) async {
    userInfo.displayName = _displayNameController.text;
    userInfo.photoUrl =
        "https://api.adorable.io/avatars/100/${user.phoneNumber}.png";
    await user.updateProfile(userInfo);

    await Firestore.instance
        .collection('Users 2.0')
        .document(user.phoneNumber.substring(user.phoneNumber.length - 10))
        .setData({
      "displayName": _displayNameController.text,
      "phoneNumber": user.phoneNumber.substring(user.phoneNumber.length - 10),
      "uid": user.uid,
      "photoUrl":
          "https://api.adorable.io/avatars/100/${user.phoneNumber}.png"
    });
  }
}
