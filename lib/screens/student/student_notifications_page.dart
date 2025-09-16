import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

class StudentNotificationsPage extends ConsumerStatefulWidget {
  const StudentNotificationsPage({super.key});

  @override
  ConsumerState<StudentNotificationsPage> createState() =>
      _StudentNotificationsPageState();
}

class _StudentNotificationsPageState
    extends ConsumerState<StudentNotificationsPage> {
  String _selectedFilter = 'all';
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Notifications',
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
            icon: Icon(Icons.filter_list, color: AppTheme.primaryColor),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: Icon(Icons.mark_email_read, color: AppTheme.primaryColor),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          _buildFilterBar(),

          // Notifications List
          Expanded(child: _buildNotificationsList()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('attendance', 'Attendance'),
                      const SizedBox(width: 8),
                      _buildFilterChip('classes', 'Classes'),
                      const SizedBox(width: 8),
                      _buildFilterChip('goals', 'Goals'),
                      const SizedBox(width: 8),
                      _buildFilterChip('system', 'System'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: _showUnreadOnly,
                onChanged: (value) {
                  setState(() {
                    _showUnreadOnly = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Unread only',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
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

  Widget _buildNotificationsList() {
    final notifications = _getFilteredNotifications();

    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 80,
                color: Colors.grey.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'re all caught up!',
                style: TextStyle(fontSize: 14, color: AppTheme.textHintColor),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead
                ? Border.all(color: Colors.grey[200]!, width: 1)
                : Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getNotificationColor(
                  notification.type,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 20,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: notification.isRead
                    ? FontWeight.normal
                    : FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppTheme.textHintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHintColor,
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: notification.action != null
                ? IconButton(
                    onPressed: () => _handleNotificationAction(notification),
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.textHintColor,
                    ),
                  )
                : null,
            onTap: () {
              _markAsRead(notification);
              if (notification.action != null) {
                _handleNotificationAction(notification);
              }
            },
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  List<NotificationItem> _getFilteredNotifications() {
    final allNotifications = _getMockNotifications();

    var filtered = allNotifications.where((notification) {
      if (_selectedFilter != 'all' && notification.type != _selectedFilter) {
        return false;
      }
      if (_showUnreadOnly && notification.isRead) {
        return false;
      }
      return true;
    }).toList();

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  List<NotificationItem> _getMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationItem(
        id: '1',
        title: 'Attendance Marked Successfully',
        message: 'You have been marked present for Data Structures class',
        type: 'attendance',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        action: () => context.go('/student/ledger'),
      ),
      NotificationItem(
        id: '2',
        title: 'Class Starting Soon',
        message: 'Database Management class starts in 10 minutes',
        type: 'classes',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        action: () => context.go('/student/timetable'),
      ),
      NotificationItem(
        id: '3',
        title: 'Goal Achievement',
        message: 'Congratulations! You completed your weekly study goal',
        type: 'goals',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: true,
        action: () => context.go('/student/goals'),
      ),
      NotificationItem(
        id: '4',
        title: 'Free Period Task Available',
        message: 'You have 30 minutes free. Complete a quick math problem set?',
        type: 'goals',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
        action: () => context.go('/student/coach'),
      ),
      NotificationItem(
        id: '5',
        title: 'System Update',
        message: 'New features added to the attendance system',
        type: 'system',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        action: null,
      ),
      NotificationItem(
        id: '6',
        title: 'Attendance Reminder',
        message: 'Don\'t forget to mark attendance for your next class',
        type: 'attendance',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
        action: () => context.go('/student/attendance'),
      ),
      NotificationItem(
        id: '7',
        title: 'Weekly Report Ready',
        message: 'Your weekly attendance report is now available',
        type: 'system',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        action: () => context.go('/student/reports'),
      ),
      NotificationItem(
        id: '8',
        title: 'Class Cancelled',
        message: 'Mathematics class scheduled for today has been cancelled',
        type: 'classes',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
        action: () => context.go('/student/timetable'),
      ),
    ];
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'attendance':
        return Icons.assignment_turned_in;
      case 'classes':
        return Icons.schedule;
      case 'goals':
        return Icons.track_changes;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'attendance':
        return AppTheme.presentColor;
      case 'classes':
        return AppTheme.primaryColor;
      case 'goals':
        return AppTheme.accentColor;
      case 'system':
        return AppTheme.textSecondaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      // In a real app, this would update the backend
      for (var notification in _getMockNotifications()) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppTheme.presentColor,
      ),
    );
  }

  void _handleNotificationAction(NotificationItem notification) {
    if (notification.action != null) {
      notification.action!();
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Show unread only'),
              value: _showUnreadOnly,
              onChanged: (value) {
                setState(() {
                  _showUnreadOnly = value;
                });
                Navigator.pop(context);
              },
              activeColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  bool isRead;
  final VoidCallback? action;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.action,
  });
}
