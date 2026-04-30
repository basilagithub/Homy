import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
//import 'package:flutter_share/flutter_share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/models/shoppingCart.dart';
import 'package:home_order_app/providerDeepLink/firebase_dynamicLink.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class add_person_screen extends StatefulWidget {
  static const String screenRoute = '/add_person_screen';

  const add_person_screen({Key? key}) : super(key: key);

  @override
  _add_personScreenState createState() => _add_personScreenState();
}

class _add_personScreenState extends State<add_person_screen> {
  final _firestore = FirebaseFirestore.instance;
  late SharedPreferences prefs;
  String userId = '';
  String shoppingCartId = '';

  TextEditingController nameController = TextEditingController();
  void initState() {
    getuserId_shared_preferences_user();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      shoppingCartId = Provider.of<shoppingCart>(
        context,
        listen: false,
      ).shoppingCartId;
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${DemoLocalization.of(context)!.translate('shareShopping')} ',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            // FormBuilderTextField(
            //     controller: nameController,
            //     decoration: InputDecoration(
            //         labelText:
            //             "${DemoLocalization.of(context)!.translate('enter_email_adress')}"),
            //     name: 'text'),
            IconButton(
              icon: const Icon(Icons.add, size: 35),
              onPressed: () {
                // String generateDeepLink = await    FirebaseDynamicLinkService.createDynamicLink('hi')  ;
                //getUrl('X6NdHikFALdYa5beNTI7').then((value) {
                getUrl().then((value) {
                  print(value);
                  shareInvitationLink(value);
                });

                //1 add to my fiend
                //2 send email
                //3 show it in list here
              },
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                '${DemoLocalization.of(context)!.translate('invitationNote')}',
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: shoppingCartId != null
                  ? _firestore
                        .collection('shoppinglists')
                        .doc(
                          Provider.of<shoppingCart>(
                            context,
                            listen: false,
                          ).shoppingCartId,
                        )
                        .collection('members')
                        .snapshots()
                  : null,
              builder: (context, snapshot) {
                List<LabeledListTile> ourItemWidgets = [];
                if (!snapshot.hasData) {
                  //add here a spinner
                }
                final ourItems = snapshot.data!.docs;
                for (var ouritem in ourItems) {
                  final ourItemId = ouritem.get('userId'); //userEmail
                  final userEmail = ouritem.get('userEmail');
                  final ourItemWidget = LabeledListTile(
                    label: '${userEmail}',
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    deletefromOurList: () {
                      setState(() {
                        deleteSubscriber(userId, shoppingCartId);
                      });
                    },
                  );
                  ourItemWidgets.add(ourItemWidget);
                }
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: ListView(children: ourItemWidgets),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future getUrl() async {
    String cid = Provider.of<shoppingCart>(
      context,
      listen: false,
    ).shoppingCartId;
    String generateDeepLink =
        await FirebaseDynamicLinkService.createDynamicLink(cid);
    return generateDeepLink;
  }

  /*note we create shopping list in 2 place registeration and in screen add shopping list
note2 : in sharing my be by whatsap so we will not depends on userEmail but on userid, so we will send link by shopping id by email or whatsup 

 */
  addShoppingListIdToUer(friendEmail) {
    // get useid from friendEmail no may be not register yet
    // add to frienduser shoppinglist
    // send email to him
  }

  Future<void> shareInvitationLink(url) async {
    Share.share(url);
    //   await FlutterShare.share(
    //     title: 'Homy App',
    //     text: DemoLocalization.of(context)!.translate('invitationText'),
    //     linkUrl: url,
    //     chooserTitle: 'Homy App',
    //   );
  }

  showShoppingListMemebers() {}
  Future getuserId_shared_preferences_user() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId')!;
    print(';;;;;;;;;;;;;;;;;;$userId');
  }

  //2 place need to remove
  void deleteSubscriber(userId, cid) async {
    if ((cid != null) && (userId != null)) {
      var doc = await _firestore
          .collection('shoppinglists')
          .doc(cid)
          .collection('members')
          .where('userId', isEqualTo: userId)
          .get()
          .then((snapshot) {
            for (var values in snapshot.docs) {
              values.reference.delete();
            }
          });

      var doc2 = await _firestore
          .collection('user')
          .doc(userId)
          .collection('userShoppinglists')
          .where('shoppinglistId', isEqualTo: cid)
          .get()
          .then((snapshot) {
            for (var values in snapshot.docs) {
              values.reference.delete();
            }
          });
    }
  }
}
//----------------------------

class LabeledListTile extends StatelessWidget {
  const LabeledListTile({
    super.key,
    required this.label,
    required this.padding,
    required this.deletefromOurList,
  });

  final String label;
  final EdgeInsets padding;
  final Function deletefromOurList;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: padding,
        child: ListTile(
          title: Text(label),
          trailing: IconButton(
            icon: const Icon(Icons.remove, color: Colors.black, size: 30),
            onPressed: () {
              deletefromOurList();
            },
          ),
          //               Icon(
          //   Icons.remove,
          //   color: Colors.black,
          //   size: 30,
          // ),
        ),
      ),
    );
  }
}
