import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
// Demo path provider - using local directory simulation
import '../models/attendance_record.dart';
import '../models/session.dart';
import '../models/user.dart';

class SimpleStorageService {
  static const String _attendanceFile = 'attendance_records.json';
  static const String _sessionsFile = 'sessions.json';
  static const String _usersFile = 'users.json';
  static const String _pendingFile = 'pending_sync.json';
  static const String _settingsFile = 'settings.json';

  static Directory? _appDocumentsDirectory;

  /// Initialize storage
  static Future<void> initialize() async {
    // Demo: simulate app documents directory
    _appDocumentsDirectory = null; // Will use memory storage instead
  }

  /// Get file path for a given file name
  static Future<String> _getFilePath(String fileName) async {
    if (_appDocumentsDirectory == null) {
      await initialize();
    }
    return '${_appDocumentsDirectory!.path}/$fileName';
  }

  /// Write data to file
  static Future<void> _writeToFile(
    String fileName,
    Map<String, dynamic> data,
  ) async {
    final filePath = await _getFilePath(fileName);
    final file = File(filePath);
    await file.writeAsString(jsonEncode(data));
  }

  /// Read data from file
  static Future<Map<String, dynamic>> _readFromFile(String fileName) async {
    try {
      final filePath = await _getFilePath(fileName);
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error reading file $fileName: $e');
    }
    return {};
  }

  // Attendance Records
  static Future<void> saveAttendanceRecord(AttendanceRecord record) async {
    final data = await _readFromFile(_attendanceFile);
    data[record.id] = record.toMap();
    await _writeToFile(_attendanceFile, data);

    // Also add to pending sync
    await addToPendingSync('attendance', record.id, record.toMap());
  }

  static Future<AttendanceRecord?> getAttendanceRecord(String id) async {
    final data = await _readFromFile(_attendanceFile);
    final recordMap = data[id];
    if (recordMap == null) return null;

    return AttendanceRecord.fromMap(Map<String, dynamic>.from(recordMap));
  }

  static Future<List<AttendanceRecord>> getAllAttendanceRecords() async {
    final data = await _readFromFile(_attendanceFile);
    final records = <AttendanceRecord>[];

    for (final recordMap in data.values) {
      try {
        records.add(
          AttendanceRecord.fromMap(Map<String, dynamic>.from(recordMap)),
        );
      } catch (e) {
        continue;
      }
    }

    return records;
  }

  static Future<List<AttendanceRecord>> getAttendanceRecordsByStudent(
    String studentId,
  ) async {
    final allRecords = await getAllAttendanceRecords();
    return allRecords.where((record) => record.studentId == studentId).toList();
  }

  static Future<List<AttendanceRecord>> getAttendanceRecordsBySession(
    String sessionId,
  ) async {
    final allRecords = await getAllAttendanceRecords();
    return allRecords.where((record) => record.sessionId == sessionId).toList();
  }

  // Sessions
  static Future<void> saveSession(Session session) async {
    final data = await _readFromFile(_sessionsFile);
    data[session.id] = session.toMap();
    await _writeToFile(_sessionsFile, data);
  }

  static Future<Session?> getSession(String id) async {
    final data = await _readFromFile(_sessionsFile);
    final sessionMap = data[id];
    if (sessionMap == null) return null;

    return Session.fromMap(Map<String, dynamic>.from(sessionMap));
  }

  static Future<List<Session>> getAllSessions() async {
    final data = await _readFromFile(_sessionsFile);
    final sessions = <Session>[];

    for (final sessionMap in data.values) {
      try {
        sessions.add(Session.fromMap(Map<String, dynamic>.from(sessionMap)));
      } catch (e) {
        continue;
      }
    }

    return sessions;
  }

  static Future<List<Session>> getActiveSessions() async {
    final allSessions = await getAllSessions();
    return allSessions
        .where((session) => session.state == SessionState.live)
        .toList();
  }

  // Users
  static Future<void> saveUser(User user) async {
    final data = await _readFromFile(_usersFile);
    data[user.uid] = user.toJson();
    await _writeToFile(_usersFile, data);
  }

  static Future<User?> getUser(String id) async {
    final data = await _readFromFile(_usersFile);
    final userMap = data[id];
    if (userMap == null) return null;

    return User.fromJson(Map<String, dynamic>.from(userMap));
  }

  static Future<List<User>> getAllUsers() async {
    final data = await _readFromFile(_usersFile);
    final users = <User>[];

    for (final userMap in data.values) {
      try {
        users.add(User.fromJson(Map<String, dynamic>.from(userMap)));
      } catch (e) {
        continue;
      }
    }

    return users;
  }

  // Pending Sync Management
  static Future<void> addToPendingSync(
    String type,
    String id,
    Map<String, dynamic> data,
  ) async {
    final pendingData = await _readFromFile(_pendingFile);
    final pendingItem = {
      'type': type,
      'id': id,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'retryCount': 0,
    };

    pendingData['${type}_$id'] = pendingItem;
    await _writeToFile(_pendingFile, pendingData);
  }

  static Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final data = await _readFromFile(_pendingFile);
    return data.values.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<void> removePendingSyncItem(String type, String id) async {
    final data = await _readFromFile(_pendingFile);
    data.remove('${type}_$id');
    await _writeToFile(_pendingFile, data);
  }

  static Future<void> incrementRetryCount(String type, String id) async {
    final data = await _readFromFile(_pendingFile);
    final key = '${type}_$id';
    final item = data[key];
    if (item != null) {
      final updatedItem = Map<String, dynamic>.from(item);
      updatedItem['retryCount'] = (updatedItem['retryCount'] ?? 0) + 1;
      data[key] = updatedItem;
      await _writeToFile(_pendingFile, data);
    }
  }

  // Settings
  static Future<void> saveSetting(String key, dynamic value) async {
    final data = await _readFromFile(_settingsFile);
    data[key] = value;
    await _writeToFile(_settingsFile, data);
  }

  static Future<T?> getSetting<T>(String key) async {
    final data = await _readFromFile(_settingsFile);
    return data[key] as T?;
  }

  // Data Export/Import
  static Future<Map<String, dynamic>> exportAllData() async {
    final data = <String, dynamic>{
      'attendanceRecords': await getAllAttendanceRecords(),
      'sessions': await getAllSessions(),
      'users': await getAllUsers(),
      'settings': await _readFromFile(_settingsFile),
      'exportTimestamp': DateTime.now().millisecondsSinceEpoch,
    };

    return data;
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    // Import attendance records
    if (data['attendanceRecords'] != null) {
      for (final recordData in data['attendanceRecords']) {
        final record = AttendanceRecord.fromMap(recordData);
        await saveAttendanceRecord(record);
      }
    }

    // Import sessions
    if (data['sessions'] != null) {
      for (final sessionData in data['sessions']) {
        final session = Session.fromMap(sessionData);
        await saveSession(session);
      }
    }

    // Import users
    if (data['users'] != null) {
      for (final userData in data['users']) {
        final user = User.fromJson(userData);
        await saveUser(user);
      }
    }

    // Import settings
    if (data['settings'] != null) {
      final settings = Map<String, dynamic>.from(data['settings']);
      for (final entry in settings.entries) {
        await saveSetting(entry.key, entry.value);
      }
    }
  }

  // Cleanup
  static Future<void> clearAllData() async {
    await _writeToFile(_attendanceFile, {});
    await _writeToFile(_sessionsFile, {});
    await _writeToFile(_usersFile, {});
    await _writeToFile(_pendingFile, {});
    await _writeToFile(_settingsFile, {});
  }

  static Future<void> clearOldData({int daysOld = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

    // Clear old attendance records
    final attendanceData = await _readFromFile(_attendanceFile);
    final keysToDelete = <String>[];

    for (final entry in attendanceData.entries) {
      try {
        final record = AttendanceRecord.fromMap(
          Map<String, dynamic>.from(entry.value),
        );
        if (record.timestamp.isBefore(cutoffDate)) {
          keysToDelete.add(entry.key);
        }
      } catch (e) {
        continue;
      }
    }

    for (final key in keysToDelete) {
      attendanceData.remove(key);
    }

    await _writeToFile(_attendanceFile, attendanceData);
  }

  // Statistics
  static Future<StorageStats> getStorageStats() async {
    final attendanceData = await _readFromFile(_attendanceFile);
    final sessionsData = await _readFromFile(_sessionsFile);
    final usersData = await _readFromFile(_usersFile);
    final pendingData = await _readFromFile(_pendingFile);
    final lastSyncTime = await getSetting<DateTime>('lastSyncTime');

    return StorageStats(
      attendanceRecordsCount: attendanceData.length,
      sessionsCount: sessionsData.length,
      usersCount: usersData.length,
      pendingSyncCount: pendingData.length,
      lastSyncTime: lastSyncTime,
    );
  }
}

class StorageStats {
  final int attendanceRecordsCount;
  final int sessionsCount;
  final int usersCount;
  final int pendingSyncCount;
  final DateTime? lastSyncTime;

  StorageStats({
    required this.attendanceRecordsCount,
    required this.sessionsCount,
    required this.usersCount,
    required this.pendingSyncCount,
    this.lastSyncTime,
  });
}
  // Additional methods for background sync compatibility
  static Future<List<AttendanceRecord>> getPendingAttendanceRecords() async {
    final pendingItems = await getPendingSyncItems();
    final attendanceRecords = <AttendanceRecord>[];
    
    for (final item in pendingItems) {
      if (item['type'] == 'attendance') {
        try {
          final record = AttendanceRecord.fromMap(Map<String, dynamic>.from(item['data']));
          attendanceRecords.add(record);
        } catch (e) {
          continue;
        }
      }
    }
    
    return attendanceRecords;
  }

  static Future<List<Map<String, dynamic>>> getPendingSessions() async {
    final pendingItems = await getPendingSyncItems();
    final sessions = <Map<String, dynamic>>[];
    
    for (final item in pendingItems) {
      if (item['type'] == 'session') {
        sessions.add(Map<String, dynamic>.from(item['data']));
      }
    }
    
    return sessions;
  }

  static Future<void> addPendingAttendanceRecord(AttendanceRecord record) async {
    await addToPendingSync('attendance', record.id, record.toMap());
  }

  static Future<void> addPendingSession(Map<String, dynamic> sessionData) async {
    final sessionId = sessionData['id'] ?? 'session_${DateTime.now().millisecondsSinceEpoch}';
    await addToPendingSync('session', sessionId, sessionData);
  }

  static Future<void> removePendingAttendanceRecord(String recordId) async {
    await removePendingSyncItem('attendance', recordId);
  }

  static Future<void> removePendingSession(String sessionId) async {
    await removePendingSyncItem('session', sessionId);
  }