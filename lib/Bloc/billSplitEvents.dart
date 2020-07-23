import 'package:flutter/foundation.dart';
import 'package:udhari/Models/billClass.dart';

@deprecated
abstract class BillSplitEvent {}

class CreateNewBill extends BillSplitEvent {
  BillClass bill;
  CreateNewBill({@required this.bill});
}

class UpdateBillEvent extends BillSplitEvent {
  BillClass bill;
  String docID;
  UpdateBillEvent({
    @required this.bill,
    @required this.docID,
  });
}

class BillSplitEqually extends BillSplitEvent {}

class BillSplitUnequally extends BillSplitEvent {}

class DeleteBillEvent extends BillSplitEvent {
  BillClass bill;
  String docID;
  DeleteBillEvent({
    @required this.bill,
    @required this.docID,
  });
}

class AddToUdhariEvent extends BillSplitEvent {}

class ToggleArchiveEvent extends BillSplitEvent {}
