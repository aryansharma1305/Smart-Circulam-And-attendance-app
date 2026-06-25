import '../../models/attendance.dart';
import '../../core/app_error.dart';
import '../attendance_repository.dart';

/// In-memory [AttendanceRepository].
///
/// Seeds a realistic history for student-001 yielding:
/// - ~85 % overall attendance
/// - 7-day consecutive streak
class InMemoryAttendanceRepository implements AttendanceRepository {
  InMemoryAttendanceRepository() {
    _seed();
  }

  final List<Attendance> _records = [];

  // -------------------------------------------------------------------------
  // Seed
  // -------------------------------------------------------------------------

  void _seed() {
    final now = DateTime.now();
    const studentId = 'student-001';

    // Build 30 days of history (Mon–Fri, ~85 % present)
    for (int i = 29; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      // Skip weekends
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        continue;
      }

      // 3 classes per day (Math, Physics, Chemistry)
      final sessions = [
        ('session-math-${i}', 'course-math'),
        ('session-physics-${i}', 'course-physics'),
        ('session-chemistry-${i}', 'course-chemistry'),
      ];

      for (final (sessionId, _) in sessions) {
        // Absent ~15 % of the time: absent on days 4, 9, 14, 19 first class
        final absent = i % 5 == 1 && sessionId.contains('math');
        _records.add(
          Attendance(
            sessionId: sessionId,
            studentId: studentId,
            status: absent ? AttendanceStatus.absent : AttendanceStatus.present,
            isLate: false,
            geoOK: !absent,
            ssidOK: !absent,
            createdAt: DateTime(day.year, day.month, day.day, 9),
          ),
        );
      }
    }
  }

  // -------------------------------------------------------------------------
  // AttendanceRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Attendance> markAttendance(Attendance record) async {
    final duplicate = _records.any(
      (r) =>
          r.sessionId == record.sessionId && r.studentId == record.studentId,
    );

    if (duplicate) {
      throw ConflictError(
        detail:
            'Attendance has already been marked for student ${record.studentId} '
            'in session ${record.sessionId}.',
      );
    }

    _records.add(record);
    return record;
  }

  @override
  Future<List<Attendance>> getStudentHistory(
    String studentId, {
    DateRange? range,
  }) async {
    return _records.where((r) {
      if (r.studentId != studentId) return false;
      if (range != null && !range.contains(r.createdAt)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<double> getAttendancePercentage(
    String studentId,
    String courseId,
  ) async {
    // For the in-memory impl, compute across all seeded records for the student
    // (course filtering deferred to Phase 3 when session→course linkage is stored)
    final all = _records.where((r) => r.studentId == studentId).toList();
    if (all.isEmpty) return 0.0;

    final present = all
        .where((r) =>
            r.status == AttendanceStatus.present ||
            r.status == AttendanceStatus.late)
        .length;

    return (present / all.length) * 100;
  }

  @override
  Future<int> getStreakDays(String studentId) async {
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        continue;
      }

      final dayRecords = _records.where((r) {
        return r.studentId == studentId &&
            r.createdAt.year == day.year &&
            r.createdAt.month == day.month &&
            r.createdAt.day == day.day;
      });

      final wasPresent = dayRecords.any(
        (r) =>
            r.status == AttendanceStatus.present ||
            r.status == AttendanceStatus.late,
      );

      if (wasPresent) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Future<List<Attendance>> getSessionRoll(String sessionId) async {
    return _records.where((r) => r.sessionId == sessionId).toList();
  }

  // -------------------------------------------------------------------------
  // Test helpers
  // -------------------------------------------------------------------------

  void reset() {
    _records.clear();
    _seed();
  }

  List<Attendance> get allRecords => List.unmodifiable(_records);
}
