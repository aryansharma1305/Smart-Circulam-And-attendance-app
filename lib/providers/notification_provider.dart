import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';

// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider for announcements
final announcementsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final notificationService = ref.watch(notificationServiceProvider);
      return await notificationService.getAnnouncements();
    });

// Provider for unread announcements count
final unreadAnnouncementsCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final announcements = await ref.watch(announcementsProvider.future);
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  if (currentUserId == null) {
    return 0;
  }

  return announcements.where((announcement) {
    final List<dynamic> readBy = announcement['readBy'] ?? [];
    return !readBy.contains(currentUserId);
  }).length;
});

// Provider for creating a new announcement
final createAnnouncementProvider = FutureProvider.family
    .autoDispose<String, Map<String, dynamic>>((ref, announcementData) async {
      final notificationService = ref.watch(notificationServiceProvider);

      final title = announcementData['title'] as String;
      final body = announcementData['body'] as String;
      final targetUserIds = List<String>.from(
        announcementData['targetUserIds'] as List,
      );
      final senderName = announcementData['senderName'] as String;
      final courseId = announcementData['courseId'] as String?;
      final courseName = announcementData['courseName'] as String?;

      final announcementId = await notificationService
          .createAnnouncementNotification(
            title: title,
            body: body,
            targetUserIds: targetUserIds,
            senderName: senderName,
            courseId: courseId,
            courseName: courseName,
          );

      // Show a local notification
      await notificationService.showLocalNotification(title: title, body: body);

      ref.invalidate(announcementsProvider);
      ref.invalidate(unreadAnnouncementsCountProvider);

      return announcementId;
    });

// Provider for marking an announcement as read
final markAnnouncementAsReadProvider = FutureProvider.family
    .autoDispose<void, String>((ref, announcementId) async {
      final notificationService = ref.watch(notificationServiceProvider);
      await notificationService.markAnnouncementAsRead(announcementId);

      // Invalidate the announcements provider to refresh the list
      ref.invalidate(announcementsProvider);
      ref.invalidate(unreadAnnouncementsCountProvider);
    });

// Provider for scheduling class notifications
final scheduleClassNotificationProvider = FutureProvider.family
    .autoDispose<void, Map<String, dynamic>>((ref, notificationData) async {
      final notificationService = ref.watch(notificationServiceProvider);

      final title = notificationData['title'] as String;
      final body = notificationData['body'] as String;
      final scheduledTime = notificationData['scheduledTime'] as DateTime;
      final id = notificationData['id'] as int? ?? 0;

      await notificationService.scheduleClassNotification(
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        id: id,
      );
    });
