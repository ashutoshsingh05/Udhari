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
      "udhari": udhari,
      "isBorrowed": isBorrowed,
    };
  }
}

