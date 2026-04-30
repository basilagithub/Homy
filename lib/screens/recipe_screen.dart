import 'package:flutter/material.dart';
import 'package:home_order_app/widgets/recipe_widget.dart';

class recipe_screen extends StatefulWidget {
  static const screenRoute = '/recipe_screen';
  Locale? _locale;
  recipe_screen(Locale? this._locale);

  @override
  State<recipe_screen> createState() => _add_item_screenState();
}

class _add_item_screenState extends State<recipe_screen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: recipe_widget(widget._locale),
    );
  }
}
