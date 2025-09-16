import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/timetable_service.dart';
import '../models/user.dart';
import 'auth_provider.dart';

// Provider for the TimetableService
final timetableServiceProvider = Provider<TimetableService>((ref) {
  return TimetableService();
});

// Provider for today's classes
final todayClassesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) {
        return [];
      }

      final timetableService = ref.watch(timetableServiceProvider);
      return timetableService.getTodayClasses(user.uid, user.role.name);
    });

// Provider for weekly schedule
final weeklyScheduleProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      weekday,
    ) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) {
        return [];
      }

      final timetableService = ref.watch(timetableServiceProvider);
      return timetableService.getSchedulesForDay(
        user.uid,
        user.role.name,
        weekday,
      );
    });

// Provider for all schedules based on user role
final allSchedulesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) {
        return [];
      }

      final timetableService = ref.watch(timetableServiceProvider);

      if (user.role == UserRole.teacher) {
        return timetableService.getTeacherSchedules(user.uid);
      } else {
        return timetableService.getStudentSchedules(user.uid);
      }
    });

// Provider for creating a new class schedule
final createClassScheduleProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
      final timetableService = ref.watch(timetableServiceProvider);

      await timetableService.createClassSchedule(
        courseId: params['courseId'],
        courseName: params['courseName'],
        teacherId: params['teacherId'],
        teacherName: params['teacherName'],
        roomNumber: params['roomNumber'],
        startTime: params['startTime'],
        endTime: params['endTime'],
        studentIds: params['studentIds'],
        weekdays: params['weekdays'],
      );
    });

// Provider for updating a class schedule
final updateClassScheduleProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
      final timetableService = ref.watch(timetableServiceProvider);

      await timetableService.updateClassSchedule(
        scheduleId: params['scheduleId'],
        courseName: params['courseName'],
        roomNumber: params['roomNumber'],
        startTime: params['startTime'],
        endTime: params['endTime'],
        studentIds: params['studentIds'],
        weekdays: params['weekdays'],
      );
    });

// Provider for deleting a class schedule
final deleteClassScheduleProvider = FutureProvider.family<void, String>((
  ref,
  scheduleId,
) async {
  final timetableService = ref.watch(timetableServiceProvider);
  await timetableService.deleteClassSchedule(scheduleId);
});

// Provider for getting a course color
final courseColorProvider = Provider.family<Color, String>((ref, courseName) {
  final timetableService = ref.watch(timetableServiceProvider);
  return timetableService.getCourseColor(courseName);
});
