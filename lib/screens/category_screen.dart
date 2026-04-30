import 'package:flutter/material.dart';
import 'package:home_order_app/models/category.dart';
import 'package:home_order_app/screens/category_items_screen.dart';

class categoryScreen extends StatefulWidget {
  Locale? _locale;
  static const screenRoute = '/category_screen';
  categoryScreen(Locale? this._locale);

  @override
  State<categoryScreen> createState() => _categoryScreenState();
}

class _categoryScreenState extends State<categoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Category> Categorys = Category.getCategory();

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: Categorys.length,
      itemBuilder: (context, index) {
        return Material(
          child: GestureDetector(
            onTap: () => selectCategory(
              context,
              Categorys[index].id,
              Categorys[index].name,
              Categorys[index].name_ar,
              Categorys[index].name_de,
              Categorys[index].image,
            ),
            child: Container(
              color: Color.fromARGB(255, 209, 207, 207),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      ((widget._locale ?? Locale('en')).languageCode == 'ar')
                          ? Categorys[index].name_ar
                          : ((widget._locale ?? Locale('en')).languageCode ==
                                  'de')
                              ? Categorys[index].name_de
                              : Categorys[index].name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(child: new Image.asset(Categorys[index].image)),
                ],
              ),
            ),
          ),
        );
      },
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        childAspectRatio: 7 / 8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
    );
  }

  void selectCategory(
    BuildContext ctx,
    int id,
    String name,
    String name_ar,
    String name_de,
    String image,
  ) {
    Navigator.of(ctx).pushNamed(
      CategoryItemScreen.screenRoute,
      arguments: {
        'id': id.toString(),
        'name': name,
        'name_ar': name_ar,
        'name_de': name_de,
        'image': image,
      },
    );
  }
}
