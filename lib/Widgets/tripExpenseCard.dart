import 'package:flutter/material.dart';
import 'package:udhari/Models/tripClass.dart';
import 'package:udhari/Utils/globals.dart';
import 'package:udhari/Widgets/participantAvatars.dart';

class TripExpenseCard extends StatelessWidget {
  final TripExpense expense;

  TripExpenseCard({@required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        title: Text(
          expense.expenseName,
          style: Globals.titleTextStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        dense: true,
        isThreeLine: true,
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ParticipantAvatars(
              key: ObjectKey(expense),
              tripExpense: expense,
            ),
            SizedBox(height: 5),
            Text(Globals.timeAbsoluteToRelative(
              dateTimeString: expense.dateTime,
            )),
          ],
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
        // onTap: () {
        //   Navigator.push(
        //     context,
        //     PageRouteBuilder(
        //       fullscreenDialog: true,
        //       opaque: false,
        //       pageBuilder:
        //           (BuildContext context, animation, secondaryAnimation) {
        //         return SlideTransition(
        //           position: Tween<Offset>(
        //             begin: Offset(1.0, 0),
        //             end: Offset.zero,
        //           ).animate(animation),
        //           child: TripDetails(
        //             trip: widget.trip,
        //             tripBloc: tripBloc,
        //             userBloc: userBloc,
        //             key: ObjectKey(widget.trip),
        //             // userBloc: userBloc,
        //             // tripBloc: tripBloc,
        //           ),
        //         );
        //       },
        //     ),
        //   );
        // },
      ),
    );
    // return Card(
    //   child: ListTile(
    //     title: Text(expense.expenseName),
    //     isThreeLine: true,
    //     subtitle: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       children: <Widget>[
    //         ParticipantAvatars(
    //           key: ObjectKey(expense),
    //           tripExpense: expense,
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
