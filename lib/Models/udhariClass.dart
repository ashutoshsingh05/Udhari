import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:udhari/Bloc/userBloc.dart';

enum Udhari { Borrowed, Lent }

enum PartyType { FirstParty, SecondParty }

/// Modal class for Udhari transactions happening between [firstParty] and [secondParty]
class UdhariClass {
  /// The amount of money in question as a floating point number
  double amount;

  /// 10 digit phone number of the person borrowing the money
  String borrower;

  /// The display name of the [borrower]
  String borrowerName;

  /// 10 digit phone number of the person lending the money
  String lender;

  /// The display name of the [lender]
  String lenderName;

  /// The context(purpose or reason) for the [amount] in question
  String context;

  /// Date and time of this transaction
  String dateTime;

  /// The epoch time as milliseconds when this record was added
  String createdAt;

  /// An array consisting of phone numbers of [firstParty] and [secondParty]
  /// for easier query of data from firestore
  List<String> participants;

  /// The photot url associated with [borrower]
  String borrowerPhotoUrl;

  /// The photot url associated with [lender]
  String lenderPhotoUrl;

  /// The 10 digit phone number of the party creating the record
  String firstParty;

  /// A boolean to check if [firstParty] has deleted the record
  bool firstPartyDeleted;

  /// A boolean to check if the [firstParty] is satisfied with the transaction
  /// i.e has tapped the 'Paid' or 'Received' button.
  bool firstPartySatisfied;

  /// Boolean to keep record if [firstParty] has merged the current
  /// udhari record or not
  bool firstPartyMerged;

  /// The FCM token associated with [firstParty]
  String firstPartyFcmToken;

  /// The 10 digit phone number of the party for whom this record was created.
  /// In other words, the other party involved with this transaction.
  String secondParty;

  /// A boolean to check if [secondParty] has deleted the record
  bool secondPartyDeleted;

  /// A boolean to check if the [secondParty] is satisfied with the transaction
  /// i.e has tapped the 'Paid' or 'Received' button
  bool secondPartySatisfied;

  /// The FCM token associated with [secondParty]
  String secondPartyFcmToken;

  // /// A boolen to check if the curent user is the [firstParty].
  // /// This value is not fetched from firestore
  // bool amIFirstParty;

  /// This is a non unique id with the purpose of
  /// sorting the fetched results with respect to it's value from database.
  /// It is just a representation of [dateTime] as epochtime.
  String id;

  /// Boolean to check if the given udari was created by merging
  /// exisitng udharis with the same participants.
  bool isMerged;

  //---------DATA MEMBERS BELOW ARE NOT PUSHED TO FIREBASE---------//

  /// A string to keep a record of the name([borrowerName] or [lenderName]) to be displayed
  /// in the [UdhariTile]. If [Udhari] is [Udhari.Borrowed], then
  /// name is [lenderName] and vice-versa.
  String name;

  // /// If this record is merge-able with
  // /// some other [udhariClass] record or not
  // bool isMergeable;

  /// enum for deciding the state of udhari,
  /// wheather it is [Borrowed] or [Lent]
  Udhari udhariType;

  /// enum for deciding wheather the state of participant
  /// is [Firstparty] or [SecondParty]
  PartyType partyType;

  /// The document ID in which this udhari record is kept.
  /// Used for editing and updating udhari records.
  String documentID;

  /// Wheather or not this document can be edited by the
  /// current participant. For the record, documents can only
  /// be editied by it's [firstParty]
  bool isEditable;

  /// A string which contains the phone number of the person
  /// other than the current user. This is the phoneNumber which
  /// is associated with each [UdhariTile] (and [name]) and used for merging
  /// udhari records.
  String otherPhoneNumber;

//TODO: give the "not-so-absolutely" required fields a default value
  UdhariClass({
    @required this.amount,
    @required this.borrower,
    @required this.borrowerName,
    @required this.lender,
    @required this.lenderName,
    @required this.context,
    @required this.dateTime,
    @required this.createdAt,
    @required this.participants,
    @required this.borrowerPhotoUrl,
    @required this.lenderPhotoUrl,
    @required this.firstParty,
    @required this.firstPartyDeleted,
    @required this.firstPartySatisfied,
    @required this.firstPartyFcmToken,
    @required this.secondParty,
    @required this.secondPartyDeleted,
    @required this.secondPartySatisfied,
    @required this.secondPartyFcmToken,
    @required this.id,
    @required this.isMerged,
    this.firstPartyMerged = false,
  });

  UdhariClass.fromSnapshot({
    @required DocumentSnapshot snapshot,
    @required UserBloc userBloc,
  }) {
    this.amount = double.parse(snapshot.data["amount"].toString());
    this.borrower = snapshot.data["borrower"];
    this.borrowerName = snapshot.data["borrowerName"];
    this.lender = snapshot.data["lender"];
    this.lenderName = snapshot.data["lenderName"];
    this.context = snapshot.data["context"];
    this.dateTime = snapshot.data["dateTime"];
    this.createdAt = snapshot.data["createdAt"];
    this.participants = List<String>.from(snapshot.data["participants"]);
    this.borrowerPhotoUrl = snapshot.data["borrowerPhotoUrl"];
    this.lenderPhotoUrl = snapshot.data["lenderPhotoUrl"];
    this.firstParty = snapshot.data["firstParty"];
    this.firstPartyDeleted = snapshot.data["firstPartyDeleted"];
    this.firstPartySatisfied = snapshot.data["firstPartySatisfied"];
    this.secondParty = snapshot.data["secondParty"];
    this.secondPartyDeleted = snapshot.data["secondPartyDeleted"];
    this.secondPartySatisfied = snapshot.data["secondPartySatisfied"];
    this.id = snapshot.data["id"];
    this.isMerged = snapshot.data["isMerged"];
    this.firstPartyMerged = snapshot.data["firstPartyMerged"];
    this.firstPartyFcmToken = snapshot.data["firstPartyFcmToken"];
    this.secondPartyFcmToken = snapshot.data["secondPartyFcmToken"];
    this.documentID = snapshot.documentID;

    //TODO: Initializing values which are not a part of Firestore document

    if (this.firstParty == userBloc.phoneNumber) {
      partyType = PartyType.FirstParty;
      isEditable = true;
    } else {
      partyType = PartyType.SecondParty;
      isEditable = false;
    }

    if (this.borrower == userBloc.phoneNumber) {
      this.udhariType = Udhari.Borrowed;
      this.name = lenderName;
      this.otherPhoneNumber = lender;
    } else if (this.lender == userBloc.phoneNumber) {
      this.udhariType = Udhari.Lent;
      this.name = borrowerName;
      this.otherPhoneNumber = borrower;
    } else {
      throw FormatException(
          "Invalid borrower or lender value fetched from udhari document in Firebase");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": this.amount,
      "borrower": this.borrower,
      "borrowerName": this.borrowerName,
      "lender": this.lender,
      "lenderName": this.lenderName,
      "context": this.context,
      "dateTime": this.dateTime,
      "createdAt": this.createdAt,
      "participants": this.participants,
      "borrowerPhotoUrl": this.borrowerPhotoUrl,
      "lenderPhotoUrl": this.lenderPhotoUrl,
      "firstParty": this.firstParty,
      "firstPartyDeleted": this.firstPartyDeleted,
      "firstPartySatisfied": this.firstPartySatisfied,
      "secondParty": this.secondParty,
      "secondPartyDeleted": this.secondPartyDeleted,
      "secondPartySatisfied": this.secondPartySatisfied,
      "id": this.id,
      "isMerged": this.isMerged,
      "firstPartyMerged": this.firstPartyMerged,
      "firstPartyFcmToken": this.firstPartyFcmToken,
      "secondPartyFcmToken": this.secondPartyFcmToken,
    };
  }
}
