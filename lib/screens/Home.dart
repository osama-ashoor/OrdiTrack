import 'package:b2b/Search.dart';
import 'package:b2b/auth/AuthService.dart';
import 'package:b2b/auth/wrapper.dart';
import 'package:b2b/cart.dart';
import 'package:b2b/databaseService/database.dart';
import 'package:b2b/product.dart';
import 'package:b2b/screens/HomePage.dart';
import 'package:b2b/screens/OrdersScreen.dart';
import 'package:b2b/screens/addProductScreen.dart';
import 'package:b2b/screens/cartScreen.dart';
import 'package:b2b/screens/settings.dart';
import 'package:b2b/screens/wallet.dart';
import 'package:b2b/shopInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _connectionStatus = "Unknown";

  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (mounted) {
      setState(() {
        if (result == ConnectivityResult.mobile) {
          _connectionStatus = 'Mobile';
        } else if (result == ConnectivityResult.wifi) {
          _connectionStatus = 'WiFi';
        } else {
          _connectionStatus = 'No Connection';
        }
      });
    }
  }

  bool _isLoading = false;
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
                                  size: 40, color: Colors.red),
                              const SizedBox(width: 25),
                              Text("Delete",
                                  style: GoogleFonts.bebasNeue(fontSize: 32)),
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

  int _SelectedIndex = 0;
  List<Widget> _Pages = [
    SafeArea(child: HomePage()),
    SafeArea(child: Orders()),
    SafeArea(child: wallet()),
    SafeArea(child: CartScreen()),
    SafeArea(child: SettingsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      title: Center(
                        child: Column(
                          children: [
                            Icon(Icons.exit_to_app,
                                color: Colors.red, size: 30),
                            const SizedBox(height: 10),
                            Text("Sign Out",
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 25,
                                )),
                          ],
                        ),
                      ),
                      content: Text(
                          textAlign: TextAlign.center,
                          "Are you sure you want to sign out?",
                          style: GoogleFonts.bebasNeue(
                            fontSize: 20,
                          )),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel",
                              style: GoogleFonts.bebasNeue(
                                color: Colors.black,
                                fontSize: 20,
                              )),
                        ),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black)
                            : TextButton(
                                onPressed: () async {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                  }
                                  await AuthService().signOut();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => Wrapper()),
                                    (Route<dynamic> route) => false,
                                  );
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                                child: Text("Sign Out",
                                    style: GoogleFonts.bebasNeue(
                                      color: Colors.red[600],
                                      fontSize: 20,
                                    )),
                              ),
                      ],
                    );
                  });
                });
          },
          icon: Icon(Icons.exit_to_app, size: 30, color: Colors.red[600]),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: Search());
              },
              icon: Icon(
                Icons.search,
                size: 35,
              )),
        ],
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: Consumer<shopInfo>(
          builder: (context, value, child) => Text(
            value.getShopName().toString(),
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: GoogleFonts.bebasNeue(),
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 25,
          selectedItemColor: Colors.green[600],
          currentIndex: _SelectedIndex,
          onTap: (index) {
            if (mounted) {
              setState(() {
                _SelectedIndex = index;
              });
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              label: "Wallet",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            )
          ]),
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _connectionStatus == 'Unknown'
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
          : _connectionStatus == "No Connection"
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("No Network Connection",
                          style: GoogleFonts.bebasNeue(
                            fontSize: 18,
                            color: Colors.black,
                          )),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(MediaQuery.sizeOf(context).width, 50)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            onPressed: _checkConnection,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Retry",
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Icon(
                                  Icons.refresh_outlined,
                                  color: Colors.black,
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                )
              : _Pages.elementAt(_SelectedIndex),
    );
  }
}
