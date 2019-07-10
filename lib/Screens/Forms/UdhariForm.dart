import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udhari_2/Models/UdhariClass.dart';
import 'package:udhari_2/Models/ExpensesClass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:udhari_2/Models/ContactsProvider.dart';

class UdhariForm extends StatefulWidget {
  UdhariForm({
    @required this.user,
    this.amountOpt,
    this.personNameOpt,
    this.contextOpt,
    this.dateTimeOpt,
    this.udhariTypeValue,
    this.epochTime,
  });

  final FirebaseUser user;
  final double amountOpt;
  final String personNameOpt;
  final String contextOpt;
  final String dateTimeOpt;
  final String epochTime;
  final udhariTypeValue;

  @override
  _UdhariFormState createState() => _UdhariFormState();
}

class _UdhariFormState extends State<UdhariForm> {
  Expenses expenses;
  Udhari udhari;

  var udhariTypeValue;
  var personNamevalue;

  OverlayEntry _overlayEntry;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController dateController = TextEditingController();
  TextEditingController contextController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController personNameController = TextEditingController();

  FocusNode amountFocus = FocusNode();
  FocusNode contextFocus = FocusNode();
  FocusNode personNameFocus = FocusNode();

  List<DropdownMenuItem> myContacts;

  ContactsProvider _contactsProvider;

  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  @override
  void initState() {
    super.initState();
    udhariTypeValue = widget.udhariTypeValue;
    amountController.text = widget.amountOpt.toString();
    personNameController.text = widget.personNameOpt;
    contextController.text = widget.contextOpt;
    dateController.text = widget.dateTimeOpt;

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.4),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    _permissionhandler();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.6),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.withOpacity(0.5),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 80,
                          maxWidth: 160,
                        ),
                        child: DropdownButtonFormField(
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
                              value: "Borrowed",
                            ),
                            DropdownMenuItem(
                              child: Text("Lent"),
                              value: "Lent",
                            ),
                          ],
                          validator: (value) {
                            if (value == null) {
                              return "Select Udhari Type!";
                            }
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
                        suggestionsCallback: (pattern) {
                          return _contactsProvider.getSuggestions(pattern);
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
                          if (!_contactsProvider.contactNames.contains(value)) {
                            return "Select Contact from dropdown Menu";
                          }
                        },
                        // onSaved: (value) => this._selectedCity = value,
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
                            //check if the value entered is ill
                            //formatted(cotains more than one decimal)
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
                              labelText: "Amount"),
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
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: DateTimePickerFormField(
                        initialDate: DateTime.now(),
                        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                        maxLines: null,
                        controller: dateController,
                        inputType: InputType.both,
                        format: formats[InputType.both],
                        editable: false,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            color: Colors.white,
                          ),
                          helperText: "(Optional)",
                          icon: Icon(Icons.today),
                          labelText: 'Date/Time',
                          hasFloatingPlaceholder: true,
                        ),
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
        child: Icon(Icons.check),
      ),
    );
  }

  void _permissionhandler() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    print("Permission Check: $permission");
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissionReq =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      print("Permission Req: $permissionReq");
      if (permissionReq.values.elementAt(0) != PermissionStatus.granted) {
        await PermissionHandler().openAppSettings();
        if (permission != PermissionStatus.granted) {
          return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    title: Text("Permission Denied"),
                    content: Text(
                        "Please give Contacts permission. It is required for providing person name suggestions"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          _permissionhandler();
                        },
                      ),
                      FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              });
        } else {
          print("Initializing contacts");
          _contactsProvider = ContactsProvider();
        }
      }
    } else {
      print("Initializing contacts");
      _contactsProvider = ContactsProvider();
    }
  }

  void _validateAndSave() async {
    if (_formKey.currentState.validate() == true) {
      _formKey.currentState.save();
      List<String> regPhones = List<String>();
      final String _time =
          widget.epochTime ?? DateTime.now().millisecondsSinceEpoch.toString();
      List<String> allPhones =
          _contactsProvider.getPhoneNumbers(personNameController.text);
      regPhones = await fetchRegisteredPhones(allPhones);
      print("RegPhones after await: $regPhones");

      //CASE I - If only one phone is registered then put data to that
      //document
      //CASE II - In case there is no registered phone number, then use
      //the first number as default
      //CASE III - In case there are multiple registered phones, present user
      //with a dialog box to selsect one number and use it with CASE I

      if (regPhones.length == 1) {
        // Overlay.of(context).insert(_overlayEntry);
        runRegularTransaction(_time, regPhones.first);
      } else if (regPhones.length == 0) {
        runRegularTransaction(_time, allPhones.first);
      } else {
        await runMultiTransaction(regPhones, _time);
      }
      print("RegPhones after transaction: $regPhones");
    } else {
      print("Form data NOT saved");
    }
  }

  Future<List<String>> fetchRegisteredPhones(List<String> phones) async {
    List<String> registeredPhones = List<String>();
    debugPrint("Fetch initiated");
    for (String phoneNumber in phones) {
      print("Iteration :$phoneNumber");
      DocumentSnapshot docSnap = await Firestore.instance
          .collection("Users 2.0")
          .document(phoneNumber)
          .get();
      if (docSnap.exists) {
        print("phoneNumber $phoneNumber is registered");
        registeredPhones.add(phoneNumber);
      } else {
        print("phoneNumber $phoneNumber is NOT registered");
      }
    }

    // phones.forEach((phoneNumber) async {
    //   debugPrint("Iteration on phone: $phoneNumber");
    //   await Firestore.instance
    //       .collection("Users 2.0")
    //       .document(phoneNumber)
    //       .get()
    //       .then((docSnap) {
    //     if (docSnap.exists) {
    //       print("phoneNumber $phoneNumber is registered");
    //       registeredPhones.add(phoneNumber);
    //     } else {
    //       print("phoneNumber $phoneNumber is NOT registered");
    //     }
    //   });
    // });
    debugPrint("Fetch concluded");
    return registeredPhones;
  }

  void runRegularTransaction(String time, String phoneNumber) async {
    Overlay.of(context).insert(_overlayEntry);

    final String _time = time;
    String recipientPhone;
    String recipientPhoto;

    //get the photoUrl and uid of the recipient of udhari

    await Firestore.instance
        .collection("Users 2.0")
        .where("phoneNumber", isEqualTo: phoneNumber)
        .getDocuments()
        .then((docSnap) {
      docSnap.documents.forEach((f) {
        // print("Document Exists: ${f.exists}");
        recipientPhone = f.data["phoneNumber"];
        recipientPhoto = f.data["photoUrl"];
        print("Recipent UID: $recipientPhone");
        print("Recipent Photo: $recipientPhoto");
      });
    });

    //initialise expenses and udhari
    expenses = Expenses(
      photoUrl: recipientPhoto ??
          "https://api.adorable.io/avatars/100/$phoneNumber.png",
      amount: double.parse(amountController.text),
      context: contextController.text,
      personName: personNameController.text,
      epochTime: _time,
      dateTime: dateController.text == ""
          ? DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")
              .format(DateTime.now())
              .toString()
          : dateController.text,
    );

    udhari = Udhari(
      expense: expenses,
      isBorrowed: udhariTypeValue == "Borrowed" ? true : false,
      isPaid: false,
      isSelfAdded: true,
      phoneNumber: phoneNumber,
    );

    await Firestore.instance
        .collection('Users 2.0')
        .document(
            "${widget.user.phoneNumber.substring(widget.user.phoneNumber.length - 10)}")
        .collection('Udhari')
        .document(_time)
        .setData(udhari.toJson())
        .then((_) async {
      print("Data Successfully saved to cloud!");

      //commit to recipient details to firebase only if
      //the user is already registered i.e when uid is not null
      if (recipientPhone != null) {
        udhari.expense.photoUrl = widget.user.photoUrl;
        udhari.expense.personName =
            widget.user.displayName ?? widget.user.phoneNumber;
        udhari.isBorrowed = !udhari.isBorrowed;
        udhari.isSelfAdded = !udhari.isSelfAdded;
        udhari.phoneNumber = widget.user.phoneNumber
            .substring(widget.user.phoneNumber.length - 10);
        await Firestore.instance
            .collection("Users 2.0")
            .document(recipientPhone)
            .collection("Udhari")
            .document(_time)
            .setData(udhari.toJson())
            .then((_) {
          print("Data added to Recipient profile");
        }).catchError((e) {
          print("Error commiting recipient data: $e");
        });
      } else {
        print("Recipient not using Udhari, Not commiting to cloud");
      }

      _formKey.currentState.reset();
      _overlayEntry.remove();
      Navigator.pop(context);
    }).catchError((e) {
      _overlayEntry.remove();
      print("Error occured: $e");
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Error: $e"),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    });
  }

  runMultiTransaction(List<String> phones, String time) {
    // List<Widget> columnElements = List<Widget>();
    // columnElements = phoneNumbersAsWidget(phones, time);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose an account"),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: phoneNumbersAsWidget(phones, time),
            // children: phoneNumbersAsWidget(phones, time),
          ),
        );
      },
    );
  }

  List<Widget> phoneNumbersAsWidget(List<String> phones, String time) {
    debugPrint("phoneNumbersAsWidget: $phones");
    List<Widget> columnChild = List<Widget>();
    for (String phoneNumber in phones) {
      columnChild.add(ListTile(
        title: Text(
          phoneNumber,
        ),
        dense: true,
        onTap: () {
          Navigator.of(context).pop();
          runRegularTransaction(time, phoneNumber);
        },
      ));
    }
    // print("Column Childs $columnChild");
    return columnChild;
  }
}
