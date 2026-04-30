import 'package:flutter/material.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/models/shoppingCart.dart';
import 'package:home_order_app/providerDeepLink/firebase_dynamicLink.dart';
import 'package:home_order_app/screens/category_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_drawer.dart';
import 'items_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TabsScreen extends StatefulWidget {
  static const String screenRoute = 'TabsScreen';
  Locale? _locale;
  TabsScreen(Locale? this._locale);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  Locale? _locale;
  late SharedPreferences prefs;
  String userEmail = '';
  String userId = '';
  String shoppingCartId = ''; // from pref
  String shoppingCartName = ''; //from firebase
  List ourItems = []; //from firebase
  List cartMember = []; //from firebase
  final _auth = FirebaseAuth.instance;
  late User signedInUser;
  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  int _selectedScreenIndex = 0;

  late List<Map<String, Object>> _screens;
  Future getData_shared_preferences_user() async {
    prefs = await SharedPreferences.getInstance();
    // userEmail = prefs.getString('userEmail')!;
    // shoppingCartId = prefs.getString('shoppingCartId')!;
    // shoppingCartName = prefs.getString('shoppingCartName')!;
    // userId = prefs.getString('userId')!;
    userEmail = prefs.getString('userEmail') ?? '';
    shoppingCartId = prefs.getString('shoppingCartId') ?? '';
    shoppingCartName = prefs.getString('shoppingCartName') ?? '';
    userId = prefs.getString('userId') ?? '';
  }

  @override
  void initState() {
    //check if get invitation from fiend so deal with invitation and navigation to page lists
    getData_shared_preferences_user().then((value) {
      FirebaseDynamicLinkService fs =
          FirebaseDynamicLinkService(); ////https://firebase.google.com/docs/dynamic-links/flutter/receive
      // fs.initDynamicLink(context, 'O16kOJYMIF3jhC2GVrOq', '123@gmail.com');
      fs.initDynamicLink(context, userId, userEmail);
    });
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    print('settings _locale ${_locale}');
    // print( 'fisrt${widget._locale} ${DemoLocalization.of(context)!.translate('item_List')}');
    //2026 remove form iinit just in build
    _screens = [
      {
        'Title': Provider.of<shoppingCart>(
          context,
          listen: false,
        ).shoppingCartName,
        'Screen': itemListScreen(),
      },
      {'Title': 'Category', 'Screen': categoryScreen(widget._locale)},
    ];
    super.initState();
    getCurrentUser();
    // getData_shared_preferences_user();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_screens[_selectedScreenIndex]['Title'] as String),
      ),
      drawer: AppDrawer(widget._locale),
      body: _screens[_selectedScreenIndex]['Screen'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectScreen,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Theme.of(context).primaryColorDark, // Colors.amber,
        // selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedScreenIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '${DemoLocalization.of(context)!.translate('Products')}  ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '${DemoLocalization.of(context)!.translate('Category')}  ',
          ),
        ],
      ),
    );
  }
}
