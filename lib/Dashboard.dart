import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unicorndial/unicorndial.dart';

class Dashboard extends StatefulWidget {
  Dashboard({this.firestore, this.uuid});

  final firestore, uuid;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List childButtons = List<UnicornButton>();
  List bottomNaviagtionBarList = List<BottomNavigationBarItem>();

  @override
  void initState() {
    super.initState();
    initializeUnicornButtons();
    initializeBottomNavigationBar();
  }

  void initializeUnicornButtons() {
    childButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Single Udhari",
        currentButton: FloatingActionButton(
          heroTag: "Single",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.person_add),
          onPressed: () {},
        ),
      ),
    );

    childButtons.add(
      UnicornButton(
        currentButton: FloatingActionButton(
          heroTag: "airplane",
          backgroundColor: Colors.greenAccent,
          mini: true,
          child: Icon(Icons.airplanemode_active),
        ),
      ),
    );

    childButtons.add(
      UnicornButton(
        currentButton: FloatingActionButton(
          heroTag: "directions",
          backgroundColor: Colors.blueAccent,
          mini: true,
          child: Icon(Icons.directions_car),
        ),
      ),
    );
  }

  void initializeBottomNavigationBar() {
    bottomNaviagtionBarList.add(
      BottomNavigationBarItem(
        title: Text("Group"),
        icon: Icon(Icons.people),
        activeIcon: Icon(Icons.people_outline),
      ),
    );
    bottomNaviagtionBarList.add(
      BottomNavigationBarItem(
        title: Text("Person"),
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: null,
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNaviagtionBarList,
      ),
      floatingActionButton: UnicornDialer(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
        // backgroundColor: Colors.transparent,
        parentButtonBackground: Colors.redAccent,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.add),
        childButtons: childButtons,
        // hasNotch: true,
      ),
    );
  }
}
