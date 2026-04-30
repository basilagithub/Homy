//import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:home_order_app/models/item.dart';
import 'package:home_order_app/models/req_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class DataBaseHelper extends ChangeNotifier {
  static final DataBaseHelper _instance = DataBaseHelper.internal();
  factory DataBaseHelper() => _instance;
  DataBaseHelper.internal();
  late Database db;

  List<dynamic> reqItems = [];
  Future<Database> init() async {
    print('___________in db helper init');
    io.Directory applicationDirectory =
        await getApplicationDocumentsDirectory();

    String dbPathItem =
        // path.join(applicationDirectory.path, "englishDictionary.db");
        path.join(applicationDirectory.path, "home_order_db.db");

    bool dbHomeOrder = await io.File(dbPathItem).exists();

    if (!dbHomeOrder) {
      // Copy from asset
      ByteData data =
          await rootBundle.load(path.join("assets", "home_order_db.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await io.File(dbPathItem).writeAsBytes(bytes, flush: true);
    }

    this.db = await openDatabase(dbPathItem);

    notifyListeners();
    return this.db;
  }

  Future<List> allItems1() async {
    Database db = await init();
    //db.rawQuery('select * from courses');
    return db.query('item');
  }

  Future<void> insert(String table, Map<String, Object> data) async {
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getData(String table) async {
    return await db.query(table);
  }

  Future<List> allItemsbyCategory(String categoryId) async {
    Database db = await init();
    return db
        .rawQuery('SELECT * FROM  item where category_id = ?', [categoryId]);
  }

  ///-----------section of requesting---------------------///
  Future<int> insertReqItem(ReqItem reqItem) async {
    // old version no need to requested_item table
    Database db = await init();
    int id;
    List<dynamic> foundItems = await selectRequestedItems(reqItem.reqItemId)
        as List; // i add await to handel error Unhandled Exception: type 'Future<List<dynamic>>' is not a subtype of type 'List<dynamic>' in type cast
    if (foundItems.length == 0) {
      id = await db.insert('requested_item', reqItem.toMap());
    } else
      id = -1; //not inserted casue already in db
    // show the results: print all rows in the db
    reqItems = await allRequestedItems() as List;
    notifyListeners();
    return id;
  }

  Future<List> allRequestedItems() async {
    Database db = await init();
    return db.query('requested_item');
  }

  fillReqItemsList() {
    reqItems = allRequestedItems() as List;
    notifyListeners();
  }

  Future<List> getRequestedItems() async {
    Database db = await init();
    return db.query('req_item_view');
  }

  Future<List> getRequestedItemsIds() async {
    // old version no need to requested_item table
    Database db = await init();
    return db.rawQuery('SELECT req_item_id FROM "requested_item"');
  }

  Future<int> deleteRequestedItems(int id) async {
    // old version no need to requested_item table
    Database db = await init();
    Future<int> id2 =
        db.delete('requested_item', where: 'req_item_id = ?', whereArgs: [id]);
    reqItems = await getRequestedItems() as List;
    notifyListeners();
    return id2;
  }

  Future<List> selectRequestedItems(int id) async {
    // old version no need to requested_item table
    Database db = await init();
    return db.rawQuery(
        'SELECT req_item_id FROM  requested_item where req_item_id = ?', [id]);
  }

  Future<int> deleteAllRequestedItems() async {
    // old version no need to requested_item table
    Database db = await init();
    Future<int> id2 = db.delete('requested_item');
    reqItems = await getRequestedItems() as List;
    notifyListeners();
    return id2;
  }

  Future<int?> getReqItemAmount() async {
    Future<int> count;
    Database db = await init();
    //amount = db.rawQuery('SELECT COUNT(*) FROM "requested_item"') as Future<int>;
    count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM requested_item'))
        as Future<int>;
    return count;

    //int count = Sqflite.firstIntValue(        await db.rawQuery('SELECT COUNT(*) FROM table_name'));
  }

  Future<void> DonShoppingItem(int id) async {
    // old version no need to requested_item table
    Database db = await init();
    db.rawUpdate(
        'update requested_item   set done= ?  where req_item_id = ?', [1, id]);
    reqItems = await getRequestedItems() as List;
    notifyListeners();
  }

  Future<void> unDonShoppingItem(int id) async {
    // old version no need to requested_item table
    Database db = await init();
    db.rawUpdate(
        'update requested_item   set done= ?  where req_item_id = ?', [0, id]);
    reqItems = await getRequestedItems() as List;
    notifyListeners();
  }

  //--------------------settings-------------------------------------------------
  Future<void> insertNewItemInSettings(String itemName, int categoryId) async {
    Database db = await init();
    db.rawInsert(
        'INSERT INTO item(item_name,item_name_ar,item_name_de, category_id) VALUES(?,?,?, ?)',
        [itemName, itemName, itemName, categoryId]);
    notifyListeners();
  }

  Future<List> getItemAddedByUserList() async {
    //can get all item added by user by its id 334
    Database db = await init();
    return db.query('item', where: 'item_id >  334');
  }

  Future<int> deletUsedItemFromSettings(int id) async {
    Database db = await init();
    Future<int> id2 = db.delete('item', where: 'item_id = ?', whereArgs: [id]);
    reqItems = await getRequestedItems() as List;
    notifyListeners();
    return id2;
  }

  Future<List<Item>> getallItemstoAddinRecipe() async {
    Database db = await init();
    final List<Map<String, dynamic>> maps = await db.query('item');

    return List.generate(maps.length, (i) {
      return Item(
          itemId1: maps[i]['item_id'],
          itemName1: maps[i]['item_name'],
          itemNameAR1: maps[i]['item_name_ar'],
          itemNameDE1: maps[i]['item_name_de']);
    });
  }

  Future<void> insertRecipe(recipeName, desc, categoryId, Ids_String) async {
    Database db = await init();
    db.rawInsert(
        'INSERT INTO recipe(recipe_name,recipe_desc,recipe_items,recipe_category_id) VALUES(?,?,?, ?)',
        [
          recipeName,
          desc,
          Ids_String,
          categoryId,
        ]);
    notifyListeners();
  }

  Future<List> getRecipes() async {
    Database db = await init();
    return db.query('recipe');
  }

  Future<List> getRecipeItems(String listItemId) async {
    Database db = await init();
    return db.rawQuery('SELECT * FROM  item where item_id in ($listItemId)');
  }

  Future<void> updateRecipe(
      id, recipeName, desc, categoryId, Ids_String) async {
    print('update..........${categoryId}');
    Database db = await init();
    db.rawUpdate(
        'update recipe   set recipe_name=?,recipe_desc=?,recipe_items=?,recipe_category_id=?  where recipe_id = ?',
        [recipeName, desc, Ids_String, categoryId, id]);
  }

  Future<void> deleteRecipe(int id) async {
    Database db = await init();
    db.delete('recipe', where: 'recipe_id = ?', whereArgs: [id]);
  }
}
