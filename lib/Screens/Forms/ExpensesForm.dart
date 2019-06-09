import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpensesForm extends StatefulWidget {
  ExpensesForm({@required this.user});

  final FirebaseUser user;

  @override
  _ExpensesFormState createState() => _ExpensesFormState();
}

class _ExpensesFormState extends State<ExpensesForm> {
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
                        icon: Icon(Icons.calendar_today),
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
                      onFieldSubmitted: (_) {
                        _validateAndSave();
                      },
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
      _formKey.currentState.save();

      // Firestore firestore = Firestore.instance;
      // var settings = FirebaseFirestoreSettings.Builder().

      DocumentReference database = Firestore.instance
          .collection("${widget.user.uid}")
          .document("Expenses");
      await database.setData({
        "DateTime": dateController.text,
        "Amount": amountController.text,
        "Context": contextController.text,
      }).then((onValue) {
        print("Data Successfully saved to cloud!");
        dateController.clear();
        amountController.clear();
        contextController.clear();
      }).catchError((e) {
        print("Error occured: $e");
      });
    } else {
      print("Form data NOT saved");
    }
  }
}
