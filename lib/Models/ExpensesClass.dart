import 'package:flutter/widgets.dart';

class Expenses {
  String dateTime;
  double amount;
  String context;
  String personName;
  String epochTime;
  String displayPicture;

  Expenses(
      {@required this.amount,
      @required this.context,
      @required this.dateTime,
      @required this.personName,
      @required this.epochTime,
      @required this.displayPicture});

  Expenses.fromSnapshot(snapshot) {
    dateTime = snapshot.data['dateTime'];
    amount = snapshot.data['amount'];
    context = snapshot.data['context'];
    personName = snapshot.data['personName'];
    epochTime = snapshot.data['epochTime'];
    displayPicture = snapshot.data['displayPicture'];
  }

  toJson() {
    return {
      "dateTime": dateTime,
      "amount": amount,
      "context": context,
      "personName": personName,
      "epochTime": epochTime,
      "displayPicture": displayPicture,
    };
  }
}
