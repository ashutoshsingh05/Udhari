import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Models/udhariClass.dart';
import 'package:udhari/Models/userClass.dart';
import 'package:udhari/Utils/globals.dart';
import 'package:udhari/Bloc/udhariEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';

class UdhariBloc extends Bloc {
  UserBloc userBloc;
  List<UdhariClass> _udhariList = List<UdhariClass>();
  double _totalDebit = 0;
  double _totalCredit = 0;

  double get getTotalCredit => _totalCredit;
  double get getTotalDebit => _totalDebit;
  List<UdhariClass> get getUdhariList => this._udhariList;

  set setUserBloc(UserBloc userBloc) {
    this.userBloc = userBloc;
    print("I got my user!!, said udhariBloc for: ${this.userBloc.phoneNumber}");
    _fetchUdhari();
  }

  /// Stream controller for mapping events to respective functions tasks
  StreamController<UdhariEvent> _udhariEventController =
      StreamController<UdhariEvent>.broadcast();
  StreamSink<UdhariEvent> get udhariEventSink => _udhariEventController.sink;
  Stream<UdhariEvent> get _udhariEventStream => _udhariEventController.stream;

  /// Stream controller for displaying list of udhari
  StreamController<List<UdhariClass>> _udhariListController =
      StreamController<List<UdhariClass>>.broadcast();
  Stream<List<UdhariClass>> get udhariListStream =>
      _udhariListController.stream;
  StreamSink<List<UdhariClass>> get _udhariListSink =>
      _udhariListController.sink;

  /// Stream controller for displaying total debit on dashboard
  StreamController<double> _totalDebitController =
      StreamController<double>.broadcast();
  Stream<double> get totalDebitStream => _totalDebitController.stream;
  StreamSink<double> get _totalDebitSink => _totalDebitController.sink;

  /// Stream controller for displaying total credit on dashboard
  StreamController<double> _totalCreditController =
      StreamController<double>.broadcast();
  Stream<double> get totalCreditStream => _totalCreditController.stream;
  StreamSink<double> get _totalCreditSink => _totalCreditController.sink;

  UdhariBloc() {
    _udhariEventStream.listen(_mapEventToFunction);
  }

  void _mapEventToFunction(UdhariEvent event) async {
    //===========================AddUdhariRecord===========================
    if (event is AddUdhariRecord) {
      await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("udhari")
          .add(event.udhari.toJson())
          .then((onValue) {
        print("Added new udhari \"${event.udhari.context}\"");
      });

      //===========================UpdateUdhariRecord===========================

    } else if (event is UpdateUdhariRecord) {
      await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("udhari")
          .document(event.docID)
          .updateData(event.udhari.toJson())
          .then((onValue) {
        print("Updated udhari for ${event.udhari.context}"
            " dated ${event.udhari.dateTime}");
      }).catchError((onError) {
        print("Error Caught updating udhari: $onError");
      });

      //===========================SatisfiedUdhariRecord===========================

    } else if (event is SatisfiedUdhariRecord) {
      if (event.udhari.partyType == PartyType.FirstParty) {
        event.udhari.firstPartySatisfied = true;
      } else {
        event.udhari.secondPartySatisfied = true;
      }
      // Add the updated udhari to udhariEventSink to push changes to firebase
      this.udhariEventSink.add(UpdateUdhariRecord(
            udhari: event.udhari,
            docID: event.udhari.documentID,
          ));

      //===========================DeleteUdhariRecord===========================

    } else if (event is DeleteUdhariRecord) {
      if (event.udhari.partyType == PartyType.FirstParty) {
        event.udhari.firstPartyDeleted = true;
      } else {
        event.udhari.secondPartyDeleted = true;
      }
      // Add udhari with deletion value to UpdateUdhariRecord
      // event to propogate values to Firebase
      this.udhariEventSink.add(UpdateUdhariRecord(
            udhari: event.udhari,
            docID: event.docID,
          ));

      //===========================MergeSatisfyEvent===========================

    } else if (event is MergeSatisfyEvent) {
      if (event.udhari.partyType == PartyType.FirstParty) {
        // first party records are not deleted because they would
        // make the records dissappear from secondParty
        event.udhari.firstPartyMerged = true;
      } else {
        event.udhari.secondPartyDeleted = true;
      }
      this.udhariEventSink.add(UpdateUdhariRecord(
            udhari: event.udhari,
            docID: event.docID,
          ));

      //===========================MergeThisUdhariRecord===========================

    } else if (event is MergeThisUdhariRecord) {
      List<UdhariClass> mergeablUdharis = List<UdhariClass>();
      mergeablUdharis.addAll(_udhariList);

      // filter out udharis having phoneNumberToMerge listed
      // in participants list as these udharis are mergeable
      mergeablUdharis.retainWhere((udhari) {
        return udhari.participants.contains(event.phoneNumberToMerge);
      });

      if (mergeablUdharis.length <= 1) {
        print("Not Mergeable");
      } else {
        UdhariClass _mergedUdhari;
        double _amount = 0;
        String _borrower;
        String _borrowerName;
        String _borrowerPhotoUrl;
        String _lender;
        String _lenderName;
        String _lenderPhotoUrl;
        String _context = "";
        String _lentContext = "";
        String _borrowedContext = "";
        String _dateTime = Globals.dateTimeFormat.format(DateTime.now());
        String _createdAt = Globals.dateTimeFormat.format(DateTime.now());
        List<String> _participants = [
          userBloc.phoneNumber,
          event.phoneNumberToMerge,
        ];
        String _firstParty = userBloc.phoneNumber;
        bool _firstPartyDeleted = false;
        bool _firstPartySatisfied = false;
        String _secondParty = event.phoneNumberToMerge;
        bool _secondPartyDeleted = true;
        bool _secondPartySatisfied = true;
        String _id = DateTime.now().millisecondsSinceEpoch.toString();
        bool _isMerged = true;

        for (int i = 0; i < mergeablUdharis.length; i++) {
          if (mergeablUdharis[i].udhariType == Udhari.Borrowed) {
            _amount = _amount - mergeablUdharis[i].amount;
            _borrowedContext =
                _borrowedContext + "${mergeablUdharis[i].context} + ";
          } else {
            _amount = _amount + mergeablUdharis[i].amount;
            _lentContext = _lentContext + "${mergeablUdharis[i].context} + ";
          }
        }

        // Clip the trailing "; " character from contexts if these contexts
        // contain any context
        if (_borrowedContext.isNotEmpty) {
          _borrowedContext =
              _borrowedContext.substring(0, _borrowedContext.length - 2);
          _borrowedContext = "($_borrowedContext)";
        }
        if (_lentContext.isNotEmpty) {
          _lentContext = _lentContext.substring(0, _lentContext.length - 2);

          _lentContext = "($_lentContext)";
        }

        // Now if the net _amount is -ve, then that means the current user
        // has borrowed money and if it positive then the user has
        // lent money to the other user
        if (_amount < 0) {
          //udhari is actually of type Udhari.Borrowed
          _amount = _amount.abs();
          _borrower = userBloc.phoneNumber;
          _borrowerName = userBloc.name;
          _borrowerPhotoUrl = userBloc.photoUrl;
          _lender = event.phoneNumberToMerge;
          _lenderName =
              await Globals.getOneNameFromPhone(event.phoneNumberToMerge);
          _lenderPhotoUrl = Globals.phoneToPhotoUrl(event.phoneNumberToMerge);
          // if udhari is of type borrowed, then borrowed contexts should be
          // shown first and lent contexts should be subtracted from them
          // with a minus (-) sign.
          // if udhari is of type lent, then lent contexts should be
          // shown first and borrowed contexts should be subtracted from them
          // with a minus (-) sign.

          // If lent context is empty, don't show them at all
          _lentContext.isNotEmpty
              ? _context = _borrowedContext + " - " + _lentContext
              : _context = _borrowedContext;
        } else {
          //udhari is actually of type Udhari.Lent
          _borrower = event.phoneNumberToMerge;
          _borrowerName =
              await Globals.getOneNameFromPhone(event.phoneNumberToMerge);
          _borrowerPhotoUrl = Globals.phoneToPhotoUrl(event.phoneNumberToMerge);
          _lender = userBloc.phoneNumber;
          _lenderName = userBloc.name;
          _lenderPhotoUrl = userBloc.photoUrl;

          // If borrowed context is empty, don't show them at all
          _borrowedContext.isNotEmpty
              ? _context = _lentContext + " - " + _borrowedContext
              : _context = _lentContext;
        }

        _mergedUdhari = UdhariClass(
          amount: _amount,
          borrower: _borrower,
          borrowerName: _borrowerName,
          borrowerPhotoUrl: _borrowerPhotoUrl,
          context: _context,
          createdAt: _createdAt,
          dateTime: _dateTime,
          firstParty: _firstParty,
          firstPartyDeleted: _firstPartyDeleted,
          firstPartySatisfied: _firstPartySatisfied,
          // fcm tokens are empty here because we do not
          // with to send notifications on merge events
          firstPartyFcmToken: "",
          id: _id,
          isMerged: _isMerged,
          lender: _lender,
          lenderName: _lenderName,
          lenderPhotoUrl: _lenderPhotoUrl,
          participants: _participants,
          secondParty: _secondParty,
          secondPartyDeleted: _secondPartyDeleted,
          secondPartySatisfied: _secondPartySatisfied,
          secondPartyFcmToken: ""
        );

        // add the merged udhari to database
        this.udhariEventSink.add(AddUdhariRecord(udhari: _mergedUdhari));

        // delete (mark as deleted) the udharis which have been merged into
        // a single udhari for the current user.
        for (UdhariClass udhari in mergeablUdharis) {
          this.udhariEventSink.add(MergeSatisfyEvent(
                udhari: udhari,
                docID: udhari.documentID,
              ));
        }
      }

      //===========================MergeAllUdhariRecord===========================

    } else if (event is MergeAllUdhariRecord) {
      throw UnsupportedError("MergeAllUdhariRecord is currently not supported");
      // Just add MergeThisUdhariRecord event
      // to the sink for all phone numbers in _udhariList
      // for (UdhariClass udhari in _udhariList) {
      //   String _phoneNumberToMerge = udhari.otherPhoneNumber;

      //   this.udhariEventSink.add(MergeThisUdhariRecord(
      //         phoneNumberToMerge: _phoneNumberToMerge,
      //       ));
      // }
    }
  }

  void _fetchUdhari() {
    Firestore.instance
        // .collection("Users 3.0")
        // .document("data")
        .collection("udhari")
        .where("participants", arrayContains: userBloc.phoneNumber)
        .where("firstPartyDeleted", isEqualTo: false)
        .where("firstPartySatisfied", isEqualTo: false)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      _udhariList = List<UdhariClass>();
      _totalDebit = 0;
      _totalCredit = 0;

      //TODO: Implement Isolates to improve performance

      for (int i = 0; i < snapshot.documents.length; i++) {
        _udhariList.add(UdhariClass.fromSnapshot(
          snapshot: snapshot.documents[i],
          userBloc: userBloc,
        ));
      }

      // Remove the udhari records where the participant is secondParty
      // and secondParty has already deleted the record OR party is first
      // party and it has merged this record

      _udhariList.removeWhere((UdhariClass udhari) {
        return ((udhari.partyType == PartyType.SecondParty) &&
                ((udhari.secondPartyDeleted) ||
                    (udhari.secondPartySatisfied))) ||
            ((udhari.partyType == PartyType.FirstParty) &&
                (udhari.firstPartyMerged == true));
      });

      for (int i = 0; i < _udhariList.length; i++) {
        if (_udhariList[i].udhariType == Udhari.Borrowed) {
          _totalDebit += _udhariList[i].amount;
        } else {
          _totalCredit += _udhariList[i].amount;
        }
      }

      _udhariList.sort((a, b) => b.id.compareTo(a.id));

      _totalDebitSink.add(_totalDebit);
      _totalCreditSink.add(_totalCredit);
      _udhariListSink.add(_udhariList);
    });
  }

  Future<List<UserClass>> fetchRegisteredUsers(List<String> phones) async {
    List<UserClass> registeredUsers = List<UserClass>();
    for (String phoneNumber in phones) {
      DocumentSnapshot snapshot = await Firestore.instance
          // .collection("Users 3.0")
          // .document("data")
          .collection("users")
          .document(phoneNumber)
          .get();
      if (snapshot.exists) {
        registeredUsers.add(UserClass.fromSnapshot(snapshot));
        print("USER $phoneNumber EXISTS");
      } else {
        print("USER $phoneNumber DOES NOT exists");
      }
    }
    return registeredUsers;
  }

  @override
  void dispose() {
    _udhariListController.close();
    _udhariEventController.close();
    _totalDebitController.close();
    _totalCreditController.close();
  }
}
