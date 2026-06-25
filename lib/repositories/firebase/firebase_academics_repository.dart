import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_error.dart';
import '../../models/course.dart';
import '../../models/session.dart';
import '../../models/timetable.dart';
import '../../models/user.dart';
import '../academics_repository.dart';

/// Firestore implementation of [AcademicsRepository].
///
/// Collections:
///   `timetables/{id}`  — TimetableEntry documents
///   `sessions/{id}`    — Session documents
///   `courses/{id}`     — Course documents
class FirebaseAcademicsRepository implements AcademicsRepository {
  FirebaseAcademicsRepository({required FirebaseFirestore firestore})
    : _db = firestore;

  final FirebaseFirestore _db;

  // ── Timetable ─────────────────────────────────────────────────────────────

  @override
  Future<List<TimetableEntry>> getTodaySchedule(
    String userId,
    UserRole role,
  ) async {
    final allEntries = await _queryTimetable(userId, role);
    return allEntries.where((e) => e.isToday()).toList();
  }

  @override
  Future<List<TimetableEntry>> getWeekSchedule(
    String userId,
    UserRole role,
  ) async {
    return _queryTimetable(userId, role);
  }

  Future<List<TimetableEntry>> _queryTimetable(
    String userId,
    UserRole role,
  ) async {
    try {
      Query<Map<String, dynamic>> query = _db.collection('timetables');

      if (role == UserRole.teacher) {
        query = query.where('teacherId', isEqualTo: userId);
      } else {
        query = query.where('studentIds', arrayContains: userId);
      }

      final snap = await query.get();
      return snap.docs
          .map((d) => TimetableEntry.fromMap(_withId(d.id, d.data())))
          .toList();
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  // ── Courses ──────────────────────────────────────────────────────────────

  @override
  Future<List<Course>> getCoursesForUser(String userId, UserRole role) async {
    try {
      if (role == UserRole.teacher) {
        final teacherSnap = await _db
            .collection('courses')
            .where('teacherId', isEqualTo: userId)
            .get();
        return teacherSnap.docs
            .map((d) => Course.fromMap(_withId(d.id, d.data())))
            .toList();
      }

      final studentSnap = await _db
          .collection('courses')
          .where('enrolledStudentIds', arrayContains: userId)
          .get();
      return studentSnap.docs
          .map((d) => Course.fromMap(_withId(d.id, d.data())))
          .toList();
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  // ── Sessions ─────────────────────────────────────────────────────────────

  @override
  Future<List<Session>> getSessionsForTeacher(
    String teacherId, {
    DateTime? date,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db
          .collection('sessions')
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true);

      if (date != null) {
        final start = DateTime(date.year, date.month, date.day);
        final end = start.add(const Duration(days: 1));
        query = query
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start),
            )
            .where('createdAt', isLessThan: Timestamp.fromDate(end));
      }

      final snap = await query.limit(100).get();
      return snap.docs
          .map((d) => Session.fromMap(_withId(d.id, d.data())))
          .toList();
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<Session> createSession(Session session) async {
    try {
      // Conflict check: live session for same timetable entry today.
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = start.add(const Duration(days: 1));

      final conflict = await _db
          .collection('sessions')
          .where('timetableId', isEqualTo: session.timetableId)
          .where('state', isEqualTo: 'live')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .limit(1)
          .get();

      if (conflict.docs.isNotEmpty) {
        throw const ConflictError(
          detail: 'A live session already exists for this class today.',
        );
      }

      final ref = _db.collection('sessions').doc();
      final map = session.toMap()
        ..['id'] = ref.id
        ..['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(map);
      final snap = await ref.get();
      return Session.fromMap(_withId(snap.id, snap.data()!));
    } on ConflictError {
      rethrow;
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<Session> updateSessionState(
    String sessionId,
    SessionState newState,
  ) async {
    try {
      await _db.collection('sessions').doc(sessionId).update({
        'state': newState.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final snap = await _db.collection('sessions').doc(sessionId).get();
      return Session.fromMap(_withId(snap.id, snap.data()!));
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  static Map<String, dynamic> _withId(String id, Map<String, dynamic> source) {
    final data = Map<String, dynamic>.from(source)..['id'] = id;
    for (final entry in data.entries.toList()) {
      if (entry.value is Timestamp) {
        data[entry.key] = (entry.value as Timestamp).toDate().toIso8601String();
      }
    }
    return data;
  }
}
