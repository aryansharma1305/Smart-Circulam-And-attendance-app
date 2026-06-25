import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../core/app_error.dart';
import '../../models/attendance_exception.dart';
import '../exception_repository.dart';

/// Firestore implementation of [ExceptionRepository].
///
/// Collection: `attendance_exceptions/{id}`
class FirebaseExceptionRepository implements ExceptionRepository {
  FirebaseExceptionRepository({
    required FirebaseFirestore firestore,
    FirebaseFunctions? functions,
  }) : _db = firestore,
       _functions = functions;

  final FirebaseFirestore _db;
  final FirebaseFunctions? _functions;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('attendance_exceptions');

  // ── Reads ────────────────────────────────────────────────────────────────

  @override
  Future<List<AttendanceException>> getExceptionsForTeacher(
    String teacherId,
  ) async {
    try {
      final snap = await _col
          .where('teacher_id', isEqualTo: teacherId)
          .orderBy('requested_at', descending: true)
          .get();
      return snap.docs
          .map((d) => AttendanceException.fromMap(d.data()..['id'] = d.id))
          .toList();
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<List<AttendanceException>> getExceptionsForStudent(
    String studentId,
  ) async {
    try {
      final snap = await _col
          .where('student_id', isEqualTo: studentId)
          .orderBy('requested_at', descending: true)
          .get();
      return snap.docs
          .map((d) => AttendanceException.fromMap(d.data()..['id'] = d.id))
          .toList();
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<int> getPendingCount(String teacherId) async {
    try {
      final snap = await _col
          .where('teacher_id', isEqualTo: teacherId)
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      return snap.count ?? 0;
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  // ── Writes ───────────────────────────────────────────────────────────────

  @override
  Future<AttendanceException> submitException(
    AttendanceException exception,
  ) async {
    try {
      // Check for existing pending/under-review exception for the same pair.
      final existing = await _col
          .where('session_id', isEqualTo: exception.sessionId)
          .where('student_id', isEqualTo: exception.studentId)
          .where('status', whereIn: ['pending', 'underReview'])
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw const ConflictError(
          detail: 'A pending exception already exists for this session.',
        );
      }

      final ref = _col.doc();
      final saved = exception.copyWith(id: ref.id);
      final map = saved.toMap()
        ..['id'] = ref.id
        ..removeWhere((_, value) => value == null);
      await ref.set(map);
      return AttendanceException.fromMap(map);
    } on ConflictError {
      rethrow;
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }

  @override
  Future<AttendanceException> reviewException(
    String id,
    ExceptionStatus status, {
    String? comments,
    String? reviewerId,
  }) async {
    try {
      if (_functions != null) {
        final callable = _functions.httpsCallable('reviewAttendanceException');
        final result = await callable.call<Map<String, dynamic>>({
          'exceptionId': id,
          'status': status.name,
          if (comments != null) 'comments': comments,
        });
        final exceptionData = Map<String, dynamic>.from(
          result.data['exception'] as Map,
        )..['id'] = id;
        return AttendanceException.fromMap(exceptionData);
      }

      final ref = _col.doc(id);

      // Only update the review-related fields — security rules enforce this.
      await ref.update({
        'status': status.name,
        'reviewed_at': FieldValue.serverTimestamp(),
        if (reviewerId != null) 'reviewed_by': reviewerId,
        if (comments != null) 'reviewer_comments': comments,
      });

      final snap = await ref.get();
      return AttendanceException.fromMap(snap.data()!..['id'] = snap.id);
    } on FirebaseException catch (e) {
      throw NetworkError(detail: e.message ?? e.code);
    }
  }
}
