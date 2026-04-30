import 'package:flutter/material.dart';
import 'package:home_order_app/screens/RegistrationScreen.dart';
import 'package:home_order_app/screens/SignInScreen.dart';
import 'package:home_order_app/widgets/my_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String screenRoute = 'welcome_screen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String userEmail = '';
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(height: 180, child: Image.asset('assets/logo.png')),
              ],
            ),
            SizedBox(height: 30),
            MyButton(
              color: Theme.of(context).colorScheme.primary,
              title: 'Sign in',
              onPressed: () {
                Navigator.pushNamed(context, SignInScreen.screenRoute);
              },
            ),
            MyButton(
              color: Theme.of(context).primaryColor,
              title: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.screenRoute);
              },
            ),
          ],
        ),
      ),
    );
  }
}
