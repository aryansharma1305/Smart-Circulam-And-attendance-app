import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_summary.dart';
import '../models/user.dart';
import '../core/app_error.dart';
import '../repositories/academics_repository.dart';
import '../repositories/exception_repository.dart';
import '../providers/repository_providers.dart';
import '../controllers/auth_controller.dart';

// ---------------------------------------------------------------------------
// Teacher Dashboard Controller
// ---------------------------------------------------------------------------

/// Aggregates today's classes, pending exception count, and recent sessions
/// into a [TeacherDashboardSummary] for [TeacherHomePage].
class TeacherDashboardController
    extends StateNotifier<AsyncValue<TeacherDashboardSummary>> {
  TeacherDashboardController({
    required this.academicsRepo,
    required this.exceptionRepo,
    required this.teacherId,
  }) : super(const AsyncValue.loading()) {
    load();
  }

  final AcademicsRepository academicsRepo;
  final ExceptionRepository exceptionRepo;
  final String teacherId;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();

      final results = await Future.wait([
        academicsRepo.getTodaySchedule(teacherId, UserRole.teacher),
        exceptionRepo.getPendingCount(teacherId),
        academicsRepo.getSessionsForTeacher(teacherId),
      ]);

      final todayEntries = results[0] as List;
      final pendingCount = results[1] as int;
      final allSessions = results[2] as List;

      // Map TimetableEntry → TeacherClassSlot
      final classSlots = todayEntries.map((entry) {
        // Determine live/closed/planned based on sessions
        final todaySessions = allSessions.where(
          (s) =>
              s.timetableId == entry.id &&
              s.date.year == now.year &&
              s.date.month == now.month &&
              s.date.day == now.day,
        );

        String status = 'planned';
        if (todaySessions.isNotEmpty) {
          final session = todaySessions.first;
          status = session.state.name; // 'live', 'closed', 'planned'
        }

        return TeacherClassSlot(
          timetableId: entry.id,
          course: _courseLabel(entry.courseId),
          section: entry.section,
          room: _roomLabel(entry.roomId),
          start: entry.startTime,
          end: entry.endTime,
          enrolled: _enrolledCount(entry.courseId),
          status: status,
        );
      }).toList();

      // Build recent sessions summary (closed, last 7 days)
      final recent = allSessions
          .where((s) => s.state.name == 'closed')
          .take(3)
          .map((s) => RecentSessionSummary(
                course: _courseLabel(_timetableIdToCourseId(s.timetableId)),
                section: _timetableIdToSection(s.timetableId),
                dateLabel: _dateLabel(s.date, now),
                presentCount: s.presentStudents,
                totalCount: s.totalStudents,
              ))
          .toList();

      state = AsyncValue.data(
        TeacherDashboardSummary(
          todayClasses: classSlots,
          pendingExceptionsCount: pendingCount,
          recentSessions: recent,
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
  // Label helpers (Phase 3: look up from AcademicsRepository.getCourse)
  // -------------------------------------------------------------------------

  static String _courseLabel(String courseId) {
    const map = {
      'course-dsa': 'DSA',
      'course-dbms': 'DBMS',
      'course-os': 'OS',
      'course-math': 'Mathematics',
      'course-physics': 'Physics',
      'course-chemistry': 'Chemistry',
    };
    return map[courseId] ?? courseId;
  }

  static String _roomLabel(String roomId) {
    const map = {
      'room-B201': 'Room B201',
      'room-B205': 'Room B205',
      'room-B210': 'Room B210',
      'room-101': 'Room 101',
    };
    return map[roomId] ?? roomId;
  }

  static int _enrolledCount(String courseId) {
    const map = {
      'course-dsa': 52,
      'course-dbms': 48,
      'course-os': 45,
    };
    return map[courseId] ?? 40;
  }

  static String _timetableIdToCourseId(String timetableId) {
    const map = {
      'tt-dsa': 'course-dsa',
      'tt-dbms': 'course-dbms',
      'tt-os': 'course-os',
    };
    return map[timetableId] ?? timetableId;
  }

  static String _timetableIdToSection(String timetableId) {
    const map = {
      'tt-dsa': 'Sec A',
      'tt-dbms': 'Sec B',
      'tt-os': 'Sec C',
    };
    return map[timetableId] ?? '';
  }

  static String _dateLabel(DateTime date, DateTime now) {
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff <= 6) return '$diff days ago';
    return DateFormat('d MMM').format(date);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final teacherDashboardControllerProvider = StateNotifierProvider.autoDispose<
    TeacherDashboardController, AsyncValue<TeacherDashboardSummary>>((ref) {
  final user = ref.watch(currentUserProvider);
  final academicsRepo = ref.watch(academicsRepositoryProvider);
  final exceptionRepo = ref.watch(exceptionRepositoryProvider);

  return TeacherDashboardController(
    academicsRepo: academicsRepo,
    exceptionRepo: exceptionRepo,
    teacherId: user?.uid ?? '',
  );
});
