import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Models/expensesClass.dart';
import 'package:udhari/Bloc/dashboardEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';

class DashboardBloc extends Bloc {
  double _totalMonthlyeExpenses = 0;
  UserBloc userBloc;
  List<ExpenseClass> _expensesList = List<ExpenseClass>();

  double get monthlyExpense => _totalMonthlyeExpenses;
  List<ExpenseClass> get getExpenseList => _expensesList;

  set setUserBloc(UserBloc userBloc) {
    this.userBloc = userBloc;
    print(
        "I got my user!!, said dashboardBloc for: ${this.userBloc.phoneNumber}");
    _fetchExpenses();
  }

  DashboardBloc() {
    _dashboardEventStream.listen(_mapEventToState);
  }

  /// Stream controller for mapping incoming events to respective database calls
  StreamController<ExpenseEvent> _dashboardEventController =
      StreamController<ExpenseEvent>();
  Stream<ExpenseEvent> get _dashboardEventStream =>
      _dashboardEventController.stream;
  StreamSink<ExpenseEvent> get dashboardEventSink =>
      _dashboardEventController.sink;

  /// Stream controller for displaying total expenses in the last month on dashboard
  StreamController<double> _monthlyExpenseController =
      StreamController<double>.broadcast();
  Stream<double> get monthlyExpenseStream => _monthlyExpenseController.stream;
  StreamSink<double> get _monthlyExpenseSink => _monthlyExpenseController.sink;

  /// Stream controller for controlling the expense list displayed on the home page
  StreamController<List<ExpenseClass>> _expenseListController =
      StreamController<List<ExpenseClass>>.broadcast();
  Stream<List<ExpenseClass>> get expenseListStream =>
      _expenseListController.stream;
  StreamSink<List<ExpenseClass>> get _expenseListSink =>
      _expenseListController.sink;

  void _mapEventToState(ExpenseEvent event) async {
    if (event is AddExpenseRecord) {
      await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("expenses")
          .add(event.expense.toJson())
          .then((onValue) {
        print("Added new Expense \"${event.expense.context}\"");
      });
    } else if (event is UpdateExpenseRecord) {
      await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("expenses")
          .document(event.docID)
          .updateData(event.expense.toJson())
          .then((onValue) {
        print(
          "Updated expense for ${event.expense.participant}"
          " dated ${event.expense.dateTime}",
        );
      }).catchError((onError) {
        print("Error Caught updating expense: $onError");
      });
    } else if (event is DeleteExpenseRecord) {
      await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("expenses")
          .document(event.docID)
          .delete()
          .then((onValue) {
        print("Deleted document ${event.docID}");
      });
    }
  }

  void _fetchExpenses() {
    Firestore.instance
        // .collection("Users 3.0")
        // .document("data")
        .collection("expenses")
        .where("participant", isEqualTo: userBloc.phoneNumber)
        .where("month", isEqualTo: DateTime.now().month)
        .where("year", isEqualTo: DateTime.now().year)
        //TODO: values not updating automatically when ordering field by id
        // .orderBy("id", descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      _expensesList = List<ExpenseClass>();
      _totalMonthlyeExpenses = 0;

      for (int i = 0; i < snapshot.documents.length; i++) {
        _expensesList.add(ExpenseClass.fromSnapshot(snapshot.documents[i]));
        _totalMonthlyeExpenses += snapshot.documents[i].data["amount"];
      }
      // Sorting on device because values are not updating
      // automatically when using orderBy on firestore
      _expensesList.sort((a, b) => b.id.compareTo(a.id));
      _expenseListSink.add(_expensesList);
      _monthlyExpenseSink.add(_totalMonthlyeExpenses);
    });
  }

  @override
  void dispose() {
    _dashboardEventController.close();
    _monthlyExpenseController.close();
    _expenseListController.close();
  }
}
