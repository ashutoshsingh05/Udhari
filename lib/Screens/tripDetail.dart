import 'package:flutter/material.dart';
import 'package:udhari/Bloc/tripBloc.dart';
import 'package:udhari/Bloc/tripEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/tripClass.dart';
import 'package:udhari/Screens/Forms/tripExpenseForm.dart';
import 'package:udhari/Utils/globals.dart';
import 'package:udhari/Widgets/contributionLiquid.dart';
import 'package:udhari/Widgets/participantAvatars.dart';
import 'package:udhari/Widgets/tripExpenseCard.dart';

class TripDetails extends StatefulWidget {
  final TripClass trip;
  final Key key;
  final TripBloc tripBloc;
  final UserBloc userBloc;

  // final TripExpense tripExpenses;

  TripDetails({
    @required this.trip,
    @required this.key,
    @required this.userBloc,
    @required this.tripBloc,
    // @required this.tripExpenses,
  });

  @override
  _TripDetailsState createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails>
    with SingleTickerProviderStateMixin {
  AnimationController _controllerList;

  // UserBloc userBloc;
  // TripBloc tripBloc;

  @override
  void initState() {
    super.initState();
    widget.tripBloc.tripEventSink
        .add(FetchTripExpense(documentID: widget.trip.documentID));

    _controllerList = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controllerList.forward();
  }

  @override
  void dispose() {
    _controllerList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("tripdetail.dart money exp " +
    //     widget.trip.participantDetails[widget.userBloc.phoneNumber]);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.trip.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
                // to make the column stretch to
                // the whole width of the screen
                width: double.maxFinite,
              ),
              Card(
                child: Container(
                  margin: EdgeInsets.all(8),
                  height: MediaQuery.of(context).size.height / 4.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            "Contribution\nStats",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ParticipantAvatars(
                                maxAvatars: 5,
                                tripClass: widget.trip,
                                key: ObjectKey(widget.trip),
                                // maxWidth: constraints.maxWidth,
                              ),
                              SizedBox(height: 5),
                              Text(
                                widget.trip.tripDurationString,
                                style: Globals.mediumGreyText,
                              ),
                              SizedBox(height: 4),
                              SizedBox(
                                width: 130,
                                child: Text(
                                  "Updated " +
                                      Globals.timeAbsoluteToRelative(
                                        dateTimeString:
                                            widget.trip.dateTimeUpdated,
                                      ),
                                  style: Globals.mediumGreyText,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ContributionLiquid(
                        //TODO: get percent of contribution
                        percent: 0.1,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: StreamBuilder<List<TripExpense>>(
                    // initialData: widget.tripBloc.getTripExpenseList,
                    stream: widget.tripBloc.tripExpenseListStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<TripExpense>> snapshot) {
                      if (snapshot.hasData) {
                        return SingleChildScrollView(
                          child: Column(
                            children: snapshot.data.map(
                              (TripExpense expense) {
                                return ScaleTransition(
                                  scale: CurvedAnimation(
                                    curve: Curves.elasticOut,
                                    parent: _controllerList,
                                  ),
                                  child: TripExpenseCard(
                                    expense: expense,
                                    // key: ObjectKey(expense),
                                    // expense: expense,
                                    // udhari: udhari,
                                    // onTap: () {
                                    //   if (udhari.isEditable) {
                                    //     _editCard(udhari: udhari);
                                    //   } else {
                                    //     // Only first party is
                                    //     // allowed to edit records
                                    //     print("Editing not allowed");
                                    //     Fluttertoast.showToast(
                                    //       msg: "Cannot edit",
                                    //       backgroundColor: Colors.grey,
                                    //       gravity: ToastGravity.BOTTOM,
                                    //     );
                                    //   }
                                    // },
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator(),
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
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Trip Expense",
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder:
                  (BuildContext context, animation, secondaryAnimation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: TripExpenseForm(
                    trip: widget.trip,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
