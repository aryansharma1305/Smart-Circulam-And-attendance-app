import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

class StudentCalendarPage extends ConsumerStatefulWidget {
  const StudentCalendarPage({super.key});

  @override
  ConsumerState<StudentCalendarPage> createState() => _StudentCalendarPageState();
}

class _StudentCalendarPageState extends ConsumerState<StudentCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _viewMode = 'month'; // month, week, day

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Calendar',
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
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _viewMode = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'month',
                child: Text('Month View'),
              ),
              const PopupMenuItem(
                value: 'week',
                child: Text('Week View'),
              ),
              const PopupMenuItem(
                value: 'day',
                child: Text('Day View'),
              ),
            ],
            icon: Icon(Icons.view_module, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: Column(
        children: [
          // View Mode Selector
          _buildViewModeSelector(),
          
          // Calendar
          Expanded(
            child: _buildCalendarContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildViewModeButton('month', 'Month', Icons.calendar_month),
          _buildViewModeButton('week', 'Week', Icons.calendar_view_week),
          _buildViewModeButton('day', 'Day', Icons.calendar_today),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.3);
  }

  Widget _buildViewModeButton(String mode, String label, IconData icon) {
    final isSelected = _viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _viewMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarContent() {
    switch (_viewMode) {
      case 'month':
        return _buildMonthView();
      case 'week':
        return _buildWeekView();
      case 'day':
        return _buildDayView();
      default:
        return _buildMonthView();
    }
  }

  Widget _buildMonthView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TableCalendar<String>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: AppTheme.textSecondaryColor),
          holidayTextStyle: TextStyle(color: AppTheme.absentColor),
          defaultTextStyle: TextStyle(color: AppTheme.textPrimaryColor),
          selectedTextStyle: const TextStyle(color: Colors.white),
          todayTextStyle: TextStyle(color: AppTheme.primaryColor),
          selectedDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppTheme.accentColor,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primaryColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.3);
  }

  Widget _buildWeekView() {
    final weekStart = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    final weekDays = List.generate(7, (index) => weekStart.add(Duration(days: index)));
    
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
      child: Column(
        children: [
          // Week Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Week of ${DateFormat('MMM d').format(weekStart)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                        });
                      },
                      icon: Icon(Icons.chevron_left, color: AppTheme.primaryColor),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedDay = _focusedDay.add(const Duration(days: 7));
                        });
                      },
                      icon: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Week Days
          Expanded(
            child: ListView.builder(
              itemCount: weekDays.length,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                final isToday = isSameDay(day, DateTime.now());
                final isSelected = isSameDay(day, _selectedDay);
                final events = _getEventsForDay(day);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          child: Column(
                            children: [
                              Text(
                                DateFormat('E').format(day),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                                ),
                              ),
                              Text(
                                day.day.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (events.isNotEmpty)
                                ...events.map((event) => _buildEventChip(event, day))
                              else
                                Text(
                                  'No classes scheduled',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textHintColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (events.isNotEmpty)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.3);
  }

  Widget _buildDayView() {
    final selectedDate = _selectedDay ?? DateTime.now();
    final events = _getEventsForDay(selectedDate);
    
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
      child: Column(
        children: [
          // Day Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(selectedDate),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM d, y').format(selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDay = selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                      icon: Icon(Icons.chevron_left, color: AppTheme.primaryColor),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDay = selectedDate.add(const Duration(days: 1));
                        });
                      },
                      icon: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Day Events
          Expanded(
            child: events.isEmpty
                ? _buildEmptyDayState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _buildEventCard(event, selectedDate);
                    },
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.3);
  }

  Widget _buildEmptyDayState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No classes scheduled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy your free day!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textHintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventChip(String event, DateTime day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        event,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEventCard(String event, DateTime day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '9:00 AM - 10:30 AM', // Mock time
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.textHintColor,
          ),
        ],
      ),
    );
  }

  List<String> _getEventsForDay(DateTime day) {
    // Mock data - in real app, this would come from timetable service
    final mockEvents = {
      DateTime(2024, 12, 16): ['Data Structures', 'Database Management'],
      DateTime(2024, 12, 17): ['Mathematics', 'Computer Networks'],
      DateTime(2024, 12, 18): ['Data Structures', 'Database Management'],
      DateTime(2024, 12, 19): ['Software Engineering'],
      DateTime(2024, 12, 20): ['Mathematics', 'Computer Networks'],
    };
    
    return mockEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }
}
