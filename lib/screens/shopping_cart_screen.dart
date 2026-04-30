import 'package:flutter/material.dart';
import 'package:home_order_app/widgets/shopping_item_list_widget.dart';

class ShoppingCartScreen extends StatelessWidget {
  Locale? _locale;
  static const screenRoute = '/shopping_cart_screen';
  ShoppingCartScreen(Locale? this._locale);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: ShoppingItemsList(),
    );
  }
}
