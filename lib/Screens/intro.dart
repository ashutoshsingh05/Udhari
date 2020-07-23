import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:udhari/Screens/login.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  List<Slide> slides = new List();
  Color page1Color = Color(0xff9932CC);
  Color page2Color = Colors.green;
  Color page3Color = Colors.deepOrangeAccent;

  void initColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      page1Color = Color(0xff9932CC);
      page2Color = Colors.green;
      page3Color = Colors.deepOrangeAccent;
    } else {
      page1Color = Color(0xff231E35);
      page2Color = Color(0xff601945);
      page3Color = Color(0xff583B51);
    }
  }

  // @override
  // void initState() {
  //   super.initState();

  //   // _permissionHandler();
  // }

  void addSlides() {
    slides.add(
      new Slide(
        title: "UDHARI",
        pathImage: 'assets/icon.png',
        description:
            "Ever lent money to a friend but they forgot to pay you back?\n\nNot anymore!\nKeep record of all your Udhari",
        backgroundColor: page1Color,
      ),
    );
    slides.add(
      new Slide(
        maxLineTitle: 2,
        title: "EVERYTHING\nIN CHECK",
        pathImage: 'assets/checklist.png',
        description: "Monitor all your expenses. Never lose a penny again!",
        backgroundColor: page2Color,
      ),
    );
    slides.add(
      new Slide(
        title: "GET STARTED!",
        maxLineTitle: 2,
        centerWidget: Center(child: Login()),
        // description:
        //     "Login with your Google account to manage all your expenses\n\nSafe, Secure and Convenient.",
        backgroundColor: page3Color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initColor(context);
    addSlides();
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

  /// Function to get contacts permission. Essential for
  /// the functioning of the app. One more copy of this
  /// function is inside the file [homepage.dart] for
  /// checking the permission at the starting
  /// of the app after login.
  void _permissionHandler() async {
    // Permisssion.
    print("");
    bool contactPermission = await Permission.contacts.isGranted;
    print("Contact Permission Check: $contactPermission");
    if (!contactPermission) {
      // Map<PermissionGroup, PermissionStatus> permissionReq =
      //     await PermissionHandler()
      //         .requestPermissions([PermissionGroup.contacts]);
      PermissionStatus status = await Permission.contacts.request();
      print("Permission Req: ${status.isGranted}");
      if (status.isPermanentlyDenied) {
        openAppSettings();
        status = await Permission.contacts.request();
        if (status.isPermanentlyDenied) {
          return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    title: Text("Permission Denied"),
                    content: Text(
                        "Udhari needs your contacts to show people's name instead of phone numbers."),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          _permissionHandler();
                        },
                      ),
                      FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                      ),
                    ],
                  ),
                );
              });
        } else {
          print("Contacts Accessible");
          // _contactsProvider = ContactsProvider();
        }
      }
    } else {
      print("Contacts Accessible");
      // _contactsProvider = ContactsProvider();
    }
  }
}
