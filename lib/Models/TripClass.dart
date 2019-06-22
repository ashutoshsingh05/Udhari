import 'package:flutter/material.dart';
import 'package:udhari_2/Models/ExpensesClass.dart';

class Trip {
  List<Expenses> trips;
  String tripCode;
  String tripName;
  bool isActive;

  Trip({
    @required this.isActive,
    @required this.tripCode,
    @required this.tripName,
    @required this.trips,
  });

  Trip.fromSnapshot(snapshot) {
    trips = snapshot.data['trips'];
    tripCode = snapshot.data['tripCode'];
    tripName = snapshot.data['tripName'];
    isActive = snapshot.data['isActive'];
  }

  toJson() {
    return {
      "trips": trips,
      "tripCode": tripCode,
      "tripName": tripName,
      "isActive": isActive,
    };
  }
}

