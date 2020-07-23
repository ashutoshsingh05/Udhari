import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Models/expensesClass.dart';
import 'package:udhari/Screens/Forms/expensesForm.dart';
import 'package:udhari/Bloc/dashboardBloc.dart';
import 'package:udhari/Bloc/dashboardEvents.dart';
import 'package:udhari/Bloc/udhariBloc.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Utils/globals.dart';
import 'package:udhari/Widgets/expenseTile.dart';
import 'package:udhari/Widgets/transparentAppBar.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  Color bgSecondaryColor = Colors.blue;

  UserBloc userBloc;
  DashboardBloc dashboardBloc;
  UdhariBloc udhariBloc;

  AnimationController _controllerBorrowed;
  AnimationController _controllerLent;
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
    _controllerBorrowed = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controllerLent = AnimationController(
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
      _controllerBorrowed.forward();
    });
    Timer(Duration(milliseconds: 200), () {
      _controllerLent.forward();
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
    _controllerBorrowed.dispose();
    _controllerLent.dispose();
    _controllerExp.dispose();
    _controllerTrip.dispose();
    _controllerList.dispose();
    super.dispose();
  }

  void initColors(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      bgSecondaryColor = Colors.blueAccent;
    } else {
      bgSecondaryColor = Color(0xff35374C);
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    udhariBloc = BlocProvider.of<UdhariBloc>(context);
    initColors(context);

    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            bgSecondaryColor,
            Colors.black,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TransparentAppBar(),
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
                      parent: _controllerBorrowed,
                    ),
                    child: Card(
                      elevation: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Total Borrowed", style: _textStyleHeader),
                          SizedBox(
                            height: 3,
                          ),
                          StreamBuilder<double>(
                            initialData: udhariBloc.getTotalDebit,
                            stream: udhariBloc.totalDebitStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<double> snapshot) {
                              // print(
                              //     "============INSIDE DEBIT STREAM BLDR============");
                              // print("Conn State: ${snapshot.connectionState}");
                              // print("Has Data: ${snapshot.hasData}");
                              // print("Data: ${snapshot.data}");
                              // print("Has Error: ${snapshot.hasError}");
                              // print("Error: ${snapshot.error}\n\n");
                              return Text("₹${snapshot.data.floor()}",
                                  style: _textStyleFooter);
                            },
                          ),
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
                      parent: _controllerLent,
                    ),
                    child: Card(
                      elevation: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Total Lent", style: _textStyleHeader),
                          SizedBox(
                            height: 3,
                          ),
                          StreamBuilder<double>(
                            initialData: udhariBloc.getTotalCredit,
                            stream: udhariBloc.totalCreditStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<double> snapshot) {
                              return Text("₹${snapshot.data.floor()}",
                                  style: _textStyleFooter);
                            },
                          ),
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
                          Text(
                              "Expenses (${Globals.mapMonth(DateTime.now().month)})",
                              style: _textStyleHeader),
                          SizedBox(
                            height: 3,
                          ),
                          StreamBuilder<double>(
                            initialData: dashboardBloc.monthlyExpense,
                            stream: dashboardBloc.monthlyExpenseStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<double> snapshot) {
                              return Text(
                                "₹${snapshot.data.floor()}",
                                style: _textStyleFooter,
                              );
                            },
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
              child: StreamBuilder<List<ExpenseClass>>(
                initialData: dashboardBloc.getExpenseList,
                stream: dashboardBloc.expenseListStream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<ExpenseClass>> snapshot) {
                  return Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: snapshot.data.map(
                          (ExpenseClass expense) {
                            return ScaleTransition(
                              scale: CurvedAnimation(
                                curve: Curves.elasticOut,
                                parent: _controllerList,
                              ),
                              child: ExpenseTile(
                                expense: expense,
                                key: ObjectKey(expense),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @deprecated
  Widget _cardBuilder(ExpenseClass expense) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage("${userBloc.photoUrl}"),
              ),
              title: Text(
                "${expense.context}",
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
                      "${expense.dateTime}",
                      textScaleFactor: 0.9,
                    ),
                  ],
                ),
              ),
              trailing: SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    '₹${expense.amount.floor()}',
                    textScaleFactor: 1.3,
                  ),
                ),
              ),
              onTap: () {
                _editCard(expense);
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
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text("OK"),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            dashboardBloc.dashboardEventSink.add(
                                DeleteExpenseRecord(docID: expense.documentID));
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
    );
  }

  //TODO: implement trips
  activeTripHandler() {}

  @deprecated
  void _editCard(ExpenseClass expense) {
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
            child: ExpensesForm(expenseToEdit: expense),
          );
        },
      ),
    );
  }

  @deprecated
  String _monthCode() {
    switch (DateTime.now().month) {
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
        return "";
    }
  }
}
