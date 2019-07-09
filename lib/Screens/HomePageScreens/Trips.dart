import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Trips extends StatefulWidget {
  Trips({@required this.user});

  final FirebaseUser user;

  @override
  _TripsState createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Colors.blueAccent,
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.transparent.withOpacity(0),
              elevation: 0,
              leading: Padding(
                padding: EdgeInsets.all(5),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    widget.user.photoUrl ??
                        "https://api.adorable.io/avatars/100/${widget.user.phoneNumber}.png",
                  ),
                ),
              ),
              title: Text(widget.user.displayName ?? widget.user.phoneNumber),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    // _signOut();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
