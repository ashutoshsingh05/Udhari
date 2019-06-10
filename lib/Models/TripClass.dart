import 'package:udhari_2/Models/ExpensesClass.dart';

class Trip {
  List<Expenses> trips;
  String tripCode;
  String tripName;
  bool isActive;

  Trip({
    this.isActive,
    this.tripCode,
    this.tripName,
    this.trips,
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

