import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class shoppingCart extends ChangeNotifier {
  String shoppingCartId = '';
  String shoppingCartName = 'Home'; //defult
  List<dynamic> cartItemsIds = [];
  shoppingCart(String shoppingCartId1, String shoppingCartName1) {
    this.shoppingCartId = shoppingCartId1;
    this.shoppingCartName = shoppingCartName1;
    print('in provider---------${this.shoppingCartId}');
    notifyListeners();
  }

  void setCartItems(List<String> ids) {
    cartItemsIds = ids;
    notifyListeners(); // rebuilds all widgets listening
  }

  setShoppingCart({
    required String shoppingCartId,
    required String shoppingCartName,
  }) {
    print('in setShoppingCart--------$shoppingCartName');
    this.shoppingCartId = shoppingCartId;
    this.shoppingCartName = shoppingCartName;
    cartItemsIds.clear();
    notifyListeners();
  }

  addCartItemsIds(id) {
    if (!cartItemsIds.contains(id)) {
      cartItemsIds.add(id);
      notifyListeners();
    }
  }

  deleteCartItemsIds(id) {
    cartItemsIds.remove(id);
    notifyListeners();
  }

  deleteCartAllItemsIds() {
    cartItemsIds.clear();
    notifyListeners();
  }

  checkItemExist(id) {
    if (cartItemsIds.contains(id))
      return true;
    else
      return false;
  }

  /**class City {
  final String? name;
  final String? state;
  final String? country;
  final bool? capital;
  final int? population;
  final List<String>? regions;

  City({
    this.name,
    this.state,
    this.country,
    this.capital,
    this.population,
    this.regions,
  });

  factory City.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return City(
      name: data?['name'],
      state: data?['state'],
      country: data?['country'],
      capital: data?['capital'],
      population: data?['population'],
      regions:
          data?['regions'] is Iterable ? List.from(data?['regions']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (state != null) "state": state,
      if (country != null) "country": country,
      if (capital != null) "capital": capital,
      if (population != null) "population": population,
      if (regions != null) "regions": regions,
    };
  }
} */
}
