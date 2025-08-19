///Clases para mapear las respuestas (worksessions, DayStatus)

class WorkSession {
  final String id, userId, status;
  final DateTime date;
  final int sequence;
  final DateTime? checkInAt, checkOutAt;

  WorkSession({required this.id,required this.userId,required this.date,required this.sequence,
    this.checkInAt,this.checkOutAt,required this.status});

  Duration get duration => (checkInAt!=null && checkOutAt!=null)
      ? checkOutAt!.difference(checkInAt!) : Duration.zero;

  factory WorkSession.fromJson(Map<String,dynamic> j){
    DateTime dOnly(String s){ final p=s.split('-'); return DateTime.utc(int.parse(p[0]),int.parse(p[1]),int.parse(p[2])); }
    DateTime? dt(v)=> (v==null||v=='')?null:DateTime.parse(v);
    return WorkSession(
      id: j[r'$id']??'', userId: j['user_id'], date: dOnly(j['date']),
      sequence: (j['sequence'] as num).toInt(), checkInAt: dt(j['check_in_at']),
      checkOutAt: dt(j['check_out_at']), status: j['status'],
    );
  }
}

class DayStatus {
  final String date;
  final int count;
  final bool open;
  final List<WorkSession> sessions;
  DayStatus({required this.date,required this.count,required this.open,required this.sessions});
  factory DayStatus.fromJson(Map<String,dynamic> j)=> DayStatus(
    date: j['date'], count: (j['count'] as num).toInt(), open: j['open'] as bool,
    sessions: (j['sessions'] as List).map((e)=>WorkSession.fromJson(e)).toList(),
  );
}
