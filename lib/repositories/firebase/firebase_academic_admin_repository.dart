import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_error.dart';
import '../../models/academic_models.dart';
import '../academic_admin_repository.dart';

class FirebaseAcademicAdminRepository implements AcademicAdminRepository {
  FirebaseAcademicAdminRepository({required FirebaseFirestore firestore})
    : _db = firestore;

  final FirebaseFirestore _db;

  @override
  Future<AcademicCatalog> getCatalog(String institutionId) async {
    try {
      final results = await Future.wait([
        _query('departments', institutionId),
        _query('terms', institutionId),
        _query('subjects', institutionId),
        _query('sections', institutionId),
        _query('rooms', institutionId),
        _query('enrollments', institutionId),
        _query('teaching_assignments', institutionId),
        _query('academic_timetable', institutionId),
      ]);
      return AcademicCatalog(
        departments: results[0].map(Department.fromJson).toList(),
        terms: results[1].map(AcademicTerm.fromJson).toList(),
        subjects: results[2].map(Subject.fromJson).toList(),
        sections: results[3].map(AcademicSection.fromJson).toList(),
        rooms: results[4].map(AcademicRoom.fromJson).toList(),
        enrollments: results[5].map(Enrollment.fromJson).toList(),
        assignments: results[6].map(TeachingAssignment.fromJson).toList(),
        timetable: results[7].map(AcademicTimetableSlot.fromJson).toList(),
      );
    } on FirebaseException catch (error) {
      throw NetworkError(detail: error.message ?? error.code);
    }
  }

  Future<List<Map<String, dynamic>>> _query(
    String collection,
    String institutionId,
  ) async {
    final snapshot = await _db
        .collection(collection)
        .where('institutionId', isEqualTo: institutionId)
        .get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data())..['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _save(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collection).doc(id).set({
        ...data,
        'id': id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw NetworkError(detail: error.message ?? error.code);
    }
  }

  @override
  Future<void> saveDepartment(Department value) =>
      _save('departments', value.id, value.toJson());

  @override
  Future<void> saveTerm(AcademicTerm value) =>
      _save('terms', value.id, value.toJson());

  @override
  Future<void> saveSubject(Subject value) =>
      _save('subjects', value.id, value.toJson());

  @override
  Future<void> saveSection(AcademicSection value) =>
      _save('sections', value.id, value.toJson());

  @override
  Future<void> saveRoom(AcademicRoom value) =>
      _save('rooms', value.id, value.toJson());

  @override
  Future<void> saveEnrollment(Enrollment value) async {
    final duplicate = await _db
        .collection('enrollments')
        .where('institutionId', isEqualTo: value.institutionId)
        .where('logicalKey', isEqualTo: value.logicalKey)
        .limit(1)
        .get();
    if (duplicate.docs.any((doc) => doc.id != value.id)) {
      throw const ConflictError(detail: 'Enrollment already exists.');
    }
    await _save('enrollments', value.id, value.toJson());
  }

  @override
  Future<void> saveAssignment(TeachingAssignment value) =>
      _save('teaching_assignments', value.id, value.toJson());

  @override
  Future<void> saveTimetableSlot(AcademicTimetableSlot value) async {
    final snapshot = await _db
        .collection('academic_timetable')
        .where('institutionId', isEqualTo: value.institutionId)
        .where('termId', isEqualTo: value.termId)
        .where('weekday', isEqualTo: value.weekday)
        .get();
    final slots = snapshot.docs
        .map(
          (doc) => AcademicTimetableSlot.fromJson(
            Map<String, dynamic>.from(doc.data())..['id'] = doc.id,
          ),
        )
        .where((slot) => slot.id != value.id && value.overlaps(slot));
    if (slots.any(
      (slot) =>
          slot.teacherId == value.teacherId ||
          slot.roomId == value.roomId ||
          slot.sectionId == value.sectionId,
    )) {
      throw const ConflictError(
        detail: 'Teacher, room, or section has a timetable collision.',
      );
    }
    await _save('academic_timetable', value.id, value.toJson());
  }

  @override
  Future<void> deleteRecord(String collection, String id) async {
    const allowed = {
      'departments',
      'terms',
      'subjects',
      'sections',
      'rooms',
      'enrollments',
      'teaching_assignments',
      'academic_timetable',
    };
    if (!allowed.contains(collection)) {
      throw ValidationError(fields: {'collection': collection});
    }
    await _db.collection(collection).doc(id).delete();
  }
}
