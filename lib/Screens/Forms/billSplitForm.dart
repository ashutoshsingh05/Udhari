import 'dart:ui';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:native_contact_picker/native_contact_picker.dart';
import 'package:udhari/Bloc/billSplitBloc.dart';
import 'package:udhari/Bloc/billSplitEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/billClass.dart';
import 'package:udhari/Models/contactsProvider.dart';
import 'package:udhari/Utils/globals.dart';

@deprecated
class BillsplitForm extends StatefulWidget {
  final BillClass billToEdit;

  BillsplitForm({this.billToEdit});

  @override
  _BillsplitFormState createState() => _BillsplitFormState();
}

class _BillsplitFormState extends State<BillsplitForm> {
  UserBloc userBloc;
  BillSplitBloc billSplitBloc;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FocusNode totalAmountFocus = FocusNode();
  FocusNode titleFocus = FocusNode();

  TextEditingController _dateController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _totalAmountController = TextEditingController();
  List<BillParticipants> _billParticipants = List<BillParticipants>();

  @override
  void initState() {
    super.initState();
    if (widget.billToEdit != null) {
      _assignValues();
    } else {
      // initialize creator text fields because a bill
      _billParticipants.add(BillParticipants(
        key: ValueKey(Globals.phoneNumber),
        name: Globals.pref.getString(Globals.namePref),
        phoneNumber: Globals.phoneNumber,
      ));
    }
  }

  void _assignValues() {
    _dateController.text = widget.billToEdit.dateTime;
    _titleController.text = widget.billToEdit.title;
    _totalAmountController.text = widget.billToEdit.totalAmount.toString();
    _billParticipants = List<BillParticipants>();
    widget.billToEdit.contributors.forEach((k, v) {
      _billParticipants.add(BillParticipants(
        key: ValueKey(v.phoneNumber),
        name: v.name,
        phoneNumber: v.phoneNumber,
      ));
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _titleController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    billSplitBloc = BlocProvider.of<BillSplitBloc>(context);

    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.6),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.withOpacity(0.5),
        title: Text("Create Bill"),
      ),
      body: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 5.0,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            // autovalidate: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 80, maxWidth: 160),
                  child: TextFormField(
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    enableInteractiveSelection: false,
                    textInputAction: TextInputAction.next,
                    focusNode: totalAmountFocus,
                    maxLines: 1,
                    //TODO: complete focus shift
                    onEditingComplete: () {
                      // FocusScope.of(context).requestFocus(contextFocus);
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
                          _totalAmountController.clear();
                        },
                      ),
                      icon: Icon(Icons.attach_money),
                      labelText: "Total Bill",
                    ),
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp("[0-9\.]")),
                    ],
                  ),
                ),
                //==============================//
                TextFormField(
                  controller: _titleController,
                  keyboardType: TextInputType.text,
                  maxLength: 80,
                  autocorrect: true,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  focusNode: titleFocus,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Title cannot be empty!";
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
                        _titleController.clear();
                      },
                    ),
                    icon: Icon(Icons.assignment),
                    labelText: "What's this for?",
                  ),
                  inputFormatters: [
                    WhitelistingTextInputFormatter(
                      RegExp(
                        "[a-zA-Z0-9\$\.\(\)\@\#\%\&\-\+\,\_\=\;\"\ ]",
                      ),
                    ),
                  ],
                ),
                //========================//
                participants(),
                //========================//
                Container(
                  // padding: EdgeInsets.symmetric(vertical: 20),
                  constraints: BoxConstraints(
                    maxHeight: 160,
                    minHeight: 120,
                  ),
                  child: DateTimeField(
                    format: Globals.dateTimeFormat,
                    controller: _dateController,
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
                      hasFloatingPlaceholder: true,
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _validateAndSave,
        child: Icon(Icons.check),
      ),
    );
  }

  void _validateAndSave() {
    if (_formKey.currentState.validate() == true) {
      _formKey.currentState.save();
      createBill();
    } else {
      print("Form data NOT saved");
    }
  }

  void createBill() {
    double _totalAmount;
    String _title;
    String _dateTime;
    String _firstParty;
    String _id;
    String _createdAt;
    bool _isSplit;
    bool _isArchived;
    Map<String, dynamic> _contributors = Map<String, dynamic>();
    List<Contributor> _contributorsList = List<Contributor>();
    List<String> _participants = List<String>();

    _totalAmount = double.parse(_totalAmountController.text);
    _title = _titleController.text;
    _dateTime = _dateController.text == ""
        ? Globals.dateTimeFormat.format(DateTime.now())
        : _dateController.text;
    _createdAt = widget.billToEdit == null
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : widget.billToEdit.createdAt;
    _firstParty = widget.billToEdit == null
        ? userBloc.phoneNumber
        : widget.billToEdit.firstParty;

    String _dateTimeString = _dateController.text == ""
        ? Globals.dateTimeFormat.format(DateTime.now())
        : _dateController.text;
    DateTime idDateTime = Globals.dateTimeFormat.parse(_dateTimeString);
    _id = idDateTime.millisecondsSinceEpoch.toString();

    if (widget.billToEdit == null) {
      _isSplit = false;
      _isArchived = false;
    } else {
      _isSplit = false;
      _isArchived = false;
    }

    _billParticipants.forEach((BillParticipants p) {
      _participants.add(p.phoneNumber);
      _contributorsList.add(
        Contributor(
          amountContributed: _totalAmount / _billParticipants.length,
          isDeleted: false,
          maxShare: _totalAmount / _billParticipants.length,
          name: p.name,
          phoneNumber: p.phoneNumber,
          photoUrl: Globals.phoneToPhotoUrl(p.phoneNumber),
        ),
      );
    });

    // var _contributor = {for (var v in _contributorsList) v.phoneNumber: v};

    _contributors = Map.fromIterable(
      _contributorsList,
      key: (val) {
        return val.phoneNumber;
      },
      value: (val) {
        Contributor c = val;
        return Contributor(
          amountContributed: c.amountContributed,
          isDeleted: c.isDeleted,
          maxShare: c.maxShare,
          name: c.name,
          phoneNumber: c.phoneNumber,
          photoUrl: c.photoUrl,
        );
        // return {
        //   "phoneNumber": c.phoneNumber,
        //   "name": c.name,
        //   "amountContributed": c.amountContributed,
        //   "photoUrl": c.photoUrl,
        //   "isDeleted": c.isDeleted,
        //   "maxShare": c.maxShare,
        // };
      },
    );
    print(_contributors);

    _contributors = _contributors.map(
        (k, v) => MapEntry<String, Contributor>(k, Contributor.fromJson(v)));
    print(_contributors);

    // Map.from(snapshot.data["contributors"]).map(
    //     (k, v) => MapEntry<String, Contributor>(k, Contributor.fromJson(v)));

    BillClass bill = BillClass(
      contributors: _contributors,
      createdAt: _createdAt,
      dateTime: _dateTime,
      firstParty: _firstParty,
      id: _id,
      isArchived: _isArchived,
      isSplit: _isSplit,
      participants: _participants,
      title: _title,
      totalAmount: _totalAmount,
    );
    // print("Bill: ${bill}");

    if (widget.billToEdit == null) {
      billSplitBloc.billsEventSink.add(CreateNewBill(
        bill: bill,
      ));
      // Go back to Udhari page
      Navigator.of(context).pop();
    } else {
      // Assigned the document ID of previous doc (doc being editing) to
      // sink to enable successful overriding of the document at
      // the given document ID
      billSplitBloc.billsEventSink.add(UpdateBillEvent(
        bill: bill,
        docID: widget.billToEdit.documentID,
      ));
      // Go back to Udhari page
      Navigator.of(context).pop();
    }
  }

  Widget participants() {
    List<Widget> participantChips = List<Widget>();
    for (int i = 0; i < _billParticipants.length; i++) {
      BillParticipants participant = _billParticipants[i];

      bool isSelf;
      if (participant.phoneNumber == userBloc.phoneNumber) {
        isSelf = true;
      } else {
        isSelf = false;
      }

      participantChips.add(
        Chip(
          backgroundColor: Colors.lightBlue,
          label: isSelf ? Text("You") : Text("${participant.name}"),
          avatar: CircleAvatar(
            backgroundImage: NetworkImage(
              Globals.phoneToPhotoUrl(participant.phoneNumber),
            ),
          ),
          deleteButtonTooltipMessage: "Remove",
          onDeleted: () {
            setState(() {
              if (!isSelf) {
                _billParticipants.remove(participant);
              } else {
                print("Cannot remove YOU");
              }
            });
          },
        ),
      );
    }

    // the trailing 'plus' button to add chips
    participantChips.add(
      IconButton(
        icon: Icon(Icons.add_circle_outline),
        onPressed: addParticipant,
      ),
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      alignment: WrapAlignment.start,
      spacing: 12,
      children: participantChips,
    );
  }

  void addParticipant() async {
    final NativeContactPicker _contactPicker = new NativeContactPicker();
    Contact contact = await _contactPicker.selectContact();
    if (contact != null) {
      if (_billParticipants.contains(
        BillParticipants(
          key: ValueKey(ContactsProvider.stripPhoneNumber(contact.phoneNumber)),
          name: contact.fullName,
          phoneNumber: ContactsProvider.stripPhoneNumber(contact.phoneNumber),
        ),
      )) {
        print("Participant already exists");

        Fluttertoast.showToast(
          msg: "Already exists",
          backgroundColor: Colors.grey,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        setState(() {
          _billParticipants.add(BillParticipants(
            key: ValueKey(
                ContactsProvider.stripPhoneNumber(contact.phoneNumber)),
            name: contact.fullName,
            phoneNumber: ContactsProvider.stripPhoneNumber(contact.phoneNumber),
          ));
        });
        print(
            "Added: ${contact.fullName} : ${ContactsProvider.stripPhoneNumber(contact.phoneNumber)}");
      }
    } else {
      print("No contact selected");
    }
  }
}

class BillParticipants {
  String name;
  String phoneNumber;
  Key key;

  BillParticipants({
    @required this.name,
    @required this.phoneNumber,
    @required this.key,
  });

  @override
  bool operator ==(Object other) {
    if (other is BillParticipants &&
        (this.phoneNumber == other.phoneNumber) &&
        (this.name == other.name))
      return true;
    else
      return false;
  }

  @override
  int get hashCode => this.name.hashCode ^ this.phoneNumber.hashCode;
}
