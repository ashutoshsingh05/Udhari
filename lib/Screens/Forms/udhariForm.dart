import 'dart:ui';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Models/contactsProvider.dart';
import 'package:udhari/Models/udhariClass.dart';
import 'package:udhari/Models/userClass.dart';
import 'package:udhari/Utils/globals.dart';
import 'package:udhari/Bloc/udhariBloc.dart';
import 'package:udhari/Bloc/udhariEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';

class UdhariForm extends StatefulWidget {
  UdhariForm({this.udhariToEdit});

  final UdhariClass udhariToEdit;

  @override
  _UdhariFormState createState() => _UdhariFormState();
}

class _UdhariFormState extends State<UdhariForm> {
  Color bgColor = Color(0xff231E35);
  Color appBarColor = Color(0xff641C4A);
  Color fabBgColor = Colors.white;
  Color fabFgColor = Colors.black;

  UserBloc userBloc;
  UdhariBloc udhariBloc;
  Udhari udhariTypeValue;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController dateController = TextEditingController();
  TextEditingController contextController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController personNameController = TextEditingController();

  FocusNode amountFocus = FocusNode();
  FocusNode contextFocus = FocusNode();
  FocusNode personNameFocus = FocusNode();

  ContactsProvider _contactsProvider = ContactsProvider();

  @override
  void initState() {
    super.initState();
    if (widget.udhariToEdit != null) {
      _assignValues();
    }
  }

  void _assignValues() async {
    udhariTypeValue = widget.udhariToEdit.udhariType;
    amountController.text = widget.udhariToEdit.amount.toString();
    personNameController.text = widget.udhariToEdit.borrower;
    contextController.text = widget.udhariToEdit.context;
    dateController.text = widget.udhariToEdit.dateTime;
    personNameController.text = widget.udhariToEdit.name;
  }

  @override
  void dispose() {
    dateController.dispose();
    contextController.dispose();
    amountController.dispose();
    personNameController.dispose();
    amountFocus.dispose();
    contextFocus.dispose();
    personNameFocus.dispose();
    super.dispose();
  }

  void initColors(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      bgColor = Colors.blueAccent;
      appBarColor = Colors.deepPurple;
      fabBgColor = Colors.white;
      fabFgColor = Colors.black;
    } else {
      bgColor = Color(0xff231E35);
      appBarColor = Color(0xff641C4A);
      fabBgColor = Color(0xff605052);
      fabFgColor = Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    udhariBloc = BlocProvider.of<UdhariBloc>(context);
    initColors(context);

    return Scaffold(
      backgroundColor: bgColor.withOpacity(0.7),
      appBar: AppBar(
        backgroundColor: appBarColor.withOpacity(0.5),
        title: Text("Udhari"),
      ),
      body: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 5.0,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                autovalidate: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 80,
                          maxHeight: 140,
                          maxWidth: 160,
                        ),
                        child: DropdownButtonFormField<Udhari>(
                          value: udhariTypeValue,
                          onChanged: (newValue) {
                            setState(() {
                              udhariTypeValue = newValue;
                              print("Udhari Type: $newValue");
                            });
                          },
                          hint: Text("Udhari Type"),
                          items: [
                            DropdownMenuItem(
                              child: Text("Borrowed"),
                              value: Udhari.Borrowed,
                            ),
                            DropdownMenuItem(
                              child: Text("Lent"),
                              value: Udhari.Lent,
                            ),
                          ],
                          validator: (value) {
                            if (value == null) {
                              return "Select Udhari Type!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            errorStyle: TextStyle(
                              color: Colors.white,
                            ),
                            icon: Icon(Icons.arrow_drop_down_circle),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: TypeAheadFormField(
                        textFieldConfiguration: TextFieldConfiguration(
                          focusNode: personNameFocus,
                          controller: personNameController,
                          inputFormatters: [
                            WhitelistingTextInputFormatter(
                              RegExp("[a-zA-Z0-9\ \(\)\-\=\+\&\,\.]"),
                            ),
                          ],
                          decoration: InputDecoration(
                            errorStyle: TextStyle(
                              color: Colors.white,
                            ),
                            labelText: 'Person Name',
                            icon: Icon(
                              Icons.account_circle,
                            ),
                          ),
                        ),
                        suggestionsCallback: (pattern) async {
                          if (pattern.length >= 2)
                            return await ContactsProvider
                                .getSimilarNameSuggestion(pattern);
                          else
                            return [];
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        transitionBuilder:
                            (context, suggestionsBox, controller) {
                          return suggestionsBox;
                        },
                        onSuggestionSelected: (suggestion) {
                          personNameController.text = suggestion;
                          print("Selected: $suggestion");
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a name';
                          }
                          if (!_contactsProvider.nameExists(value)) {
                            return "Select Contact from dropdown Menu";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxHeight: 80, maxWidth: 250),
                        child: TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          enableInteractiveSelection: false,
                          textInputAction: TextInputAction.next,
                          focusNode: amountFocus,
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(contextFocus);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Amount cannot be empty!";
                            }
                            //check if the value entered is
                            // ill-formatted(cotains more than one decimal)
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
                            suffixIcon: IconButton(
                              icon: Icon(Icons.backspace),
                              onPressed: () {
                                amountController.clear();
                              },
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
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: TextFormField(
                        controller: contextController,
                        keyboardType: TextInputType.text,
                        maxLength: 120,
                        autocorrect: true,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        focusNode: contextFocus,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Context cannot be empty!";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.backspace),
                            onPressed: () {
                              amountController.clear();
                            },
                          ),
                          icon: Icon(Icons.assignment),
                          labelText: "Context",
                        ),
                        inputFormatters: [
                          WhitelistingTextInputFormatter(
                            RegExp(
                              "[a-zA-Z0-9\$\.\(\)\@\#\%\&\-\+\,\_\=\;\"\ ]",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      constraints: BoxConstraints(
                        maxHeight: 160,
                        minHeight: 140,
                      ),
                      child: DateTimeField(
                        format: Globals.dateTimeFormat,
                        controller: dateController,
                        readOnly: true,
                        resetIcon: Icon(Icons.clear),
                        initialValue: DateTime.now(),
                        // expands: true,
                        maxLines: 2,
                        minLines: 2,
                        decoration: InputDecoration(
                            errorStyle: TextStyle(
                              color: Colors.white,
                            ),
                            helperText: "(Optional)",
                            icon: Icon(Icons.today),
                            labelText: 'Date/Time',
                            // hasFloatingPlaceholder: true,
                            floatingLabelBehavior: FloatingLabelBehavior.auto),
                        onShowPicker: (context, currentValue) async {
                          final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                currentValue ?? DateTime.now(),
                              ),
                            );
                            return DateTimeField.combine(date, time);
                          } else {
                            return currentValue;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _validateAndSave,
        backgroundColor: fabBgColor,
        foregroundColor: fabFgColor,
        child: Icon(Icons.check),
      ),
    );
  }

  void _validateAndSave() async {
    if (_formKey.currentState.validate() == true) {
      _formKey.currentState.save();

      // Get phoneNumbers associated with personNameController
      List<String> phoneNumbers =
          await ContactsProvider.getContactNumbersFromName(
              personNameController.text);
      print("PhoneNumbers $phoneNumbers");

      List<UserClass> registeredUsers =
          await udhariBloc.fetchRegisteredUsers(phoneNumbers);

      // print("Registered : ${registeredUsers}");

      //CASE I - If only one phone is registered then put data to that
      //document
      //CASE II - In case there is no registered phone number, then use
      //the first number as default
      //CASE III - In case there are multiple registered phones, present user
      //with a dialog box to select one number and use it with CASE I

      if (registeredUsers.length == 1) {
        print("CASE I");
        createUdhari(registeredUsers.first);
      } else if (registeredUsers.length == 0) {
        print("CASE II");
        UserClass unregisteredUser = UserClass(
          joinedOn: "",
          lastSeen: "",
          name: personNameController.text,
          phoneNumber: phoneNumbers[0],
          photoUrl: Globals.phoneToPhotoUrl(phoneNumbers[0]),
          uid: "",
          fcmToken: userBloc.getFcmToken,
        );
        createUdhari(unregisteredUser);
      } else {
        print("CASE III");
        await decideUser(registeredUsers);
      }
    } else {
      print("Form data NOT saved");
    }
  }

  Future decideUser(List<UserClass> registeredUsers) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose an account"),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: phoneNumbersAsWidget(registeredUsers),
          ),
        );
      },
    );
  }

  List<Widget> phoneNumbersAsWidget(List<UserClass> registeredUsers) {
    List<Widget> columnChild = List<Widget>();
    for (int i = 0; i < registeredUsers.length; i++) {
      columnChild.add(ListTile(
        title: Text(
          registeredUsers[i].name,
        ),
        subtitle: Text(registeredUsers[i].phoneNumber),
        dense: true,
        onTap: () {
          Navigator.of(context).pop();
          createUdhari(registeredUsers[i]);
        },
      ));
    }
    return columnChild;
  }

  void createUdhari(UserClass registeredUser) {
    double _amount;
    String _borrower;
    String _borrowerName;
    String _lender;
    String _lenderName;
    String _context;
    String _dateTime;
    String _createdAt;
    List<String> _participants = List<String>();
    String _borrowerPhotoUrl;
    String _lenderPhotoUrl;
    String _firstParty;
    bool _firstPartyDeleted;
    bool _firstPartySatisfied;
    String _secondParty;
    bool _secondPartyDeleted;
    bool _secondPartySatisfied;
    String _id;

    _amount = double.parse(amountController.text);
    _context = contextController.text;
    _dateTime = dateController.text == ""
        ? Globals.dateTimeFormat.format(DateTime.now())
        : dateController.text;
    _createdAt = widget.udhariToEdit == null
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : widget.udhariToEdit.createdAt;

    _participants.addAll([userBloc.phoneNumber, registeredUser.phoneNumber]);
    _firstParty = userBloc.phoneNumber;
    _firstPartyDeleted = false;
    _firstPartySatisfied = false;
    _secondParty = registeredUser.phoneNumber;
    _secondPartyDeleted = widget.udhariToEdit == null
        ? false
        : widget.udhariToEdit.secondPartyDeleted;
    _secondPartySatisfied = widget.udhariToEdit == null
        ? false
        : widget.udhariToEdit.secondPartySatisfied;

    String _dateTimeString = dateController.text == ""
        ? Globals.dateTimeFormat.format(DateTime.now())
        : dateController.text;

    DateTime idDateTime = Globals.dateTimeFormat.parse(_dateTimeString);

    _id = idDateTime.millisecondsSinceEpoch.toString();

    if (udhariTypeValue == Udhari.Borrowed) {
      _borrower = userBloc.phoneNumber;
      _borrowerName = userBloc.name;
      _borrowerPhotoUrl = Globals.phoneToPhotoUrl(userBloc.phoneNumber);

      _lender = registeredUser.phoneNumber;
      _lenderName = personNameController.text;
      _lenderPhotoUrl = Globals.phoneToPhotoUrl(registeredUser.phoneNumber);
    } else {
      _lender = userBloc.phoneNumber;
      _lenderName = userBloc.name;
      _lenderPhotoUrl = Globals.phoneToPhotoUrl(userBloc.phoneNumber);

      _borrower = registeredUser.phoneNumber;
      _borrowerName = personNameController.text;
      _borrowerPhotoUrl = Globals.phoneToPhotoUrl(registeredUser.phoneNumber);
    }

    UdhariClass udhari = UdhariClass(
      amount: _amount,
      context: _context,
      dateTime: _dateTime,
      borrower: _borrower,
      borrowerName: _borrowerName,
      borrowerPhotoUrl: _borrowerPhotoUrl,
      createdAt: _createdAt,
      firstParty: _firstParty,
      firstPartyDeleted: _firstPartyDeleted,
      firstPartySatisfied: _firstPartySatisfied,
      firstPartyFcmToken: userBloc.getFcmToken,
      id: _id,
      isMerged: false,
      lender: _lender,
      lenderName: _lenderName,
      lenderPhotoUrl: _lenderPhotoUrl,
      participants: _participants,
      secondParty: _secondParty,
      secondPartyDeleted: _secondPartyDeleted,
      secondPartySatisfied: _secondPartySatisfied,
      secondPartyFcmToken: registeredUser.fcmToken,
    );

    if (widget.udhariToEdit == null) {
      udhariBloc.udhariEventSink.add(AddUdhariRecord(
        udhari: udhari,
      ));

      // Go back to Udhari page
      Navigator.of(context).pop();
    } else {
      // Assigned the document ID of previous doc (doc being editing) to
      // sink to enable successful overriding of the document at
      // the given document ID
      udhariBloc.udhariEventSink.add(UpdateUdhariRecord(
        udhari: udhari,
        docID: widget.udhariToEdit.documentID,
      ));

      // Go back to Udhari page
      Navigator.of(context).pop();
    }
  }
}
