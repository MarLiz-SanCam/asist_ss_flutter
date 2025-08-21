import 'package:asist_ss/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa datos de la locale que vas a usar
  await initializeDateFormatting('es_MX', null);
  // (Opcional) fija la locale por defecto
  Intl.defaultLocale = 'es_MX';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistencias',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // o tu widget inicial
    );
  }
}
