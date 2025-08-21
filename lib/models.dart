/// Clases para mapear las respuestas (WorkSession, DayStatus)
library;

class WorkSession {
  final String id, userId, status;
  final DateTime date;
  final int sequence;
  final DateTime? checkInAt, checkOutAt;

  WorkSession({
    required this.id,
    required this.userId,
    required this.date,
    required this.sequence,
    this.checkInAt,
    this.checkOutAt,
    required this.status,
  });

  Duration get duration =>
      (checkInAt != null && checkOutAt != null) ? checkOutAt!.difference(checkInAt!) : Duration.zero;

  factory WorkSession.fromJson(Map<String, dynamic> j) {
    DateTime dOnly(dynamic v) {
      final s = v is String ? v : (v?.toString() ?? '');
      return DateTime.parse(
        s.replaceFirst('Z', '+00:00'),
      ); // viene con medianoche UTC en la función
    }

    DateTime? dt(dynamic v) {
      if (v == null || (v is String && v.isEmpty)) return null;
      final s = v is String ? v : v.toString();
      return DateTime.parse(s.replaceFirst('Z', '+00:00'));
    }

    return WorkSession(
      id: (j[r'$id'] ?? j['id'] ?? '') as String,
      userId: (j['user_id'] ?? '') as String,
      date: dOnly(j['date']),
      sequence: (j['sequence'] as num).toInt(),
      checkInAt: dt(j['check_in_at']),
      checkOutAt: dt(j['check_out_at']),
      status: (j['status'] ?? '') as String,
    );
  }
}

class DayStatus {
  final String date;
  final int count;
  final bool open;
  final List<WorkSession> sessions;

  DayStatus({
    required this.date,
    required this.count,
    required this.open,
    required this.sessions,
  });

  factory DayStatus.fromJson(Map<String, dynamic> j) => DayStatus(
        date: (j['date'] ?? '') as String,
        count: (j['count'] as num).toInt(),
        open: j['open'] as bool,
        sessions: (j['sessions'] as List).map((e) => WorkSession.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
