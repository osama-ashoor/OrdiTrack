import 'package:b2b/product.dart';
import 'package:flutter/foundation.dart';

int place = 0;

class Cart extends ChangeNotifier {
  static int itemCount = 0;
  static double total = 0.0;
  List<Product> cart = [];
  void addToCart(Product item) {
    if (checkIfExists(item)) {
      cart[place].Quntity += 1;
      notifyListeners();
    } else {
      cart.add(item);
      notifyListeners();
    }
  }

  bool checkIfExists(Product item) {
    for (int i = 0; i < cart.length; i++) {
      if (cart[i].code == item.code) {
        place = i;
        return true;
      }
    }
    return false;
  }

  double getTotal() {
    total = callcluteTotal();
    return total;
  }

  double getEarnedAmount() {
    double earnedAmount = 0.0;
    for (int i = 0; i < cart.length; i++) {
      earnedAmount = earnedAmount +
          ((cart[i].sellprice * cart[i].Quntity) -
              (cart[i].buyprice * cart[i].Quntity));
    }
    return earnedAmount;
  }

  int getItemsCount() {
    itemCount = CItemCount();
    return itemCount;
  }

  int CItemCount() {
    int itemCount = 0;
    for (int i = 0; i < cart.length; i++) {
      if (cart[i].Quntity == 1) {
        itemCount = itemCount + 1;
      } else {
        itemCount = itemCount + (1 * cart[i].Quntity);
      }
    }
    return itemCount;
  }

  double callcluteTotal() {
    double sum = 0.0;
    for (int i = 0; i < cart.length; i++) {
      if (cart[i].Quntity == 1) {
        sum = sum + cart[i].sellprice;
      } else {
        sum = sum + (cart[i].sellprice * cart[i].Quntity);
      }
    }
    return sum;
  }
}
