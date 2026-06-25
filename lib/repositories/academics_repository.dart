import '../models/user.dart';
import '../models/timetable.dart';
import '../models/session.dart';
import '../models/course.dart';
import '../core/app_error.dart';

/// Contract for timetable, course, and session (class) data.
///
/// Implementations throw [AppError] subtypes on failure.
abstract class AcademicsRepository {
  // -------------------------------------------------------------------------
  // Timetable
  // -------------------------------------------------------------------------

  /// Returns the [TimetableEntry]s scheduled for today for [userId].
  ///
  /// For students, returns entries the student is enrolled in.
  /// For teachers, returns entries the teacher is responsible for.
  Future<List<TimetableEntry>> getTodaySchedule(String userId, UserRole role);

  /// Returns the full week's [TimetableEntry]s for [userId].
  Future<List<TimetableEntry>> getWeekSchedule(String userId, UserRole role);

  // -------------------------------------------------------------------------
  // Courses
  // -------------------------------------------------------------------------

  /// Returns all [Course]s relevant to [userId] for their [role].
  Future<List<Course>> getCoursesForUser(String userId, UserRole role);

  // -------------------------------------------------------------------------
  // Sessions
  // -------------------------------------------------------------------------

  /// Returns [Session]s managed by [teacherId], optionally filtered to [date].
  Future<List<Session>> getSessionsForTeacher(
    String teacherId, {
    DateTime? date,
  });

  /// Persists a new [Session] and returns the saved copy (with server-assigned
  /// ID if applicable).
  ///
  /// Throws [ConflictError] if a live session already exists for the same
  /// timetable entry on the same day.
  Future<Session> createSession(Session session);

  /// Transitions [sessionId] to [newState].
  ///
  /// Throws [ConflictError] if the transition is invalid (e.g. re-opening a
  /// closed session).
  Future<Session> updateSessionState(String sessionId, SessionState newState);
}
