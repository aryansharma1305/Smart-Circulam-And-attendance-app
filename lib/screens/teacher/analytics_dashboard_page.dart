import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../services/analytics_service.dart';
import '../../services/csv_export_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/analytics_chart_widget.dart';
import '../../widgets/export_dialog_widget.dart';

class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() =>
      _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends ConsumerState<AnalyticsDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Date range selection
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedSubject = 'All Subjects';

  // Analytics data
  TeacherAnalytics? _analytics;
  List<SessionAnalytics> _sessionAnalytics = [];
  List<StudentAnalytics> _studentAnalytics = [];
  List<AttendanceTrend> _trends = [];

  bool _isLoading = false;
  String? _errorMessage;

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
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final subjectId = _selectedSubject == 'All Subjects'
          ? null
          : _selectedSubject;

      // Load all analytics data in parallel
      final results = await Future.wait([
        AnalyticsService.getTeacherAnalytics(
          teacherId: user.uid,
          startDate: _startDate,
          endDate: _endDate,
          subjectId: subjectId,
        ),
        AnalyticsService.getSessionAnalytics(
          teacherId: user.uid,
          startDate: _startDate,
          endDate: _endDate,
          subjectId: subjectId,
        ),
        AnalyticsService.getStudentAnalytics(
          teacherId: user.uid,
          startDate: _startDate,
          endDate: _endDate,
          subjectId: subjectId,
        ),
        AnalyticsService.getAttendanceTrends(
          teacherId: user.uid,
          startDate: _startDate,
          endDate: _endDate,
          subjectId: subjectId,
          period: TrendPeriod.daily,
        ),
      ]);

      setState(() {
        _analytics = results[0] as TeacherAnalytics;
        _sessionAnalytics = results[1] as List<SessionAnalytics>;
        _studentAnalytics = results[2] as List<StudentAnalytics>;
        _trends = results[3] as List<AttendanceTrend>;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportToCSV(ExportFormat format) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final subjectId = _selectedSubject == 'All Subjects'
          ? null
          : _selectedSubject;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final filePath = await CSVExportService.exportAnalyticsToCSV(
        teacherId: user.uid,
        startDate: _startDate,
        endDate: _endDate,
        subjectId: subjectId,
        format: format,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message with file path
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved to: $filePath'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'View Files',
            onPressed: () => _showExportedFiles(),
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showExportedFiles() {
    showDialog(context: context, builder: (context) => _ExportedFilesDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _showExportDialog(),
            tooltip: 'Export Reports',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Sessions', icon: Icon(Icons.event)),
            Tab(text: 'Students', icon: Icon(Icons.people)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorWidget()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildSessionsTab(),
                      _buildStudentsTab(),
                      _buildTrendsTab(),
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
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _subjects.map((subject) {
                return DropdownMenuItem(value: subject, child: Text(subject));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSubject = value;
                  });
                  _loadAnalytics();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadAnalytics, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_analytics == null)
      return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildAtRiskStudents(),
          const SizedBox(height: 24),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final analytics = _analytics!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Sessions',
          analytics.totalSessions.toString(),
          Icons.event,
          AppTheme.primaryColor,
        ),
        _buildStatCard(
          'Avg Attendance',
          '${analytics.attendancePercentage.toStringAsFixed(1)}%',
          Icons.people,
          Colors.green,
        ),
        _buildStatCard(
          'At-Risk Students',
          analytics.atRiskCount.toString(),
          Icons.warning,
          Colors.orange,
        ),
        _buildStatCard(
          'Late Percentage',
          '${analytics.latePercentage.toStringAsFixed(1)}%',
          Icons.schedule,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtRiskStudents() {
    final atRiskStudents = _studentAnalytics
        .where((s) => s.isAtRisk)
        .take(5)
        .toList();

    if (atRiskStudents.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No at-risk students found'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'At-Risk Students',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ...atRiskStudents.map((student) => _buildStudentTile(student)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTile(StudentAnalytics student) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: student.isAtRisk ? Colors.red : Colors.green,
        child: Text(
          student.studentName.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(student.studentName),
      subtitle: Text(
        '${student.attendancePercentage.toStringAsFixed(1)}% attendance',
      ),
      trailing: Text(
        '${student.presentClasses}/${student.totalClasses}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildQuickStats() {
    final analytics = _analytics!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Students', analytics.totalStudents.toString()),
            _buildStatRow(
              'Present Students',
              analytics.presentStudents.toString(),
            ),
            _buildStatRow(
              'Absent Students',
              analytics.absentStudents.toString(),
            ),
            _buildStatRow('Late Students', analytics.lateStudents.toString()),
            _buildStatRow(
              'Average Class Size',
              analytics.averageClassSize.toStringAsFixed(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessionAnalytics.length,
      itemBuilder: (context, index) {
        final session = _sessionAnalytics[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getAttendanceColor(
                session.attendancePercentage,
              ),
              child: Text(
                '${session.attendancePercentage.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text('Session ${session.session.id.substring(0, 8)}'),
            subtitle: Text(
              '${session.session.date.day}/${session.session.date.month}/${session.session.date.year} - ${session.session.timetableId}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${session.presentStudents}/${session.totalStudents}'),
                Text(
                  '${session.absentStudents} absent, ${session.lateStudents} late',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: () => _viewSessionDetails(session),
          ),
        );
      },
    );
  }

  Widget _buildStudentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _studentAnalytics.length,
      itemBuilder: (context, index) {
        final student = _studentAnalytics[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: student.isAtRisk ? Colors.red : Colors.green,
              child: Text(
                student.studentName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(student.studentName),
            subtitle: Text(
              '${student.attendancePercentage.toStringAsFixed(1)}% attendance',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${student.presentClasses}/${student.totalClasses}'),
                if (student.currentStreak > 0)
                  Text(
                    '${student.currentStreak} streak',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
              ],
            ),
            onTap: () => _viewStudentDetails(student),
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab() {
    if (_trends.isEmpty) {
      return const Center(
        child: Text('No trend data available for the selected period'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          AnalyticsChartWidget(trends: _trends),
          const SizedBox(height: 24),
          _buildTrendsList(),
        ],
      ),
    );
  }

  Widget _buildTrendsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Trends',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ..._trends.take(10).map((trend) => _buildTrendItem(trend)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(AttendanceTrend trend) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(trend.period),
          Row(
            children: [
              Text('${trend.attendancePercentage.toStringAsFixed(1)}%'),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: trend.attendancePercentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getAttendanceColor(trend.attendancePercentage),
                      borderRadius: BorderRadius.circular(4),
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

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.orange;
    return Colors.red;
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAnalytics();
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportDialogWidget(onExport: _exportToCSV),
    );
  }

  void _viewSessionDetails(SessionAnalytics session) {
    // Navigate to session details page
    // You can implement this based on your routing structure
  }

  void _viewStudentDetails(StudentAnalytics student) {
    // Navigate to student details page
    // You can implement this based on your routing structure
  }
}

class _ExportedFilesDialog extends StatefulWidget {
  @override
  _ExportedFilesDialogState createState() => _ExportedFilesDialogState();
}

class _ExportedFilesDialogState extends State<_ExportedFilesDialog> {
  List<File> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final files = await CSVExportService.getExportedFiles();
      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exported Reports'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _files.isEmpty
            ? const Center(child: Text('No exported files found'))
            : ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  final fileName = file.path.split('/').last;
                  final fileSize = CSVExportService.getFileSize(file);
                  final modifiedDate = file.lastModifiedSync();

                  return ListTile(
                    leading: const Icon(Icons.description, color: Colors.green),
                    title: Text(fileName),
                    subtitle: Text(
                      'Size: $fileSize • Modified: ${modifiedDate.day}/${modifiedDate.month}/${modifiedDate.year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFile(file),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _deleteFile(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await CSVExportService.deleteExportedFile(file.path);
      if (success) {
        _loadFiles(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
