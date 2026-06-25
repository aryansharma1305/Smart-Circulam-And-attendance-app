import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/attendance_exception.dart';
import '../../controllers/exception_controller.dart';

class AttendanceExceptionsPage extends ConsumerStatefulWidget {
  const AttendanceExceptionsPage({super.key});

  @override
  ConsumerState<AttendanceExceptionsPage> createState() =>
      _AttendanceExceptionsPageState();
}

class _AttendanceExceptionsPageState
    extends ConsumerState<AttendanceExceptionsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    switch (_tabController.index) {
      case 0:
        _selectedFilter = 'all';
        break;
      case 1:
        _selectedFilter = 'pending';
        break;
      case 2:
        _selectedFilter = 'approved';
        break;
      case 3:
        _selectedFilter = 'rejected';
        break;
    }
    setState(() {});
  }

  List<AttendanceException> _applyFilter(List<AttendanceException> all) {
    final filtered = all.where((exception) {
      // Filter by status
      bool statusMatch = true;
      switch (_selectedFilter) {
        case 'pending':
          statusMatch = exception.isPending || exception.isUnderReview;
          break;
        case 'approved':
          statusMatch = exception.isApproved;
          break;
        case 'rejected':
          statusMatch = exception.isRejected;
          break;
      }

      // Filter by search query
      bool searchMatch =
          _searchQuery.isEmpty ||
          exception.studentName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          exception.reason.toLowerCase().contains(_searchQuery.toLowerCase());

      return statusMatch && searchMatch;
    }).toList();

    // Sort by urgency and date
    filtered.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      return b.requestedAt.compareTo(a.requestedAt);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(exceptionControllerProvider);
    final all = allAsync.value ?? [];
    final filtered = _applyFilter(all);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Attendance Exceptions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'All (${all.length})'),
            Tab(
              text:
                  'Pending (${all.where((e) => e.isPending || e.isUnderReview).length})',
            ),
            Tab(
              text:
                  'Approved (${all.where((e) => e.isApproved).length})',
            ),
            Tab(
              text:
                  'Rejected (${all.where((e) => e.isRejected).length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsCards(all),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExceptionsList(filtered),
                _buildExceptionsList(filtered),
                _buildExceptionsList(filtered),
                _buildExceptionsList(filtered),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by student name or reason...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.textSecondaryColor,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildStatsCards(List<AttendanceException> all) {
    final pendingCount = all
        .where((e) => e.isPending || e.isUnderReview)
        .length;
    final urgentCount = all.where((e) => e.isUrgent).length;
    final todayCount = all
        .where((e) => DateTime.now().difference(e.requestedAt).inDays == 0)
        .length;

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending Review',
              pendingCount.toString(),
              Icons.pending_actions,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Urgent',
              urgentCount.toString(),
              Icons.priority_high,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Today',
              todayCount.toString(),
              Icons.today,
              AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
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

  Widget _buildExceptionsList(List<AttendanceException> filtered) {
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final exception = filtered[index];
        return _buildExceptionCard(exception, index);
      },
    );
  }

  Widget _buildExceptionCard(AttendanceException exception, int index) {
    final statusColor = _getStatusColor(exception.status);
    final typeColor = _getTypeColor(exception.type);

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: exception.isUrgent
                ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                exception.studentName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              if (exception.isUrgent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'URGENT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exception.studentEmail,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            exception.statusDisplayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exception.daysSinceRequest}d ago',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exception Type
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            exception.typeDisplayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (exception.hasDocument)
                          Icon(
                            Icons.attach_file,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Status Change
                    if (exception.originalStatus != null &&
                        exception.requestedStatus != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                exception.originalStatus!.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                exception.requestedStatus!.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Reason
                    Text(
                      'Reason:',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exception.reason,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),

                    // Reviewer Comments (if any)
                    if (exception.reviewerComments != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Teacher Comments:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exception.reviewerComments!,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Action Buttons
                    if (exception.isPending || exception.isUnderReview)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _approveException(exception),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _rejectException(exception),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _viewExceptionDetails(exception),
                            icon: const Icon(Icons.visibility),
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 400.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No exceptions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All attendance exceptions have been reviewed',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ExceptionStatus status) {
    switch (status) {
      case ExceptionStatus.pending:
        return Colors.orange;
      case ExceptionStatus.approved:
        return Colors.green;
      case ExceptionStatus.rejected:
        return Colors.red;
      case ExceptionStatus.underReview:
        return Colors.blue;
    }
  }

  Color _getTypeColor(ExceptionType type) {
    switch (type) {
      case ExceptionType.lateArrival:
        return Colors.orange;
      case ExceptionType.medicalLeave:
        return Colors.red;
      case ExceptionType.technicalIssue:
        return Colors.blue;
      case ExceptionType.wronglyMarkedAbsent:
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  void _approveException(AttendanceException exception) {
    _showApprovalDialog(exception, true);
  }

  void _rejectException(AttendanceException exception) {
    _showApprovalDialog(exception, false);
  }

  void _showApprovalDialog(AttendanceException exception, bool isApproval) {
    final TextEditingController commentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproval ? 'Approve Exception' : 'Reject Exception'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${exception.studentName}'),
            Text('Type: ${exception.typeDisplayName}'),
            const SizedBox(height: 16),
            TextField(
              controller: commentsController,
              decoration: const InputDecoration(
                labelText: 'Comments (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _processException(exception, isApproval, commentsController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproval ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isApproval ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _processException(
    AttendanceException exception,
    bool isApproval,
    String comments,
  ) {
    ref.read(exceptionControllerProvider.notifier).review(
      exception.id,
      isApproval ? ExceptionStatus.approved : ExceptionStatus.rejected,
      comments: comments.isNotEmpty ? comments : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exception ${isApproval ? 'approved' : 'rejected'} successfully',
        ),
        backgroundColor: isApproval ? Colors.green : Colors.red,
      ),
    );
  }

  void _viewExceptionDetails(AttendanceException exception) {
    // Navigate to detailed view or show detailed dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exception Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Student', exception.studentName),
              _buildDetailRow('Email', exception.studentEmail),
              _buildDetailRow('Type', exception.typeDisplayName),
              _buildDetailRow('Status', exception.statusDisplayName),
              _buildDetailRow(
                'Requested',
                DateFormat('MMM dd, yyyy HH:mm').format(exception.requestedAt),
              ),
              if (exception.reviewedAt != null)
                _buildDetailRow(
                  'Reviewed',
                  DateFormat(
                    'MMM dd, yyyy HH:mm',
                  ).format(exception.reviewedAt!),
                ),
              const SizedBox(height: 12),
              const Text(
                'Reason:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(exception.reason),
              if (exception.hasDocument) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // Open document
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening document...')),
                    );
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('View Document'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // Show additional filtering options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Additional filters coming soon...'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Reset filters
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'all';
                  _tabController.index = 0;
                });
                Navigator.pop(context);
              },
              child: const Text('Reset Filters'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
