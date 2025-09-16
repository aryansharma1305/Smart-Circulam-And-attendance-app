import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:uuid/uuid.dart';

import '../models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;
  final _uuid = const Uuid();

  TaskService({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = (firebaseAuth ?? auth.FirebaseAuth.instance);

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create a new task
  Future<String> createTask({
    required String title,
    String? description,
    required int estimatedMinutes,
    required TaskDifficulty difficulty,
    DateTime? dueAt,
    String? subject,
    String? goalTag,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final taskId = _uuid.v4();
    final now = DateTime.now();

    final taskData = {
      'taskId': taskId,
      'ownerId': currentUserId,
      'title': title,
      'description': description,
      'estimatedMinutes': estimatedMinutes,
      'difficulty': difficulty.toString().split('.').last,
      'dueAt': dueAt?.toIso8601String(),
      'subject': subject,
      'goalTag': goalTag,
      'status': TaskStatus.pending.toString().split('.').last,
      'createdAt': now.toIso8601String(),
      'completedAt': null,
      'actualMinutes': null,
    };

    await _firestore.collection('tasks').doc(taskId).set(taskData);
    return taskId;
  }

  // Get all tasks for the current user
  Future<List<Task>> getUserTasks() async {
    if (currentUserId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('tasks')
        .where('ownerId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
  }

  // Get tasks for a specific subject
  Future<List<Task>> getTasksBySubject(String subject) async {
    if (currentUserId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('tasks')
        .where('ownerId', isEqualTo: currentUserId)
        .where('subject', isEqualTo: subject)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
  }

  // Get tasks by status
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    if (currentUserId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('tasks')
        .where('ownerId', isEqualTo: currentUserId)
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
  }

  // Get tasks due today
  Future<List<Task>> getTasksDueToday() async {
    if (currentUserId == null) {
      return [];
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final snapshot = await _firestore
        .collection('tasks')
        .where('ownerId', isEqualTo: currentUserId)
        .where('status', isEqualTo: TaskStatus.pending.toString().split('.').last)
        .get();

    return snapshot.docs
        .map((d) => Task.fromMap(d.data()))
        .where((task) {
          if (task.dueAt == null) return false;
          final parsed = task.dueAt;
          if (parsed == null) return false;
          final dueDate = DateTime(parsed.year, parsed.month, parsed.day);
          return dueDate.isAtSameMomentAs(today);
        })
        .toList();
  }

  // Update task status
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final updates = {
      'status': status.toString().split('.').last,
    };

    // If completing the task, record completion time
    if (status == TaskStatus.completed) {
      updates['completedAt'] = DateTime.now().toIso8601String();
    }

    await _firestore.collection('tasks').doc(taskId).update(updates);
  }

  // Update task details
  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    int? estimatedMinutes,
    TaskDifficulty? difficulty,
    DateTime? dueAt,
    String? subject,
    String? goalTag,
    TaskStatus? status,
    int? actualMinutes,
  }) async {
    final updates = <String, dynamic>{};

    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (estimatedMinutes != null) updates['estimatedMinutes'] = estimatedMinutes;
    if (difficulty != null) {
      updates['difficulty'] = difficulty.toString().split('.').last;
    }
    if (dueAt != null) updates['dueAt'] = dueAt.toIso8601String();
    if (subject != null) updates['subject'] = subject;
    if (goalTag != null) updates['goalTag'] = goalTag;
    if (status != null) {
      updates['status'] = status.toString().split('.').last;
      
      // If completing the task, record completion time
      if (status == TaskStatus.completed && !updates.containsKey('completedAt')) {
        updates['completedAt'] = DateTime.now().toIso8601String();
      }
    }
    if (actualMinutes != null) updates['actualMinutes'] = actualMinutes;

    if (updates.isNotEmpty) {
      await _firestore.collection('tasks').doc(taskId).update(updates);
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  // Get tasks for free time optimization
  Future<List<Task>> getTasksForOptimization(int availableMinutes) async {
    final pendingTasks = await getTasksByStatus(TaskStatus.pending);
    
    // Sort tasks by value per minute (highest first)
    pendingTasks.sort((a, b) =>
        (b.durationMinutes == 0 ? 0 : b.durationMinutes)
            .compareTo(a.durationMinutes == 0 ? 0 : a.durationMinutes));
    
    // Filter tasks that can be completed within available time
    return pendingTasks
        .where((task) => task.estimatedMinutes <= availableMinutes)
        .toList();
  }

  // Suggest tasks based on free time duration and subject preferences
  Future<List<Task>> suggestTasks({
    required int availableMinutes,
    List<String>? preferredSubjects,
  }) async {
    final pendingTasks = await getTasksByStatus(TaskStatus.pending);
    
    // Filter by preferred subjects if provided
    var filteredTasks = pendingTasks;
    if (preferredSubjects != null && preferredSubjects.isNotEmpty) {
      filteredTasks = pendingTasks
          .where((task) => task.subject != null && 
                preferredSubjects.contains(task.subject))
          .toList();
      
      // If no tasks match preferred subjects, fall back to all pending tasks
      if (filteredTasks.isEmpty) {
        filteredTasks = pendingTasks;
      }
    }
    
    // Sort by urgency and value
    filteredTasks.sort((a, b) {
      // First prioritize tasks that fit within available time
      final aFits = a.durationMinutes <= availableMinutes;
      final bFits = b.durationMinutes <= availableMinutes;
      
      if (aFits && !bFits) return -1;
      if (!aFits && bFits) return 1;
      
      // Then sort by value per minute
      return a.durationMinutes.compareTo(b.durationMinutes);
    });
    
    // Return top suggestions (limit to 5)
    return filteredTasks.take(5).toList();
  }
}