import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../home/presentation/home_page.dart';
import '../../auth/presentation/login/pages/login_page.dart';

class SplashController {
  Future<void> initialize(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3)); // tempo da animação
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }
}
