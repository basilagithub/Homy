import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/models/shoppingCart.dart';
import 'package:home_order_app/screens/tabs_screen.dart';
import 'package:home_order_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class buildNewCart extends StatefulWidget {
  Locale? _locale;

  static const String screenRoute = '/buildNewCart';
  buildNewCart(Locale? this._locale);

  @override
  State<buildNewCart> createState() => _buildNewCartState();
}

class _buildNewCartState extends State<buildNewCart> {
  final _firestore = FirebaseFirestore.instance;
  late SharedPreferences prefs;
  String userEmail = '';
  String userId = '';
  getData_shared_preferences_user() async {
    prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('userEmail')!;
    userId = prefs.getString('userId')!;
  }

  @override
  void initState() {
    getData_shared_preferences_user();
    super.initState();
  }

  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                '${DemoLocalization.of(context)!.translate('add_new_list')} $userId')),
        drawer: AppDrawer(widget._locale),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(children: <Widget>[
            FormBuilderTextField(
                //validator: [FormBuilderValidators.required()],
                controller: nameController,
                decoration: InputDecoration(
                    labelText:
                        "${DemoLocalization.of(context)!.translate('Name')}"),
                name: 'text'),
            SizedBox(
              height: 10,
              width: 10,
            ),
            ElevatedButton(
              child: Text('${DemoLocalization.of(context)!.translate('Add')}'),
              onPressed: () {
                addNewList();
              },
            )
          ]),
        ));
  }

  void addNewList() async {
    //check name not null
    //1 add cart in firebase
    //2 set its id and name in Provider
    //3 navigator to tab page

    String cartName = nameController.text;
    if (cartName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name for the cart')),
      );
      return;
    }
    // if (cartName != '') {
    createShoppingCartFirebase(userEmail, cartName).then((shoppingCartId) {
      saveData_shared_preferences(shoppingCartId, cartName);

      //navigate
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => TabsScreen(widget._locale)));
    });
    // }
  }

  Future<String> createShoppingCartFirebase(email, cartName) async {
    String cartId = '';
    await _firestore.collection('shoppinglists').add({
      'shoppingListName': cartName,
      'ownerEmail': email,
    }).then((docRef) {
      _firestore.collection('shoppinglists').doc(docRef.id).set({
        'shoppingListName': cartName,
        'ownerEmail': email,
        'shoppinglistId': docRef.id
      });
      cartId = docRef.id;
      addCartToUserCollection(userId, docRef.id, cartName);
      addUserToCartMemberCollection(userId, cartId, userEmail);
      //set provider
      Provider.of<shoppingCart>(context, listen: false).setShoppingCart(
          shoppingCartId: docRef.id, shoppingCartName: cartName);
      return cartId;
    });
    //now reach here
    return cartId;
  }

  Future addCartToUserCollection(userId, cartId, cartName) async {
    await _firestore
        .collection('user')
        .doc(userId)
        .collection('userShoppinglists')
        .add({'shoppinglistId': cartId, 'shoppingListName': cartName});
  }

  Future addUserToCartMemberCollection(userId, cartId, userEmail) async {
    await _firestore
        .collection('shoppinglists')
        .doc(cartId)
        .collection('members')
        .add({'userId': userId, 'userEmail': userEmail});
  }

  saveData_shared_preferences(shoppingCartId, shoppingCartName) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('shoppingCartId', shoppingCartId);
    prefs.setString('shoppingCartName', shoppingCartName);
  }
}
