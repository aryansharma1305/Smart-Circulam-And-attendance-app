import '../models/attendance_exception.dart';
import '../core/app_error.dart';

/// Contract for attendance-exception lifecycle operations.
///
/// Implementations throw [AppError] subtypes on failure.
abstract class ExceptionRepository {
  // -------------------------------------------------------------------------
  // Reads
  // -------------------------------------------------------------------------

  /// Returns all exceptions assigned for review to [teacherId], ordered by
  /// most-recent first.
  Future<List<AttendanceException>> getExceptionsForTeacher(String teacherId);

  /// Returns all exceptions submitted by [studentId], ordered by most-recent
  /// first.
  Future<List<AttendanceException>> getExceptionsForStudent(String studentId);

  /// Returns the number of exceptions with [ExceptionStatus.pending] status
  /// for [teacherId].
  Future<int> getPendingCount(String teacherId);

  // -------------------------------------------------------------------------
  // Writes
  // -------------------------------------------------------------------------

  /// Persists a new exception request and returns the saved copy (with an
  /// assigned [id]).
  ///
  /// Throws [ConflictError] if a pending or under-review exception already
  /// exists for the same (sessionId, studentId) pair.
  Future<AttendanceException> submitException(AttendanceException exception);

  /// Updates the [status] and optional [comments] of the exception identified
  /// by [id].
  ///
  /// Throws [AuthorizationError] if the caller is not allowed to review the
  /// exception (e.g. a student calling this method).
  Future<AttendanceException> reviewException(
    String id,
    ExceptionStatus status, {
    String? comments,
    String? reviewerId,
  });
}
