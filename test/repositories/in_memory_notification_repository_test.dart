import 'package:flutter_test/flutter_test.dart';
import 'package:management_app/models/in_app_notification.dart';
import 'package:management_app/repositories/in_memory/in_memory_notification_repository.dart';

void main() {
  group('InMemoryNotificationRepository', () {
    late InMemoryNotificationRepository repository;

    setUp(() {
      repository = InMemoryNotificationRepository();
    });

    test('returns inbox newest first for a user', () async {
      final inbox = await repository.getInbox('student-001');

      expect(inbox, isNotEmpty);
      expect(inbox.first.createdAt.isAfter(inbox.last.createdAt), isTrue);
    });

    test('creates notifications and counts unread items', () async {
      final before = await repository.getUnreadCount('student-002');

      await repository.createNotification(
        InAppNotification(
          id: '',
          institutionId: 'demo-inst',
          recipientId: 'student-002',
          title: 'New update',
          message: 'A new notification is available.',
          type: InAppNotificationType.system,
          createdAt: DateTime.now(),
        ),
      );

      final after = await repository.getUnreadCount('student-002');
      expect(after, before + 1);
    });

    test('markRead is idempotent and scoped to recipient', () async {
      final inbox = await repository.getInbox('student-001');
      final unread = inbox.firstWhere((notification) => !notification.isRead);

      await repository.markRead(unread.id, 'other-user');
      expect(await repository.getUnreadCount('student-001'), 1);

      await repository.markRead(unread.id, 'student-001');
      await repository.markRead(unread.id, 'student-001');

      expect(await repository.getUnreadCount('student-001'), 0);
    });
  });
}
