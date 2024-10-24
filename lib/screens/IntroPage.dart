import 'package:b2b/databaseService/database.dart';
import 'package:b2b/screens/Home.dart';
import 'package:b2b/shopInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool _isLoading = false;
  String shop = "";
  initState() {
    setShopInfo();
    super.initState();
  }

  void setShopInfo() async {
    setState(() {
      _isLoading = true;
    });
    shop = await Database().getShopInfo();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading) {
      return Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: 120,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  shop,
                  style: GoogleFonts.bebasNeue(
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Orders Management App",
                  style: GoogleFonts.bebasNeue(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 25,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Consumer<shopInfo>(
                  builder: (context, value, child) => GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                        size: 35,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onTap: () {
                      value.setShopName(shop);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Home()));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      );
    }
  }
}
