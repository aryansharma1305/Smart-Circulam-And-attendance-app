import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/goal.dart';

class GoalsPlannerPage extends ConsumerStatefulWidget {
  const GoalsPlannerPage({super.key});

  @override
  ConsumerState<GoalsPlannerPage> createState() => _GoalsPlannerPageState();
}

class _GoalsPlannerPageState extends ConsumerState<GoalsPlannerPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  String _selectedPriority = 'All';
  // bool _isCreatingGoal = false; // Removed unused field

  final List<String> _filters = ['All', 'Active', 'Completed', 'Overdue'];
  final List<String> _priorities = ['All', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Goals & Planner',
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
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: _showCreateGoalDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Goals', icon: Icon(Icons.flag)),
            Tab(text: 'Planner', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Progress', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGoalsTab(), _buildPlannerTab(), _buildProgressTab()],
      ),
    );
  }

  Widget _buildGoalsTab() {
    final goals = _getFilteredGoals();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters
          _buildFilters(),
          const SizedBox(height: 20),

          // Goals List
          if (goals.isEmpty)
            _buildEmptyGoalsState()
          else
            ...goals.map((goal) => _buildGoalCard(goal)).toList(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _filters.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _priorities.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGoalsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag_outlined,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Goals Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Set your first goal to start tracking your progress and achieving your dreams!',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreateGoalDialog,
              icon: Icon(Icons.add),
              label: Text('Create Your First Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).scale();
  }

  Widget _buildGoalCard(Goal goal) {
    final isOverdue =
        goal.targetDate.isBefore(DateTime.now()) &&
        goal.status != GoalStatus.completed;
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: isOverdue
                ? Border.all(
                    color: AppTheme.absentColor.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getGoalTypeColor(goal.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          goal.typeDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getGoalTypeColor(goal.type),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getGoalPriorityColor(
                            goal.priority,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          goal.priorityDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getGoalPriorityColor(goal.priority),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                goal.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Progress Section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            Text(
                              '${goal.progress}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: goal.progressDecimal,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getGoalTypeColor(goal.type),
                          ),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textHintColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverdue
                            ? 'Overdue by ${-daysLeft} days'
                            : daysLeft > 0
                            ? '$daysLeft days left'
                            : 'Due today',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue
                              ? AppTheme.absentColor
                              : AppTheme.textHintColor,
                          fontWeight: isOverdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _editGoal(goal),
                        icon: Icon(
                          Icons.edit,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteGoal(goal),
                        icon: Icon(
                          Icons.delete,
                          color: AppTheme.absentColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildPlannerTab() {
    final weeklyPlan = _getWeeklyPlan();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week Overview
          _buildWeekOverview(weeklyPlan),
          const SizedBox(height: 24),

          // Daily Plans
          ...(weeklyPlan['days'] as List)
              .map((day) => _buildDayPlan(day))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildWeekOverview(Map<String, dynamic> weeklyPlan) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Week\'s Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildWeekStat(
                      'Goals',
                      weeklyPlan['totalGoals'].toString(),
                      Icons.flag,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildWeekStat(
                      'Tasks',
                      weeklyPlan['totalTasks'].toString(),
                      Icons.task,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildWeekStat(
                      'Completed',
                      weeklyPlan['completedTasks'].toString(),
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildWeekStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPlan(Map<String, dynamic> day) {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day['dayName'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: day['isToday']
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      day['isToday'] ? 'Today' : day['date'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: day['isToday']
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Classes
              if (day['classes'].isNotEmpty) ...[
                Text(
                  'Classes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...day['classes']
                    .map<Widget>((cls) => _buildClassItem(cls))
                    .toList(),
                const SizedBox(height: 16),
              ],

              // Goals & Tasks
              if (day['goals'].isNotEmpty || day['tasks'].isNotEmpty) ...[
                Text(
                  'Goals & Tasks',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...day['goals']
                    .map<Widget>((goal) => _buildGoalItem(goal))
                    .toList(),
                ...day['tasks']
                    .map<Widget>((task) => _buildTaskItem(task))
                    .toList(),
              ],

              // Free Time
              if (day['freeTime'].isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Free Time Suggestions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...day['freeTime']
                    .map<Widget>(
                      (suggestion) => _buildSuggestionItem(suggestion),
                    )
                    .toList(),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildClassItem(Map<String, dynamic> cls) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.class_, color: AppTheme.primaryColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${cls['time']} - ${cls['subject']} (${cls['room']})',
              style: TextStyle(fontSize: 14, color: AppTheme.textPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(Map<String, dynamic> goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getGoalTypeColor(
          GoalType.values.firstWhere((e) => e.toString() == goal['type']),
        ).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getGoalTypeColor(
            GoalType.values.firstWhere((e) => e.toString() == goal['type']),
          ).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flag,
            color: _getGoalTypeColor(
              GoalType.values.firstWhere((e) => e.toString() == goal['type']),
            ),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              goal['title'],
              style: TextStyle(fontSize: 14, color: AppTheme.textPrimaryColor),
            ),
          ),
          Text(
            '${goal['progress']}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getGoalTypeColor(
                GoalType.values.firstWhere((e) => e.toString() == goal['type']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.task, color: AppTheme.textSecondaryColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task['title'],
              style: TextStyle(fontSize: 14, color: AppTheme.textPrimaryColor),
            ),
          ),
          Text(
            task['duration'],
            style: TextStyle(fontSize: 12, color: AppTheme.textHintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: AppTheme.secondaryColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              suggestion['title'],
              style: TextStyle(fontSize: 14, color: AppTheme.textPrimaryColor),
            ),
          ),
          Text(
            suggestion['duration'],
            style: TextStyle(fontSize: 12, color: AppTheme.textHintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    final progressData = _getProgressData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Progress
          _buildOverallProgress(progressData),
          const SizedBox(height: 24),

          // Goal Categories
          _buildGoalCategories(progressData['categories']),
          const SizedBox(height: 24),

          // Recent Achievements
          _buildRecentAchievements(progressData['achievements']),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(Map<String, dynamic> data) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildProgressStat(
                      'Goals Completed',
                      data['completedGoals'].toString(),
                      data['totalGoals'].toString(),
                      Icons.flag,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildProgressStat(
                      'Tasks Done',
                      data['completedTasks'].toString(),
                      data['totalTasks'].toString(),
                      Icons.task,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Keep up the great work! You\'re making excellent progress towards your goals.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildProgressStat(
    String label,
    String completed,
    String total,
    IconData icon,
  ) {
    final percentage = total != '0'
        ? (int.parse(completed) / int.parse(total) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            '$completed/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCategories(List<Map<String, dynamic>> categories) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                'Goal Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ...categories
                  .map((category) => _buildCategoryCard(category))
                  .toList(),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(category['icon'], color: category['color'], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category['completed']}/${category['total']} goals completed',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${category['percentage']}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: category['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements(List<Map<String, dynamic>> achievements) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                'Recent Achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              if (achievements.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No achievements yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...achievements
                    .map((achievement) => _buildAchievementCard(achievement))
                    .toList(),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.presentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.presentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: AppTheme.presentColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['date'],
                  style: TextStyle(fontSize: 12, color: AppTheme.textHintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Goal> _getFilteredGoals() {
    // Mock data - in real app, this would come from goals service
    final allGoals = [
      Goal(
        id: '1',
        studentId: 'student_1',
        title: 'Improve Mathematics Grade',
        description: 'Achieve 90% or higher in all math assignments',
        type: GoalType.academic,
        status: GoalStatus.active,
        priority: GoalPriority.high,
        targetDate: DateTime.now().add(Duration(days: 30)),
        tags: ['mathematics', 'academic'],
        metrics: {'current_grade': 75, 'target_grade': 90},
        progress: 60,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Goal(
        id: '2',
        studentId: 'student_1',
        title: 'Learn Flutter Development',
        description: 'Build 3 mobile apps using Flutter framework',
        type: GoalType.skill,
        status: GoalStatus.active,
        priority: GoalPriority.medium,
        targetDate: DateTime.now().add(Duration(days: 60)),
        tags: ['programming', 'mobile'],
        metrics: {'apps_completed': 1, 'target_apps': 3},
        progress: 33,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Goal(
        id: '3',
        studentId: 'student_1',
        title: 'Complete Data Structures Course',
        description: 'Finish all assignments and projects for DS course',
        type: GoalType.academic,
        status: GoalStatus.completed,
        priority: GoalPriority.high,
        targetDate: DateTime.now().subtract(Duration(days: 5)),
        tags: ['programming', 'academic'],
        metrics: {'assignments_completed': 10, 'target_assignments': 10},
        progress: 100,
        createdAt: DateTime.now().subtract(Duration(days: 90)),
        updatedAt: DateTime.now().subtract(Duration(days: 5)),
      ),
    ];

    return allGoals.where((goal) {
      if (_selectedFilter != 'All') {
        switch (_selectedFilter) {
          case 'Active':
            return goal.status == GoalStatus.active;
          case 'Completed':
            return goal.status == GoalStatus.completed;
          case 'Overdue':
            return goal.targetDate.isBefore(DateTime.now()) &&
                goal.status != GoalStatus.completed;
        }
      }

      if (_selectedPriority != 'All') {
        switch (_selectedPriority) {
          case 'High':
            return goal.priority == GoalPriority.high;
          case 'Medium':
            return goal.priority == GoalPriority.medium;
          case 'Low':
            return goal.priority == GoalPriority.low;
        }
      }

      return true;
    }).toList();
  }

  Map<String, dynamic> _getWeeklyPlan() {
    // Mock data - in real app, this would come from planner service
    return {
      'totalGoals': 5,
      'totalTasks': 12,
      'completedTasks': 8,
      'days': [
        {
          'dayName': 'Monday',
          'date': 'Dec 16',
          'isToday': true,
          'classes': [
            {'time': '09:00', 'subject': 'Data Structures', 'room': 'Room 101'},
            {
              'time': '11:00',
              'subject': 'Database Management',
              'room': 'Lab 2',
            },
          ],
          'goals': [
            {
              'title': 'Complete Math Assignment',
              'type': 'academic',
              'progress': 60,
            },
          ],
          'tasks': [
            {'title': 'Review DS Notes', 'duration': '30 min'},
            {'title': 'Practice Coding Problems', 'duration': '45 min'},
          ],
          'freeTime': [
            {'title': 'Read Physics Chapter', 'duration': '1 hour'},
          ],
        },
        // Add more days...
      ],
    };
  }

  Map<String, dynamic> _getProgressData() {
    // Mock data
    return {
      'completedGoals': 3,
      'totalGoals': 8,
      'completedTasks': 24,
      'totalTasks': 32,
      'categories': [
        {
          'name': 'Academic',
          'completed': 2,
          'total': 4,
          'percentage': 50,
          'color': Colors.blue,
          'icon': Icons.school,
        },
        {
          'name': 'Skills',
          'completed': 1,
          'total': 3,
          'percentage': 33,
          'color': Colors.green,
          'icon': Icons.code,
        },
        {
          'name': 'Personal',
          'completed': 0,
          'total': 1,
          'percentage': 0,
          'color': Colors.purple,
          'icon': Icons.person,
        },
      ],
      'achievements': [
        {
          'title': 'First Goal Completed!',
          'description': 'You completed your first goal. Great job!',
          'date': 'Dec 10, 2024',
        },
        {
          'title': 'Week Streak',
          'description': 'You completed tasks for 7 days in a row!',
          'date': 'Dec 8, 2024',
        },
      ],
    };
  }

  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.academic:
        return Colors.blue;
      case GoalType.career:
        return Colors.green;
      case GoalType.personal:
        return Colors.purple;
      case GoalType.skill:
        return Colors.orange;
    }
  }

  Color _getGoalPriorityColor(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.low:
        return Colors.grey;
      case GoalPriority.medium:
        return Colors.orange;
      case GoalPriority.high:
        return Colors.red;
    }
  }

  void _showCreateGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Goal'),
        content: Text('Goal creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Create goal logic
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _editGoal(Goal goal) {
    // Edit goal logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit goal: ${goal.title}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _deleteGoal(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete goal logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.absentColor,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
