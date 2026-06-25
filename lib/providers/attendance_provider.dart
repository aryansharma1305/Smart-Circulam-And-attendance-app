import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance.dart';
import '../core/app_error.dart';
import '../repositories/attendance_repository.dart';
import '../providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Attendance Providers
// ---------------------------------------------------------------------------
//
// These providers replace the previous Firebase-dependent implementations.
// All data now flows through [AttendanceRepository], which defaults to
// [InMemoryAttendanceRepository] and can be overridden with a Firebase
// implementation via ProviderScope.
//
// The provider names are unchanged so existing consumers compile without
// modification.

// ---------------------------------------------------------------------------
// Active Session State (teacher-facing)
// ---------------------------------------------------------------------------

/// State for the currently active (live) session being managed by a teacher.
///
/// null means no session is currently active.
class ActiveSessionNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  ActiveSessionNotifier(this._attendanceRepo)
      : super(const AsyncValue.data(null));

  final AttendanceRepository _attendanceRepo;

  /// Marks a student's attendance for the current session.
  ///
  /// [sessionId]  – the live session identifier.
  /// [studentId]  – the student marking in.
  /// [status]     – the attendance status to record.
  Future<void> markStudentAttendance({
    required String sessionId,
    required String studentId,
    required AttendanceStatus status,
  }) async {
    try {
      state = const AsyncValue.loading();

      final record = Attendance(
        sessionId: sessionId,
        studentId: studentId,
        status: status,
        geoOK: true,
        ssidOK: false,
        createdAt: DateTime.now(),
      );

      await _attendanceRepo.markAttendance(record);
      state = AsyncValue.data({'sessionId': sessionId, 'status': 'active'});
    } on ConflictError catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(
        NetworkError(detail: e.toString()),
        st,
      );
    }
  }

  void clearSession() => state = const AsyncValue.data(null);
}

/// Provider for the currently active session state.
final activeSessionProvider = StateNotifierProvider<ActiveSessionNotifier,
    AsyncValue<Map<String, dynamic>?>>(
  (ref) => ActiveSessionNotifier(ref.watch(attendanceRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Student Attendance History
// ---------------------------------------------------------------------------

/// Returns the full attendance history for [studentId].
final studentAttendanceHistoryProvider =
    FutureProvider.family<List<Attendance>, String>((ref, studentId) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getStudentHistory(studentId);
});

// ---------------------------------------------------------------------------
// Session Roll (teacher view of who attended a specific session)
// ---------------------------------------------------------------------------

/// Returns the list of attendance records for [sessionId].
final sessionAttendanceProvider =
    FutureProvider.family<List<Attendance>, String>((ref, sessionId) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getSessionRoll(sessionId);
});

// ---------------------------------------------------------------------------
// Convenience: mark attendance (student action)
// ---------------------------------------------------------------------------

/// Marks attendance for the given session/student combo.
///
/// Throws [ConflictError] if attendance has already been marked.
final markAttendanceProvider = FutureProvider.family<Attendance,
    ({String sessionId, String studentId, AttendanceStatus status})>(
  (ref, params) async {
    final repo = ref.watch(attendanceRepositoryProvider);
    return repo.markAttendance(
      Attendance(
        sessionId: params.sessionId,
        studentId: params.studentId,
        status: params.status,
        geoOK: true,
        ssidOK: false,
        createdAt: DateTime.now(),
      ),
    );
  },
);
