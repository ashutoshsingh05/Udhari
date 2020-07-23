import 'package:flutter/material.dart';

@deprecated
class CustomTextController extends TextEditingController {
  String phoneNumber;
  String name;
  CustomTextController({this.phoneNumber, this.name})
      : super(
          text: name,
        );

  // overrides the super().text and return
  // this.name instead
  // @override
  // String get text => this.name;

  // @override
  // set text(String text) {
  //   this.name = text;
  // }
}
