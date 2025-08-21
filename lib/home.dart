// ignore_for_file: use_build_context_synchronously
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- añade
import 'services.dart';
import 'models.dart';
import 'login.dart'; // <-- para redirigir si 401

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.jwt});
  final String jwt;
  @override
  State<HomePage> createState() => _S();
}

class _S extends State<HomePage> {
  late final AttendanceService _svc = AttendanceService(widget.jwt);
  DayStatus? _st;
  bool _busy = false;
  bool _init = true;

  final _fmtDate = DateFormat('EEEE d MMM yyyy', 'es_MX'); // mar, 19 ago 2025
  final _fmtTime = DateFormat('HH:mm'); // 08:35

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await _svc.status();
      if (!mounted) return;
      setState(() => _st = s);
    } catch (e) {
      // Si es 401/Unauthorized: regresa a login
      final msg = e.toString();
      if (msg.contains('401') || msg.toLowerCase().contains('unauthorized')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión expirada. Inicia sesión de nuevo.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _init = false);
    }
  }

  Future<void> _action() async {
    if (_st == null) return;
    setState(() => _busy = true);
    try {
      if (_st!.open) {
        await _svc.checkOut();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Salida registrada')));
      } else {
        if (_st!.count >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ya registraste 2 sesiones hoy')));
          return;
        }
        await _svc.checkIn();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Entrada registrada')));
      }
      await _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    if (_init) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final open = _st?.open ?? false;
    final count = _st?.count ?? 0;
    final enabled = open || count < 2;
    final label = open ? 'Marcar salida' : (count >= 2 ? 'Límite alcanzado' : 'Marcar entrada');

    // Formatea fecha bonita (a partir del ISO de _st!.date)
    String friendlyDate = '—';
    if (_st?.date != null && _st!.date.isNotEmpty) {
      try {
        final dt = DateTime.parse(_st!.date.replaceFirst('Z', '+00:00')).toLocal();
        friendlyDate = _fmtDate.format(dt);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencias'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(), // <-- importante
          children: [
            Text(friendlyDate, style: Theme.of(c).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 58,
              child: FilledButton.icon(
                onPressed: enabled && !_busy ? _action : null,
                icon: _busy
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(open ? Icons.logout : (enabled ? Icons.login : Icons.lock)),
                label: Text(label),
              ),
            ),
            const SizedBox(height: 20),
            Text('Sesiones de hoy', style: Theme.of(c).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...(_st?.sessions ?? const <WorkSession>[]).map((s) {
              final inStr = s.checkInAt != null ? _fmtTime.format(s.checkInAt!.toLocal()) : '—';
              final outStr = s.checkOutAt != null ? _fmtTime.format(s.checkOutAt!.toLocal()) : '—';
              final dur = s.duration;
              final durStr = dur == Duration.zero ? '' : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';

              return Card(
                child: ListTile(
                  title: Text('Bloque ${s.sequence}  •  ${s.status}'),
                  subtitle: Text('Entrada: $inStr   Salida: $outStr'),
                  trailing: s.status == 'closed' ? Text(durStr) : null,
                ),
              );
            }),
            if ((_st?.sessions.length ?? 0) == 0)
              const Text('Sin registros hoy'),
          ],
        ),
      ),
    );
  }
}
