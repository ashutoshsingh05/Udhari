import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:simple_search_bar/simple_search_bar.dart';
import 'package:udhari/Bloc/tripBloc.dart';
import 'package:udhari/Bloc/tripEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/tripClass.dart';
import 'package:udhari/Utils/globals.dart';
import 'package:udhari/Widgets/contactCard.dart';
import 'package:udhari/Widgets/selectedContactsAvatars.dart';

class TripsForm extends StatefulWidget {
  @override
  _TripsFormState createState() => _TripsFormState();
}

class _TripsFormState extends State<TripsForm> {
  AppBarController _searchController = AppBarController();

  UserBloc userBloc;
  TripBloc tripBloc;
  String _query = "";

  TextEditingController _titleController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// For caching the values of selected contact cards
  List<ContactCardData> _selectedContacts = List<ContactCardData>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    tripBloc = BlocProvider.of<TripBloc>(context);

    tripBloc.tripEventSink.add(QueryContactList(query: _query));
    // tripBloc.tripEventSink.add(SelectedContactList());

    return Scaffold(
      appBar: SearchAppBar(
        primary: Theme.of(context).primaryColor,
        appBarController: _searchController,
        searchHint: "Enter name",
        mainTextColor: Colors.white,
        onChange: (String queryValue) {
          _query = queryValue;
          tripBloc.tripEventSink.add(QueryContactList(query: queryValue));
        },
        // The app bar displayed when search
        // is inactive
        mainAppBar: AppBar(
          title: Text("Select Contacts"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _searchController.stream.add(true);
              },
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
                // to make the column stretch to
                // the whole width of the screen
                width: double.maxFinite,
              ),
              Container(
                height: 100,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: StreamBuilder<List<ContactCardData>>(
                  initialData: tripBloc.getSelectedContacts,
                  stream: tripBloc.selectedContactListStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ContactCardData>> snapshot) {
                    // print("tripForm.dart ${snapshot.data}");
                    if (snapshot.hasData) {
                      _selectedContacts = snapshot.data;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SelectedContactAvatars(
                            contactCards: snapshot.data,
                            tripBloc: tripBloc,
                          ),
                          SizedBox(
                            height: 20,
                            width: double.maxFinite,
                            child: Text(
                              "${snapshot.data.length} selected",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<List<ContactCardData>>(
                  stream: tripBloc.queryContactListStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ContactCardData>> snapshot) {
                    if (snapshot.hasData) {
                      // List<ContactCard> contactCards = snapshot.data;
                      return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            String name = snapshot.data[index].displayName;
                            String phone = snapshot.data[index].phoneNumber;
                            // bool isSelected = snapshot.data[index].isSelected;
                            return ContactCard(
                              name: name,
                              phoneNumber: phone,
                              onTap: () {
                                tripBloc.tripEventSink.add(
                                  ToggleContactSelection(
                                    contactCardHandler: snapshot.data[index],
                                  ),
                                );
                              },
                            );
                            // return Card(
                            //   child: ListTile(
                            //     leading: CircleAvatar(
                            //       backgroundImage: NetworkImage(
                            //         Globals.phoneToPhotoUrl(phone),
                            //       ),
                            //     ),
                            //     title: Text(name),
                            //     subtitle: Text(phone),
                            //     // trailing: isSelected
                            //     //     ? Icon(
                            //     //         Icons.check_circle,
                            //     //         color: Colors.green,
                            //     //       )
                            //     //     : null,
                            //     onTap: () {
                            //       tripBloc.tripEventSink.add(
                            //         ToggleContactSelection(
                            //           contactCard: snapshot.data[index],
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // );
                          });
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
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
          } else {
            getTripName();
          }
        },
      ),
    );
  }

  Future getTripName() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Trip name"),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _titleController,
              autocorrect: true,
              autofocus: true,
              autovalidate: true,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              validator: (String value) {
                if (value.trim().isEmpty)
                  return "Cannot be empty";
                else
                  return null;
              },
              inputFormatters: [
                WhitelistingTextInputFormatter(
                  RegExp(
                    "[a-zA-Z0-9\$\.\(\)\@\#\%\&\-\+\,\_\=\;\"\ ]",
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                initializeTrip();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void initializeTrip() {
    if (_formKey.currentState.validate() == true) {
      List<String> participant = List<String>();
      // print("selected contacts: $_selectedContacts");
      participant = _selectedContacts.map((f) {
        return f.phoneNumber;
      }).toList();

      // print("participant before additon: $participant");

      participant.add(userBloc.phoneNumber);

      // print("participant after additon: $participant");

      Map<String, dynamic> _partDetails = Map<String, dynamic>();
      for (String phone in participant) {
        _partDetails[phone] = {
          "isDeleted": false,
          "totalExpense": 0.0,
        };
      }

      // print("participants: $participant");

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
