enum AttendanceStatus { present, absent, late }
enum AttendanceMethod { qr, ble, wifi, face, manual }

class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final AttendanceStatus status;
  final AttendanceMethod method;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String? reason;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    required this.method,
    required this.timestamp,
    required this.metadata,
    this.reason,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] ?? '',
      sessionId: map['session_id'] ?? '',
      studentId: map['student_id'] ?? '',
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == 'AttendanceStatus.${map['status']}',
        orElse: () => AttendanceStatus.absent,
      ),
      method: AttendanceMethod.values.firstWhere(
        (e) => e.toString() == 'AttendanceMethod.${map['method']}',
        orElse: () => AttendanceMethod.manual,
      ),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      reason: map['reason'],
      approvedBy: map['approved_by'],
      approvedAt: map['approved_at'] != null 
          ? DateTime.parse(map['approved_at']) 
          : null,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'reason': reason,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    AttendanceStatus? status,
    AttendanceMethod? method,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? reason,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      method: method ?? this.method,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      reason: reason ?? this.reason,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPresent {
    return status == AttendanceStatus.present;
  }

  bool get isAbsent {
    return status == AttendanceStatus.absent;
  }

  bool get isLate {
    return status == AttendanceStatus.late;
  }

  bool get isApproved {
    return approvedBy != null && approvedAt != null;
  }

  String get methodDisplayName {
    switch (method) {
      case AttendanceMethod.qr:
        return 'QR Code';
      case AttendanceMethod.ble:
        return 'Bluetooth';
      case AttendanceMethod.wifi:
        return 'Wi-Fi';
      case AttendanceMethod.face:
        return 'Face Recognition';
      case AttendanceMethod.manual:
        return 'Manual';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
    }
  }
}
