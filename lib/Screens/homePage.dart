import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:udhari/Bloc/screenBloc.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Screens/Forms/expensesForm.dart';
import 'package:udhari/Screens/Forms/tripsForm.dart';
import 'package:udhari/Screens/Forms/udhariForm.dart';
import 'package:udhari/Utils/globals.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color labelBackgroundColor = Colors.white;
  Color floatingButtonBgColor = Colors.white;
  Color floatingButtonFgColor = Colors.white;
  Color expensesLabelColor = Colors.red;
  Color udhariLabelColor = Colors.blue;
  Color tripsLabelColor = Colors.green;
  Color bottomNavUnselectedColor = Colors.black;

  int _iconIndex = 0;
  UserBloc user;
  ScreenBloc screenBloc;

  @override
  void initState() {
    super.initState();
    requestContactPermission(context);
  }

  // printProfile() {
  //   print("======================================");
  //   print("PROFILE");
  //   print("displayName:${user.firebaseUser.displayName}");
  //   print("photoUrl:${user.firebaseUser.photoUrl}");
  //   print("phoneNumber:${user.firebaseUser.phoneNumber}");
  //   print("uid:${user.firebaseUser.uid}");
  //   print("======================================");
  // }

  void initColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      labelBackgroundColor = Colors.white;
      floatingButtonBgColor = Colors.white;
      floatingButtonFgColor = Colors.black;
      bottomNavUnselectedColor = Colors.black;
    } else {
      labelBackgroundColor = Colors.white;
      floatingButtonBgColor = Color(0xff605052);
      floatingButtonFgColor = Colors.white;
      bottomNavUnselectedColor = Color(0xff969696);
    }
  }

  @override
  Widget build(BuildContext context) {
    user = BlocProvider.of<UserBloc>(context);
    screenBloc = BlocProvider.of<ScreenBloc>(context);
    _iconIndex = screenBloc.getIndex;
    initColor(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder(
        stream: screenBloc.screenStateStream,
        initialData: screenBloc.getCurrentScreen,
        builder: (BuildContext context, snapshot) {
          return snapshot.data;
        },
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          elevation: 5,
          selectedItemColor: Colors.blue,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: bottomNavUnselectedColor,
          showUnselectedLabels: true,
          currentIndex: _iconIndex,
          onTap: (int index) async {
            switch (index) {
              // request contact permission if user wants to go to udhari tab
              case 1:
                if (await requestContactPermission(context) ?? false) {
                  screenBloc.screenEventSink.add(index);
                  setState(() {
                    _iconIndex = index;
                  });
                } else {
                  Fluttertoast.showToast(msg: "Contacts permission denied");
                }
                break;
              default:
                screenBloc.screenEventSink.add(index);
                setState(() {
                  _iconIndex = index;
                });
            }
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              title: Text("Expenses"),
              icon: Icon(Icons.trending_up),
            ),
            BottomNavigationBarItem(
              title: Text("Udhari"),
              icon: Icon(Icons.attach_money),
            ),
            // BottomNavigationBarItem(
            //   title: Text("Bill Split"),
            //   icon: Icon(Icons.description),
            // ),
            //TODO: uncomment when developing trips
            // BottomNavigationBarItem(
            //   title: Text("Trips"),
            //   icon: Icon(Icons.group),
            // ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        tooltip: 'MENU',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: floatingButtonBgColor,
        foregroundColor: floatingButtonFgColor,
        elevation: 7.0,
        shape: CircleBorder(),
        children: <SpeedDialChild>[
          SpeedDialChild(
            child: Icon(Icons.attach_money),
            backgroundColor: expensesLabelColor,
            label: 'Expenses',
            labelStyle: TextStyle(fontSize: 18.0),
            labelBackgroundColor: floatingButtonBgColor,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder:
                      (BuildContext context, animation, secondaryAnimation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1.0, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: ExpensesForm(),
                    );
                  },
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.person_add),
            backgroundColor: udhariLabelColor,
            label: 'Udhari',
            labelStyle: TextStyle(fontSize: 18.0),
            labelBackgroundColor: floatingButtonBgColor,
            onTap: () async {
              bool isGranted = await requestContactPermission(context) ?? false;
              if (isGranted) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder:
                        (BuildContext context, animation, secondaryAnimation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(1.0, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: UdhariForm(),
                      );
                    },
                  ),
                );
              } else {
                Fluttertoast.showToast(msg: "Contacts permission denied");
              }
            },
          ),
          // TODO: uncomment when developing trips
          // SpeedDialChild(
          //   child: Icon(Icons.group_add),
          //   backgroundColor: tripsLabelColor,
          //   label: 'Trip',
          //   labelStyle: TextStyle(fontSize: 18.0),
          //   labelBackgroundColor: floatingButtonBgColor,
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       PageRouteBuilder(
          //         opaque: false,
          //         pageBuilder:
          //             (BuildContext context, animation, secondaryAnimation) {
          //           return SlideTransition(
          //             position: Tween<Offset>(
          //               begin: Offset(1.0, 0),
          //               end: Offset.zero,
          //             ).animate(animation),
          //             child: TripsForm(),
          //           );
          //         },
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  // Future<bool> _requestContactPermission() async {
  //   PermissionStatus permissonStatus = await Permission.contacts.status;
  //   print("Permisson status: $permissonStatus");
  //   switch (permissonStatus) {
  //     case PermissionStatus.undetermined:
  //       print("PermissionStatus.undetermined");
  //       permissonStatus = await Permission.contacts.request();
  //       return await _requestContactPermission();
  //       break;
  //     case PermissionStatus.granted:
  //       print("PermissionStatus.granted");
  //       return true;
  //       break;
  //     case PermissionStatus.denied:
  //       print("PermissionStatus.denied");
  //       permissonStatus = await Permission.contacts.request();
  //       return permissonStatus.isGranted;
  //       break;
  //     case PermissionStatus.restricted:
  //       print("PermissionStatus.restricted");
  //       return false;
  //       break;
  //     case PermissionStatus.permanentlyDenied:
  //       print("PermissionStatus.permanentlyDenied");
  //       await permissionUsageDialog();
  //       // permissonStatus = await Permission.contacts.request();
  //       return await _requestContactPermission();
  //       break;
  //     default:
  //       return false;
  //   }
  // }

  // Future permissionUsageDialog() {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return WillPopScope(
  //           onWillPop: () async => false,
  //           child: AlertDialog(
  //             title: Text("Permission Denied"),
  //             content: Text(
  //                 "Udhari needs access your contacts to show people's name instead of phone numbers."),
  //             actions: <Widget>[
  //               FlatButton(
  //                 child: Text("Cancel"),
  //                 onPressed: () {
  //                   SystemNavigator.pop();
  //                 },
  //               ),
  //               FlatButton(
  //                 child: Text("Settings"),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   openAppSettings();
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

  /// Function to get contacts permission. Essential for
  /// the functioning of the app. One more copy of this
  /// function is inside file [intro.dart] for getting
  /// permission at the starting of the app. It's purpose
  /// is to make sure the app does not crashes when the
  /// user has denied contacts permission from the settings
  /// after initially granting when signing up.
  @Deprecated("Use _requestContactPermission instead")
  Future<bool> _permissionHandler() async {
    // Permisssion.
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
        // print("Settings opened: $opened");
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
                        "Udhari needs access your contacts to show people's name instead of phone numbers."),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                      ),
                      FlatButton(
                        child: Text("Settings"),
                        onPressed: () {
                          Navigator.pop(context);
                          openAppSettings();
                          // _permissionHandler();
                        },
                      ),
                    ],
                  ),
                );
              });
        } else {
          print("Contacts Accessible");
          return true;
          // _contactsProvider = ContactsProvider();
        }
      }
    } else {
      print("Contacts Accessible");
      return true;
      // _contactsProvider = ContactsProvider();
    }
  }
}
