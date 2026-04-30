import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/providerDeepLink/firebase_dynamicLink.dart';
import 'package:home_order_app/screens/ListCartsScreen.dart';
import 'package:home_order_app/screens/RegistrationScreen.dart';
import 'package:home_order_app/screens/SignInScreen.dart';
import 'package:home_order_app/screens/WelcomeScreen.dart';
import 'package:home_order_app/screens/add_item_settings_screen.dart';
import 'package:home_order_app/screens/add_person_screen.dart';
import 'package:home_order_app/screens/add_recipe_screen.dart';
import 'package:home_order_app/screens/buildNewCart.dart';
import 'package:home_order_app/screens/category_screen.dart';
import 'package:home_order_app/screens/recipe_screen.dart';
import 'package:home_order_app/screens/shopping_cart_screen.dart';
import 'package:home_order_app/screens/tabs_screen.dart';
import 'package:home_order_app/screens/category_items_screen.dart';
import 'package:home_order_app/screens/view_recipe_screen.dart';
import 'package:home_order_app/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/shoppingCart.dart';
import 'screens/items_list_screen.dart';
import 'package:home_order_app/database_helper.dart';
import 'package:provider/provider.dart';
import 'screens/settingsScreen.dart';

/*   read here
 this vision connect to firestore
so we keep item in local database
but shopping will be in fire store couldly
so add new item to shopping list will add just in firebase and not locally 
will will stop deal with requested_item

resource

1- firebase i finish for android reamin ios https://www.youtube.com/watch?v=knbWcmJAWNA&list=PLw6Y5u47CYq5_KE9a-Sh0UcSBZe4I85Bd
2- firebase store in db need to finish ios https://www.youtube.com/watch?v=UJ6IQGkoEgA&list=PLJgpUKI76n7RY1k_Y63Sc58p43CXku0OD&index=2
https://www.youtube.com/watch?v=aBrRJqrQTpQ&list=PLJgpUKI76n7RY1k_Y63Sc58p43CXku0OD&index=1
 */

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();

  // MobileAds.instance.initialize();

  runApp(MyApp());
}

Future initialization(BuildContext context) async {
  //load resouces
  await Future.delayed(Duration(seconds: 0));
}

class MyApp extends StatefulWidget {
  const MyApp();
  //const MyApp();

  //2 method for local
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //save user info in shared_preferences
  late SharedPreferences prefs;
  String userEmail = '';
  String shoppingCartId = '';
  String shoppingCartName = '';
  String userId = '';

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User signedInUser; //this will give us user email
  Locale? _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  Future getData_shared_preferences_user() async {
    prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('userEmail') ?? '';
    shoppingCartId = prefs.getString('shoppingCartId') ?? '';
    shoppingCartName = prefs.getString('shoppingCartName') ?? '';
    userId = prefs.getString('userId') ?? '';
    print('-----------main ---${shoppingCartId}');
    // we set provider cart id in 4 position
    //1- in register page
    //2 in login
    //3 in tap or item list widget page
    //4 in select list from lists page
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
        print(this._locale);
      });
    });
    super.didChangeDependencies();
  }

  void initState() {
    getCurrentUser();
    getData_shared_preferences_user().then((value) {});
    super.initState();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        print(signedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DataBaseHelper>(
          create: (context) => DataBaseHelper(),
        ),
        ChangeNotifierProvider<shoppingCart>(
          create: (context) => shoppingCart(shoppingCartId, shoppingCartName),
        ),
      ],
      child: MaterialApp(
        title: 'Home App',
        locale: _locale,
        home: SplashScreen(),
        supportedLocales: [
          Locale('en', 'US'), // English, no country code
          Locale('ed', 'DE'),
          Locale('ar', 'SA'),
        ],
        localizationsDelegates: [
          DemoLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale!.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        theme: ThemeData(
          textTheme: ThemeData.light().textTheme.copyWith(
                // ignore: prefer_const_constructors
                headlineMedium: TextStyle(
                  color: Colors.black,
                  //  color: Colors.blue,
                  fontSize: 19,
                  //  fontFamily: 'ElMessiri',
                  fontWeight: FontWeight.bold,
                ),
                // ignore: prefer_const_constructors
                headlineSmall: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  // fontFamily: 'ElMessiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blueGrey,
          ).copyWith(secondary: Colors.amber),
        ),

        //initialRoute: (userEmail == '') ? '/' : TabsScreen.screenRoute,
        routes: {
          //'/': (ctx) => WelcomeScreen(),
          TabsScreen.screenRoute: (ctx) => TabsScreen(_locale),
          itemListScreen.screenRoute: (ctx) => itemListScreen(),
          ShoppingCartScreen.screenRoute: (ctx) => ShoppingCartScreen(_locale),
          categoryScreen.screenRoute: (ctx) => categoryScreen(_locale),
          CategoryItemScreen.screenRoute: (ctx) => CategoryItemScreen(),
          settingsScreen.screenRoute: (ctx) => settingsScreen(),
          add_item_settings_screen.screenRoute: (ctx) =>
              add_item_settings_screen(_locale),
          recipe_screen.screenRoute: (ctx) => recipe_screen(_locale),
          add_recipe_screen.screenRoute: (ctx) => add_recipe_screen(_locale),
          view_recipe_screen.screenRoute: (ctx) => view_recipe_screen(_locale),
          SignInScreen.screenRoute: (ctx) => SignInScreen(),
          RegistrationScreen.screenRoute: (ctx) => RegistrationScreen(),
          add_person_screen.screenRoute: (ctx) => add_person_screen(),
          list_carts_screen.screenRoute: (ctx) => list_carts_screen(_locale),
          buildNewCart.screenRoute: (ctx) => buildNewCart(_locale),
          recipe_screen.screenRoute: (context) => recipe_screen(_locale),
        },
      ),
    );
  }
}
