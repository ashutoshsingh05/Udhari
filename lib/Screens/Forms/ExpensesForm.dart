import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udhari_2/Models/ExpensesClass.dart';

class ExpensesForm extends StatefulWidget {
  ExpensesForm({@required this.user});

  final FirebaseUser user;

  @override
  _ExpensesFormState createState() => _ExpensesFormState();
}

class _ExpensesFormState extends State<ExpensesForm> {
  OverlayEntry _overlayEntry;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController dateController = TextEditingController();
  TextEditingController contextController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  FocusNode dateFocus = FocusNode();
  FocusNode amountFocus = FocusNode();
  FocusNode contextFocus = FocusNode();

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
        title: Text("Expenses"),
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
                    child: DateTimePickerFormField(
                      initialDate: DateTime.now(),
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                      maxLines: null,
                      controller: dateController,
                      inputType: InputType.both,
                      format: formats[InputType.both],
                      editable: false,
                      focusNode: dateFocus,
                      onChanged: (_) {
                        FocusScope.of(context).requestFocus(amountFocus);
                      },
                      validator: (value) {
                        if (value == null || value.toString() == "") {
                          return "Date cannot be empty!";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.today),
                        labelText: 'Date/Time',
                        hasFloatingPlaceholder: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 80, maxWidth: 200),
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        enableInteractiveSelection: false,
                        textInputAction: TextInputAction.next,
                        focusNode: amountFocus,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(contextFocus);
                        },
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
                          return null;
                        },
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.close),
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
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: TextFormField(
                      controller: contextController,
                      keyboardType: TextInputType.text,
                      maxLength: 120,
                      autocorrect: true,
                      maxLines: null,
                      focusNode: contextFocus,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Context cannot be empty!";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            amountController.clear();
                          },
                        ),
                        icon: Icon(Icons.event_note),
                        labelText: "Context",
                      ),
                      inputFormatters: [
                        WhitelistingTextInputFormatter(
                          RegExp("[a-zA-Z0-9\$\.\(\)\@\#\%\&\-\+\,\_\=\;\"\ ]"),
                        ),
                      ],
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

      Expenses expenses = Expenses(
        dateTime: dateController.text,
        amount: double.parse(amountController.text),
        context: contextController.text,
        personName: "Me",
      );

      await Firestore.instance
          .collection('Users 2.0')
          .document("${widget.user.uid}")
          .collection('Expenses')
          .document('${DateTime.now().millisecondsSinceEpoch.toString()}')
          .setData(expenses.toJson())
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
