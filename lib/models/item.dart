class Item {
  int itemId = 0;
  String itemName = '';
  String itemNameAR = '';
  String itemNameDE = '';
  var categoryId = 1;

  Item(
      {required int itemId1,
      required String itemName1,
      required String itemNameAR1,
      required String itemNameDE1}) {
    itemId = itemId1;
    itemName = itemName1;
    itemNameAR = itemNameAR1;
    itemNameDE = itemNameDE1;
  }

  @override
  String toString() {
    return ' ${this.itemNameAR}:${this.itemNameDE}:${this.itemName}';
  }

  Item.fromMap(Map<String, dynamic> data) {
    itemId = data['item_id'];
    itemName = data['item_name'];
    itemNameAR = data['item_name_ar'];
    itemNameDE = data['item_name_de'];
    categoryId = data['category_id'];
  }
  Map<String, dynamic> toMap() => {
        'item_id': itemId,
        'item_name': itemName,
        'item_name_ar': itemNameAR,
        'item_name_de': itemNameDE,
        'category_id': categoryId,
      };
  static dynamic getListObj(List<dynamic> listItems) {
    if (listItems == null) {
      return null;
    }
    List<Item> result = [];
    listItems.forEach((v) {
      result.add(new Item.fromMap(v));
    });

    return result;
  }
  // static dynamic getListMap(List<dynamic> items) {
  //   if (items == null) {
  //     return null;
  //   }
  //   List<Map<String, dynamic>> list = [];
  //   items.forEach((element) {
  //     list.add(element.toMap());
  //   });
  //   return list;
  // }

  int get item_id => itemId;
  String get item_name => itemName;
  String get item_name_ar => itemNameAR;
  String get item_name_de => itemNameDE;
  int get category_id => categoryId;
}
