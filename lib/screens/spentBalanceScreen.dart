import 'package:b2b/databaseService/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpentBalance extends StatefulWidget {
  const SpentBalance({super.key});

  @override
  State<SpentBalance> createState() => _SpentBalanceState();
}

class _SpentBalanceState extends State<SpentBalance> {
  String selectedValue = "User1";
  double spentAmount = 0.0;
  bool _isDeleteing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Spent Balance",
          style: GoogleFonts.bebasNeue(
            fontSize: 30,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Database().getSpentProcesses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
              "Something went wrong",
              style: GoogleFonts.bebasNeue(fontSize: 30),
            ));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No Processes Found",
                style: GoogleFonts.bebasNeue(fontSize: 30),
              ),
            );
          }

          Iterable<QueryDocumentSnapshot> data = snapshot.data!.docs
              .where((element) => element.get("name") == selectedValue);
          spentAmount = 0.0;
          for (int i = 0; i < data.length; i++) {
            spentAmount +=
                double.parse(data.elementAt(i).get("amount").toString());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField(
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
                    items: [
                      DropdownMenuItem(
                        value: 'User1',
                        child: Text("User1",
                            style: GoogleFonts.bebasNeue(
                              fontSize: 22,
                            )),
                      ),
                      DropdownMenuItem(
                        value: "User2",
                        child: Text("User2",
                            style: GoogleFonts.bebasNeue(
                              fontSize: 22,
                            )),
                      ),
                    ],
                    value: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value.toString();
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 300), // Animation duration
                  child: Padding(
                    key: ValueKey(
                        spentAmount), // Ensures smooth transition when spentAmount changes
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: ListTile(
                        trailing: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 35,
                        ),
                        subtitle: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(spentAmount.toString(),
                              style: GoogleFonts.bebasNeue(
                                fontSize: 18,
                              )),
                        ),
                        title: Text(
                          "SPENT BALANCE",
                          style: GoogleFonts.bebasNeue(
                            fontSize: 19,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ListView.builder(
                    key: ValueKey(
                        data.length), // Change triggers smooth transition
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          title: Text(
                            "Withdrawal At ${data.elementAt(index).get("date")}",
                            style: GoogleFonts.bebasNeue(
                              fontSize: 18,
                            ),
                          ),
                          leading: IconButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) => StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                            content: Text(
                                              textAlign: TextAlign.center,
                                              "Are you sure you want to delete this process?",
                                              style: GoogleFonts.bebasNeue(
                                                  fontSize: 25,
                                                  color: Colors.black),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "Cancel",
                                                  style: GoogleFonts.bebasNeue(
                                                      fontSize: 20,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      _isDeleteing = true;
                                                    });
                                                    await Database()
                                                        .deleteWithdraw(data
                                                            .elementAt(index)
                                                            .id);
                                                    setState(() {
                                                      _isDeleteing = false;
                                                    });
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
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
                                                            'Withdrawal Deleted',
                                                            style: GoogleFonts
                                                                .bebasNeue(
                                                                    fontSize:
                                                                        25),
                                                          )),
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  },
                                                  child: _isDeleteing
                                                      ? CircularProgressIndicator(
                                                          color: Colors.red)
                                                      : Text(
                                                          "Delete",
                                                          style: GoogleFonts
                                                              .bebasNeue(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .red),
                                                        ))
                                            ]);
                                      }));
                            },
                            icon: Icon(
                              size: 25,
                              Icons.delete_forever_rounded,
                              color: Colors.red,
                            ),
                          ),
                          trailing: FittedBox(
                            alignment: Alignment.centerRight,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "- " +
                                  data
                                      .elementAt(index)
                                      .get("amount")
                                      .toString(),
                              style: GoogleFonts.bebasNeue(
                                  fontSize: 18, color: Colors.red[600]),
                            ),
                          ),
                          subtitle: Text(
                            data.elementAt(index).get("name"),
                            style: GoogleFonts.bebasNeue(
                                fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
