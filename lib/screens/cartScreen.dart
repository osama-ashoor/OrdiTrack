import 'package:auto_size_text/auto_size_text.dart';
import 'package:b2b/auth/AuthService.dart';
import 'package:b2b/auth/wrapper.dart';
import 'package:b2b/cart.dart';
import 'package:b2b/databaseService/database.dart';
import 'package:b2b/orderProvider.dart';
import 'package:b2b/screens/Home.dart';
import 'package:b2b/screens/OrdersScreen.dart';
import 'package:b2b/screens/settings.dart';
import 'package:b2b/screens/wallet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreen();
}

class _CartScreen extends State<CartScreen> {
  String name = "";
  String phone = "";
  String customerLocation = "";
  double deliveryPrice = 0.0;

  bool isLoading = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void showCompletionBottomSheet(BuildContext context) {
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
          initialChildSize: 0.8, // Initial height of the modal sheet
          minChildSize: 0.3, // Minimum height the modal can be dragged down to
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 10,
                  right: 10),
              child: Form(
                key: _formKey,
                child: Consumer<OrderProvider>(
                  builder: (context, orderPorvider, child) =>
                      SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // Emoji or image at the top
                        Center(
                          child: Icon(Icons.info_outlined, size: 48),
                        ),
                        SizedBox(height: 16),
                        // Main message
                        Text(
                          'Please Enter Customer Details',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.bebasNeue(
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please customer name';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            name = newValue!;
                          },
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Customer Name',
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            hintText: 'Enter Customer Name',
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    Colors.black, // Border color when enabled
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),

                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter customer number';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            phone = newValue!;
                          },
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Customer Number',
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            hintText: 'Enter Customer Number',
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    Colors.black, // Border color when enabled
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter customer location';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            customerLocation = newValue!;
                          },
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Customer Location',
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            hintText: 'Enter Customer Location',
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    Colors.black, // Border color when enabled
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter delivery price';
                            }
                            if (double.tryParse(value) != null) {
                              return null;
                            }
                            if (int.tryParse(value) != null) {
                              return null;
                            }

                            return 'Please enter valid delivery price';
                          },
                          onSaved: (newValue) {
                            deliveryPrice = double.parse(newValue!);
                          },
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Delivery Pirce',
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            hintText: 'Enter Delivery Price',
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    Colors.black, // Border color when enabled
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Navigation button
                        Consumer<Cart>(
                          builder: (context, value, child) => isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      setState(() {
                                        isLoading = true;
                                      });
                                      orderPorvider.addOrder(
                                          value.cart,
                                          value.getTotal(),
                                          name,
                                          phone,
                                          value.CItemCount(),
                                          value.getEarnedAmount());

                                      await Database().addOrder(
                                          value.cart,
                                          value.getTotal(),
                                          name,
                                          phone,
                                          value.CItemCount(),
                                          deliveryPrice,
                                          value.getEarnedAmount(),
                                          customerLocation);
                                      value.cart.clear();
                                      setState(() {});
                                      Navigator.pop(context);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content: Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.02),
                                            child: Center(
                                                child: Text(
                                              'Order Created Successfully',
                                              style: GoogleFonts.bebasNeue(
                                                  fontSize: 25),
                                            )),
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  child: Text('Create Order',
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 24,
                                        color: Colors.black,
                                      )),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, value, child) => Scaffold(
        body: value.cart.isEmpty
            ? Center(
                child: Text(
                  "Cart is empty",
                  style: GoogleFonts.bebasNeue(fontSize: 18),
                ),
              )
            : Column(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    height: MediaQuery.of(context).size.height - 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: value.cart.length +
                          1, // +1 to add the invoice as the last item
                      itemBuilder: (context, index) {
                        // Check if the index is the last index
                        if (index == value.cart.length) {
                          // Render the invoice at the end
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Divider(color: Colors.black),
                                Text(
                                  "Invoice",
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  value.getItemsCount().toString() + " Items",
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Items Price
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Items Price",
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 16),
                                          ),
                                          Text(
                                            (value.getTotal() % 1 == 0)
                                                ? value
                                                    .getTotal()
                                                    .toInt()
                                                    .toString()
                                                : value
                                                    .getTotal()
                                                    .toStringAsFixed(2),
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Delivery Price
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Delivery Price",
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 16),
                                          ),
                                          Text(
                                            "-",
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Total Price
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Total",
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 16),
                                          ),
                                          Text(
                                            (value.getTotal() % 1 == 0)
                                                ? value
                                                    .getTotal()
                                                    .toInt()
                                                    .toString()
                                                : value
                                                    .getTotal()
                                                    .toStringAsFixed(2),
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            height: 195,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    child: CachedNetworkImage(
                                      width: 75,
                                      height: 100,
                                      imageUrl: value.cart[index].imageUrl,
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  tileColor:
                                      Theme.of(context).colorScheme.secondary,
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline_outlined,
                                      color: Colors.red,
                                      size: 33,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        value.cart.removeAt(index);
                                      });
                                    },
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.only(left: 17.0),
                                    child: FittedBox(
                                      alignment: Alignment.centerLeft,
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        value.cart[index].code,
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  subtitle: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey
                                              .withOpacity(0.4), // Shadow color
                                          spreadRadius: 2, // Spread radius
                                          blurRadius: 6, // Blur radius
                                          offset: Offset(0,
                                              2), // Changes position of shadow (x, y)
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(15),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    child: ListTile(
                                      leading: IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            value.addToCart(value.cart[index]);
                                          });
                                        },
                                      ),
                                      title: AutoSizeText(
                                        minFontSize: 16,
                                        maxLines: 1,
                                        overflow: TextOverflow.fade, //
                                        value.cart[index].Quntity.toString(),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {
                                          if (value.cart[index].Quntity == 1) {
                                            setState(() {
                                              value.cart.removeAt(index);
                                            });
                                          } else {
                                            setState(() {
                                              value.cart[index].Quntity -= 1;
                                            });
                                          }
                                        },
                                        icon: Icon(Icons.remove),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                // Price Text
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.4), // Shadow color
                                              spreadRadius: 2, // Spread radius
                                              blurRadius: 6, // Blur radius
                                              offset: Offset(0,
                                                  2), // Changes position of shadow (x, y)
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            "${(value.cart[index].sellprice) % 1 == 0 ? value.cart[index].sellprice.toInt().toString() : (value.cart[index].sellprice).toStringAsFixed(2)} LYD", // Display price here
                                            style: GoogleFonts.bebasNeue(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: Colors.black),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  // Checkout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        minimumSize:
                            MaterialStatePropertyAll(Size(double.infinity, 60)),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        backgroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onPressed: () {
                        showCompletionBottomSheet(context);
                      },
                      child: Text(
                        "Checkout",
                        style: GoogleFonts.bebasNeue(
                          fontSize: 35,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
