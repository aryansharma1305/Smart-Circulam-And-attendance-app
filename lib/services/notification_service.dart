import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService({FirebaseFirestore? firestore, auth.FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = firebaseAuth ?? auth.FirebaseAuth.instance,
      _notificationsPlugin = FlutterLocalNotificationsPlugin() {
    _initNotifications();
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Initialize notifications
  Future<void> _initNotifications() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  // Request notification permissions
  Future<void> requestPermissions() async {
    // iOS permission request
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    // Android 13+ permissions are handled by the host app manifest/intents; no-op here for demo
  }

  // Create a new announcement notification
  Future<String> createAnnouncementNotification({
    required String title,
    required String body,
    required List<String> targetUserIds,
    required String senderName,
    String? courseId,
    String? courseName,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Create the announcement document
    final docRef = await _firestore.collection('announcements').add({
      'title': title,
      'body': body,
      'senderId': currentUserId,
      'senderName': senderName,
      'targetUserIds': targetUserIds,
      'courseId': courseId,
      'courseName': courseName,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [],
    });

    // Return the announcement ID
    return docRef.id;
  }

  // Get announcements for the current user
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    if (currentUserId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('announcements')
        .where('targetUserIds', arrayContains: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }

  // Mark announcement as read
  Future<void> markAnnouncementAsRead(String announcementId) async {
    if (currentUserId == null) {
      return;
    }

    await _firestore.collection('announcements').doc(announcementId).update({
      'readBy': FieldValue.arrayUnion([currentUserId]),
    });
  }

  // Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'smart_study_channel',
          'Smart Study Notifications',
          channelDescription: 'Notifications from Smart Study app',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, notificationDetails);
  }

  // Schedule a notification for a class
  Future<void> scheduleClassNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    int id = 0,
  }) async {
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime.subtract(
        const Duration(minutes: 15),
      ), // 15 minutes before class
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'smart_study_class_channel',
          'Smart Study Class Reminders',
          channelDescription: 'Reminders for upcoming classes',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
