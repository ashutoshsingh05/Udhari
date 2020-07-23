import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Models/expensesClass.dart';
import 'package:udhari/Screens/Forms/expensesForm.dart';
import 'package:udhari/Bloc/dashboardBloc.dart';
import 'package:udhari/Bloc/dashboardEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';

class ExpenseTile extends StatefulWidget {
  final ExpenseClass expense;
  final Key key;
  ExpenseTile({
    @required this.expense,
    @required this.key,
  }) : super(key: key);
  @override
  _ExpenseTileState createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile> {
  UserBloc userBloc;
  DashboardBloc dashboardBloc;
  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    dashboardBloc = BlocProvider.of<DashboardBloc>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(userBloc.photoUrl),
              ),
              title: Text(
                "${widget.expense.context}",
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
                    // Text(
                    //   Globals.timeAbsoluteToRelative(
                    //       dateTimeString: "${widget.expense.dateTime}"),
                    //   textScaleFactor: 0.9,
                    // ),
                    Text(
                      "${widget.expense.dateTime}",
                      textScaleFactor: 0.9,
                    ),
                  ],
                ),
              ),
              trailing: SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    '₹${widget.expense.amount.floor()}',
                    textScaleFactor: 1.3,
                  ),
                ),
              ),
              onTap: _editCard,
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
                                DeleteExpenseRecord(
                                    docID: widget.expense.documentID));
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

  void _editCard() {
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
            child: ExpensesForm(expenseToEdit: widget.expense),
          );
        },
      ),
    );
  }
}
