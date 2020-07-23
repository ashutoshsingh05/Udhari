import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:udhari/Utils/globals.dart';
// import 'package:intl/intl.dart';

class TripClass {
  /// The date time in fancy string format. Represents the
  /// date and time of creation of this trip reocrd.
  String dateTimeCreated;

  /// The date time in fancy string format. Represents the
  /// date and time of last updation of this trip reocrd.
  String dateTimeUpdated;

  /// The date time in fancy string format. Represents the
  /// finish date and time of this trip reocrd.
  String dateTimeFinished;

  /// The milliseconds epoch time representation of [dateTimeUpdated]
  /// The trip records would be sorted according to [id]
  String id;

  /// The title or purpose of this trip expense
  String title;

  /// A boolean to check if the current trip has ended or not.
  /// an ended trip shows bill split info instead of showing the
  /// option to add more expenses.
  bool isActive;

  /// The total expense which has happened on this trip so far
  /// including all the expenses by all the [participants]
  double totalExpense;

  /// List of 10 digit phone numbers of all the participants of the trip
  /// Used for quering while fetching the records from firestore.
  List<String> participants = List<String>();

  /// A map keeping record of the total expenses made by each [participant]
  /// as well as if the participant has deleted the trip record or not.
  /// The name of the map is the phoneNumber of the participant.
  /// The vales are themselves a map with their keys as the parameters
  /// "totalExpense" and "isDeleted" and values in double and bool respectively.
  ///
  /// The complete structure in firestore is somewhat like this
  /// ```
  /// 7743960763 :
  ///         {
  ///              "isDeleted" : false,
  ///              "totalExpense" : 85.69,
  ///         },
  /// 9421847232 :
  ///         {
  ///              "isDeleted" : false,
  ///              "totalExpense" : 12.78,
  ///         },
  /// 7875060184 :
  ///         {
  ///              "isDeleted" : true,
  ///              "totalExpense" : 45.00,
  ///         },
  /// ```
  Map<String, dynamic> participantDetails = Map<String, dynamic>();

  //========================NOT_PUSHED_TO_FIREBASE========================//

  /// The document ID of the firebase document storing the trip record.
  /// Used for editing and deleting the trip record.
  String documentID;

  /// The list of names of people for currrent user associated with
  /// their phoneNumbers in [participants] in the same order. These
  /// are fetched from the user's contacts.
  List<String> names = List<String>();

  /// A string which shows the duration of the trip duration as
  /// a date format like "24 Nov - Now" or 24 - 27 Nov
  String tripDurationString;

  TripClass({
    @required this.totalExpense,
    @required this.dateTimeCreated,
    @required this.dateTimeUpdated,
    @required this.dateTimeFinished,
    @required this.id,
    @required this.title,
    this.isActive = true,
    @required this.participants,
    @required this.participantDetails,
  });

  TripClass.fromSnapshot(DocumentSnapshot snapshot) {
    this.dateTimeCreated = snapshot.data["dateTimeCreated"];
    this.dateTimeUpdated = snapshot.data["dateTimeUpdated"];
    this.dateTimeFinished = snapshot.data["dateTimeFinished"];
    this.id = snapshot.data["id"];
    this.title = snapshot.data["title"];
    this.totalExpense = snapshot.data["totalExpense"];
    this.isActive = snapshot.data["isActive"];
    this.participants =
        List<String>.from(snapshot.data["participants"].map((x) => x));

    for (int i = 0; i < participants.length; i++) {
      participantDetails[participants[i]] =
          snapshot.data["${participants[i]}"].cast<String, dynamic>();
    }

    // assigning values to data members not being pushed to firebase

    this.documentID = snapshot.documentID;
    _getNames();
    this.tripDurationString = _convertToDurationString();
  }

  Map<String, dynamic> toJson() {
    return {
      "totalExpense": this.totalExpense,
      "dateTimeCreated": this.dateTimeCreated,
      "dateTimeUpdated": this.dateTimeUpdated,
      "dateTimeFinished": this.dateTimeFinished,
      "id": this.id,
      "title": this.title,
      "isActive": this.isActive,
      "participants": List<dynamic>.from(this.participants.map((x) => x)),

      /// Loops around all the [participants] phoneNumbers to create subJson structure
      /// i.e a map inside a map to push to firestore
      for (String phone in participants) phone.toString(): _toSubJson(phone),
    };
  }

  /// A private function which return a json map of details of properties
  /// like "isDeleted" and "totalExpense" for the corresponding
  /// phone number. This is used to provide a sub Json
  /// structure(map inside a map) to the trip details document in
  /// firestore as defined in the definiton of [participantDetails]
  Map<String, dynamic> _toSubJson(String phone) {
    return {
      "isDeleted": participantDetails[phone]["isDeleted"],
      "totalExpense": participantDetails[phone]["totalExpense"],
    };
  }

  /// Keeps a record of all the names corresponding to the
  /// list of phoneNumbers of all the participants in [participants].
  Future<void> _getNames() async {
    names = List<String>();
    for (int i = 0; i < participants.length; i++) {
      names.add(await Globals.getOneNameFromPhone(participants[i]));
    }
  }

  /// A function to convert the DateTime received from [dateTimeCreated]
  /// and [dateTimeFinished] and return a string representing the duration
  /// of the trip in a format like "24 Nov - 2 Dec" or  "24 - 27 Nov".
  String _convertToDurationString() {
    // If the finish date is missing(or null) then just show
    // "Ongoing" for the trip duration
    if (dateTimeFinished == null) {
      return "Ongoing";
    }
    DateTime startDateTime = Globals.dateTimeFormat.parse(dateTimeCreated);
    DateTime finishDateTime = Globals.dateTimeFormat.parse(dateTimeFinished);
    String startString = "";
    String finishString = "";
    String durationString = "";

    if (finishDateTime.year - startDateTime.year > 0) {
      // Trip spans in multiple years. (or between the transition of the year
      // like 30 Dec 2019 to 2 Jan 2020)
      startString =
          "${startDateTime.day} ${Globals.mapMonth(startDateTime.month)} ${startDateTime.year}";
      finishString =
          "${finishDateTime.day} ${Globals.mapMonth(finishDateTime.month)} ${finishDateTime.year}";
      durationString = startString + " - " + finishString;
    }
    // Trip spans in multiple months
    else if (finishDateTime.month - startDateTime.month > 0) {
      startString =
          "${startDateTime.day} ${Globals.mapMonth(startDateTime.month)}";
      finishString =
          "${finishDateTime.day} ${Globals.mapMonth(finishDateTime.month)}";
      durationString = startString + " - " + finishString;
    }
    // Trip spans in multiple days but in the same month
    else if (finishDateTime.day - startDateTime.day > 0) {
      startString = "${startDateTime.day}";
      finishString =
          "${finishDateTime.day} ${Globals.mapMonth(finishDateTime.month)}";
      durationString = startString + " - " + finishString;
    }
    // Trip spans in the same day
    else if (finishDateTime.day - startDateTime.day == 0) {
      startString =
          "${startDateTime.day} ${Globals.mapMonth(startDateTime.month)}";
      finishString = "";
      durationString = startString;
    }
    // print("startString: $startString  finishString: $finishString");
    // print("durationString: $durationString");
    return durationString;
  }
}

class TripExpense {
  /// The amount of money expended for [expenseName] in this trip
  double amount;

  /// The date time as a fancy string indicating the
  /// time of creation of this trip expense record.
  String dateTime;

  /// The 10 digit phoneNumber of the person creating this record
  String firstParty;

  /// The milliseconds epoch time representation of [dateTime]
  /// The expense record would be sorted according to [id]
  String id;

  /// The purpose or name of the expense as a plain string.
  String expenseName;

  /// The list of [Contributors] for this expense.
  /// This list contains the phoneNumbers along with the
  /// amount contributed and the amount which was in one's shares.
  List<Contributors> contributors;

  /// List of 10 digit phone numbers of the people involved
  /// in this trip expense. This list is always a subset of the
  /// list of participants of [TripClass]. The [participants]
  /// in this class may be the people among whom the [expenseName]
  /// bill is to be split and the people who have paid for this expense.
  /// It's primary function is for searching and picking out which
  /// expenes are linked with which person.
  List<String> participants;

  //========================NOT_PUSHED_TO_FIREBASE========================//

  /// The document ID of the firebase document storing the trip expense record.
  /// Used for editing and deleting the trip record.
  String documentID;

  /// The list of names of people for currrent user associated with
  /// their phoneNumbers in [participants] in the same order. These
  /// are fetched from the user's contacts.
  List<String> names = List<String>();

  TripExpense({
    @required this.dateTime,
    @required this.amount,
    @required this.firstParty,
    @required this.id,
    @required this.expenseName,
    @required this.participants,
    @required this.contributors,
  });

  TripExpense.fromSnapshot(DocumentSnapshot snapshot) {
    this.amount = snapshot.data["amount"];
    this.dateTime = snapshot.data["dateTime"];
    this.firstParty = snapshot.data["firstParty"];
    this.id = snapshot.data["id"];
    this.expenseName = snapshot.data["expenseName"];
    this.participants = List<String>.from(
      snapshot.data["participants"].map((x) => x),
    );

    List<Contributors> _contributorsList = List<Contributors>();

    // parsing contributors from the firebase data
    for (int i = 0; i < snapshot.data["contributors"].length; i++) {
      _contributorsList.add(Contributors.fromJson(
          Map<String, dynamic>.from(snapshot.data["contributors"][i])));
    }

    this.contributors = _contributorsList;
    this.documentID = snapshot.documentID;
    _getNames();
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "dateTime": dateTime,
      "firstParty": firstParty,
      "id": id,
      "expenseName": expenseName,
      "participants": List<dynamic>.from(participants.map((x) => x)),
      "contributors": List<dynamic>.from(contributors.map((x) => x.toJson())),
    };
  }

  /// Keeps a record of all the names corresponding to the
  /// list of phoneNumbers of all the participants in [participants].
  Future<void> _getNames() async {
    names = List<String>();
    for (int i = 0; i < participants.length; i++) {
      names.add(await Globals.getOneNameFromPhone(participants[i]));
    }
  }
}

class Contributors {
  /// The 10 digit phoneNumber of the participant
  String phoneNumber;

  /// The amount contributed by the participant for this expense
  double amountContributed;

  /// The actual amount this participant was
  /// supposed to pay for this expense
  double shareAmount;

  Contributors({
    @required this.phoneNumber,
    @required this.amountContributed,
    @required this.shareAmount,
  });

  Contributors.fromJson(Map<String, dynamic> json) {
    this.phoneNumber = json["phoneNumber"];
    this.amountContributed = double.parse(json["amountContributed"].toString());
    this.shareAmount = double.parse(json["shareAmount"].toString());
  }

  Map<String, dynamic> toJson() {
    return {
      "phoneNumber": phoneNumber,
      "amountContributed": amountContributed,
      "shareAmount": shareAmount,
    };
  }
}

/// The contact class used to show list of contacts when
/// searching for participants in trip creation. Also keeps
/// record of all the contacts that were selcted and handles
/// toggling of selecting and unselecting contatcs.
// class TripContacts {
//   /// The list of contacts which were selecting while
//   /// creating a new trip.
//   List<ContactCard> _selectedContacts = List<ContactCard>();

//   /// List of all the contacts on the device
//   // List<Contact> _allContacts = List<Contact>();

//   List<ContactCard> get selectedContacts => _selectedContacts;

//   TripContacts() {
//     _selectedContacts = List<ContactCard>();
//     // _allContacts = List<Contact>();
//     // _getContacts();
//   }

//   /// Fetches all contacts from device
//   // void _getContacts() async {
//   //   _allContacts = (await ContactsService.getContacts(
//   //     // query: query,
//   //     withThumbnails: false,
//   //     photoHighResolution: false,
//   //     orderByGivenName: true,
//   //   ))
//   //       .toList();
//   // }

//   /// Function to toggle [_selectedContacts] when they
//   /// are selected or unselected.
//   void toggleContact(ContactCard contact) {
//     if (_selectedContacts.contains(contact)) {
//       _removeContact(contact);
//       print("tripClass.dart removed :${contact.phoneNumber}");
//     } else {
//       _addContact(contact);
//       print("tripClass.dart added :${contact.phoneNumber}");
//     }
//     // print("tripClass.dart tapped :${contact.phoneNumber}");
//   }

//   /// Adds a [ContactCard] to the list of selected contacts [_selectedContacts]
//   void _addContact(ContactCard contact) {
//     _selectedContacts.add(contact);
//   }

//   /// Remove a [ContactCard] from the list of selected contacts [_selectedContacts]
//   void _removeContact(ContactCard contact) {
//     _selectedContacts.remove(contact);
//   }

//   /// Return a list of contacts relating to a specific [query]
//   /// for fetching related contacts. Used for contructing
//   /// the contact list for adding trip participants.
//   Future<List<ContactCard>> getContactsQueryList(String query) async {
//     // Fetch all the contacts from device
//     List<Contact> contactList = (await ContactsService.getContacts(
//       query: query,
//       withThumbnails: false,
//       photoHighResolution: false,
//       orderByGivenName: true,
//     ))
//         .toList();

//     Set<ContactCard> contactCards = Set<ContactCard>();
//     // loops through all the contacts and saved them to a set
//     // to remove duplicates arising from whatsapp and telegram
//     // accounts.
//     for (int i = 0; i < contactList.length; i++) {
//       for (int j = 0; j < contactList[i].phones.length; j++) {
//         contactCards.add(
//           ContactCard(
//             displayName: contactList[i].displayName,
//             phoneNumber: ContactsProvider.stripPhoneNumber(
//                 contactList[i].phones.toList()[j].value.toString()),
//           ),
//         );
//       }
//     }
//     return contactCards.toList();
//   }
// }

/// Keeps track of all the contacts numbers
/// along with their names
class ContactCardData {
  String displayName;
  String phoneNumber;
  bool isRemovable;
  
  ContactCardData({
    @required this.displayName,
    @required this.phoneNumber,
    this.isRemovable = true,
  });

  // void toggleSelected() {
  // isSelected = !isSelected;
  // }

  bool operator ==(Object other) =>
      other is ContactCardData &&
      other.phoneNumber == this.phoneNumber &&
      other.displayName == this.displayName;

  int get hashCode => displayName.hashCode ^ phoneNumber.hashCode;
}
