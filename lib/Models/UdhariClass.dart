import 'package:udhari_2/Models/ExpensesClass.dart';

class Udhari {
  Expenses udhari;
  bool isBorrowed;

  Udhari({
    this.isBorrowed,
    this.udhari,
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
    };
  }
}
