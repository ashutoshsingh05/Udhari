import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';

class UdhariTile extends StatefulWidget {
  UdhariTile({
    @required this.personName,
    @required this.amount,
    @required this.expenseContext,
    @required this.dateTime,
    @required this.epochTime,
    @required this.photoUrl,
    @required this.isBorrowed,
    @required this.phoneNumber,
    @required this.onButtonTapped,
    @required this.onTap,
    @required this.onLongPress,
  });

  final String personName;
  final String expenseContext;
  final String dateTime;
  final String epochTime;
  final String photoUrl;
  final String phoneNumber;
  final double amount;
  final bool isBorrowed;
  final Function() onButtonTapped;
  final Function() onTap;
  final Function onLongPress;
  @override
  _UdhariTileState createState() => _UdhariTileState();
}

class _UdhariTileState extends State<UdhariTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
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
                          CachedNetworkImageProvider(widget.photoUrl),
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
                      widget.personName,
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
                      widget.expenseContext,
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
                      widget.dateTime,
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
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //show borrowed or lent as per parameters
                      // widget.isBorrowed
                      //     ? Text(
                      //         "Borrowed",
                      //         style: TextStyle(
                      //           color: Colors.green,
                      //           fontWeight: FontWeight.w600,
                      //         ),
                      //       )
                      //     : Text(
                      //         "Lent",
                      //         style: TextStyle(
                      //           color: Colors.red,
                      //           fontWeight: FontWeight.w600,
                      //         ),
                      //       ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "₹${widget.amount.floor()}",
                        textScaleFactor: 1.3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: widget.isBorrowed ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      OutlineButton(
                        color: Colors.lightBlue.withOpacity(0.2),
                        child: Text(
                          widget.isBorrowed ? "Paid" : "Received",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: widget.onButtonTapped,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
