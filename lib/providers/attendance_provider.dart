import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/attendance_service.dart';

// Provider for the attendance service
final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService();
});

// Provider for active session (for teachers)
final activeSessionProvider =
    StateNotifierProvider<
      ActiveSessionNotifier,
      AsyncValue<Map<String, dynamic>?>
    >((ref) {
      final attendanceService = ref.watch(attendanceServiceProvider);
      return ActiveSessionNotifier(attendanceService);
    });

// Notifier for managing active session state
class ActiveSessionNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AttendanceService _attendanceService;

  ActiveSessionNotifier(this._attendanceService)
    : super(const AsyncValue.data(null));

  Future<void> createSession({
    required String subjectId,
    required String classId,
    required String teacherId,
    required GeoPoint location,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      state = const AsyncValue.loading();

      final result = await _attendanceService.createSession(
        subjectId: subjectId,
        classId: classId,
        teacherId: teacherId,
        location: location,
        startTime: startTime,
        endTime: endTime,
      );

      if (result['success']) {
        state = AsyncValue.data(result);
      } else {
        state = AsyncValue.error(result['error'], StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> endSession(String sessionId) async {
    try {
      state = const AsyncValue.loading();

      final success = await _attendanceService.endSession(sessionId);

      if (success) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error('Failed to end session', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider for student attendance marking
final markAttendanceProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final attendanceService = ref.watch(attendanceServiceProvider);

      return attendanceService.markAttendance(
        sessionId: params['sessionId'],
        sessionCode: params['sessionCode'],
        studentId: params['studentId'],
        currentLocation: params['currentLocation'],
      );
    });

// Provider for student attendance history
final studentAttendanceHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      studentId,
    ) async {
      final attendanceService = ref.watch(attendanceServiceProvider);
      return attendanceService.getStudentAttendanceHistory(studentId);
    });

// Provider for session attendance
final sessionAttendanceProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      sessionId,
    ) async {
      final attendanceService = ref.watch(attendanceServiceProvider);
      return attendanceService.getSessionAttendance(sessionId);
    });
