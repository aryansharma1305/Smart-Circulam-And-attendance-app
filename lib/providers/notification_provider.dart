import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/announcement.dart';
import '../models/in_app_notification.dart';
import '../controllers/auth_controller.dart';
import '../controllers/announcement_controller.dart';
import '../providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Notification / Announcement Providers
// ---------------------------------------------------------------------------
//
// These providers replace the previous Firebase-dependent implementations
// (which imported firebase_auth and notification_service.dart).
// All data now flows through [AnnouncementRepository].
//
// The provider names are kept backward-compatible where possible.

/// All announcements for the currently signed-in user.
///
/// Replaces the old [announcementsProvider] (which returned raw Maps).
/// Consumers that previously read `Map<String, dynamic>` may need to be
/// updated to use the typed [Announcement] model.
final announcementsProvider = announcementControllerProvider;

/// Number of unread announcements for the current user.
final unreadAnnouncementsCountProvider = unreadAnnouncementCountProvider;

/// Creates a new announcement.
///
/// Pass an [Announcement] value; the repository will assign an ID.
final createAnnouncementProvider = FutureProvider.family
    .autoDispose<Announcement, Announcement>((ref, announcement) async {
      final repo = ref.watch(announcementRepositoryProvider);
      final saved = await repo.createAnnouncement(announcement);
      ref.invalidate(announcementsProvider);
      return saved;
    });

/// Marks a single announcement as read by [announcementId] (the current user).
final markAnnouncementAsReadProvider = FutureProvider.family
    .autoDispose<void, String>((ref, announcementId) async {
      final controller = ref.read(announcementControllerProvider.notifier);
      await controller.markRead(announcementId);
    });

final inAppNotificationsProvider =
    FutureProvider.autoDispose<List<InAppNotification>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const [];

      final repo = ref.watch(notificationRepositoryProvider);
      return repo.getInbox(user.uid);
    });

final unreadInAppNotificationsCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadCount(user.uid);
});

final markInAppNotificationReadProvider = FutureProvider.family
    .autoDispose<void, String>((ref, notificationId) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return;

      final repo = ref.watch(notificationRepositoryProvider);
      await repo.markRead(notificationId, user.uid);
      ref.invalidate(inAppNotificationsProvider);
      ref.invalidate(unreadInAppNotificationsCountProvider);
    });

final markAllInAppNotificationsReadProvider = FutureProvider.autoDispose<void>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final repo = ref.watch(notificationRepositoryProvider);
  await repo.markAllRead(user.uid);
  ref.invalidate(inAppNotificationsProvider);
  ref.invalidate(unreadInAppNotificationsCountProvider);
});
