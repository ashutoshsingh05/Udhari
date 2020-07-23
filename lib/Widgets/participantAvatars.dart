import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:udhari/Models/tripClass.dart';
import 'package:udhari/Utils/globals.dart';

class ParticipantAvatars extends StatefulWidget {
  final TripExpense tripExpense;
  final TripClass tripClass;
  final ObjectKey key;
  final double maxWidth;
  final int maxAvatars;
  ParticipantAvatars({
    this.tripClass,
    this.tripExpense,
    this.maxAvatars,
    @required this.key,
    this.maxWidth = 230,
  }) : assert(tripClass != null || tripExpense != null);

  @override
  _ParticipantAvatarsState createState() => _ParticipantAvatarsState();
}

class _ParticipantAvatarsState extends State<ParticipantAvatars> {
  final double _avatarRadius = 12.0;
  final double _avatarPadding = 3.0;
  int length = 0;
  List<String> _phoneNumbers = List<String>();
  List<String> _names = List<String>();

  @override
  void initState() {
    initialize();
    super.initState();
  }

  void initialize() {
    if (widget.tripExpense == null) {
      length = widget.tripClass.participants.length;
      for (int i = 0; i < length; i++) {
        _phoneNumbers.add(widget.tripClass.participants[i]);
      }
      _names = widget.tripClass.names;
    } else {
      length = widget.tripExpense.contributors.length;
      for (int i = 0; i < length; i++) {
        _phoneNumbers.add(widget.tripExpense.contributors[i].phoneNumber);
      }
      _names = widget.tripExpense.names;
    }
  }

  // String participantsCount() {
  //   return "${this.length} people";
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text(
          //   participantsCount(),
          //   style: Globals.smallGreyText,
          //   maxLines: 2,
          //   overflow: TextOverflow.ellipsis,
          // ),
          SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: _buildAvatars(),
            ),
          ),
        ],
      ),
      onTap: () {
        return showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text("Participants"),
                titlePadding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
                contentPadding: EdgeInsets.all(4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                children: participantsDialog(),
              );
            });
      },
    );
  }

  List<ListTile> participantsDialog() {
    List<ListTile> list = List<ListTile>();
    for (int i = 0; i < _phoneNumbers.length; i++) {
      list.add(
        ListTile(
          leading: Avatar(
            photoUrl: Globals.phoneToPhotoUrl(_phoneNumbers[i]),
            avatarPadding: 12,
            avatarRadius: 18,
          ),
          title: Text(_names[i]),
          subtitle: Text(
            _phoneNumbers[i],
            style: Globals.smallGreyText,
          ),
        ),
      );
    }
    //===========FOR SCROLL TEST=========//
    return list;
  }

  List<Widget> _buildAvatars() {
    List<Widget> avatars = List<Widget>();

    // 'a ~/ b` is equivalent to `(a/b).toInt()` but efficient
    /// Check if there is any inherent constraint on the number of
    /// avatars possible. If there isn't any, then show the max possible.
    /// Calculates and maximum number of avatars which can be
    /// fit into the card. This happens to be the ratio of width
    /// of parent widget (taken from layout builder) to the
    /// width taken by each avatar(diameter+padding on right side)
    int maxAvatarsPossible = widget.maxAvatars ??
        (widget.maxWidth ~/ (_avatarRadius * 2 + _avatarPadding));

    for (int i = 0; i < length; i++) {
      avatars.add(
        Avatar(
          // name: await Globals.getOneNameFromPhone(c.phoneNumber),
          photoUrl: Globals.phoneToPhotoUrl(_phoneNumbers[i]),
          avatarRadius: _avatarRadius,
          // maxWidth: widget.maxWidth,
          avatarPadding: _avatarPadding,
        ),
      );
    }

    int avatarLength = avatars.length;

    // If avatars are more than the max possible number of avatars
    // then remove the last avatar and add a "+x" avatar to indicate
    // remaining avatars, like seen in google photos shared albums
    if (avatarLength > maxAvatarsPossible) {
      avatars = avatars.sublist(0, maxAvatarsPossible - 1);
      avatars.add(
        CircleAvatar(
          radius: _avatarRadius,
          child: Text("+${avatarLength - avatars.length}"),
        ),
      );
    }
    return avatars;
  }
}

class Avatar extends StatelessWidget {
  // final String name;
  final String photoUrl;
  final double avatarRadius;
  // final double maxWidth;
  final double avatarPadding;
  Avatar({
    // @required this.name,
    @required this.photoUrl,
    @required this.avatarRadius,
    // @required this.maxWidth,
    @required this.avatarPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: avatarPadding),
          child: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(photoUrl),
            radius: avatarRadius,
          ),
        ),
      ],
    );
  }
}
