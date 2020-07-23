import 'package:flutter/material.dart';
import 'package:udhari/Utils/globals.dart';

/// Shows a card with contact details in it.
/// Also used for showing selected and unselected
/// contacts.
class ContactCard extends StatelessWidget {
  final String phoneNumber;
  final String name;
  final void Function() onTap;
  final bool isSelected;

  ContactCard({
    @required this.name,
    @required this.phoneNumber,
    @required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            Globals.phoneToPhotoUrl(this.phoneNumber),
          ),
        ),
        title: Text(name),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(phoneNumber),
          ],
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Colors.green,
              )
            : null,
        onTap: this.onTap,
        // onTap: () {
        //   tripBloc.tripEventSink.add(
        //     ToggleContactSelection(
        //       contactCard: snapshot.data[index],
        //     ),
        //   );
        // },
      ),
    );
  }
}
