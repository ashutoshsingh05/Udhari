import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Bloc/tripEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/contactsProvider.dart';
import 'package:udhari/Models/tripClass.dart';

class TripBloc extends Bloc {
  UserBloc userBloc;
  List<TripClass> _tripList = List<TripClass>();
  List<TripExpense> _tripExpense = List<TripExpense>();
  TripContacts _tripContacts = TripContacts();

  List<TripClass> get getTripList => this._tripList;
  List<TripExpense> get getTripExpenseList => this._tripExpense;
  //  get getQueriedContacts => this._tripContacts;
  List<ContactCardData> get getSelectedContacts =>
      this._tripContacts.selectedContacts;

  set setUserBloc(UserBloc userBloc) {
    this.userBloc = userBloc;
    print("I got my user!!, said tripBloc for: ${this.userBloc.phoneNumber}");
    _fetchTrips();
  }

  StreamController<TripEvent> _tripEventController =
      StreamController<TripEvent>.broadcast();
  StreamSink<TripEvent> get tripEventSink => _tripEventController.sink;
  Stream<TripEvent> get _tripEventStream => _tripEventController.stream;

  StreamController<List<TripClass>> _tripListController =
      StreamController<List<TripClass>>.broadcast();
  StreamSink<List<TripClass>> get _tripListSink => _tripListController.sink;
  Stream<List<TripClass>> get tripListStream => _tripListController.stream;

  StreamController<List<TripExpense>> _tripExpenseListController =
      StreamController<List<TripExpense>>.broadcast();
  StreamSink<List<TripExpense>> get _tripExpenseListSink =>
      _tripExpenseListController.sink;
  Stream<List<TripExpense>> get tripExpenseListStream =>
      _tripExpenseListController.stream;

  StreamController<List<ContactCardData>> _queryContactListController =
      StreamController<List<ContactCardData>>.broadcast();
  StreamSink<List<ContactCardData>> get _queryContactListSink =>
      _queryContactListController.sink;
  Stream<List<ContactCardData>> get queryContactListStream =>
      _queryContactListController.stream;

  StreamController<List<ContactCardData>> _selectedContactListController =
      StreamController<List<ContactCardData>>.broadcast();
  StreamSink<List<ContactCardData>> get _selectedContactListSink =>
      _selectedContactListController.sink;
  Stream<List<ContactCardData>> get selectedContactListStream =>
      _selectedContactListController.stream;

  TripBloc() {
    _tripEventStream.listen(_mapEventToFunction);
  }

  void _mapEventToFunction(TripEvent event) async {
    if (event is CreateNewTrip) {
      Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("trips")
          .add(event.trip.toJson())
          .then((onValue) {
        print("Added new Trip \"${event.trip.title}\"");
      });
    } else if (event is UpdateTripDetails) {
    } else if (event is DeleteTrip) {
      //===========================DeleteTrip===========================
      Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("trips")
          .document(event.documentID)
          .updateData({
        "${userBloc.phoneNumber}.isDeleted": true,
      });
    } else if (event is DeleteTripAll) {
      //===========================DeleteTripAll===========================
      Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("trips")
          .document(event.documentID)
          .delete()
          .then((onValue) {
        print("Trip deleted: ${event.documentID}");
      });
    } else if (event is AddTripExpense) {
    } else if (event is UpdateTripExpense) {
    } else if (event is DeleteTripExpense) {
    } else if (event is FetchTripExpense) {
      //===========================FetchTripExpense===========================
      Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("trips")
          .document(event.documentID)
          .collection("tripExpenses")
          .orderBy("id", descending: true)
          .getDocuments()
          .then((QuerySnapshot snapshot) {
        _tripExpense = List<TripExpense>();

        for (int i = 0; i < snapshot.documents.length; i++) {
          _tripExpense.add(TripExpense.fromSnapshot(snapshot.documents[i]));
        }

        // add trip expense list values to stream sink
        _tripExpenseListSink.add(_tripExpense);
      });
    } else if (event is SplitExpense) {
    } else if (event is QueryContactList) {
      //===========================QueryContactList===========================

      _queryContactListSink.add(
        await _tripContacts.getContactsQueryList(event.query),
      );
    } else if (event is ToggleContactSelection) {
      //===========================ToggleContactSelection===========================

      // toggle the contact given
      _tripContacts.toggleContact(event.contactCardHandler);

      // TO  push chaged values to stream
      _selectedContactListSink.add(_tripContacts.selectedContacts);
    } else if (event is SelectedContactList) {
      //===========================SelectedContactList===========================

      // add list of selected contacts to _selectedContactListSink sink
      _selectedContactListSink.add(_tripContacts.selectedContacts);
    }
  }

  void _fetchTrips() {
    Firestore.instance
        // .collection("Users 3.0")
        // .document("data")
        .collection("trips")
        .where("participants", arrayContains: userBloc.phoneNumber)
        .where("${userBloc.phoneNumber}.isDeleted", isEqualTo: false)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      _tripList = List<TripClass>();

      for (int i = 0; i < snapshot.documents.length; i++) {
        _tripList.add(TripClass.fromSnapshot(snapshot.documents[i]));
      }

      _tripListSink.add(_tripList);

      //====================Test====================//
      // Firestore.instance
      //     .collection("test")
      //     .document("test")
      //     .setData(_tripList[0].toJson())
      //     .then((onValue) {
      //   print("Addded to test Data");
      // });
    });
  }

  @override
  void dispose() {
    _tripEventController.close();
    _tripListController.close();
    _tripExpenseListController.close();
    _queryContactListController.close();
    _selectedContactListController.close();
  }
}

/// The contact class used to show list of contacts when
/// searching for participants in trip creation. Also keeps
/// record of all the contacts that were selcted and handles
/// toggling of selecting and unselecting contatcs.
class TripContacts extends Bloc {
  /// The list of contacts which were selecting while
  /// creating a new trip.
  List<ContactCardData> _selectedContacts = List<ContactCardData>();

  /// List of all the contacts stored in the device
  List<ContactCardData> _allContacts = List<ContactCardData>();

  /// Getter for getting all the contacts stored in the device
  List<ContactCardData> get getAllContacts => _allContacts;

  // List<Contact> _allContacts = List<Contact>();
  List<ContactCardData> get selectedContacts => _selectedContacts;

  StreamController<List<ContactCardData>> _contactCardController =
      StreamController<List<ContactCardData>>();
  StreamSink<List<ContactCardData>> get _contactCardSink =>
      _contactCardController.sink;
  Stream<List<ContactCardData>> get contactCardStream =>
      _contactCardController.stream;

  TripContacts() {
    _selectedContacts = List<ContactCardData>();
    fetchAllContacts();
  }

  Future<List<ContactCardData>> fetchAllContacts() async {
    List<Contact> contactList = (await ContactsService.getContacts(
      withThumbnails: false,
      photoHighResolution: false,
      orderByGivenName: true,
    ))
        .toList();

    Set<ContactCardData> contactCards = Set<ContactCardData>();
    // loops through all the contacts and saved them to a set
    // to remove duplicates arising from whatsapp and telegram
    // accounts.
    for (int i = 0; i < contactList.length; i++) {
      for (int j = 0; j < contactList[i].phones.length; j++) {
        contactCards.add(
          ContactCardData(
            displayName: contactList[i].displayName,
            phoneNumber: ContactsProvider.stripPhoneNumber(
                contactList[i].phones.toList()[j].value.toString()),
          ),
        );
      }
    }
    _allContacts = contactCards.toList();
    return _allContacts;
  }

  Future<List<ContactCardData>> getNamesFromNumber(List<String> phoneNumbers) async {
    List<ContactCardData> contacts = List<ContactCardData>();
    List<ContactCardData> allContacts = await fetchAllContacts();
    for (int i = 0; i < allContacts.length; i++) {
      if (phoneNumbers.contains(allContacts[i].phoneNumber)) {
        contacts.add(_allContacts[i]);
      }
    }
    return contacts;
  }

  /// Function to toggle [_selectedContacts] when they
  /// are selected or unselected.
  void toggleContact(ContactCardData contact) {
    if (_selectedContacts.contains(contact)) {
      _removeContact(contact);
      // print("tripClass.dart removed :${contact.phoneNumber}");
    } else {
      _addContact(contact);
      // print("tripClass.dart added :${contact.phoneNumber}");
    }
    // print("tripClass.dart tapped :${contact.phoneNumber}");
    _contactCardSink.add(_selectedContacts);
  }

  /// Adds a [ContactCardData] to the list of selected contacts [_selectedContacts]
  void _addContact(ContactCardData contact) {
    _selectedContacts.add(contact);
  }

  /// Remove a [ContactCardData] from the list of selected contacts [_selectedContacts]
  void _removeContact(ContactCardData contact) {
    _selectedContacts.remove(contact);
  }

  /// Return a list of contacts relating to a specific [query]
  /// for fetching related contacts. Used for contructing
  /// the contact list for adding trip participants.
  Future<List<ContactCardData>> getContactsQueryList(String query) async {
    // Fetch all the contacts from device
    List<Contact> contactList = (await ContactsService.getContacts(
      query: query,
      withThumbnails: false,
      photoHighResolution: false,
      orderByGivenName: true,
    ))
        .toList();

    Set<ContactCardData> contactCards = Set<ContactCardData>();
    // loops through all the contacts and saved them to a set
    // to remove duplicates arising from whatsapp and telegram
    // accounts.
    for (int i = 0; i < contactList.length; i++) {
      for (int j = 0; j < contactList[i].phones.length; j++) {
        contactCards.add(
          ContactCardData(
            displayName: contactList[i].displayName,
            phoneNumber: ContactsProvider.stripPhoneNumber(
                contactList[i].phones.toList()[j].value.toString()),
          ),
        );
      }
    }
    return contactCards.toList();
  }

  @override
  void dispose() {
    _contactCardController.close();
  }
}
