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
  final String sessionId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final ExceptionType type;
  final ExceptionStatus status;
  final String reason;
  final String? supportingDocument; // URL or file path
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy; // Teacher ID
  final String? reviewerComments;
  final String? originalStatus; // What the attendance was originally marked as
  final String? requestedStatus; // What the student wants it changed to
  final Map<String, dynamic> metadata;

  AttendanceException({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.type,
    required this.status,
    required this.reason,
    this.supportingDocument,
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
      sessionId: map['session_id'] ?? '',
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'] ?? '',
      studentEmail: map['student_email'] ?? '',
      type: ExceptionType.values.firstWhere(
        (e) => e.toString() == 'ExceptionType.${map['type']}',
        orElse: () => ExceptionType.other,
      ),
      status: ExceptionStatus.values.firstWhere(
        (e) => e.toString() == 'ExceptionStatus.${map['status']}',
        orElse: () => ExceptionStatus.pending,
      ),
      reason: map['reason'] ?? '',
      supportingDocument: map['supporting_document'],
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
      'session_id': sessionId,
      'student_id': studentId,
      'student_name': studentName,
      'student_email': studentEmail,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'reason': reason,
      'supporting_document': supportingDocument,
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
    String? sessionId,
    String? studentId,
    String? studentName,
    String? studentEmail,
    ExceptionType? type,
    ExceptionStatus? status,
    String? reason,
    String? supportingDocument,
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
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      type: type ?? this.type,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      supportingDocument: supportingDocument ?? this.supportingDocument,
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
