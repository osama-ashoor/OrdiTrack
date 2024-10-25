import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:b2b/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Database {
  CollectionReference pruducts =
      FirebaseFirestore.instance.collection('products');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  CollectionReference Settings =
      FirebaseFirestore.instance.collection('settings');
  CollectionReference Wallet = FirebaseFirestore.instance.collection('wallet');
  CollectionReference Users = FirebaseFirestore.instance.collection('users');

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetWallet() async {
    await Users.doc(_auth.currentUser!.uid)
        .collection("wallet")
        .doc("spent")
        .collection("processes")
        .get()
        .then((value) =>
            value.docs.forEach((element) => element.reference.delete()));

    await Users.doc(_auth.currentUser!.uid)
        .collection("wallet")
        .doc("spent")
        .delete();

    QuerySnapshot snapshot =
        await Users.doc(_auth.currentUser!.uid).collection("orders").get();

    for (int i = 0; i < snapshot.docs.length; i++) {
      await deleteDocumentAndSubCollections(snapshot.docs[i].id);
    }
  }

  Future<void> addWithdraw(double amount, String name) async {
    // AddWithdraw
    await Users.doc(_auth.currentUser!.uid)
        .collection("wallet")
        .doc("spent")
        .collection("processes")
        .doc()
        .set({
      "amount": amount,
      "name": name,
      "date": DateTime.now().toString(),
    });
  }

  Future<void> deleteWithdraw(String docId) async {
    //DeleteWithdraw
    await Users.doc(_auth.currentUser!.uid)
        .collection("wallet")
        .doc("spent")
        .collection("processes")
        .doc(docId)
        .delete();
  }

  Future addProducts(String name, double Sellprice, double Buyprice,
      String code, String image) async {
    await Users.doc(_auth.currentUser!.uid)
        .collection("products")
        .doc(code)
        .set({
      "name": name,
      "Sellprice": Sellprice,
      "Buyprice": Buyprice,
      "code": code,
      "image": image,
      "date": DateTime.now(),
    });
  }

  Future<void> updateProduct(
      double Sellprice, double Buyprice, String code) async {
    await Users.doc(_auth.currentUser!.uid)
        .collection("products")
        .doc(code)
        .update({
      "Sellprice": Sellprice,
      "Buyprice": Buyprice,
    });
  }

  Future<void> deleteProduct(String code) async {
    //Delete Product
    await Users.doc(_auth.currentUser!.uid)
        .collection("products")
        .doc(code)
        .delete();
  }

  Future addOrder(
      List<Product> cartItems,
      double total,
      String customerName,
      String customerPhone,
      int itemsCount,
      double deliveryPrice,
      double earnedAmount,
      String location) async {
    //Add New Order
    String orderNumber = await getOrderCount();
    await Users.doc(_auth.currentUser!.uid)
        .collection("orders")
        .doc(orderNumber)
        .set({
      "DeliveryPrice": deliveryPrice,
      "orderStatus": "Pending",
      "customerName": customerName,
      "customerPhone": customerPhone,
      "totalAmount": total,
      "itemsCount": itemsCount,
      "earnedAmount": earnedAmount,
      "location": location,
    });
    for (int i = 0; i < cartItems.length; i++) {
      String itemNumber = await getItemsCount(orderNumber);
      await Users.doc(_auth.currentUser!.uid)
          .collection("orders")
          .doc(orderNumber)
          .collection("items")
          .doc(cartItems[i].code + "$itemNumber")
          .set({
        "name": cartItems[i].name,
        "Sellprice": cartItems[i].sellprice,
        "Buyprice": cartItems[i].buyprice,
        "Quntity": cartItems[i].Quntity,
        "image": cartItems[i].imageUrl,
        "size": cartItems[i].size != null ? cartItems[i].size : null,
      });
    }
  }

  Future<double> getTotalAmount() async {
    double totalAmount = 0.0;
    QuerySnapshot snapshot =
        await Users.doc(_auth.currentUser!.uid).collection("orders").get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      totalAmount +=
          double.parse(snapshot.docs[i].get("totalAmount").toString());
    }
    return totalAmount;
  }

  Future<double> getCurrentBalance() async {
    double currentBalance = 0.0;
    QuerySnapshot snapshot =
        await Users.doc(_auth.currentUser!.uid).collection("orders").get();
    Iterable<QueryDocumentSnapshot> delivered = snapshot.docs
        .where((element) => element.get("orderStatus") == "Delivered");
    for (int i = 0; i < delivered.length; i++) {
      currentBalance +=
          double.parse(delivered.elementAt(i).get("totalAmount").toString());
    }

    QuerySnapshot snapshot2 = await Users.doc(_auth.currentUser!.uid)
        .collection("wallet")
        .doc("spent")
        .collection("processes")
        .get();

    for (int i = 0; i < snapshot2.docs.length; i++) {
      currentBalance -=
          double.parse(snapshot2.docs[i].get("amount").toString());
    }
    return currentBalance;
  }

  Future<double> getPendingBalance() async {
    double pendingBalance = 0.0;
    QuerySnapshot snapshot =
        await Users.doc(_auth.currentUser!.uid).collection("orders").get();
    Iterable<QueryDocumentSnapshot> delivered = snapshot.docs.where((element) =>
        element.get("orderStatus") == "Pending" ||
        element.get("orderStatus") == "Shipped");
    for (int i = 0; i < delivered.length; i++) {
      pendingBalance +=
          double.parse(delivered.elementAt(i).get("totalAmount").toString());
    }
    return pendingBalance;
  }

  Future<double> getEarnedAmount() async {
    double upcomingAmount = 0.0;
    QuerySnapshot snapshot =
        await Users.doc(_auth.currentUser!.uid).collection("orders").get();
    Iterable<QueryDocumentSnapshot> delivered = snapshot.docs
        .where((element) => element.get("orderStatus") == "Delivered");
    for (int i = 0; i < delivered.length; i++) {
      upcomingAmount +=
          double.parse(delivered.elementAt(i).get("earnedAmount").toString());
    }
    return upcomingAmount;
  }

  Future<double> getSpentAmount() async {
    double spentAmount = 0.0;
    QuerySnapshot snapshot = await Users.doc(_auth.currentUser!.uid)
        .collection("wallet")
        .doc("spent")
        .collection("processes")
        .get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      spentAmount += double.parse(snapshot.docs[i].get("amount").toString());
    }
    return spentAmount;
  }

  Stream<QuerySnapshot> getSpentProcesses() {
    return Users.doc(_auth.currentUser!.uid)
        .collection("wallet")
        .doc("spent")
        .collection("processes")
        .orderBy(
          'date',
          descending: true,
        )
        .snapshots();
  }

  Future<String> getShopInfo() async {
    try {
      DocumentSnapshot snapshot = await Users.doc(_auth.currentUser!.uid)
          .collection("settings")
          .doc("shopInfo")
          .get();
      return snapshot.get("name").toString();
    } catch (e) {
      return "";
    }
  }

  Future<void> setShopInfo(String name) async {
    await Users.doc(_auth.currentUser!.uid)
        .collection("settings")
        .doc("shopInfo")
        .set({'name': name});
  }

  Future<void> setCurrencyExchange(double priceUSA, double priceTRY) async {
    await Users.doc(_auth.currentUser!.uid)
        .collection("settings")
        .doc("currencyExchange")
        .set({'USAToLYD': priceUSA, 'USAToTRY': priceTRY});
  }

  Future<double> getCurrencyExchangeUSA() async {
    try {
      DocumentSnapshot snapshot = await Users.doc(_auth.currentUser!.uid)
          .collection("settings")
          .doc("currencyExchange")
          .get();
      return snapshot.get("USAToLYD").toDouble();
    } catch (e) {
      await setCurrencyExchange(0.0, 0.0);

      DocumentSnapshot snapshot = await Users.doc(_auth.currentUser!.uid)
          .collection("settings")
          .doc("currencyExchange")
          .get();
      return snapshot.get("USAToLYD").toDouble();
    }
  }

  Future<double> getCurrencyExchangeTRY() async {
    DocumentSnapshot snapshot = await Users.doc(_auth.currentUser!.uid)
        .collection("settings")
        .doc("currencyExchange")
        .get();
    return snapshot.get("USAToTRY").toDouble();
  }

  Stream<QuerySnapshot> getProducts() {
    return Users.doc(_auth.currentUser!.uid)
        .collection("products")
        .orderBy("date", descending: true)
        .snapshots();
  }

  Future<void> deleteDocumentAndSubCollections(String docId) async {
    final DocumentReference docRef =
        Users.doc(_auth.currentUser!.uid).collection("orders").doc(docId);

    await _deleteSubCollections(docRef);

    await docRef.delete();
  }

  Future<void> _deleteSubCollections(DocumentReference docRef) async {
    final collectionRefs = await docRef.collection('items').get();

    for (var doc in collectionRefs.docs) {
      await doc.reference.delete();
    }
  }

  Future<String> getOrderCount() async {
    QuerySnapshot snapshot =
        await Users.doc(_auth.currentUser!.uid).collection("orders").get();
    if (snapshot.docs.length == 0) {
      return "0";
    } else {
      return (int.parse(snapshot.docs[snapshot.docs.length - 1].id) + 1)
          .toString();
    }
  }

  Future<String> getItemsCount(String orderNumber) async {
    QuerySnapshot snapshot = await Users.doc(_auth.currentUser!.uid)
        .collection("orders")
        .doc(orderNumber)
        .collection("items")
        .get();
    if (snapshot.docs.length == 0) {
      return "0";
    } else {
      return snapshot.docs.length.toString();
    }
  }

  void updateOrderStatus(String orderNumber, String orderStatus) async {
    await Users.doc(_auth.currentUser!.uid)
        .collection("orders")
        .doc(orderNumber)
        .update({"orderStatus": orderStatus});
  }

  Stream<QuerySnapshot> getOrders() {
    return Users.doc(_auth.currentUser!.uid).collection("orders").snapshots();
  }

  Future<List<DocumentSnapshot>> accessFieldFromFirstItem(
      DocumentSnapshot orderDoc) async {
    CollectionReference itemsSubcollectionRef =
        orderDoc.reference.collection('items');
    QuerySnapshot itemsSnapshot = await itemsSubcollectionRef.get();
    return itemsSnapshot.docs;
  }

  Future<int> docCount(DocumentSnapshot orderDoc, int index) async {
    CollectionReference itemsSubcollectionRef =
        orderDoc.reference.collection('items');

    QuerySnapshot itemsSnapshot = await itemsSubcollectionRef.get();

    if (itemsSnapshot.docs.isNotEmpty) {
      int itemCount = itemsSnapshot.docs.length;
      return itemCount;
    } else {
      return 0;
    }
  }

  Future<void> UploadImage(XFile _image, String name, double Sellprice,
      double Buyprice, String code) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("products").child(code);
      UploadTask uploadTask = ref.putFile(File(_image!.path));
      await uploadTask;
      String url = await ref.getDownloadURL();
      await addProducts(name, Sellprice, Buyprice, code, url);
    } catch (e) {
      print("e");
    }
  }
}
