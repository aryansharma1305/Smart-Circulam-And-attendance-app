import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/admin_provider.dart';

class TimetableAdminPage extends ConsumerWidget {
  const TimetableAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetableAsync = ref.watch(globalTimetableProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Timetable'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: timetableAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rows) => ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final r = rows[index];
            return ListTile(
              leading: const Icon(Icons.schedule),
              title: Text('${r['course']} • ${r['weekday']}'),
              subtitle: Text(
                '${r['teacher']} • ${r['room']} • ${r['start']}-${r['end']}',
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref.read(adminServiceProvider).addGlobalTimetableEntry({
            'course': 'Mathematics',
            'teacher': 'Prof. Rao',
            'room': 'B110',
            'weekday': 'Wednesday',
            'start': '12:00',
            'end': '12:50',
          });
          ref.invalidate(globalTimetableProvider);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
