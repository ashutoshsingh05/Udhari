import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udhari/Models/contactsProvider.dart';

class Globals {
  // static bool darkModeEnabled = true;

  static const namePref = "namePref";
  static const isDark = "isDark";
  static SharedPreferences pref;

  static final dateTimeFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");

  static final double dialogTextScale = 1.2;

  static const double curvature = 12;

  static PackageInfo packageInfo;

  /// For easy access of phoneNumber in [billSplitForm.dart]
  /// since we need phoneNumber in initState i.e before build method
  /// where the bloc is accessed. This parameter is assigned inside
  /// file [billSplitBloc.dart] inside setter [setUserBloc].
  /// It is also initialized inside userBloc since the [billSplitBloc.dart]
  /// is currently not being used.
  static String phoneNumber;

  static const TextStyle smallGreyText = const TextStyle(
    color: Colors.grey,
    fontSize: 11.5,
  );

  static const TextStyle mediumGreyText = const TextStyle(
    color: Colors.grey,
    fontSize: 14,
  );

  static const TextStyle titleTextStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  static String phoneToPhotoUrl(String phoneNumber, [int size = 55]) {
    return "https://api.adorable.io/avatars/$size/$phoneNumber.png";
  }

  /// Try to fetch a name from user contacts with the related phoneNumber
  /// In case, if no contact exists for the given number,
  /// assign the phone number to name instead.
  static Future<String> getOneNameFromPhone(String phoneNumber) async {
    List<String> names;
    names = await ContactsProvider.getNameFromContactNumber(phoneNumber);
    // If the result is empty, check wheather the number
    // belongs to the user or not.
    // print("phone:$phoneNumber name: $names");
    if (names.isEmpty) {
      if (phoneNumber == Globals.phoneNumber) {
        return "You";
      } else {
        return phoneNumber;
      }
    }
    return names.first;
  }

  /// A boolean function which checks if the given phoneNumber is
  /// registered or not. It checks for it's existence
  /// in Users 3.0/data/users/{phoneNumber} document
  static Future<bool> isPhoneRegistered(String phoneNumber) async {
    DocumentSnapshot snapshot = await Firestore.instance
        // .collection("Users 3.0")
        // .document("data")
        .collection("users")
        .document("$phoneNumber")
        .get();
    if (snapshot.exists)
      return true;
    else
      return false;
  }

  /// Function to convert time to relative time.
  /// For eg. converts time 23 Jan 2020 to 2 days ago
  /// Used to removing commotion from all the tiles
  /// and make them look clean.
  static String timeAbsoluteToRelative(
      {DateTime dateTime, String dateTimeString}) {
    assert(dateTime != null || dateTimeString != null);

    String relative = "meh.";
    Duration duration;
    if (dateTimeString != null) {
      dateTime =
          DateFormat("EEEE, MMMM d, yyyy 'at' h:mma").parse(dateTimeString);
    }

    duration = DateTime.now().difference(dateTime);

    if (duration < Duration(seconds: 0)) {
      relative = "Sometime in future";
    } else if (duration < Duration(minutes: 3)) {
      relative = "Just Now";
    } else if (duration < Duration(hours: 1)) {
      relative = "Few minutes ago";
    } else if (duration < Duration(hours: 2)) {
      relative = "An hour ago";
    } else if (duration < Duration(hours: 12)) {
      relative = "Few hours ago";
    } else if (duration < Duration(hours: 24)) {
      relative = "More than 12 hours ago";
    } else if (duration < Duration(days: 2)) {
      relative = "A day ago";
    } else if (duration < Duration(days: 7)) {
      relative = "Few days ago";
    } else if (duration < Duration(days: 30)) {
      relative = "Few weeks ago";
    } else if (duration < Duration(days: 365)) {
      relative = "${(duration.inDays ~/ 30)} month ago";
    } else {
      relative = "${((duration.inDays / 30)) ~/ 12} year ago";
    }
    return relative;
  }

  /// Returns the corresponding 3 character month
  /// (JAN,FEB etc) from the integer provided.
  static String mapMonth(int a) {
    assert(a >= 1 && a <= 12);
    switch (a) {
      case 1:
        return "JAN";
      case 2:
        return "FEB";
      case 3:
        return "MAR";
      case 4:
        return "APR";
      case 5:
        return "MAY";
      case 6:
        return "JUN";
      case 7:
        return "JUL";
      case 8:
        return "AUG";
      case 9:
        return "SEP";
      case 10:
        return "OCT";
      case 11:
        return "NOV";
      case 12:
        return "DEC";
      default:
        return "UNK";
    }
  }
}

Future<bool> requestContactPermission(BuildContext context) async {
  PermissionStatus permissonStatus = await Permission.contacts.status;
  print("Permisson status: $permissonStatus");
  switch (permissonStatus) {
    case PermissionStatus.undetermined:
      print("PermissionStatus.undetermined");
      permissonStatus = await Permission.contacts.request();
      return await requestContactPermission(context);
      break;
    case PermissionStatus.granted:
      print("PermissionStatus.granted");
      return true;
      break;
    case PermissionStatus.denied:
      print("PermissionStatus.denied");
      permissonStatus = await Permission.contacts.request();
      return permissonStatus.isGranted;
      break;
    case PermissionStatus.restricted:
      print("PermissionStatus.restricted");
      return false;
      break;
    case PermissionStatus.permanentlyDenied:
      print("PermissionStatus.permanentlyDenied");
      await _permissionUsageDialog(context);
      // permissonStatus = await Permission.contacts.request();
      return await requestContactPermission(context);
      break;
    default:
      return false;
  }
}

Future _permissionUsageDialog(BuildContext context) {
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
                },
              ),
            ],
          ),
        );
      });
}
