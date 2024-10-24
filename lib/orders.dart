import 'package:b2b/product.dart';

class Orderr {
  final String customerName;
  final String customerPhone;
  final List<Product> items;
  final double totalAmount;
  final int itemsCount;
  final int orderNumber;
  final double earnedAmount;
  Orderr({
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.customerPhone,
    required this.itemsCount,
    required this.orderNumber,
    required this.earnedAmount,
  });
}
