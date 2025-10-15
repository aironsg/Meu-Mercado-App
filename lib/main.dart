import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meu_mercado/app/test_data_initializer.dart';
import 'app/app_module.dart';
import 'app/app_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //remover esta linha apos o teste de mock
  // await TestDataInitializer().initializeMockData();

  runApp(
    ProviderScope(
      child: ModularApp(module: AppModule(), child: const AppWidget()),
    ),
  );
}
