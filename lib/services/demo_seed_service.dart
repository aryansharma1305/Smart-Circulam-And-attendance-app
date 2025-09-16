import 'package:flutter/foundation.dart';
import 'admin_service.dart';
import 'simple_storage_service.dart';
import '../models/attendance_record.dart';

class DemoSeedService {
  static Future<void> seedIfEmpty() async {
    try {
      // Seed admin institute settings
      final admin = AdminService();
      final current = await admin.getInstituteSettings();
      if ((current['code'] ?? '').toString().isEmpty) {
        await admin.saveInstituteSettings({
          'name': 'Demo Institute',
          'code': 'DEMO123',
          'city': 'Mumbai',
        });
      }

      // Seed attendance records if none
      final existing = await SimpleStorageService.getAllAttendanceRecords();
      if (existing.isEmpty) {
        for (int i = 0; i < 5; i++) {
          final record = AttendanceRecord(
            id: 'seed_$i',
            sessionId: 'sess_${100 + i}',
            studentId: 'student_${i + 1}',
            status: i % 4 == 0 ? AttendanceStatus.late : AttendanceStatus.present,
            method: AttendanceMethod.qr,
            timestamp: DateTime.now().subtract(Duration(days: i)),
            metadata: {'seed': true},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await SimpleStorageService.saveAttendanceRecord(record);
        }
      }
    } catch (e) {
      debugPrint('Demo seeding failed: $e');
    }
  }
}


