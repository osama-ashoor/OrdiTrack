import 'package:flutter/material.dart';

class shopInfo extends ChangeNotifier {
  String shopName = "";

  void setShopName(String name) {
    shopName = name;
    notifyListeners();
  }

  String getShopName() {
    return shopName;
  }
}
