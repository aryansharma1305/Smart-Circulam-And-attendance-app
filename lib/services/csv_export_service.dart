// Demo CSV Export Service
// This simulates CSV export functionality

import 'dart:convert';
import 'dart:developer' as developer;
import '../models/attendance_record.dart';

class CSVExportService {
  // Export attendance records to CSV format (demo)
  static Future<String> exportAttendanceRecords(
    List<AttendanceRecord> records,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));

    if (records.isEmpty) {
      return 'No data to export';
    }

    // CSV header
    final csvLines = <String>[
      'Student ID,Student Name,Session ID,Timestamp,Method,Status,Latitude,Longitude',
    ];

    // CSV data rows
    for (final record in records) {
      final line = [
        record.studentId,
        'Student ${record.studentId}', // Demo student name
        record.sessionId,
        record.timestamp.toIso8601String(),
        record.methodDisplayName,
        record.statusDisplayName,
        record.metadata['latitude']?.toString() ?? '0.0',
        record.metadata['longitude']?.toString() ?? '0.0',
      ].map((field) => '"$field"').join(',');

      csvLines.add(line);
    }

    final csvContent = csvLines.join('\n');
    developer.log('CSV Export: Generated CSV with ${records.length} records');

    return csvContent;
  }

  // Export class attendance summary
  static Future<String> exportClassSummary({
    required String classId,
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> summaryData,
  }) async {
    await Future.delayed(Duration(milliseconds: 400));

    final csvLines = <String>[
      'Class ID,Date Range,Total Students,Total Sessions,Average Attendance',
      '"$classId","${startDate.toIso8601String().split('T')[0]} to ${endDate.toIso8601String().split('T')[0]}","${summaryData.length}","10","85%"',
    ];

    csvLines.add(''); // Empty line
    csvLines.add(
      'Student Name,Student ID,Sessions Attended,Total Sessions,Attendance Rate',
    );

    for (final student in summaryData) {
      final line = [
        student['name'] ?? 'Unknown',
        student['id'] ?? 'N/A',
        student['attended']?.toString() ?? '0',
        student['total']?.toString() ?? '0',
        '${((student['attended'] ?? 0) / (student['total'] ?? 1) * 100).toStringAsFixed(1)}%',
      ].map((field) => '"$field"').join(',');

      csvLines.add(line);
    }

    developer.log('CSV Export: Generated class summary CSV');
    return csvLines.join('\n');
  }

  // Save CSV to demo location
  static Future<String> saveCsvFile(String csvContent, String filename) async {
    await Future.delayed(Duration(milliseconds: 300));

    // In a real app, this would save to device storage
    // For demo, we just return a simulated file path
    final demoPath = '/demo/downloads/$filename';

    developer.log(
      'CSV Export: Saved CSV file to $demoPath (${csvContent.length} characters)',
    );

    return demoPath;
  }

  // Get demo file path
  static Future<String> getExportDirectory() async {
    await Future.delayed(Duration(milliseconds: 100));
    return '/demo/downloads/';
  }

  // Demo file sharing
  static Future<void> shareCSVFile(String filePath) async {
    await Future.delayed(Duration(milliseconds: 200));
    developer.log('CSV Export: Shared file $filePath (demo)');
  }

  // Additional methods for compatibility
  static Future<String> exportAnalyticsToCSV(Map<String, dynamic> data, String format) async {
    await Future.delayed(Duration(milliseconds: 400));
    
    final csvContent = '''
Analytics Export - $format
Generated: ${DateTime.now().toIso8601String()}

Student ID,Name,Attendance Rate,Total Sessions,Present Sessions
student_1,John Doe,85%,20,17
student_2,Jane Smith,92%,20,18
student_3,Bob Johnson,78%,20,16
''';
    
    final filePath = '/demo/exports/analytics_${DateTime.now().millisecondsSinceEpoch}.csv';
    developer.log('CSV Export: Analytics exported to $filePath');
    
    return filePath;
  }

    static Future<List<Map<String, dynamic>>> getExportedFiles() async {
    await Future.delayed(Duration(milliseconds: 200));
    
    return [
      {
        'name': 'analytics_export_1.csv',
        'path': '/demo/exports/analytics_export_1.csv',
        'size': 1024,
        'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      },
      {
        'name': 'attendance_report_2.csv',
        'path': '/demo/exports/attendance_report_2.csv',
        'size': 2048,
        'date': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
      },
    ];
  }

    static String getFileSize(Map<String, dynamic> file) {
    final bytes = file['size'] ?? 0;
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

    static Future<bool> deleteExportedFile(String filePath) async {
    await Future.delayed(Duration(milliseconds: 200));
    developer.log('CSV Export: Deleted file $filePath (demo)');
    return true;
  }
