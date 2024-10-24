import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Stream<User?> get currentUser {
    return _auth.userChanges();
  }

  Future signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  Future SignIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } catch (e) {
      return null;
    }
  }

  Future SignUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        CollectionReference tasks =
            FirebaseFirestore.instance.collection('users');
        tasks.doc(user.uid).set({'email': email, 'password': password});
        tasks
            .doc(user.uid)
            .collection("settings")
            .doc("shopInfo")
            .set({'name': "MyShop"});

        return user;
      }
    } catch (e) {
      return null;
    }
  }
}
