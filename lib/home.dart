///llama a /status para mostrar el estado, botón único que cambia entre marcar entrada/marcar salida y refresca

import 'package:flutter/material.dart';
import 'services.dart';
import 'models.dart';

class HomePage extends StatefulWidget { const HomePage({super.key, required this.jwt}); final String jwt;
  @override State<HomePage> createState()=>_S(); }
class _S extends State<HomePage>{
  late final AttendanceService _svc = AttendanceService(widget.jwt);
  DayStatus? _st; bool _busy=false; bool _init=true;

  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    try{ final s=await _svc.status(); if(!mounted) return; setState(()=>_st=s);}
    catch(e){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));}
    finally{ if(mounted) setState(()=>_init=false); }
  }
  Future<void> _action() async {
    if(_st==null) return; setState(()=>_busy=true);
    try{
      if(_st!.open) { await _svc.checkOut(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Salida registrada'))); }
      else { if(_st!.count>=2){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ya registraste 2 sesiones hoy'))); return; }
             await _svc.checkIn(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Entrada registrada'))); }
      await _load();
    } catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    finally{ if(mounted) setState(()=>_busy=false); }
  }

  @override Widget build(BuildContext c){
    if(_init) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final open=_st?.open??false; final count=_st?.count??0;
    final enabled = open || count<2;
    final label = open? 'Marcar salida' : (count>=2? 'Límite alcanzado' : 'Marcar entrada');
    return Scaffold(
      appBar: AppBar(title: const Text('Asistencias')),
      body: RefreshIndicator(onRefresh:_load, child: ListView(padding: const EdgeInsets.all(16), children: [
        Text(_st?.date ?? '—', style: Theme.of(c).textTheme.titleMedium),
        const SizedBox(height:12),
        SizedBox(height:58, child: FilledButton(
          onPressed: enabled && !_busy ? _action : null,
          child: _busy? const CircularProgressIndicator() : Text(label),
        )),
        const SizedBox(height:20),
        Text('Sesiones de hoy', style: Theme.of(c).textTheme.titleMedium),
        const SizedBox(height:8),
        ...(_st?.sessions ?? const <WorkSession>[]).map((s)=>Card(child: ListTile(
          title: Text('Bloque ${s.sequence}  •  ${s.status}'),
          subtitle: Text('Entrada: ${s.checkInAt?.toLocal().toString().substring(11,16) ?? '—'}   '
                         'Salida: ${s.checkOutAt?.toLocal().toString().substring(11,16) ?? '—'}'),
          trailing: s.status=='closed'? Text('${s.duration.inHours}h ${s.duration.inMinutes.remainder(60)}m') : null,
        ))),
        if((_st?.sessions.length ?? 0)==0) const Text('Sin registros hoy'),
      ])),
    );
  }
}
