class Product {
  int Quntity = 1;
  final String code;
  final String name;
  final double buyprice;
  final double sellprice;
  final String imageUrl;
  String? size;

  int getQuntity() {
    return Quntity;
  }

  Product({
    required this.code,
    required this.name,
    required this.buyprice,
    required this.sellprice,
    required this.imageUrl,
    this.size,
  });
}
