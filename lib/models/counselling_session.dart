enum SessionType { individual, group, family, crisis, followUp }

enum SessionStatus { scheduled, inProgress, completed, cancelled, noShow }

class CounsellingSession {
  final String id;
  final String studentId;
  final String studentName;
  final String counsellorId;
  final String counsellorName;
  final SessionType type;
  final SessionStatus status;
  final DateTime scheduledDate;
  final Duration duration;
  final String? reason;
  final String? notes;
  final List<String> concerns;
  final List<String> actionItems;
  final bool isUrgent;
  final String? parentContact;
  final DateTime createdAt;
  final DateTime? completedAt;

  CounsellingSession({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.counsellorId,
    required this.counsellorName,
    required this.type,
    this.status = SessionStatus.scheduled,
    required this.scheduledDate,
    this.duration = const Duration(minutes: 45),
    this.reason,
    this.notes,
    this.concerns = const [],
    this.actionItems = const [],
    this.isUrgent = false,
    this.parentContact,
    required this.createdAt,
    this.completedAt,
  });

  CounsellingSession copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? counsellorId,
    String? counsellorName,
    SessionType? type,
    SessionStatus? status,
    DateTime? scheduledDate,
    Duration? duration,
    String? reason,
    String? notes,
    List<String>? concerns,
    List<String>? actionItems,
    bool? isUrgent,
    String? parentContact,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return CounsellingSession(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      counsellorId: counsellorId ?? this.counsellorId,
      counsellorName: counsellorName ?? this.counsellorName,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      duration: duration ?? this.duration,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      concerns: concerns ?? this.concerns,
      actionItems: actionItems ?? this.actionItems,
      isUrgent: isUrgent ?? this.isUrgent,
      parentContact: parentContact ?? this.parentContact,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'counsellorId': counsellorId,
      'counsellorName': counsellorName,
      'type': type.name,
      'status': status.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'duration': duration.inMinutes,
      'reason': reason,
      'notes': notes,
      'concerns': concerns,
      'actionItems': actionItems,
      'isUrgent': isUrgent,
      'parentContact': parentContact,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory CounsellingSession.fromJson(Map<String, dynamic> json) {
    return CounsellingSession(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      counsellorId: json['counsellorId'],
      counsellorName: json['counsellorName'],
      type: SessionType.values.firstWhere((e) => e.name == json['type']),
      status: SessionStatus.values.firstWhere((e) => e.name == json['status']),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      duration: Duration(minutes: json['duration'] ?? 45),
      reason: json['reason'],
      notes: json['notes'],
      concerns: List<String>.from(json['concerns'] ?? []),
      actionItems: List<String>.from(json['actionItems'] ?? []),
      isUrgent: json['isUrgent'] ?? false,
      parentContact: json['parentContact'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}
