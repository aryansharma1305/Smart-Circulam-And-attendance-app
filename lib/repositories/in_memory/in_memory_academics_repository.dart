import '../../models/user.dart';
import '../../models/timetable.dart';
import '../../models/session.dart';
import '../../models/course.dart';
import '../../core/app_error.dart';
import '../academics_repository.dart';

/// In-memory [AcademicsRepository].
///
/// Seeds the same schedule data that previously lived in
/// [TeacherHomePage._loadMockData()] and [StudentDashboardPage._buildTodaySchedule()].
class InMemoryAcademicsRepository implements AcademicsRepository {
  InMemoryAcademicsRepository() {
    _seed();
  }

  final List<TimetableEntry> _timetable = [];
  final List<Session> _sessions = [];
  final List<Course> _courses = [];

  // -------------------------------------------------------------------------
  // Seed helpers
  // -------------------------------------------------------------------------

  static DateTime _today(int hour, [int minute = 0]) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void _seed() {
    final now = DateTime.now();

    // Courses ---------------------------------------------------------------
    _courses.addAll([
      Course(
        id: 'course-dsa',
        code: 'CS301',
        name: 'DSA',
        teacherId: 'teacher-001',
        department: 'Computer Science',
        semester: 'Spring 2025',
        sections: ['Sec A'],
        credits: 4,
        description: 'Data Structures & Algorithms',
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: 'course-dbms',
        code: 'CS302',
        name: 'DBMS',
        teacherId: 'teacher-001',
        department: 'Computer Science',
        semester: 'Spring 2025',
        sections: ['Sec B'],
        credits: 4,
        description: 'Database Management Systems',
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: 'course-os',
        code: 'CS303',
        name: 'OS',
        teacherId: 'teacher-001',
        department: 'Computer Science',
        semester: 'Spring 2025',
        sections: ['Sec C'],
        credits: 4,
        description: 'Operating Systems',
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: 'course-math',
        code: 'MA101',
        name: 'Mathematics',
        teacherId: 'teacher-001',
        department: 'Science',
        semester: 'Spring 2025',
        sections: ['A'],
        credits: 4,
        description: 'Engineering Mathematics',
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: 'course-physics',
        code: 'PH101',
        name: 'Physics',
        teacherId: 'teacher-001',
        department: 'Science',
        semester: 'Spring 2025',
        sections: ['A'],
        credits: 3,
        description: 'Engineering Physics',
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: 'course-chemistry',
        code: 'CH101',
        name: 'Chemistry',
        teacherId: 'teacher-001',
        department: 'Science',
        semester: 'Spring 2025',
        sections: ['A'],
        credits: 3,
        description: 'Engineering Chemistry',
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    // Timetable entries (today's weekday) ------------------------------------
    final weekday = now.weekday; // 1 = Mon … 7 = Sun

    _timetable.addAll([
      // Teacher's classes
      TimetableEntry(
        id: 'tt-dsa',
        courseId: 'course-dsa',
        roomId: 'room-B201',
        teacherId: 'teacher-001',
        section: 'Sec A',
        dayOfWeek: weekday,
        startTime: _today(10),
        endTime: _today(10, 50),
        semester: 'Spring 2025',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      TimetableEntry(
        id: 'tt-dbms',
        courseId: 'course-dbms',
        roomId: 'room-B205',
        teacherId: 'teacher-001',
        section: 'Sec B',
        dayOfWeek: weekday,
        startTime: _today(14),
        endTime: _today(14, 50),
        semester: 'Spring 2025',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      TimetableEntry(
        id: 'tt-os',
        courseId: 'course-os',
        roomId: 'room-B210',
        teacherId: 'teacher-001',
        section: 'Sec C',
        dayOfWeek: weekday,
        startTime: _today(16),
        endTime: _today(16, 50),
        semester: 'Spring 2025',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      // Student's classes
      TimetableEntry(
        id: 'tt-math',
        courseId: 'course-math',
        roomId: 'room-101',
        teacherId: 'teacher-001',
        section: 'A',
        dayOfWeek: weekday,
        startTime: _today(9),
        endTime: _today(10),
        semester: 'Spring 2025',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      TimetableEntry(
        id: 'tt-physics',
        courseId: 'course-physics',
        roomId: 'room-102',
        teacherId: 'teacher-001',
        section: 'A',
        dayOfWeek: weekday,
        startTime: _today(10, 30),
        endTime: _today(11, 30),
        semester: 'Spring 2025',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      TimetableEntry(
        id: 'tt-chemistry',
        courseId: 'course-chemistry',
        roomId: 'room-103',
        teacherId: 'teacher-001',
        section: 'A',
        dayOfWeek: weekday,
        startTime: _today(14),
        endTime: _today(15),
        semester: 'Spring 2025',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    // Sessions (recent + one live) ------------------------------------------
    _sessions.addAll([
      Session(
        id: 'session-001',
        timetableId: 'tt-dbms',
        date: now,
        state: SessionState.live,
        qrSeed: 'seed-live-001',
        qrExpiry: now.add(const Duration(minutes: 30)),
        proximityPolicy: {'geo': true, 'ssid': true},
        stats: {
          'total_students': 48,
          'present_students': 42,
          'absent_students': 6,
          'late_students': 3,
        },
        createdAt: now,
        updatedAt: now,
      ),
      Session(
        id: 'session-002',
        timetableId: 'tt-dsa',
        date: now.subtract(const Duration(days: 1)),
        state: SessionState.closed,
        qrSeed: 'seed-closed-001',
        qrExpiry: now.subtract(const Duration(hours: 23)),
        proximityPolicy: {},
        stats: {
          'total_students': 52,
          'present_students': 45,
          'absent_students': 7,
          'late_students': 2,
        },
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Session(
        id: 'session-003',
        timetableId: 'tt-dbms',
        date: now.subtract(const Duration(days: 2)),
        state: SessionState.closed,
        qrSeed: 'seed-closed-002',
        qrExpiry: now.subtract(const Duration(days: 2)),
        proximityPolicy: {},
        stats: {
          'total_students': 48,
          'present_students': 42,
          'absent_students': 6,
          'late_students': 1,
        },
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Session(
        id: 'session-004',
        timetableId: 'tt-os',
        date: now.subtract(const Duration(days: 3)),
        state: SessionState.closed,
        qrSeed: 'seed-closed-003',
        qrExpiry: now.subtract(const Duration(days: 3)),
        proximityPolicy: {},
        stats: {
          'total_students': 45,
          'present_students': 40,
          'absent_students': 5,
          'late_students': 0,
        },
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ]);
  }

  // -------------------------------------------------------------------------
  // AcademicsRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<List<TimetableEntry>> getTodaySchedule(
    String userId,
    UserRole role,
  ) async {
    final today = DateTime.now().weekday;
    return _timetable.where((e) {
      if (!e.isActive || e.dayOfWeek != today) return false;
      return role == UserRole.teacher
          ? e.teacherId == userId
          : true; // student: return all (enrolment filter Phase 3)
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<List<TimetableEntry>> getWeekSchedule(
    String userId,
    UserRole role,
  ) async {
    return _timetable.where((e) {
      if (!e.isActive) return false;
      return role == UserRole.teacher ? e.teacherId == userId : true;
    }).toList()
      ..sort((a, b) {
        final dayComp = a.dayOfWeek.compareTo(b.dayOfWeek);
        return dayComp != 0
            ? dayComp
            : a.startTime.compareTo(b.startTime);
      });
  }

  @override
  Future<List<Course>> getCoursesForUser(String userId, UserRole role) async {
    if (role == UserRole.teacher) {
      return _courses.where((c) => c.teacherId == userId).toList();
    }
    return List.of(_courses); // students see all (Phase 3: enrolment filter)
  }

  @override
  Future<List<Session>> getSessionsForTeacher(
    String teacherId, {
    DateTime? date,
  }) async {
    final teacherEntryIds = _timetable
        .where((e) => e.teacherId == teacherId)
        .map((e) => e.id)
        .toSet();

    return _sessions.where((s) {
      if (!teacherEntryIds.contains(s.timetableId)) return false;
      if (date != null) {
        return s.date.year == date.year &&
            s.date.month == date.month &&
            s.date.day == date.day;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Session> createSession(Session session) async {
    // Check for conflict: same timetable entry, same day, already live
    final conflict = _sessions.any((s) =>
        s.timetableId == session.timetableId &&
        s.date.year == session.date.year &&
        s.date.month == session.date.month &&
        s.date.day == session.date.day &&
        s.state == SessionState.live);

    if (conflict) {
      throw const ConflictError(
        detail: 'A live session already exists for this class today.',
      );
    }

    _sessions.add(session);
    return session;
  }

  @override
  Future<Session> updateSessionState(
    String sessionId,
    SessionState newState,
  ) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) {
      throw const ServiceUnavailableError(
        detail: 'Session not found.',
      );
    }

    final existing = _sessions[index];

    // Disallow re-opening a closed session
    if (existing.state == SessionState.closed &&
        newState != SessionState.closed) {
      throw const ConflictError(
        detail: 'Cannot reopen a session that has already been closed.',
      );
    }

    final updated = existing.copyWith(
      state: newState,
      updatedAt: DateTime.now(),
    );
    _sessions[index] = updated;
    return updated;
  }

  // -------------------------------------------------------------------------
  // Test helpers
  // -------------------------------------------------------------------------

  void reset() {
    _timetable.clear();
    _sessions.clear();
    _courses.clear();
    _seed();
  }

  List<Session> get allSessions => List.unmodifiable(_sessions);
}
