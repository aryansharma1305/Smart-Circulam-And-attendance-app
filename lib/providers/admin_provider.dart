import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

final instituteSettingsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final svc = ref.watch(adminServiceProvider);
  return svc.getInstituteSettings();
});

final complianceStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final svc = ref.watch(adminServiceProvider);
  return svc.getComplianceStats();
});

final auditLogsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final svc = ref.watch(adminServiceProvider);
  return svc.getAuditLogs();
});

final globalTimetableProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final svc = ref.watch(adminServiceProvider);
  return svc.getGlobalTimetable();
});

final previewBulkImportProvider =
    FutureProvider.family<List<Map<String, String>>, String>((ref, csv) async {
      final svc = ref.watch(adminServiceProvider);
      return svc.previewBulkImport(csv);
    });
