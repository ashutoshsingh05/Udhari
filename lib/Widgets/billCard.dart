import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Bloc/billSplitBloc.dart';
import 'package:udhari/Bloc/billSplitEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/billClass.dart';
import 'package:udhari/Utils/globals.dart';
import 'package:udhari/Widgets/participantAvatars.dart';

@deprecated
class BillCard extends StatefulWidget {
  final BillClass bill;
  final Key key;
  final void Function() onTap;
  BillCard({
    @required this.bill,
    @required this.key,
    @required this.onTap,
  }) : super(key: key);

  @override
  _BillCardState createState() => _BillCardState();
}

class _BillCardState extends State<BillCard> {
  UserBloc userBloc;
  BillSplitBloc billSplitBloc;

  final TextStyle titleTextStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  final TextStyle dateTextStyle = Globals.smallGreyText;
  final TextStyle peopleTextStyle = Globals.smallGreyText;
  final TextStyle amountTextStyle = const TextStyle(
    fontSize: 18,
  );

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    billSplitBloc = BlocProvider.of<BillSplitBloc>(context);

    return Card(
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () {
          return showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return SimpleDialog(
                  children: <Widget>[
                    SimpleDialogOption(
                      child: Text(
                        "Details",
                        textScaleFactor: Globals.dialogTextScale,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDetailsDialog();
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    // SimpleDialogOption(
                    //   child: Text(
                    //     "Merge",
                    //     textScaleFactor: Globals.dialogTextScale,
                    //   ),
                    //   onPressed: () {
                    //     udhariBloc.udhariEventSink.add(MergeThisUdhariRecord(
                    //       phoneNumberToMerge: widget.udhari.otherPhoneNumber,
                    //     ));
                    //     Navigator.of(context).pop();
                    //   },
                    // ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    SimpleDialogOption(
                      child: Text(
                        "Delete",
                        textScaleFactor: Globals.dialogTextScale,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDeletionDialog();
                      },
                    ),
                  ],
                );
              });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.bill.title,
                style: titleTextStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.bill.dateTime,
                style: dateTextStyle,
              ),
              //TODO: Uncomment
              // LayoutBuilder(
              //   builder: (BuildContext context, BoxConstraints constraints) {
              //     return ParticipantAvatars(
              //       bill: widget.bill,
              //       key: ObjectKey(widget.bill),
              //       maxWidth: constraints.maxWidth,
              //     );
              //   },
              // ),
              Text(
                "₹" + widget.bill.totalAmount.toString(),
                style: amountTextStyle,
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> showDeletionDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you wish to delete this record?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                billSplitBloc.billsEventSink.add(DeleteBillEvent(
                  bill: widget.bill,
                  docID: widget.bill.documentID,
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Widget> showDetailsDialog() {
    // Navigator.push(
    //   context,
    //   PageRouteBuilder(
    //     opaque: false,
    //     pageBuilder: (BuildContext context, animation, secondaryAnimation) {
    //       return ScaleTransition(
    //         scale: Tween<double>(
    //           begin: 0,
    //           end: 1.0,
    //         ).animate(animation),
    //         child: Scaffold(),
    //       );
    //     },
    //   ),
    // );
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Details"),

          // content: Table(
          //   children: <TableRow>[
          //     TableRow(
          //       children: <Widget>[
          //         Text("Udhari Type"),
          //         Text(udhariTypeString),
          //       ],
          //     ),
          //     TableRow(
          //       children: <Widget>[
          //         Text("Phone"),
          //         Text(
          //           phoneNumber,
          //         ),
          //       ],
          //     ),
          //     TableRow(
          //       children: <Widget>[
          //         Text("Amount"),
          //         Text("₹$amountString"),
          //       ],
          //     ),
          //     TableRow(
          //       children: <Widget>[
          //         Text("Added by"),
          //         Text(widget.udhari.firstParty),
          //       ],
          //     ),
          //     TableRow(
          //       children: <Widget>[
          //         Text("Created on"),
          //         Text(
          //           Globals.dateTimeFormat
          //               .format(
          //                 DateTime.fromMillisecondsSinceEpoch(
          //                   int.parse(widget.udhari.createdAt),
          //                 ),
          //               )
          //               .toString(),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          // actions: <Widget>[
          //   FlatButton(
          //     child: Text("OK"),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ],
        );
      },
    );
  }
}
