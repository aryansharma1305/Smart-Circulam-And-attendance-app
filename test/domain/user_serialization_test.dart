import 'package:flutter_test/flutter_test.dart';

import 'package:management_app/models/user.dart';

void main() {
  group('User serialization', () {
    test('round-trips through toJson / fromJson', () {
      final now = DateTime(2025, 1, 15, 8, 30);
      final user = User(
        uid: 'user-001',
        name: 'Alice',
        phone: '+919000000001',
        email: 'alice@test.edu',
        role: UserRole.student,
        department: 'CS',
        year: '2025',
        section: 'A',
        subjects: ['Math', 'Physics'],
        institutionCode: 'TEST_UNI',
        createdAt: now,
        lastActive: now,
      );

      final json = user.toJson();
      final restored = User.fromJson(json);

      expect(restored.uid, user.uid);
      expect(restored.name, user.name);
      expect(restored.email, user.email);
      expect(restored.role, user.role);
      expect(restored.department, user.department);
      expect(restored.year, user.year);
      expect(restored.section, user.section);
      expect(restored.subjects, user.subjects);
      expect(restored.institutionCode, user.institutionCode);
    });

    test('equality is based on uid only', () {
      final now = DateTime.now();
      final a = User(
        uid: 'uid-1',
        name: 'Alice',
        phone: '+1',
        email: 'a@test.edu',
        role: UserRole.student,
        createdAt: now,
        lastActive: now,
      );
      final b = User(
        uid: 'uid-1',
        name: 'Alice Updated',
        phone: '+2',
        email: 'b@test.edu',
        role: UserRole.teacher,
        createdAt: now,
        lastActive: now,
      );
      final c = User(
        uid: 'uid-2',
        name: 'Alice',
        phone: '+1',
        email: 'a@test.edu',
        role: UserRole.student,
        createdAt: now,
        lastActive: now,
      );

      expect(a, equals(b)); // same uid
      expect(a, isNot(equals(c))); // different uid
      expect(a.hashCode, equals(b.hashCode));
    });

    test('role helpers return correct booleans', () {
      final now = DateTime.now();
      final student = User(
        uid: 's',
        name: 'S',
        phone: '+1',
        email: 's@t.edu',
        role: UserRole.student,
        createdAt: now,
        lastActive: now,
      );
      final teacher = User(
        uid: 't',
        name: 'T',
        phone: '+2',
        email: 't@t.edu',
        role: UserRole.teacher,
        createdAt: now,
        lastActive: now,
      );

      expect(student.isStudent, isTrue);
      expect(student.isTeacher, isFalse);
      expect(teacher.isTeacher, isTrue);
      expect(teacher.isStudent, isFalse);
    });

    test('copyWith preserves unmodified fields', () {
      final now = DateTime.now();
      final original = User(
        uid: 'u1',
        name: 'Original',
        phone: '+1',
        email: 'orig@t.edu',
        role: UserRole.student,
        department: 'CS',
        createdAt: now,
        lastActive: now,
      );

      final updated = original.copyWith(name: 'Updated');
      expect(updated.name, 'Updated');
      expect(updated.uid, original.uid);
      expect(updated.department, original.department);
    });
  });
}
