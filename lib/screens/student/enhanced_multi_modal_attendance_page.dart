import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/session.dart';
import '../../services/qr_service.dart';
import '../../widgets/simple_qr_scanner.dart';
import '../../widgets/attendance_success_animation.dart';
import '../../providers/auth_provider.dart';

class EnhancedMultiModalAttendancePage extends ConsumerStatefulWidget {
  const EnhancedMultiModalAttendancePage({super.key});

  @override
  ConsumerState<EnhancedMultiModalAttendancePage> createState() =>
      _EnhancedMultiModalAttendancePageState();
}

class _EnhancedMultiModalAttendancePageState
    extends ConsumerState<EnhancedMultiModalAttendancePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isScanning = false;
  bool _isProcessing = false;
  bool _showSuccessAnimation = false;
  String _statusMessage = 'Select an attendance method';
  Color _statusColor = AppTheme.textSecondaryColor;
  String _attendanceStatus = 'present';

  // Mock session data
  final Session _currentSession = Session(
    id: 'session_123',
    timetableId: 'timetable_456',
    date: DateTime.now(),
    state: SessionState.live,
    qrSeed: 'qr_seed_789',
    qrExpiry: DateTime.now().add(Duration(minutes: 30)),
    proximityPolicy: {
      'wifi_ssid': 'Campus_WiFi',
      'ble_uuid': 'beacon_123',
      'location_radius': 50.0,
      'latitude': 12.9716,
      'longitude': 77.5946,
    },
    stats: {'total_students': 25, 'present_students': 18, 'absent_students': 7},
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccessAnimation) {
      return AttendanceSuccessAnimation(
        studentName: 'John Doe',
        courseName: 'Mathematics 101',
        status: _attendanceStatus,
        onComplete: () {
          setState(() {
            _showSuccessAnimation = false;
          });
          context.pop();
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Mark Attendance',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'QR Code'),
            Tab(icon: Icon(Icons.bluetooth), text: 'Bluetooth'),
            Tab(icon: Icon(Icons.wifi), text: 'Wi-Fi'),
            Tab(icon: Icon(Icons.face), text: 'Face ID'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildQRCodeTab(),
              _buildBluetoothTab(),
              _buildWiFiTab(),
              _buildFaceIdTab(),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.book, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mathematics 101',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Room 101 • Dr. Smith',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      '09:00 - 10:00 AM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Students',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      '18/25',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildSessionInfo(),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scan QR Code',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              Text(
                                'Point your camera at the classroom QR code',
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
                  ),
                  Expanded(
                    child: _isScanning
                        ? _buildQRScanner()
                        : _buildQRPlaceholder(),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              color: _statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isScanning
                                    ? _stopScanning
                                    : _startScanning,
                                icon: Icon(
                                  _isScanning ? Icons.stop : Icons.play_arrow,
                                ),
                                label: Text(
                                  _isScanning
                                      ? 'Stop Scanning'
                                      : 'Start Scanning',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isScanning
                                      ? AppTheme.absentColor
                                      : AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SimpleQRScanner(
          expectedSessionId: _currentSession.id,
          studentName: 'John Doe',
          courseName: 'Mathematics 101',
          onQRScanned: (success) {
            if (success) {
              _markAttendance('QR Code');
            }
          },
          onClose: _stopScanning,
        ),
      ),
    );
  }

  Widget _buildQRPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'QR Scanner Ready',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Start Scanning" to scan any QR code',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildSessionInfo(),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Animated Bluetooth Icon
                    Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.bluetooth,
                            size: 60,
                            color: Colors.blue,
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 2000.ms,
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),

                    const SizedBox(height: 24),
                    Text(
                      'Bluetooth Proximity',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Make sure Bluetooth is enabled and you\'re near the classroom beacon',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Bluetooth Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildStatusRow(
                            'Bluetooth Status',
                            'Enabled',
                            Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildStatusRow(
                            'Beacon Signal',
                            'Weak',
                            Colors.orange,
                            Icons.bluetooth_searching,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _checkBluetoothProximity,
                        icon: Icon(Icons.bluetooth_searching),
                        label: Text('Check Proximity'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Widget _buildWiFiTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildSessionInfo(),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Animated Wi-Fi Icon
                    Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.pink.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.wifi, size: 60, color: Colors.pink),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 2000.ms,
                          color: Colors.pink.withValues(alpha: 0.3),
                        ),

                    const SizedBox(height: 24),
                    Text(
                      'Wi-Fi Verification',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Connect to the campus Wi-Fi network to verify your location',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Wi-Fi Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildStatusRow(
                            'Current Network',
                            'Campus_WiFi',
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildStatusRow(
                            'Signal Strength',
                            'Strong',
                            Colors.green,
                            Icons.signal_wifi_4_bar,
                          ),
                          const SizedBox(height: 12),
                          _buildStatusRow(
                            'Verification',
                            'Verified',
                            Colors.green,
                            Icons.verified,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _checkWiFiVerification,
                        icon: Icon(Icons.wifi_find),
                        label: Text('Verify Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Widget _buildFaceIdTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildSessionInfo(),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Animated Face Icon
                    Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.face,
                            size: 60,
                            color: Colors.purple,
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 2000.ms,
                          color: Colors.purple.withValues(alpha: 0.3),
                        ),

                    const SizedBox(height: 24),
                    Text(
                      'Face Recognition',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Use facial recognition to verify your identity and mark attendance',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Face ID Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildStatusRow(
                            'Face Template',
                            'Registered',
                            Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildStatusRow(
                            'Camera Permission',
                            'Granted',
                            Colors.green,
                            Icons.camera_alt,
                          ),
                          const SizedBox(height: 12),
                          _buildStatusRow(
                            'Lighting',
                            'Good',
                            Colors.orange,
                            Icons.lightbulb,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startFaceRecognition,
                        icon: Icon(Icons.face_retouching_natural),
                        label: Text('Start Recognition'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Widget _buildStatusRow(
    String label,
    String value,
    Color color, [
    IconData? icon,
  ]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
        ),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning for QR code...';
      _statusColor = AppTheme.primaryColor;
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
      _statusMessage = 'Select an attendance method';
      _statusColor = AppTheme.textSecondaryColor;
    });
  }

  void _checkBluetoothProximity() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate Bluetooth check
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _markAttendance('Bluetooth');
      }
    });
  }

  void _checkWiFiVerification() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate Wi-Fi verification
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _markAttendance('Wi-Fi');
      }
    });
  }

  void _startFaceRecognition() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate face recognition
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _markAttendance('Face Recognition');
      }
    });
  }

  void _markAttendance(String method) {
    // Determine if late based on current time
    final now = DateTime.now();
    final isLate = now.hour > 9 || (now.hour == 9 && now.minute > 15);

    setState(() {
      _isProcessing = false;
      _attendanceStatus = isLate ? 'late' : 'present';
      _showSuccessAnimation = true;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance marked via $method'),
        backgroundColor: isLate ? AppTheme.lateColor : AppTheme.presentColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
