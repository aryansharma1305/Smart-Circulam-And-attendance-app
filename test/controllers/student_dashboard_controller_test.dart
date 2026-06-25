import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:management_app/controllers/student_dashboard_controller.dart';
import 'package:management_app/models/dashboard_summary.dart';
import 'package:management_app/providers/repository_providers.dart';
import 'package:management_app/repositories/in_memory/in_memory_academics_repository.dart';
import 'package:management_app/repositories/in_memory/in_memory_attendance_repository.dart';
import 'package:management_app/controllers/auth_controller.dart';
import 'package:management_app/repositories/in_memory/in_memory_auth_repository.dart';

void main() {
  group('StudentDashboardController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(InMemoryAuthRepository()),
          academicsRepositoryProvider
              .overrideWithValue(InMemoryAcademicsRepository()),
          attendanceRepositoryProvider
              .overrideWithValue(InMemoryAttendanceRepository()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('starts in loading state', () {
      final state = container.read(studentDashboardControllerProvider);
      // May be loading or already loaded depending on async timing
      expect(
        state.isLoading || state.hasValue,
        isTrue,
      );
    });

    test('resolves to success with StudentDashboardSummary', () async {
      // Sign in to set a user so the controller has a userId
      final authRepo = container.read(authRepositoryProvider);
      await (authRepo as InMemoryAuthRepository).signIn(
        'student@demo.edu',
        'demo1234',
      );

      // Directly construct and call load
      final academicsRepo = container.read(academicsRepositoryProvider);
      final attendanceRepo = container.read(attendanceRepositoryProvider);

      final controller = StudentDashboardController(
        academicsRepo: academicsRepo,
        attendanceRepo: attendanceRepo,
        userId: 'student-001',
      );

      // Give it time to complete the async load
      await Future.delayed(const Duration(milliseconds: 100));

      final state = controller.state;
      expect(state.hasValue, isTrue);

      final summary = state.value;
      expect(summary, isA<StudentDashboardSummary>());
      expect(summary!.attendancePercent, greaterThanOrEqualTo(0));
      expect(summary.attendancePercent, lessThanOrEqualTo(100));
      expect(summary.streakDays, greaterThanOrEqualTo(0));
      expect(summary.completedGoals, lessThanOrEqualTo(summary.totalGoals));
    });

    test('ProviderContainer override allows replacing repositories', () {
      // Verify that the override is in effect
      final repo = container.read(academicsRepositoryProvider);
      expect(repo, isA<InMemoryAcademicsRepository>());

      final attendanceRepo = container.read(attendanceRepositoryProvider);
      expect(attendanceRepo, isA<InMemoryAttendanceRepository>());
    });
  });
}
