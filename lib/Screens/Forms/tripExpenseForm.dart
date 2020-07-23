import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:udhari/Bloc/tripBloc.dart';
import 'package:udhari/Bloc/tripEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/tripClass.dart';
import 'package:udhari/Utils/globals.dart';

class TripExpenseForm extends StatefulWidget {
  final TripClass trip;

  TripExpenseForm({
    @required this.trip,
  });

  @override
  _TripExpenseFormState createState() => _TripExpenseFormState();
}

class _TripExpenseFormState extends State<TripExpenseForm> {
  UserBloc userBloc;
  TripBloc tripBloc;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<ContactCardData> _selectedContacts = List<ContactCardData>();

  bool isAll = true;
  bool isEqual = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    tripBloc = BlocProvider.of<TripBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Trip Expense"),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Colors.blueAccent,
              Colors.black,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                    width: double.maxFinite,
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        controller: _titleController,
                        autocorrect: true,
                        decoration: InputDecoration(
                          icon: Icon(Icons.note),
                          labelText: "Title",
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          enableInteractiveSelection: false,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Amount cannot be empty!";
                            }

                            int decimalCount = 0, i = 0;
                            while (i < value.length) {
                              if (value[i] == '.') {
                                decimalCount++;
                                if (decimalCount > 1) {
                                  return "Invalid Amount format!";
                                }
                              }
                              i++;
                            }
                            if (double.parse(value) > 100000) {
                              return "Too large! Pay your taxes!!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            errorStyle: TextStyle(
                              color: Colors.white,
                            ),
                            icon: Icon(Icons.attach_money),
                            labelText: "Amount",
                          ),
                          inputFormatters: [
                            WhitelistingTextInputFormatter(RegExp("[0-9\.]")),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        LiteRollingSwitch(
                          value: isAll,
                          textOn: 'All',
                          textOff: 'Select',
                          animationDuration: Duration(milliseconds: 400),
                          colorOn: Colors.greenAccent[700],
                          colorOff: Colors.redAccent[700],
                          iconOn: Icons.people,
                          iconOff: Icons.person,
                          textSize: 16.0,
                          onChanged: (bool state) {
                            isAll = state;
                          },
                        ),
                        LiteRollingSwitch(
                          value: isEqual,
                          textOn: 'Equal',
                          textOff: 'Unequal',
                          animationDuration: Duration(milliseconds: 400),
                          colorOn: Colors.greenAccent[700],
                          colorOff: Colors.redAccent[700],
                          iconOn: Icons.person,
                          iconOff: Icons.people,
                          textSize: 16.0,
                          onChanged: (bool state) {
                            isEqual = state;
                          },
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                    future: _ExpenseContacts(
                      phoneNumbers: widget.trip.participants,
                    ).getParticipantCards(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Card>> snapshot) {
                      print(snapshot.data);
                      if (snapshot.hasData) {
                        return Column(
                          children: snapshot.data,
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          if (_selectedContacts.length <= 0) {
            Fluttertoast.showToast(
              msg: "Select one more contact",
              backgroundColor: Colors.grey,
              gravity: ToastGravity.BOTTOM,
            );
            return null;
          } else {}
        },
      ),
    );
  }

  void initializeTripExpense() {
    if (_formKey.currentState.validate() == true) {
      List<String> participant = List<String>();

      participant = _selectedContacts.map((f) {
        return f.phoneNumber;
      }).toList();

      participant.add(userBloc.phoneNumber);

      Map<String, dynamic> _partDetails = Map<String, dynamic>();
      for (String phone in participant) {
        _partDetails[phone] = {
          "isDeleted": false,
          "totalExpense": 0.0,
        };
      }

      TripClass trip = TripClass(
        totalExpense: 0.0,
        dateTimeCreated: Globals.dateTimeFormat.format(DateTime.now()),
        dateTimeUpdated: Globals.dateTimeFormat.format(DateTime.now()),
        dateTimeFinished: null,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        participants: participant,
        participantDetails: _partDetails,
      );

      tripBloc.tripEventSink.add(CreateNewTrip(trip: trip));

      Navigator.of(context).pop();
    } else {
      print("Form validation failed");
    }
  }
}

/// Handles how the cards are displayed for
/// adjusting expenses
class _ExpenseContacts {
  List<String> phoneNumbers = List<String>();
  List<bool> isSelected = List<bool>();
  TripContacts tripContact = TripContacts();
  // List<ContactCardData> _contacts = List<ContactCardData>();
  // TripClass trip;

  _ExpenseContacts({
    @required this.phoneNumbers,
  });

  Future<List<Card>> getParticipantCards() async {
    List<Card> list = List<Card>();
    List<ContactCardData> _contacts =
        await tripContact.getNamesFromNumber(phoneNumbers);

    for (int i = 0; i < _contacts.length; i++) {
      list.add(
        Card(
          child: ListTile(
            leading: _CheckedAvatar(
              photoUrl: Globals.phoneToPhotoUrl(_contacts[i].phoneNumber),
              isChecked: isSelected[i],
            ),
            title: Text(
              await Globals.getOneNameFromPhone(_contacts[i].displayName),
            ),
          ),
        ),
      );
    }
    return list;
  }
}

/// Wrapper class for CircleAvatar. Adds a check
/// over an avatar to show that it is selected
class _CheckedAvatar extends StatelessWidget {
  final bool isChecked;
  final String photoUrl;

  _CheckedAvatar({
    @required this.photoUrl,
    @required this.isChecked,
  });

  @override
  Widget build(BuildContext context) {
    if (isChecked) {
      return Stack(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(photoUrl),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(Icons.check_circle),
          )
        ],
      );
    } else {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(photoUrl),
      );
    }
  }
}
