import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class TimetablePage extends ConsumerStatefulWidget {
  const TimetablePage({super.key});

  @override
  ConsumerState<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends ConsumerState<TimetablePage> {
  int _selectedDay = 0;
  final List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  final List<String> _fullWeekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Timetable',
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
            icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Week Selector
          _buildWeekSelector(),

          // Day Selector
          _buildDaySelector(),

          // Schedule Content
          Expanded(child: _buildScheduleContent()),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week of Dec 16, 2024',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chevron_left,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chevron_right,
                      color: AppTheme.primaryColor,
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

  Widget _buildDaySelector() {
    return Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _weekDays.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedDay == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = index;
                  });
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekDays[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${15 + index}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildScheduleContent() {
    final selectedDayName = _fullWeekDays[_selectedDay];
    final schedules = _getMockSchedules(selectedDayName);

    return Container(
          margin: const EdgeInsets.all(16),
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
          child: schedules.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return _buildClassCard(schedule);
                  },
                ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'No classes scheduled for ${_fullWeekDays[_selectedDay]}',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy your free day!',
            style: TextStyle(fontSize: 14, color: AppTheme.textHintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.class_, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule['subject'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule['teacher'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textHintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHintColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.textHintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule['room'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              schedule['type'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockSchedules(String dayName) {
    // Mock data - in real app, this would come from timetable service
    final schedules = {
      'Monday': [
        {
          'subject': 'Data Structures',
          'teacher': 'Dr. Smith',
          'time': '09:00 - 10:30',
          'room': 'Room 101',
          'type': 'Lecture',
        },
        {
          'subject': 'Database Management',
          'teacher': 'Prof. Johnson',
          'time': '11:00 - 12:30',
          'room': 'Lab 2',
          'type': 'Lab',
        },
        {
          'subject': 'Software Engineering',
          'teacher': 'Ms. Davis',
          'time': '14:00 - 15:30',
          'room': 'Room 205',
          'type': 'Lecture',
        },
      ],
      'Tuesday': [
        {
          'subject': 'Mathematics',
          'teacher': 'Dr. Wilson',
          'time': '10:00 - 11:30',
          'room': 'Room 301',
          'type': 'Lecture',
        },
        {
          'subject': 'Computer Networks',
          'teacher': 'Prof. Brown',
          'time': '13:00 - 14:30',
          'room': 'Lab 3',
          'type': 'Lab',
        },
      ],
      'Wednesday': [
        {
          'subject': 'Data Structures',
          'teacher': 'Dr. Smith',
          'time': '09:00 - 10:30',
          'room': 'Room 101',
          'type': 'Lecture',
        },
        {
          'subject': 'Database Management',
          'teacher': 'Prof. Johnson',
          'time': '11:00 - 12:30',
          'room': 'Lab 2',
          'type': 'Lab',
        },
      ],
      'Thursday': [
        {
          'subject': 'Software Engineering',
          'teacher': 'Ms. Davis',
          'time': '14:00 - 15:30',
          'room': 'Room 205',
          'type': 'Lecture',
        },
      ],
      'Friday': [
        {
          'subject': 'Mathematics',
          'teacher': 'Dr. Wilson',
          'time': '10:00 - 11:30',
          'room': 'Room 301',
          'type': 'Lecture',
        },
        {
          'subject': 'Computer Networks',
          'teacher': 'Prof. Brown',
          'time': '13:00 - 14:30',
          'room': 'Lab 3',
          'type': 'Lab',
        },
      ],
      'Saturday': [],
      'Sunday': [],
    };

    return (schedules[dayName] as List<Map<String, dynamic>>?) ?? [];
  }
}
