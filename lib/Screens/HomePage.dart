import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:udhari_2/Screens/Forms/ExpensesForm.dart';
import 'package:udhari_2/Screens/Forms/NormalUdhariForm.dart';
import 'package:udhari_2/Screens/Forms/TripsForm.dart';
import 'package:udhari_2/Screens/HomePageScreens/Dashboard.dart';
import 'package:udhari_2/Utils/ScreenHandler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
class HomePage extends StatefulWidget {
  HomePage({@required this.user});

  final FirebaseUser user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScreenHandler screens;

  int _iconIndex = 0;

  @override
  void initState() {
    super.initState();
    screens = ScreenHandler(Dashboard(user: widget.user), widget.user);
  }

  @override
  void dispose() {
    super.dispose();
    screens.screenController.close();
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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        currentIndex: _iconIndex,
        onTap: _handleBottomBarOnTap,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            title: Text("Home"),
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            title: Text("Udhari"),
            icon: Icon(Icons.person),
          ),
          BottomNavigationBarItem(
            title: Text("Trips"),
            icon: Icon(Icons.group),
          ),
          BottomNavigationBarItem(
            title: Text("History"),
            icon: Icon(Icons.history),
          ),
        ],
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
                    fullscreenDialog: true,
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
                  fullscreenDialog: true,
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
                  fullscreenDialog: true,
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

  _handleBottomBarOnTap(int index) {
    screens.setScreen = index;
    setState(() {
      _iconIndex = index;
    });
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    print("Logged out");
  }
}
