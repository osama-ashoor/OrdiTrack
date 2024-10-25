import 'package:b2b/cart.dart';
import 'package:b2b/databaseService/database.dart';
import 'package:b2b/product.dart';
import 'package:b2b/screens/addProductScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  @override
  void initState() {
    setCurrencyExchange();
    super.initState();
  }

  Future<void> setCurrencyExchange() async {
    currencyExchangeUSA = await Database().getCurrencyExchangeUSA();
    currencyExchangeTRY = await Database().getCurrencyExchangeTRY();
  }

  String _SelectedValue = "TRY";
  double currencyExchangeUSA = 0.0;
  double currencyExchangeTRY = 0.0;
  String sellprice = "";
  String code = "";
  String buyprice = "0";
  String originalBuyPrice = "0";
  String size = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  String shopName = "";
  bool _isDeleting = false;
  void showBottomSheet(BuildContext context, String docId) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.background,
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Builder(builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Center(
                                child: Text("Delete Product",
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 30,
                                    )),
                              ),
                              content: StatefulBuilder(
                                builder: (context, setState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        textAlign: TextAlign.center,
                                        "Are you sure you want to delete this product?",
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 25,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Cancel",
                                              style: GoogleFonts.bebasNeue(
                                                color: Colors.black,
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              setState(() {
                                                _isDeleting = true;
                                              });
                                              await Database()
                                                  .deleteProduct(docId);
                                              setState(() {
                                                _isDeleting = false;
                                              });
                                              Navigator.pop(
                                                  context); // Close the dialog
                                            },
                                            child: _isDeleting
                                                ? CircularProgressIndicator(
                                                    color: Colors.black)
                                                : Text(
                                                    "Delete",
                                                    style:
                                                        GoogleFonts.bebasNeue(
                                                      color: Colors.red[600],
                                                      fontSize: 25,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(children: [
                              const Icon(Icons.delete_forever_rounded,
                                  size: 25, color: Colors.red),
                              const SizedBox(width: 25),
                              Text("Delete",
                                  style: GoogleFonts.bebasNeue(fontSize: 18)),
                            ])),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Builder(builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Center(
                                child: Text("Edit Product Price",
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 25,
                                    )),
                              ),
                              content: StatefulBuilder(
                                builder: (context, setState) {
                                  return SingleChildScrollView(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButton(
                                              elevation: 2,
                                              value: _SelectedValue,
                                              items: [
                                                DropdownMenuItem(
                                                  child: FaIcon(FontAwesomeIcons
                                                      .turkishLiraSign),
                                                  value: "TRY",
                                                ),
                                                DropdownMenuItem(
                                                  child: FaIcon(FontAwesomeIcons
                                                      .dollarSign),
                                                  value: "USD",
                                                ),
                                              ],
                                              onChanged: (value) {
                                                setState(() {
                                                  _SelectedValue = value!;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return null;
                                              }
                                              if (double.tryParse(value) !=
                                                  null) {
                                                return null;
                                              }
                                              if (int.tryParse(value) != null) {
                                                return null;
                                              }

                                              return 'Please enter valid product buy price';
                                            },
                                            onSaved: (newValue) {
                                              if (newValue!.isNotEmpty) {
                                                originalBuyPrice = newValue!;
                                              } else {
                                                originalBuyPrice = "0";
                                              }
                                            },
                                            onChanged: (value) {
                                              setState(() {
                                                if (value.isNotEmpty) {
                                                  originalBuyPrice = value;
                                                } else {
                                                  originalBuyPrice = "0";
                                                }
                                              });
                                            },
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              suffix: Text(
                                                _SelectedValue == "TRY"
                                                    ? (currencyExchangeTRY !=
                                                            0.0
                                                        ? (((double.parse(originalBuyPrice) /
                                                                            currencyExchangeTRY) +
                                                                        3) *
                                                                    currencyExchangeUSA)
                                                                .toStringAsFixed(
                                                                    2) +
                                                            " LYD"
                                                        : (((double.parse(originalBuyPrice) *
                                                                            currencyExchangeTRY) +
                                                                        3) *
                                                                    currencyExchangeUSA)
                                                                .toStringAsFixed(
                                                                    2) +
                                                            " LYD")
                                                    : ((double.parse(originalBuyPrice) +
                                                                    6) *
                                                                currencyExchangeUSA)
                                                            .toStringAsFixed(
                                                                2) +
                                                        " LYD",
                                                style: GoogleFonts.bebasNeue(
                                                  fontSize: 16,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              labelText:
                                                  'Product Original Price',
                                              labelStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                              hintText:
                                                  'Enter Product Original Price',
                                              hintStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors
                                                      .black, // Border color when enabled
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.green,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter product buy price';
                                              }
                                              if (double.tryParse(value) !=
                                                  null) {
                                                return null;
                                              }
                                              if (int.tryParse(value) != null) {
                                                return null;
                                              }

                                              return 'Please enter valid product buy price';
                                            },
                                            onSaved: (newValue) {
                                              buyprice = newValue!;
                                            },
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: 'Product Buy Price',
                                              labelStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                              hintText: originalBuyPrice.isEmpty
                                                  ? 'Enter Product Buy Price'
                                                  : _SelectedValue == "TRY"
                                                      ? (currencyExchangeTRY !=
                                                              0.0
                                                          ? (((double.parse(originalBuyPrice) /
                                                                              currencyExchangeTRY) +
                                                                          3) *
                                                                      currencyExchangeUSA)
                                                                  .toStringAsFixed(
                                                                      2) +
                                                              " LYD"
                                                          : (((double.parse(originalBuyPrice) *
                                                                              currencyExchangeTRY) +
                                                                          3) *
                                                                      currencyExchangeUSA)
                                                                  .toStringAsFixed(
                                                                      2) +
                                                              " LYD")
                                                      : ((double.parse(originalBuyPrice) +
                                                                      6) *
                                                                  currencyExchangeUSA)
                                                              .toStringAsFixed(
                                                                  2) +
                                                          " LYD",
                                              hintStyle: TextStyle(
                                                color: Colors.green,
                                                fontSize: 18,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors
                                                      .black, // Border color when enabled
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.green,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter product sell price';
                                              }
                                              if (double.tryParse(value) !=
                                                  null) {
                                                return null;
                                              }
                                              if (int.tryParse(value) != null) {
                                                return null;
                                              }

                                              return 'Please enter valid product sell price';
                                            },
                                            onSaved: (newValue) {
                                              sellprice = newValue!;
                                            },
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            decoration: const InputDecoration(
                                              labelText: 'Product Sell Price',
                                              labelStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                              hintText:
                                                  'Enter Product Sell Price',
                                              hintStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors
                                                      .black, // Border color when enabled
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.green,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "Cancel",
                                                  style: GoogleFonts.bebasNeue(
                                                    color: Colors.black,
                                                    fontSize: 25,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    _formKey.currentState!
                                                        .save();

                                                    setState(() {
                                                      _isDeleting = true;
                                                    });
                                                    await Database()
                                                        .updateProduct(
                                                            double.parse(
                                                                sellprice),
                                                            double.parse(
                                                                buyprice),
                                                            docId);
                                                    setState(() {
                                                      _isDeleting = false;
                                                    });
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);

                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        backgroundColor:
                                                            Colors.green,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        content: Container(
                                                          margin: EdgeInsets.symmetric(
                                                              horizontal:
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.1),
                                                          child: Center(
                                                              child: Text(
                                                            "Product Edited",
                                                            style: GoogleFonts
                                                                .bebasNeue(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: _isDeleting
                                                    ? CircularProgressIndicator(
                                                        color: Colors.black)
                                                    : Text(
                                                        "Edit",
                                                        style: GoogleFonts
                                                            .bebasNeue(
                                                          color:
                                                              Colors.red[600],
                                                          fontSize: 25,
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(children: [
                              const Icon(
                                Icons.edit,
                                size: 25,
                              ),
                              const SizedBox(width: 25),
                              Text("Edit",
                                  style: GoogleFonts.bebasNeue(fontSize: 18)),
                            ])),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => addProduct()));
        },
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Database().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
              'No products found',
              style: GoogleFonts.bebasNeue(fontSize: 18),
            ));
          }

          final products = snapshot.data!.docs;
          return SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  kBottomNavigationBarHeight,
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 90.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 5.0,
                  childAspectRatio:
                      0.5, // Adjust based on your aspect ratio needs
                ),
                itemCount: products.length, // Total number of products
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1, // Ensures the image is square
                            child: Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: product['image'].toString(),
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          // Product Name
                          FittedBox(
                            child: Text(
                              product['name'],
                              style: GoogleFonts.bebasNeue(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Product Code
                          Text(
                            product['code'],
                            style: GoogleFonts.bebasNeue(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(height: 5),
                          // Buy Price
                          Text(
                            "Buy Price: " +
                                (product['Buyprice'] % 1 == 0
                                    ? product['Buyprice'].toInt().toString()
                                    : product['Buyprice'].toString()),
                            style: GoogleFonts.bebasNeue(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          // Sell Price
                          Text(
                            "Sell Price: " +
                                (product['Sellprice'] % 1 == 0
                                    ? product['Sellprice'].toInt().toString()
                                    : product['Sellprice'].toString()),
                            style: GoogleFonts.bebasNeue(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(height: 10),
                          // Add to Cart Button and More Options
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Add to Cart Button
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Consumer<Cart>(
                                  builder: (context, value, child) =>
                                      IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: Center(
                                                  child: Text(
                                                    'Please Enter The Size Of The Product To Add To Cart',
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        GoogleFonts.bebasNeue(
                                                            fontSize: 18),
                                                  ),
                                                ),
                                                content: StatefulBuilder(
                                                    builder:
                                                        (context, setState) {
                                                  return SingleChildScrollView(
                                                    child: Form(
                                                      key: _formKey2,
                                                      child: Column(
                                                        children: [
                                                          TextFormField(
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Please enter product size';
                                                              }
                                                              return null;
                                                            },
                                                            onSaved:
                                                                (newValue) {
                                                              size = newValue!;
                                                            },
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Product Size',
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              hintText:
                                                                  'Enter Product Size',
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18,
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .black, // Border color when enabled
                                                                ),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .green,
                                                                  width: 2,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 20),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    _isDeleting =
                                                                        false;
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  "Cancel",
                                                                  style: GoogleFonts
                                                                      .bebasNeue(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        25,
                                                                  ),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  setState(() {
                                                                    _isDeleting =
                                                                        true;
                                                                  });
                                                                  if (_formKey2
                                                                      .currentState!
                                                                      .validate()) {
                                                                    _formKey2
                                                                        .currentState!
                                                                        .save();
                                                                    value.addToCart(
                                                                        Product(
                                                                      code: product[
                                                                          'code'],
                                                                      name: product[
                                                                          'name'],
                                                                      buyprice:
                                                                          product[
                                                                              'Buyprice'],
                                                                      sellprice:
                                                                          product[
                                                                              'Sellprice'],
                                                                      imageUrl:
                                                                          product[
                                                                              'image'],
                                                                      size:
                                                                          size,
                                                                    ));
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        behavior:
                                                                            SnackBarBehavior.floating,
                                                                        content:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'Product Added Successfully To Cart',
                                                                            style:
                                                                                GoogleFonts.bebasNeue(fontSize: 18),
                                                                          ),
                                                                        ),
                                                                        backgroundColor:
                                                                            Colors.green,
                                                                      ),
                                                                    );
                                                                    setState(
                                                                        () {
                                                                      _isDeleting =
                                                                          false;
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      _isDeleting =
                                                                          false;
                                                                    });
                                                                  }
                                                                },
                                                                child:
                                                                    _isDeleting
                                                                        ? CircularProgressIndicator(
                                                                            color:
                                                                                Colors.black)
                                                                        : Text(
                                                                            "Add",
                                                                            style:
                                                                                GoogleFonts.bebasNeue(
                                                                              color: Colors.green[600],
                                                                              fontSize: 25,
                                                                            ),
                                                                          ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ));
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.more_vert,
                                    color: Colors.black, size: 28),
                                onPressed: () {
                                  showBottomSheet(context, product.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
