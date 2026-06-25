// Dashboard summary value objects for student and teacher views.

/// A scheduled class slot for a student's "today" view.
///
/// Lighter than a full [TimetableEntry] – carries display-ready strings so
/// the dashboard widget never needs to look up course/room names.
class ScheduleSlot {
  const ScheduleSlot({
    required this.subject,
    required this.room,
    required this.startTime,
    required this.endTime,
    this.isNow = false,
    this.attendanceMarked = false,
  });

  final String subject;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final bool isNow;
  final bool attendanceMarked;

  String get timeRange {
    String fmt(DateTime dt) {
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour < 12 ? 'AM' : 'PM';
      return '$h:$m $period';
    }

    return '${fmt(startTime)} – ${fmt(endTime)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleSlot &&
          subject == other.subject &&
          startTime == other.startTime;

  @override
  int get hashCode => Object.hash(subject, startTime);
}

/// Aggregated data displayed on the student dashboard.
///
/// Produced by [StudentDashboardController]; the screen never computes
/// these values itself.
class StudentDashboardSummary {
  const StudentDashboardSummary({
    required this.attendancePercent,
    required this.streakDays,
    required this.completedGoals,
    required this.totalGoals,
    required this.todaySlots,
    required this.goalsProgress,
  });

  /// Overall attendance percentage across all enrolled courses (0–100).
  final double attendancePercent;

  /// Number of consecutive days the student has been present.
  final int streakDays;

  final int completedGoals;
  final int totalGoals;

  /// Ordered list of today's classes.
  final List<ScheduleSlot> todaySlots;

  /// Goal title → progress fraction (0.0–1.0).
  final Map<String, double> goalsProgress;

  String get attendanceLabel => '${attendancePercent.toStringAsFixed(0)}%';
  String get goalsLabel => '$completedGoals/$totalGoals';
  String get streakLabel => '$streakDays days';

  @override
  String toString() =>
      'StudentDashboardSummary(attendance: $attendanceLabel, '
      'streak: $streakLabel, goals: $goalsLabel)';
}

// ---------------------------------------------------------------------------
// Teacher variant
// ---------------------------------------------------------------------------

/// A single class entry for the teacher's today-view.
class TeacherClassSlot {
  const TeacherClassSlot({
    required this.timetableId,
    required this.course,
    required this.section,
    required this.room,
    required this.start,
    required this.end,
    required this.enrolled,
    required this.status, // 'planned' | 'live' | 'closed'
  });

  final String timetableId;
  final String course;
  final String section;
  final String room;
  final DateTime start;
  final DateTime end;
  final int enrolled;
  final String status;

  bool get isLive => status == 'live';
  bool get isClosed => status == 'closed';
  bool get isPlanned => status == 'planned';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherClassSlot && timetableId == other.timetableId;

  @override
  int get hashCode => timetableId.hashCode;
}

/// A summary of a recently closed attendance session.
class RecentSessionSummary {
  const RecentSessionSummary({
    required this.course,
    required this.section,
    required this.dateLabel,
    required this.presentCount,
    required this.totalCount,
  });

  final String course;
  final String section;
  final String dateLabel;
  final int presentCount;
  final int totalCount;

  double get percentage =>
      totalCount == 0 ? 0.0 : (presentCount / totalCount) * 100;
}

/// Aggregated data displayed on the teacher dashboard.
class TeacherDashboardSummary {
  const TeacherDashboardSummary({
    required this.todayClasses,
    required this.pendingExceptionsCount,
    required this.recentSessions,
  });

  final List<TeacherClassSlot> todayClasses;
  final int pendingExceptionsCount;
  final List<RecentSessionSummary> recentSessions;

  @override
  String toString() =>
      'TeacherDashboardSummary(classes: ${todayClasses.length}, '
      'pendingExceptions: $pendingExceptionsCount)';
}
