import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../controllers/academic_admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/academic_models.dart';

class AcademicManagementPage extends ConsumerWidget {
  const AcademicManagementPage({super.key});

  static const _fallbackInstitutionId = String.fromEnvironment(
    'INSTITUTION_ID',
    defaultValue: 'demo-institution',
  );

  String _institutionId(WidgetRef ref) =>
      ref.read(currentUserProvider)?.institutionId ?? _fallbackInstitutionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(academicAdminControllerProvider);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Academic Setup'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Structure'),
              Tab(text: 'Terms'),
              Tab(text: 'Timetable'),
              Tab(text: 'Enrollments'),
            ],
          ),
        ),
        body: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(
            error: error,
            retry: () =>
                ref.read(academicAdminControllerProvider.notifier).reload(),
          ),
          data: (catalog) => TabBarView(
            children: [
              _structure(context, ref, catalog),
              _terms(context, ref, catalog),
              _timetable(context, ref, catalog),
              _enrollments(context, ref, catalog),
            ],
          ),
        ),
      ),
    );
  }

  Widget _structure(
    BuildContext context,
    WidgetRef ref,
    AcademicCatalog catalog,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(
          context,
          'Departments',
          () => _addDepartment(context, ref),
        ),
        ...catalog.departments.map(
          (item) => ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: Text('${item.code} · ${item.name}'),
            trailing: _delete(ref, 'departments', item.id),
          ),
        ),
        _sectionHeader(context, 'Subjects', () => _addSubject(context, ref)),
        ...catalog.subjects.map(
          (item) => ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text('${item.code} · ${item.name}'),
            subtitle: Text('${item.creditHours} credit hours'),
            trailing: _delete(ref, 'subjects', item.id),
          ),
        ),
        _sectionHeader(context, 'Sections', () => _addSection(context, ref)),
        ...catalog.sections.map(
          (item) => ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: Text(item.name),
            subtitle: Text('Year ${item.year} · Term ${item.termId}'),
            trailing: _delete(ref, 'sections', item.id),
          ),
        ),
        _sectionHeader(context, 'Rooms', () => _addRoom(context, ref)),
        ...catalog.rooms.map(
          (item) => ListTile(
            leading: const Icon(Icons.meeting_room_outlined),
            title: Text(item.code),
            subtitle: Text('${item.building} · Capacity ${item.capacity}'),
            trailing: _delete(ref, 'rooms', item.id),
          ),
        ),
      ],
    );
  }

  Widget _terms(BuildContext context, WidgetRef ref, AcademicCatalog catalog) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(context, 'Academic Terms', () => _addTerm(context, ref)),
        ...catalog.terms.map(
          (item) => Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(item.name),
              subtitle: Text(
                '${_day(item.startsAt)} – ${_day(item.endsAt)} · ${item.status.name}',
              ),
              trailing: _delete(ref, 'terms', item.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _timetable(
    BuildContext context,
    WidgetRef ref,
    AcademicCatalog catalog,
  ) {
    final slots = [...catalog.timetable]
      ..sort(
        (a, b) => a.weekday != b.weekday
            ? a.weekday.compareTo(b.weekday)
            : a.startMinute.compareTo(b.startMinute),
      );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(context, 'Timetable', () => _addSlot(context, ref)),
        const Text(
          'Conflicts are rejected when a teacher, room, or section overlaps.',
        ),
        const SizedBox(height: 12),
        ...slots.map(
          (item) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${item.weekday}')),
              title: Text('${item.subjectId} · ${item.sectionId}'),
              subtitle: Text(
                '${_time(item.startMinute)}–${_time(item.endMinute)} · ${item.roomId} · ${item.teacherId}',
              ),
              trailing: _delete(ref, 'academic_timetable', item.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _enrollments(
    BuildContext context,
    WidgetRef ref,
    AcademicCatalog catalog,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(
          context,
          'Enrollments',
          () => _addEnrollment(context, ref),
        ),
        ...catalog.enrollments.map(
          (item) => ListTile(
            leading: const Icon(Icons.school_outlined),
            title: Text(item.studentId),
            subtitle: Text(
              '${item.subjectId} · ${item.sectionId} · ${item.termId}',
            ),
            trailing: _delete(ref, 'enrollments', item.id),
          ),
        ),
        _sectionHeader(
          context,
          'Teaching Assignments',
          () => _addAssignment(context, ref),
        ),
        ...catalog.assignments.map(
          (item) => ListTile(
            leading: const Icon(Icons.assignment_ind_outlined),
            title: Text(item.teacherId),
            subtitle: Text(
              '${item.subjectId} · ${item.sectionId} · ${item.termId}',
            ),
            trailing: _delete(ref, 'teaching_assignments', item.id),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, VoidCallback add) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          IconButton(
            onPressed: add,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _delete(WidgetRef ref, String collection, String id) => IconButton(
    icon: const Icon(Icons.delete_outline),
    onPressed: () => ref
        .read(academicAdminControllerProvider.notifier)
        .deleteRecord(collection, id),
  );

  Future<Map<String, String>?> _fields(
    BuildContext context,
    String title,
    List<String> names,
  ) async {
    final controllers = {
      for (final name in names) name: TextEditingController(),
    };
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: names
                .map(
                  (name) => TextField(
                    controller: controllers[name],
                    decoration: InputDecoration(labelText: name),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, {
              for (final entry in controllers.entries)
                entry.key: entry.value.text.trim(),
            }),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addDepartment(BuildContext context, WidgetRef ref) async {
    final values = await _fields(context, 'Add department', ['Code', 'Name']);
    if (values == null) return;
    final now = DateTime.now();
    await _run(
      context,
      () => ref
          .read(academicAdminControllerProvider.notifier)
          .saveDepartment(
            Department(
              id: const Uuid().v4(),
              institutionId: _institutionId(ref),
              code: values['Code']!,
              name: values['Name']!,
              status: RecordStatus.active,
              createdAt: now,
              updatedAt: now,
            ),
          ),
    );
  }

  Future<void> _addSubject(BuildContext context, WidgetRef ref) async {
    final v = await _fields(context, 'Add subject', [
      'Code',
      'Name',
      'Department ID',
      'Credits',
    ]);
    if (v == null) return;
    final now = DateTime.now();
    await _run(
      context,
      () => ref
          .read(academicAdminControllerProvider.notifier)
          .saveSubject(
            Subject(
              id: const Uuid().v4(),
              institutionId: _institutionId(ref),
              departmentId: v['Department ID']!,
              code: v['Code']!,
              name: v['Name']!,
              creditHours: int.tryParse(v['Credits']!) ?? 0,
              status: RecordStatus.active,
              createdAt: now,
              updatedAt: now,
            ),
          ),
    );
  }

  Future<void> _addSection(BuildContext context, WidgetRef ref) async {
    final v = await _fields(context, 'Add section', [
      'Name',
      'Course ID',
      'Term ID',
      'Year',
    ]);
    if (v == null) return;
    final now = DateTime.now();
    await _run(
      context,
      () => ref
          .read(academicAdminControllerProvider.notifier)
          .saveSection(
            AcademicSection(
              id: const Uuid().v4(),
              institutionId: _institutionId(ref),
              courseId: v['Course ID']!,
              termId: v['Term ID']!,
              name: v['Name']!,
              year: int.tryParse(v['Year']!) ?? 1,
              status: RecordStatus.active,
              createdAt: now,
              updatedAt: now,
            ),
          ),
    );
  }

  Future<void> _addRoom(BuildContext context, WidgetRef ref) async {
    final v = await _fields(context, 'Add room', [
      'Code',
      'Building',
      'Capacity',
    ]);
    if (v == null) return;
    final now = DateTime.now();
    await _run(
      context,
      () => ref
          .read(academicAdminControllerProvider.notifier)
          .saveRoom(
            AcademicRoom(
              id: const Uuid().v4(),
              institutionId: _institutionId(ref),
              code: v['Code']!,
              building: v['Building']!,
              capacity: int.tryParse(v['Capacity']!) ?? 0,
              status: RecordStatus.active,
              createdAt: now,
              updatedAt: now,
            ),
          ),
    );
  }

  Future<void> _addTerm(BuildContext context, WidgetRef ref) async {
    final v = await _fields(context, 'Add term', [
      'Name',
      'Start YYYY-MM-DD',
      'End YYYY-MM-DD',
    ]);
    if (v == null) return;
    final now = DateTime.now();
    await _run(
      context,
      () => ref
          .read(academicAdminControllerProvider.notifier)
          .saveTerm(
            AcademicTerm(
              id: const Uuid().v4(),
              institutionId: _institutionId(ref),
              name: v['Name']!,
              startsAt: DateTime.parse(v['Start YYYY-MM-DD']!),
              endsAt: DateTime.parse(v['End YYYY-MM-DD']!),
              status: RecordStatus.active,
              createdAt: now,
              updatedAt: now,
            ),
          ),
    );
  }

  Future<void> _addEnrollment(BuildContext context, WidgetRef ref) async {
    final v = await _fields(context, 'Add enrollment', [
      'Student ID',
      'Section ID',
      'Subject ID',
      'Term ID',
    ]);
    if (v == null) return;
    final now = DateTime.now();
    await _run(
      context,
      () => ref
          .read(academicAdminControllerProvider.notifier)
          .saveEnrollment(
            Enrollment(
              id: const Uuid().v4(),
              institutionId: _institutionId(ref),
              studentId: v['Student ID']!,
              sectionId: v['Section ID']!,
              subjectId: v['Subject ID']!,
              termId: v['Term ID']!,
              status: RecordStatus.active,
              createdAt: now,
              updatedAt: now,
            ),
          ),
    );
  }

  Future<void> _addAssignment(BuildContext context, WidgetRef ref) async {
    final v = await _fields(context, 'Add teaching assignment', [
      'Teacher ID',
      'Section ID',
      'Subject ID',
      'Term ID',
    ]);
    if (v == null) return;
    final now = DateTime.now();
    await _run(
      context,
      () => ref
          .read(academicAdminControllerProvider.notifier)
          .saveAssignment(
            TeachingAssignment(
              id: const Uuid().v4(),
              institutionId: _institutionId(ref),
              teacherId: v['Teacher ID']!,
              sectionId: v['Section ID']!,
              subjectId: v['Subject ID']!,
              termId: v['Term ID']!,
              createdAt: now,
              updatedAt: now,
            ),
          ),
    );
  }

  Future<void> _addSlot(BuildContext context, WidgetRef ref) async {
    final v = await _fields(context, 'Add timetable slot', [
      'Term ID',
      'Section ID',
      'Subject ID',
      'Teacher ID',
      'Room ID',
      'Weekday 1-7',
      'Start minute',
      'End minute',
    ]);
    if (v == null) return;
    final now = DateTime.now();
    await _run(
      context,
      () => ref
          .read(academicAdminControllerProvider.notifier)
          .saveTimetableSlot(
            AcademicTimetableSlot(
              id: const Uuid().v4(),
              institutionId: _institutionId(ref),
              termId: v['Term ID']!,
              sectionId: v['Section ID']!,
              subjectId: v['Subject ID']!,
              teacherId: v['Teacher ID']!,
              roomId: v['Room ID']!,
              weekday: int.parse(v['Weekday 1-7']!),
              startMinute: int.parse(v['Start minute']!),
              endMinute: int.parse(v['End minute']!),
              status: RecordStatus.active,
              createdAt: now,
              updatedAt: now,
            ),
          ),
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  static String _day(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  static String _time(int minute) =>
      '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.retry});
  final Object error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$error'),
        const SizedBox(height: 12),
        FilledButton(onPressed: retry, child: const Text('Retry')),
      ],
    ),
  );
}
