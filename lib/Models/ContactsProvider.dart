// import 'package:flutter/material.dart';
// import 'package:contacts_service/contacts_service.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';

// class ContactsProvider {
//   static final List<String> cities = [
//     'Beirut',
//     'Damascus',
//     'San Fransisco',
//     'Rome',
//     'Los Angeles',
//     'Madrid',
//     'Bali',
//     'Barcelona',
//     'Paris',
//     'Bucharest',
//     'New York City',
//     'Philadelphia',
//     'Sydney',
//   ];

//   static List<String> getSuggestions(String query) {
//     List<String> matches = List();
//     matches.addAll(cities);

//     matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
//     return matches;
//   }

//   void _permissionhandler() async {
//     PermissionStatus permission = await PermissionHandler()
//         .checkPermissionStatus(PermissionGroup.contacts);
//     print("Permission Check: $permission");
//     if (permission != PermissionStatus.granted) {
//       Map<PermissionGroup, PermissionStatus> permissionReq =
//           await PermissionHandler()
//               .requestPermissions([PermissionGroup.contacts]);
//       print("Permission Req: $permissionReq");
//       if (permissionReq.values.elementAt(0) == PermissionStatus.denied) {
//         await PermissionHandler().openAppSettings();
//         if (permission != PermissionStatus.granted) {
//           return showDialog(
//               context: context,
//               barrierDismissible: false,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: Text("Permission Denied"),
//                   content: Text(
//                       "Please give Contacts permission. It is necessary for providing person name suggestion"),
//                   actions: <Widget>[
//                     FlatButton(
//                       child: Text("OK"),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _permissionhandler();
//                       },
//                     ),
//                   ],
//                 );
//               });
//         } else {
//           print("Initializing contacts");
//           contactNameListBuilder();
//         }
//       }
//     } else if (permission == PermissionStatus.granted) {
//       print("Initializing contacts");
//       contactNameListBuilder();
//     }
//   }

//   contactNameListBuilder() async {
//     myContacts = List<DropdownMenuItem>();
//     Iterable<Contact> contacts = await ContactsService.getContacts();
//     setState(() {
//       for (Contact c in contacts) {
//         print("Contact: ${c.displayName}");
//         for (Item i in c.phones) {
//           String number = i.value;
//           if (number.length > 10) {
//             number = number
//                 .replaceAll(" ", "")
//                 .replaceAll("+", "")
//                 .replaceAll("-", "")
//                 .trim();
//             number = number.substring(number.length - 10, number.length);
//             print("Number: $number");
//           }
//           myContacts.add(
//             DropdownMenuItem(
//               // child: RichText(
//               //   text: TextSpan(
//               //     children: [
//               //       TextSpan(
//               //         text: c.displayName,
//               //         style: TextStyle(fontSize: 14, color: Colors.black),
//               //       ),
//               //       TextSpan(
//               //         text: ", $number",
//               //         style: TextStyle(fontSize: 12, color: Colors.grey),
//               //       ),
//               //     ],
//               //   ),
//               //   maxLines: 1,
//               //   overflow: TextOverflow.ellipsis,
//               // ),
//               child: ListTile(
//                 title: Text(c.displayName),
//               ),
//               value: number,
//             ),
//           );
//         }
//       }
//     });
//     // print("Contacts: $contacts");
//   }
// }
