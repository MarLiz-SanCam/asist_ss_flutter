/// formulario mínimo para iniciar sesión (mejorado)
library;

import 'package:flutter/material.dart';
import 'services.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Ingresa tu email';
    // validador simple
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s);
    if (!ok) return 'Email no válido';
    return null;
  }

  String? _validatePass(String? v) {
    if ((v ?? '').isEmpty) return 'Ingresa tu contraseña';
    return null;
  }

  String _prettyError(Object e) {
    final msg = e.toString();
    if (msg.contains('invalid_credentials')) return 'Credenciales inválidas';
    if (msg.contains('blocked') || msg.contains('rate')) return 'Demasiados intentos. Intenta más tarde.';
    if (msg.contains('Network')) return 'Error de red. Revisa tu conexión.';
    return msg.replaceFirst('Exception: ', '');
  }

  Future<void> _go() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = AuthService();
      final jwt = await auth.login(_email.text.trim(), _pass.text);
      if (!mounted) return;
      // Si llegó aquí, ya hay sesión -> Functions podrá ejecutarse sin API key
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => HomePage(jwt: jwt)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_prettyError(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'usuario@dominio.com',
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pass,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: _validatePass,
                onFieldSubmitted: (_) => _loading ? null : _go(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _go,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Entrar'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
