import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/task.dart';

class FreePeriodCoachPage extends ConsumerStatefulWidget {
  const FreePeriodCoachPage({super.key});

  @override
  ConsumerState<FreePeriodCoachPage> createState() =>
      _FreePeriodCoachPageState();
}

class _FreePeriodCoachPageState extends ConsumerState<FreePeriodCoachPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedDuration = '30';
  String _selectedCategory = 'All';
  List<Task> _recommendedTasks = [];
  List<Task> _completedTasks = [];
  bool _isLoading = false;

  final List<String> _durations = ['15', '30', '45', '60', '90'];
  final List<String> _categories = [
    'All',
    'Academic',
    'Skills',
    'Health',
    'Personal',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadRecommendedTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Free Period Coach',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => context.go('/student'),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.lightbulb), text: 'Recommendations'),
            Tab(icon: Icon(Icons.timer), text: 'Quick Tasks'),
            Tab(icon: Icon(Icons.history), text: 'Completed'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRecommendationsTab(),
            _buildQuickTasksTab(),
            _buildCompletedTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Filters
          _buildFilters(),
          const SizedBox(height: 20),

          // Recommendations
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _recommendedTasks.isEmpty
                ? _buildEmptyState()
                : _buildTasksList(_recommendedTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTasksTab() {
    final quickTasks = _getQuickTasks();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Quick Task Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.flash_on, color: AppTheme.accentColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Tasks',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          Text(
                            'Tasks you can complete in 15 minutes or less',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Tasks List
          Expanded(
            child: quickTasks.isEmpty
                ? _buildEmptyState()
                : _buildTasksList(quickTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Completed Tasks Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.presentColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Completed Tasks',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          Text(
                            '${_completedTasks.length} tasks completed today',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Completed Tasks List
          Expanded(
            child: _completedTasks.isEmpty
                ? _buildEmptyCompletedState()
                : _buildCompletedTasksList(_completedTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Duration Filter
          Row(
            children: [
              Text(
                'Duration: ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _durations.map((duration) {
                      final isSelected = _selectedDuration == duration;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${duration}m'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDuration = duration;
                            });
                            _loadRecommendedTasks();
                          },
                          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Filter
          Row(
            children: [
              Text(
                'Category: ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _loadRecommendedTasks();
                          },
                          selectedColor: AppTheme.secondaryColor.withOpacity(
                            0.2,
                          ),
                          checkmarkColor: AppTheme.secondaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, index);
      },
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _showTaskDetails(task),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getTaskTypeColor(
                              task.type,
                            ).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getTaskTypeIcon(task.type),
                            color: _getTaskTypeColor(task.type),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(
                              task.difficulty,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.difficultyDisplayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getDifficultyColor(task.difficulty),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Task Details
                    Row(
                      children: [
                        _buildTaskDetail(
                          Icons.access_time,
                          task.durationDisplay,
                        ),
                        const SizedBox(width: 16),
                        _buildTaskDetail(Icons.category, task.typeDisplayName),
                        const SizedBox(width: 16),
                        _buildTaskDetail(
                          Icons.star,
                          '${_getTaskScore(task)} points',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _skipTask(task),
                            icon: Icon(Icons.skip_next, size: 18),
                            label: Text('Skip'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textSecondaryColor,
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _startTask(task),
                            icon: Icon(Icons.play_arrow, size: 18),
                            label: Text('Start'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: 100 * index),
        )
        .slideY(begin: 0.3);
  }

  Widget _buildTaskDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textHintColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: AppTheme.textHintColor),
        ),
      ],
    );
  }

  Widget _buildCompletedTasksList(List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.presentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: AppTheme.presentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Completed ${_getTimeAgo(task.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.presentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${_getTaskScore(task)} pts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.presentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Finding perfect tasks for you...',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tasks available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCompletedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.presentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 60,
              color: AppTheme.presentColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No completed tasks yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start completing tasks to see them here!',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper Methods
  void _loadRecommendedTasks() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _recommendedTasks = _generateRecommendedTasks();
      });
    });
  }

  List<Task> _generateRecommendedTasks() {
    // Mock data - in real app, this would come from recommendation engine
    return [
      Task(
        id: '1',
        title: 'Complete Math Assignment',
        description: 'Solve calculus problems from chapter 5',
        tags: ['mathematics', 'homework'],
        durationMinutes: int.parse(_selectedDuration),
        type: TaskType.exercise,
        difficulty: TaskDifficulty.medium,
        skillMap: {'mathematics': 0.7, 'problem_solving': 0.8},
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: '2',
        title: 'Read Physics Chapter',
        description: 'Study quantum mechanics concepts',
        tags: ['physics', 'reading'],
        durationMinutes: int.parse(_selectedDuration),
        type: TaskType.reading,
        difficulty: TaskDifficulty.hard,
        skillMap: {'physics': 0.9, 'reading': 0.6},
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: '3',
        title: 'Practice Coding',
        description: 'Solve LeetCode problems',
        tags: ['programming', 'coding'],
        durationMinutes: int.parse(_selectedDuration),
        type: TaskType.coding,
        difficulty: TaskDifficulty.medium,
        skillMap: {'programming': 0.8, 'algorithms': 0.7},
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<Task> _getQuickTasks() {
    return _recommendedTasks
        .where((task) => task.durationMinutes <= 15)
        .toList();
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.reading:
        return Colors.blue;
      case TaskType.coding:
        return Colors.green;
      case TaskType.quiz:
        return Colors.orange;
      case TaskType.project:
        return Colors.purple;
      case TaskType.exercise:
        return Colors.red;
      case TaskType.summary:
        return Colors.teal;
      case TaskType.other:
        return Colors.grey;
    }
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.reading:
        return Icons.book;
      case TaskType.coding:
        return Icons.code;
      case TaskType.quiz:
        return Icons.quiz;
      case TaskType.project:
        return Icons.work;
      case TaskType.exercise:
        return Icons.fitness_center;
      case TaskType.summary:
        return Icons.summarize;
      case TaskType.other:
        return Icons.task;
    }
  }

  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return Colors.green;
      case TaskDifficulty.medium:
        return Colors.orange;
      case TaskDifficulty.hard:
        return Colors.red;
    }
  }

  int _getTaskScore(Task task) {
    // Calculate points based on difficulty and duration
    int basePoints = task.difficulty == TaskDifficulty.easy
        ? 10
        : task.difficulty == TaskDifficulty.medium
        ? 20
        : 30;
    return basePoints + (task.durationMinutes ~/ 15);
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Task Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getTaskTypeColor(task.type).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTaskTypeIcon(task.type),
                      color: _getTaskTypeColor(task.type),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.typeDisplayName,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Task Details
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Description', task.description),
                      _buildDetailRow('Duration', task.durationDisplay),
                      _buildDetailRow('Difficulty', task.difficultyDisplayName),
                      _buildDetailRow(
                        'Points',
                        '${_getTaskScore(task)} points',
                      ),
                      _buildDetailRow('Tags', task.tags.join(', ')),

                      const SizedBox(height: 24),

                      // Skills
                      Text(
                        'Skills Developed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: task.skillMap.entries.map((entry) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${entry.key} (${(entry.value * 100).toInt()}%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _startTask(task);
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _startTask(Task task) {
    // Navigate to task timer/detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting task: ${task.title}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _skipTask(Task task) {
    setState(() {
      _recommendedTasks.remove(task);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Skipped: ${task.title}'),
        backgroundColor: AppTheme.textSecondaryColor,
      ),
    );
  }
}
