import 'dart:math';

import 'package:b2b/orders.dart';
import 'package:b2b/product.dart';
import 'package:flutter/foundation.dart';

class OrderProvider with ChangeNotifier {
  List<Orderr> _orders = [];
  int itemCount = 0;

  List<Orderr> get orders => _orders;

  int getItemsCount(int index) {
    itemCount = CItemCount(index);
    return itemCount;
  }

  int CItemCount(int index) {
    int itemCount = 0;
    for (int i = 0; i < _orders[index].items.length; i++) {
      if (_orders[index].items[i].Quntity == 1) {
        itemCount = itemCount + 1;
      } else {
        itemCount = itemCount + (1 * _orders[index].items[i].Quntity);
      }
    }
    return itemCount;
  }

  void addOrder(List<Product> cartItems, double total, String customerName,
      String customerPhone, int itemsCount, double earnedAmount) {
    final newOrder = Orderr(
        customerName: customerName,
        customerPhone: customerPhone,
        items: cartItems,
        totalAmount: total,
        itemsCount: itemsCount,
        orderNumber: Random().nextInt(1000),
        earnedAmount: earnedAmount);

    _orders.add(newOrder);
    notifyListeners();
  }
}
