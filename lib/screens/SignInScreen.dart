import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_order_app/models/shoppingCart.dart';
import 'package:home_order_app/screens/tabs_screen.dart';
import 'package:home_order_app/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  static const String screenRoute = '/signin_screen';

  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;
  late SharedPreferences prefs;
  final _auth = FirebaseAuth.instance;
  //late String email;
  //late String password;
  String email = '';
  String password = '';
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    // return Stack(
    //   children: [
    //     Scaffold(
    //       appBar: AppBar(title: Text('Register')),
    //       body: Center(
    //         child: ElevatedButton(
    //           onPressed: () async {
    //             setState(() => isLoading = true);
    //             await Future.delayed(Duration(seconds: 2));
    //             setState(() => isLoading = false);
    //           },
    //           child: Text('Submit'),
    //         ),
    //       ),
    //     ),

    //     if (isLoading)
    //       Container(
    //         color: Colors.black.withOpacity(0.5),
    //         child: const Center(child: CircularProgressIndicator()),
    //       ),
    //   ],
    // );

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
                color: Colors.yellow[900]!,
                title: 'Sign in',
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  if (email.isEmpty || password.isEmpty) {
                    setState(() => showSpinner = false); // ✅ FIX
                    showMessage(context, 'Error', 'Enter email and password');
                    return;
                  }
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    if (user != null) {
                      final snapshot = await _firestore
                          .collection('shoppinglists')
                          .where('ownerEmail', isEqualTo: email)
                          .get();
                      if (snapshot.docs.isEmpty) {
                        setState(() => showSpinner = false);
                        showMessage(context, 'Error', 'No  found');
                        return;
                      }
                      {
                        for (var cart in snapshot.docs) {
                          print(cart.data());
                        }

                        String id = snapshot.docs[0].id;
                        String name = snapshot.docs[0].get('shoppingListName');

                        saveData_shared_preferences(
                          email,
                          password,
                          id,
                          name,
                        ).then((value) {
                          //set provider
                          Provider.of<shoppingCart>(
                            context,
                            listen: false,
                          ).setShoppingCart(
                            shoppingCartId: id,
                            shoppingCartName: name,
                          );

                          // get user id from firebase then save in pref
                          //! need test
                          getUserId(email); //just first time register cr
                          //naviagtor
                          Navigator.pushNamed(context, TabsScreen.screenRoute);
                          setState(() {
                            showSpinner = false;
                          });
                        });
                      }
                    }
                  } on FirebaseAuthException catch (error) {
                    print(error);
                    switch (error.code) {
                      case "ERROR_INVALID_EMAIL":
                        showMessage(
                          context,
                          'Email not valid',
                          'Your email address appears to be malformed.',
                        );
                        break;
                      case "ERROR_WRONG_PASSWORD":
                        showMessage(
                          context,
                          'Password Wrong',
                          'Your password is wrong.',
                        );
                        break;
                      case "ERROR_USER_NOT_FOUND":
                        showMessage(
                          context,
                          'User not found',
                          'User with this email doesn t exist.',
                        );
                        break;
                      case "ERROR_USER_DISABLED":
                        showMessage(
                          context,
                          'User disabled',
                          'User with this email has been disabled.',
                        );
                        break;
                      case "ERROR_TOO_MANY_REQUESTS":
                        showMessage(
                          context,
                          'Try again later',
                          'Too many requests. Try again later.',
                        );
                        break;
                      case "ERROR_OPERATION_NOT_ALLOWED":
                        showMessage(
                          context,
                          'Try again later',
                          'Signing in with Email and Password is not enabled.',
                        );
                        break;
                      default:
                        showMessage(
                          context,
                          'Try again later',
                          'Login failed. Please try again.',
                        );
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

  Future getUserId(userEmail) async {
    //need test !
    await _firestore
        .collection('user')
        .where('userEmail', isEqualTo: userEmail)
        .get()
        .then((docRef) {
      print('#########$docRef   ${docRef.docs[0].reference.id}');
      saveuserId_shared_preferences(docRef.docs[0].reference.id);
      return docRef.docs[0].reference.id;
    });
  }

  saveuserId_shared_preferences(userId) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userId);
  }

  Future saveData_shared_preferences(
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
