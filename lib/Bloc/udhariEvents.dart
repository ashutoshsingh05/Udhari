import 'package:flutter/foundation.dart';
import 'package:udhari/Models/udhariClass.dart';

abstract class UdhariEvent {}

class AddUdhariRecord extends UdhariEvent {
  UdhariClass udhari;
  AddUdhariRecord({@required this.udhari});
}

class UpdateUdhariRecord extends UdhariEvent {
  UdhariClass udhari;
  String docID;
  UpdateUdhariRecord({@required this.udhari, @required this.docID});
}

class DeleteUdhariRecord extends UdhariEvent {
  UdhariClass udhari;
  String docID;
  DeleteUdhariRecord({@required this.udhari, @required this.docID});
}

class SatisfiedUdhariRecord extends UdhariEvent {
  UdhariClass udhari;
  String docID;
  SatisfiedUdhariRecord({@required this.udhari, @required this.docID});
}

class MergeThisUdhariRecord extends UdhariEvent {
  String phoneNumberToMerge;
  MergeThisUdhariRecord({@required this.phoneNumberToMerge});
}

class MergeSatisfyEvent extends UdhariEvent {
  UdhariClass udhari;
  String docID;
  MergeSatisfyEvent({@required this.udhari, @required this.docID});
}

class MergeAllUdhariRecord extends UdhariEvent {}
