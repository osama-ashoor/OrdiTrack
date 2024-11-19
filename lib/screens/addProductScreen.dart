import 'dart:async';
import 'dart:io';
import 'package:b2b/databaseService/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class addProduct extends StatefulWidget {
  const addProduct({super.key});

  @override
  State<addProduct> createState() => _addProductState();
}

class _addProductState extends State<addProduct> {
  String _connectionStatus = 'No Connection';
  XFile? _image;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isAdding = false;
  String name = "";
  String sellprice = "";
  String percentage = "";
  String code = "";
  double buyPriceAfterExchange = 0.0;
  String buyprice = "0";
  String originalBuyPrice = "0";
  String _DefaultImageUrl =
      "https://firebasestorage.googleapis.com/v0/b/b2b-store-9f4f1.appspot.com/o/products%2Fdefault-product.30484205.png?alt=media&token=2ea6ead8-9c5b-4c4e-a977-a320d50c56a8";
  File imageFile = File("");
  void pickImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  void initState() {
    setCurrencyExchange();
    _checkConnection();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
    super.initState();
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

  Future<void> setCurrencyExchange() async {
    currencyExchangeUSA = await Database().getCurrencyExchangeUSA();
    currencyExchangeTRY = await Database().getCurrencyExchangeTRY();
  }

  String _SelectedValue = "TRY";
  double currencyExchangeUSA = 0.0;
  double currencyExchangeTRY = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
              elevation: 2,
              value: _SelectedValue,
              items: [
                DropdownMenuItem(
                  child: FaIcon(FontAwesomeIcons.turkishLiraSign),
                  value: "TRY",
                ),
                DropdownMenuItem(
                  child: FaIcon(FontAwesomeIcons.dollarSign),
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
        ],
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: Text(
          "Add Product",
          style: GoogleFonts.bebasNeue(
            fontSize: 32,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                radius: 100,
                child: ClipOval(
                  child: _image == null
                      ? Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.grey,
                        )
                      : Image.file(
                          File(_image!.path),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.2),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.inversePrimary,
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                      Size(
                        MediaQuery.of(context).size.width * 0.5,
                        50,
                      ),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )),
                  ),
                  onPressed: pickImage,
                  child: Text(
                    'Upload Image',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 25,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  if (double.tryParse(value) != null) {
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
                        ? (currencyExchangeTRY != 0.0
                            ? (((double.parse(originalBuyPrice) /
                                                currencyExchangeTRY) +
                                            3) *
                                        currencyExchangeUSA)
                                    .toStringAsFixed(2) +
                                " LYD"
                            : (((double.parse(originalBuyPrice) *
                                                currencyExchangeTRY) +
                                            3) *
                                        currencyExchangeUSA)
                                    .toStringAsFixed(2) +
                                " LYD")
                        : ((double.parse(originalBuyPrice)) *
                                    currencyExchangeUSA)
                                .toStringAsFixed(2) +
                            " LYD",
                    style: GoogleFonts.bebasNeue(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  labelText: 'Product Original Price',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  hintText: 'Enter Product Original Price',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black, // Border color when enabled
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
              _SelectedValue == "TRY"
                  ? TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product buy price';
                        }
                        if (double.tryParse(value) != null) {
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
                                ? (currencyExchangeTRY != 0.0
                                    ? (((double.parse(originalBuyPrice) /
                                                        currencyExchangeTRY) +
                                                    3) *
                                                currencyExchangeUSA)
                                            .toStringAsFixed(2) +
                                        " LYD"
                                    : (((double.parse(originalBuyPrice) *
                                                        currencyExchangeTRY) +
                                                    3) *
                                                currencyExchangeUSA)
                                            .toStringAsFixed(2) +
                                        " LYD")
                                : ((double.parse(originalBuyPrice) + 6) *
                                            currencyExchangeUSA)
                                        .toStringAsFixed(2) +
                                    " LYD",
                        hintStyle: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black, // Border color when enabled
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                      ),
                    )
                  : TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter percentage %';
                        }
                        if (double.tryParse(value) != null) {
                          return null;
                        }
                        if (int.tryParse(value) != null) {
                          return null;
                        }

                        return 'Please enter valid percentage %';
                      },
                      onChanged: (value) {
                        setState(() {
                          percentage = value;
                          if (originalBuyPrice.isNotEmpty) {
                            if (_SelectedValue == "TRY") {
                              buyPriceAfterExchange =
                                  (((double.parse(originalBuyPrice) /
                                              currencyExchangeTRY) +
                                          3) *
                                      currencyExchangeUSA);
                            } else {
                              buyPriceAfterExchange =
                                  ((double.parse(originalBuyPrice)) *
                                      currencyExchangeUSA);
                            }
                          }
                        });
                      },
                      onSaved: (newValue) {
                        percentage = newValue!;
                      },
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'percentage %',
                        labelStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        hintText: 'Enter percentage %',
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black, // Border color when enabled
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
              _SelectedValue == "TRY"
                  ? TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product sell price';
                        }
                        if (double.tryParse(value) != null) {
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
                        hintText: 'Enter Product Sell Price',
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black, // Border color when enabled
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (percentage == "" || originalBuyPrice == "")
                                ? "No Price"
                                : (sellprice = (buyPriceAfterExchange +
                                            ((buyPriceAfterExchange *
                                                    double.parse(percentage)) /
                                                100))
                                        .toStringAsFixed(2)) +
                                    " LYD",
                            style: GoogleFonts.bebasNeue(
                              fontSize: 19,
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          FaIcon(
                            FontAwesomeIcons.moneyBillAlt,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product code';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  code = newValue!;
                },
                style: const TextStyle(
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  labelText: 'Product Code',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  hintText: 'Enter Product Code',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
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
              _isAdding
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.black,
                    ))
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.inversePrimary,
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(
                            MediaQuery.of(context).size.width * 0.5,
                            50,
                          ),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                      ),
                      onPressed: () async {
                        if (_connectionStatus == "No Connection") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              content: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.1),
                                child: Center(
                                    child: Text(
                                  "No Network Connection",
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                )),
                              ),
                            ),
                          );
                          return;
                        }
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            _isAdding = true;
                          });
                          if (_image == null) {
                            if (_SelectedValue == "USD") {
                              await Database().addProducts(
                                  name,
                                  double.parse(sellprice),
                                  buyPriceAfterExchange,
                                  code,
                                  _DefaultImageUrl);
                            } else {
                              await Database().addProducts(
                                  name,
                                  double.parse(sellprice),
                                  double.parse(buyprice),
                                  code,
                                  _DefaultImageUrl);
                            }
                          } else {
                            if (_SelectedValue == "USD") {
                              await Database().UploadImage(
                                  _image!,
                                  name,
                                  double.parse(sellprice),
                                  buyPriceAfterExchange,
                                  code);
                            } else {
                              await Database().UploadImage(
                                  _image!,
                                  name,
                                  double.parse(sellprice),
                                  double.parse(buyprice),
                                  code);
                            }
                          }
                          setState(() {
                            _image = null;
                            _isAdding = false;
                            buyPriceAfterExchange = 0.0;
                          });
                          _formKey.currentState!.reset();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.1),
                                child: Center(
                                    child: Text(
                                  'Product Added Successfully',
                                  style: GoogleFonts.bebasNeue(fontSize: 25),
                                )),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Add Product',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 25,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
