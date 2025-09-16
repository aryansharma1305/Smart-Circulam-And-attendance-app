import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/admin_provider.dart';

class AuditLogsPage extends ConsumerWidget {
  const AuditLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) => ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final log = logs[index];
            return ListTile(
              leading: const Icon(Icons.event_note),
              title: Text(log['message'] ?? ''),
              subtitle: Text('${log['actor']} • ${log['timestamp']}'),
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: logs.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(adminServiceProvider).addAuditLog('Manual log added');
          ref.invalidate(auditLogsProvider);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
