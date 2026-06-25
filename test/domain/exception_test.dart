import 'package:flutter_test/flutter_test.dart';
import 'package:management_app/core/app_error.dart';
import 'package:management_app/models/attendance_exception.dart';

void main() {
  group('AppError hierarchy', () {
    test('ConflictError carries its detail message', () {
      const err = ConflictError(detail: 'Duplicate session');
      expect(err.message, 'Duplicate session');
      expect(err.code, 'conflict');
    });

    test('ValidationError joins field messages', () {
      const err = ValidationError(fields: {'email': 'Bad email', 'otp': 'Too short'});
      expect(err.message, contains('email'));
      expect(err.code, 'validation_error');
    });

    test('NetworkError has default message', () {
      const err = NetworkError();
      expect(err.message, isNotEmpty);
    });
  });

  group('AttendanceException domain rules', () {
    final now = DateTime.now();

    AttendanceException make({
      String id = '1',
      ExceptionType type = ExceptionType.lateArrival,
      ExceptionStatus status = ExceptionStatus.pending,
      DateTime? requestedAt,
    }) {
      return AttendanceException(
        id: id,
        sessionId: 'sess-1',
        studentId: 'student-1',
        studentName: 'Test Student',
        studentEmail: 'test@test.edu',
        type: type,
        status: status,
        reason: 'Test reason',
        requestedAt: requestedAt ?? now,
        originalStatus: 'absent',
        requestedStatus: 'present',
      );
    }

    test('isPending is true for pending status', () {
      expect(make(status: ExceptionStatus.pending).isPending, isTrue);
      expect(make(status: ExceptionStatus.approved).isPending, isFalse);
    });

    test('isUnderReview is true for underReview status', () {
      expect(make(status: ExceptionStatus.underReview).isUnderReview, isTrue);
    });

    test('isApproved is true for approved status', () {
      expect(make(status: ExceptionStatus.approved).isApproved, isTrue);
    });

    test('isRejected is true for rejected status', () {
      expect(make(status: ExceptionStatus.rejected).isRejected, isTrue);
    });

    test('isUrgent when pending and requested > 4 days ago', () {
      final oldRequest = now.subtract(const Duration(days: 4));
      final exception = make(
        status: ExceptionStatus.pending,
        requestedAt: oldRequest,
      );
      expect(exception.isUrgent, isTrue);
    });

    test('not urgent when pending but recent', () {
      final exception = make(
        status: ExceptionStatus.pending,
        requestedAt: now.subtract(const Duration(hours: 1)),
      );
      expect(exception.isUrgent, isFalse);
    });

    test('not urgent when approved regardless of age', () {
      final oldRequest = now.subtract(const Duration(hours: 25));
      final exception = make(
        status: ExceptionStatus.approved,
        requestedAt: oldRequest,
      );
      expect(exception.isUrgent, isFalse);
    });

    test('copyWith updates status and preserves other fields', () {
      final original = make();
      final updated = original.copyWith(
        status: ExceptionStatus.approved,
        reviewedBy: 'teacher-001',
        reviewerComments: 'Looks fine',
        reviewedAt: now,
      );

      expect(updated.status, ExceptionStatus.approved);
      expect(updated.reviewedBy, 'teacher-001');
      expect(updated.id, original.id);
      expect(updated.studentId, original.studentId);
    });
  });
}
