import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class CreateAnnouncementPage extends ConsumerStatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  ConsumerState<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends ConsumerState<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _attachmentController = TextEditingController();
  
  String selectedCourse = 'DSA';
  String selectedSection = 'Sec A';
  bool isScheduled = false;
  DateTime? scheduledDate;

  final List<String> courses = ['DSA', 'DBMS', 'OS', 'Networks'];
  final List<String> sections = ['Sec A', 'Sec B', 'Sec C'];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Create Announcement'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _sendAnnouncement,
            child: const Text(
              'Send',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseSectionSelector(),
              const SizedBox(height: 24),
              _buildTitleField(),
              const SizedBox(height: 24),
              _buildMessageField(),
              const SizedBox(height: 24),
              _buildAttachmentField(),
              const SizedBox(height: 24),
              _buildSchedulingOptions(),
              const SizedBox(height: 32),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseSectionSelector() {
    return Container(
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
          const Text(
            'Course & Section',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedCourse,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: courses.map((course) {
                    return DropdownMenuItem(
                      value: course,
                      child: Text(course),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCourse = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedSection,
                  decoration: const InputDecoration(
                    labelText: 'Section',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: sections.map((section) {
                    return DropdownMenuItem(
                      value: section,
                      child: Text(section),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSection = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
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
          const Text(
            'Title',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Enter announcement title',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Title is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageField() {
    return Container(
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
          const Text(
            'Message',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _messageController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter your message...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentField() {
    return Container(
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
          const Text(
            'Attachment/Link (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _attachmentController,
            decoration: const InputDecoration(
              hintText: 'Enter file name or link',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulingOptions() {
    return Container(
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
          const Text(
            'Scheduling',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Schedule for later'),
            subtitle: Text(
              isScheduled 
                ? scheduledDate != null 
                  ? 'Scheduled for ${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}'
                  : 'Select date and time'
                : 'Send immediately',
            ),
            value: isScheduled,
            onChanged: (value) {
              setState(() {
                isScheduled = value;
                if (!value) {
                  scheduledDate = null;
                }
              });
            },
          ),
          if (isScheduled) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _selectScheduleDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                scheduledDate != null 
                  ? 'Change Date & Time'
                  : 'Select Date & Time',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _sendAnnouncement,
        icon: const Icon(Icons.send),
        label: Text(
          isScheduled ? 'Schedule Announcement' : 'Send Announcement',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _selectScheduleDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: scheduledDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          scheduledDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _sendAnnouncement() {
    if (_formKey.currentState!.validate()) {
      if (isScheduled && scheduledDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date and time for scheduling'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Simulate sending
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isScheduled 
              ? 'Announcement scheduled for ${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}'
              : 'Announcement sent to $selectedSection',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      context.pop();
    }
  }
}