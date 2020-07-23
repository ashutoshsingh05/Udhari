import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Bloc/billSplitEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/billClass.dart';
import 'package:udhari/Utils/globals.dart';

@deprecated
class BillSplitBloc extends Bloc {
  UserBloc userBloc;
  List<BillClass> _billsList = List<BillClass>();
  // String _peopleList;

  set setUserBloc(UserBloc bloc) {
    this.userBloc = bloc;
    print(
        "I got my user!!, said billSplitBloc for: ${this.userBloc.phoneNumber}");
    Globals.phoneNumber = bloc.phoneNumber;
    _fetchBills();
  }

  List<BillClass> get getBillsList => _billsList;
  // String get peopleListString => this._peopleList;

  BillSplitBloc() {
    _billsEventStream.listen(_mapEventToState);
  }

  StreamController<List<BillClass>> _billsListController =
      StreamController<List<BillClass>>.broadcast();
  Stream<List<BillClass>> get billsListStream => _billsListController.stream;
  StreamSink<List<BillClass>> get _billsListSink => _billsListController.sink;

  // StreamController<Widget> _billsStateController = StreamController<Widget>();
  // Stream<Widget> get billsStateStream => _billsStateController.stream;
  // StreamSink<Widget> get _billsStateSink => _billsStateController.sink;

  StreamController<BillSplitEvent> _billsEventController =
      StreamController<BillSplitEvent>();
  Stream<BillSplitEvent> get _billsEventStream => _billsEventController.stream;
  StreamSink<BillSplitEvent> get billsEventSink => _billsEventController.sink;

  void _mapEventToState(BillSplitEvent event) async {
    if (event is CreateNewBill) {
      await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("bills")
          .add(event.bill.toJson())
          .then((onValue) {
        print("Bill created : ${event.bill.title}");
      });
    } else if (event is UpdateBillEvent) {
      await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("bills")
          .document(event.docID)
          .updateData(event.bill.toJson())
          .then((onValue) {
        print("Bill Updated : ${event.bill.title}");
      });
    } else if (event is DeleteBillEvent) {
      await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("bills")
          .document(event.docID)
          .updateData(event.bill.toJson())
          .then((onValue) {
        print("Bill Deleted : ${event.bill.title}");
      });
    } else if (event is BillSplitEqually) {
    } else if (event is BillSplitUnequally) {
    } else if (event is ToggleArchiveEvent) {}
  }

  void _fetchBills() {
    Firestore.instance
        // .collection("Users 3.0")
        // .document("data")
        .collection("bills")
        .where("participants", arrayContains: userBloc.phoneNumber)
        // .orderBy("id", descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      _billsList = List<BillClass>();

      for (int i = 0; i < snapshot.documents.length; i++) {
        _billsList.add(BillClass.fromSnapshot(
          snapshot: snapshot.documents[i],
          userBloc: userBloc,
        ));

        // _billsList.retainWhere((BillClass bill){
        //   return bill.contributors.
        // });
        // print(_billsList[i].toJson());
      }
      // //================================================================//
      // // extra for loops to simulate billS
      // for (int i = 0; i < snapshot.documents.length; i++) {
      //   _billsList.add(BillClass.fromSnapshot(
      //     snapshot: snapshot.documents[i],
      //     userBloc: userBloc,
      //   ));

      //   // _billsList.retainWhere((BillClass bill){
      //   //   return bill.contributors.
      //   // });
      //   // print(_billsList[i].toJson());
      // }

      // for (int i = 0; i < snapshot.documents.length; i++) {
      //   _billsList.add(BillClass.fromSnapshot(
      //     snapshot: snapshot.documents[i],
      //     userBloc: userBloc,
      //   ));

      //   // _billsList.retainWhere((BillClass bill){
      //   //   return bill.contributors.
      //   // });
      //   // print(_billsList[i].toJson());
      // }
      // for (int i = 0; i < snapshot.documents.length; i++) {
      //   _billsList.add(BillClass.fromSnapshot(
      //     snapshot: snapshot.documents[i],
      //     userBloc: userBloc,
      //   ));

      //   // _billsList.retainWhere((BillClass bill){
      //   //   return bill.contributors.
      //   // });
      //   // print(_billsList[i].toJson());
      // }
      // for (int i = 0; i < snapshot.documents.length; i++) {
      //   _billsList.add(BillClass.fromSnapshot(
      //     snapshot: snapshot.documents[i],
      //     userBloc: userBloc,
      //   ));

      //   // _billsList.retainWhere((BillClass bill){
      //   //   return bill.contributors.
      //   // });
      //   // print(_billsList[i].toJson());
      // }
      // for (int i = 0; i < snapshot.documents.length; i++) {
      //   _billsList.add(BillClass.fromSnapshot(
      //     snapshot: snapshot.documents[i],
      //     userBloc: userBloc,
      //   ));

      //   // _billsList.retainWhere((BillClass bill){
      //   //   return bill.contributors.
      //   // });
      //   // print(_billsList[i].toJson());
      // }
      // for (int i = 0; i < snapshot.documents.length; i++) {
      //   _billsList.add(BillClass.fromSnapshot(
      //     snapshot: snapshot.documents[i],
      //     userBloc: userBloc,
      //   ));

      //   // _billsList.retainWhere((BillClass bill){
      //   //   return bill.contributors.
      //   // });
      //   // print(_billsList[i].toJson());
      // }
      // //================================================================//

      //SORT
      // _billsList.sort((a, b) {
      //   return b.id.compareTo(a.id);
      // });

      _billsListSink.add(_billsList);
    });
  }

  @override
  void dispose() {
    // _billsStateController.close();
    _billsEventController.close();
    _billsListController.close();
  }
}
