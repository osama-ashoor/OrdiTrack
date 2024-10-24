import 'package:b2b/auth/auth.dart';
import 'package:b2b/screens/IntroPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<User?>(
      builder: (context, user, child) {
        if (user == null) {
          return const auth(); // Show Auth page
        } else {
          return const IntroPage(); // Show Intro page
        }
      },
    );
  }
}
