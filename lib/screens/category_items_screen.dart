import 'package:flutter/material.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/widgets/category_items_widget.dart';

class CategoryItemScreen extends StatefulWidget {
  const CategoryItemScreen({Key? key}) : super(key: key);

  static const screenRoute = '/CategoryItemScreen';

  @override
  State<CategoryItemScreen> createState() => _CategoryItemScreenState();
}

class _CategoryItemScreenState extends State<CategoryItemScreen> {
  Locale? _locale;
  @override
  void initState() {
    super.initState();
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    //final routeArgument =        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final routeArgument = route?.settings.arguments as Map<String, String>;
    // final categoryId = routeArgument['id'];
    // final categoryName = routeArgument['name']!;
    // final categoryNameAr = routeArgument['name_ar']!;
    // final categoryNameDE = routeArgument['name_de']!;
    final categoryId = routeArgument?['id'] ?? '';
    final categoryName = routeArgument?['name'] ?? '';
    final categoryNameAr = routeArgument?['name_ar'] ?? '';
    final categoryNameDE = routeArgument?['name_de'] ?? '';

    return Container(
      //  return Expanded(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: CategoryItemsWidget(
        categoryId,
        categoryName,
        categoryNameAr,
        categoryNameDE,
      ),
    );
  }
}
