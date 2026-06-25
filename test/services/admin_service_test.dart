import 'package:flutter_test/flutter_test.dart';
import 'package:management_app/services/admin_service.dart';

void main() {
  test('bulk import reports row-level validation errors', () async {
    final service = AdminService();
    final rows = await service.previewBulkImport(
      'name,email,role\nAlice,not-an-email,owner',
    );
    expect(rows.single['_status'], 'invalid');
    expect(rows.single['_errors'], contains('invalid email'));
    expect(rows.single['_errors'], contains('role must be'));
  });

  test('bulk import commit is idempotent by email', () async {
    final service = AdminService();
    final rows = await service.previewBulkImport(
      'name,email,role\nPhase Four,phase4-${DateTime.now().microsecondsSinceEpoch}@test.edu,student',
    );
    await service.commitBulkImport(rows);
    final second = await service.previewBulkImport(
      'name,email,role\nPhase Four,${rows.single['email']},student',
    );
    expect(second.single['_status'], 'invalid');
    expect(second.single['_errors'], contains('already imported'));
  });
}
