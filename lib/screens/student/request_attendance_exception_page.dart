import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/attendance_exception.dart';

class RequestAttendanceExceptionPage extends ConsumerStatefulWidget {
  final String? sessionId;
  final String? courseName;
  final DateTime? sessionDate;

  const RequestAttendanceExceptionPage({
    super.key,
    this.sessionId,
    this.courseName,
    this.sessionDate,
  });

  @override
  ConsumerState<RequestAttendanceExceptionPage> createState() =>
      _RequestAttendanceExceptionPageState();
}

class _RequestAttendanceExceptionPageState
    extends ConsumerState<RequestAttendanceExceptionPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  ExceptionType _selectedType = ExceptionType.lateArrival;
  String? _selectedDocument;
  bool _isSubmitting = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Request Exception',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSessionInfo(),
              const SizedBox(height: 24),
              _buildExceptionTypeSection(),
              const SizedBox(height: 24),
              _buildReasonSection(),
              const SizedBox(height: 24),
              _buildDocumentSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Request an exception for this attendance record',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Course',
            widget.courseName ?? 'Data Structures & Algorithms',
          ),
          _buildInfoRow(
            'Date',
            widget.sessionDate?.toString().substring(0, 10) ?? 'Today',
          ),
          _buildInfoRow('Current Status', 'Absent'),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExceptionTypeSection() {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exception Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ...ExceptionType.values.map((type) => _buildTypeOption(type)),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildTypeOption(ExceptionType type) {
    final isSelected = _selectedType == type;
    final typeColor = _getTypeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? typeColor : Colors.grey.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? typeColor.withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      child: RadioListTile<ExceptionType>(
        value: type,
        groupValue: _selectedType,
        onChanged: (value) {
          setState(() {
            _selectedType = value!;
          });
        },
        title: Text(
          _getTypeDisplayName(type),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? typeColor : AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: Text(
          _getTypeDescription(type),
          style: TextStyle(
            fontSize: 12,
            color: isSelected
                ? typeColor.withValues(alpha: 0.8)
                : AppTheme.textSecondaryColor,
          ),
        ),
        activeColor: typeColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildReasonSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reason for Exception',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide a detailed explanation for your request',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reasonController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter your reason here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide a reason for your request';
              }
              if (value.trim().length < 10) {
                return 'Please provide a more detailed reason (at least 10 characters)';
              }
              return null;
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildDocumentSection() {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Supporting Document',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload any supporting documents (optional but recommended)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDocument,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedDocument != null
                          ? AppTheme.primaryColor
                          : Colors.grey.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedDocument != null
                        ? AppTheme.primaryColor.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.05),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedDocument != null
                            ? Icons.check_circle
                            : Icons.cloud_upload,
                        size: 48,
                        color: _selectedDocument != null
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedDocument != null
                            ? 'Document Selected: $_selectedDocument'
                            : 'Tap to upload document',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _selectedDocument != null
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_selectedDocument == null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Supported formats: PDF, JPG, PNG',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildSubmitButton() {
    return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit Request',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Color _getTypeColor(ExceptionType type) {
    switch (type) {
      case ExceptionType.lateArrival:
        return Colors.orange;
      case ExceptionType.earlyDeparture:
        return Colors.blue;
      case ExceptionType.medicalLeave:
        return Colors.red;
      case ExceptionType.personalLeave:
        return Colors.purple;
      case ExceptionType.technicalIssue:
        return Colors.teal;
      case ExceptionType.wronglyMarkedAbsent:
        return Colors.green;
      case ExceptionType.wronglyMarkedPresent:
        return Colors.indigo;
      case ExceptionType.other:
        return Colors.grey;
    }
  }

  String _getTypeDisplayName(ExceptionType type) {
    switch (type) {
      case ExceptionType.lateArrival:
        return 'Late Arrival';
      case ExceptionType.earlyDeparture:
        return 'Early Departure';
      case ExceptionType.medicalLeave:
        return 'Medical Leave';
      case ExceptionType.personalLeave:
        return 'Personal Leave';
      case ExceptionType.technicalIssue:
        return 'Technical Issue';
      case ExceptionType.wronglyMarkedAbsent:
        return 'Wrongly Marked Absent';
      case ExceptionType.wronglyMarkedPresent:
        return 'Wrongly Marked Present';
      case ExceptionType.other:
        return 'Other';
    }
  }

  String _getTypeDescription(ExceptionType type) {
    switch (type) {
      case ExceptionType.lateArrival:
        return 'You arrived late but were present in class';
      case ExceptionType.earlyDeparture:
        return 'You had to leave class early';
      case ExceptionType.medicalLeave:
        return 'Medical emergency or appointment';
      case ExceptionType.personalLeave:
        return 'Personal or family emergency';
      case ExceptionType.technicalIssue:
        return 'QR scanner or app technical problems';
      case ExceptionType.wronglyMarkedAbsent:
        return 'You were present but marked absent';
      case ExceptionType.wronglyMarkedPresent:
        return 'You were absent but marked present';
      case ExceptionType.other:
        return 'Other circumstances not listed above';
    }
  }

  void _pickDocument() {
    // Simulate document picker
    setState(() {
      _selectedDocument = 'medical_certificate.pdf';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document selected successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Request Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your exception request has been submitted successfully. You will be notified once it\'s reviewed.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
