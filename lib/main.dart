import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udhari/Bloc/dashboardBloc.dart';
import 'package:udhari/Bloc/screenBloc.dart';
import 'package:udhari/Bloc/themeBloc.dart';
import 'package:udhari/Bloc/tripBloc.dart';
import 'package:udhari/Bloc/udhariBloc.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Utils/cloudMessaging.dart';
import 'package:udhari/Utils/firebaseCrashlytics.dart';
import 'package:udhari/Utils/globals.dart';
import 'package:udhari/Utils/handleSignIn.dart';
import 'package:udhari/Utils/notificationHandler.dart';

String fcmToken = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseCrashlytics.initialize();
  NotificationHandler notificationHandler = NotificationHandler();
  CloudMessaging cloudMessaging =
      CloudMessaging.withNotification(notificationHandler);
  Globals.pref = await SharedPreferences.getInstance();
  Globals.packageInfo = await PackageInfo.fromPlatform();
  fcmToken = await cloudMessaging.getToken();
  print("FCMToken: $fcmToken");
  // Globals.darkModeEnabled =
  //     SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
  runApp(UdhariApp());
}

class UdhariApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeBloc themeBloc = ThemeBloc();
    // Theme Bloc
    return BlocProvider(
      bloc: themeBloc,
      //User Bloc
      child: BlocProvider(
        bloc: UserBloc(fcmToken),
        // Screen Bloc
        child: BlocProvider(
          bloc: ScreenBloc(),
          //Dashboard Bloc
          child: BlocProvider(
            bloc: DashboardBloc(),
            //Udhari Bloc
            child: BlocProvider(
              bloc: UdhariBloc(),
              // Trip Bloc
              // TODO: uncomment when developing trip bloc
              // child: BlocProvider(
              // bloc: TripBloc(),
              //Split Bill Bloc
              // child: BlocProvider(
              //   bloc: BillSplitBloc(),
              child: StreamBuilder<ThemeData>(
                initialData: themeBloc.initialTheme,
                stream: themeBloc.themeStateStream,
                builder:
                    (BuildContext context, AsyncSnapshot<ThemeData> snapshot) {
                  return MaterialApp(
                    title: "Udhari",
                    theme: snapshot.data,
                    // theme: ThemeData.light(),
                    darkTheme: ThemeData.dark(),
                    home: HandleSignIn(),
                  );
                },
              ),
            ),
          ),
        ),
        // ),
        // ),
      ),
    );
  }
}

/* Dark Theme colors taken from
https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.pinterest.com%2Fpin%2F332844228709719412%2F&psig=AOvVaw24S2CosAXSwT-8gYkkhB0H&ust=1593681695639000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCNjQy67dq-oCFQAAAAAdAAAAABAI
https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.color-hex.com%2Fcolor-palette%2F5875&psig=AOvVaw0jW0rt4hB5OBuSND-_jZ4A&ust=1593682996289000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCNCugpviq-oCFQAAAAAdAAAAABAD
https://www.google.com/url?sa=i&url=https%3A%2F%2Fmedium.com%2F%40BBharathKumar%2Fdata-driven-decisions-googles-50-shades-of-blue-experiment-996f01819a97&psig=AOvVaw31MCjwerd0-NDQC8-Iq9R-&ust=1593683248567000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCLCGiJfjq-oCFQAAAAAdAAAAABAD
*/
