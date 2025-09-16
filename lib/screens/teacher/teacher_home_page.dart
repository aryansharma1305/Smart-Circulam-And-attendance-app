import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class TeacherClass {
  final String timetableId;
  final String course;
  final String section;
  final String room;
  final DateTime start;
  final DateTime end;
  final int enrolled;
  final String status; // 'planned' | 'live' | 'closed'

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

class TeacherHomePage extends ConsumerStatefulWidget {
  const TeacherHomePage({super.key});

  @override
  ConsumerState<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends ConsumerState<TeacherHomePage> {
  List<TeacherClass> todayClasses = [];
  int pendingExceptions = 3;
  List<Map<String, dynamic>> recentSessions = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    todayClasses = [
      TeacherClass(
        timetableId: 'tt1',
        course: 'DSA',
        section: 'Sec A',
        room: 'Room B201',
        start: today.add(const Duration(hours: 10)),
        end: today.add(const Duration(hours: 10, minutes: 50)),
        enrolled: 52,
        status: 'planned',
      ),
      TeacherClass(
        timetableId: 'tt2',
        course: 'DBMS',
        section: 'Sec B',
        room: 'Room B205',
        start: today.add(const Duration(hours: 14)),
        end: today.add(const Duration(hours: 14, minutes: 50)),
        enrolled: 48,
        status: 'live',
      ),
      TeacherClass(
        timetableId: 'tt3',
        course: 'OS',
        section: 'Sec C',
        room: 'Room B210',
        start: today.add(const Duration(hours: 16)),
        end: today.add(const Duration(hours: 16, minutes: 50)),
        enrolled: 45,
        status: 'closed',
      ),
    ];

    recentSessions = [
      {
        'course': 'DSA',
        'section': 'Sec A',
        'date': 'Yesterday',
        'present': 45,
        'total': 52,
        'percentage': 87,
      },
      {
        'course': 'DBMS',
        'section': 'Sec B',
        'date': '2 days ago',
        'present': 42,
        'total': 48,
        'percentage': 88,
      },
      {
        'course': 'OS',
        'section': 'Sec C',
        'date': '3 days ago',
        'present': 40,
        'total': 45,
        'percentage': 89,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/teacher/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/teacher/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user),
            const SizedBox(height: 24),
            _buildTodayClasses(),
            const SizedBox(height: 24),
            _buildPendingExceptions(),
            const SizedBox(height: 24),
            _buildRecentSessions(),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(User? user) {
    final greeting = _getGreeting();
    final name = user?.name ?? 'Professor';

    return Container(
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, Prof. $name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Here's your schedule for today",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildTodayClasses() {
    if (todayClasses.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Classes",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ...todayClasses.map((cls) => _buildClassCard(cls)),
      ],
    );
  }

  Widget _buildClassCard(TeacherClass cls) {
    final timeFormat = DateFormat('HH:mm');
    final statusColor = _getStatusColor(cls.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cls.course} • ${cls.section}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cls.room,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cls.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${timeFormat.format(cls.start)} – ${timeFormat.format(cls.end)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.people, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text(
                '${cls.enrolled} students',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _startClass(cls),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start Class'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openRoster(cls),
                  icon: const Icon(Icons.people, size: 18),
                  label: const Text('Roster'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openDisplay(cls),
                  icon: const Icon(Icons.qr_code, size: 18),
                  label: const Text('Display QR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planned':
        return Colors.orange;
      case 'live':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No classes today. Your next class: DBMS, tomorrow 9:00 AM.",
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingExceptions() {
    if (pendingExceptions == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You have $pendingExceptions correction requests',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _openExceptions(),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Sessions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...recentSessions.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session['course']} • ${session['section']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                Text(
                  session['date'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session['present']}/${session['total']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              Text(
                '${session['percentage']}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.visibility, size: 18),
            onPressed: () => _viewSession(session),
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildQuickActionCard(
              'Analytics',
              Icons.analytics,
              AppTheme.primaryColor,
              () => context.push('/teacher/analytics-dashboard'),
            ),
            _buildQuickActionCard(
              'Timetable',
              Icons.schedule,
              Colors.blue,
              () => context.push('/teacher/timetable'),
            ),
            _buildQuickActionCard(
              'Announcements',
              Icons.announcement,
              Colors.orange,
              () => context.push('/teacher/announcements'),
            ),
            _buildQuickActionCard(
              'Past Sessions',
              Icons.history,
              Colors.green,
              () => context.push('/teacher/sessions'),
            ),
            _buildQuickActionCard(
              'Students',
              Icons.people,
              Colors.purple,
              () => context.push('/teacher/roster'),
            ),
            _buildQuickActionCard(
              'Settings',
              Icons.settings,
              Colors.grey,
              () => context.push('/teacher/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startClass(TeacherClass cls) {
    context.push('/teacher/start-session', extra: cls);
  }

  void _openRoster(TeacherClass cls) {
    context.push('/teacher/roster', extra: cls);
  }

  void _openDisplay(TeacherClass cls) {
    context.push('/teacher/attendance-display', extra: cls);
  }

  void _openExceptions() {
    context.push('/teacher/attendance-exceptions');
  }

  void _viewSession(Map<String, dynamic> session) {
    // Navigate to session details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${session['course']} session')),
    );
  }
}
