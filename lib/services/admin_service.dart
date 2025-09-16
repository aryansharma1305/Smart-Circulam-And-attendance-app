import 'dart:async';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  Map<String, dynamic> _instituteSettings = {
    'name': 'Demo Institute',
    'code': 'DEMO123',
    'city': 'Mumbai',
    'timezone': 'Asia/Kolkata',
    'currency': 'INR',
    'phone': '+91 99999 99999',
    'email': 'info@demo.edu',
    'website': 'https://demo.edu',
  };

  final List<Map<String, dynamic>> _auditLogs = [];
  final StreamController<List<Map<String, dynamic>>> _auditStreamCtrl =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  // Timetable entries across institute
  final List<Map<String, dynamic>> _globalTimetable = [
    {
      'course': 'DBMS',
      'teacher': 'Prof. Sharma',
      'room': 'B205',
      'weekday': 'Monday',
      'start': '10:00',
      'end': '10:50',
    },
    {
      'course': 'OS',
      'teacher': 'Prof. Iyer',
      'room': 'B210',
      'weekday': 'Tuesday',
      'start': '11:00',
      'end': '11:50',
    },
  ];

  // Compliance stats demo
  Map<String, dynamic> _complianceStats = {
    'overallAttendance': 86,
    'lateMarks': 7,
    'exceptionsPending': 12,
    'sessionsToday': 124,
  };

  Future<Map<String, dynamic>> getInstituteSettings() async {
    return _instituteSettings;
  }

  Future<void> saveInstituteSettings(Map<String, dynamic> settings) async {
    _instituteSettings = {..._instituteSettings, ...settings};
    addAuditLog('Institute settings updated');
  }

  Stream<List<Map<String, dynamic>>> watchAuditLogs() => _auditStreamCtrl.stream;

  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    return List<Map<String, dynamic>>.from(_auditLogs.reversed);
  }

  void addAuditLog(String message) {
    final log = {
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'actor': 'admin_demo',
      'level': 'INFO',
    };
    _auditLogs.add(log);
    _auditStreamCtrl.add(List<Map<String, dynamic>>.from(_auditLogs.reversed));
  }

  Future<Map<String, dynamic>> getComplianceStats() async {
    return _complianceStats;
  }

  Future<void> refreshComplianceStats() async {
    // Simulate slight variation
    _complianceStats = {
      ..._complianceStats,
      'overallAttendance': _complianceStats['overallAttendance'],
    };
    addAuditLog('Compliance stats refreshed');
  }

  Future<List<Map<String, dynamic>>> getGlobalTimetable() async {
    return List<Map<String, dynamic>>.from(_globalTimetable);
  }

  Future<void> addGlobalTimetableEntry(Map<String, dynamic> entry) async {
    _globalTimetable.add(entry);
    addAuditLog('Timetable entry added: ${entry['course']}');
  }

  // Bulk import (demo): parse CSV-like text
  Future<List<Map<String, String>>> previewBulkImport(String csvText) async {
    final lines = csvText.trim().split(RegExp(r'\r?\n'));
    if (lines.isEmpty) return [];
    final headers = lines.first.split(',').map((s) => s.trim()).toList();
    final rows = <Map<String, String>>[];
    for (var i = 1; i < lines.length; i++) {
      final values = lines[i].split(',').map((s) => s.trim()).toList();
      final row = <String, String>{};
      for (var j = 0; j < headers.length && j < values.length; j++) {
        row[headers[j]] = values[j];
      }
      rows.add(row);
    }
    return rows;
  }

  Future<void> commitBulkImport(List<Map<String, String>> rows) async {
    // Demo: just log the import
    addAuditLog('Bulk import committed: ${rows.length} rows');
  }

  void dispose() {
    _auditStreamCtrl.close();
  }
}


