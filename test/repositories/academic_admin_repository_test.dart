import 'package:flutter_test/flutter_test.dart';
import 'package:management_app/core/app_error.dart';
import 'package:management_app/models/academic_models.dart';
import 'package:management_app/repositories/in_memory/in_memory_academic_admin_repository.dart';

void main() {
  const institutionId = 'inst-1';
  late InMemoryAcademicAdminRepository repository;
  late DateTime now;

  setUp(() {
    repository = InMemoryAcademicAdminRepository();
    now = DateTime(2026, 1, 1);
  });

  AcademicTimetableSlot slot({
    required String id,
    String teacherId = 'teacher-1',
    String roomId = 'room-1',
    String sectionId = 'section-1',
    int start = 600,
    int end = 660,
  }) => AcademicTimetableSlot(
    id: id,
    institutionId: institutionId,
    termId: 'term-1',
    sectionId: sectionId,
    subjectId: 'subject-1',
    teacherId: teacherId,
    roomId: roomId,
    weekday: 1,
    startMinute: start,
    endMinute: end,
    status: RecordStatus.active,
    createdAt: now,
    updatedAt: now,
  );

  test('catalog is institution scoped', () async {
    await repository.saveDepartment(
      Department(
        id: 'd1',
        institutionId: institutionId,
        code: 'CSE',
        name: 'Computer Science',
        status: RecordStatus.active,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final catalog = await repository.getCatalog(institutionId);
    expect(catalog.departments.single.code, 'CSE');
    expect((await repository.getCatalog('other')).departments, isEmpty);
  });

  test('duplicate enrollment is rejected idempotently', () async {
    Enrollment enrollment(String id) => Enrollment(
      id: id,
      institutionId: institutionId,
      studentId: 'student-1',
      sectionId: 'section-1',
      subjectId: 'subject-1',
      termId: 'term-1',
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    await repository.saveEnrollment(enrollment('e1'));
    expect(
      () => repository.saveEnrollment(enrollment('e2')),
      throwsA(isA<ConflictError>()),
    );
  });

  test('teacher timetable collision is rejected', () async {
    await repository.saveTimetableSlot(slot(id: 'one'));
    expect(
      () => repository.saveTimetableSlot(
        slot(
          id: 'two',
          roomId: 'room-2',
          sectionId: 'section-2',
          start: 630,
          end: 690,
        ),
      ),
      throwsA(isA<ConflictError>()),
    );
  });

  test('non-overlapping timetable slots are accepted', () async {
    await repository.saveTimetableSlot(slot(id: 'one'));
    await repository.saveTimetableSlot(slot(id: 'two', start: 660, end: 720));
    expect(
      (await repository.getCatalog(institutionId)).timetable,
      hasLength(2),
    );
  });
}
