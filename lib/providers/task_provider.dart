import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/task_service.dart';

// Provider for the TaskService
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

// Provider for all user tasks
final userTasksProvider = FutureProvider.autoDispose<List<Task>>((ref) async {
  final taskService = ref.watch(taskServiceProvider);
  return taskService.getUserTasks();
});

// Provider for tasks by status
final tasksByStatusProvider = FutureProvider.family<List<Task>, TaskStatus>(
  (ref, status) async {
    final taskService = ref.watch(taskServiceProvider);
    return taskService.getTasksByStatus(status);
  },
);

// Provider for tasks by subject
final tasksBySubjectProvider = FutureProvider.family<List<Task>, String>(
  (ref, subject) async {
    final taskService = ref.watch(taskServiceProvider);
    return taskService.getTasksBySubject(subject);
  },
);

// Provider for tasks due today
final tasksDueTodayProvider = FutureProvider.autoDispose<List<Task>>((ref) async {
  final taskService = ref.watch(taskServiceProvider);
  return taskService.getTasksDueToday();
});

// Provider for creating a new task
final createTaskProvider = FutureProvider.family<String, Map<String, dynamic>>(
  (ref, taskData) async {
    final taskService = ref.watch(taskServiceProvider);
    
    final taskId = await taskService.createTask(
      title: taskData['title'],
      description: taskData['description'],
      estimatedMinutes: taskData['estimatedMinutes'],
      difficulty: taskData['difficulty'],
      dueAt: taskData['dueAt'],
      subject: taskData['subject'],
      goalTag: taskData['goalTag'],
    );
    
    // Invalidate providers to refresh task lists
    ref.invalidate(userTasksProvider);
    ref.invalidate(tasksDueTodayProvider);
    
    return taskId;
  },
);

// Provider for updating task status
final updateTaskStatusProvider = FutureProvider.family<void, Map<String, dynamic>>(
  (ref, data) async {
    final taskService = ref.watch(taskServiceProvider);
    final taskId = data['taskId'] as String;
    final status = data['status'] as TaskStatus;
    
    await taskService.updateTaskStatus(taskId, status);
    
    // Invalidate providers to refresh task lists
    ref.invalidate(userTasksProvider);
    ref.invalidate(tasksDueTodayProvider);
    ref.invalidate(tasksByStatusProvider(TaskStatus.pending));
    ref.invalidate(tasksByStatusProvider(status));
  },
);

// Provider for updating task details
final updateTaskProvider = FutureProvider.family<void, Map<String, dynamic>>(
  (ref, taskData) async {
    final taskService = ref.watch(taskServiceProvider);
    
    await taskService.updateTask(
      taskId: taskData['taskId'],
      title: taskData['title'],
      description: taskData['description'],
      estimatedMinutes: taskData['estimatedMinutes'],
      difficulty: taskData['difficulty'],
      dueAt: taskData['dueAt'],
      subject: taskData['subject'],
      goalTag: taskData['goalTag'],
      status: taskData['status'],
      actualMinutes: taskData['actualMinutes'],
    );
    
    // Invalidate providers to refresh task lists
    ref.invalidate(userTasksProvider);
    ref.invalidate(tasksDueTodayProvider);
    
    // Invalidate status-specific providers if status was updated
    if (taskData['status'] != null) {
      ref.invalidate(tasksByStatusProvider(TaskStatus.pending));
      ref.invalidate(tasksByStatusProvider(taskData['status']));
    }
    
    // Invalidate subject-specific provider if subject was updated
    if (taskData['subject'] != null) {
      ref.invalidate(tasksBySubjectProvider(taskData['subject']));
    }
  },
);

// Provider for deleting a task
final deleteTaskProvider = FutureProvider.family<void, String>(
  (ref, taskId) async {
    final taskService = ref.watch(taskServiceProvider);
    await taskService.deleteTask(taskId);
    
    // Invalidate providers to refresh task lists
    ref.invalidate(userTasksProvider);
    ref.invalidate(tasksDueTodayProvider);
    ref.invalidate(tasksByStatusProvider(TaskStatus.pending));
  },
);

// Provider for task optimization suggestions
final taskOptimizationProvider = FutureProvider.family<List<Task>, int>(
  (ref, availableMinutes) async {
    final taskService = ref.watch(taskServiceProvider);
    return taskService.getTasksForOptimization(availableMinutes);
  },
);

// Provider for task suggestions based on free time and preferences
final taskSuggestionsProvider = FutureProvider.family<List<Task>, Map<String, dynamic>>(
  (ref, params) async {
    final taskService = ref.watch(taskServiceProvider);
    final availableMinutes = params['availableMinutes'] as int;
    final preferredSubjects = params['preferredSubjects'] as List<String>?;
    
    return taskService.suggestTasks(
      availableMinutes: availableMinutes,
      preferredSubjects: preferredSubjects,
    );
  },
);