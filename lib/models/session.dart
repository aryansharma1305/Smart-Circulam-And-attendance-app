enum SessionState { planned, live, closed }

class Session {
  final String id;
  final String timetableId;
  final DateTime date;
  final SessionState state;
  final String qrSeed;
  final DateTime qrExpiry;
  final Map<String, dynamic> proximityPolicy;
  final Map<String, dynamic> stats;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Session({
    required this.id,
    required this.timetableId,
    required this.date,
    required this.state,
    required this.qrSeed,
    required this.qrExpiry,
    required this.proximityPolicy,
    required this.stats,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] ?? '',
      timetableId: map['timetable_id'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      state: SessionState.values.firstWhere(
        (e) => e.toString() == 'SessionState.${map['state']}',
        orElse: () => SessionState.planned,
      ),
      qrSeed: map['qr_seed'] ?? '',
      qrExpiry: DateTime.parse(map['qr_expiry'] ?? DateTime.now().add(Duration(minutes: 30)).toIso8601String()),
      proximityPolicy: Map<String, dynamic>.from(map['proximity_policy'] ?? {}),
      stats: Map<String, dynamic>.from(map['stats'] ?? {}),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timetable_id': timetableId,
      'date': date.toIso8601String(),
      'state': state.toString().split('.').last,
      'qr_seed': qrSeed,
      'qr_expiry': qrExpiry.toIso8601String(),
      'proximity_policy': proximityPolicy,
      'stats': stats,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Session copyWith({
    String? id,
    String? timetableId,
    DateTime? date,
    SessionState? state,
    String? qrSeed,
    DateTime? qrExpiry,
    Map<String, dynamic>? proximityPolicy,
    Map<String, dynamic>? stats,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      timetableId: timetableId ?? this.timetableId,
      date: date ?? this.date,
      state: state ?? this.state,
      qrSeed: qrSeed ?? this.qrSeed,
      qrExpiry: qrExpiry ?? this.qrExpiry,
      proximityPolicy: proximityPolicy ?? this.proximityPolicy,
      stats: stats ?? this.stats,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isQrValid {
    return DateTime.now().isBefore(qrExpiry);
  }

  bool get isLive {
    return state == SessionState.live;
  }

  bool get isClosed {
    return state == SessionState.closed;
  }

  int get totalStudents {
    return stats['total_students'] ?? 0;
  }

  int get presentStudents {
    return stats['present_students'] ?? 0;
  }

  int get absentStudents {
    return stats['absent_students'] ?? 0;
  }

  int get lateStudents {
    return stats['late_students'] ?? 0;
  }

  double get attendancePercentage {
    if (totalStudents == 0) return 0.0;
    return (presentStudents / totalStudents) * 100;
  }
}