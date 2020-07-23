import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';
import 'package:udhari/Utils/historyTile.dart';
import 'package:udhari/Bloc/userBloc.dart';

@deprecated
class History extends StatefulWidget {
  // History({@required this.user});

  // final FirebaseUser user;

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  CollectionReference colRef;
  AnimationController _controllerList;
  FirebaseUser firebaseUser;

  @override
  void initState() {
    super.initState();
    // colRef = Firestore.instance
    //     .collection('Users 2.0')
    //     .document(
    //         '${firebaseUser.phoneNumber.substring(firebaseUser.phoneNumber.length - 10)}')
    //     .collection('Udhari');
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
    firebaseUser = BlocProvider.of<UserBloc>(context).firebaseUser;

    colRef = Firestore.instance
        .collection('Users 2.0')
        .document(
            '${firebaseUser.phoneNumber.substring(firebaseUser.phoneNumber.length - 10)}')
        .collection('Udhari');

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
                  backgroundImage: NetworkImage(firebaseUser.photoUrl ??
                      "https://api.adorable.io/avatars/100/${firebaseUser.phoneNumber}.png"),
                ),
              ),
              title: Text(firebaseUser.displayName ?? firebaseUser.phoneNumber),
              actions: <Widget>[
                IconButton(
                  tooltip: "Delete All",
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    return showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete all"),
                            content: Text(
                                "Are you sure you want to clear your entire history?"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Delete All"),
                                onPressed: () async {
                                  var db = await Firestore.instance
                                      .collection("Users 2.0")
                                      .document(firebaseUser.phoneNumber
                                          .substring(
                                              firebaseUser.phoneNumber.length -
                                                  10))
                                      .collection("Udhari")
                                      .where("isPaid", isEqualTo: true)
                                      .getDocuments();
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    _signOut();
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
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
                      .where("isPaid", isEqualTo: true)
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
                                child: HistoryTile(
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
                                        .document(firebaseUser.phoneNumber
                                            .substring(firebaseUser
                                                    .phoneNumber.length -
                                                10))
                                        .collection("Udhari")
                                        .document(document['epochTime'])
                                        .updateData({
                                      "isPaid": false,
                                    });
                                  },
                                  // onTap: () {
                                  //   _editCard(
                                  //     amount: document['amount'],
                                  //     dateTime: document['dateTime'],
                                  //     epochTime: document['epochTime'],
                                  //     personName: document['personName'],
                                  //     udhariContext: document['context'],
                                  //     udhariTypeValue: document['isBorrowed']
                                  //         ? "Borrowed"
                                  //         : "Lent",
                                  //   );
                                  // },
                                  onTap: () {
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
                                                        ? firebaseUser
                                                            .displayName
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
                                              TableRow(children: <Widget>[
                                                Text("Paid at"),
                                                Text(
                                                  DateFormat(
                                                          "MMMM d, yyyy 'at' h:mma")
                                                      .format(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                          int.parse(
                                                            document["paidOn"],
                                                          ),
                                                        ),
                                                      )
                                                      .toString(),
                                                ),
                                              ]),
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
                                                    .document(firebaseUser
                                                        .phoneNumber
                                                        .substring(firebaseUser
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

  // void _editCard({
  //   @required double amount,
  //   @required String personName,
  //   @required String udhariContext,
  //   @required String dateTime,
  //   @required String epochTime,
  //   @required String udhariTypeValue,
  // }) {
  //   Navigator.push(
  //     context,
  //     PageRouteBuilder(
  //       opaque: false,
  //       pageBuilder: (BuildContext context, animation, secondaryAnimation) {
  //         return SlideTransition(
  //           position: Tween<Offset>(
  //             begin: Offset(1.0, 0),
  //             end: Offset.zero,
  //           ).animate(animation),
  //           child: UdhariForm(
  //             user: firebaseUser,
  //             amountOpt: amount,
  //             contextOpt: udhariContext,
  //             dateTimeOpt: dateTime,
  //             personNameOpt: personName,
  //             udhariTypeValue: udhariTypeValue,
  //             epochTime: epochTime,
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    var _auth = FirebaseAuth.instance;
    _auth.signOut();
    print("Logged out");
  }
}
