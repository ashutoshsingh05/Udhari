import 'package:flutter/cupertino.dart';
import 'package:udhari_2/Models/ExpensesClass.dart';

class Udhari {
  Expenses expense;
  bool isBorrowed;
  bool isPaid;
  bool isSelfAdded;

  Udhari({
    @required this.isBorrowed,
    @required this.expense,
    @required this.isPaid,
    @required this.isSelfAdded,
  });

  Udhari.fromSnapshot(snapshot) {
    expense = snapshot.data['expense'];
    isBorrowed = snapshot.data['isBorrowed'];
    isSelfAdded = snapshot.data['isSelfAdded'];
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
      "isSelfAdded": isSelfAdded,
    };
  }
}
