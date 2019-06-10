import 'package:udhari_2/Models/ExpensesClass.dart';

class History {
  Expenses history;
  String category;

  History({
    this.category,
    this.history,
  });

  History.fromSnapshot(snapshot) {
    category = snapshot.data['category'];
    history = snapshot.data['history'];
  }

  toJson() {
    return {
      "category": category,
      "history": history,
    };
  }
}

