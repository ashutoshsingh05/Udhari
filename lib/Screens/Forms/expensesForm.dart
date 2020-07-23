import 'dart:ui';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Bloc/dashboardBloc.dart';
import 'package:udhari/Bloc/dashboardEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/expensesClass.dart';
import 'package:udhari/Utils/globals.dart';

class ExpensesForm extends StatefulWidget {
  ExpensesForm({this.expenseToEdit});
  final ExpenseClass expenseToEdit;
  @override
  _ExpensesFormState createState() => _ExpensesFormState();
}

class _ExpensesFormState extends State<ExpensesForm> {
  Color bgColor = Color(0xff231E35);
  Color appBarColor = Color(0xff641C4A);
  Color fabBgColor = Colors.white;
  Color fabFgColor = Colors.black;
  // OverlayEntry _overlayEntry;

  UserBloc userBloc;
  DashboardBloc dashboardBloc;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController dateController = TextEditingController();
  TextEditingController contextController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  FocusNode amountFocus = FocusNode();
  FocusNode contextFocus = FocusNode();

  // final format = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      dateController.text = widget.expenseToEdit.dateTime;
      contextController.text = widget.expenseToEdit.context;
      amountController.text = (widget.expenseToEdit.amount) == null
          ? ""
          : widget.expenseToEdit.amount.toString();
    }
    // _overlayEntry = OverlayEntry(
    //   builder: (BuildContext context) {
    //     return Container(
    //       color: Color.fromRGBO(0, 0, 0, 0.4),
    //       child: Center(
    //         child: CircularProgressIndicator(),
    //       ),
    //     );
    //   },
    // );
  }

  @override
  void dispose() {
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
    dashboardBloc = BlocProvider.of<DashboardBloc>(context);

    initColors(context);

    return Scaffold(
      backgroundColor: bgColor.withOpacity(0.7),
      appBar: AppBar(
        backgroundColor: appBarColor.withOpacity(0.5),
        title: Text("Expenses"),
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
                        constraints:
                            BoxConstraints(maxHeight: 80, maxWidth: 200),
                        child: TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          // autofocus: true,
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
                              return "Amount is too large!";
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
                      padding: EdgeInsets.only(top: 20, bottom: 5),
                      child: TextFormField(
                        controller: contextController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        maxLength: 120,
                        textCapitalization: TextCapitalization.sentences,
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
                          errorStyle: TextStyle(
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.backspace),
                            onPressed: () {
                              amountController.clear();
                            },
                          ),
                          icon: Icon(Icons.event_note),
                          labelText: "Context",
                        ),
                        inputFormatters: [
                          WhitelistingTextInputFormatter(
                            RegExp(
                                "[a-zA-Z0-9\$\.\(\)\@\#\%\&\-\+\,\_\=\;\"\ ]"),
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
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          // hasFloatingPlaceholder: true,
                        ),
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
        backgroundColor: fabBgColor,
        foregroundColor: fabFgColor,
        onPressed: _validateAndSave,
        child: Icon(Icons.check),
      ),
    );
  }

  void _validateAndSave() async {
    if (_formKey.currentState.validate() == true) {
      // Overlay.of(context).insert(_overlayEntry);
      _formKey.currentState.save();

      //when the doc alredy exists, it must be overwritten
      //with the given createdAt since a non null createdAt
      //means doc is being edited otherwise it would
      //result in duplicate entries on editing the cards
      String _time = widget.expenseToEdit == null
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : widget.expenseToEdit.created;

      // Convert an empty entry in dateField to dateTimeFormatStd
      // with the current time and use it everywhere
      // Otherwise just keep the previous non-empty value
      String dateTimeString = dateController.text == ""
          ? Globals.dateTimeFormat.format(DateTime.now())
          : dateController.text;

      // Converting dateTimeString format to
      // DateTime(and later to epoch time)format for enabling
      // comparison of values during database query.
      // This helps show chronologically sorted expenses.
      DateTime idDateTime = Globals.dateTimeFormat.parse(dateTimeString);

      int monthNumber = widget.expenseToEdit == null
          ? Globals.dateTimeFormat.parse(dateTimeString).month
          : widget.expenseToEdit.month;

      int yearNumber = widget.expenseToEdit == null
          ? Globals.dateTimeFormat.parse(dateTimeString).year
          : widget.expenseToEdit.year;

      ExpenseClass expenses = ExpenseClass(
        participant: userBloc.phoneNumber,
        photoUrl: userBloc.photoUrl,
        dateTime: dateTimeString,
        amount: double.parse(amountController.text),
        context: contextController.text,
        created: _time,
        month: monthNumber,
        year: yearNumber,
        id: idDateTime.millisecondsSinceEpoch.toString(),
      );

      if (widget.expenseToEdit == null) {
        dashboardBloc.dashboardEventSink.add(AddExpenseRecord(
          expense: expenses,
        ));
      } else {
        // Assigned the document ID of previous doc (doc being editing) to
        // sink to enable successful overriding of the document at
        // the given document ID
        dashboardBloc.dashboardEventSink.add(UpdateExpenseRecord(
          expense: expenses,
          docID: widget.expenseToEdit.documentID,
        ));
      }

      Navigator.of(context).pop();
    } else {
      print("Form data NOT saved");
    }
  }
}
