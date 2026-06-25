import '../models/attendance.dart';
import '../core/app_error.dart';

/// Simple date-range value object used to filter attendance history.
class DateRange {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime dt) =>
      !dt.isBefore(start) && !dt.isAfter(end);
}

/// Contract for attendance record reads and writes.
///
/// Implementations throw [AppError] subtypes on failure:
/// - [ConflictError]  if a student tries to mark attendance twice in a session.
/// - [NetworkError]   for connectivity failures.
abstract class AttendanceRepository {
  // -------------------------------------------------------------------------
  // Write
  // -------------------------------------------------------------------------

  /// Persists an attendance [record] and returns the saved copy.
  ///
  /// Throws [ConflictError] if an [Attendance] record already exists for the
  /// same (sessionId, studentId) pair.
  Future<Attendance> markAttendance(Attendance record);

  // -------------------------------------------------------------------------
  // Read – student perspective
  // -------------------------------------------------------------------------

  /// Returns a student's full attendance history, optionally bounded by
  /// [range].
  Future<List<Attendance>> getStudentHistory(
    String studentId, {
    DateRange? range,
  });

  /// Computes the overall attendance percentage for [studentId] in [courseId].
  ///
  /// Returns a value in [0.0, 100.0].
  Future<double> getAttendancePercentage(String studentId, String courseId);

  /// Returns the number of consecutive calendar days [studentId] was present
  /// up to and including today.
  Future<int> getStreakDays(String studentId);

  // -------------------------------------------------------------------------
  // Read – teacher perspective
  // -------------------------------------------------------------------------

  /// Returns all [Attendance] records for a given [sessionId].
  Future<List<Attendance>> getSessionRoll(String sessionId);
}
