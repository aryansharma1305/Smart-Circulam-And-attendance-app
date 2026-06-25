import 'package:flutter_test/flutter_test.dart';
import 'package:management_app/core/app_error.dart';
import 'package:management_app/models/session.dart';
import 'package:management_app/repositories/in_memory/in_memory_attendance_repository.dart';
import 'package:management_app/services/attendance_qr_submission_service.dart';
import 'package:management_app/services/secure_qr_service.dart';

void main() {
  group('AttendanceQrSubmissionService', () {
    final now = DateTime.utc(2026, 1, 1, 9);
    const sessionId = 'session-secure-1';

    late InMemoryAttendanceRepository attendanceRepository;
    late SecureQrService qrService;
    late AttendanceQrSubmissionService submissionService;

    Session liveSession() => Session(
      id: sessionId,
      timetableId: 'slot-1',
      date: now,
      state: SessionState.live,
      qrSeed: '',
      qrExpiry: now.add(const Duration(minutes: 5)),
      proximityPolicy: const {},
      stats: const {},
      createdAt: now,
      updatedAt: now,
    );

    setUp(() {
      attendanceRepository = InMemoryAttendanceRepository();
      qrService = SecureQrService(
        signingSecret: 'unit-test-secret',
        tokenTtl: const Duration(seconds: 30),
        now: () => now,
      );
      submissionService = AttendanceQrSubmissionService(
        qrService: qrService,
        attendanceRepository: attendanceRepository,
        resolveSession: (id) async => id == sessionId ? liveSession() : null,
        isStudentEnrolled: ({required sessionId, required studentId}) async =>
            studentId == 'student-001',
        now: () => now.add(const Duration(seconds: 5)),
      );
    });

    test('submits attendance from a valid signed QR token', () async {
      final token = qrService.issueToken(
        sessionId: sessionId,
        timetableEntryId: 'slot-1',
        teacherId: 'teacher-1',
        nonce: 'nonce-1',
      );

      final record = await submissionService.submit(
        rawQrToken: token,
        studentId: 'student-001',
        expectedSessionId: sessionId,
      );

      expect(record.sessionId, sessionId);
      expect(record.studentId, 'student-001');
      expect(record.totpNonce, 'nonce-1');
    });

    test('duplicate submit is rejected by attendance repository', () async {
      final token = qrService.issueToken(
        sessionId: sessionId,
        timetableEntryId: 'slot-1',
        teacherId: 'teacher-1',
      );

      await submissionService.submit(
        rawQrToken: token,
        studentId: 'student-001',
      );

      expect(
        () => submissionService.submit(
          rawQrToken: token,
          studentId: 'student-001',
        ),
        throwsA(isA<ConflictError>()),
      );
    });

    test('unenrolled student is rejected', () {
      final token = qrService.issueToken(
        sessionId: sessionId,
        timetableEntryId: 'slot-1',
        teacherId: 'teacher-1',
      );

      expect(
        () => submissionService.submit(
          rawQrToken: token,
          studentId: 'student-999',
        ),
        throwsA(isA<AuthorizationError>()),
      );
    });

    test('expired QR token is rejected before writing attendance', () {
      final token = qrService.issueToken(
        sessionId: sessionId,
        timetableEntryId: 'slot-1',
        teacherId: 'teacher-1',
        issuedAt: now.subtract(const Duration(minutes: 2)),
      );

      expect(
        () => submissionService.submit(
          rawQrToken: token,
          studentId: 'student-001',
        ),
        throwsA(isA<ValidationError>()),
      );
    });
  });
}
