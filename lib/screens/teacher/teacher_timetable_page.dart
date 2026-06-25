import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';

class TeacherTimetablePage extends ConsumerStatefulWidget {
  const TeacherTimetablePage({super.key});

  @override
  ConsumerState<TeacherTimetablePage> createState() =>
      _TeacherTimetablePageState();
}

class _TeacherTimetablePageState extends ConsumerState<TeacherTimetablePage> {
  String _selectedDay = 'Monday';
  String _selectedWeek = 'Current Week';

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _weeks = ['Current Week', 'Next Week', 'Previous Week'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Timetable',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _showCalendarView,
            tooltip: 'Calendar View',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshTimetable,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildTimetableContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewClass,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: InputDecoration(
                labelText: 'Day',
                labelStyle: const TextStyle(color: AppTheme.textPrimaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: AppTheme.textPrimaryColor),
              items: _days.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(
                    day,
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value!;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedWeek,
              decoration: InputDecoration(
                labelText: 'Week',
                labelStyle: const TextStyle(color: AppTheme.textPrimaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: AppTheme.textPrimaryColor),
              items: _weeks.map((week) {
                return DropdownMenuItem(
                  value: week,
                  child: Text(
                    week,
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWeek = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayHeader(),
          const SizedBox(height: 16),
          _buildTimeSlots(),
          const SizedBox(height: 24),
          _buildUpcomingClasses(),
          const SizedBox(height: 24),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildDayHeader() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedDay,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _selectedWeek,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_getClassesForDay().length} Classes',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    final classes = _getClassesForDay();

    if (classes.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No classes scheduled for $_selectedDay',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Add a new class to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Schedule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...classes.map((classData) => _buildClassCard(classData)),
      ],
    );
  }

  Widget _buildClassCard(TeacherClass classData) {
    final isCurrentClass = _isCurrentClass(classData);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrentClass ? 6 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isCurrentClass
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          isThreeLine: true,
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getClassStatusColor(classData),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${classData.start.hour.toString().padLeft(2, '0')}:${classData.start.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${classData.end.hour.toString().padLeft(2, '0')}:${classData.end.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
          title: Text(
            classData.course,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    classData.room,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.people,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${classData.enrolled} students',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: SizedBox(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getClassStatusColor(classData).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getClassStatusText(classData),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _getClassStatusColor(classData),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: AppTheme.primaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _startClass(classData),
                        tooltip: 'Start Class',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppTheme.textSecondaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _editClass(classData),
                        tooltip: 'Edit Class',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingClasses() {
    final upcomingClasses = _getUpcomingClasses();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Classes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            if (upcomingClasses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No upcoming classes',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...upcomingClasses
                  .take(3)
                  .map((classData) => _buildUpcomingClassItem(classData)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingClassItem(TeacherClass classData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${classData.start.hour.toString().padLeft(2, '0')}:${classData.start.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classData.course,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                Text(
                  '${classData.room} • ${classData.enrolled} students',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getTimeUntilClass(classData),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
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
                  child: _buildStatItem(
                    'Today\'s Classes',
                    '${_getClassesForDay().length}',
                    Icons.event,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Total Students',
                    '${_getTotalStudents()}',
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'This Week',
                    '${_getClassesThisWeek()}',
                    Icons.calendar_view_week,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Next Class',
                    _getNextClassTime(),
                    Icons.schedule,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<TeacherClass> _getClassesForDay() {
    // Mock data - replace with actual data from your service
    final today = DateTime.now();

    return [
      TeacherClass(
        timetableId: 'tt1',
        course: 'Data Structures',
        section: 'CS-A',
        room: 'Room 101',
        start: today.add(const Duration(hours: 9)),
        end: today.add(const Duration(hours: 10)),
        enrolled: 45,
        status: 'planned',
      ),
      TeacherClass(
        timetableId: 'tt2',
        course: 'Algorithms',
        section: 'CS-B',
        room: 'Room 102',
        start: today.add(const Duration(hours: 11)),
        end: today.add(const Duration(hours: 12)),
        enrolled: 42,
        status: 'planned',
      ),
      TeacherClass(
        timetableId: 'tt3',
        course: 'Database Systems',
        section: 'CS-C',
        room: 'Room 103',
        start: today.add(const Duration(hours: 14)),
        end: today.add(const Duration(hours: 15)),
        enrolled: 38,
        status: 'planned',
      ),
    ];
  }

  List<TeacherClass> _getUpcomingClasses() {
    final now = DateTime.now();
    return _getClassesForDay()
        .where((classData) => classData.start.isAfter(now))
        .toList();
  }

  bool _isCurrentClass(TeacherClass classData) {
    final now = DateTime.now();
    return now.isAfter(classData.start) && now.isBefore(classData.end);
  }

  Color _getClassStatusColor(TeacherClass classData) {
    final now = DateTime.now();
    if (now.isAfter(classData.start) && now.isBefore(classData.end)) {
      return AppTheme.primaryColor; // Current
    } else if (classData.start.isAfter(now)) {
      return Colors.green; // Upcoming
    } else {
      return Colors.grey; // Past
    }
  }

  String _getClassStatusText(TeacherClass classData) {
    final now = DateTime.now();
    if (now.isAfter(classData.start) && now.isBefore(classData.end)) {
      return 'LIVE';
    } else if (classData.start.isAfter(now)) {
      return 'UPCOMING';
    } else {
      return 'COMPLETED';
    }
  }

  String _getTimeUntilClass(TeacherClass classData) {
    final now = DateTime.now();
    final difference = classData.start.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  int _getTotalStudents() {
    return _getClassesForDay().fold(
      0,
      (sum, classData) => sum + classData.enrolled,
    );
  }

  int _getClassesThisWeek() {
    return _getClassesForDay().length * 5; // Mock calculation
  }

  String _getNextClassTime() {
    final upcoming = _getUpcomingClasses();
    if (upcoming.isEmpty) return 'None';

    final nextClass = upcoming.first;
    return '${nextClass.start.hour.toString().padLeft(2, '0')}:${nextClass.start.minute.toString().padLeft(2, '0')}';
  }

  // Action methods
  void _showCalendarView() {
    // Implement calendar view
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Calendar view coming soon!')));
  }

  void _refreshTimetable() {
    setState(() {
      // Refresh timetable data
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Timetable refreshed!')));
  }

  void _addNewClass() {
    // Navigate to add class page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add class feature coming soon!')),
    );
  }

  void _startClass(TeacherClass classData) {
    // Navigate to start session page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting class: ${classData.course}')),
    );
  }

  void _editClass(TeacherClass classData) {
    // Navigate to edit class page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing class: ${classData.course}')),
    );
  }
}

// Mock data class - replace with your actual TeacherClass model
class TeacherClass {
  final String timetableId;
  final String course;
  final String section;
  final String room;
  final DateTime start;
  final DateTime end;
  final int enrolled;
  final String status;

  TeacherClass({
    required this.timetableId,
    required this.course,
    required this.section,
    required this.room,
    required this.start,
    required this.end,
    required this.enrolled,
    required this.status,
  });
}
