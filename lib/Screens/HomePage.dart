import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udhari_2/Screens/HomePages/Trips.dart';
import 'package:udhari_2/Screens/HomePages/History.dart';
import 'package:udhari_2/Screens/HomePages/NormalUdhari.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:udhari_2/Utils/HomePage/IconHandler.dart';
import 'package:udhari_2/Utils/HomePage/ScreenHandler.dart';
import 'package:udhari_2/Utils/HomePage/BottomBarIndexHandler.dart';
import 'package:udhari_2/Widgets/Layout.dart';
import 'package:udhari_2/Widgets/FabWithIcons.dart';
import 'package:udhari_2/Screens/HomePages/Dashboard.dart';

class HomePage extends StatefulWidget {
  HomePage({this.firestore, this.uuid});

  final firestore, uuid;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List childButtons = List<UnicornButton>();

  // List bottomNaviagtionBarList = List<BottomAppBarItemsItem>();
  IconHandler udhariIcon = IconHandler(Icon(Icons.person_outline));
  IconHandler moneyIcon = IconHandler(Icon(Icons.attach_money));
  IconHandler groupIcon = IconHandler(Icon(Icons.people_outline));

  ScreenHandler screens = ScreenHandler(Icon(Icons.person_outline));
  BottomBarIndexHandler bottomBarIndexHandler = BottomBarIndexHandler(2);

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeUnicornButtons();
    // initializeBottomAppBarItems();
  }

  @override
  void dispose() {
    udhariIcon.iconController.close();
    moneyIcon.iconController.close();
    groupIcon.iconController.close();
    super.dispose();
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
          child: Icon(Icons.group_add),
          onPressed: () {},
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
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Udhari"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder(
        stream: screens.screenStream,
        initialData: Container(),
        builder: (BuildContext context, snapshot) {
          return snapshot.data;
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                screens.screenSink.add(Dashboard());
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                screens.screenSink.add(NormalUdhari());
              },
            ),
            SizedBox(
              width: 50,
            ),
            IconButton(
              icon: Icon(Icons.people),
              onPressed: () {
                screens.screenSink.add(Trips());
              },
            ),
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                screens.screenSink.add(History());
              },
            ),
          ],
        ),
      ),

      // FAB with Notched bottom appbar taken from https://github.com/bizz84/bottom_bar_fab_flutter
      // by Andrea Bizzotto

      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFab(BuildContext context) {
    final icons = [Icons.person_add, Icons.group_add, Icons.drive_eta];
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy - icons.length * 35.0),
          child: FabWithIcons(
            icons: icons,
            onIconTapped: (_) {
              print("FAB index: $_");
            },
          ),
        );
      },
      child: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add',
        child: Icon(Icons.add),
        elevation: 2.0,
      ),
    );
  }
}
