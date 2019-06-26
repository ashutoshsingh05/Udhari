import 'package:flutter/cupertino.dart';
import 'package:udhari_2/Models/ExpensesClass.dart';

class Udhari {
  Expenses udhari;
  bool isBorrowed;
  bool isPaid;

  Udhari({
    @required this.isBorrowed,
    @required this.udhari,
    @required this.isPaid,
  });

  Udhari.fromSnapshot(snapshot) {
    udhari = snapshot.data['udhari'];
    isBorrowed = snapshot.data['isBorrowed'];
  }

  toJson() {
    return {
      "dateTime": udhari.dateTime,
      "amount": udhari.amount,
      "context": udhari.context,
      "personName": udhari.personName,
      "isBorrowed": isBorrowed,
      "isPaid": isPaid,
      "epochTime": udhari.epochTime,
      "displayPicture": udhari.displayPicture,
    };
  }
}
