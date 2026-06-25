import 'package:flutter_test/flutter_test.dart';
import 'package:management_app/core/app_error.dart';
import 'package:management_app/repositories/in_memory/in_memory_attendance_repository.dart';
import 'package:management_app/models/attendance.dart';

void main() {
  group('InMemoryAttendanceRepository', () {
    late InMemoryAttendanceRepository repo;

    setUp(() => repo = InMemoryAttendanceRepository());

    test('getStreakDays returns ≥ 1 for the seeded student', () async {
      final streak = await repo.getStreakDays('student-001');
      expect(streak, greaterThanOrEqualTo(1));
    });

    test('getAttendancePercentage is between 0 and 100', () async {
      final pct = await repo.getAttendancePercentage('student-001', '');
      expect(pct, greaterThanOrEqualTo(0));
      expect(pct, lessThanOrEqualTo(100));
    });

    test('getStudentHistory returns seeded records for student-001', () async {
      final history = await repo.getStudentHistory('student-001');
      expect(history, isNotEmpty);
    });

    test('getStudentHistory returns empty for unknown student', () async {
      final history = await repo.getStudentHistory('nobody');
      expect(history, isEmpty);
    });

    test('markAttendance persists a new record', () async {
      final record = Attendance(
        sessionId: 'new-session-001',
        studentId: 'student-001',
        status: AttendanceStatus.present,
        geoOK: true,
        ssidOK: false,
        createdAt: DateTime.now(),
      );

      final saved = await repo.markAttendance(record);
      expect(saved.sessionId, record.sessionId);

      // Should now appear in history
      final roll = await repo.getSessionRoll('new-session-001');
      expect(roll.length, 1);
    });

    test('markAttendance throws ConflictError on duplicate (sessionId, studentId)', () async {
      final record = Attendance(
        sessionId: 'dup-session',
        studentId: 'student-001',
        status: AttendanceStatus.present,
        geoOK: true,
        ssidOK: false,
        createdAt: DateTime.now(),
      );

      await repo.markAttendance(record);

      expect(
        () => repo.markAttendance(record),
        throwsA(isA<ConflictError>()),
      );
    });

    test('getSessionRoll returns all records for a session', () async {
      final r1 = Attendance(
        sessionId: 'multi-sess',
        studentId: 'student-A',
        status: AttendanceStatus.present,
        geoOK: true,
        ssidOK: false,
        createdAt: DateTime.now(),
      );
      final r2 = Attendance(
        sessionId: 'multi-sess',
        studentId: 'student-B',
        status: AttendanceStatus.absent,
        geoOK: false,
        ssidOK: false,
        createdAt: DateTime.now(),
      );

      await repo.markAttendance(r1);
      await repo.markAttendance(r2);

      final roll = await repo.getSessionRoll('multi-sess');
      expect(roll.length, 2);
    });
  });
}
