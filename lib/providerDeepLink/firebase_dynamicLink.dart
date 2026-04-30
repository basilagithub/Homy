import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_order_app/screens/ListCartsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

//https://firebase.flutter.dev/docs/dynamic-links/create
//https://www.youtube.com/watch?v=aBrRJqrQTpQ  in last
//!! need to apply for ios :)
//!! need to write some function init... to deal with all cases for app  https://www.youtube.com/watch?v=UJ6IQGkoEgA
class FirebaseDynamicLinkService {
  late SharedPreferences prefs;
  final _firestore = FirebaseFirestore.instance;

  static Future<String> createDynamicLink(String cid) async {
    String _linkCart;
    print("https://aladdin.com/shoppigcart?cid=$cid");
    final dynamicLinkParams = DynamicLinkParameters(
      // link: Uri.parse("https://homeorderapp.page.link/dmCn"),
      //link: Uri.parse("https://www.aladdin.com/shoppigcart?cid=$cid"),
      link: Uri.parse("https://aladdin.com/shoppigcart?cid=$cid"), //without www
      // "https://homeorderapp.page.link?cid=${cid}"), //get form dynamic link in firebase consol https://www.youtube.com/watch?v=UJ6IQGkoEgA
      // uriPrefix: "https://example.page.link",
      uriPrefix:
          "https://homeorderapp.page.link", //com.aladdin.homy_order_app",
      androidParameters: const AndroidParameters(
        // packageName: "home_order_app",
        packageName: "com.aladdin.homy_order_app",
      ), //"com.aladdin.app.android"
      iosParameters: const IOSParameters(
        bundleId: "com.aladdin.homy_order_app.ios",
      ), //com.aladdin.app.ios
    );
    final dynamicLink = await FirebaseDynamicLinks.instance.buildLink(
      dynamicLinkParams,
    );

    _linkCart = dynamicLink.toString();
    return _linkCart;
  }

  //---------------------------------------------------------------------------------------------
  Future<void> initDynamicLink(
    BuildContext context,
    String userId,
    String userEmail,
  ) async {
    // 🔹 Handle when app is OPEN
    FirebaseDynamicLinks.instance.onLink.listen((data) {
      _handleDeepLink(data.link, context, userId, userEmail);
    }).onError((error) {
      print("Dynamic Link Error: $error");
    });

    // 🔹 Handle when app is CLOSED
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    if (data != null) {
      _handleDeepLink(data.link, context, userId, userEmail);
    }
  }

  //---------------------------------------------------------------------------------------------
  Future<void> _handleDeepLink(
    Uri deepLink,
    BuildContext context,
    String userId,
    String userEmail,
  ) async {
    final isCart = deepLink.pathSegments.contains('shoppigcart');

    if (!isCart) return;

    final cid = deepLink.queryParameters['cid'];

    if (cid == null || cid.isEmpty) {
      print("Invalid CID");
      return;
    }

    try {
      await addCartToUser(userId, userEmail, cid);

      if (context.mounted) {
        Navigator.pushNamed(
          context,
          list_carts_screen.screenRoute,
          arguments: {'userId': userId},
        );
      }
    } catch (e) {
      print("Error handling deep link: $e");
    }
  }

  //----------------------------------------------------------------------------------------------
  Future<void> addCartToUser(
    String userId,
    String userEmail,
    String cid,
  ) async {
    final query = await _firestore
        .collection("user")
        .doc(userId)
        .collection('userShoppinglists')
        .where('shoppinglistId', isEqualTo: cid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      print("Cart already exists");
      return;
    }

    // 🔹 Get cart info safely
    final cartDoc = await _firestore.collection('shoppinglists').doc(cid).get();

    if (!cartDoc.exists) {
      print("Cart does not exist");
      return;
    }

    final cartName = cartDoc.get('shoppingListName');

    // 🔹 Add to user
    await _firestore
        .collection('user')
        .doc(userId)
        .collection('userShoppinglists')
        .add({
      'shoppinglistId': cid,
      'shoppingListName': cartName,
    });

    // 🔹 Add  cart to user
    await _firestore
        .collection('shoppinglists')
        .doc(cid)
        .collection('members')
        .add({
      'userId': userId,
      'userEmail': userEmail,
    });
  }
  //----------------------------------------------------------------------------------------------

  /*Future addCartToUser(userId, userEmail, cid) async {
    //add if not already exists
    var docRef = await _firestore
        .collection("user")
        .doc(userId)
        .collection('userShoppinglists')
        .where('shoppinglistId', isEqualTo: cid)
        .limit(1);
    docRef.get().then((documents) {
      // final List<dynamic> documents = docRef.get() as List;
      print(
        'value.docs.length ${documents.docs.length} !!!!!!!!!!!!!!!111userId=$userId cid=$cid',
      );
      
      if (documents.docs.length == 0) //not found
      {
        print("No such document!");
        //get cart name to add it
        _firestore.collection('shoppinglists').doc(cid).get().then((value) {
          String CartName = value.get('shoppingListName');
          _firestore
              .collection('user')
              .doc(userId)
              .collection('userShoppinglists')
              .add({'shoppinglistId': cid, 'shoppingListName': CartName});
        });
        // add cart to user
        _firestore
            .collection('shoppinglists')
            .doc(cid)
            .collection('members')
            .add({'userId': userId, 'userEmail': userEmail});
      }
    });
  }*/
}
