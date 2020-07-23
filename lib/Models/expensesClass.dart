import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class ExpenseClass {
  /// The amount of money in question as a floating point number
  double amount;

  /// The context(purpose or reason) for the [amount] in question
  String context;

  /// Date and time of this transaction
  String dateTime;

  /// An array consisting of phone numbers of [firstParty] and [secondParty]
  /// for easier query of data from firestore
  String participant;

  /// The epoch time as milliseconds when this record was added
  String created;

  /// The photo url associated with the user itself
  String photoUrl;

  /// The month in which this expense was added
  int month;

  /// The year in which this expense was added
  int year;

  /// The document ID in which this expense record is kept.
  /// Used for editing and updating expense records.
  String documentID;

  /// This is a non unique id with the purpose of
  /// sorting the fetched results with respect to it's value from database.
  /// It is just a representation of [dateTime] as epochtime.
  String id;

  ExpenseClass({
    @required this.amount,
    @required this.context,
    @required this.dateTime,
    @required this.participant,
    @required this.created,
    @required this.photoUrl,
    @required this.month,
    @required this.year,
    @required this.id,
  }) {
    assert(this.month > 0 && this.month < 13);
    assert(this.year > 2000 && this.year < 2100);
  }

  ExpenseClass.fromSnapshot(DocumentSnapshot snapshot) {
    this.amount = double.parse(snapshot.data['amount'].toString());
    this.context = snapshot.data['context'];
    this.dateTime = snapshot.data['dateTime'];
    this.participant = snapshot.data['participant'];
    this.created = snapshot.data['createdAt'];
    this.photoUrl = snapshot.data['photoUrl'];
    this.month = snapshot.data['month'];
    this.year = snapshot.data['year'];
    this.documentID = snapshot.documentID;
    this.id = snapshot.data["id"];
  }

  toJson() {
    return {
      "amount": this.amount,
      "context": this.context,
      "dateTime": this.dateTime,
      "participant": this.participant,
      "createdAt": this.created,
      "photoUrl": this.photoUrl,
      "month": this.month,
      "year": this.year,
      "id": this.id,
    };
  }
}
