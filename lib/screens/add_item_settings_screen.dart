import 'package:flutter/material.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/database_helper.dart';
import 'package:home_order_app/models/category.dart';
import 'package:home_order_app/models/item.dart';

class add_item_settings_screen extends StatefulWidget {
  static const screenRoute = '/add_item_settings_screen';
  Locale? _locale;
  add_item_settings_screen(Locale? this._locale);
  @override
  State<add_item_settings_screen> createState() =>
      _add_item_settings_screenState();
}

class _add_item_settings_screenState extends State<add_item_settings_screen> {
  List<Category> categories = Category.getCategory();

  TextEditingController nameController = TextEditingController();
  String _selectedCategory = '1';
  late DataBaseHelper helper;
  Locale? _locale;
  var itemAddedByUserList = [];

  @override
  void initState() {
    helper = DataBaseHelper();
    helper.getItemAddedByUserList().then((itemsList) {
      setState(() {
        itemAddedByUserList = itemsList;
      });
    });

    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${DemoLocalization.of(context)!.translate('add_new_items')} ')),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: <Widget>[
          FormBuilderTextField(
              //validator: [FormBuilderValidators.required()],
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
              name: 'text'),
          FormBuilderDropdown(
            decoration: InputDecoration(
                labelText:
                    '${DemoLocalization.of(context)!.translate('Category')}'),
            items: categories.map((item) {
              return DropdownMenuItem(
                child: new Text(
                  (this._locale!.languageCode == 'ar')
                      ? item.name_ar.toString()
                      : (this._locale!.languageCode == 'de')
                          ? item.name_de.toString()
                          : item.name.toString(),
                ),
                value: item.id.toString(),
              );
            }).toList(),
            name: 'Category',
            initialValue: _selectedCategory,
            onChanged: (String? value) => setState(() {
              _selectedCategory = value ?? "";
            }),
          ),
          ElevatedButton(
            child: Text('${DemoLocalization.of(context)!.translate('Add')}'),
            onPressed: () {
              addItemToList();
            },
          ),
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: itemAddedByUserList.length,
                  itemBuilder: (context, index) {
                    Item item1 = Item.fromMap(itemAddedByUserList[index]);
                    return Container(
                      height: 50,
                      margin: EdgeInsets.all(2),
                      child: Center(
                        child: Row(children: [
                          Text(
                            '${item1.itemName}  ',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            (this._locale != null)
                                ? (this._locale!.languageCode == 'ar')
                                    ? '${categories[item1.categoryId].name_ar}  '
                                    : (this._locale!.languageCode == 'de')
                                        ? '${categories[item1.categoryId].name_de}  '
                                        : '${categories[item1.categoryId].name}  '
                                : '${categories[item1.categoryId].name}  ',
                            style: TextStyle(fontSize: 18),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                            ),
                            onPressed: () {
                              setState(() {
                                deletUsedItemFromSettings(item1.itemId);
                              });
                            },
                          )
                          // IconButton(onPressed: {}, icon: Icons.delete)
                        ]),
                      ),
                    );
                  }))
        ]),
      ),
    );
  }

  void addItemToList() async {
    String itemName = nameController.text;
    nameController.text = '';
    int categoryId = 1;
    if (_selectedCategory != null) categoryId = int.parse(_selectedCategory);
    if (itemName != '') {
      await helper.insertNewItemInSettings(itemName, categoryId);
    }

    helper.getItemAddedByUserList().then((itemsList) {
      setState(() {
        itemAddedByUserList = itemsList;
      });
    });
  }

  deletUsedItemFromSettings(id) async {
    try {
      await helper.deletUsedItemFromSettings(id);
      helper.getItemAddedByUserList().then((itemsList) {
        setState(() {
          itemAddedByUserList = itemsList;
        });
      });
    } catch (error) {
      // Scaffold.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Deleting failed!'),
      //   ),
      // );
    }
  }
}
