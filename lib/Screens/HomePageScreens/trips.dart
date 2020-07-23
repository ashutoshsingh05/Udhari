import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Bloc/tripBloc.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/tripClass.dart';
import 'package:udhari/Widgets/transparentAppBar.dart';
import 'package:udhari/Widgets/tripCard.dart';

class Trips extends StatefulWidget {
  @override
  _TripsState createState() => _TripsState();
}

class _TripsState extends State<Trips> with SingleTickerProviderStateMixin {
  AnimationController _controllerList;

  UserBloc userBloc;
  TripBloc tripBloc;

  @override
  void initState() {
    super.initState();
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
    userBloc = BlocProvider.of<UserBloc>(context);
    tripBloc = BlocProvider.of<TripBloc>(context);

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
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TransparentAppBar(),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder<List<TripClass>>(
                  initialData: tripBloc.getTripList,
                  stream: tripBloc.tripListStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<TripClass>> snapshot) {
                    return SingleChildScrollView(
                      child: Column(
                        children: snapshot.data.map(
                          (TripClass trip) {
                            return ScaleTransition(
                              scale: CurvedAnimation(
                                curve: Curves.elasticOut,
                                parent: _controllerList,
                              ),
                              child: TripCard(
                                key: ObjectKey(trip),
                                trip: trip,
                                onTap: () {
                                  // if (udhari.isEditable) {
                                  //   _editCard(udhari: udhari);
                                  // } else {
                                  //   // Only first party is
                                  //   // allowed to edit records
                                  //   print("Editing not allowed");
                                  //   Fluttertoast.showToast(
                                  //     msg: "Cannot edit",
                                  //     backgroundColor: Colors.grey,
                                  //     gravity: ToastGravity.BOTTOM,
                                  //   );
                                  // }
                                },
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
