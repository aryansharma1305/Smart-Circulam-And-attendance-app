import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/admin_provider.dart';

class BulkImportPage extends ConsumerStatefulWidget {
  const BulkImportPage({super.key});

  @override
  ConsumerState<BulkImportPage> createState() => _BulkImportPageState();
}

class _BulkImportPageState extends ConsumerState<BulkImportPage> {
  final TextEditingController _csvController = TextEditingController(
    text:
        'name,email,role\nAlice,alice@demo.edu,student\nBob,bob@demo.edu,teacher',
  );
  List<Map<String, String>> _previewRows = const [];
  bool _isPreviewing = false;
  bool _isCommitting = false;

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Import'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _csvController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Paste CSV (name,email,role,...)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isPreviewing
                      ? null
                      : () async {
                          setState(() => _isPreviewing = true);
                          final rows = await ref
                              .read(adminServiceProvider)
                              .previewBulkImport(_csvController.text);
                          setState(() {
                            _previewRows = rows;
                            _isPreviewing = false;
                          });
                        },
                  child: const Text('Preview'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _previewRows.isEmpty || _isCommitting
                      ? null
                      : () async {
                          setState(() => _isCommitting = true);
                          await ref
                              .read(adminServiceProvider)
                              .commitBulkImport(_previewRows);
                          setState(() => _isCommitting = false);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Import committed')),
                          );
                        },
                  child: const Text('Commit'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _previewRows.isEmpty
                  ? const Center(child: Text('No preview yet'))
                  : ListView.builder(
                      itemCount: _previewRows.length,
                      itemBuilder: (context, index) {
                        final row = _previewRows[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(row['name'] ?? ''),
                          subtitle: Text(
                            '${row['email'] ?? ''} • ${row['role'] ?? ''}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
