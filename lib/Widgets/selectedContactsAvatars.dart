import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:udhari/Bloc/tripEvents.dart';
import 'package:udhari/Models/tripClass.dart';
import 'package:udhari/Utils/globals.dart';

class SelectedContactAvatars extends StatelessWidget {
  final List<ContactCardData> contactCards;
  final double height;
  final double width;
  final tripBloc;

  SelectedContactAvatars({
    @required this.contactCards,
    @required this.tripBloc,
    this.height = 80.0,
    this.width = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: contactCards.map((contact) {
          return GestureDetector(
            onTap: () {
              if (contact.isRemovable) {
                tripBloc.tripEventSink.add(
                  ToggleContactSelection(
                    contactCardHandler: contact,
                  ),
                );
              } else {
                Fluttertoast.showToast(msg: "Non removable");
              }
            },
            child: Container(
              key: ValueKey(contact.phoneNumber),
              height: this.height,
              width: this.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                        Globals.phoneToPhotoUrl(contact.phoneNumber)),
                  ),
                  SizedBox(height: 5),
                  Text(
                    // return first name only
                    contact.displayName.split(" ")[0],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
