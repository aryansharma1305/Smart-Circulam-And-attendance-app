import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/attendance_record.dart';
import '../../models/session.dart';
import '../../services/qr_service.dart';
import '../../services/location_security_service.dart';
import '../../services/simple_storage_service.dart';
import '../../services/firebase_attendance_service.dart';
import '../../widgets/demo_qr_scanner.dart';
import '../../providers/auth_provider.dart';

class MultiModalAttendancePage extends ConsumerStatefulWidget {
  const MultiModalAttendancePage({super.key});

  @override
  ConsumerState<MultiModalAttendancePage> createState() =>
      _MultiModalAttendancePageState();
}

class _MultiModalAttendancePageState
    extends ConsumerState<MultiModalAttendancePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isScanning = false;
  bool _isProcessing = false;
  // String _currentMethod = 'QR'; // Removed unused field
  String _statusMessage = 'Select an attendance method';
  Color _statusColor = AppTheme.textSecondaryColor;

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
          onPressed: () => context.go('/student'),
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

  Widget _buildQRCodeTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Session Info
          _buildSessionInfo(),
          const SizedBox(height: 24),

          // QR Scanner
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  // Scanner Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
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

                  // Scanner View
                  Expanded(
                    child: _isScanning
                        ? _buildQRScanner()
                        : _buildQRPlaceholder(),
                  ),

                  // Status Message
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
                            color: _statusColor.withOpacity(0.1),
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
        child: DemoQRScanner(
          expectedSessionId: _currentSession.id,
          studentName: 'John Doe', // Get from user provider
          courseName: 'Data Structures & Algorithms',
          onQRScanned: (success) =>
              _onQRScanned(QRValidationResult(isValid: success)),
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
            'Tap "Start Scanning" to scan the teacher\'s QR code',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure you\'re in the classroom and connected to the campus Wi-Fi',
                  style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.bluetooth,
                      size: 80,
                      color: AppTheme.secondaryColor,
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
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bluetooth Status'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Enabled',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Beacon Signal'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Weak',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    ElevatedButton.icon(
                      onPressed: _checkBluetoothProximity,
                      icon: Icon(Icons.bluetooth_searching),
                      label: Text('Check Proximity'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.wifi, size: 80, color: AppTheme.accentColor),
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
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Current Network'),
                              Text(
                                'Campus_WiFi',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Signal Strength'),
                              Row(
                                children: [
                                  Icon(
                                    Icons.signal_wifi_4_bar,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Strong',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Verification'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    ElevatedButton.icon(
                      onPressed: _checkWiFiVerification,
                      icon: Icon(Icons.wifi_find),
                      label: Text('Verify Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.face, size: 80, color: Colors.purple),
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
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Face Template'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Registered',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Camera Permission'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Granted',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Lighting'),
                              Row(
                                children: [
                                  Icon(Icons.lightbulb, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Good',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    ElevatedButton.icon(
                      onPressed: _startFaceRecognition,
                      icon: Icon(Icons.face_retouching_natural),
                      label: Text('Start Recognition'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

  Widget _buildSessionInfo() {
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
          Row(
            children: [
              Icon(Icons.class_, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mathematics 101',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.presentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Live',
                  style: TextStyle(
                    color: AppTheme.presentColor,
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
              Expanded(child: _buildInfoItem('Time', '09:00 - 10:00 AM')),
              Expanded(
                child: _buildInfoItem(
                  'Students',
                  '${_currentSession.presentStudents}/${_currentSession.totalStudents}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.textHintColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  // Event Handlers
  void _onQRScanned(QRValidationResult result) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing QR code...';
      _statusColor = AppTheme.primaryColor;
    });

    try {
      if (result.isValid) {
        // Create record via service with validated session
        final currentUser = ref.read(currentUserProvider);
        final studentId = currentUser?.uid ?? 'anonymous_student';

        await FirebaseAttendanceService.createAttendanceRecord(
          sessionId: result.sessionId!,
          studentId: studentId,
          status: AttendanceStatus.present,
          method: AttendanceMethod.qr,
          metadata: {
            'validated': true,
            'latitude': result.timestamp?.millisecondsSinceEpoch,
          },
        );

        setState(() {
          _statusMessage = 'Attendance recorded successfully!';
          _statusColor = AppTheme.presentColor;
          _isProcessing = false;
        });

        _showSuccessDialog(AttendanceMethod.qr);
      } else {
        setState(() {
          _statusMessage = result.error ?? 'Invalid QR code';
          _statusColor = AppTheme.absentColor;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to record attendance: ${e.toString()}';
        _statusColor = AppTheme.absentColor;
        _isProcessing = false;
      });
    }
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
      _statusMessage = 'Scanning stopped';
      _statusColor = AppTheme.textSecondaryColor;
    });
  }

  void _checkBluetoothProximity() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Checking Bluetooth proximity...';
      _statusColor = AppTheme.secondaryColor;
    });

    try {
      // Get current location for proximity check
      final locationResult = await LocationSecurityService.getCurrentLocation();

      if (!locationResult.success) {
        _setStatus(
          'Location access required: ${locationResult.error}',
          AppTheme.absentColor,
        );
        return;
      }

      // Check proximity to expected location
      final proximityValid = LocationSecurityService.validateLocationProximity(
        currentLatitude: locationResult.latitude!,
        currentLongitude: locationResult.longitude!,
        expectedLatitude: _currentSession.proximityPolicy['latitude'] as double,
        expectedLongitude:
            _currentSession.proximityPolicy['longitude'] as double,
      );

      if (proximityValid) {
        _processAttendance(AttendanceMethod.ble, {'ble_uuid': 'beacon_123'});
      } else {
        _setStatus('Too far from classroom location', AppTheme.absentColor);
      }
    } catch (e) {
      _setStatus(
        'Bluetooth proximity check failed: ${e.toString()}',
        AppTheme.absentColor,
      );
    }
  }

  void _checkWiFiVerification() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Verifying Wi-Fi connection...';
      _statusColor = AppTheme.accentColor;
    });

    try {
      // Get current Wi-Fi SSID
      final wifiResult = await LocationSecurityService.getCurrentWifiSSID();

      if (!wifiResult.success) {
        _setStatus(
          'Wi-Fi access required: ${wifiResult.error}',
          AppTheme.absentColor,
        );
        return;
      }

      // Validate Wi-Fi SSID
      final wifiValid = LocationSecurityService.validateWifiSSID(
        currentSSID: wifiResult.ssid!,
        expectedSSID: _currentSession.proximityPolicy['wifi_ssid'] as String,
      );

      if (wifiValid) {
        _processAttendance(AttendanceMethod.wifi, {
          'wifi_ssid': wifiResult.ssid!,
        });
      } else {
        _setStatus(
          'Wrong Wi-Fi network. Expected: ${_currentSession.proximityPolicy['wifi_ssid']}',
          AppTheme.absentColor,
        );
      }
    } catch (e) {
      _setStatus(
        'Wi-Fi verification failed: ${e.toString()}',
        AppTheme.absentColor,
      );
    }
  }

  void _startFaceRecognition() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Starting face recognition...';
      _statusColor = Colors.purple;
    });

    // Simulate face recognition
    await Future.delayed(Duration(seconds: 3));

    _processAttendance(AttendanceMethod.face, {'face_match_score': 0.95});
  }

  void _processAttendance(
    AttendanceMethod method,
    Map<String, dynamic> metadata,
  ) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing attendance...';
      _statusColor = AppTheme.primaryColor;
    });

    try {
      // Create attendance record
      final attendanceRecord = AttendanceRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: _currentSession.id,
        studentId: 'student_123', // This should come from auth
        status: AttendanceStatus.present,
        timestamp: DateTime.now(),
        method: method,
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to offline storage
      await SimpleStorageService.saveAttendanceRecord(attendanceRecord);

      _setStatus('Attendance marked successfully!', AppTheme.presentColor);

      // Show success dialog
      _showSuccessDialog(method);
    } catch (e) {
      _setStatus(
        'Failed to save attendance: ${e.toString()}',
        AppTheme.absentColor,
      );
    }
  }

  void _setStatus(String message, Color color) {
    setState(() {
      _statusMessage = message;
      _statusColor = color;
      _isProcessing = false;
    });
  }

  void _showSuccessDialog(AttendanceMethod method) {
    showDialog(
      context: context,
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
                size: 40,
                color: AppTheme.presentColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Attendance Marked!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Method: ${_getMethodDisplayName(method)}',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/student');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMethodDisplayName(AttendanceMethod method) {
    switch (method) {
      case AttendanceMethod.qr:
        return 'QR Code';
      case AttendanceMethod.ble:
        return 'Bluetooth';
      case AttendanceMethod.wifi:
        return 'Wi-Fi';
      case AttendanceMethod.face:
        return 'Face Recognition';
      case AttendanceMethod.manual:
        return 'Manual';
    }
  }
}
