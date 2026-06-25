enum ExceptionType {
  lateArrival,
  earlyDeparture,
  medicalLeave,
  personalLeave,
  technicalIssue,
  wronglyMarkedAbsent,
  wronglyMarkedPresent,
  other,
}

enum ExceptionStatus { pending, approved, rejected, underReview }

class AttendanceException {
  final String id;
  final String institutionId;
  final String sessionId;
  final String studentId;
  final String? teacherId;
  final String? attendanceRecordId;
  final String studentName;
  final String studentEmail;
  final ExceptionType type;
  final ExceptionStatus status;
  final String reason;
  final String? supportingDocument; // URL or file path
  final List<String> attachmentPaths;
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy; // Teacher ID
  final String? reviewerComments;
  final String? originalStatus; // What the attendance was originally marked as
  final String? requestedStatus; // What the student wants it changed to
  final Map<String, dynamic> metadata;

  AttendanceException({
    required this.id,
    this.institutionId = '',
    required this.sessionId,
    required this.studentId,
    this.teacherId,
    this.attendanceRecordId,
    required this.studentName,
    required this.studentEmail,
    required this.type,
    required this.status,
    required this.reason,
    this.supportingDocument,
    this.attachmentPaths = const [],
    required this.requestedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewerComments,
    this.originalStatus,
    this.requestedStatus,
    this.metadata = const {},
  });

  factory AttendanceException.fromMap(Map<String, dynamic> map) {
    return AttendanceException(
      id: map['id'] ?? '',
      institutionId: map['institutionId'] ?? map['institution_id'] ?? '',
      sessionId: map['session_id'] ?? map['sessionId'] ?? '',
      studentId: map['student_id'] ?? map['studentId'] ?? '',
      teacherId: map['teacher_id'] ?? map['teacherId'],
      attendanceRecordId:
          map['attendance_record_id'] ?? map['attendanceRecordId'],
      studentName: map['student_name'] ?? '',
      studentEmail: map['student_email'] ?? '',
      type: ExceptionType.values.firstWhere(
        (e) => e.toString() == 'ExceptionType.${map['type']}',
        orElse: () => ExceptionType.other,
      ),
      status: ExceptionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExceptionStatus.pending,
      ),
      reason: map['reason'] ?? '',
      supportingDocument: map['supporting_document'],
      attachmentPaths: List<String>.from(map['attachment_paths'] ?? []),
      requestedAt: DateTime.parse(
        map['requested_at'] ?? DateTime.now().toIso8601String(),
      ),
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.parse(map['reviewed_at'])
          : null,
      reviewedBy: map['reviewed_by'],
      reviewerComments: map['reviewer_comments'],
      originalStatus: map['original_status'],
      requestedStatus: map['requested_status'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institutionId': institutionId,
      'session_id': sessionId,
      'student_id': studentId,
      'teacher_id': teacherId,
      'attendance_record_id': attendanceRecordId,
      'student_name': studentName,
      'student_email': studentEmail,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'reason': reason,
      'supporting_document': supportingDocument,
      'attachment_paths': attachmentPaths,
      'requested_at': requestedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
      'reviewer_comments': reviewerComments,
      'original_status': originalStatus,
      'requested_status': requestedStatus,
      'metadata': metadata,
    };
  }

  AttendanceException copyWith({
    String? id,
    String? institutionId,
    String? sessionId,
    String? studentId,
    String? teacherId,
    String? attendanceRecordId,
    String? studentName,
    String? studentEmail,
    ExceptionType? type,
    ExceptionStatus? status,
    String? reason,
    String? supportingDocument,
    List<String>? attachmentPaths,
    DateTime? requestedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewerComments,
    String? originalStatus,
    String? requestedStatus,
    Map<String, dynamic>? metadata,
  }) {
    return AttendanceException(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      attendanceRecordId: attendanceRecordId ?? this.attendanceRecordId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      type: type ?? this.type,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      supportingDocument: supportingDocument ?? this.supportingDocument,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      requestedAt: requestedAt ?? this.requestedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewerComments: reviewerComments ?? this.reviewerComments,
      originalStatus: originalStatus ?? this.originalStatus,
      requestedStatus: requestedStatus ?? this.requestedStatus,
      metadata: metadata ?? this.metadata,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case ExceptionType.lateArrival:
        return 'Late Arrival';
      case ExceptionType.earlyDeparture:
        return 'Early Departure';
      case ExceptionType.medicalLeave:
        return 'Medical Leave';
      case ExceptionType.personalLeave:
        return 'Personal Leave';
      case ExceptionType.technicalIssue:
        return 'Technical Issue';
      case ExceptionType.wronglyMarkedAbsent:
        return 'Wrongly Marked Absent';
      case ExceptionType.wronglyMarkedPresent:
        return 'Wrongly Marked Present';
      case ExceptionType.other:
        return 'Other';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ExceptionStatus.pending:
        return 'Pending Review';
      case ExceptionStatus.approved:
        return 'Approved';
      case ExceptionStatus.rejected:
        return 'Rejected';
      case ExceptionStatus.underReview:
        return 'Under Review';
    }
  }

  bool get isPending => status == ExceptionStatus.pending;
  bool get isApproved => status == ExceptionStatus.approved;
  bool get isRejected => status == ExceptionStatus.rejected;
  bool get isUnderReview => status == ExceptionStatus.underReview;

  bool get hasDocument =>
      supportingDocument != null && supportingDocument!.isNotEmpty;

  int get daysSinceRequest {
    return DateTime.now().difference(requestedAt).inDays;
  }

  bool get isUrgent => daysSinceRequest > 3 && isPending;
}
