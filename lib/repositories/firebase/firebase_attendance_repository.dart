import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_error.dart';
import '../../models/attendance.dart';
import '../attendance_repository.dart';

/// Firebase/Firestore implementation of [AttendanceRepository].
///
/// Collection path: `attendance/{sessionId}/records/{studentId}`
/// Using a subcollection per session allows Firestore security rules to scope
/// reads by session ownership without a costly collection-group query.
class FirebaseAttendanceRepository implements AttendanceRepository {
  FirebaseAttendanceRepository({required FirebaseFirestore firestore})
      : _db = firestore;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _records(String sessionId) =>
      _db.collection('attendance').doc(sessionId).collection('records');

  // ── Write ────────────────────────────────────────────────────────────────

  @override
  Future<Attendance> markAttendance(Attendance record) async {
    final ref = _records(record.sessionId).doc(record.studentId);

    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (snap.exists) {
          throw const ConflictError(
            detail: 'Attendance already marked for this session.',
          );
        }
        tx.set(ref, _toMap(record));
      });
      return record;
    } on ConflictError {
      rethrow;
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  // ── Read – student perspective ───────────────────────────────────────────

  @override
  Future<List<Attendance>> getStudentHistory(
    String studentId, {
    DateRange? range,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db
          .collectionGroup('records')
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true);

      if (range != null) {
        query = query
            .where('createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
            .where('createdAt',
                isLessThanOrEqualTo: Timestamp.fromDate(range.end));
      }

      final snap = await query.get();
      return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<double> getAttendancePercentage(
      String studentId, String courseId) async {
    try {
      final snap = await _db
          .collectionGroup('records')
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .get();

      if (snap.docs.isEmpty) return 0.0;
      final present = snap.docs
          .where((d) => d.data()['status'] == 'present')
          .length;
      return (present / snap.docs.length) * 100.0;
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<int> getStreakDays(String studentId) async {
    try {
      final snap = await _db
          .collectionGroup('records')
          .where('studentId', isEqualTo: studentId)
          .where('status', isEqualTo: 'present')
          .orderBy('createdAt', descending: true)
          .limit(60)
          .get();

      if (snap.docs.isEmpty) return 0;

      final dates = snap.docs
          .map((d) =>
              (d.data()['createdAt'] as Timestamp).toDate())
          .map((dt) => DateTime(dt.year, dt.month, dt.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      int streak = 0;
      DateTime cursor = DateTime.now();
      cursor = DateTime(cursor.year, cursor.month, cursor.day);

      for (final date in dates) {
        if (date == cursor || date == cursor.subtract(const Duration(days: 1))) {
          streak++;
          cursor = date;
        } else {
          break;
        }
      }
      return streak;
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  // ── Read – teacher perspective ───────────────────────────────────────────

  @override
  Future<List<Attendance>> getSessionRoll(String sessionId) async {
    try {
      final snap = await _records(sessionId)
          .orderBy('createdAt', descending: false)
          .get();
      return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  // ── Serialisation helpers ────────────────────────────────────────────────

  static Map<String, dynamic> _toMap(Attendance a) => {
        'sessionId': a.sessionId,
        'studentId': a.studentId,
        'status': a.status.name,
        'geoOK': a.geoOK,
        'ssidOK': a.ssidOK,
        'createdAt': Timestamp.fromDate(a.createdAt),
      };

  static Attendance _fromMap(String docId, Map<String, dynamic> d) =>
      Attendance(
        sessionId: d['sessionId'] as String? ?? '',
        studentId: d['studentId'] as String? ?? docId,
        status: AttendanceStatus.values.firstWhere(
          (s) => s.name == d['status'],
          orElse: () => AttendanceStatus.absent,
        ),
        geoOK: d['geoOK'] as bool? ?? false,
        ssidOK: d['ssidOK'] as bool? ?? false,
        createdAt: d['createdAt'] != null
            ? (d['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}
