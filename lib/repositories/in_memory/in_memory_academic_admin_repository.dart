import '../../core/app_error.dart';
import '../../models/academic_models.dart';
import '../academic_admin_repository.dart';

class InMemoryAcademicAdminRepository implements AcademicAdminRepository {
  final Map<String, Department> _departments = {};
  final Map<String, AcademicTerm> _terms = {};
  final Map<String, Subject> _subjects = {};
  final Map<String, AcademicSection> _sections = {};
  final Map<String, AcademicRoom> _rooms = {};
  final Map<String, Enrollment> _enrollments = {};
  final Map<String, TeachingAssignment> _assignments = {};
  final Map<String, AcademicTimetableSlot> _timetable = {};

  @override
  Future<AcademicCatalog> getCatalog(String institutionId) async =>
      AcademicCatalog(
        departments: _departments.values
            .where((e) => e.institutionId == institutionId)
            .toList(),
        terms: _terms.values
            .where((e) => e.institutionId == institutionId)
            .toList(),
        subjects: _subjects.values
            .where((e) => e.institutionId == institutionId)
            .toList(),
        sections: _sections.values
            .where((e) => e.institutionId == institutionId)
            .toList(),
        rooms: _rooms.values
            .where((e) => e.institutionId == institutionId)
            .toList(),
        enrollments: _enrollments.values
            .where((e) => e.institutionId == institutionId)
            .toList(),
        assignments: _assignments.values
            .where((e) => e.institutionId == institutionId)
            .toList(),
        timetable: _timetable.values
            .where((e) => e.institutionId == institutionId)
            .toList(),
      );

  @override
  Future<void> saveDepartment(Department value) async {
    _requireUnique(
      _departments.values,
      value.id,
      value.institutionId,
      value.code,
      (e) => e.code,
      'Department code',
    );
    _departments[value.id] = value;
  }

  @override
  Future<void> saveTerm(AcademicTerm value) async {
    if (!value.endsAt.isAfter(value.startsAt)) {
      throw const ValidationError(
        fields: {'endsAt': 'Term must end after it starts.'},
      );
    }
    _terms[value.id] = value;
  }

  @override
  Future<void> saveSubject(Subject value) async {
    _requireUnique(
      _subjects.values,
      value.id,
      value.institutionId,
      value.code,
      (e) => e.code,
      'Subject code',
    );
    _subjects[value.id] = value;
  }

  @override
  Future<void> saveSection(AcademicSection value) async {
    _sections[value.id] = value;
  }

  @override
  Future<void> saveRoom(AcademicRoom value) async {
    _requireUnique(
      _rooms.values,
      value.id,
      value.institutionId,
      value.code,
      (e) => e.code,
      'Room code',
    );
    _rooms[value.id] = value;
  }

  @override
  Future<void> saveEnrollment(Enrollment value) async {
    final duplicate = _enrollments.values.any(
      (e) => e.id != value.id && e.logicalKey == value.logicalKey,
    );
    if (duplicate) {
      throw const ConflictError(detail: 'Enrollment already exists.');
    }
    _enrollments[value.id] = value;
  }

  @override
  Future<void> saveAssignment(TeachingAssignment value) async {
    _assignments[value.id] = value;
  }

  @override
  Future<void> saveTimetableSlot(AcademicTimetableSlot value) async {
    if (value.weekday < 1 ||
        value.weekday > 7 ||
        value.startMinute < 0 ||
        value.endMinute > 1440 ||
        value.startMinute >= value.endMinute) {
      throw const ValidationError(
        fields: {'time': 'Provide a valid weekday and time range.'},
      );
    }

    for (final other in _timetable.values) {
      if (other.id == value.id ||
          other.termId != value.termId ||
          other.status != RecordStatus.active ||
          !value.overlaps(other)) {
        continue;
      }
      if (other.teacherId == value.teacherId ||
          other.roomId == value.roomId ||
          other.sectionId == value.sectionId) {
        throw const ConflictError(
          detail: 'Teacher, room, or section has a timetable collision.',
        );
      }
    }
    _timetable[value.id] = value;
  }

  @override
  Future<void> deleteRecord(String collection, String id) async {
    switch (collection) {
      case 'departments':
        _departments.remove(id);
      case 'terms':
        _terms.remove(id);
      case 'subjects':
        _subjects.remove(id);
      case 'sections':
        _sections.remove(id);
      case 'rooms':
        _rooms.remove(id);
      case 'enrollments':
        _enrollments.remove(id);
      case 'teaching_assignments':
        _assignments.remove(id);
      case 'academic_timetable':
        _timetable.remove(id);
      default:
        throw ValidationError(fields: {'collection': collection});
    }
  }

  void _requireUnique<T extends AcademicRecord>(
    Iterable<T> records,
    String id,
    String institutionId,
    String value,
    String Function(T) select,
    String label,
  ) {
    if (value.trim().isEmpty) {
      throw ValidationError(fields: {'code': '$label is required.'});
    }
    if (records.any(
      (e) =>
          e.id != id &&
          e.institutionId == institutionId &&
          select(e).toLowerCase() == value.toLowerCase(),
    )) {
      throw ConflictError(detail: '$label already exists.');
    }
  }
}
