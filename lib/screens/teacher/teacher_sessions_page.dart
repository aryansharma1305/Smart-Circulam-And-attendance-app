import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';

class TeacherSessionsPage extends ConsumerStatefulWidget {
  const TeacherSessionsPage({super.key});

  @override
  ConsumerState<TeacherSessionsPage> createState() =>
      _TeacherSessionsPageState();
}

class _TeacherSessionsPageState extends ConsumerState<TeacherSessionsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  String _selectedSubject = 'All Subjects';

  final List<String> _filters = ['All', 'Today', 'This Week', 'This Month'];
  final List<String> _subjects = [
    'All Subjects',
    'DSA',
    'DBMS',
    'OS',
    'Networks',
  ];

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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Session History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Sessions',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshSessions,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Recent', icon: Icon(Icons.history)),
            Tab(text: 'Live', icon: Icon(Icons.live_tv)),
            Tab(text: 'Scheduled', icon: Icon(Icons.schedule)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecentSessions(),
                _buildLiveSessions(),
                _buildScheduledSessions(),
              ],
            ),
          ),
        ],
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
              value: _selectedFilter,
              decoration: InputDecoration(
                labelText: 'Time Filter',
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
              items: _filters.map((filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(
                    filter,
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                  ),
                );
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
              value: _selectedSubject,
              decoration: InputDecoration(
                labelText: 'Subject',
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
              items: _subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(
                    subject,
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions() {
    final sessions = _getRecentSessions();

    if (sessions.isEmpty) {
      return _buildEmptyState('No recent sessions found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildLiveSessions() {
    final liveSessions = _getLiveSessions();

    if (liveSessions.isEmpty) {
      return _buildEmptyState('No live sessions');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: liveSessions.length,
      itemBuilder: (context, index) {
        final session = liveSessions[index];
        return _buildLiveSessionCard(session);
      },
    );
  }

  Widget _buildScheduledSessions() {
    final scheduledSessions = _getScheduledSessions();

    if (scheduledSessions.isEmpty) {
      return _buildEmptyState('No scheduled sessions');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scheduledSessions.length,
      itemBuilder: (context, index) {
        final session = scheduledSessions[index];
        return _buildScheduledSessionCard(session);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionData session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getSessionStatusColor(session.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${session.attendancePercentage}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                'Present',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
        title: Text(
          session.course,
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
                  Icons.schedule,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${session.startTime} - ${session.endTime}',
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
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  session.room,
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
                  '${session.presentStudents}/${session.totalStudents} students',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getSessionStatusColor(session.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                session.status.toUpperCase(),
                style: TextStyle(
                  color: _getSessionStatusColor(session.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.visibility,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () => _viewSessionDetails(session),
                  tooltip: 'View Details',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.download,
                    color: AppTheme.textSecondaryColor,
                  ),
                  onPressed: () => _exportSession(session),
                  tooltip: 'Export Report',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveSessionCard(SessionData session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.live_tv, color: Colors.white, size: 20),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            session.course,
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
              Text(
                '${session.presentStudents}/${session.totalStudents} students present',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Started at ${session.startTime}',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          trailing: ElevatedButton.icon(
            onPressed: () => _manageLiveSession(session),
            icon: const Icon(Icons.manage_accounts, size: 16),
            label: const Text('Manage'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduledSessionCard(SessionData session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, color: Colors.orange, size: 20),
              Text(
                'UPCOMING',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          session.course,
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
            Text(
              'Scheduled for ${session.startTime}',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${session.totalStudents} students enrolled',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
              onPressed: () => _editScheduledSession(session),
              tooltip: 'Edit Session',
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              onPressed: () => _startScheduledSession(session),
              tooltip: 'Start Session',
            ),
          ],
        ),
      ),
    );
  }

  Color _getSessionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'live':
        return AppTheme.primaryColor;
      case 'scheduled':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Mock data methods
  List<SessionData> _getRecentSessions() {
    return [
      SessionData(
        id: '1',
        course: 'Data Structures',
        room: 'Room 101',
        startTime: '09:00',
        endTime: '10:00',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: 'completed',
        presentStudents: 42,
        totalStudents: 45,
        attendancePercentage: 93,
      ),
      SessionData(
        id: '2',
        course: 'Algorithms',
        room: 'Room 102',
        startTime: '11:00',
        endTime: '12:00',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'completed',
        presentStudents: 38,
        totalStudents: 42,
        attendancePercentage: 90,
      ),
    ];
  }

  List<SessionData> _getLiveSessions() {
    return [
      SessionData(
        id: '3',
        course: 'Database Systems',
        room: 'Room 103',
        startTime: '14:00',
        endTime: '15:00',
        date: DateTime.now(),
        status: 'live',
        presentStudents: 35,
        totalStudents: 40,
        attendancePercentage: 88,
      ),
    ];
  }

  List<SessionData> _getScheduledSessions() {
    return [
      SessionData(
        id: '4',
        course: 'Operating Systems',
        room: 'Room 104',
        startTime: '16:00',
        endTime: '17:00',
        date: DateTime.now().add(const Duration(days: 1)),
        status: 'scheduled',
        presentStudents: 0,
        totalStudents: 38,
        attendancePercentage: 0,
      ),
    ];
  }

  // Action methods
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Sessions'),
        content: const Text('Advanced filtering options coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _refreshSessions() {
    setState(() {
      // Refresh session data
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sessions refreshed!')));
  }

  void _viewSessionDetails(SessionData session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${session.course}')),
    );
  }

  void _exportSession(SessionData session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting report for ${session.course}')),
    );
  }

  void _manageLiveSession(SessionData session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Managing live session: ${session.course}')),
    );
  }

  void _editScheduledSession(SessionData session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing session: ${session.course}')),
    );
  }

  void _startScheduledSession(SessionData session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting session: ${session.course}')),
    );
  }
}

// Mock data class
class SessionData {
  final String id;
  final String course;
  final String room;
  final String startTime;
  final String endTime;
  final DateTime date;
  final String status;
  final int presentStudents;
  final int totalStudents;
  final int attendancePercentage;

  SessionData({
    required this.id,
    required this.course,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.status,
    required this.presentStudents,
    required this.totalStudents,
    required this.attendancePercentage,
  });
}

