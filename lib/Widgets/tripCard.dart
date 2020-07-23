import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Bloc/tripBloc.dart';
import 'package:udhari/Bloc/tripEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/tripClass.dart';
import 'package:udhari/Screens/tripDetail.dart';
import 'package:udhari/Utils/globals.dart';
import 'package:udhari/Widgets/participantAvatars.dart';

class TripCard extends StatefulWidget {
  final Key key;
  final TripClass trip;
  final void Function() onTap;

  TripCard({
    @required this.key,
    @required this.trip,
    @required this.onTap,
  });

  @override
  _TripCardState createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  UserBloc userBloc;
  TripBloc tripBloc;

  final TextStyle dateTextStyle = Globals.smallGreyText;
  final TextStyle peopleTextStyle = Globals.smallGreyText;
  final TextStyle amountTextStyle = const TextStyle(
    fontSize: 18,
  );

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    tripBloc = BlocProvider.of<TripBloc>(context);

    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        title: Text(
          widget.trip.title,
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
            Text(
              "Updated " +
                  Globals.timeAbsoluteToRelative(
                      dateTimeString: widget.trip.dateTimeUpdated),
              style: dateTextStyle,
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return ParticipantAvatars(
                  maxAvatars: 5,
                  tripClass: widget.trip,
                  key: ObjectKey(widget.trip),
                  maxWidth: constraints.maxWidth,
                );
              },
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {
            tripBloc.tripEventSink.add(DeleteTrip(
              documentID: widget.trip.documentID,
            ));
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              // fullscreenDialog: true,
              opaque: false,
              pageBuilder:
                  (BuildContext context, animation, secondaryAnimation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: TripDetails(
                    trip: widget.trip,
                    tripBloc: tripBloc,
                    userBloc: userBloc,
                    key: ObjectKey(widget.trip),
                    // userBloc: userBloc,
                    // tripBloc: tripBloc,
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
