import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:udhari_2/Dashboard.dart';

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
        title: "Udhari",
        description:
            "Ever lent money to a friend but forgot to ask him to pay to back?",
        backgroundColor: Color(0xff9932CC),
      ),
    );
    slides.add(
      new Slide(
        title: "Udhari",
        description:
            "Ever lent money to a friend but forgot to ask him to pay to back?",
        backgroundColor: Color(0xff9932CC),
      ),
    );
    slides.add(
      new Slide(
        title: "Login or SignUp",
        description: "Someday you will come here and sign up for yourself",
        backgroundColor: Color(0xff9932CC),
      ),
    );
  }

  void onDonePressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Dashboard(),
      ),
    );
  }

  void onSkipPressed() {}

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: slides,
      onDonePress: onDonePressed,
      isScrollable: false,
      borderRadiusDoneBtn: 0,
      borderRadiusSkipBtn: 0,
      borderRadiusPrevBtn: 0,
      onSkipPress: onSkipPressed,
    );
  }
}
