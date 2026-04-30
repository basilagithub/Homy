import 'package:flutter/material.dart';
import '../widgets/items_list_widget.dart';

class itemListScreen extends StatelessWidget {
  static const screenRoute = '/items_page';
  @override
  Widget build(BuildContext context) {
    return Container(
      //  return Expanded(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: ItemsList(),
    );
  }
}
