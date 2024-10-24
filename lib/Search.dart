import 'package:b2b/cart.dart';
import 'package:b2b/databaseService/database.dart';
import 'package:b2b/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Search extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        colorScheme: ColorScheme.light(
          background: Colors.grey.shade300,
          primary: Colors.grey.shade200,
          secondary: Colors.white,
          inversePrimary: Colors.grey.shade700,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
        ));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text("Data");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query == "") {
      return StreamBuilder<QuerySnapshot>(
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Suggestions",
                          style: GoogleFonts.bebasNeue(fontSize: 25),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.all(15),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //product Image
                              AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  width: double.infinity,
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
                              SizedBox(
                                height: 25,
                              ),
                              //product Name
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  product['name'],
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                product['code'],
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),

                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Consumer<Cart>(
                                      builder: (context, value, child) =>
                                          IconButton(
                                        onPressed: () {
                                          value.addToCart(Product(
                                              code: product['code'],
                                              name: product['name'],
                                              buyprice: product['Buyprice'],
                                              sellprice: product['Sellprice'],
                                              imageUrl: product['image']));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.02),
                                                child: Center(
                                                    child: Text(
                                                  'Product Added Successfully To Cart',
                                                  style: GoogleFonts.bebasNeue(
                                                      fontSize: 20),
                                                )),
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
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
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: products.length > 10 ? 5 : products.length,
                    ),
                  ),
                ],
              ),
            );
          });
    } else {
      return StreamBuilder<QuerySnapshot>(
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

            final products = snapshot.data!.docs
                .where((element) => element
                    .get("code")
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
                .toList();
            if (products.isNotEmpty) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.52,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.all(15),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //product Image
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(25),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    width: double.infinity,
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
                                SizedBox(
                                  height: 25,
                                ),
                                //product Name
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    product['name'],
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  product['code'],
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),

                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Consumer<Cart>(
                                        builder: (context, value, child) =>
                                            IconButton(
                                          onPressed: () {
                                            value.addToCart(Product(
                                                code: product['code'],
                                                name: product['name'],
                                                buyprice: product['Buyprice'],
                                                sellprice: product['Sellprice'],
                                                imageUrl: product['image']));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.02),
                                                  child: Center(
                                                      child: Text(
                                                    'Product Added Successfully To Cart',
                                                    style:
                                                        GoogleFonts.bebasNeue(
                                                            fontSize: 20),
                                                  )),
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
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
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: products.length,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 30,
                    color: Colors.red[600],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'No products found',
                    style: GoogleFonts.bebasNeue(fontSize: 18),
                  ),
                ],
              ));
            }
          });
    }
  }
}
