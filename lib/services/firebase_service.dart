// Demo Firebase Service
// This simulates Firebase Firestore functionality

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import '../models/attendance_record.dart';
import '../models/session.dart';
import '../models/user.dart' as app_user;

class FirebaseService {
  static final Map<String, Map<String, dynamic>> _collections = {};
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    developer.log('Demo Firebase Service initialized');
    _initialized = true;
  }

  // Current user simulation
  static app_user.User? get currentUser => app_user.User(
    uid: 'demo_user_123',
    name: 'Demo User',
    phone: '+1234567890',
    email: 'demo@example.com',
    role: app_user.UserRole.student,
    createdAt: DateTime.now(),
    lastActive: DateTime.now(),
  );

  static Stream<app_user.User?> get authStateChanges =>
      Stream.value(currentUser);

  // Collection operations
  static Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(Duration(milliseconds: 200));

    _collections[collection] ??= {};
    _collections[collection]![documentId] = Map.from(data);

    developer.log('Demo Firebase: Set document $documentId in $collection');
  }

  static Future<Map<String, dynamic>?> getDocument(
    String collection,
    String documentId,
  ) async {
    await Future.delayed(Duration(milliseconds: 150));

    final doc = _collections[collection]?[documentId];
    developer.log('Demo Firebase: Get document $documentId from $collection');
    return doc != null ? Map.from(doc) : null;
  }

  static Future<List<Map<String, dynamic>>> getCollection(
    String collection, {
    Map<String, dynamic>? where,
    String? orderBy,
    int? limit,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));

    final collectionData = _collections[collection] ?? {};
    var results = collectionData.values.toList();

    // Simple filtering (demo implementation)
    if (where != null) {
      results = results.where((doc) {
        return where.entries.every((entry) {
          return doc[entry.key] == entry.value;
        });
      }).toList();
    }

    // Simple ordering (demo implementation)
    if (orderBy != null) {
      results.sort((a, b) {
        final aVal = a[orderBy];
        final bVal = b[orderBy];
        if (aVal is Comparable && bVal is Comparable) {
          return aVal.compareTo(bVal);
        }
        return 0;
      });
    }

    // Limit results
    if (limit != null && results.length > limit) {
      results = results.take(limit).toList();
    }

    developer.log(
      'Demo Firebase: Get collection $collection (${results.length} items)',
    );
    return results.map((doc) => Map<String, dynamic>.from(doc)).toList();
  }

  static Future<void> deleteDocument(
    String collection,
    String documentId,
  ) async {
    await Future.delayed(Duration(milliseconds: 100));

    _collections[collection]?.remove(documentId);
    developer.log(
      'Demo Firebase: Deleted document $documentId from $collection',
    );
  }

  // Stream operations (simplified)
  static Stream<List<Map<String, dynamic>>> streamCollection(
    String collection, {
    Map<String, dynamic>? where,
  }) {
    return Stream.periodic(Duration(seconds: 2), (count) {
      final collectionData = _collections[collection] ?? {};
      var results = collectionData.values.toList();

      if (where != null) {
        results = results.where((doc) {
          return where.entries.every((entry) {
            return doc[entry.key] == entry.value;
          });
        }).toList();
      }

      return results.map((doc) => Map<String, dynamic>.from(doc)).toList();
    });
  }

  // Batch operations
  static Future<void> batch(List<Map<String, dynamic>> operations) async {
    await Future.delayed(Duration(milliseconds: 500));

    for (final op in operations) {
      final type = op['type'];
      final collection = op['collection'];
      final documentId = op['documentId'];
      final data = op['data'];

      switch (type) {
        case 'set':
          await setDocument(collection, documentId, data);
          break;
        case 'delete':
          await deleteDocument(collection, documentId);
          break;
      }
    }

    developer.log(
      'Demo Firebase: Executed batch with ${operations.length} operations',
    );
  }

  // Error simulation
  static void _simulateError(String operation) {
    if (DateTime.now().millisecond % 100 == 0) {
      // 1% chance of error
      throw Exception('Demo Firebase error during $operation');
    }
  }

  // Utility methods
  static String generateId() {
    return 'demo_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  static Map<String, dynamic> timestamp() {
    return {
      'seconds': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'nanoseconds': (DateTime.now().microsecond * 1000) % 1000000000,
    };
  }
}
