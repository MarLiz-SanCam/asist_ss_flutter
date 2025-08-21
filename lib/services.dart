/// Servicios: autenticación con sesión y ejecución de Function de asistencia
library;

import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'config.dart';
import 'models.dart';

class AuthService {
  final _client = Client()
    ..setEndpoint(AppConfig.endpoint)
    ..setProject(AppConfig.projectId);

  late final Account _account = Account(_client);

  /// Crea sesión de email/contraseña y devuelve un JWT (opcional para tu UI).
  Future<String> login(String email, String pass) async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {
      // ignorar si no había sesión
    }
    await _account.createEmailPasswordSession(email: email, password: pass);
    final jwt = await _account.createJWT();
    return jwt.jwt; // lo usas para navegar como ya tienes en LoginPage
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {}
  }
}

class AttendanceService {
  final String jwt; // no se usa para la Function, pero mantenemos firma
  AttendanceService(this.jwt);

  final _client = Client()
    ..setEndpoint(AppConfig.endpoint)
    ..setProject(AppConfig.projectId);

  late final Functions _functions = Functions(_client);

  Future<Map<String, dynamic>> _exec(Map<String, dynamic> body) async {
    // IMPORTANTE: la sesión del usuario debe existir (createEmailSession previo).
    final ex = await _functions.createExecution(
      functionId: AppConfig.functionId,
      body: jsonEncode(body),
    );
    // En el SDK de Dart, la respuesta JSON de tu Function viene en `ex.response`
    final txt = ex.responseBody;// string
    final Map<String, dynamic> json = jsonDecode(txt);
    if (json['success'] == true) return json;
    throw Exception(json['error'] ?? 'Error');
  }

  /// Estado del día (cuántos bloques, abiertos, etc.)
  Future<DayStatus> status() async {
    final j = await _exec({
      'action': 'status',
      'tz': AppConfig.defaultTz,
    });
    return DayStatus.fromJson(j);
  }

  Future<void> checkIn() async {
    await _exec({
      'action': 'check_in',
      'tz': AppConfig.defaultTz,
    });
  }

  Future<void> checkOut() async {
    await _exec({
      'action': 'check_out',
      'tz': AppConfig.defaultTz,
    });
  }
}
