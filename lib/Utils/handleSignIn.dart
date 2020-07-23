import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Bloc/dashboardBloc.dart';
import 'package:udhari/Bloc/tripBloc.dart';
import 'package:udhari/Bloc/udhariBloc.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Screens/homePage.dart';
import 'package:udhari/Screens/intro.dart';
import 'package:udhari/Screens/splashScreen.dart';
import 'package:udhari/Utils/globals.dart';

class HandleSignIn extends StatefulWidget {
  @override
  _HandleSignInState createState() => _HandleSignInState();
}

class _HandleSignInState extends State<HandleSignIn> {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none) {
          return SplashScreen();
        } else {
          if (snapshot.hasData) {
            UserBloc userBloc = BlocProvider.of<UserBloc>(context);

            // print("Restored Name:  ${Globals.pref.getString(Globals.namePref)}");

            // If for some reasons, the name fetch operation fails,
            // show "Udhari" instead person name
            if (userBloc.name == null)
              userBloc.setName =
                  Globals.pref.getString(Globals.namePref) ?? "Udhari";

            // print("Bloc in signInHandle before setter ${userBloc.phoneNumber}");
            userBloc.setFirebaseUserOnStartUp = snapshot.data;
            // print("Bloc in signInHandle after setter ${userBloc.phoneNumber}");

            BlocProvider.of<DashboardBloc>(context).setUserBloc = userBloc;
            BlocProvider.of<UdhariBloc>(context).setUserBloc = userBloc;
            //TODO: uncomment when developing trip
            // BlocProvider.of<TripBloc>(context).setUserBloc = userBloc;
            // BlocProvider.of<BillSplitBloc>(context).setUserBloc = userBloc;

            //function to update last seen and initialize
            // user data inside UserBloc

            return HomePage();
          }
          return new Intro();
        }
      },
    );
  }
}
