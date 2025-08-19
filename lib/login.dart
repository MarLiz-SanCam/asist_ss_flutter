///formulario mínimo para iniciar sesión

import 'package:flutter/material.dart';
import 'services.dart';
import 'home.dart';

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState()=>_S(); }
class _S extends State<LoginPage>{
  final _email=TextEditingController(), _pass=TextEditingController(); bool _loading=false;
  Future<void> _go() async {
    setState(()=>_loading=true);
    try{
      final auth=AuthService(); await auth.login(_email.text.trim(), _pass.text);
      final jwt=await auth.jwt();
      if(!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>HomePage(jwt: jwt)));
    } catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    finally{ if(mounted) setState(()=>_loading=false); }
  }
  @override Widget build(BuildContext c)=>Scaffold(
    appBar: AppBar(title: const Text('Ingresar')),
    body: Padding(padding: const EdgeInsets.all(16), child: Column(children:[
      TextField(controller:_email, decoration: const InputDecoration(labelText:'Email')),
      TextField(controller:_pass, decoration: const InputDecoration(labelText:'Contraseña'), obscureText:true),
      const SizedBox(height:16),
      FilledButton(onPressed:_loading?null:_go, child:_loading?const CircularProgressIndicator():const Text('Entrar')),
    ])),
  );
}
