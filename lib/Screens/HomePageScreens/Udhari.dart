import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:udhari_2/Screens/Forms/UdhariForm.dart';

class Udhari extends StatefulWidget {
  Udhari({@required this.user});

  final FirebaseUser user;

  @override
  _UdhariState createState() => _UdhariState();
}

class _UdhariState extends State<Udhari> {
  CollectionReference colRef;

  @override
  void initState() {
    super.initState();
    colRef = Firestore.instance
        .collection('Users 2.0')
        .document('${widget.user.phoneNumber}')
        .collection('Udhari');
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
                padding: EdgeInsets.all(7),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(widget
                          .user.photoUrl ??
                      "https://api.adorable.io/avatars/100/${widget.user.phoneNumber}.png"),
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
                              return _cardBuilder(
                                amount: document['amount'],
                                dateTime: document['dateTime'],
                                epochTime: document['epochTime'],
                                expenseContext: document['context'],
                                personName: document['personName'],
                                photoUrl: document['photoUrl'],
                                // document['personName'],
                                // document['amount'],
                                // document['context'],
                                // document['dateTime'],
                                // document['epochTime'],
                                // document['photoUrl'],
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

  Widget _cardBuilder({
    @required String personName,
    @required double amount,
    @required String expenseContext,
    @required String dateTime,
    @required String epochTime,
    @required String photoUrl,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      // child: GestureDetector(
      // onTap: () {
      //   _editCard(amount, expenseContext, dateTime);
      // },
      // onLongPress: () {
      //   return showDialog(
      //     context: context,
      //     barrierDismissible: true,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: Text("Confirm Deletion"),
      //         content: Text("Are you sure you wish to delete this record?"),
      //         actions: <Widget>[
      //           FlatButton(
      //             child: Text("OK"),
      //             onPressed: () async {
      //               Navigator.of(context).pop();
      //               await colRef.document('$epochTime').delete().then((_) {
      //                 print("Document Deleted Successfully");
      //               });
      //             },
      //           ),
      //           FlatButton(
      //             child: Text("Cancel"),
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //             },
      //           ),
      //         ],
      //       );
      //     },
      //   );
      // },
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(photoUrl),
              ),
              dense: true,
              isThreeLine: true,
              title: Text(
                "$personName",
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      expenseContext,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      textScaleFactor: 0.9,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      "$dateTime",
                      textScaleFactor: 0.9,
                    ),
                  ],
                ),
              ),
              trailing: SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    '₹${amount.floor()}',
                    textScaleFactor: 1.3,
                  ),
                ),
              ),
              onTap: () {
                _editCard(amount, expenseContext, dateTime);
              },
              onLongPress: () {
                return showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirm Deletion"),
                      content: Text(
                        "Are you sure you wish to delete this record?",
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("OK"),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await colRef
                                .document('$epochTime')
                                .delete()
                                .then((_) {
                              print("Document Deleted Successfully");
                            }).catchError((e) {
                              print("Error deleting record: $e");
                            });
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
                  },
                );
              },
            ),
          ],
        ),
      ),
      // ),
    );
  }

  void _editCard(double amount, String expenseContext, String datetime) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return UdhariForm(
            user: widget.user,
            // amountOpt: amount,
            // contextOpt: expenseContext,
            // dateTimeOpt: datetime,
          );
        },
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    // await GoogleSignIn().signOut();
    var _auth = FirebaseAuth.instance;
    _auth.signOut();
    print("Logged out");
  }
}
