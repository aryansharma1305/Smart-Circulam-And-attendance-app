import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../providers/admin_provider.dart';
// import '../../providers/auth_provider.dart'; // Removed unused import

class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key});

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Form controllers
  final _instituteNameController = TextEditingController();
  final _instituteCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  // Selected options
  String _selectedCountry = 'India';
  String _selectedState = 'Maharashtra';
  String _selectedCity = 'Mumbai';
  String _selectedTimezone = 'Asia/Kolkata';
  String _selectedCurrency = 'INR';

  final List<String> _countries = ['India', 'USA', 'UK', 'Canada', 'Australia'];
  final List<String> _states = [
    'Maharashtra',
    'Delhi',
    'Karnataka',
    'Tamil Nadu',
    'Gujarat',
  ];
  final List<String> _cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Chennai',
    'Ahmedabad',
  ];
  final List<String> _timezones = [
    'Asia/Kolkata',
    'America/New_York',
    'Europe/London',
    'America/Toronto',
    'Australia/Sydney',
  ];
  final List<String> _currencies = ['INR', 'USD', 'EUR', 'CAD', 'AUD'];

  @override
  void dispose() {
    _pageController.dispose();
    _instituteNameController.dispose();
    _instituteCodeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(currentUserProvider); // Removed unused variable

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Institute Setup',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => context.go('/login'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: AppTheme.primaryColor),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBasicInfoStep(),
                _buildLocationStep(),
                _buildContactStep(),
                _buildPreferencesStep(),
                _buildReviewStep(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: List.generate(5, (index) {
                  final isActive = index <= _currentStep;
                  final isCompleted = index < _currentStep;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppTheme.presentColor
                                  : isActive
                                  ? AppTheme.primaryColor
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : Icons.circle,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStepTitle(index),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isActive
                                  ? AppTheme.textPrimaryColor
                                  : AppTheme.textSecondaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (_currentStep + 1) / 5,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
                minHeight: 4,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader(
                'Basic Information',
                'Let\'s start with the basic details of your institute',
                Icons.school,
              ),
              const SizedBox(height: 32),

              _buildTextField(
                controller: _instituteNameController,
                label: 'Institute Name',
                hint: 'Enter your institute name',
                icon: Icons.school,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter institute name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _instituteCodeController,
                label: 'Institute Code',
                hint: 'Enter unique institute code',
                icon: Icons.code,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter institute code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter complete address',
                icon: Icons.location_on,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideX(begin: 0.3);
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader(
                'Location Details',
                'Set your institute\'s location and timezone',
                Icons.public,
              ),
              const SizedBox(height: 32),

              _buildDropdownField(
                label: 'Country',
                value: _selectedCountry,
                items: _countries,
                icon: Icons.flag,
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              _buildDropdownField(
                label: 'State/Province',
                value: _selectedState,
                items: _states,
                icon: Icons.location_city,
                onChanged: (value) {
                  setState(() {
                    _selectedState = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              _buildDropdownField(
                label: 'City',
                value: _selectedCity,
                items: _cities,
                icon: Icons.location_on,
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              _buildDropdownField(
                label: 'Timezone',
                value: _selectedTimezone,
                items: _timezones,
                icon: Icons.access_time,
                onChanged: (value) {
                  setState(() {
                    _selectedTimezone = value!;
                  });
                },
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideX(begin: 0.3);
  }

  Widget _buildContactStep() {
    return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader(
                'Contact Information',
                'Provide contact details for communication',
                Icons.contact_phone,
              ),
              const SizedBox(height: 32),

              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter primary phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter primary email address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _websiteController,
                label: 'Website (Optional)',
                hint: 'Enter institute website URL',
                icon: Icons.language,
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideX(begin: 0.3);
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader(
                'Preferences',
                'Configure your institute preferences',
                Icons.settings,
              ),
              const SizedBox(height: 32),

              _buildDropdownField(
                label: 'Currency',
                value: _selectedCurrency,
                items: _currencies,
                icon: Icons.attach_money,
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),
              const SizedBox(height: 32),

              _buildPreferenceCard(
                'Academic Year',
                'Set the academic year structure',
                Icons.calendar_today,
                AppTheme.primaryColor,
                () => _showAcademicYearDialog(),
              ),
              const SizedBox(height: 16),

              _buildPreferenceCard(
                'Attendance Policy',
                'Configure attendance rules',
                Icons.rule,
                AppTheme.secondaryColor,
                () => _showAttendancePolicyDialog(),
              ),
              const SizedBox(height: 16),

              _buildPreferenceCard(
                'Notification Settings',
                'Set up notification preferences',
                Icons.notifications,
                AppTheme.accentColor,
                () => _showNotificationSettingsDialog(),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideX(begin: 0.3);
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Review & Complete',
            'Review all the information before completing setup',
            Icons.verified,
          ),
          const SizedBox(height: 32),

          _buildReviewCard(
            'Basic Information',
            [
              'Institute Name: ${_instituteNameController.text.isEmpty ? "Not provided" : _instituteNameController.text}',
              'Institute Code: ${_instituteCodeController.text.isEmpty ? "Not provided" : _instituteCodeController.text}',
              'Address: ${_addressController.text.isEmpty ? "Not provided" : _addressController.text}',
            ],
            Icons.school,
            AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),

          _buildReviewCard(
            'Location',
            [
              'Country: $_selectedCountry',
              'State: $_selectedState',
              'City: $_selectedCity',
              'Timezone: $_selectedTimezone',
            ],
            Icons.public,
            AppTheme.secondaryColor,
          ),
          const SizedBox(height: 16),

          _buildReviewCard(
            'Contact',
            [
              'Phone: ${_phoneController.text.isEmpty ? "Not provided" : _phoneController.text}',
              'Email: ${_emailController.text.isEmpty ? "Not provided" : _emailController.text}',
              'Website: ${_websiteController.text.isEmpty ? "Not provided" : _websiteController.text}',
            ],
            Icons.contact_phone,
            AppTheme.accentColor,
          ),
          const SizedBox(height: 16),

          _buildReviewCard(
            'Preferences',
            [
              'Currency: $_selectedCurrency',
              'Academic Year: 2024-2025',
              'Attendance Policy: Standard',
              'Notifications: Enabled',
            ],
            Icons.settings,
            AppTheme.presentColor,
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideX(begin: 0.3);
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Row(
                  children: [
                    Icon(icon, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Text(item),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
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
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(
    String title,
    List<String> details,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...details.map(
            (detail) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                detail,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 4 ? 'Complete Setup' : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Basic';
      case 1:
        return 'Location';
      case 2:
        return 'Contact';
      case 3:
        return 'Preferences';
      case 4:
        return 'Review';
      default:
        return '';
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeSetup() {
    // TODO: Save setup data to database
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.presentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.presentColor,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Setup Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your institute has been configured successfully. You can now start using SmartStudy+.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final settings = {
                    'name': _instituteNameController.text.trim(),
                    'code': _instituteCodeController.text.trim(),
                    'address': _addressController.text.trim(),
                    'phone': _phoneController.text.trim(),
                    'email': _emailController.text.trim(),
                    'website': _websiteController.text.trim(),
                    'country': _selectedCountry,
                    'state': _selectedState,
                    'city': _selectedCity,
                    'timezone': _selectedTimezone,
                    'currency': _selectedCurrency,
                  };
                  await ref
                      .read(adminServiceProvider)
                      .saveInstituteSettings(settings);
                  if (!mounted) return;
                  Navigator.pop(context);
                  context.go('/admin');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.presentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Text('Need help with setup? Contact our support team.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAcademicYearDialog() {
    // TODO: Implement academic year configuration
  }

  void _showAttendancePolicyDialog() {
    // TODO: Implement attendance policy configuration
  }

  void _showNotificationSettingsDialog() {
    // TODO: Implement notification settings configuration
  }
}
