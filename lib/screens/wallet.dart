import 'dart:async';
import 'package:b2b/auth/AuthService.dart';
import 'package:b2b/auth/wrapper.dart';
import 'package:b2b/databaseService/database.dart';
import 'package:b2b/screens/Home.dart';
import 'package:b2b/screens/OrdersScreen.dart';
import 'package:b2b/screens/cartScreen.dart';
import 'package:b2b/screens/settings.dart';
import 'package:b2b/screens/spentBalanceScreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class wallet extends StatefulWidget {
  const wallet({super.key});

  @override
  State<wallet> createState() => _walletState();
}

class _walletState extends State<wallet> {
  String _connectionStatus = "Unknown";
  bool _isWithdrawalLoading = false;

  @override
  initState() {
    super.initState();
    getTotalAmount();
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

  Future<void> getTotalAmount() async {
    if (mounted) {
      setState(() {
        _isWithdrawalLoading = true;
      });
    }
    await _checkConnection();
    if (_connectionStatus == 'No Connection') {
      if (mounted) {
        setState(() {
          _isWithdrawalLoading = false;
        });
      }
      return;
    }
    _totalAmount = await Database().getTotalAmount();
    _currentBalance = await Database().getCurrentBalance();
    _spentAmount = await Database().getSpentAmount();
    _upcomingAmount = await Database().getPendingBalance();
    _earnedAmount = await Database().getEarnedAmount();
    if (mounted) {
      setState(() {
        _isWithdrawalLoading = false;
      });
    }
  }

  double _currentBalance = 0.0;
  double _totalAmount = 0.0;
  double _spentAmount = 0.0;
  double _upcomingAmount = 0.0;
  double _earnedAmount = 0.0;

  List<String> dropdownItems = ['User1', 'User2', 'Other']; // Initial items
  String selectedValue = "User1";
  TextEditingController customValueController = TextEditingController();
  bool isLoading = false;
  double withdrawalAmount = 0.0;
  bool _isDeleteing = false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.background,
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
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
              if (isLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.black,
                ));
              } else {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          items: dropdownItems
                              .map((item) => DropdownMenuItem(
                                    child: Text(
                                      item,
                                      style:
                                          GoogleFonts.bebasNeue(fontSize: 18),
                                    ),
                                    value: item,
                                  ))
                              .toList(),
                          value: selectedValue,
                          onChanged: (value) {
                            if (value == 'Other') {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Enter custom value"),
                                  content: TextField(
                                    controller: customValueController,
                                    decoration: InputDecoration(
                                        hintText: "Enter value"),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        if (customValueController
                                            .text.isNotEmpty) {
                                          if (mounted) {
                                            setBuilderState(() {
                                              dropdownItems.add(
                                                  customValueController.text);
                                              selectedValue =
                                                  customValueController.text;
                                            });
                                          }
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Save"),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              if (mounted) {
                                setBuilderState(() {
                                  selectedValue = value.toString();
                                });
                              }
                            }
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter withdrawal amount';
                            }
                            if (double.tryParse(value) != null) {
                              return null;
                            }
                            if (int.tryParse(value) != null) {
                              return null;
                            }

                            return 'Please enter valid amount';
                          },
                          onSaved: (newValue) {
                            withdrawalAmount = double.parse(newValue!);
                          },
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            labelText: 'withdrawal amount',
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            hintText: 'Enter withdrawal amount',
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
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
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width,
                                            50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await _checkConnection();
                                        if (_connectionStatus ==
                                            "No Connection") {
                                          if (mounted) {
                                            setBuilderState(() {
                                              _connectionStatus =
                                                  "No Connection";
                                            });
                                          }
                                          return;
                                        }
                                        if (_formKey.currentState!.validate()) {
                                          if (mounted) {
                                            setBuilderState(() {
                                              isLoading = true;
                                            });
                                          }
                                          _formKey.currentState!.save();
                                          await Database().addWithdraw(
                                              withdrawalAmount, selectedValue);
                                          if (mounted) {
                                            setBuilderState(() {
                                              isLoading = false;
                                            });
                                          }
                                          Navigator.of(context).pop();
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
                                                            0.1),
                                                child: Center(
                                                    child: Text(
                                                  'Withdrawal Successful',
                                                  style: GoogleFonts.bebasNeue(
                                                      fontSize: 18),
                                                )),
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          if (mounted) {
                                            setState(() {
                                              _isWithdrawalLoading = true;
                                            });
                                          }
                                          _totalAmount =
                                              await Database().getTotalAmount();
                                          _currentBalance = await Database()
                                              .getCurrentBalance();
                                          _spentAmount =
                                              await Database().getSpentAmount();
                                          _upcomingAmount = await Database()
                                              .getPendingBalance();
                                          _earnedAmount = await Database()
                                              .getEarnedAmount();
                                          if (mounted) {
                                            setState(() {
                                              _isWithdrawalLoading = false;
                                            });
                                          }
                                        }
                                      },
                                      child: Text(
                                        "Withdraw",
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 30,
                                          color: Colors.black,
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                _connectionStatus == "No Connection"
                                    ? Text(
                                        "Check Your Network Connection And Try Again",
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 16,
                                          color: Colors.red,
                                        ))
                                    : Container(),
                              ],
                            ))
                      ],
                    ),
                  ),
                );
              }
            });
          },
        );
      },
    );
  }

  int _SelectedIndex = 3;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isWithdrawalLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black))
            : _connectionStatus != "No Connection"
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: ListTile(
                                      subtitle: FittedBox(
                                        alignment: Alignment.centerLeft,
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                            (_totalAmount % 1 == 0)
                                                ? _totalAmount
                                                    .toInt()
                                                    .toString()
                                                : _totalAmount
                                                    .toStringAsFixed(2),
                                            style: GoogleFonts.bebasNeue(
                                              fontSize: 25,
                                              color: Colors.black,
                                            )),
                                      ),
                                      title: Text(
                                        "TOTAL BALANCE",
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 19,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: ListTile(
                                      subtitle: FittedBox(
                                        alignment: Alignment.centerLeft,
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                            (_earnedAmount % 1 == 0)
                                                ? _earnedAmount
                                                    .toInt()
                                                    .toString()
                                                : _earnedAmount
                                                    .toStringAsFixed(2),
                                            style: GoogleFonts.bebasNeue(
                                              fontSize: 25,
                                              color: Colors.black,
                                            )),
                                      ),
                                      title: Text(
                                        "EARNED BALANCE",
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 19,
                                          color: Colors.green[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => SpentBalance(),
                                      ))
                                          .then((value) async {
                                        if (mounted) {
                                          setState(() {
                                            _isWithdrawalLoading = true;
                                          });
                                        }

                                        _totalAmount =
                                            await Database().getTotalAmount();
                                        _currentBalance = await Database()
                                            .getCurrentBalance();
                                        _spentAmount =
                                            await Database().getSpentAmount();
                                        _upcomingAmount = await Database()
                                            .getPendingBalance();
                                        _earnedAmount =
                                            await Database().getEarnedAmount();
                                        if (mounted) {
                                          setState(() {
                                            _isWithdrawalLoading = false;
                                          });
                                        }
                                      });
                                    },
                                    trailing: Icon(
                                      Icons.arrow_outward_rounded,
                                      size: 35,
                                    ),
                                    subtitle: FittedBox(
                                      alignment: Alignment.centerLeft,
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                          _spentAmount % 1 == 0
                                              ? _spentAmount.toInt().toString()
                                              : _spentAmount.toStringAsFixed(2),
                                          style: GoogleFonts.bebasNeue(
                                            fontSize: 25,
                                            color: Colors.black,
                                          )),
                                    ),
                                    title: Text(
                                      "SPENT BALANCE",
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 19,
                                        color: Colors.red[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: ListTile(
                                    trailing: Icon(
                                        Icons.account_balance_wallet_rounded,
                                        size: 35,
                                        color: Colors.yellow[600]),
                                    subtitle: FittedBox(
                                      alignment: Alignment.centerLeft,
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                          _upcomingAmount % 1 == 0
                                              ? _upcomingAmount
                                                  .toInt()
                                                  .toString()
                                              : _upcomingAmount
                                                  .toStringAsFixed(2),
                                          style: GoogleFonts.bebasNeue(
                                            fontSize: 25,
                                            color: Colors.yellow[600],
                                          )),
                                    ),
                                    title: Text(
                                      "UPCOMING BALANCE",
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 19,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: ListTile(
                                    trailing: Icon(
                                        Icons.account_balance_wallet_rounded,
                                        size: 35,
                                        color: Colors.green[600]),
                                    subtitle: FittedBox(
                                      alignment: Alignment.centerLeft,
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                          _currentBalance % 1 == 0
                                              ? _currentBalance
                                                  .toInt()
                                                  .toString()
                                              : _currentBalance
                                                  .toStringAsFixed(2),
                                          style: GoogleFonts.bebasNeue(
                                            fontSize: 25,
                                            color: Colors.green,
                                          )),
                                    ),
                                    title: Text(
                                      "Current BALANCE",
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 19,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async {
                                      showBottomSheet(context);
                                    },
                                    child: Text(
                                      "Withdraw Funds",
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(builder:
                                              (context, setBuilderState) {
                                            return AlertDialog(
                                              title: Center(
                                                child: Text("Reset Wallet",
                                                    style:
                                                        GoogleFonts.bebasNeue(
                                                      fontSize: 30,
                                                    )),
                                              ),
                                              content: Text(
                                                  "Are you sure you want to reset your wallet?\nThis will reset all your data.",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.bebasNeue(
                                                    fontSize: 20,
                                                  )),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("Cancel",
                                                      style:
                                                          GoogleFonts.bebasNeue(
                                                        fontSize: 20,
                                                        color: Colors.black,
                                                      )),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _checkConnection();
                                                    if (_connectionStatus ==
                                                        'No Connection') {
                                                      Navigator.of(context)
                                                          .pop();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              Colors.red,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          content: Container(
                                                            margin: EdgeInsets.symmetric(
                                                                horizontal: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.1),
                                                            child: Center(
                                                                child: Text(
                                                              "No Network Connection",
                                                              style: GoogleFonts
                                                                  .bebasNeue(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )),
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    if (mounted) {
                                                      setBuilderState(() {
                                                        _isDeleteing = true;
                                                      });
                                                    }
                                                    await Database()
                                                        .resetWallet();
                                                    if (mounted) {
                                                      setBuilderState(() {
                                                        _isDeleteing = false;
                                                      });
                                                    }
                                                    Navigator.of(context).pop();
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
                                                            "Wallet Has Been Reset",
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
                                                    if (mounted) {
                                                      setState(() {
                                                        _isWithdrawalLoading =
                                                            true;
                                                      });
                                                    }
                                                    _totalAmount =
                                                        await Database()
                                                            .getTotalAmount();
                                                    _currentBalance =
                                                        await Database()
                                                            .getCurrentBalance();
                                                    _spentAmount =
                                                        await Database()
                                                            .getSpentAmount();
                                                    _upcomingAmount =
                                                        await Database()
                                                            .getPendingBalance();
                                                    _earnedAmount =
                                                        await Database()
                                                            .getEarnedAmount();
                                                    if (mounted) {
                                                      setState(() {
                                                        _isWithdrawalLoading =
                                                            false;
                                                      });
                                                    }
                                                  },
                                                  child: _isDeleteing
                                                      ? CircularProgressIndicator(
                                                          color:
                                                              Colors.red[600],
                                                        )
                                                      : Text("Reset",
                                                          style: GoogleFonts
                                                              .bebasNeue(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.red[600],
                                                          )),
                                                ),
                                              ],
                                            );
                                          });
                                        },
                                      );
                                    },
                                    child: Text(
                                      "Reset Wallet",
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
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
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
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
                              onPressed: getTotalAmount,
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
                  ));
  }
}
