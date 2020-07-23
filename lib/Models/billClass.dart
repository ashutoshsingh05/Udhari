import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:udhari/Bloc/userBloc.dart';

@deprecated
class BillClass {
  double totalAmount;
  String title;
  String dateTime;
  String firstParty;
  String id;
  String createdAt;
  bool isSplit;
  bool isArchived;
  Map<String, Contributor> contributors = Map<String, Contributor>();
  List<String> participants = List<String>();

  //---------DATA MEMBERS BELOW ARE NOT PUSHED TO FIREBASE---------//

  bool isFirstParty;
  bool isEditable;
  String documentID;

  BillClass({
    @required this.totalAmount,
    @required this.title,
    @required this.dateTime,
    @required this.firstParty,
    @required this.id,
    @required this.createdAt,
    @required this.isSplit,
    @required this.isArchived,
    @required this.contributors,
    @required this.participants,
  });

  BillClass.fromSnapshot({
    @required DocumentSnapshot snapshot,
    @required UserBloc userBloc,
  }) {
    // print(snapshot.data);
    this.documentID = snapshot.documentID;
    this.totalAmount = snapshot.data["totalAmount"];
    this.title = snapshot.data["title"];
    this.dateTime = snapshot.data["dateTime"];
    this.firstParty = snapshot.data["firstParty"];
    this.id = snapshot.data["id"];
    this.createdAt = snapshot.data["createdAt"];
    this.isSplit = snapshot.data["isSplit"];
    this.isArchived = snapshot.data["isArchived"];
    this.participants = List<String>.from(snapshot.data["participants"]);
    this.contributors = Map.from(snapshot.data["contributors"]).map(
        (k, v) => MapEntry<String, Contributor>(k, Contributor.fromJson(v)));
    // Map _contributors =
    //     Map<String, dynamic>.from(snapshot.data["contributors"]);

    // _contributors.forEach((key, value) {
    //   // print(Map.from);
    //   return contributors.addEntries([MapEntry(key, Map.from(value))]);
    // });

    // print(this.contributors["7743960763"].photoUrl);

    if (firstParty == userBloc.phoneNumber) {
      this.isFirstParty = true;
      this.isEditable = true;
    } else {
      this.isFirstParty = false;
      this.isEditable = false;
    }
  }

  Map<String, dynamic> toJson() {
    // print("totalAmount : "
    //     "${this.totalAmount}"
    //     "title : "
    //     "${this.title}"
    //     "dateTime : "
    //     "${this.dateTime}"
    //     "firstParty : "
    //     "${this.firstParty}"
    //     "id : "
    //     "${this.id}"
    //     "createdAt : "
    //     "${this.createdAt}"
    //     "isSplit : "
    //     "${this.isSplit}"
    //     "isArchived : "
    //     "${this.isArchived}"
    //     "contributors : "
    //     "${this.contributors}"
    //     "participants : "
    //     "${this.participants}");
    return {
      "totalAmount": this.totalAmount,
      "title": this.title,
      "dateTime": this.dateTime,
      "firstParty": this.firstParty,
      "id": this.id,
      "createdAt": this.createdAt,
      "isSplit": this.isSplit,
      "isArchived": this.isArchived,
      "contributors": this.contributors,
      "participants": this.participants,
    };
  }
}

class Contributor {
  double amountContributed;
  double maxShare;
  String name;
  String phoneNumber;
  String photoUrl;
  bool isDeleted;

  Contributor({
    @required this.amountContributed,
    @required this.name,
    @required this.phoneNumber,
    @required this.photoUrl,
    @required this.isDeleted,
    @required this.maxShare,
  });

  Contributor.fromInstance(Contributor contributor) {
    this.amountContributed = contributor.amountContributed;
    this.name = contributor.name;
    this.phoneNumber = contributor.phoneNumber;
    this.photoUrl = contributor.photoUrl;
    this.isDeleted = contributor.isDeleted;
    this.maxShare = contributor.maxShare;
  }

  Contributor.fromJson(Map json) {
    this.amountContributed = double.parse(json["amountContributed"].toString());
    this.name = json["name"];
    this.phoneNumber = json["phoneNumber"];
    this.photoUrl = json["photoUrl"];
    this.isDeleted = json["isDeleted"];
    this.maxShare = double.parse(json["maxShare"].toString());
  }

  Map<String, dynamic> toJson() {
    return {
      "phoneNumber": this.phoneNumber,
      "name": this.name,
      "amountContributed": this.amountContributed,
      "photoUrl": this.photoUrl,
      "isDeleted": this.isDeleted,
      "maxShare": this.maxShare,
    };
  }
}
