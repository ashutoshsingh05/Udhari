import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Models/udhariClass.dart';
import 'package:udhari/Utils/globals.dart';
import 'package:udhari/Bloc/udhariBloc.dart';
import 'package:udhari/Bloc/udhariEvents.dart';
import 'package:udhari/Widgets/cardBanner.dart';

enum ButtonType { paid, received }

class UdhariTile extends StatefulWidget {
  final UdhariClass udhari;
  final void Function() onTap;

  /// Key to ensure the widget does not lose state when items are
  /// deleted or added to the collection
  final Key key;

  UdhariTile({
    @required this.udhari,
    @required this.onTap,
    @required this.key,
  }) : super(key: key);

  @override
  _UdhariTileState createState() => _UdhariTileState();
}

class _UdhariTileState extends State<UdhariTile> {
  UdhariBloc udhariBloc;

  String name;
  String udhariContext;
  String amountString;
  String dateTime;
  String photoUrl;
  String phoneNumber;
  String udhariTypeString;

  /// enum for keeping track of the type of button to be drawn on the card
  ButtonType buttonType;

  @override
  void initState() {
    super.initState();
    assignValues();
  }

  void assignValues() {
    this.amountString = widget.udhari.amount.floor().toString();
    this.udhariContext = widget.udhari.context;
    this.dateTime = widget.udhari.dateTime;
    this.name = widget.udhari.name;
    this.phoneNumber = widget.udhari.otherPhoneNumber;

    if (widget.udhari.udhariType == Udhari.Borrowed) {
      this.photoUrl = widget.udhari.lenderPhotoUrl;
      this.buttonType = ButtonType.paid;
      // this.phoneNumber = widget.udhari.lender;
      this.udhariTypeString = "Borrowed";
    } else {
      this.photoUrl = widget.udhari.borrowerPhotoUrl;
      this.buttonType = ButtonType.received;
      // this.phoneNumber = widget.udhari.borrower;
      this.udhariTypeString = "Lent";
    }
  }

  @override
  Widget build(BuildContext context) {
    udhariBloc = BlocProvider.of<UdhariBloc>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
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
                    SimpleDialogOption(
                      child: Text(
                        "Merge",
                        textScaleFactor: Globals.dialogTextScale,
                      ),
                      onPressed: () {
                        udhariBloc.udhariEventSink.add(MergeThisUdhariRecord(
                          phoneNumberToMerge: widget.udhari.otherPhoneNumber,
                        ));
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
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
        child: CardBanner(
          showBanner: widget.udhari.isMerged,
          message: "Merged",
          child: Card(
            elevation: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(this.photoUrl),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        this.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        this.udhariContext,
                        textScaleFactor: 0.9,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        Globals.timeAbsoluteToRelative(
                            dateTimeString: this.dateTime),
                        textScaleFactor: 0.9,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "₹${this.amountString}",
                          textScaleFactor: 1.3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: widget.udhari.udhariType == Udhari.Borrowed
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        SizedBox(
                          height: 1,
                        ),
                        OutlineButton(
                          color: Colors.lightBlue.withOpacity(0.2),
                          child: Text(
                            this.buttonType == ButtonType.paid
                                ? "Paid"
                                : "Received",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          onPressed: () {
                            udhariBloc.udhariEventSink
                                .add(SatisfiedUdhariRecord(
                              udhari: widget.udhari,
                              docID: widget.udhari.documentID,
                            ));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                  udhariBloc.udhariEventSink.add(DeleteUdhariRecord(
                    udhari: widget.udhari,
                    docID: widget.udhari.documentID,
                  ));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<Widget> showDetailsDialog() {
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
                  Text(udhariTypeString),
                ],
              ),
              TableRow(
                children: <Widget>[
                  Text("Phone"),
                  Text(
                    phoneNumber,
                  ),
                ],
              ),
              TableRow(
                children: <Widget>[
                  Text("Amount"),
                  Text("₹$amountString"),
                ],
              ),
              TableRow(
                children: <Widget>[
                  Text("Added by"),
                  Text(widget.udhari.firstParty),
                ],
              ),
              TableRow(
                children: <Widget>[
                  Text("Created on"),
                  Text(
                    Globals.dateTimeFormat
                        .format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(widget.udhari.createdAt),
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
          ],
        );
      },
    );
  }
}
