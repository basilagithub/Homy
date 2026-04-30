import 'package:badges/badges.dart' as badges; // ضع prefix
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/database_helper.dart';
import 'package:home_order_app/models/item.dart';
import 'package:home_order_app/models/req_item.dart';
import 'package:home_order_app/models/shoppingCart.dart';
import 'package:home_order_app/screens/shopping_cart_screen.dart'
    hide shoppingCart;
import 'package:home_order_app/widgets/LabeledCheckbox.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryItemsWidget extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String categoryNameAr;
  final String categoryNameDe;
  // Locale? _locale;
  CategoryItemsWidget(
    //Locale this._locale,
    String this.categoryId,
    String this.categoryName,
    String this.categoryNameAr,
    String this.categoryNameDe,
  );

  @override
  _CategoryItemsWidgetState createState() => _CategoryItemsWidgetState();
}

class _CategoryItemsWidgetState extends State<CategoryItemsWidget> {
  Locale? _locale;
  late DataBaseHelper helper;
  TextEditingController teSeach = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String shoppingCartId = '';
  String shoppingCartName = '';
  late SharedPreferences prefs;
  String userEmail = '';
  var allCategorycategoryItems = [];
  var categoryItems = [];
  var allReqcategoryItems = [];
  var AllReqcategoryItemsIds = [];
  var ShoppingcategoryItemsList = [];
  int reqItemAmount = 0;
  String reqDate = '';
  String description = '';
  int done = 0;
  void getShoppingCartItem_firebase(shoppingCartId) async {
    print('------insid getListItem_firebase$shoppingCartId] ');
    //if (shoppingCartId != null) {

    if (shoppingCartId.isNotEmpty) {
      await for (var snapshot in _firestore
          .collection('shoppinglists')
          .doc(shoppingCartId)
          .collection('listItems')
          .snapshots()) {
        for (var shoppingItem in snapshot.docs) {
          print(shoppingItem.get('itemName'));
          Provider.of<shoppingCart>(
            context,
            //  listen: false,2026
          ).addCartItemsIds(shoppingItem.get('itemId'));
        }
      }
    }
  }

  Future getData_shared_preferences_user() async {
    prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('userEmail') ?? '';
    // dont get cart id from prefs , just from provider (becaue could came form page lists )
  }

  @override
  void initState() {
    helper = DataBaseHelper();
    helper.allItemsbyCategory(widget.categoryId).then((categoryItemsList) {
      setState(() {
        allCategorycategoryItems = categoryItemsList;
        categoryItems = allCategorycategoryItems;
      });
    });
    // Provider.of<shoppingCart>(context, listen: false).setCartItems(cartItemIds);
    getData_shared_preferences_user();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      shoppingCartId = Provider.of<shoppingCart>(
        context,
        listen: false,
      ).shoppingCartId;
      shoppingCartName = Provider.of<shoppingCart>(
        context,
        listen: false,
      ).shoppingCartName;
      getShoppingCartItem_firebase(
        Provider.of<shoppingCart>(context, listen: false).shoppingCartId,
      );
    });
    //helper.getRequestedItemsIds().then((ShoppingcategoryItemsList) {});
    super.initState();

    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (_locale!.languageCode == 'ar')
              ? widget.categoryNameAr
              : (this._locale!.languageCode == 'de')
                  ? widget.categoryNameDe
                  : widget.categoryName +
                      '_' +
                      Provider.of<shoppingCart>(
                        context,
                        listen: false,
                      ).shoppingCartName,
        ),
      ),
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 100,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/category_image/test.png',
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  color: Colors.amber,
                  margin: EdgeInsets.only(top: 15, right: 25, left: 20),
                  child: badges.Badge(
                    badgeContent: StreamBuilder<QuerySnapshot>(
                      stream: shoppingCartId.isNotEmpty
                          ? _firestore
                              .collection('shoppinglists')
                              .doc(shoppingCartId)
                              .collection('listItems')
                              .snapshots()
                          : const Stream.empty(),
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
                            builder: (context) =>
                                ShoppingCartScreen(this._locale),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categoryItems.length,
              itemBuilder: (context, i) {
                Item item = Item.fromMap(categoryItems[i]);
                return LabeledCheckbox(
                  label: (this._locale!.languageCode == 'ar')
                      ? (item.itemNameAR)
                      : (this._locale!.languageCode == 'de')
                          ? (item.itemNameDE)
                          : (item.itemName),
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  value: Provider.of<shoppingCart>(
                    context,
                    listen: false,
                  ).checkItemExist(item.itemId), //checkExisted(item.itemId),
                  onChanged: (bool newValue) {
                    setState(() {
                      clickItem(
                        newValue,
                        item,
                        Provider.of<shoppingCart>(
                          context,
                          listen: false,
                        ).shoppingCartId,
                      );
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  checkExisted(int id) {
    AllReqcategoryItemsIds = Provider.of<DataBaseHelper>(
      context,
      listen: false,
    ).reqItems;
    final element = AllReqcategoryItemsIds.firstWhere(
      (e) => e['req_item_id'] == id,
      orElse: () => {"req_item_id": -1},
    );
    print(element);
    if (element.values.first != -1)
      return true;
    else
      return false;
  }

  clickItem(newValue, item, shoppingCartId) async {
    ReqItem reqItem = ReqItem({
      'req_item_id': item.itemId,
      'req_item_amount': reqItemAmount,
      'description': description,
      'req_date': reqDate,
      'done': done,
    });
    if (newValue == true) {
      // int id = await helper.insertReqItem(reqItem);
      addItemInFireStore(item, userEmail, shoppingCartId);
    } else {
      //delete
      deleteItemInFireStore(item, shoppingCartId);
    }
  }

  void addItemInFireStore(Item item, userEmail, shoppingCartId) {
    print('----------------in addItemInFireStore $shoppingCartId');
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

  void deleteItemInFireStore(Item item, shoppingCartId) async {
    print('deleteItemInFireStore $shoppingCartId');
    if (shoppingCartId != null) {
      var doc = await _firestore
          .collection('shoppinglists')
          .doc(shoppingCartId)
          .collection('listItems')
          .where('itemId', isEqualTo: item.itemId)
          .get()
          .then((snapshot) {
        for (var values in snapshot.docs) {
          values.reference.delete();
          setState(() {
            Provider.of<shoppingCart>(
              context,
              listen: false,
            ).deleteCartItemsIds(item.itemId);
          });
        }
      });
    }
  }
}
