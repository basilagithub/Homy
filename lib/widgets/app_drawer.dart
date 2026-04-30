import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_share/flutter_share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/screens/recipe_screen.dart';
import 'package:home_order_app/screens/settingsScreen.dart';
import 'package:home_order_app/screens/tabs_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:home_order_app/screens/ListCartsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  Locale? _locale;
  AppDrawer(Locale? this._locale);
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Locale? _locale;
  late SharedPreferences prefs;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User signedInUser; //this will give us user email
  List CartsListIds = [];
  //add by me
  String? appName;
  String? packageName;
  String? version;
  String? buildNumber;
  String userId = '';
  @override
  void initState() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        print(signedInUser.email);
        // getCartListIds(_auth.currentUser?.email ?? 'Guest');
      }
    } catch (e) {
      print(e);
    }
  }

  Future getuserId_shared_preferences_user() async {
    prefs = await SharedPreferences.getInstance();
    //userId = prefs.getString('userId')!;
    userId = prefs.getString('userId') ?? '';
    print(';;;;;;;;;;;;;;;;;;$userId');
  }

  Widget buildListTile(String title, IconData icon, VoidCallback onTapLink) {
    return ListTile(
      leading: Icon(icon, size: 30, color: Colors.blue),
      title: Text(
        title, //from argument
        style: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize, // 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTapLink,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.only(top: 40),
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              '${DemoLocalization.of(context)!.translate('myApp_name')} ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          SizedBox(height: 20),
          buildListTile(
            '${DemoLocalization.of(context)!.translate('user')} ${_auth.currentUser?.email ?? 'Guest'}  ',
            Icons.person,
            () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          buildListTile(
            '${DemoLocalization.of(context)!.translate('cartLists')} ',
            Icons.list,
            () {
              getuserId_shared_preferences_user().then((value) {
                Navigator.pushNamed(
                  context,
                  list_carts_screen.screenRoute,
                  arguments: {'userId': userId},
                );
              });
            },
          ),

          buildListTile(
            '${DemoLocalization.of(context)!.translate('item_List')} ',
            Icons.store,
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => TabsScreen(this._locale),
                ),
              );
            },
          ),
          buildListTile(
            '${DemoLocalization.of(context)!.translate('recipe')} ',
            Icons.food_bank,
            () {
              Navigator.pushNamed(context, recipe_screen.screenRoute);
            },
          ),
          // buildListTile(
          //   '${DemoLocalization.of(context)!.translate('recipe')} ',
          //   Icons.food_bank,
          //   () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(
          //         builder: (BuildContext context) =>
          //             recipe_screen(this._locale),
          //       ),
          //     );
          //   },
          // ),

          // buildListTile(
          //   '${DemoLocalization.of(context)!.translate('settings')} ',
          //   Icons.settings,
          //   () {
          //     Navigator.of(
          //       context,
          //     ).pushReplacementNamed(settingsScreen.screenRoute);
          //   },
          // ),
          buildListTile(
            '${DemoLocalization.of(context)!.translate('settings')} ',
            Icons.settings,
            () {
              Navigator.of(
                context,
              ).pushNamed(settingsScreen.screenRoute);
            },
          ),
          buildListTile(
            '${DemoLocalization.of(context)!.translate('recommend_app')} ',
            Icons.share,
            () {
              _getPackageInfo().then(
                (value) => {
                  //  print(  "https://play.google.com/store/apps/details?id=${value.packageName}");
                  share(
                    "https://play.google.com/store/apps/details?id=${value.packageName}",
                  ),
                },
              );
            },
          ),
          // buildListTile(
          //   '${DemoLocalization.of(context)!.translate('about')} ',
          //   Icons.,
          //   () {},
          // )
          // order for alexa
          //about home order(social media privacy policy copyright)/
          //theme
          //add suggeted order that show items that alway ordered
        ],
      ),
    );
  }

  Future<PackageInfo> _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    return packageInfo;
  }

  Future<void> share(String url) async {
    Share.share(url);
  }
}
