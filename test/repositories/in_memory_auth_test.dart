import 'package:flutter_test/flutter_test.dart';
import 'package:management_app/core/app_error.dart';
import 'package:management_app/repositories/in_memory/in_memory_auth_repository.dart';
import 'package:management_app/models/user.dart';

void main() {
  group('InMemoryAuthRepository', () {
    late InMemoryAuthRepository repo;

    setUp(() => repo = InMemoryAuthRepository());

    test('getCurrentUser returns null initially', () async {
      final user = await repo.getCurrentUser();
      expect(user, isNull);
    });

    test('signIn with valid student credentials returns the seeded User', () async {
      final user = await repo.signIn('student@demo.edu', 'demo1234');
      expect(user.role, UserRole.student);
      expect(user.email, 'student@demo.edu');
      expect(user.uid, 'student-001');
    });

    test('signIn with valid teacher credentials returns teacher User', () async {
      final user = await repo.signIn('teacher@demo.edu', 'demo1234');
      expect(user.role, UserRole.teacher);
    });

    test('signIn with wrong password throws AuthorizationError', () async {
      expect(
        () => repo.signIn('student@demo.edu', 'wrong_password'),
        throwsA(isA<AuthorizationError>()),
      );
    });

    test('signIn with unknown email throws AuthorizationError', () async {
      expect(
        () => repo.signIn('nobody@test.edu', 'demo1234'),
        throwsA(isA<AuthorizationError>()),
      );
    });

    test('signIn with empty email throws ValidationError', () async {
      expect(
        () => repo.signIn('', 'demo1234'),
        throwsA(isA<ValidationError>()),
      );
    });

    test('getCurrentUser returns signed-in user after signIn', () async {
      await repo.signIn('student@demo.edu', 'demo1234');
      final user = await repo.getCurrentUser();
      expect(user, isNotNull);
      expect(user!.email, 'student@demo.edu');
    });

    test('signOut clears the current user', () async {
      await repo.signIn('student@demo.edu', 'demo1234');
      await repo.signOut();
      expect(await repo.getCurrentUser(), isNull);
    });

    test('signInWithOtp accepts any 6-digit OTP', () async {
      final user = await repo.signInWithOtp('+91900000001', '123456');
      expect(user, isNotNull);
    });

    test('signInWithOtp rejects OTPs not 6 digits', () async {
      expect(
        () => repo.signInWithOtp('+91900000001', '123'),
        throwsA(isA<ValidationError>()),
      );
    });

    test('signInAsRole fails if role does not match', () async {
      expect(
        () => repo.signInAsRole(
          UserRole.teacher,
          'student@demo.edu',
          'demo1234',
        ),
        throwsA(isA<AuthorizationError>()),
      );
    });

    test('signInAsRole succeeds with matching role', () async {
      final user = await repo.signInAsRole(
        UserRole.teacher,
        'teacher@demo.edu',
        'demo1234',
      );
      expect(user.role, UserRole.teacher);
    });

    test('updateProfile throws AuthorizationError when not signed in', () async {
      expect(
        () => repo.updateProfile(name: 'New Name'),
        throwsA(isA<AuthorizationError>()),
      );
    });

    test('updateProfile updates name when signed in', () async {
      await repo.signIn('student@demo.edu', 'demo1234');
      final updated = await repo.updateProfile(name: 'Updated Name');
      expect(updated.name, 'Updated Name');
      expect(updated.email, 'student@demo.edu');
    });
  });
}
