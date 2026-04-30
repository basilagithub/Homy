import 'package:flutter/material.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_order_app/screens/WelcomeScreen.dart';
import 'package:home_order_app/screens/tabs_screen.dart';

class SplashScreen extends StatefulWidget {
  static const screenRoute = '/splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Locale? _locale;
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(Duration(seconds: 2)); // optional delay

    final prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('userEmail') ?? '';
    // ✅ get saved language
    Locale locale = await getLocale(); // from your language_constants.dart
    if (!mounted) return;

    if (userEmail.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TabsScreen(_locale)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔷 App Logo (replace with your image)
            // Icon(Icons.shopping_cart, size: 100, color: Colors.white),
            // Container(height: 180, child: Image.asset('assets/logo.png')),
            Image.asset('assets/logo.png', width: 120),
            SizedBox(height: 20),

            SizedBox(height: 40),

            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
