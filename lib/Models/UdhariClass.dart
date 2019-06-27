import 'package:flutter/cupertino.dart';
import 'package:udhari_2/Models/ExpensesClass.dart';

class Udhari {
  Expenses expense;
  bool isBorrowed;
  bool isPaid;

  Udhari({
    @required this.isBorrowed,
    @required this.expense,
    @required this.isPaid,
  });

  Udhari.fromSnapshot(snapshot) {
    expense = snapshot.data['expense'];
    isBorrowed = snapshot.data['isBorrowed'];
  }

  toJson() {
    return {
      "dateTime": expense.dateTime,
      "amount": expense.amount,
      "context": expense.context,
      "personName": expense.personName,
      "isBorrowed": isBorrowed,
      "isPaid": isPaid,
      "epochTime": expense.epochTime,
      "photoUrl": expense.photoUrl,
    };
  }
}
