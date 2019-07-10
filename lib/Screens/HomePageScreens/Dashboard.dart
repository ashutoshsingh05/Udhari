import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:udhari_2/Screens/Forms/ExpensesForm.dart';

class Dashboard extends StatefulWidget {
  Dashboard({@required this.user});

  final FirebaseUser user;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  CollectionReference colRef;
  double total = 0;
  AnimationController _controllerDebit;
  AnimationController _controllerCredit;
  AnimationController _controllerExp;
  AnimationController _controllerTrip;
  AnimationController _controllerList;

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
        .document('${widget.user.phoneNumber.substring(widget.user.phoneNumber.length - 10)}')
        .collection('Expenses');
    expenseHandler();
    debitHandler();
    creditHandler();
    activeTripHandler();
    _controllerDebit = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controllerCredit = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controllerTrip = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controllerExp = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controllerList = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    scheduleTimeBombs();
  }

  void scheduleTimeBombs() {
    Timer(Duration(milliseconds: 0), () {
      _controllerDebit.forward();
    });
    Timer(Duration(milliseconds: 200), () {
      _controllerCredit.forward();
    });
    Timer(Duration(milliseconds: 400), () {
      _controllerExp.forward();
    });
    Timer(Duration(milliseconds: 600), () {
      _controllerTrip.forward();
    });
    Timer(Duration(milliseconds: 800), () {
      _controllerList.forward();
    });
  }

  @override
  void dispose() {
    _controllerDebit.dispose();
    _controllerCredit.dispose();
    _controllerExp.dispose();
    _controllerTrip.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                icon: Icon(Icons.refresh),
                tooltip: 'Recalculate',
                onPressed: () {
                  // setState(() {
                  expenseHandler();
                  // });
                },
              ),
              IconButton(
                tooltip: 'Options',
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
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      curve: Curves.elasticOut,
                      parent: _controllerDebit,
                    ),
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
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 10, 5),
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      curve: Curves.elasticOut,
                      parent: _controllerCredit,
                    ),
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
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 5, 10),
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      curve: Curves.elasticOut,
                      parent: _controllerExp,
                    ),
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
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 10, 10),
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      curve: Curves.elasticOut,
                      parent: _controllerTrip,
                    ),
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
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder(
                // "where" query to fetch expenses records only of the past month
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
                              return ScaleTransition(
                                scale: CurvedAnimation(
                                  curve: Curves.elasticOut,
                                  parent: _controllerList,
                                ),
                                child: _cardBuilder(
                                  amount: document['amount'],
                                  dateTime: document['dateTime'],
                                  epochTime: document['epochTime'],
                                  expenseContext: document['context'],
                                ),
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

  Widget _cardBuilder({
    @required double amount,
    @required String expenseContext,
    @required String dateTime,
    @required String epochTime,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
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
              onTap: () {
                // _editCard(amount, expenseContext, dateTime);
                _editCard(
                  amount: amount,
                  datetime: dateTime,
                  epochTime: epochTime,
                  expenseContext: expenseContext,
                );
              },
              onLongPress: () {
                return showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirm Deletion"),
                      content:
                          Text("Are you sure you wish to delete this record?"),
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

  void expenseHandler() async {
    total = 0;
    String _time =
        (DateTime.now().millisecondsSinceEpoch - 2592000000).toString();
    QuerySnapshot db = await Firestore.instance
        .collection('Users 2.0')
        .document("${widget.user.phoneNumber.substring(widget.user.phoneNumber.length - 10)}")
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
    print("Logged out");
  }

  void _editCard({
    @required double amount,
    @required String expenseContext,
    @required String datetime,
    @required String epochTime,
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
            child: ExpensesForm(
              user: widget.user,
              amountOpt: amount,
              contextOpt: expenseContext,
              dateTimeOpt: datetime,
              epochTime: epochTime,
            ),
          );
        },
      ),
    );
  }
}
