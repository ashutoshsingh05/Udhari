import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:udhari/Models/contactsProvider.dart';
import 'package:udhari/Utils/customTextController.dart';
import 'package:udhari/Utils/globals.dart';

class AmountSlider extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final double amount;
  final CustomTextController textController;
  final bool isSelf;
  final void Function() onButtonPressed;
  final int index;

  AmountSlider({
    @required this.textController,
    @required this.isSelf,
    @required this.onButtonPressed,
    @required this.index,
    this.amount = 0.0,
    this.name,
    this.phoneNumber,
  });

  @override
  _AmountSliderState createState() => _AmountSliderState();
}

class _AmountSliderState extends State<AmountSlider> {
  ContactsProvider _contactsProvider = ContactsProvider();
  double sliderVal = 5;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
            // if the participant is the creator himself,
            // he should not be able to remove himself
            // since he must be the participant of the bill
            enabled: !widget.isSelf,
            // focusNode: personNameFocus,
            controller: widget.textController,
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
              // show remove button only if the user
              // is not the creator since the creator is
              // not allowed to remove himself
              // OR
              // do not show remove IconButton for the first
              // 3 text fields
              suffixIcon: (widget.isSelf || widget.index <= 2)
                  ? null
                  : IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: widget.onButtonPressed,
                    ),
            ),
          ),
          suggestionsCallback: (pattern) async {
            if (pattern.length >= 2)
              return await ContactsProvider.getSimilarNameSuggestion(pattern);
            else
              return [];
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: (suggestion) async {
            widget.textController.text = suggestion;
            print("Selected: $suggestion");
            widget.textController.phoneNumber =
                await Globals.getOneNameFromPhone(suggestion);
            print("Selected Phone: ${widget.textController.phoneNumber}");
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
        Slider.adaptive(
          onChanged: (double value) {},
          value: sliderVal,
          divisions: 100,
          label: "Money",
          max: 200,
          min: 1,
          onChangeStart: (double val) {
            setState(() {
              sliderVal = val;
            });
          },
          onChangeEnd: (double val) {
            setState(() {
              sliderVal = val;
            });
          },
        ),
      ],
    );
  }
}
