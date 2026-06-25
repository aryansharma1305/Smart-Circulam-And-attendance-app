import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/in_app_notification.dart';
import '../../providers/notification_provider.dart';

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
    final notificationsAsync = ref.watch(inAppNotificationsProvider);

    return notificationsAsync.when(
      data: (allNotifications) {
        final notifications = _getFilteredNotifications(allNotifications);

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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Unable to load notifications: $error')),
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

  Widget _buildNotificationCard(InAppNotification notification) {
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
                  _filterType(notification.type),
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getNotificationIcon(_filterType(notification.type)),
                color: _getNotificationColor(_filterType(notification.type)),
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
                      _formatTime(notification.createdAt),
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
            trailing: notification.actionRoute != null
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
              if (notification.actionRoute != null) {
                _handleNotificationAction(notification);
              }
            },
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  List<InAppNotification> _getFilteredNotifications(
    List<InAppNotification> allNotifications,
  ) {
    var filtered = allNotifications.where((notification) {
      if (_selectedFilter != 'all' &&
          _filterType(notification.type) != _selectedFilter) {
        return false;
      }
      if (_showUnreadOnly && notification.isRead) {
        return false;
      }
      return true;
    }).toList();

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  String _filterType(InAppNotificationType type) {
    switch (type) {
      case InAppNotificationType.attendance:
      case InAppNotificationType.exception:
        return 'attendance';
      case InAppNotificationType.classUpdate:
      case InAppNotificationType.announcement:
        return 'classes';
      case InAppNotificationType.goal:
        return 'goals';
      case InAppNotificationType.system:
        return 'system';
    }
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

  void _markAsRead(InAppNotification notification) {
    if (notification.isRead) return;
    ref.read(markInAppNotificationReadProvider(notification.id));
  }

  void _markAllAsRead() {
    ref.read(markAllInAppNotificationsReadProvider.future);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppTheme.presentColor,
      ),
    );
  }

  void _handleNotificationAction(InAppNotification notification) {
    final route = notification.actionRoute;
    if (route != null) {
      context.go(route);
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
