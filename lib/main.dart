import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF2563EB)),
    home: const LoginPage(),
  ));
}
