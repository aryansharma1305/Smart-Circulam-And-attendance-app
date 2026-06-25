import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/academic_models.dart';
import '../providers/repository_providers.dart';
import '../repositories/academic_admin_repository.dart';
import 'auth_controller.dart';

class AcademicAdminController
    extends StateNotifier<AsyncValue<AcademicCatalog>> {
  AcademicAdminController(this._repository, this.institutionId)
    : super(const AsyncValue.loading()) {
    reload();
  }

  final AcademicAdminRepository _repository;
  final String institutionId;

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getCatalog(institutionId));
  }

  Future<void> saveDepartment(Department value) =>
      _mutate(() => _repository.saveDepartment(value));
  Future<void> saveTerm(AcademicTerm value) =>
      _mutate(() => _repository.saveTerm(value));
  Future<void> saveSubject(Subject value) =>
      _mutate(() => _repository.saveSubject(value));
  Future<void> saveSection(AcademicSection value) =>
      _mutate(() => _repository.saveSection(value));
  Future<void> saveRoom(AcademicRoom value) =>
      _mutate(() => _repository.saveRoom(value));
  Future<void> saveEnrollment(Enrollment value) =>
      _mutate(() => _repository.saveEnrollment(value));
  Future<void> saveAssignment(TeachingAssignment value) =>
      _mutate(() => _repository.saveAssignment(value));
  Future<void> saveTimetableSlot(AcademicTimetableSlot value) =>
      _mutate(() => _repository.saveTimetableSlot(value));
  Future<void> deleteRecord(String collection, String id) =>
      _mutate(() => _repository.deleteRecord(collection, id));

  Future<void> _mutate(Future<void> Function() operation) async {
    final previous = state;
    try {
      await operation();
      await reload();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      await Future<void>.delayed(Duration.zero);
      state = previous;
      rethrow;
    }
  }
}

final academicAdminControllerProvider =
    StateNotifierProvider.autoDispose<
      AcademicAdminController,
      AsyncValue<AcademicCatalog>
    >((ref) {
      const institutionId = String.fromEnvironment(
        'INSTITUTION_ID',
        defaultValue: 'demo-institution',
      );
      final userInstitutionId = ref.watch(currentUserProvider)?.institutionId;
      return AcademicAdminController(
        ref.watch(academicAdminRepositoryProvider),
        userInstitutionId ?? institutionId,
      );
    });
