import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/database_helper.dart';
import 'package:home_order_app/models/item.dart';
import 'package:home_order_app/models/recipe_category.dart';
import 'package:fluttertoast/fluttertoast.dart';

class add_recipe_screen extends StatefulWidget {
  static const screenRoute = '/add_recipe_screen';
  Locale? _locale;
  add_recipe_screen(Locale? this._locale);
  var recipeList = [];

  @override
  State<add_recipe_screen> createState() => _add_item_screenState();
}

class _add_item_screenState extends State<add_recipe_screen> {
  late Locale _locale;
  List<Item> items = <Item>[];
  List<Item> allItems = <Item>[];
  var selectedItems = [];
  @override
  void initState() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });

    helper = DataBaseHelper();
    helper.getallItemstoAddinRecipe().then((itemsList) {
      setState(() {
        allItems = itemsList; //as Future<List<Item>>;
        items = allItems;
      });
    });
    super.initState();
  }

  List<RecipeCategory> categories = RecipeCategory.getRecipeCategory();

  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String _selectedRecipeCategory = '1';
  late DataBaseHelper helper;
  List<String> added = [];
  String currentText = "";
  String _displayStringForOption(Item option) => ((_locale.languageCode == 'ar')
      ? option.itemNameAR
      : (_locale.languageCode == 'de')
          ? option.itemNameDE
          : option.itemName);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${DemoLocalization.of(context)!.translate('add_recipe')} ')),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: <Widget>[
          FormBuilderTextField(
              //validator: [FormBuilderValidators.required()],
              controller: nameController,
              decoration: InputDecoration(
                  labelText:
                      "${DemoLocalization.of(context)!.translate('Name')}"),
              name: 'text'),
          FormBuilderDropdown(
            decoration: InputDecoration(
                labelText:
                    '${DemoLocalization.of(context)!.translate('RecipeCategory')}'),
            items: categories.map((item) {
              return DropdownMenuItem(
                child: new Text((this._locale != null)
                    ? (this._locale.languageCode == 'ar')
                        ? item.name_ar.toString()
                        : (this._locale.languageCode == 'de')
                            ? item.name_de.toString()
                            : item.name.toString()
                    : item.name.toString()),
                value: item.id.toString(),
              );
            }).toList(),
            name: 'RecipeCategory',
            initialValue: _selectedRecipeCategory,
            onChanged: (String? value) => setState(() {
              _selectedRecipeCategory = value ?? "";
            }),
          ),
          TextField(
            controller: descController,
            decoration: InputDecoration(
                labelText:
                    "${DemoLocalization.of(context)!.translate('description')}"),
            maxLines: 5, //or null
          ),
          SizedBox(
            height: 10,
            width: 10,
          ),
          Align(
              // alignment: Alignment.centerLeft,
              child: Text(
            '${DemoLocalization.of(context)!.translate('ingredient')}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          )),
          Autocomplete<Item>(
            displayStringForOption: _displayStringForOption,
            optionsBuilder: (TextEditingValue textEditingValue) {
              return items
                  .where((Item option) =>
                      option.itemNameAR
                          .toLowerCase()
                          .startsWith(textEditingValue.text.toLowerCase()) ||
                      option.itemNameDE
                          .toLowerCase()
                          .startsWith(textEditingValue.text.toLowerCase()) ||
                      option.itemName
                          .toLowerCase()
                          .startsWith(textEditingValue.text.toLowerCase()))
                  .toList();
            },
            onSelected: (Item selection) {
              // this.currentText = '';
              addItemToList(selection);
              debugPrint(
                  'You just selected ${_displayStringForOption(selection)}');
            },
          ),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: selectedItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      height: 50,
                      margin: EdgeInsets.all(2),
                      child: Center(
                          child: Row(children: [
                        Text((this._locale.languageCode == 'ar')
                            ? '${selectedItems[index].toString().split(':')[0]} '
                            : (this._locale.languageCode == 'de')
                                ? '${selectedItems[index].toString().split(':')[1]} '
                                : '${selectedItems[index].toString().split(':')[2]} '),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.remove,
                          ),
                          onPressed: () {
                            setState(() {
                              deleteItemFromList(selectedItems[index]);
                            });
                          },
                        )
                      ])));
                }),
          ),
          ElevatedButton(
            child: Text('${DemoLocalization.of(context)!.translate('Add')}'),
            onPressed: () {
              addRecipe();
            },
          )
        ]),
      ),
    );
  }

  void addItemToList(select_item) {
    setState(() {
      selectedItems.add(select_item);
    });
  }

  void deleteItemFromList(select_item) {
    setState(() {
      selectedItems.remove(select_item);
    });
  }

  void addRecipe() async {
    String recipeName = nameController.text;
    String desc = descController.text;
    int categoryId = 1;
    if (_selectedRecipeCategory != null)
      categoryId = int.parse(_selectedRecipeCategory);

    List<String> seletctedItemsIds =
        selectedItems.map((item) => item.itemId.toString()).toList();
    String Ids_String = seletctedItemsIds.toString();
    print(
        Ids_String); //var a = '["one", "two", "three", "four"]';var ab = json.decode(a);
    if (recipeName != '') {
      await helper.insertRecipe(recipeName, desc, categoryId, Ids_String);
      Fluttertoast.showToast(
        msg: "${DemoLocalization.of(context)!.translate('saveDone')}",
      );
    }
    Navigator.pop(context, true);
    //Navigator.pop(context, 'Yep!');
  }
}
