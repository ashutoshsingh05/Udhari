import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udhari_2/Models/UdhariClass.dart';
import 'package:udhari_2/Models/ExpensesClass.dart';

class NormalUdhariForm extends StatefulWidget {
  NormalUdhariForm({@required this.user});

  final FirebaseUser user;

  @override
  _NormalUdhariFormState createState() => _NormalUdhariFormState();
}

class _NormalUdhariFormState extends State<NormalUdhariForm> {
  Expenses expenses;
  Udhari udhari;

  var dropDownButtonValue;

  OverlayEntry _overlayEntry;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController dateController = TextEditingController();
  TextEditingController contextController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController personNameController = TextEditingController();

  FocusNode dateFocus = FocusNode();
  FocusNode amountFocus = FocusNode();
  FocusNode contextFocus = FocusNode();
  FocusNode personNameFocus = FocusNode();

  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

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
                        value: dropDownButtonValue,
                        onChanged: (newValue) {
                          setState(() {
                            dropDownButtonValue = newValue;
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
                    child: TextFormField(
                      controller: personNameController,
                      keyboardType: TextInputType.text,
                      maxLength: 30,
                      textCapitalization: TextCapitalization.words,
                      autocorrect: true,
                      maxLines: 1,
                      focusNode: personNameFocus,
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(amountFocus);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Name cannot be empty!";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.backspace),
                          onPressed: () {
                            personNameController.clear();
                          },
                        ),
                        icon: Icon(Icons.account_circle),
                        labelText: "Name",
                      ),
                      inputFormatters: [
                        WhitelistingTextInputFormatter(
                          RegExp("[a-zA-Z\.\(\)\&\-\+\,\ ]"),
                        ),
                      ],
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
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(dateFocus);
                      },
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
                      focusNode: dateFocus,
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

  void _validateAndSave() async {
    if (_formKey.currentState.validate() == true) {
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
        personName: personNameController.text,
      );

      udhari = Udhari(
        udhari: expenses,
        isBorrowed: dropDownButtonValue == "Borrowed" ? true : false,
      );

      await Firestore.instance
          .collection('Users 2.0')
          .document("${widget.user.uid}")
          .collection('Udhari')
          .document('${DateTime.now().millisecondsSinceEpoch.toString()}')
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
