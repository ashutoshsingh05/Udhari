import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:udhari_2/Screens/HomePage.dart';
import 'package:udhari_2/Screens/Login.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();
    addSlides();
  }

  void addSlides() {
    slides.add(
      new Slide(
        title: "UDHARI",
        pathImage: 'assets/icon.png',
        description:
            "Ever lent money to a friend but they forgot to pay you back?\n\nNot anymore!\nKeep record of all your Udhari",
        backgroundColor: Color(0xff9932CC),
      ),
    );
    slides.add(
      new Slide(
        title: "IN CHECK",
        pathImage: 'assets/checklist.png',
        description:
            "Monitor your expenses, keep your money in check ...\n\nNever lose a penny again!",
        backgroundColor: Color(0xff9432CC),
      ),
    );
    slides.add(
      new Slide(
        title: "Login or SignUp",
        centerWidget: Center(child: Login()),
        description: "Login with your Google account to manage your expenses ",
        backgroundColor: Color(0xff9932CC),
      ),
    );
  }

  void onDonePressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomePage(),
      ),
    );
  }

  void onSkipPressed() {}

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: slides,
      onDonePress: onDonePressed,
      isScrollable: true,
      borderRadiusDoneBtn: 0,
      isShowPrevBtn: true,
      isShowSkipBtn: false,
      borderRadiusPrevBtn: 0,
    );
  }
}
