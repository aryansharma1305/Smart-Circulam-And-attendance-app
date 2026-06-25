import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance_exception.dart';
import '../core/app_error.dart';
import '../repositories/exception_repository.dart';
import '../providers/repository_providers.dart';
import '../controllers/auth_controller.dart';

// ---------------------------------------------------------------------------
// Exception Controller
// ---------------------------------------------------------------------------

/// Manages the list of [AttendanceException]s for the current user.
///
/// Teachers see all exceptions pending their review.
/// Students see their own submitted exceptions.
class ExceptionController
    extends StateNotifier<AsyncValue<List<AttendanceException>>> {
  ExceptionController({
    required this.repository,
    required this.userId,
    required this.isTeacher,
  }) : super(const AsyncValue.loading()) {
    load();
  }

  final ExceptionRepository repository;
  final String userId;
  final bool isTeacher;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = isTeacher
          ? await repository.getExceptionsForTeacher(userId)
          : await repository.getExceptionsForStudent(userId);
      state = AsyncValue.data(list);
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(
        ServiceUnavailableError(detail: e.toString()),
        st,
      );
    }
  }

  /// Submit a new exception request (student action).
  Future<void> submit(AttendanceException exception) async {
    try {
      final saved = await repository.submitException(exception);
      final current = state.value ?? [];
      state = AsyncValue.data([saved, ...current]);
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Approve or reject an exception (teacher action).
  Future<void> review(
    String id,
    ExceptionStatus status, {
    String? comments,
  }) async {
    try {
      final updated = await repository.reviewException(
        id,
        status,
        comments: comments,
        reviewerId: userId,
      );
      final current = state.value ?? [];
      state = AsyncValue.data([
        for (final e in current) e.id == id ? updated : e,
      ]);
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refreshes the list from the repository.
  Future<void> refresh() => load();
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Exception list for the current user (teacher sees all; student sees own).
final exceptionControllerProvider = StateNotifierProvider.autoDispose<
    ExceptionController, AsyncValue<List<AttendanceException>>>((ref) {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(exceptionRepositoryProvider);

  return ExceptionController(
    repository: repository,
    userId: user?.uid ?? '',
    isTeacher: user?.isTeacher ?? false,
  );
});

/// Pending exception count for badge display (teacher-facing).
final pendingExceptionCountProvider = Provider.autoDispose<int>((ref) {
  final exceptions = ref.watch(exceptionControllerProvider).value ?? [];
  return exceptions.where((e) => e.isPending).length;
});
