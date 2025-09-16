import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

// Provider for the storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Provider for cached user data
final cachedUserDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final storageService = ref.watch(storageServiceProvider);
  return await storageService.getUserData();
});

// Provider for cached timetable
final cachedTimetableProvider = FutureProvider.family<List<Map<String, dynamic>>?, String>(
  (ref, userId) async {
    final storageService = ref.watch(storageServiceProvider);
    return await storageService.getTimetable(userId);
  },
);

// Provider for cached attendance history
final cachedAttendanceHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>?, String>(
  (ref, userId) async {
    final storageService = ref.watch(storageServiceProvider);
    return await storageService.getAttendanceHistory(userId);
  },
);

// Provider for cached active session
final cachedActiveSessionProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, teacherId) async {
    final storageService = ref.watch(storageServiceProvider);
    return await storageService.getActiveSession(teacherId);
  },
);

// Provider for cached notifications
final cachedNotificationsProvider = FutureProvider.family<List<Map<String, dynamic>>?, String>(
  (ref, userId) async {
    final storageService = ref.watch(storageServiceProvider);
    return await storageService.getNotifications(userId);
  },
);

// Provider for saving user data
final saveUserDataProvider = FutureProvider.family<void, Map<String, dynamic>>(
  (ref, userData) async {
    final storageService = ref.watch(storageServiceProvider);
    await storageService.saveUserData(userData);
    ref.invalidate(cachedUserDataProvider);
  },
);

// Provider for saving timetable
final saveTimetableProvider = FutureProvider.family<void, Map<String, dynamic>>(
  (ref, params) async {
    final storageService = ref.watch(storageServiceProvider);
    final userId = params['userId'] as String;
    final timetable = List<Map<String, dynamic>>.from(params['timetable'] as List);
    
    await storageService.saveTimetable(userId, timetable);
    ref.invalidate(cachedTimetableProvider(userId));
  },
);

// Provider for saving attendance history
final saveAttendanceHistoryProvider = FutureProvider.family<void, Map<String, dynamic>>(
  (ref, params) async {
    final storageService = ref.watch(storageServiceProvider);
    final userId = params['userId'] as String;
    final history = List<Map<String, dynamic>>.from(params['history'] as List);
    
    await storageService.saveAttendanceHistory(userId, history);
    ref.invalidate(cachedAttendanceHistoryProvider(userId));
  },
);

// Provider for saving active session
final saveActiveSessionProvider = FutureProvider.family<void, Map<String, dynamic>>(
  (ref, params) async {
    final storageService = ref.watch(storageServiceProvider);
    final teacherId = params['teacherId'] as String;
    final sessionData = params['sessionData'] as Map<String, dynamic>;
    
    await storageService.saveActiveSession(teacherId, sessionData);
    ref.invalidate(cachedActiveSessionProvider(teacherId));
  },
);

// Provider for clearing active session
final clearActiveSessionProvider = FutureProvider.family<void, String>(
  (ref, teacherId) async {
    final storageService = ref.watch(storageServiceProvider);
    await storageService.clearActiveSession(teacherId);
    ref.invalidate(cachedActiveSessionProvider(teacherId));
  },
);

// Provider for saving notifications
final saveNotificationsProvider = FutureProvider.family<void, Map<String, dynamic>>(
  (ref, params) async {
    final storageService = ref.watch(storageServiceProvider);
    final userId = params['userId'] as String;
    final notifications = List<Map<String, dynamic>>.from(params['notifications'] as List);
    
    await storageService.saveNotifications(userId, notifications);
    ref.invalidate(cachedNotificationsProvider(userId));
  },
);

// Provider for marking notification as read
final markNotificationAsReadProvider = FutureProvider.family<void, Map<String, dynamic>>(
  (ref, params) async {
    final storageService = ref.watch(storageServiceProvider);
    final userId = params['userId'] as String;
    final notificationId = params['notificationId'] as String;
    
    await storageService.markNotificationAsRead(userId, notificationId);
    ref.invalidate(cachedNotificationsProvider(userId));
  },
);

// Provider for clearing all data (logout)
final clearAllDataProvider = FutureProvider<void>((ref) async {
  final storageService = ref.watch(storageServiceProvider);
  await storageService.clearAllData();
  
  // Invalidate all cached data providers
  ref.invalidate(cachedUserDataProvider);
  // Note: We can't invalidate family providers globally, they'll be invalidated when accessed with specific parameters
});