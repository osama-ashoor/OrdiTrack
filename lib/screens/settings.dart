import 'package:b2b/databaseService/database.dart';
import 'package:b2b/shopInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  String shopName = "";
  double currencyExchangeUSA = 0.0;
  double currencyExchangeTRY = 0.0;
  void showBottomSheet(BuildContext context) {
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
          maxChildSize: 0.9, // Maximum height the modal can be expanded to
          expand: false, // Prevents expanding to full screen height
          builder: (context, scrollController) {
            return StatefulBuilder(builder: (context, setBuilderState) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag, size: 70),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your shop name';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          shopName = newValue!;
                        },
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Your Shop Name',
                          labelStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          hintText: 'Enter Your Shop Name',
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black, // Border color when enabled
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
                        height: 20,
                      ),
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                setBuilderState(() {
                                  _isLoading = true;
                                });
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  await Database().setShopInfo(shopName);
                                  if (mounted) {
                                    setBuilderState(() {
                                      Provider.of<shopInfo>(context,
                                              listen: false)
                                          .setShopName(shopName);

                                      _isLoading = false;
                                    });
                                  }

                                  // Pop the bottom sheet only after the state update
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                              child: Text(
                                'Save',
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 35,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }

  void showCurrencyBottomSheet(BuildContext context) {
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
          maxChildSize: 0.9, // Maximum height the modal can be expanded to
          expand: false, // Prevents expanding to full screen height
          builder: (context, scrollController) {
            return StatefulBuilder(builder: (context, setBuilderState) {
              return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey2,
                    child: _isLoading
                        ? Center(
                            child: const CircularProgressIndicator(
                                color: Colors.black))
                        : Column(
                            children: [
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter usa -> LYD exchange rate';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  currencyExchangeUSA = double.parse(newValue!);
                                },
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.dollarSign,
                                      size: 25,
                                    ),
                                  ),
                                  labelText: 'USA -> LYD exchange rate',
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                  hintText: 'USA -> LYD exchange rate',
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors
                                          .black, // Border color when enabled
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
                                height: 20,
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter try -> usa exchange rate';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  currencyExchangeTRY = double.parse(newValue!);
                                },
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.turkishLiraSign,
                                      size: 25,
                                    ),
                                  ),
                                  labelText: 'TRY -> USA exchange rate',
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                  hintText: 'TRY -> USA exchange rate',
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors
                                          .black, // Border color when enabled
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
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(
                                        MediaQuery.sizeOf(context).width, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setBuilderState(() {
                                      _isLoading = true;
                                    });
                                    if (_formKey2.currentState!.validate()) {
                                      _formKey2.currentState!.save();
                                      await Database().setCurrencyExchange(
                                          currencyExchangeUSA,
                                          currencyExchangeTRY);
                                      await setCurrency();

                                      if (mounted) {
                                        setBuilderState(() {
                                          _isLoading = false;
                                        });
                                      }

                                      if (mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            content: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                              child: Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                        .width,
                                                child: Center(
                                                    child: Text(
                                                  'Currency Exchange Rates Updated Successfully',
                                                  style: GoogleFonts.bebasNeue(
                                                      fontSize: 16),
                                                )),
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Save',
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 35,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 80,
                              ),
                              Text(
                                "Current Exchange Rates",
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 20,
                                ),
                              ),
                              Consumer<shopInfo>(
                                builder: (context, value, child) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("USA -> LYD",
                                            style: GoogleFonts.bebasNeue(
                                              fontSize: 20,
                                            )),
                                        Text(
                                          currencyExchangeUSA.toString(),
                                          style: GoogleFonts.bebasNeue(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Divider(),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("USA -> TRY",
                                            style: GoogleFonts.bebasNeue(
                                              fontSize: 20,
                                            )),
                                        Text(currencyExchangeTRY.toString(),
                                            style: GoogleFonts.bebasNeue(
                                              fontSize: 20,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ));
            });
          },
        );
      },
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  bool _isLoading = false;
  double deliveryPrice = 0;

  @override
  void initState() {
    setCurrency();
    super.initState();
  }

  Future<void> setCurrency() async {
    currencyExchangeUSA = await Database().getCurrencyExchangeUSA();
    currencyExchangeTRY = await Database().getCurrencyExchangeTRY();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: ListTile(
                leading: Icon(
                  Icons.shopping_bag,
                  size: 30,
                ),
                title: Text(
                  "Shop Info",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  showBottomSheet(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: ListTile(
                leading: Icon(
                  Icons.monetization_on,
                  size: 30,
                ),
                title: Text(
                  "Currency Edit",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 18,
                  ),
                ),
                onTap: () async {
                  showCurrencyBottomSheet(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
