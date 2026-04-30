import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_order_app/screens/tabs_screen.dart';
import 'package:home_order_app/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_order_app/models/shoppingCart.dart';

class RegistrationScreen extends StatefulWidget {
  static const String screenRoute = '/registration_screen';

  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late SharedPreferences prefs;
  late String email;
  late String password;

  bool showSpinner = false;
  String fistCartName = 'home';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 180, child: Image.asset('assets/logo.png')),
              SizedBox(height: 50),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your Email',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              MyButton(
                color: Colors.blue[800]!,
                title: 'register',
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    saveDataInfoFireBase(email).then((userId) {
                      //navigate
                      //  Navigator.pushNamed(context, TabsScreen.screenRoute);
                      setState(() {
                        showSpinner = false;
                      });
                    });
                  } on FirebaseAuthException catch (e) {
                    print(e.code);
                    if (e.code == 'weak-password') {
                      print(e);
                      showMessage(
                        context,
                        'Password is weak',
                        'The password provided is too weak.',
                      );
                    } else if (e.code == 'email-already-in-use') {
                      print(e);
                      showMessage(
                        context,
                        'This Email address is already',
                        'This Email address is already registered Please create your account with an different email address,or sign in t your existing account instead.',
                      );
                    } else if (e.code == 'operation-not-allowed') {
                      showMessage(
                        context,
                        'Operation not allowed',
                        'There is a problem with auth service config :/',
                      );
                    } else {
                      print('auth error ' + e.toString());
                      rethrow;
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Future<String> saveUserInfoFireBase(email) async {
  Future<String> saveDataInfoFireBase(email) async {
    //first add user to db
    _firestore.collection('user').add({'userEmail': email, 'photo': ''}).then((
      docRef,
    ) {
      String userId = docRef.id;
      //add cart to db
      _firestore
          .collection('shoppinglists')
          .add({'shoppingListName': fistCartName, 'ownerEmail': email}).then(
              (docRef2) {
        _firestore.collection('shoppinglists').doc(docRef.id).set({
          'shoppingListName': fistCartName,
          'ownerEmail': email,
          'shoppinglistId': docRef2.id,
        });
        // add id in field that for steam in cart list page
        String cartId = docRef2.id;
        addCartToUserCollection(userId, docRef2.id, fistCartName);
        addUserToCartMemberCollection(userId, cartId, email);
        //set provider
        Provider.of<shoppingCart>(context, listen: false).setShoppingCart(
          shoppingCartId: cartId,
          shoppingCartName: fistCartName,
        );
        saveData_shared_preferences(
          userId,
          email,
          password,
          cartId,
          fistCartName,
        ).then((value) {
          Navigator.pushNamed(context, TabsScreen.screenRoute);
        });
        //!! add id in field that for steam in cart list page

        return cartId;
      });
    });
    return '';
  }

  Future saveData_shared_preferences(
    userId,
    email,
    password,
    shoppingCartId,
    shoppingCartName,
  ) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('userEmail', email);
    prefs.setString('userpassword', password);
    prefs.setString('shoppingCartId', shoppingCartId);
    prefs.setString('shoppingCartName', shoppingCartName);
    prefs.setString('userId', userId);
  }

  Future<String> createfirstShoppingCartFirebase(userId, email) async {
    String cartId = '';
    // Step 1: Check if first cart already exists for this user
    final querySnapshot = await _firestore
        .collection('shoppinglists')
        .where('ownerEmail', isEqualTo: email)
        .where('shoppingListName',
            isEqualTo: fistCartName) // your default first cart name
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Cart already exists, return its ID
      cartId = querySnapshot.docs.first.id;
      print('First cart already exists: $cartId');
      return cartId;
    }

    // Step 2: Cart not found → create it

    await _firestore.collection('shoppinglists').add(
        {'shoppingListName': fistCartName, 'ownerEmail': email}).then((docRef) {
      _firestore.collection('shoppinglists').doc(docRef.id).set({
        'shoppingListName': fistCartName,
        'ownerEmail': email,
        'shoppinglistId': docRef.id,
      });
      // add id in field that for steam in cart list page
      cartId = docRef.id;
      addCartToUserCollection(userId, docRef.id, fistCartName);
      addUserToCartMemberCollection(userId, cartId, email);
      return cartId;
    });
    //now reach here

    return cartId;
  }

  Future addUserToCartMemberCollection(userId, cartId, userEmail) async {
    await _firestore
        .collection('shoppinglists')
        .doc(cartId)
        .collection('members')
        .add({'userId': userId, 'userEmail': userEmail});
  }

  Future addCartToUserCollection(userId, cartId, cartName) async {
    await _firestore
        .collection('user')
        .doc(userId)
        .collection('userShoppinglists')
        .add({'shoppinglistId': cartId, 'shoppingListName': cartName});
  }

  showMessage(BuildContext context, String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  showSpinner = false;
                });
              },
            ),
          ],
        );
      },
    );
  }
}
