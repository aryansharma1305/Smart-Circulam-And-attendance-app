import '../../models/in_app_notification.dart';
import '../notification_repository.dart';

class InMemoryNotificationRepository implements NotificationRepository {
  InMemoryNotificationRepository() {
    _seed();
  }

  final List<InAppNotification> _notifications = [];
  int _nextId = 100;

  void _seed() {
    final now = DateTime.now();
    _notifications.addAll([
      InAppNotification(
        id: '1',
        institutionId: 'demo-inst',
        recipientId: 'student-001',
        title: 'Attendance Marked Successfully',
        message: 'You have been marked present for Data Structures class.',
        type: InAppNotificationType.attendance,
        createdAt: now.subtract(const Duration(minutes: 5)),
        actionRoute: '/student/ledger',
      ),
      InAppNotification(
        id: '2',
        institutionId: 'demo-inst',
        recipientId: 'student-001',
        title: 'Exception Request Updated',
        message: 'Your attendance exception request has been approved.',
        type: InAppNotificationType.exception,
        createdAt: now.subtract(const Duration(hours: 1)),
        readAt: now.subtract(const Duration(minutes: 30)),
        actionRoute: '/student/ledger',
      ),
    ]);
  }

  @override
  Future<List<InAppNotification>> getInbox(String userId) async {
    return _notifications
        .where((notification) => notification.recipientId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return _notifications
        .where(
          (notification) =>
              notification.recipientId == userId && !notification.isRead,
        )
        .length;
  }

  @override
  Future<InAppNotification> createNotification(
    InAppNotification notification,
  ) async {
    final saved = notification.copyWith(id: '${_nextId++}');
    _notifications.add(saved);
    return saved;
  }

  @override
  Future<void> markRead(String notificationId, String userId) async {
    final index = _notifications.indexWhere(
      (notification) =>
          notification.id == notificationId &&
          notification.recipientId == userId,
    );
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(
      readAt: DateTime.now(),
    );
  }

  @override
  Future<void> markAllRead(String userId) async {
    final now = DateTime.now();
    for (var i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];
      if (notification.recipientId == userId && !notification.isRead) {
        _notifications[i] = notification.copyWith(readAt: now);
      }
    }
  }
}
