// Demo Notification Service
// This is a simplified demo that simulates notification functionality

import 'dart:developer' as developer;

class NotificationDemoService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    developer.log('Demo Notification Service initialized');
    _initialized = true;
  }

  static Future<void> scheduleDemoReminders() async {
    developer.log('Demo reminders scheduled');
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    developer.log('Demo Notification: $title - $body');
  }

  static Future<void> showAttendanceReminder() async {
    await showNotification(
      id: 1,
      title: 'Attendance Reminder',
      body: 'Don\'t forget to mark your attendance!',
    );
  }

  static Future<void> showSessionStarted(String subject) async {
    await showNotification(
      id: 2,
      title: 'Session Started',
      body: '$subject session has begun. Join now!',
    );
  }

  static Future<void> showTaskReminder(String taskTitle) async {
    await showNotification(
      id: 3,
      title: 'Task Reminder',
      body: 'Don\'t forget: $taskTitle',
    );
  }
}
