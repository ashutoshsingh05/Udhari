import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:udhari_2/Screens/Forms/ExpensesForm.dart';

class Dashboard extends StatefulWidget {
  Dashboard({@required this.user});

  final FirebaseUser user;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  CollectionReference colRef;
  double total = 0;

  TextStyle _textStyleHeader = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 18,
  );

  TextStyle _textStyleFooter = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 24,
  );

  @override
  void initState() {
    super.initState();
    colRef = Firestore.instance
        .collection('Users 2.0')
        .document('${widget.user.uid}')
        .collection('Expenses');
    expenseHandler();
    debitHandler();
    creditHandler();
    activeTripHandler();
  }

  @override
  void dispose() {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppBar(
            backgroundColor: Colors.transparent.withOpacity(0),
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.all(7),
              child: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider("${widget.user.photoUrl}"),
              ),
            ),
            title: Text(widget.user.displayName),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    expenseHandler();
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
          Container(
            height: 230,
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 5, 5),
                  child: Card(
                    elevation: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Total Debit", style: _textStyleHeader),
                        SizedBox(
                          height: 3,
                        ),
                        Text("₹0", style: _textStyleFooter),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 10, 5),
                  child: Card(
                    elevation: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Total Credit", style: _textStyleHeader),
                        SizedBox(
                          height: 3,
                        ),
                        Text("₹0", style: _textStyleFooter),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 5, 10),
                  child: Card(
                    elevation: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Expenses (30d)", style: _textStyleHeader),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          "₹$total",
                          style: _textStyleFooter,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 10, 10),
                  child: Card(
                    elevation: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Active Trips", style: _textStyleHeader),
                        SizedBox(
                          height: 3,
                        ),
                        Text("0", style: _textStyleFooter),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder(
                // where query to fetch expenses records only of the past month
                // 2592000000 are the exact number of milliseconds in 30 days
                stream: colRef
                    .orderBy("epochTime", descending: true)
                    .where('epochTime',
                        isGreaterThanOrEqualTo:
                            (DateTime.now().millisecondsSinceEpoch - 2592000000)
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
                    return Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: snapshot.data.documents.map(
                            (DocumentSnapshot document) {
                              return _cardBuilder(
                                document['amount'],
                                "${document['context']}",
                                "${document['dateTime']}",
                                "${document['epochTime']}",
                              );
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

  Widget _cardBuilder(
      double amount, String expenseContext, String dateTime, String epochTime) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
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
                  content: Text("Are you sure you wish to delete this record?"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("OK"),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await colRef.document('$epochTime').delete().then((_) {
                          print("Document Deleted Successfully");
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
              });
        },
        child: Card(
          elevation: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider("${widget.user.photoUrl}"),
                ),
                title: Text(
                  "$expenseContext",
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 3,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void expenseHandler() async {
    total = 0;
    String _time =
        (DateTime.now().millisecondsSinceEpoch - 2592000000).toString();
    QuerySnapshot db = await Firestore.instance
        .collection('Users 2.0')
        .document(widget.user.uid)
        .collection('Expenses')
        .where('epochTime', isGreaterThanOrEqualTo: _time)
        .getDocuments();

    int length = db.documents.length.toInt();
    if (this.mounted)
      setState(() {
        if (length > 0) {
          for (int i = 0; i < length; i++) {
            total += db.documents[i].data['amount'];
          }
          print("total Expense: $total");
        } else {
          print("total Expense: $total");
        }
      });
  }

  debitHandler() {}
  creditHandler() {}
  activeTripHandler() {}

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    print("Logged out");
  }

  void _editCard(double amount, String expenseContext, String datetime) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return ExpensesForm(
            user: widget.user,
            amountOpt: amount,
            contextOpt: expenseContext,
            dateTimeOpt: datetime,
          );
        },
      ),
    );
  }
}
