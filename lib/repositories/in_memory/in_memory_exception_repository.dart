import '../../models/attendance_exception.dart';
import '../../core/app_error.dart';
import '../exception_repository.dart';

/// In-memory [ExceptionRepository].
///
/// Seeds the same 3 sample exceptions that previously lived in
/// [AttendanceExceptionsPage._loadMockExceptions()].
class InMemoryExceptionRepository implements ExceptionRepository {
  InMemoryExceptionRepository() {
    _seed();
  }

  final List<AttendanceException> _exceptions = [];
  int _nextId = 100;

  // -------------------------------------------------------------------------
  // Seed
  // -------------------------------------------------------------------------

  void _seed() {
    final now = DateTime.now();

    _exceptions.addAll([
      AttendanceException(
        id: '1',
        sessionId: 'session-001',
        studentId: 'student-001',
        studentName: 'John Doe',
        studentEmail: 'john.doe@university.edu',
        type: ExceptionType.lateArrival,
        status: ExceptionStatus.pending,
        reason:
            'Bus was delayed due to traffic jam on main road. '
            'Have bus ticket as proof.',
        supportingDocument: 'bus_ticket_001.jpg',
        requestedAt: now.subtract(const Duration(hours: 2)),
        originalStatus: 'absent',
        requestedStatus: 'late',
      ),
      AttendanceException(
        id: '2',
        sessionId: 'session-002',
        studentId: 'student-002',
        studentName: 'Jane Smith',
        studentEmail: 'jane.smith@university.edu',
        type: ExceptionType.medicalLeave,
        status: ExceptionStatus.underReview,
        reason: 'Had to visit doctor for emergency dental treatment.',
        supportingDocument: 'medical_certificate.pdf',
        requestedAt: now.subtract(const Duration(days: 1)),
        originalStatus: 'absent',
        requestedStatus: 'excused',
      ),
      AttendanceException(
        id: '3',
        sessionId: 'session-003',
        studentId: 'student-003',
        studentName: 'Mike Johnson',
        studentEmail: 'mike.johnson@university.edu',
        type: ExceptionType.technicalIssue,
        status: ExceptionStatus.pending,
        reason:
            'Mobile phone ran out of battery and could not scan QR code. '
            'Was physically present in class.',
        requestedAt: now.subtract(const Duration(hours: 5)),
        originalStatus: 'absent',
        requestedStatus: 'present',
      ),
    ]);
  }

  // -------------------------------------------------------------------------
  // ExceptionRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<List<AttendanceException>> getExceptionsForTeacher(
    String teacherId,
  ) async {
    // In-memory: return all (in Phase 3 filter by teacher's sessions)
    return List.of(_exceptions)
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  @override
  Future<List<AttendanceException>> getExceptionsForStudent(
    String studentId,
  ) async {
    return _exceptions
        .where((e) => e.studentId == studentId)
        .toList()
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  @override
  Future<int> getPendingCount(String teacherId) async {
    return _exceptions
        .where((e) => e.status == ExceptionStatus.pending)
        .length;
  }

  @override
  Future<AttendanceException> submitException(
    AttendanceException exception,
  ) async {
    // Conflict: existing pending/under-review exception for same session+student
    final conflict = _exceptions.any(
      (e) =>
          e.sessionId == exception.sessionId &&
          e.studentId == exception.studentId &&
          (e.status == ExceptionStatus.pending ||
              e.status == ExceptionStatus.underReview),
    );

    if (conflict) {
      throw const ConflictError(
        detail:
            'An open exception request already exists for this session.',
      );
    }

    final saved = exception.copyWith(id: '${_nextId++}');
    _exceptions.add(saved);
    return saved;
  }

  @override
  Future<AttendanceException> reviewException(
    String id,
    ExceptionStatus status, {
    String? comments,
    String? reviewerId,
  }) async {
    final index = _exceptions.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw const ServiceUnavailableError(detail: 'Exception not found.');
    }

    final updated = _exceptions[index].copyWith(
      status: status,
      reviewerComments: comments,
      reviewedBy: reviewerId,
      reviewedAt: DateTime.now(),
    );
    _exceptions[index] = updated;
    return updated;
  }

  // -------------------------------------------------------------------------
  // Test helpers
  // -------------------------------------------------------------------------

  void reset() {
    _exceptions.clear();
    _nextId = 100;
    _seed();
  }

  List<AttendanceException> get allExceptions =>
      List.unmodifiable(_exceptions);
}
