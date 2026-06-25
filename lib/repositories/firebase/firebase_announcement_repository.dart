import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_error.dart';
import '../../models/announcement.dart';
import '../../models/user.dart';
import '../announcement_repository.dart';

/// Firestore implementation of [AnnouncementRepository].
///
/// Collection: `announcements/{id}`
class FirebaseAnnouncementRepository implements AnnouncementRepository {
  FirebaseAnnouncementRepository({required FirebaseFirestore firestore})
    : _db = firestore;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('announcements');

  // ── Reads ────────────────────────────────────────────────────────────────

  @override
  Future<List<Announcement>> getAnnouncementsForUser(
    String userId,
    UserRole role,
    String institutionId,
  ) async {
    try {
      Query<Map<String, dynamic>> query;

      if (role == UserRole.teacher || role == UserRole.admin) {
        // Teachers see announcements they created.
        query = _col
            .where('institutionId', isEqualTo: institutionId)
            .where('senderId', isEqualTo: userId)
            .orderBy('createdAt', descending: true);
      } else {
        // Students see announcements where targetSections contains their
        // section, or global announcements (targetSections == []).
        // We use two queries and merge them.
        query = _col
            .where('institutionId', isEqualTo: institutionId)
            .where('isGlobal', isEqualTo: true)
            .orderBy('createdAt', descending: true);
      }

      final snap = await query.limit(50).get();
      return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final snap = await _col
          .where('readBy', whereNotIn: [userId])
          .count()
          .get();
      return snap.count ?? 0;
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  // ── Writes ───────────────────────────────────────────────────────────────

  @override
  Future<Announcement> createAnnouncement(Announcement announcement) async {
    try {
      final ref = _col.doc();
      final map = _toMap(announcement)
        ..['id'] = ref.id
        ..['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(map);
      // Re-read to get server timestamp.
      final snap = await ref.get();
      return _fromMap(snap.id, snap.data()!);
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<void> markRead(String announcementId, String userId) async {
    try {
      await _col.doc(announcementId).update({
        'readBy': FieldValue.arrayUnion([userId]),
      });
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _col.doc(announcementId).delete();
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  // ── Serialisation ────────────────────────────────────────────────────────

  static Announcement _fromMap(String id, Map<String, dynamic> d) =>
      Announcement(
        id: id,
        institutionId: d['institutionId'] as String? ?? '',
        course: d['course'] as String? ?? '',
        section: d['section'] as String? ?? '',
        title: d['title'] as String? ?? '',
        message: d['message'] as String? ?? '',
        sentAt: d['sentAt'] is Timestamp
            ? (d['sentAt'] as Timestamp).toDate()
            : DateTime.now(),
        senderId: d['senderId'] as String? ?? '',
        senderName: d['senderName'] as String? ?? '',
        isScheduled: d['isScheduled'] as bool? ?? false,
        attachment: d['attachment'] as String?,
        readBy: List<String>.from(d['readBy'] ?? []),
      );

  static Map<String, dynamic> _toMap(Announcement a) => {
    'course': a.course,
    'institutionId': a.institutionId,
    'section': a.section,
    'title': a.title,
    'message': a.message,
    'sentAt': Timestamp.fromDate(a.sentAt),
    'senderId': a.senderId,
    'senderName': a.senderName,
    'isScheduled': a.isScheduled,
    'attachment': a.attachment,
    'readBy': a.readBy,
    'isGlobal': a.course.isEmpty && a.section.isEmpty,
  };
}
