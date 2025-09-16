import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class StudentProfilePage extends ConsumerStatefulWidget {
  const StudentProfilePage({super.key});

  @override
  ConsumerState<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends ConsumerState<StudentProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _sectionController = TextEditingController();

  List<String> _selectedInterests = [];
  List<String> _selectedStrengths = [];
  List<String> _selectedGoals = [];

  bool _notificationsEnabled = true;
  bool _attendanceReminders = true;
  bool _darkMode = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _departmentController.text = user.department ?? '';
      _yearController.text = user.year ?? '';
      _sectionController.text = user.section ?? '';
      _selectedInterests = List.from(user.interests);
      _selectedStrengths = List.from(user.strengths);
      _selectedGoals = List.from(user.goals);
      _notificationsEnabled = user.preferences['notifications'] ?? true;
      _attendanceReminders = user.preferences['attendance_reminders'] ?? true;
      _darkMode = user.preferences['dark_mode'] ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
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
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.primaryColor),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: user != null
          ? _buildProfileContent(user)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileContent(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(user),

          const SizedBox(height: 24),

          // Personal Information
          _buildSectionTitle('Personal Information'),
          _buildPersonalInfoSection(),

          const SizedBox(height: 24),

          // Academic Information
          _buildSectionTitle('Academic Information'),
          _buildAcademicInfoSection(),

          const SizedBox(height: 24),

          // Interests & Goals
          _buildSectionTitle('Interests & Goals'),
          _buildInterestsSection(),

          const SizedBox(height: 24),

          // Preferences
          _buildSectionTitle('Preferences'),
          _buildPreferencesSection(),

          const SizedBox(height: 24),

          // Account Actions
          _buildSectionTitle('Account'),
          _buildAccountActions(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
          padding: const EdgeInsets.all(24),
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
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.roleDisplayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
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
            children: [
              _buildInfoField('Full Name', _nameController, Icons.person),
              const SizedBox(height: 16),
              _buildInfoField('Email', _emailController, Icons.email),
              const SizedBox(height: 16),
              _buildInfoField('Phone', _phoneController, Icons.phone),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildAcademicInfoSection() {
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
            children: [
              _buildInfoField(
                'Department',
                _departmentController,
                Icons.school,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      'Year',
                      _yearController,
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoField(
                      'Section',
                      _sectionController,
                      Icons.group,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildInterestsSection() {
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
              _buildChipSection(
                'Interests',
                _selectedInterests,
                _availableInterests,
              ),
              const SizedBox(height: 16),
              _buildChipSection(
                'Strengths',
                _selectedStrengths,
                _availableStrengths,
              ),
              const SizedBox(height: 16),
              _buildChipSection('Goals', _selectedGoals, _availableGoals),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildPreferencesSection() {
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
            children: [
              _buildSwitchTile(
                'Notifications',
                'Receive push notifications',
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
                Icons.notifications,
              ),
              const Divider(),
              _buildSwitchTile(
                'Attendance Reminders',
                'Get reminded about upcoming classes',
                _attendanceReminders,
                (value) => setState(() => _attendanceReminders = value),
                Icons.schedule,
              ),
              const Divider(),
              _buildSwitchTile(
                'Dark Mode',
                'Use dark theme throughout the app',
                _darkMode,
                (value) => setState(() => _darkMode = value),
                Icons.dark_mode,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildAccountActions() {
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
            children: [
              _buildActionTile(
                'Change Password',
                'Update your account password',
                Icons.lock,
                () {
                  // TODO: Implement change password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Change password feature coming soon'),
                    ),
                  );
                },
              ),
              const Divider(),
              _buildActionTile(
                'Privacy Settings',
                'Manage your privacy preferences',
                Icons.privacy_tip,
                () {
                  // TODO: Implement privacy settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy settings feature coming soon'),
                    ),
                  );
                },
              ),
              const Divider(),
              _buildActionTile(
                'Logout',
                'Sign out of your account',
                Icons.logout,
                () {
                  ref.read(authProvider.notifier).signOut();
                  context.go('/onboarding');
                },
                isDestructive: true,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildChipSection(
    String title,
    List<String> selected,
    List<String> available,
  ) {
    return Column(
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: available.map((item) {
            final isSelected = selected.contains(item);
            return GestureDetector(
              onTap: _isEditing
                  ? () {
                      setState(() {
                        if (isSelected) {
                          selected.remove(item);
                        } else {
                          selected.add(item);
                        }
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.textPrimaryColor,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimaryColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.absentColor : AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive
              ? AppTheme.absentColor
              : AppTheme.textPrimaryColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textHintColor,
      ),
      onTap: onTap,
    );
  }

  void _saveProfile() {
    // TODO: Implement save profile functionality
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppTheme.presentColor,
      ),
    );
  }

  // Available options for chips
  final List<String> _availableInterests = [
    'Programming',
    'Mathematics',
    'Science',
    'Literature',
    'Art',
    'Music',
    'Sports',
    'Technology',
    'Business',
    'Psychology',
  ];

  final List<String> _availableStrengths = [
    'Problem Solving',
    'Communication',
    'Leadership',
    'Creativity',
    'Analytical Thinking',
    'Teamwork',
    'Time Management',
    'Research',
    'Presentation',
    'Critical Thinking',
  ];

  final List<String> _availableGoals = [
    'Academic Excellence',
    'Career Preparation',
    'Skill Development',
    'Research Projects',
    'Internships',
    'Networking',
    'Personal Growth',
    'Community Service',
    'Innovation',
    'Global Perspective',
  ];
}
