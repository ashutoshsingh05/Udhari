import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:udhari_2/Screens/Forms/ExpensesForm.dart';
import 'package:udhari_2/Screens/Forms/NormalUdhariForm.dart';
import 'package:udhari_2/Screens/Forms/TripsForm.dart';
import 'package:udhari_2/Screens/HomePages/Dashboard.dart';
import 'package:udhari_2/Screens/HomePages/Trips.dart';
import 'package:udhari_2/Screens/HomePages/History.dart';
import 'package:udhari_2/Screens/HomePages/NormalUdhari.dart';
import 'package:udhari_2/Utils/ScreenHandler.dart';
import 'package:udhari_2/Utils/IconHandler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:udhari_2/Widgets/Layout.dart';
import 'package:udhari_2/Widgets/FabWithIcons.dart';

class HomePage extends StatefulWidget {
  HomePage({@required this.user});

  final FirebaseUser user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScreenHandler screens;
  IconHandler homeIcon =
      IconHandler(Icon(Icons.home, color: Colors.blueAccent));
  IconHandler personIcon = IconHandler(Icon(Icons.person));
  IconHandler peopleIcon = IconHandler(Icon(Icons.group));
  IconHandler historyIcon = IconHandler(Icon(Icons.history));

  @override
  void initState() {
    super.initState();
    screens = ScreenHandler(Dashboard(user: widget.user));
  }

  @override
  void dispose() {
    super.dispose();
    screens.screenController.close();
    homeIcon.iconController.close();
    personIcon.iconController.close();
    peopleIcon.iconController.close();
    historyIcon.iconController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(7),
          child: CircleAvatar(
            backgroundImage: NetworkImage("${widget.user.photoUrl}"),
          ),
        ),
        title: Text(widget.user.displayName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: screens.screenStream,
        initialData: Dashboard(
          user: widget.user,
        ),
        builder: (BuildContext context, snapshot) {
          return snapshot.data;
        },
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 5,
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: StreamBuilder(
                stream: homeIcon.iconStream,
                initialData: Container(),
                builder: (BuildContext context, snapshot) {
                  return snapshot.data;
                },
              ),
              onPressed: () {
                screens.screenSink.add(Dashboard(user: widget.user));
                homeIcon.changeIcon(Icon(Icons.home, color: Colors.blueAccent));
                personIcon.changeIcon(Icon(Icons.person, color: Colors.black));
                peopleIcon.changeIcon(Icon(Icons.people, color: Colors.black));
                historyIcon
                    .changeIcon(Icon(Icons.history, color: Colors.black));
              },
            ),
            IconButton(
              icon: StreamBuilder(
                stream: personIcon.iconStream,
                initialData: Container(),
                builder: (BuildContext context, snapshot) {
                  return snapshot.data;
                },
              ),
              onPressed: () {
                screens.screenSink.add(NormalUdhari(user: widget.user));
                homeIcon.changeIcon(Icon(Icons.home, color: Colors.black));
                personIcon
                    .changeIcon(Icon(Icons.person, color: Colors.blueAccent));
                peopleIcon.changeIcon(Icon(Icons.people, color: Colors.black));
                historyIcon
                    .changeIcon(Icon(Icons.history, color: Colors.black));
              },
            ),
            // SizedBox(
            //   width: 50,
            // ),
            IconButton(
              icon: StreamBuilder(
                stream: peopleIcon.iconStream,
                initialData: Container(),
                builder: (BuildContext context, snapshot) {
                  return snapshot.data;
                },
              ),
              onPressed: () {
                screens.screenSink.add(Trips(user: widget.user));
                homeIcon.changeIcon(Icon(Icons.home, color: Colors.black));
                personIcon.changeIcon(Icon(Icons.person, color: Colors.black));
                peopleIcon
                    .changeIcon(Icon(Icons.people, color: Colors.blueAccent));
                historyIcon
                    .changeIcon(Icon(Icons.history, color: Colors.black));
              },
            ),
            IconButton(
              icon: StreamBuilder(
                stream: historyIcon.iconStream,
                initialData: Container(),
                builder: (BuildContext context, snapshot) {
                  return snapshot.data;
                },
              ),
              onPressed: () {
                screens.screenSink.add(History(user: widget.user));
                homeIcon.changeIcon(Icon(Icons.home, color: Colors.black));
                personIcon.changeIcon(Icon(Icons.person, color: Colors.black));
                peopleIcon.changeIcon(Icon(Icons.people, color: Colors.black));
                historyIcon
                    .changeIcon(Icon(Icons.history, color: Colors.blueAccent));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        tooltip: 'MENU',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 7.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.attach_money),
              backgroundColor: Colors.red,
              label: 'Expenses',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ExpensesForm(user: widget.user);
                    },
                  ),
                );
              }),
          SpeedDialChild(
            child: Icon(Icons.person_add),
            backgroundColor: Colors.blue,
            label: 'Udhari',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return NormalUdhariForm(user: widget.user);
                  },
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.group_add),
            backgroundColor: Colors.green,
            label: 'Trip',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return TripsForm(user: widget.user);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    print("Logged out");
  }
}
