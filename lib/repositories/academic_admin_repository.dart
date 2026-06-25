import '../models/academic_models.dart';

abstract class AcademicAdminRepository {
  Future<AcademicCatalog> getCatalog(String institutionId);

  Future<void> saveDepartment(Department value);
  Future<void> saveTerm(AcademicTerm value);
  Future<void> saveSubject(Subject value);
  Future<void> saveSection(AcademicSection value);
  Future<void> saveRoom(AcademicRoom value);
  Future<void> saveEnrollment(Enrollment value);
  Future<void> saveAssignment(TeachingAssignment value);
  Future<void> saveTimetableSlot(AcademicTimetableSlot value);

  Future<void> deleteRecord(String collection, String id);
}
