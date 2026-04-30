import 'package:badges/badges.dart' as badges; // ضع prefix;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/database_helper.dart';
import 'package:home_order_app/models/item.dart';
import 'package:home_order_app/models/req_item.dart';
import 'package:home_order_app/models/shoppingCart.dart';
import 'package:home_order_app/screens/shopping_cart_screen.dart';
import 'package:home_order_app/service/add_mob_service.dart';
import 'package:home_order_app/widgets/LabeledCheckbox.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// note: this page deal wiht provider just not preferance
class ItemsList extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ItemsList> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User signedInUser; //this will give us user email
  late SharedPreferences prefs;
  String userEmail = '';
  String shoppingCartId = ' '; // initializing  with space
  String shoppingCartName = '';
  BannerAd? _banner;
  late DataBaseHelper helper;
  TextEditingController teSeach = TextEditingController();
  Locale? _locale;
  var allItems = [];
  var items = [];
  var allReqItems = [];
  var AllReqItemsIds = [];
  var ShoppingItemsList = [];
  int reqItemAmount = 0;
  String reqDate = '';
  String description = '';
  int done = 0;

  // void getTtemCartSteam(cartid) async {
  //   if (cartid != null)
  //     await for (var snapshot in _firestore
  //         .collection('shoppinglists')
  //         .doc(cartid)
  //         .collection('listItems')
  //         .snapshots()) {
  //       for (var shoppingItem in snapshot.docs) {
  //         print(shoppingItem.data());
  //       }
  //     }
  // }

  Future getData_shared_preferences_user() async {
    prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('userEmail') ?? '';
    // dont get cart id from prefs , just from provider (becaue could came form page lists )
  }

  void getListItem_firebase(shoppingCartId) async {
    if (shoppingCartId != null && shoppingCartId.isNotEmpty) {
      await for (var snapshot in _firestore
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

  @override
  void dispose() {
    _banner?.dispose();
    teSeach.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
    helper = DataBaseHelper();

    helper.allItems1().then((itemsList) {
      setState(() {
        allItems = itemsList;
        items = allItems;
      });
    });

    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });

    getData_shared_preferences_user().then((value) {});

    _createBannerAd();
  }

  void filterSeach(String query) async {
    var dummySearchList = allItems;
    if (query.isEmpty) {
      setState(() => items = allItems);
      return;
    }
    if (query != null) {
      if (query.isNotEmpty) {
        var dummyListData = <dynamic>[];
        dummySearchList.forEach((item) {
          var My_item = Item.fromMap(item);
          if (My_item.itemName.toLowerCase().contains(query.toLowerCase()) ||
              My_item.itemNameAR.toLowerCase().contains(query.toLowerCase()) ||
              My_item.itemNameDE.toLowerCase().contains(query.toLowerCase())) {
            dummyListData.add(item);
            print(
              'My_item.itemName.toLowerCase().${My_item.itemName.toLowerCase()}',
            );
          }
        });
        setState(() {
          items = [];
          items.addAll(dummyListData);
        });
        return;
      } else {
        setState(() {
          items = [];
          items = allItems;
        });
      }
    } else {
      setState(() {
        items = [];
        items = allItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          filterSeach(value);
                        });
                      },
                      controller: teSeach,
                      decoration: InputDecoration(
                        hintText:
                            ' ${DemoLocalization.of(context)!.translate('Search')}',
                        labelText:
                            ' ${DemoLocalization.of(context)!.translate('Search')}',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15, right: 25, left: 20),
                  child: badges.Badge(
                    badgeContent: StreamBuilder<QuerySnapshot>(
                      stream: shoppingCartId != null
                          ? _firestore
                              .collection('shoppinglists')
                              .doc(shoppingCartId)
                              .collection('listItems')
                              .snapshots()
                          : const Stream
                              .empty(), // <- empty stream instead of null
                      // null,
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
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  Item item = Item.fromMap(items[i]);
                  return LabeledCheckbox(
                    label: (this._locale!.languageCode == 'ar')
                        ? (item.itemNameAR)
                        : (this._locale!.languageCode == 'de')
                            ? (item.itemNameDE)
                            : (item.itemName),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    value: Provider.of<shoppingCart>(
                      context,
                    ).checkItemExist(item.itemId),
                    onChanged: (bool newValue) {
                      setState(() {
                        clickItem(newValue, item, shoppingCartId);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _banner == null
            ? Container()
            : Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 52,
                child: AdWidget(ad: _banner!),
              ),
      ),
    );
  }

  checkExisted(int id) {
    //stop deal with loacal db for shop cart
    AllReqItemsIds = Provider.of<DataBaseHelper>(
      context,
      listen: false,
    ).reqItems;
    final element = AllReqItemsIds.firstWhere(
      (e) => e['req_item_id'] == id,
      orElse: () => {"req_item_id": -1},
    );
    print(element);
    if (element.values.first != -1)
      return true;
    else
      return false;
  }

  // becasue we build local db and firebase store to store shopping item i forced to save even item name
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

  onTapListTile(newValue, item) {
    // not finish must change color and check list value and add or delete
    bool isExisted = checkExisted(item.itemId);
    if (isExisted) {
    } else {}
  }

  void _createBannerAd() {
    _banner = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: AdMobService.bannerAdUnitId!,
      listener: AdMobService.bannerListener,
      request: const AdRequest(),
    )..load();
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

  void deleteItemInFireStore(Item item, shoppingCartId) async {
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
