import '../models/in_app_notification.dart';

abstract class NotificationRepository {
  Future<List<InAppNotification>> getInbox(String userId);

  Future<int> getUnreadCount(String userId);

  Future<InAppNotification> createNotification(InAppNotification notification);

  Future<void> markRead(String notificationId, String userId);

  Future<void> markAllRead(String userId);
}
