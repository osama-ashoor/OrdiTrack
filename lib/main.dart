import 'package:b2b/auth/wrapper.dart';
import 'package:b2b/cart.dart';
import 'package:b2b/orderProvider.dart';

import 'package:b2b/shopInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>(
          create: (context) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProvider<Cart>(
          create: (context) => Cart(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (context) => OrderProvider(),
        ),
        ChangeNotifierProvider<shopInfo>(
          create: (context) => shopInfo(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
      ),
      home: Wrapper(),
    );
  }
}
