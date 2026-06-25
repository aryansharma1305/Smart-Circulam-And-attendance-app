import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import '../repositories/academics_repository.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/exception_repository.dart';
import '../repositories/announcement_repository.dart';
import '../repositories/academic_admin_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/in_memory/in_memory_auth_repository.dart';
import '../repositories/in_memory/in_memory_academics_repository.dart';
import '../repositories/in_memory/in_memory_attendance_repository.dart';
import '../repositories/in_memory/in_memory_exception_repository.dart';
import '../repositories/in_memory/in_memory_announcement_repository.dart';
import '../repositories/in_memory/in_memory_academic_admin_repository.dart';
import '../repositories/in_memory/in_memory_notification_repository.dart';

// ---------------------------------------------------------------------------
// Repository Providers
// ---------------------------------------------------------------------------
//
// Each provider defaults to the in-memory implementation so the app works
// without Firebase and tests can run in isolation.
//
// To plug in a real backend, override the provider in [ProviderScope]:
//
// ```dart
// ProviderScope(
//   overrides: [
//     authRepositoryProvider.overrideWithValue(FirebaseAuthRepository()),
//   ],
//   child: SmartStudyApp(),
// )
// ```

/// Provides the [AuthRepository] implementation in use.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => InMemoryAuthRepository(),
);

/// Provides the [AcademicsRepository] implementation in use.
final academicsRepositoryProvider = Provider<AcademicsRepository>(
  (ref) => InMemoryAcademicsRepository(),
);

/// Provides the [AttendanceRepository] implementation in use.
final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => InMemoryAttendanceRepository(),
);

/// Provides the [ExceptionRepository] implementation in use.
final exceptionRepositoryProvider = Provider<ExceptionRepository>(
  (ref) => InMemoryExceptionRepository(),
);

/// Provides the [AnnouncementRepository] implementation in use.
final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) => InMemoryAnnouncementRepository(),
);

final academicAdminRepositoryProvider = Provider<AcademicAdminRepository>(
  (ref) => InMemoryAcademicAdminRepository(),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => InMemoryNotificationRepository(),
);
