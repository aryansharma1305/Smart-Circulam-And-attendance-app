enum AttendanceStatus { present, late, absent, leave }

class Attendance {
  final String sessionId;
  final String studentId;
  final AttendanceStatus status;
  final bool isLate;
  final String? deviceHash;
  final bool geoOK;
  final bool ssidOK;
  final String? totpNonce;
  final DateTime createdAt;
  final String? notes; // For manual adjustments by teachers

  Attendance({
    required this.sessionId,
    required this.studentId,
    required this.status,
    this.isLate = false,
    this.deviceHash,
    this.geoOK = false,
    this.ssidOK = false,
    this.totpNonce,
    required this.createdAt,
    this.notes,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      sessionId: json['sessionId'] ?? '',
      studentId: json['studentId'] ?? '',
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      isLate: json['isLate'] ?? false,
      deviceHash: json['deviceHash'],
      geoOK: json['geoOK'] ?? false,
      ssidOK: json['ssidOK'] ?? false,
      totpNonce: json['totpNonce'],
      createdAt: DateTime.parse(json['createdAt']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status.toString().split('.').last,
      'isLate': isLate,
      'deviceHash': deviceHash,
      'geoOK': geoOK,
      'ssidOK': ssidOK,
      'totpNonce': totpNonce,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  Attendance copyWith({
    AttendanceStatus? status,
    bool? isLate,
    String? deviceHash,
    bool? geoOK,
    bool? ssidOK,
    String? totpNonce,
    String? notes,
  }) {
    return Attendance(
      sessionId: sessionId,
      studentId: studentId,
      status: status ?? this.status,
      isLate: isLate ?? this.isLate,
      deviceHash: deviceHash ?? this.deviceHash,
      geoOK: geoOK ?? this.geoOK,
      ssidOK: ssidOK ?? this.ssidOK,
      totpNonce: totpNonce ?? this.totpNonce,
      createdAt: createdAt,
      notes: notes ?? this.notes,
    );
  }

  bool get isValid => geoOK || ssidOK; // At least one proximity check must pass
}
