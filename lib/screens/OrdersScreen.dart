import 'package:b2b/auth/AuthService.dart';
import 'package:b2b/auth/wrapper.dart';
import 'package:b2b/databaseService/database.dart';
import 'package:b2b/screens/Home.dart';
import 'package:b2b/screens/cartScreen.dart';
import 'package:b2b/screens/orderInfoScreen.dart';
import 'package:b2b/screens/settings.dart';
import 'package:b2b/screens/wallet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  bool _isLoading = false;
  int _SelectedIndex = 2;
  bool _isDeleting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: Database().getOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.black,
              ));
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No Orders Found",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 18,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Recent Orders",
                          style: GoogleFonts.bebasNeue(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => orderInfo(
                                      orderStatus: snapshot.data!.docs[index]
                                          .get("orderStatus"),
                                      orderNumber:
                                          snapshot.data!.docs[index].id,
                                      order: snapshot.data!.docs[index],
                                      indexx: index,
                                      itemCount: snapshot.data!.docs[index]
                                          .get("itemsCount"),
                                    )));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    textAlign: TextAlign.start,
                                    "Order #" +
                                        snapshot.data!.docs[index].id
                                            .toString(),
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    textAlign: TextAlign.start,
                                    snapshot.data!.docs[index]
                                        .get("customerName")
                                        .toString(),
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 85,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(0, 3),
                                        )
                                      ],
                                      color: (snapshot.data!.docs[index]
                                                  .get("orderStatus")
                                                  .toString() ==
                                              "Pending")
                                          ? Colors.yellow[600]
                                          : snapshot.data!.docs[index]
                                                      .get("orderStatus")
                                                      .toString() ==
                                                  "Shipped"
                                              ? Colors.blue[600]
                                              : snapshot.data!.docs[index]
                                                          .get("orderStatus")
                                                          .toString() ==
                                                      "Delivered"
                                                  ? Colors.green[600]
                                                  : Colors.red[600],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        snapshot.data!.docs[index]
                                            .get("orderStatus")
                                            .toString(),
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              snapshot.data!.docs[index]
                                                      .get("itemsCount")
                                                      .toString() +
                                                  " Items",
                                              style: GoogleFonts.bebasNeue(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                  color: Colors.yellow[200],
                                                ),
                                              ),
                                            ),
                                            Text(
                                              snapshot.data!.docs[index]
                                                      .get("totalAmount")
                                                      .toString() +
                                                  " LYD",
                                              style: GoogleFonts.bebasNeue(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setState) {
                                                      return AlertDialog(
                                                        title: Center(
                                                          child: Text(
                                                              "Delete Order",
                                                              style: GoogleFonts
                                                                  .bebasNeue(
                                                                fontSize: 30,
                                                              )),
                                                        ),
                                                        content: Text(
                                                            textAlign: TextAlign
                                                                .center,
                                                            "Are you sure you want to delete this order?",
                                                            style: GoogleFonts
                                                                .bebasNeue(
                                                              fontSize: 25,
                                                            )),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                                "Cancel",
                                                                style: GoogleFonts
                                                                    .bebasNeue(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 25,
                                                                )),
                                                          ),
                                                          _isDeleting
                                                              ? const CircularProgressIndicator(
                                                                  color: Colors
                                                                      .black)
                                                              : TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      _isDeleting =
                                                                          true;
                                                                    });
                                                                    await Database().deleteDocumentAndSubCollections(snapshot
                                                                        .data!
                                                                        .docs[
                                                                            index]
                                                                        .id
                                                                        .toString());
                                                                    setState(
                                                                        () {
                                                                      _isDeleting =
                                                                          false;
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                      "Delete",
                                                                      style: GoogleFonts
                                                                          .bebasNeue(
                                                                        color: Colors
                                                                            .red[600],
                                                                        fontSize:
                                                                            25,
                                                                      )),
                                                                ),
                                                        ],
                                                      );
                                                    });
                                                  });
                                            },
                                            icon: Icon(
                                              size: 25,
                                              Icons.delete_forever_rounded,
                                              color: Colors.red[600],
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            );
          }),
    );
  }
}
