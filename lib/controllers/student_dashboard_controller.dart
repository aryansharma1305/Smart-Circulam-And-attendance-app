import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_summary.dart';
import '../models/user.dart';
import '../core/app_error.dart';
import '../repositories/academics_repository.dart';
import '../repositories/attendance_repository.dart';
import '../providers/repository_providers.dart';
import '../controllers/auth_controller.dart';

// ---------------------------------------------------------------------------
// Student Dashboard Controller
// ---------------------------------------------------------------------------

/// Aggregates all data needed by [StudentDashboardPage] into a single
/// [StudentDashboardSummary] value object.
///
/// The screen watches [studentDashboardControllerProvider] and maps
/// [AsyncValue] states to loading, error, and content widgets.
class StudentDashboardController
    extends StateNotifier<AsyncValue<StudentDashboardSummary>> {
  StudentDashboardController({
    required this.academicsRepo,
    required this.attendanceRepo,
    required this.userId,
  }) : super(const AsyncValue.loading()) {
    load();
  }

  final AcademicsRepository academicsRepo;
  final AttendanceRepository attendanceRepo;
  final String userId;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      // Parallel fetch
      final results = await Future.wait([
        academicsRepo.getTodaySchedule(userId, UserRole.student),
        attendanceRepo.getAttendancePercentage(userId, ''),
        attendanceRepo.getStreakDays(userId),
      ]);

      final timetableEntries = results[0] as List;
      final attendancePct = results[1] as double;
      final streak = results[2] as int;

      // Map TimetableEntry → ScheduleSlot (display-ready)
      final now = DateTime.now();
      final slots = timetableEntries.map((entry) {
        final isNow = entry.isNow();
        return ScheduleSlot(
          subject: _courseLabel(entry.courseId),
          room: _roomLabel(entry.roomId),
          startTime: entry.startTime,
          endTime: entry.endTime,
          isNow: isNow,
        );
      }).toList();

      // Hardcoded goal progress (Goal domain integration in Phase 3)
      const goalsProgress = {
        'Complete Math Assignment': 0.8,
        'Read Physics Chapter 5': 0.6,
        'Practice Chemistry Problems': 0.3,
      };
      const completedGoals = 1;
      const totalGoals = 3;

      state = AsyncValue.data(
        StudentDashboardSummary(
          attendancePercent: attendancePct,
          streakDays: streak,
          completedGoals: completedGoals,
          totalGoals: totalGoals,
          todaySlots: slots,
          goalsProgress: goalsProgress,
        ),
      );
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(
        ServiceUnavailableError(detail: e.toString()),
        st,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Local label helpers (Phase 3 will look these up from Course/Room repos)
  // -------------------------------------------------------------------------

  static String _courseLabel(String courseId) {
    const map = {
      'course-math': 'Mathematics',
      'course-physics': 'Physics',
      'course-chemistry': 'Chemistry',
      'course-dsa': 'DSA',
      'course-dbms': 'DBMS',
      'course-os': 'OS',
    };
    return map[courseId] ?? courseId;
  }

  static String _roomLabel(String roomId) {
    const map = {
      'room-101': 'Room 101',
      'room-102': 'Room 102',
      'room-103': 'Room 103',
      'room-B201': 'Room B201',
      'room-B205': 'Room B205',
      'room-B210': 'Room B210',
    };
    return map[roomId] ?? roomId;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final studentDashboardControllerProvider = StateNotifierProvider.autoDispose<
    StudentDashboardController, AsyncValue<StudentDashboardSummary>>((ref) {
  final user = ref.watch(currentUserProvider);
  final academicsRepo = ref.watch(academicsRepositoryProvider);
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);

  return StudentDashboardController(
    academicsRepo: academicsRepo,
    attendanceRepo: attendanceRepo,
    userId: user?.uid ?? '',
  );
});
