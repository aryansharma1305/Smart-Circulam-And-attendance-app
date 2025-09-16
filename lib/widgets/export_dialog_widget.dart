import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class ExportDialogWidget extends StatelessWidget {
  final Function(ExportFormat) onExport;

  const ExportDialogWidget({
    super.key,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Attendance Report'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose the format for your attendance report:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildExportOption(
            context,
            ExportFormat.detailed,
            'Detailed Report',
            'Complete attendance records with all details',
            Icons.list_alt,
          ),
          const SizedBox(height: 12),
          _buildExportOption(
            context,
            ExportFormat.summary,
            'Summary Report',
            'Session-wise attendance summary',
            Icons.summarize,
          ),
          const SizedBox(height: 12),
          _buildExportOption(
            context,
            ExportFormat.studentWise,
            'Student-wise Report',
            'Individual student attendance statistics',
            Icons.person,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    ExportFormat format,
    String title,
    String description,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onExport(format);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
