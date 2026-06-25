import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_error.dart';
import '../../models/in_app_notification.dart';
import '../notification_repository.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository({required FirebaseFirestore firestore})
    : _db = firestore;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('notifications');

  @override
  Future<List<InAppNotification>> getInbox(String userId) async {
    try {
      final snap = await _col
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return snap.docs.map((doc) => _fromDoc(doc)).toList();
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final snap = await _col
          .where('recipientId', isEqualTo: userId)
          .where('readAt', isNull: true)
          .count()
          .get();
      return snap.count ?? 0;
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<InAppNotification> createNotification(
    InAppNotification notification,
  ) async {
    try {
      final ref = _col.doc();
      final map = notification.copyWith(id: ref.id).toMap()
        ..['createdAt'] = Timestamp.fromDate(notification.createdAt);
      await ref.set(map);
      final snap = await ref.get();
      return _fromDoc(snap);
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<void> markRead(String notificationId, String userId) async {
    try {
      await _col.doc(notificationId).update({
        'readAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<void> markAllRead(String userId) async {
    final unread = await _col
        .where('recipientId', isEqualTo: userId)
        .where('readAt', isNull: true)
        .limit(100)
        .get();

    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'readAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }

  static InAppNotification _fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return InAppNotification.fromMap({
      ...data,
      'id': doc.id,
      'createdAt': _dateString(data['createdAt']),
      'readAt': _dateString(data['readAt']),
    });
  }

  static String? _dateString(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is String) return value;
    return null;
  }
}
