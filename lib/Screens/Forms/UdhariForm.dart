import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udhari_2/Models/UdhariClass.dart';
import 'package:udhari_2/Models/ExpensesClass.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class UdhariForm extends StatefulWidget {
  UdhariForm({@required this.user});

  final FirebaseUser user;

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
  // TextEditingController personNameController = TextEditingController();

  // FocusNode dateFocus = FocusNode();
  FocusNode amountFocus = FocusNode();
  FocusNode contextFocus = FocusNode();
  // FocusNode personNameFocus = FocusNode();

  List<DropdownMenuItem> myContacts;

  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    // InputType.date: DateFormat('yyyy-MM-dd'),
    // InputType.time: DateFormat("HH:mm"),
  };

  // getPermission() async {
  //   PermissionStatus permission;
  //   permission = await PermissionHandler()
  //       .checkPermissionStatus(PermissionGroup.contacts)
  //       .then((onValue) {
  //     print("Permission Status: $permission");
  //   });

  //   Map<PermissionGroup, PermissionStatus> permissions =
  //       await PermissionHandler()
  //           .requestPermissions([PermissionGroup.contacts]);
  //   // await PermissionHandler()
  //   //     .shouldShowRequestPermissionRationale(PermissionGroup.contacts);
  //   permission = await PermissionHandler()
  //       .checkPermissionStatus(PermissionGroup.contacts)
  //       .then((onValue) {
  //     print("Permission Status: $permission");
  //   });
  // }

  _permissionhandler() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    print("Permission Check: $permission");
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissionReq =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      print("Permission Req: $permissionReq");
      if (permissionReq.values.elementAt(0) == PermissionStatus.denied) {
        await PermissionHandler().openAppSettings();
        if (permission != PermissionStatus.granted) {
          return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Contacts Permission"),
                  content: Text(
                      "Please give Contacts permission. It is necessary for providing person name suggestion"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.pop(context);
                        _permissionhandler();
                      },
                    ),
                  ],
                );
              });
        } else {
          print("Initializing contacts");
          initializeContactsList();
        }
      }
    } else if (permission == PermissionStatus.granted) {
      print("Initializing contacts");
      initializeContactsList();
    }
  }

  @override
  void initState() {
    super.initState();
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
    // initializeContactsList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Udhari"),
      ),
      body: SingleChildScrollView(
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
                            print("Changed to new Value: $newValue");
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
                          icon: Icon(Icons.arrow_drop_down_circle),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: DropdownButtonFormField(
                      value: personNamevalue,
                      items: myContacts,
                      onChanged: (newPerson) {
                        setState(() {
                          personNamevalue = newPerson;
                        });
                      },
                      // controller: personNameController,
                      // keyboardType: TextInputType.text,
                      // maxLength: 30,
                      // textCapitalization: TextCapitalization.words,
                      // textInputAction: TextInputAction.next,
                      // autocorrect: true,
                      // maxLines: 1,
                      // focusNode: personNameFocus,
                      // onEditingComplete: () {
                      //   FocusScope.of(context).requestFocus(amountFocus);
                      // },
                      hint: Text("Select Name"),
                      validator: (value) {
                        if (value == null) {
                          return "Name cannot be empty!";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.backspace),
                          onPressed: () {
                            // personNameController.clear();
                          },
                        ),
                        icon: Icon(Icons.account_circle),
                        labelText: "Name",
                      ),
                      // inputFormatters: [
                      //   WhitelistingTextInputFormatter(
                      //     RegExp("[a-zA-Z\.\(\)\&\-\+\,\ ]"),
                      //   ),
                      // ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 80, maxWidth: 200),
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        enableInteractiveSelection: false,
                        textInputAction: TextInputAction.next,
                        focusNode: amountFocus,
                        maxLength: 6,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(contextFocus);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Amount cannot be empty!";
                          }
                          if (double.parse(value) > 100000) {
                            return "Amount is too large!";
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
                          return null;
                        },
                        decoration: InputDecoration(
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
                      // onEditingComplete: () {
                      //   FocusScope.of(context).requestFocus(dateFocus);
                      // },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Context cannot be empty!";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
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
                          RegExp("[a-zA-Z0-9\$\.\(\)\@\#\%\&\-\+\,\_\=\;\"\ ]"),
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
                      // focusNode: dateFocus,
                      // validator: (value) {
                      //   if (value == null || value.toString() == "") {
                      //     return "Date cannot be empty!";
                      //   }
                      //   return null;
                      // },
                      decoration: InputDecoration(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _validateAndSave,
        child: Icon(Icons.check),
      ),
    );
  }

  initializeContactsList() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    print(contacts);
  }

  void _validateAndSave() async {
    if (_formKey.currentState.validate() == true) {
      String _time = DateTime.now().millisecondsSinceEpoch.toString();
      Overlay.of(context).insert(_overlayEntry);
      _formKey.currentState.save();

      expenses = Expenses(
        dateTime: dateController.text == ""
            ? DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")
                .format(DateTime.now())
                .toString()
            : dateController.text,
        amount: double.parse(amountController.text),
        context: contextController.text,
        // personName: personNameController.text,
        epochTime: _time,
      );

      udhari = Udhari(
        udhari: expenses,
        isBorrowed: udhariTypeValue == "Borrowed" ? true : false,
        isPaid: false,
      );

      await Firestore.instance
          .collection('Users 2.0')
          .document("${widget.user.uid}")
          .collection('Udhari')
          .document(_time)
          .setData(udhari.toJson())
          .then((_) {
        print("Data Successfully saved to cloud!");
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
    } else {
      print("Form data NOT saved");
    }
  }
}
