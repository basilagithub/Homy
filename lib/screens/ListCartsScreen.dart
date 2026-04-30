import 'package:flutter/material.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/widgets/app_drawer.dart';
import 'package:home_order_app/widgets/listcartsWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class list_carts_screen extends StatefulWidget {
  Locale? _locale;

  static const String screenRoute = '/list_carts_screen';

  //const list_carts_screen({Key? key}) : super(key: key);
  list_carts_screen(Locale? this._locale);

  @override
  _listCartScreenState createState() => _listCartScreenState();
}

/*get from firebase all cart that user is memeber in it .. in init */
class _listCartScreenState extends State<list_carts_screen> {
  String userId = '';
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();

    // 1 get user email from pref that is future function then get all carts that memeber in it
    // each cart has name , id , memeber , items , in regtangl show name and member and count of items
  }

  Widget build(BuildContext context) {
    final routeArgument =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    userId = routeArgument['userId']!;
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${DemoLocalization.of(context)!.translate('cartLists')} $userId 10')),
      drawer: AppDrawer(widget._locale),
      body: listcartsWidget(widget._locale, userId),
    );
  }
}
