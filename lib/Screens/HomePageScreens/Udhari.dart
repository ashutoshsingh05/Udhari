import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:udhari_2/Screens/Forms/UdhariForm.dart';
import 'package:udhari_2/Utils/UdhariTile.dart';

class Udhari extends StatefulWidget {
  Udhari({@required this.user});

  final FirebaseUser user;

  @override
  _UdhariState createState() => _UdhariState();
}

class _UdhariState extends State<Udhari> with SingleTickerProviderStateMixin {
  CollectionReference colRef;
  AnimationController _controllerList;

  @override
  void initState() {
    super.initState();
    colRef = Firestore.instance
        .collection('Users 2.0')
        .document(
            '${widget.user.phoneNumber.substring(widget.user.phoneNumber.length - 10)}')
        .collection('Udhari');
    _controllerList = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controllerList.forward();
  }

  @override
  void dispose() {
    _controllerList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Colors.blueAccent,
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.transparent.withOpacity(0),
              elevation: 0,
              leading: Padding(
                padding: EdgeInsets.all(5),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    "https://api.adorable.io/avatars/100/${widget.user.phoneNumber}.png",
                  ),
                ),
              ),
              title: Text(widget.user.displayName ?? widget.user.phoneNumber),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    _signOut();
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder(
                  stream: colRef
                      .orderBy("epochTime", descending: true)
                      .where('epochTime',
                          isGreaterThanOrEqualTo:
                              (DateTime.now().millisecondsSinceEpoch -
                                      2592000000)
                                  .toString())
                      .where("isPaid", isEqualTo: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
                      return Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      if (!snapshot.hasData) {
                        return Text("No data Found!");
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: snapshot.data.documents.map(
                            (DocumentSnapshot document) {
                              return ScaleTransition(
                                scale: CurvedAnimation(
                                  curve: Curves.elasticOut,
                                  parent: _controllerList,
                                ),
                                child: UdhariTile(
                                  amount: document['amount'],
                                  dateTime: document['dateTime'],
                                  epochTime: document['epochTime'],
                                  expenseContext: document['context'],
                                  personName: document['personName'],
                                  photoUrl: document['photoUrl'],
                                  isBorrowed: document['isBorrowed'],
                                  phoneNumber: document['phoneNumber'],
                                  onButtonTapped: () {
                                    Firestore.instance
                                        .collection("Users 2.0")
                                        .document(widget.user.phoneNumber
                                            .substring(
                                                widget.user.phoneNumber.length -
                                                    10))
                                        .collection("Udhari")
                                        .document(document['epochTime'])
                                        .updateData({
                                      "isPaid": true,
                                    });
                                  },
                                  onTap: () {
                                    _editCard(
                                      amount: document['amount'],
                                      dateTime: document['dateTime'],
                                      epochTime: document['epochTime'],
                                      personName: document['personName'],
                                      udhariContext: document['context'],
                                      udhariTypeValue: document['isBorrowed']
                                          ? "Borrowed"
                                          : "Lent",
                                    );
                                  },
                                  onLongPress: () {
                                    return showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Details"),
                                          content: Table(
                                            children: <TableRow>[
                                              TableRow(
                                                children: <Widget>[
                                                  Text("Udhari Type"),
                                                  Text(document['isBorrowed']
                                                      ? "Borrowed"
                                                      : "Lent"),
                                                ],
                                              ),
                                              TableRow(
                                                children: <Widget>[
                                                  Text("Phone"),
                                                  Text(
                                                    document['phoneNumber'],
                                                  ),
                                                ],
                                              ),
                                              TableRow(
                                                children: <Widget>[
                                                  Text("Amount"),
                                                  Text(
                                                      "₹${document['amount']}"),
                                                ],
                                              ),
                                              TableRow(
                                                children: <Widget>[
                                                  Text("Added by"),
                                                  Text(
                                                    document["isSelfAdded"]
                                                        ? widget
                                                            .user.displayName
                                                        : document[
                                                            'personName'],
                                                  ),
                                                ],
                                              ),
                                              TableRow(
                                                children: <Widget>[
                                                  Text("Created at"),
                                                  Text(
                                                    DateFormat(
                                                            "MMMM d, yyyy 'at' h:mma")
                                                        .format(
                                                          DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                            int.parse(
                                                              document[
                                                                  "epochTime"],
                                                            ),
                                                          ),
                                                        )
                                                        .toString(),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text("Delete"),
                                              onPressed: () {
                                                Firestore.instance
                                                    .collection("Users 2.0")
                                                    .document(widget
                                                        .user.phoneNumber
                                                        .substring(widget
                                                                .user
                                                                .phoneNumber
                                                                .length -
                                                            10))
                                                    .collection("Udhari")
                                                    .document(
                                                        document['epochTime'])
                                                    .delete();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _cardBuilder({
  //   @required String personName,
  //   @required double amount,
  //   @required String expenseContext,
  //   @required String dateTime,
  //   @required String epochTime,
  //   @required String photoUrl,
  // }) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 10),
  //     child: Card(
  //       elevation: 5,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.max,
  //         children: <Widget>[
  //           ListTile(
  //             leading: CircleAvatar(
  //               backgroundImage: CachedNetworkImageProvider(
  //                 photoUrl,
  //                 //?? "https://api.adorable.io/avatars/100/${widget.user.phoneNumber}.png",
  //               ),
  //             ),
  //             // dense: true,
  //             isThreeLine: true,
  //             title: Text(
  //               "$personName",
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //             subtitle: Container(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: <Widget>[
  //                   Text(
  //                     expenseContext,
  //                     overflow: TextOverflow.ellipsis,
  //                     maxLines: 3,
  //                     textScaleFactor: 0.9,
  //                   ),
  //                   SizedBox(
  //                     height: 2,
  //                   ),
  //                   Text(
  //                     "$dateTime",
  //                     textScaleFactor: 0.9,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             trailing: SizedBox(
  //               width: 80,
  //               child: Center(
  //                 child: Text(
  //                   '₹${amount.floor()}',
  //                   textScaleFactor: 1.3,
  //                 ),
  //               ),
  //             ),
  //             onTap: () {
  //               _editCard(amount, expenseContext, dateTime);
  //             },
  //             onLongPress: () {
  //               return showDialog(
  //                 context: context,
  //                 barrierDismissible: true,
  //                 builder: (BuildContext context) {
  //                   return AlertDialog(
  //                     title: Text("Confirm Deletion"),
  //                     content: Text(
  //                       "Are you sure you wish to delete this record?",
  //                     ),
  //                     actions: <Widget>[
  //                       FlatButton(
  //                         child: Text("OK"),
  //                         onPressed: () async {
  //                           Navigator.of(context).pop();
  //                           await colRef
  //                               .document('$epochTime')
  //                               .delete()
  //                               .then((_) {
  //                             print("Document Deleted Successfully");
  //                           }).catchError((e) {
  //                             print("Error deleting record: $e");
  //                           });
  //                         },
  //                       ),
  //                       FlatButton(
  //                         child: Text("Cancel"),
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                       ),
  //                     ],
  //                   );
  //                 },
  //               );
  //             },
  //           ),
  //           // Row(
  //           //   mainAxisAlignment: MainAxisAlignment.end,
  //           //   verticalDirection: VerticalDirection.up,
  //           //   children: <Widget>[
  //           //     // Text("PhoneNumber"),
  //           //     FlatButton(
  //           //       child: Text(
  //           //         "Mark as Paid",
  //           //         style: TextStyle(
  //           //           color: Colors.blue,
  //           //         ),
  //           //       ),
  //           //       onPressed: () {},
  //           //     ),
  //           //   ],
  //           // ),
  //           // ButtonTheme.bar(
  //           //   child: ButtonBar(
  //           //     children: <Widget>[
  //           //       FlatButton(
  //           //         child: Text("Mark as Paid"),
  //           //         onPressed: () {},
  //           //       ),
  //           //     ],
  //           //   ),
  //           // ),
  //         ],
  //       ),
  //     ),
  //     // ),
  //   );
  // }

  void _editCard({
    @required double amount,
    @required String personName,
    @required String udhariContext,
    @required String dateTime,
    @required String epochTime,
    @required String udhariTypeValue,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, animation, secondaryAnimation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0),
              end: Offset.zero,
            ).animate(animation),
            child: UdhariForm(
              user: widget.user,
              amountOpt: amount,
              contextOpt: udhariContext,
              dateTimeOpt: dateTime,
              personNameOpt: personName,
              udhariTypeValue: udhariTypeValue,
              epochTime: epochTime,
            ),
          );
        },
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    var _auth = FirebaseAuth.instance;
    _auth.signOut();
    print("Logged out");
  }
}
