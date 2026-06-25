import 'package:flutter_test/flutter_test.dart';
import 'package:management_app/services/secure_qr_service.dart';

void main() {
  group('SecureQrService', () {
    const secret = 'unit-test-secret';
    final issuedAt = DateTime.utc(2026, 1, 1, 9);

    late SecureQrService service;

    setUp(() {
      service = SecureQrService(
        signingSecret: secret,
        tokenTtl: const Duration(seconds: 30),
        now: () => issuedAt,
      );
    });

    test('issues and verifies a signed QR token', () {
      final raw = service.issueToken(
        sessionId: 'session-1',
        timetableEntryId: 'slot-1',
        teacherId: 'teacher-1',
        nonce: 'nonce-1',
      );

      final result = service.verifyToken(
        rawToken: raw,
        expectedSessionId: 'session-1',
        now: issuedAt.add(const Duration(seconds: 5)),
      );

      expect(result.isValid, isTrue);
      expect(result.token?.sessionId, 'session-1');
      expect(result.token?.nonce, 'nonce-1');
    });

    test('rejects tampered payloads', () {
      final raw = service.issueToken(
        sessionId: 'session-1',
        timetableEntryId: 'slot-1',
        teacherId: 'teacher-1',
      );

      final parts = raw.split('.');
      final tampered = '${parts[0]}.${parts[1]}.${parts[2]}x.${parts[3]}';

      final result = service.verifyToken(rawToken: tampered);
      expect(result.isValid, isFalse);
      expect(result.error, contains('signature'));
    });

    test('rejects expired tokens', () {
      final raw = service.issueToken(
        sessionId: 'session-1',
        timetableEntryId: 'slot-1',
        teacherId: 'teacher-1',
      );

      final result = service.verifyToken(
        rawToken: raw,
        now: issuedAt.add(const Duration(seconds: 31)),
      );

      expect(result.isValid, isFalse);
      expect(result.error, contains('expired'));
    });

    test('rejects tokens for another session', () {
      final raw = service.issueToken(
        sessionId: 'session-1',
        timetableEntryId: 'slot-1',
        teacherId: 'teacher-1',
      );

      final result = service.verifyToken(
        rawToken: raw,
        expectedSessionId: 'session-2',
      );

      expect(result.isValid, isFalse);
      expect(result.error, contains('another session'));
    });
  });
}
