import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_share/flutter_share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:home_order_app/Localization/demo_Localization.dart';
import 'package:home_order_app/Localization/language_constants.dart';
import 'package:home_order_app/database_helper.dart';
import 'package:home_order_app/models/shoppingCart.dart';
import 'package:home_order_app/widgets/LabeledCheckboxShoppingList.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_order_app/screens/add_person_screen.dart';

/*   read here
 this vision connect to firestore
so we keep item in local database
but shopping will be in fire store couldly
so add new item to shopping list will add just in firebase and not locally 
will will stop deal with requested_item
 */
class ShoppingItemsList extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ShoppingItemsList> {
  String shoppingCartId = '';
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User signedInUser; //this will give us user email
  late DataBaseHelper helper;
  TextEditingController teSeach = TextEditingController();
  Locale? _locale;
  var allItems = [];
  var items = [];
  int reqItemAmount = 0;
  String reqDate = '';
  String description = '';
  List<Category> categorys = Category.getCategory();
  var itemIds;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // no need here to remove
      shoppingCartId = Provider.of<shoppingCart>(
        context,
        listen: false,
      ).shoppingCartId;
    });
    super.initState();
    getCurrentUser();
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        print(signedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void itemCartSteam(cartid) async {
    await for (var snapshot in _firestore
        .collection('shoppinglists')
        .doc(cartid)
        .collection('listItems')
        .snapshots()) {
      for (var shoppingItem in snapshot.docs) {
        print(shoppingItem.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context),
      home: Scaffold(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary, // Color.fromARGB(255, 186, 199, 206),
        appBar: AppBar(
          title: Text(
            ' ${DemoLocalization.of(context)!.translate('Shopping_List')}',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
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
                        .collection('listItems')
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  List<LabeledCheckboxShopping> ourItemWidgets = [];
                  if (!snapshot.hasData) {
                    //add here a spinner
                  }
                  final ourItems = snapshot.data!.docs;
                  for (var ouritem in ourItems) {
                    final ourItemId = ouritem.get('itemId');
                    final ourItemName = ouritem.get('itemName');
                    final ourItemNameAr = ouritem.get('itemNameAr');
                    final ourItemNameDe = ouritem.get('itemNameDe');
                    final ourItemNDone = ouritem.get('done');
                    final snapshotreference = ouritem.reference;
                    final ourId = ouritem.id;
                    final ourItemWidget = LabeledCheckboxShopping(
                      label: (this._locale!.languageCode == 'ar')
                          ? ourItemNameAr
                          : (this._locale!.languageCode == 'de')
                              ? ourItemNameDe
                              : ourItemName,
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      value: ourItemNDone != '0' ? true : false,
                      onChanged: (bool newValue) {
                        setState(() {
                          clickShoppingItemFirebase(ourItemNDone, ourId);
                        });
                      },
                      deletefromOurList: (DismissDirection direction) {
                        setState(() {
                          print(ouritem.reference);
                          ouritem.reference.delete();
                          try {} catch (error) {}
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
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(add_person_screen.screenRoute);
                },
                icon: const Icon(Icons.person_add),
                label: Text(
                  ' ${DemoLocalization.of(context)!.translate('invite')}',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    // style: style,
                    onPressed: () {
                      setState(() {
                        deleteAllItemInFireStore(
                          Provider.of<shoppingCart>(
                            context,
                            listen: false,
                          ).shoppingCartId,
                        );
                      });
                    },
                    child: Text(
                      ' ${DemoLocalization.of(context)!.translate('Finish_Delete')}',
                    ),
                  ),
                  // Spacer(),
                  ElevatedButton.icon(
                    onPressed: sharePdfFile,
                    icon: const Icon(Icons.share),
                    label: Text(
                      ' ${DemoLocalization.of(context)!.translate('Share_This_List')}',
                    ),
                  ),
                  // Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  clickShoppingItemFirebase(done, id) async {
    var newDone = '0';
    if (done == '0') newDone = '1';
    var ref = _firestore
        .collection('shoppinglists')
        .doc(Provider.of<shoppingCart>(context, listen: false).shoppingCartId)
        .collection('listItems')
        .doc(id)
        .update({'done': newDone});
  }

  bool checkDone(done) {
    return done == 1 ? true : false;
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(Icons.delete, color: Colors.white),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(width: 20),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  isDonShoppingItem(done) {
    if (done == 1)
      return true;
    else {
      print('it is false');
      return false;
    }
  }

  clickShoppingItem(id, done) async {
    try {
      if (done == 1) {
        await helper.unDonShoppingItem(id);
      } else {
        await helper.DonShoppingItem(id);
      }
    } catch (error) {
      // Scaffold.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('update failed!'),
      //   ),
      // );
    }
  }

  deleteAllItemInFireStore(shoppingCartId) async {
    try {
      if (shoppingCartId != null) {
        var doc = await _firestore
            .collection('shoppinglists')
            .doc(shoppingCartId)
            .collection('listItems')
            .get()
            .then((snapshot) {
          for (var values in snapshot.docs) {
            values.reference.delete();
            setState(() {
              Provider.of<shoppingCart>(
                context,
                listen: false,
              ).deleteCartAllItemsIds();
            });
          }
        });
      }
    } catch (error) {}
  }

  //----------------------------------------------------
  Future<File> writeFile() {
    // Write the variable as a string to the file.
    return writeShoppingList(items);
  }

  Future<void> shareFile() async {
    final path = await _localPath;
    final file = writeShoppingList(items);
    readFile();
    Share.share('$path/shoppingList.txt');
  }

  Future<void> sharePdfFile() async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    final path = await _localPath;
    final pdf = pw.Document();
    //for arbic
    final arabicfont = await rootBundle.load(
      "assets/fonts/ElMessiri-Regular.ttf",
    );
    final enfont = await rootBundle.load("assets/fonts/ElMessiri-Regular.ttf");
    dynamic ttf;
    if (this._locale!.languageCode == 'ar') {
      ttf = pw.Font.ttf(arabicfont);
    } else {
      ttf = pw.Font.ttf(enfont);
    }
    //
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(text: 'Shopping List: ${formattedDate}'),
              pw.Table(
                border: pw.TableBorder(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('#', style: pw.TextStyle(fontSize: 14)),
                          pw.Divider(thickness: 1),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Name', style: pw.TextStyle(fontSize: 14)),
                          pw.Divider(thickness: 1),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Amount', style: pw.TextStyle(fontSize: 14)),
                          pw.Divider(thickness: 1),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Unit', style: pw.TextStyle(fontSize: 14)),
                          pw.Divider(thickness: 1),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Category Name',
                            style: pw.TextStyle(fontSize: 14),
                          ),
                          pw.Divider(thickness: 1),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Check', style: pw.TextStyle(fontSize: 14)),
                          pw.Divider(thickness: 1),
                        ],
                      ),
                    ],
                  ),

                  // Now the next table
                  for (int i = 0; i < items.length; i++)
                    buildRowsForInventoryItems(items[i], i, ttf),
                ],
              ),
              pw.Divider(color: PdfColors.white, thickness: 10),
              //Details
            ],
          );
        },
      ),
    ); // Page
    final file = await _localPdfFile;
    print(file.path);
    await file.writeAsBytes(await pdf.save());
    Share.share('$path/shoppingList.pdf');
  }

  pw.TableRow buildRowsForInventoryItems(dynamic item, int index, dynamic ttf) {
    List<pw.Column> itemList = [];
    index++;
    String name = '';
    if (this._locale!.languageCode == 'ar') {
      name = item['item_name_ar'].toString();
    } else if (this._locale!.languageCode == 'de')
      name = item['item_name_de'].toString();
    else
      name = item['item_name'].toString();

    String amount = item['amount'].toString();
    final unit = item['unit'].toString();
    final Categoyname = item['category_id'].toString(); // to get categorys[]
    print('amount ${amount}');
    if (amount == null) amount = '';

    itemList.add(pw.Column(children: [pw.Text(index.toString())]));
    itemList.add(
      pw.Column(
        children: [
          // if (this._locale!.languageCode == 'ar')  {//textDirection: TextDirection.RTL
          pw.Text(
            name,
            style: pw.TextStyle(font: ttf),
            textDirection: (this._locale!.languageCode == 'ar')
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
          ),
          //  }
        ],
      ),
    );
    itemList.add(pw.Column(children: [pw.Text(amount != null ? amount : '')]));
    itemList.add(pw.Column(children: [pw.Text(unit != null ? unit : '')]));
    itemList.add(
      pw.Column(children: [pw.Text(Categoyname != null ? Categoyname : '')]),
    );
    itemList.add(pw.Column(children: [pw.Checkbox(name: '', value: false)]));
    return pw.TableRow(children: itemList);
  }

  pw.Padding paddedHeadingTextCell(String textContent) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(4),
      child: pw.Column(
        children: [pw.Text(textContent, style: pwTableHeadingTextStyle())],
      ),
    );
  }

  pw.TextStyle pwTableHeadingTextStyle() =>
      pw.TextStyle(fontWeight: pw.FontWeight.bold);

  pw.Padding paddedTextCell(String textContent) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [pw.Text(textContent, textAlign: pw.TextAlign.left)],
      ),
    );
  }

  Future<void> share() async {
    Share.share('https://flutter.dev/');
  }

  Future<String> get _localPath async {
    //final directory = await getTemporaryDirectory();
    final directory = await getExternalStorageDirectory();
    print('================path');
    print(directory!.absolute.path);
    return (directory.absolute.path);
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/shoppingList.txt');
  }

  Future<File> get _localPdfFile async {
    final path = await _localPath;
    return File('$path/shoppingList.pdf');
  }

  Future<String> readFile() async {
    String contents = '';
    try {
      final file = await _localFile;

      // Read the file
      contents = await file.readAsString();
      return contents.toString();
      // return int.parse(contents);
    } catch (e) {
      print('Couldnt read file');
    }
    return contents;
  }

  Future<File> writeText() async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('hallo');
  }

  Future<File> writeShoppingList(items) async {
    final file = await _localFile;
    String listString = '';
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    listString = '${formattedDate}\n';
    for (var i = 0; i < items.length; i++) {
      listString +=
          '${i + 1}-  ${items[i]['item_name']}  ${items[i]['req_item_amount']}  ${items[i]['unit']} \n';
    }
    const Text(
      'No, we need bold strokes. We need this plan.',
      style: TextStyle(fontWeight: FontWeight.bold),
    );
    return file.writeAsString(listString);
  }
}
