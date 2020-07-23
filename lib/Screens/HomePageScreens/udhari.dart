import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Models/udhariClass.dart';
import 'package:udhari/Screens/Forms/udhariForm.dart';
import 'package:udhari/Bloc/udhariBloc.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Widgets/transparentAppBar.dart';
import 'package:udhari/Widgets/udhariTile.dart';

class Udhari extends StatefulWidget {
  @override
  _UdhariState createState() => _UdhariState();
}

class _UdhariState extends State<Udhari> with SingleTickerProviderStateMixin {
  Color bgSecondaryColor = Colors.blue;

  AnimationController _controllerList;
  UserBloc userBloc;
  UdhariBloc udhariBloc;

  @override
  void initState() {
    super.initState();

    _controllerList = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controllerList.forward();
  }

  @override
  void dispose() {
    _controllerList.dispose();
    super.dispose();
  }

  void initColors(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      bgSecondaryColor = Colors.blueAccent;
    } else {
      bgSecondaryColor = Color(0xff35374C);
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    udhariBloc = BlocProvider.of<UdhariBloc>(context);
    initColors(context);

    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            bgSecondaryColor,
            Colors.black,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TransparentAppBar(),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder<List<UdhariClass>>(
                  initialData: udhariBloc.getUdhariList,
                  stream: udhariBloc.udhariListStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<UdhariClass>> snapshot) {
                    return SingleChildScrollView(
                      child: Column(
                        children: snapshot.data.map(
                          (UdhariClass udhari) {
                            return ScaleTransition(
                              scale: CurvedAnimation(
                                curve: Curves.elasticOut,
                                parent: _controllerList,
                              ),
                              child: UdhariTile(
                                key: ObjectKey(udhari),
                                udhari: udhari,
                                onTap: () {
                                  if (udhari.isEditable) {
                                    _editCard(udhari: udhari);
                                  } else {
                                    // Only first party is
                                    // allowed to edit records
                                    print("Editing not allowed");
                                    Fluttertoast.showToast(
                                      msg: "Cannot edit",
                                      backgroundColor: Colors.grey,
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editCard({
    @required UdhariClass udhari,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, animation, secondaryAnimation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0),
              end: Offset.zero,
            ).animate(animation),
            child: UdhariForm(
              udhariToEdit: udhari,
            ),
          );
        },
      ),
    );
  }
}
