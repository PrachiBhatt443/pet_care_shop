import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final Map<String, int> _items = {}; // productId: quantity

  Map<String, int> get items => _items;

  int get totalItems => _items.values.fold(0, (sum, qty) => sum + qty);

  void initializeCartFromPurchases(List<Map<String, dynamic>> purchases) {
    print("intialize called");
    // print(purchases);
    final user = FirebaseAuth.instance.currentUser;
    print("user called");
    print(user);
    _items.clear();

    // final snapshot = await FirebaseFirestore.instance
    //     .collection('purchases')
    //     .where('userId', isEqualTo: user?.uid)
    //     .where('status', isEqualTo: 'pending') // ensure only pending
    //     .get();
    //
    // final purchaseData = snapshot.docs.map((doc) => doc.data()).toList();
    for (var purchase in purchases) {
      final productId = purchase['productId'] as String;
      final quantity = purchase['quantity'] as int;

      if (_items.containsKey(productId)) {
        _items[productId] = _items[productId]! + quantity;
      } else {
        _items[productId] = quantity;
      }
    }
    notifyListeners();
  }

  void addItem(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId] = _items[productId]! + 1;
    } else {
      _items[productId] = 1;
    }
    print('addItem called: $_items');
    notifyListeners();
  }


  void updateItem(String productId, int quantity) {
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      _items[productId] = quantity;
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
