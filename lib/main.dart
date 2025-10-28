import 'package:advanced_mobile_programming_app/app/pages/home_page.dart';
import 'package:advanced_mobile_programming_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AdvanceMobileProgrammingApp());
}

class AdvanceMobileProgrammingApp extends StatelessWidget {
  const AdvanceMobileProgrammingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pemrograman Mobile Lanjut',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
      ),
      home: const HomePage(),
    );
  }
}
