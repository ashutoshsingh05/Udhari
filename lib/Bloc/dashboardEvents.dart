import 'package:flutter/foundation.dart';
import 'package:udhari/Models/expensesClass.dart';

abstract class ExpenseEvent {}

class AddExpenseRecord extends ExpenseEvent {
  ExpenseClass expense;
  AddExpenseRecord({@required this.expense});
  // ExpenseClass get getExpense => expense;
}

class UpdateExpenseRecord extends ExpenseEvent {
  ExpenseClass expense;
  String docID;
  UpdateExpenseRecord({
    @required this.expense,
    @required this.docID,
  });
  // ExpenseClass get getExpense => expense;
}

class DeleteExpenseRecord extends ExpenseEvent {
  String docID;
  DeleteExpenseRecord({@required this.docID});
  // String get getDocID => docID;
}

// class GetExpenseRecords extends ExpenseEvent {}
