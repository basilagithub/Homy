import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/models/shoppingCart.dart';
import 'package:home_order_app/screens/buildNewCart.dart';
import 'package:home_order_app/screens/tabs_screen.dart';
import 'package:provider/provider.dart';

class Cardwidget extends StatelessWidget {
  final String label;
  final Function goCartFunc;
  const Cardwidget({
    super.key,
    required this.label,
    required this.goCartFunc,
  });

  @override
  Widget build(BuildContext) {
    return InkWell(
      onTap: () {
        goCartFunc();
      },
      child: Card(
          elevation: 8,
          color: Colors.amber.shade100,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40.0),
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          )),
    );
  }
}

class listcartsWidget extends StatefulWidget {
  Locale? _locale;
  String userId;
  listcartsWidget(Locale? this._locale, this.userId, {super.key});

  @override
  State<listcartsWidget> createState() => _listcartsWidgetState();
}

class _listcartsWidgetState extends State<listcartsWidget> {
  final _firestore = FirebaseFirestore.instance;

  goCartList(BuildContext context, shoppingCartId, shoppingCartName) {
    //set provider
    print('----beforeProvider $shoppingCartName');
    print(Provider.of<shoppingCart>(context, listen: false).shoppingCartName);
    Provider.of<shoppingCart>(context, listen: false).setShoppingCart(
        shoppingCartId: shoppingCartId, shoppingCartName: shoppingCartName);
    print(
        '----afterProvider  ${Provider.of<shoppingCart>(context, listen: false).shoppingCartId}');
    print(Provider.of<shoppingCart>(context, listen: false).shoppingCartName);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => TabsScreen(widget._locale)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(children: <Widget>[
          Expanded(
            child: Column(children: [
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: StreamBuilder(
                    stream: widget.userId != null
                        ? _firestore
                            .collection('user')
                            .doc(widget.userId)
                            .collection('userShoppinglists')
                            .snapshots()
                        : null,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }
                      if (!snapshot.hasData) {
                        //add here a spinner
                        CircularProgressIndicator();
                      }
                      List<Cardwidget> ourCartWidgets = [];
                      final ourItems = snapshot.data!.docs;
                      for (var ouritem in ourItems) {
                        var id = ouritem.id;
                        var shoppingCartName = ouritem.get('shoppingListName');
                        var cid = ouritem.get('shoppinglistId');
                        var cartWidet = Cardwidget(
                            label: shoppingCartName,
                            goCartFunc: () {
                              setState(() {
                                print('instate');
                                goCartList(context, cid, shoppingCartName);
                              });
                            });

                        ourCartWidgets.add(cartWidet);
                      }
                      return ListView(
                        children: ourCartWidgets,
                      );
                    }),
              )),
              Container(
                width: double.infinity,
                child: Card(
                    elevation: 8,
                    color: Colors.amber.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 20.0),
                      child: ListTile(
                        onTap: (() {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      buildNewCart(widget._locale)));
                        }),
                        title: Text(
                          '${DemoLocalization.of(context)!.translate('add_new_list')}  ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        leading: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              //  color: Color.fromARGB(255, 219, 217, 217),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 45,
                            )),
                      ),
                    )),
              )
            ]),
          )
        ]),
      ),
    );
  }
}
