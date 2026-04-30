import 'package:flutter/material.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/main.dart';
import 'package:home_order_app/models/language.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/screens/add_item_settings_screen.dart';
import 'package:home_order_app/screens/recipe_screen.dart';
import '../widgets/app_drawer.dart';

class settingsScreen extends StatefulWidget {
  const settingsScreen({Key? key}) : super(key: key);
  static const screenRoute = '/settingsScreen';

  @override
  State<settingsScreen> createState() => _settingsScreenState();
}

class _settingsScreenState extends State<settingsScreen> {
  //String selectedLanguge;
  Locale? _locale;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  void _changeLanguage(Language language) async {
    Locale _locale1 = await setLocale(language.languageCode);
    print(_locale1);
    MyApp.setLocale(this.context, _locale1);
  }

  @override
  void initState() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
      print('settings _locale ${_locale}');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${DemoLocalization.of(context)!.translate('settings')} '),
      ), //work
      drawer: AppDrawer(_locale),
      body: Container(
        child: Column(
          children: [
            SettingsGroup(
              title: '${DemoLocalization.of(context)!.translate('general')} ',
              children: <Widget>[
                Row(
                  children: [
                    DropdownButton(
                      onChanged: (Language? language) {
                        if (language == null) return;
                        setState(() {
                          _changeLanguage(language!);
                        });
                      },
                      icon: Icon(Icons.language),
                      items: Language.languageList()
                          .map<DropdownMenuItem<Language>>(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text(e.flag),
                                  Text(e.name, style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ],
              titleTextStyle: Theme.of(context).textTheme.headlineMedium,
            ),
            SettingsGroup(
              title: '${DemoLocalization.of(context)!.translate('recipe')}',
              children: [
                buildListTile(
                  context,
                  '${DemoLocalization.of(context)!.translate('recipe')} ',
                  Icons.food_bank,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => recipe_screen(_locale),
                      ),
                    );
                  },
                ),
              ],
              titleTextStyle: Theme.of(context).textTheme.headlineMedium,
            ),
            SettingsGroup(
              title:
                  '${DemoLocalization.of(context)!.translate('add_new_items')}',
              children: [
                buildListTile(
                  context,
                  '${DemoLocalization.of(context)!.translate('add_new_items')} ',
                  Icons.food_bank,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => add_item_settings_screen(_locale),
                      ),
                    );
                  },
                ),
              ],
              titleTextStyle: Theme.of(context).textTheme.headlineMedium,
            ),

            // SettingsGroup(title: '${DemoLocalization.of(context)!.translate('Messaging') }', children: const <Widget>[]),
            //   SettingsGroup(title: '${DemoLocalization.of(context)!.translate('about') }', children: const <Widget>[]),
          ],
        ),
      ),

      //2 add new item
      //3 add new recepe
      //4 notification
      // contact us
      //rate us
      // ]),
    );
  }
}

Widget buildListTile(
  BuildContext context,
  String title,
  IconData icon,
  VoidCallback onTapLink,
) {
  return ListTile(
    leading: Icon(
      icon,
      size: 30,
      color: Theme.of(context).colorScheme.primary,
      // color: Colors.blue,
    ),
    title: Text(
      title, //from argument
      style: Theme.of(context).textTheme.headlineMedium,
    ),
    onTap: onTapLink,
  );
}

//--------------------------------------------------------------------------
class SettingsGroup extends StatelessWidget {
  /// title string for the tile
  final String title;

  /// subtitle string for the tile
  final String subtitle;

  /// title text style
  final TextStyle? titleTextStyle;

  /// subtitle text style
  final TextStyle? subtitleTextStyle;

  /// List of the widgets which are to be shown under the title as a group
  final List<Widget> children;

  final Alignment titleAlignment;

  SettingsGroup({
    required this.title,
    required this.children,
    this.subtitle = '',
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.titleAlignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    var elements = <Widget>[
      Container(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 22.0),
        child: Align(
          alignment: titleAlignment,
          child: Text(
            title.toUpperCase(),
            style: titleTextStyle ?? groupStyle(context),
          ),
        ),
      ),
    ];

    if (subtitle.isNotEmpty) {
      elements.addAll([
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(subtitle, style: subtitleTextStyle),
          ),
        ),
        _SettingsTileDivider(),
      ]);
    }
    elements.addAll(children);
    return Wrap(children: <Widget>[Column(children: elements)]);
  }

  TextStyle groupStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
    );
  }
}

class _SettingsTileDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 0.0);
  }
}

/////
///
class SimpleSettingsTile extends StatelessWidget {
  /// title string for the tile
  final String title;

  /// subtitle string for the tile
  final String? subtitle;

  /// title text style
  final TextStyle? titleTextStyle;

  /// subtitle text style
  final TextStyle? subtitleTextStyle;

  /// widget to be placed at first in the tile
  final Widget? leading;

  /// flag which represents the state of the settings, if false the the tile will
  /// ignore all the user inputs, default = true
  final bool enabled;

  /// widget that will be displayed on tap of the tile
  final Widget? child;

  final VoidCallback? onTap;

  final bool showDivider;

  SimpleSettingsTile({
    required this.title,
    this.subtitle,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.child,
    this.enabled = true,
    this.leading,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      titleTextStyle: titleTextStyle,
      subtitleTextStyle: subtitleTextStyle,
      enabled: enabled,
      onTap: () => (context),
      showDivider: showDivider,
      child: child != null ? getIcon(context) : Text(''),
    );
  }

  Widget getIcon(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.navigate_next),
      onPressed: enabled ? () => _handleTap(context) : null,
    );
  }

  void _handleTap(BuildContext context) {
    onTap?.call();

    if (child != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (BuildContext context) => child!));
    }
  }
}

///
class _SettingsTile extends StatefulWidget {
  /// title string for the tile
  final String title;

  /// widget to be placed at first in the tile
  final Widget? leading;

  /// subtitle string for the tile
  final String? subtitle;

  /// title text style
  final TextStyle? titleTextStyle;

  /// subtitle text style
  final TextStyle? subtitleTextStyle;

  /// flag to represent if the tile is accessible or not, if false user input is ignored
  final bool enabled;

  /// widget which is placed as the main element of the tile as settings UI
  final Widget child;

  /// call back for handling the tap event on tile
  final GestureTapCallback? onTap;

  // /// flag to show the child below the main tile elements
  // final bool showChildBelow;

  final bool showDivider;

  _SettingsTile({
    required this.title,
    required this.child,
    this.subtitle = '',
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.onTap,
    this.enabled = true,
    // this.showChildBelow = false,
    this.leading,
    this.showDivider = true,
  });

  @override
  __SettingsTileState createState() => __SettingsTileState();
}

class __SettingsTileState extends State<_SettingsTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
            leading: widget.leading,
            title: Text(
              widget.title,
              style: widget.titleTextStyle ?? headerTextStyle(context),
            ),
            subtitle: widget.subtitle?.isEmpty ?? true
                ? null
                : Text(
                    widget.subtitle!,
                    style:
                        widget.subtitleTextStyle ?? subtitleTextStyle(context),
                  ),
            enabled: widget.enabled,
            onTap: widget.onTap,
            // trailing: Visibility(
            //   visible: !widget.showChildBelow,
            //   child: widget.child,
            // ),
            trailing: widget.child,
            dense: true,
            // wrap only if the subtitle is longer than 70 characters
            isThreeLine: (widget.subtitle?.isNotEmpty ?? false) &&
                widget.subtitle!.length > 70,
          ),
          // Visibility(
          //   visible: widget.showChildBelow,
          //   child: widget.child,
          // ),
          if (widget.showDivider) _SettingsTileDivider(),
        ],
      ),
    );
  }
}

TextStyle? headerTextStyle(BuildContext context) =>
    Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16.0);

TextStyle? subtitleTextStyle(BuildContext context) => Theme.of(
      context,
    )
        .textTheme
        .titleSmall
        ?.copyWith(fontSize: 13.0, fontWeight: FontWeight.normal);
