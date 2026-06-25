import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/announcement.dart';
import '../models/user.dart';
import '../core/app_error.dart';
import '../repositories/announcement_repository.dart';
import '../providers/repository_providers.dart';
import '../controllers/auth_controller.dart';

// ---------------------------------------------------------------------------
// Announcement Controller
// ---------------------------------------------------------------------------

/// Manages the list of [Announcement]s for the current user.
///
/// Teachers see announcements they created.
/// Students see announcements targeted at their courses/sections.
class AnnouncementController
    extends StateNotifier<AsyncValue<List<Announcement>>> {
  AnnouncementController({
    required this.repository,
    required this.userId,
    required this.institutionId,
    required this.role,
  }) : super(const AsyncValue.loading()) {
    load();
  }

  final AnnouncementRepository repository;
  final String userId;
  final String institutionId;
  final UserRole role;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await repository.getAnnouncementsForUser(
        userId,
        role,
        institutionId,
      );
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

  /// Creates and publishes a new announcement (teacher action).
  Future<void> create(Announcement announcement) async {
    try {
      final saved = await repository.createAnnouncement(
        announcement.copyWith(institutionId: institutionId),
      );
      final current = state.value ?? [];
      state = AsyncValue.data([saved, ...current]);
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Marks [announcementId] as read by the current user.
  Future<void> markRead(String announcementId) async {
    try {
      await repository.markRead(announcementId, userId);
      // Optimistically update local state
      final current = state.value ?? [];
      state = AsyncValue.data([
        for (final a in current)
          a.id == announcementId
              ? a.copyWith(readBy: [...a.readBy, userId])
              : a,
      ]);
    } catch (_) {
      // Silently swallow – marking read is non-critical
    }
  }

  /// Refreshes the list from the repository.
  Future<void> refresh() => load();

  /// Deletes an announcement.
  Future<void> delete(String announcementId) async {
    try {
      await repository.deleteAnnouncement(announcementId);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.where((a) => a.id != announcementId).toList(),
      );
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Announcement list for the current user.
final announcementControllerProvider =
    StateNotifierProvider.autoDispose<
      AnnouncementController,
      AsyncValue<List<Announcement>>
    >((ref) {
      final user = ref.watch(currentUserProvider);
      final repository = ref.watch(announcementRepositoryProvider);

      return AnnouncementController(
        repository: repository,
        userId: user?.uid ?? '',
        institutionId: user?.institutionId ?? '',
        role: user?.role ?? UserRole.student,
      );
    });

/// Unread announcement count for badge display.
final unreadAnnouncementCountProvider = Provider.autoDispose<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final announcements = ref.watch(announcementControllerProvider).value ?? [];
  return announcements.where((a) => !a.hasBeenReadBy(user.uid)).length;
});
