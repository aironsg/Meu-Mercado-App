import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
// Note: Removemos o import desnecessário de 'package:flutter/material.dart'

class SplashController {
  // O método initialize não precisa mais de BuildContext
  Future<void> initialize() async {
    // 1. Aguarda o tempo da animação
    await Future.delayed(const Duration(seconds: 3));

    // 2. Verifica o usuário APÓS o tempo de espera e APÓS o Firebase ser inicializado no main
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Navega para a rota '/home'
      Modular.to.navigate('/home');
    } else {
      // Navega para a rota '/login'
      Modular.to.navigate('/login');
    }
  }
}
