import 'dart:convert';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/database_helper.dart';
import 'package:home_order_app/models/item.dart';
import 'package:home_order_app/models/recipe_category.dart';
import 'package:home_order_app/models/shoppingCart.dart';
import 'package:home_order_app/screens/shopping_cart_screen.dart';
import 'package:home_order_app/models/req_item.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class view_recipe_widget extends StatefulWidget {
  static const screenRoute = '/view_recipe_widget';

  final String recipe_id;
  final String recipe_name;
  final String recipe_description;
  final String recipe_category_id;
  final String recipes_items;
  view_recipe_widget(
    this.recipe_id,
    this.recipe_name,
    this.recipe_description,
    this.recipe_category_id,
    this.recipes_items,
  );
  var recipeList = [];

  @override
  State<view_recipe_widget> createState() => _view_recipe_widget_State();
}

class _view_recipe_widget_State extends State<view_recipe_widget> {
  final _firestore = FirebaseFirestore.instance;
  late SharedPreferences prefs;
  late Locale _locale;
  List<Item> items = <Item>[];
  List<Item> allItems = <Item>[];
  var selectedItems = [];
  late DataBaseHelper helper;
  List<String> added = [];
  List ingredientList = [];
  String currentText = "";
  String shoppingCartId = ' '; // initializing  with space
  String shoppingCartName = '';
  List<RecipeCategory> categories = RecipeCategory.getRecipeCategory();
  TextEditingController nameController = TextEditingController();
  late TextEditingController descController;
  late String _selectedRecipeCategory;
  late String recipe_id; //list of item object to work with autocomplete
  String userEmail = '';
  void getListItem_firebase(shoppingCartId) async {
    if (shoppingCartId != null) {
      await for (var snapshot
          in _firestore
              .collection('shoppinglists')
              .doc(shoppingCartId)
              .collection('listItems')
              .snapshots()) {
        for (var shoppingItem in snapshot.docs) {
          print(shoppingItem.get('itemName'));
          Provider.of<shoppingCart>(
            context,
            listen: false,
          ).addCartItemsIds(shoppingItem.get('itemId'));
        }
      }
    }
  }

  Future getData_shared_preferences_user() async {
    prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('userEmail')!;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      shoppingCartId = Provider.of<shoppingCart>(
        context,
        listen: false,
      ).shoppingCartId;
      shoppingCartName = Provider.of<shoppingCart>(
        context,
        listen: false,
      ).shoppingCartName;
      getListItem_firebase(shoppingCartId); //recheck why not work first time!
    });

    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    helper = DataBaseHelper();
    helper.getallItemstoAddinRecipe().then((itemsList) {
      setState(() {
        allItems = itemsList;
        items = allItems;
      });
    });

    var ids = json.decode(widget.recipes_items);
    print(widget.recipe_category_id);
    print(ids.join(","));
    String ingredientStr = ids.join(",");

    helper = DataBaseHelper();
    helper.getRecipeItems(ingredientStr).then((ingredientList1) {
      ingredientList = ingredientList1;
      print(ingredientList);
      var maps = Item.getListObj(ingredientList);
      selectedItems = maps;
    });

    _selectedRecipeCategory = widget.recipe_category_id;
    getData_shared_preferences_user().then((value) {});
    super.initState();
  }

  String _displayStringForOption(Item option) => ((_locale.languageCode == 'ar')
      ? option.itemNameAR
      : (_locale.languageCode == 'de')
      ? option.itemNameDE
      : option.itemName);
  @override
  Widget build(BuildContext context) {
    int _recipe_id = int.parse(widget.recipe_id);
    nameController = TextEditingController(text: widget.recipe_name);
    descController = TextEditingController(text: widget.recipe_description);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.recipe_name} '),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 15, right: 25, left: 20),
            child: badges.Badge(
              /*   badgeContent: Text(
                '${Provider.of<DataBaseHelper>(context).reqItems.length}',
                style: TextStyle(color: Colors.white),
              ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ShoppingCartScreen(this._locale)));
                },
              ),*/
              badgeContent: StreamBuilder<QuerySnapshot>(
                stream: shoppingCartId != null
                    ? _firestore
                          .collection('shoppinglists')
                          .doc(shoppingCartId)
                          .collection('listItems')
                          .snapshots()
                    : null,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    //add here a spinner
                    return Text('');
                  } else {
                    final ourItems = snapshot.data!.docs;
                    return Text(
                      '${ourItems.length}', //from firebase steam is the correct not from provider
                      style: TextStyle(color: Colors.white),
                    );
                  }
                },
              ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ShoppingCartScreen(this._locale),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            FormBuilderTextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "${DemoLocalization.of(context)!.translate('Name')}",
              ),
              name: 'text',
            ),
            FormBuilderDropdown(
              decoration: InputDecoration(
                labelText:
                    '${DemoLocalization.of(context)!.translate('RecipeCategory')}',
              ),
              items: categories.map((item) {
                return DropdownMenuItem(
                  child: new Text(
                    (this._locale != null)
                        ? (this._locale.languageCode == 'ar')
                              ? item.name_ar.toString()
                              : (this._locale.languageCode == 'de')
                              ? item.name_de.toString()
                              : item.name.toString()
                        : item.name.toString(),
                  ),
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
                    "${DemoLocalization.of(context)!.translate('description')}",
              ),
              maxLines: 5, //or null
            ),
            SizedBox(height: 10, width: 10),
            Align(
              //alignment: Alignment.centerLeft,
              child: Text(
                '${DemoLocalization.of(context)!.translate('ingredient')}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Autocomplete<Item>(
              displayStringForOption: _displayStringForOption,
              optionsBuilder: (TextEditingValue textEditingValue) {
                return items
                    .where(
                      (Item option) =>
                          option.itemNameAR.toLowerCase().startsWith(
                            textEditingValue.text.toLowerCase(),
                          ) ||
                          option.itemNameDE.toLowerCase().startsWith(
                            textEditingValue.text.toLowerCase(),
                          ) ||
                          option.itemName.toLowerCase().startsWith(
                            textEditingValue.text.toLowerCase(),
                          ),
                    )
                    .toList();
              },
              onSelected: (Item selection) {
                // this.currentText = '';
                addItemToList(selection);
                debugPrint(
                  'You just selected ${_displayStringForOption(selection)}',
                );
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
                      child: Row(
                        children: [
                          Text(
                            (this._locale.languageCode == 'ar')
                                ? '${selectedItems[index].toString().split(':')[0]} '
                                : (this._locale.languageCode == 'de')
                                ? '${selectedItems[index].toString().split(':')[1]} '
                                : '${selectedItems[index].toString().split(':')[2]} ',
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                deleteItemFromList(selectedItems[index]);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: Text(
                      '${DemoLocalization.of(context)!.translate('save')}',
                    ),
                    onPressed: () {
                      updateRecipe(_recipe_id);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: Text(
                      '${DemoLocalization.of(context)!.translate('delete')}',
                    ),
                    onPressed: () {
                      deleteRecipe(_recipe_id);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //addIngredientToShopping(ingredientList, userEmail, shoppingCartId);
          _dialogBuilder(context);
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.shopping_bag),
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

  void updateRecipe(int _recipe_id) async {
    String recipeName = nameController.text;
    String desc = descController.text;
    int categoryId = int.parse(_selectedRecipeCategory);
    print('desc ${desc}');

    print('befor add in db ${selectedItems}');
    List<String> seletctedItemsIds = selectedItems
        .map((item) => item.itemId.toString())
        .toList();
    String Ids_String = seletctedItemsIds.toString();
    print(
      Ids_String,
    ); //var a = '["one", "two", "three", "four"]';var ab = json.decode(a);
    print('categoryId ${_selectedRecipeCategory}');
    print('_recipe_id${_recipe_id}');
    if (recipeName != '') {
      await helper.updateRecipe(
        _recipe_id,
        recipeName,
        desc,
        categoryId,
        Ids_String,
      );
      Fluttertoast.showToast(
        msg: "${DemoLocalization.of(context)!.translate('saveDone')}",
      );
    }
  }

  void deleteRecipe(int _recipe_id) async {
    await helper.deleteRecipe(_recipe_id);
    Fluttertoast.showToast(
      msg: "${DemoLocalization.of(context)!.translate('DeleteDone')}",
    );
    Navigator.pop(context, true);
  }

  Future<void> addIngredientToShopping(
    ingredientList,
    userEmail,
    shoppingCartId,
  ) async {
    // add them to firebase
    for (int i = 0; i < ingredientList.length; i++) {
      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(now);

      /*ReqItem reqItem = ReqItem({
        'req_item_id': ingredientList[i].itemId,
        'req_item_amount': 0,
        'description': '',
        'req_date': formattedDate,
        'done': 0
      });*/
      // becasue we build local db and firebase store to store shopping item i forced to save even item name
      // Item meItem = Item(
      //     itemId1: ingredientList[i].itemId,
      //     itemName1: ingredientList[i].itemName,
      //     itemNameAR1: ingredientList[i].itemNameAr,
      //     itemNameDE1: ingredientList[i].itemNameDe);
      print('%%%%%%%%%%%%');
      print(ingredientList[i]);
      Item item = Item.fromMap(ingredientList[i]);
      addItemInFireStore(item, userEmail, shoppingCartId);
    }
    /*
    for (int i = 0; i < ingredientList.length; i++) {
      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(now);
      ReqItem reqItem = ReqItem({
        'req_item_id': ingredientList[i].itemId,
        'req_item_amount': 0,
        'description': '',
        'req_date': formattedDate,
        'done': 0
      });
      await helper.insertReqItem(reqItem);
    }*/
  }

  void addItemInFireStore(Item item, userEmail, shoppingCartId) {
    //! check if already exist or not
    if (shoppingCartId != null) {
      _firestore
          .collection('shoppinglists')
          .doc(shoppingCartId)
          .collection('listItems')
          .add({
            'itemId': item.itemId,
            'itemName': item.itemName,
            'itemNameAr': item.itemNameAR,
            'itemNameDe': item.itemNameDE,
            'categoryId': item.categoryId,
            // 'userId': signedInUser.uid,
            // 'userEmail': signedInUser.email,
            'userEmail': userEmail,
            'done': '0',
          });

      setState(() {
        Provider.of<shoppingCart>(
          context,
          listen: false,
        ).addCartItemsIds(item.itemId);
      });
    }
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            ' ${DemoLocalization.of(context)!.translate('titleaddIngredientToShopping')}',
          ),
          content: Text(
            ' ${DemoLocalization.of(context)!.translate('TextaddIngredientToShopping')}',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('OK'),
              onPressed: () {
                addIngredientToShopping(
                  ingredientList,
                  userEmail,
                  shoppingCartId,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
