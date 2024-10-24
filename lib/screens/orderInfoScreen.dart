import 'package:b2b/databaseService/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class orderInfo extends StatefulWidget {
  String orderNumber;
  int indexx;
  int itemCount;
  DocumentSnapshot order;
  String orderStatus;

  orderInfo({
    required this.orderNumber,
    required this.indexx,
    required this.itemCount,
    required this.order,
    required this.orderStatus,
  });

  @override
  State<orderInfo> createState() => _orderInfoState(
      orderNumber: orderNumber,
      indexx: indexx,
      itemCount: itemCount,
      orderStatus: orderStatus,
      order: order);
}

class _orderInfoState extends State<orderInfo> {
  late Future<List<DocumentSnapshot>> itemsFuture;

  void _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  void initState() {
    super.initState();
    itemsFuture = Database().accessFieldFromFirstItem(order);
  }

  String orderNumber;
  int indexx;
  int itemCount;
  DocumentSnapshot order;

  _orderInfoState({
    required this.orderNumber,
    required this.indexx,
    required this.itemCount,
    required this.order,
    required this.orderStatus,
  });

  String orderStatus;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orderStatus == "Pending"
                      ? Colors.yellow[600]
                      : orderStatus == "Shipped"
                          ? Colors.blue[600]
                          : orderStatus == "Delivered"
                              ? Colors.green[600]
                              : Colors.red[600],
                ),
                onPressed: () {},
                child: Text(
                  orderStatus,
                  style:
                      GoogleFonts.bebasNeue(fontSize: 20, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: Text(
          "Order Info",
          style: GoogleFonts.bebasNeue(fontSize: 30),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Database().getOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No Order Info Found",
                  style: GoogleFonts.bebasNeue(fontSize: 18),
                ),
              );
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Customer Info",
                            style: GoogleFonts.bebasNeue(fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person),
                        trailing: IconButton(
                          icon: Icon(Icons.call, color: Colors.green[600]),
                          onPressed: () async {
                            await launchUrl(Uri(
                                scheme: 'tel',
                                path: snapshot.data!.docs[indexx]
                                    .get("customerPhone")
                                    .toString()));
                          },
                        ),
                        title: Text(
                          snapshot.data!.docs[indexx]
                              .get("customerName")
                              .toString(),
                          style: GoogleFonts.bebasNeue(fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data!.docs[indexx]
                                  .get("customerPhone")
                                  .toString(),
                              style: GoogleFonts.bebasNeue(fontSize: 18),
                            ),
                            Text(
                              snapshot.data!.docs[indexx]
                                  .get("location")
                                  .toString(),
                              style: GoogleFonts.bebasNeue(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Order Info",
                            style: GoogleFonts.bebasNeue(fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      height: 300,
                      child: FutureBuilder<List<DocumentSnapshot>>(
                          future: itemsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              ));
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child: Text('No items found for this order'));
                            }

                            List<DocumentSnapshot> items = snapshot.data!;
                            return ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot item = items[index];
                                String id = item.id;
                                String namee = item.get('name').toString();
                                String quantityy =
                                    item.get('Quntity').toString();
                                String sellPricee =
                                    item.get('Sellprice').toString();
                                String image = item.get('image').toString();

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 65,
                                        child: CachedNetworkImage(
                                          imageUrl: image,
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
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            namee,
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 18),
                                          ),
                                          Text(
                                            " x" + quantityy,
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        sellPricee + " LYD",
                                        style:
                                            GoogleFonts.bebasNeue(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Invoice Info",
                            style: GoogleFonts.bebasNeue(fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        child: Column(
                          children: [
                            Divider(color: Colors.black),
                            Text(
                              "Invoice",
                              style: GoogleFonts.bebasNeue(
                                fontSize: 35,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              itemCount.toString() + " Items",
                              style: GoogleFonts.bebasNeue(
                                fontSize: 18,
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
                                  width: MediaQuery.of(context).size.width - 20,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Items Price",
                                        style:
                                            GoogleFonts.bebasNeue(fontSize: 18),
                                      ),
                                      Text(
                                        snapshot.data!.docs[indexx]
                                            .get("totalAmount")
                                            .toString(),
                                        style:
                                            GoogleFonts.bebasNeue(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                // Delivery Price
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 20,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Delivery Price",
                                        style:
                                            GoogleFonts.bebasNeue(fontSize: 18),
                                      ),
                                      Text(
                                        snapshot.data!.docs[indexx]
                                            .get("DeliveryPrice")
                                            .toString(),
                                        style:
                                            GoogleFonts.bebasNeue(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                // Total Price
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 20,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total",
                                        style:
                                            GoogleFonts.bebasNeue(fontSize: 18),
                                      ),
                                      Text(
                                        (snapshot.data!.docs[indexx]
                                                    .get("totalAmount") +
                                                snapshot.data!.docs[indexx]
                                                    .get("DeliveryPrice"))
                                            .toString(),
                                        style:
                                            GoogleFonts.bebasNeue(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Order Status",
                            style: GoogleFonts.bebasNeue(fontSize: 30),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: orderStatus == "Pending"
                            ? Colors.yellow[600]
                            : orderStatus == "Shipped"
                                ? Colors.blue[600]
                                : orderStatus == "Delivered"
                                    ? Colors.green[600]
                                    : Colors.red[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: DropdownButton(
                          icon: Icon(Icons.keyboard_arrow_down),
                          style: GoogleFonts.bebasNeue(
                              fontSize: 20, color: Colors.black),
                          value: orderStatus,
                          onChanged: (value) {
                            setState(() {
                              orderStatus = value.toString();
                              Database()
                                  .updateOrderStatus(orderNumber, orderStatus);
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              child: Text("Pending"),
                              value: "Pending",
                            ),
                            DropdownMenuItem(
                              child: Text("Shipped"),
                              value: "Shipped",
                            ),
                            DropdownMenuItem(
                              child: Text("Delivered"),
                              value: "Delivered",
                            ),
                            DropdownMenuItem(
                              child: Text("Cancelled"),
                              value: "Cancelled",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
