import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

class Dashboard extends StatefulWidget {
  Dashboard({@required this.user});

  final FirebaseUser user;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 200,
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Total Debit"),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          "0",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 10, 10, 5),
                  child: Card(
                    child: Center(
                      child: Text("Total Credit:"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 5, 10),
                  child: Card(
                    child: Center(
                      child: Text("Total Expenses:"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 10, 10),
                  child: Card(
                    child: Center(
                      child: Text("Active Trips::"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('Users 2.0')
                    .document('${widget.user.uid}')
                    .collection('Expenses')
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
                    return Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: snapshot.data.documents.map(
                            (DocumentSnapshot document) {
                              return _cardBuilder(
                                  document['amount'],
                                  "${document['context']}",
                                  "${document['dateTime']}");
                            },
                          ).toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardBuilder(double amount, String context, String dateTime) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.tag_faces,
                color: Colors.red,
              ),
              title: Text(
                "$context",
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 1),
                    ),
                    Text("$dateTime"),
                  ],
                ),
              ),
              trailing: SizedBox(
                child: Text(
                  '₹$amount',
                  textScaleFactor: 1.3,
                ),
                width: 65,
              ),
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('Edit'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
