import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import 'create_announcement_page.dart';

class Announcement {
  final String id;
  final String course;
  final String section;
  final String title;
  final String message;
  final DateTime sentAt;
  final bool isScheduled;
  final String? attachment;

  Announcement({
    required this.id,
    required this.course,
    required this.section,
    required this.title,
    required this.message,
    required this.sentAt,
    this.isScheduled = false,
    this.attachment,
  });
}

class AnnouncePage extends ConsumerStatefulWidget {
  const AnnouncePage({super.key});

  @override
  ConsumerState<AnnouncePage> createState() => _AnnouncePageState();
}

class _AnnouncePageState extends ConsumerState<AnnouncePage> {
  List<Announcement> announcements = [];
  String searchQuery = '';
  String selectedFilter = 'All';

  final List<String> filters = ['All', 'DSA', 'DBMS', 'OS', 'Networks'];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();

    announcements = [
      Announcement(
        id: '1',
        course: 'DSA',
        section: 'Sec A',
        title: 'Assignment 3 Submission',
        message:
            'Please submit Assignment 3 by Friday. Late submissions will not be accepted.',
        sentAt: now.subtract(const Duration(hours: 2)),
        attachment: 'assignment3.pdf',
      ),
      Announcement(
        id: '2',
        course: 'DBMS',
        section: 'Sec B',
        title: 'Mid-term Exam Schedule',
        message:
            'Mid-term exam will be held on March 15th. Please bring your student ID.',
        sentAt: now.subtract(const Duration(days: 1)),
        isScheduled: true,
      ),
    ];
  }

  List<Announcement> get filteredAnnouncements {
    var filtered = announcements;

    if (selectedFilter != 'All') {
      filtered = filtered.where((a) => a.course == selectedFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (a) =>
                a.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                a.message.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createAnnouncement(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: filteredAnnouncements.isEmpty
                ? _buildEmptyState()
                : _buildAnnouncementsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search announcements...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.announcement_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No announcements yet',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first message',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createAnnouncement(),
            icon: const Icon(Icons.add),
            label: const Text('Create Announcement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAnnouncements.length,
      itemBuilder: (context, index) {
        final announcement = filteredAnnouncements[index];
        return _buildAnnouncementCard(announcement);
      },
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAnnouncementDetail(announcement),
          onLongPress: () => _showDeleteDialog(announcement),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                    if (announcement.isScheduled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Scheduled',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${announcement.course} • ${announcement.section}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  announcement.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(announcement.sentAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    if (announcement.attachment != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.attach_file,
                        size: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        announcement.attachment!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _createAnnouncement() {
    context.push('/teacher/create-announcement');
  }

  void _showAnnouncementDetail(Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(announcement.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${announcement.course} • ${announcement.section}'),
            const SizedBox(height: 8),
            Text(announcement.message),
            if (announcement.attachment != null) ...[
              const SizedBox(height: 8),
              Text('Attachment: ${announcement.attachment}'),
            ],
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

  void _showDeleteDialog(Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text(
          'Are you sure you want to delete "${announcement.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAnnouncement(announcement);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteAnnouncement(Announcement announcement) {
    setState(() {
      announcements.removeWhere((a) => a.id == announcement.id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Deleted "${announcement.title}"')));
  }
}
