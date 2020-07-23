import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:udhari/Bloc/billSplitBloc.dart';
import 'package:udhari/Bloc/userBloc.dart';
import 'package:udhari/Models/billClass.dart';
import 'package:udhari/Screens/Forms/billSplitForm.dart';
import 'package:udhari/Widgets/cardBanner.dart';
import 'package:udhari/Widgets/billCard.dart';
import 'package:udhari/Widgets/transparentAppBar.dart';

@deprecated
class BillSplit extends StatefulWidget {
  @override
  _BillSplitState createState() => _BillSplitState();
}

class _BillSplitState extends State<BillSplit>
    with SingleTickerProviderStateMixin {
  AnimationController _controllerList;

  UserBloc userBloc;
  BillSplitBloc billSplitBloc;

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

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    billSplitBloc = BlocProvider.of<BillSplitBloc>(context);

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
            TransparentAppBar(),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<List<BillClass>>(
                initialData: billSplitBloc.getBillsList,
                stream: billSplitBloc.billsListStream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<BillClass>> snapshot) {
                  return GridView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: snapshot.data.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      BillClass bill = snapshot.data[index];
                      return CardBanner(
                        message: "Archived",
                        showBanner: bill.isArchived,
                        child: BillCard(
                          bill: bill,
                          key: ObjectKey(bill),
                          onTap: () {
                            if (bill.isArchived) {
                              print("Editing not allowed");
                              Fluttertoast.showToast(
                                msg: "Bill is archived",
                                backgroundColor: Colors.grey,
                                gravity: ToastGravity.BOTTOM,
                              );
                            } else {
                              _editCard(bill: bill);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editCard({
    @required BillClass bill,
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
            child: BillsplitForm(
              billToEdit: bill,
            ),
          );
        },
      ),
    );
  }
}
