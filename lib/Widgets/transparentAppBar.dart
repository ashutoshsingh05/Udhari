import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Bloc/themeBloc.dart';
import 'package:udhari/Bloc/themeEvents.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/feedback.dart';
import 'package:udhari/Utils/globals.dart';

class TransparentAppBar extends StatefulWidget {
  final IconButton iconButton;
  TransparentAppBar({this.iconButton});
  @override
  _TransparentAppBarState createState() => _TransparentAppBarState();
}

class _TransparentAppBarState extends State<TransparentAppBar> {
  UserBloc userBloc;
  ThemeBloc themeBloc;
  TextEditingController feedbackTitle = TextEditingController();
  TextEditingController feedbackMessage = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void dispose() {
    feedbackTitle.dispose();
    feedbackMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    themeBloc = BlocProvider.of<ThemeBloc>(context);

    return AppBar(
      backgroundColor: Colors.transparent.withOpacity(0),
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(5),
        child: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            userBloc.photoUrl,
          ),
        ),
      ),
      title: Text(userBloc.name),
      actions: <Widget>[
        widget.iconButton ?? Container(),
        PopupMenuButton<int>(
          icon: Icon(Icons.more_vert),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: Text("About"),
                value: 1,
              ),
              PopupMenuItem(
                child: Text("Feedback"),
                value: 2,
              ),
              PopupMenuItem(
                child: Text("Switch Theme"),
                value: 3,
              ),
              PopupMenuItem(
                child: Text("Logout"),
                value: 4,
              ),
            ];
          },
          onSelected: (int val) {
            print("POPup button $val");
            switch (val) {
              case 1:
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  useSafeArea: false,
                  child: AlertDialog(
                    title: Text("About Udhari"),
                    scrollable: true,
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Table(
                          children: [
                            TableRow(
                              children: [
                                Text(
                                  "Version",
                                  style: Globals.mediumGreyText,
                                ),
                                Text(
                                  "${Globals.packageInfo.version}",
                                  style: Globals.mediumGreyText,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Text(
                                  "Build no.",
                                  style: Globals.mediumGreyText,
                                ),
                                Text(
                                  "${Globals.packageInfo.buildNumber}",
                                  style: Globals.mediumGreyText,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
                        Text(_about),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Ok"),
                      )
                    ],
                  ),
                );
                break;
              case 2:
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  child: AlertDialog(
                    title: Text("Feedback"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    content: Form(
                      key: _key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: feedbackTitle,
                            inputFormatters: [
                              BlacklistingTextInputFormatter(RegExp("\\\\"))
                            ],
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return "Cannot be empty!";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              labelText: "Title",
                            ),
                          ),
                          TextFormField(
                            controller: feedbackMessage,
                            maxLines: null,
                            inputFormatters: [
                              BlacklistingTextInputFormatter(RegExp("\\\\"))
                            ],
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return "Cannot be empty!";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              labelText: "Message/feedback",
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel"),
                      ),
                      FlatButton(
                        onPressed: () async {
                          if (_key.currentState.validate()) {
                            AppFeedback feedback = AppFeedback(
                              title: feedbackTitle.text,
                              message: feedbackMessage.text,
                              dateTime: DateTime.now(),
                              phoneNumber: userBloc.phoneNumber,
                            );
                            int result =
                                await userBloc.provideFeedback(feedback);
                            // print("Result ${result}");
                            if (result == 0) {
                              Navigator.of(context).pop();
                              Fluttertoast.showToast(msg: "Feedback sent");
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "Error sending feedback. Please check internet connection");
                            }
                          } else {
                            print("Incomplete form");
                            Fluttertoast.showToast(msg: "Incomplete details");
                          }
                        },
                        child: Text("Send"),
                      ),
                    ],
                  ),
                );
                break;
              case 3:
                themeBloc.themeEventSink.add(SwitchTheme(context));
                break;
              case 4:
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text("Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel"),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          userBloc.logOut();
                        },
                        child: Text("Logout"),
                      ),
                    ],
                  ),
                );
                break;
              default:
                {
                  print(
                      "Unknown option selected from tranparent app bar popupmenu");
                }
            }
          },
        ),
      ],
    );
  }
}

const String _about =
    "Udhari is an intelligent money management solution. Built to provide our valuable users effective means to manage their daily expenses and udhari. The app targets millennials, especially those pursuing their higher education and living in hostels and dormitories. In such an environment, it's common for students to borrow money from their classmates and later forget to repay them. We help our users overcome this problem of forgetfulness by keeping a track of all their expenses and reminding them of their pending debts.";
