import 'package:flutter/foundation.dart';
import 'package:udhari/Models/tripClass.dart';

abstract class TripEvent {}

class CreateNewTrip extends TripEvent {
  TripClass trip;
  CreateNewTrip({@required this.trip});
}

class UpdateTripDetails extends TripEvent {}

class DeleteTrip extends TripEvent {
  String documentID;
  DeleteTrip({@required this.documentID});
}

class DeleteTripAll extends TripEvent {
  String documentID;
  DeleteTripAll({@required this.documentID});
}

// class FinishTrip extends TripEvent {}

class AddTripExpense extends TripEvent {}

class UpdateTripExpense extends TripEvent {}

class DeleteTripExpense extends TripEvent {}

class FetchTripExpense extends TripEvent {
  String documentID;
  FetchTripExpense({
    @required this.documentID,
  });
}

class SplitExpense extends TripEvent {}

class QueryContactList extends TripEvent {
  String query = "";
  QueryContactList({this.query});
}

class SelectedContactList extends TripEvent {}

class ToggleContactSelection extends TripEvent {
  ContactCardData contactCardHandler;
  ToggleContactSelection({@required this.contactCardHandler});
}
