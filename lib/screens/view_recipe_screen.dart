import 'package:flutter/material.dart';

import 'package:home_order_app/widgets/view_recipe_widget.dart';

class view_recipe_screen extends StatefulWidget {
  static const screenRoute = '/view_recipe_screen';
  Locale? _locale;
  view_recipe_screen(Locale? this._locale);
  var recipeList = [];

  @override
  State<view_recipe_screen> createState() => _view_recipe_screenState();
}

class _view_recipe_screenState extends State<view_recipe_screen> {
  @override
  Widget build(BuildContext context) {
    final routeArgument =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final recipe_id = routeArgument['recipe_id'];
    final recipe_name = routeArgument['recipe_name']!;
    final recipe_Description = routeArgument['recipe_Description']!;
    final recipe_category_id = routeArgument['recipe_category_id']!;
    final recipes_items = routeArgument['recipes_items']!;
    return Container(
      child: view_recipe_widget(recipe_id!, recipe_name, recipe_Description,
          recipe_category_id, recipes_items),
    );
  }
}
