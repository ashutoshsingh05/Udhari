import 'package:udhari_2/Models/ExpensesClass.dart';
import 'package:udhari_2/Models/UdhariClass.dart';
import 'package:udhari_2/Models/TripClass.dart';
import 'package:udhari_2/Models/HistoryClass.dart';


class User {
  String phoneNumber;
  String uid;
  List<Trip> trips;
  List<Udhari> udhari;
  List<Expenses> expenses;
  List<History> history;

  User({
    this.phoneNumber,
    this.uid,
    this.trips,
    this.udhari,
    this.expenses,
    this.history,
  });

  User.fromSnapshot(snapshot) {
    phoneNumber = snapshot.data['phoneNumber'];
    uid = snapshot.data['uid'];
    trips = snapshot.data['trips'];
    udhari = snapshot.data['udhari'];
    expenses = snapshot.data['expenses'];
    history = snapshot.data['history'];
  }

  toJson() {
    return {
      "phoneNumber": phoneNumber,
      "uid": uid,
      "trips": trips,
      "udhari": udhari,
      "expenses": expenses,
      "history": history,
    };
  }
}

