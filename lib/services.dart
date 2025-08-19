/// Para el servicio de autenticación (login y contraseña)
/// AttendanceService(jwt) con métodos status() checkIn() y Checkout()

import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'models.dart';

class AuthService {
  final _client = Client()..setEndpoint(AppConfig.endpoint)..setProject(AppConfig.projectId);
  late final Account _account = Account(_client);

  Future<void> login(String email, String pass) async {
    try { await _account.deleteSession(sessionId: 'current'); } catch (_) {}
    await _account.createEmailPasswordSession(email: email, password: pass);
  }

  Future<String> jwt() async => (await _account.createJWT()).jwt;
}

class AttendanceService {
  AttendanceService(this.jwt);
  final String jwt;

  Map<String,String> get _h => {'Content-Type':'application/json','X-Appwrite-User-JWT':jwt};
  Uri _u(String p,[Map<String,String>? q]) => Uri.parse('${AppConfig.attendanceFunctionBase}$p')
      .replace(queryParameters: q);

  Future<DayStatus> status() async {
    final r = await http.get(_u('/status'), headers: _h);
    final d = jsonDecode(r.body) as Map<String,dynamic>;
    if (r.statusCode>=400) throw Exception(d['error']??'Error');
    return DayStatus.fromJson(d);
  }

  Future<void> checkIn() async {
    final r = await http.post(_u('/checkin'), headers: _h, body: '{}');
    if (r.statusCode>=400) throw Exception(jsonDecode(r.body)['error']??'Error');
  }

  Future<void> checkOut() async {
    final r = await http.post(_u('/checkout'), headers: _h, body: '{}');
    if (r.statusCode>=400) throw Exception(jsonDecode(r.body)['error']??'Error');
  }
}
