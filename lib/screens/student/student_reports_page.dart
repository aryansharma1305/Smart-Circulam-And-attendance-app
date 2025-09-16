import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

class StudentReportsPage extends ConsumerStatefulWidget {
  const StudentReportsPage({super.key});

  @override
  ConsumerState<StudentReportsPage> createState() => _StudentReportsPageState();
}

class _StudentReportsPageState extends ConsumerState<StudentReportsPage> {
  String _selectedReportType = 'attendance';
  String _selectedPeriod = 'week';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Reports',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Type Selector
            _buildReportTypeSelector(),
            
            const SizedBox(height: 24),
            
            // Period Selector
            _buildPeriodSelector(),
            
            const SizedBox(height: 24),
            
            // Date Range Selector
            _buildDateRangeSelector(),
            
            const SizedBox(height: 24),
            
            // Generate Report Button
            _buildGenerateButton(),
            
            const SizedBox(height: 24),
            
            // Report Preview
            _buildReportPreview(),
            
            const SizedBox(height: 24),
            
            // Available Reports
            _buildAvailableReports(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
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
            'Report Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildReportTypeChip('attendance', 'Attendance Report', Icons.assignment),
              _buildReportTypeChip('timetable', 'Timetable Report', Icons.schedule),
              _buildReportTypeChip('goals', 'Goals Progress', Icons.track_changes),
              _buildReportTypeChip('routine', 'Daily Routine', Icons.today),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.3);
  }

  Widget _buildReportTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedReportType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReportType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
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
            'Time Period',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPeriodChip('week', 'This Week'),
              const SizedBox(width: 12),
              _buildPeriodChip('month', 'This Month'),
              const SizedBox(width: 12),
              _buildPeriodChip('semester', 'This Semester'),
              const SizedBox(width: 12),
              _buildPeriodChip('custom', 'Custom Range'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.3);
  }

  Widget _buildPeriodChip(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    if (_selectedPeriod != 'custom') return const SizedBox.shrink();
    
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
            'Date Range',
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
                child: _buildDateField('From', _selectedDate),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField('To', _selectedDate.add(const Duration(days: 7))),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.3);
  }

  Widget _buildDateField(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (selectedDate != null) {
              setState(() {
                _selectedDate = selectedDate;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, y').format(date),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _generateReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.file_download, size: 20),
        label: const Text(
          'Generate Report',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.3);
  }

  Widget _buildReportPreview() {
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
            'Report Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildPreviewContent(),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.3);
  }

  Widget _buildPreviewContent() {
    switch (_selectedReportType) {
      case 'attendance':
        return _buildAttendancePreview();
      case 'timetable':
        return _buildTimetablePreview();
      case 'goals':
        return _buildGoalsPreview();
      case 'routine':
        return _buildRoutinePreview();
      default:
        return _buildAttendancePreview();
    }
  }

  Widget _buildAttendancePreview() {
    return Column(
      children: [
        _buildPreviewRow('Total Classes', '24'),
        _buildPreviewRow('Present', '22'),
        _buildPreviewRow('Absent', '2'),
        _buildPreviewRow('Attendance %', '91.7%'),
        _buildPreviewRow('Current Streak', '5 days'),
      ],
    );
  }

  Widget _buildTimetablePreview() {
    return Column(
      children: [
        _buildPreviewRow('Total Classes This Week', '15'),
        _buildPreviewRow('Subjects', '5'),
        _buildPreviewRow('Total Hours', '30'),
        _buildPreviewRow('Free Periods', '8'),
      ],
    );
  }

  Widget _buildGoalsPreview() {
    return Column(
      children: [
        _buildPreviewRow('Total Goals', '8'),
        _buildPreviewRow('Completed', '3'),
        _buildPreviewRow('In Progress', '4'),
        _buildPreviewRow('Not Started', '1'),
        _buildPreviewRow('Completion %', '37.5%'),
      ],
    );
  }

  Widget _buildRoutinePreview() {
    return Column(
      children: [
        _buildPreviewRow('Total Tasks', '12'),
        _buildPreviewRow('Completed', '8'),
        _buildPreviewRow('Pending', '4'),
        _buildPreviewRow('Completion %', '66.7%'),
        _buildPreviewRow('Productivity Score', '8.5/10'),
      ],
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableReports() {
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
            'Available Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildReportItem(
            'Weekly Attendance Report',
            'Detailed attendance summary for the week',
            'PDF',
            '2.3 MB',
            Icons.assignment,
          ),
          _buildReportItem(
            'Monthly Progress Report',
            'Comprehensive monthly progress analysis',
            'PDF',
            '4.1 MB',
            Icons.analytics,
          ),
          _buildReportItem(
            'Goals Achievement Report',
            'Progress towards your academic goals',
            'PDF',
            '1.8 MB',
            Icons.track_changes,
          ),
          _buildReportItem(
            'Daily Routine Report',
            'Your daily routine and task completion',
            'PDF',
            '1.2 MB',
            Icons.today,
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.3);
  }

  Widget _buildReportItem(String title, String description, String format, String size, IconData icon) {
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        format,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      size,
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
          IconButton(
            onPressed: () {
              // TODO: Implement download
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading $title...'),
                  backgroundColor: AppTheme.presentColor,
                ),
              );
            },
            icon: Icon(Icons.download, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  void _generateReport() {
    // TODO: Implement report generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating ${_selectedReportType} report...'),
        backgroundColor: AppTheme.presentColor,
      ),
    );
  }
}
