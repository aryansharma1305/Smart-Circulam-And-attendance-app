import 'dart:convert';

class StorageService {
  static final Map<String, dynamic> _storage = {};

  // Initialize storage (no-op for in-memory)
  static Future<void> init() async {
    // No initialization needed for in-memory storage
  }

  // User data methods
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    _storage['userData'] = jsonEncode(userData);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = _storage['userData'];
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> clearUserData() async {
    _storage.remove('userData');
  }

  // Timetable methods
  Future<void> saveTimetable(
    String userId,
    List<Map<String, dynamic>> timetable,
  ) async {
    _storage['timetable_$userId'] = jsonEncode(timetable);
  }

  Future<List<Map<String, dynamic>>?> getTimetable(String userId) async {
    final data = _storage['timetable_$userId'];
    if (data == null) return null;

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.cast<Map<String, dynamic>>();
  }

  // Attendance methods
  Future<void> saveAttendanceHistory(
    String userId,
    List<Map<String, dynamic>> history,
  ) async {
    _storage['history_$userId'] = jsonEncode(history);
  }

  Future<List<Map<String, dynamic>>?> getAttendanceHistory(
    String userId,
  ) async {
    final data = _storage['history_$userId'];
    if (data == null) return null;

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveActiveSession(
    String teacherId,
    Map<String, dynamic> sessionData,
  ) async {
    _storage['active_session_$teacherId'] = jsonEncode(sessionData);
  }

  Future<Map<String, dynamic>?> getActiveSession(String teacherId) async {
    final data = _storage['active_session_$teacherId'];
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> clearActiveSession(String teacherId) async {
    _storage.remove('active_session_$teacherId');
  }

  // Notifications methods
  Future<void> saveNotifications(
    String userId,
    List<Map<String, dynamic>> notifications,
  ) async {
    _storage['notifications_$userId'] = jsonEncode(notifications);
  }

  Future<List<Map<String, dynamic>>?> getNotifications(String userId) async {
    final data = _storage['notifications_$userId'];
    if (data == null) return null;

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> markNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    final data = _storage['notifications_$userId'];
    if (data == null) return;

    final List<dynamic> decoded = jsonDecode(data);
    final notifications = decoded.cast<Map<String, dynamic>>();

    for (int i = 0; i < notifications.length; i++) {
      if (notifications[i]['id'] == notificationId) {
        notifications[i]['isRead'] = true;
        break;
      }
    }

    _storage['notifications_$userId'] = jsonEncode(notifications);
  }

  // General methods
  Future<void> clearAllData() async {
    _storage.clear();
  }

  // Cache expiration check
  bool isCacheExpired(String key, {int expirationHours = 24}) {
    final timestamp = _storage['cache_$key'];

    if (timestamp == null) return true;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(cachedTime).inHours;

    return difference >= expirationHours;
  }

  Future<void> updateCacheTimestamp(String key) async {
    _storage['cache_$key'] = DateTime.now().millisecondsSinceEpoch;
  }
}
