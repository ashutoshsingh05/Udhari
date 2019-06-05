import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
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
        maxLineTitle: 2,
        title: "EVERYTHING\nIN CHECK",
        pathImage: 'assets/checklist.png',
        description: "Monitor all your expenses. Never lose a penny again!",
        backgroundColor: Colors.green,
      ),
    );
    slides.add(
      new Slide(
        title: "GET STARTED!",
        maxLineTitle: 2,
        centerWidget: Center(child: Login()),
        // description:
        //     "Login with your Google account to manage all your expenses\n\nSafe, Secure and Convenient.",
        backgroundColor: Colors.deepOrangeAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: slides,
      onDonePress: null,
      renderDoneBtn: SizedBox(),
      isScrollable: true,
      borderRadiusDoneBtn: 0,
      isShowPrevBtn: true,
      isShowSkipBtn: false,
      borderRadiusPrevBtn: 0,
    );
  }
}
