import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../services/location_security_service.dart';
import '../../services/qr_service.dart';
import '../../services/firebase_attendance_service.dart';
import 'teacher_home_page.dart';
import '../../providers/auth_provider.dart';

class LiveSessionState {
  bool live;
  int present;
  int late;
  int enrolled;
  Duration ttl;
  String qrToken;

  LiveSessionState({
    required this.live,
    required this.present,
    required this.late,
    required this.enrolled,
    required this.ttl,
    required this.qrToken,
  });
}

class StartSessionPage extends ConsumerStatefulWidget {
  final TeacherClass? classData;

  const StartSessionPage({super.key, this.classData});

  @override
  ConsumerState<StartSessionPage> createState() => _StartSessionPageState();
}

class _StartSessionPageState extends ConsumerState<StartSessionPage> {
  late TeacherClass classData;
  LiveSessionState? sessionState;
  bool isOffline = false;
  String? classNotes;
  Timer? _timer;
  double? _currentLatitude;
  double? _currentLongitude;
  String? _currentWifiSSID;
  QRCodeData? _currentQRCode;
  Timer? _qrRotationTimer;

  @override
  void initState() {
    super.initState();
    classData = widget.classData ?? _getDefaultClass();
    _initializeSession();
    _getLocationAndWifi();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _qrRotationTimer?.cancel();
    super.dispose();
  }

  TeacherClass _getDefaultClass() {
    final now = DateTime.now();
    return TeacherClass(
      timetableId: 'default',
      course: 'DSA',
      section: 'Sec A',
      room: 'B201',
      start: now,
      end: now.add(const Duration(minutes: 50)),
      enrolled: 52,
      status: 'planned',
    );
  }

  void _initializeSession() {
    sessionState = LiveSessionState(
      live: false,
      present: 0,
      late: 0,
      enrolled: classData.enrolled,
      ttl: const Duration(minutes: 45),
      qrToken: _generateQRToken(),
    );
  }

  Future<void> _getLocationAndWifi() async {
    try {
      // Get current location
      final locationResult = await LocationSecurityService.getCurrentLocation();
      // Demo: Use location data directly
      _currentLatitude = locationResult.latitude;
      _currentLongitude = locationResult.longitude;

      // Get current Wi-Fi SSID
      final wifiResult = await LocationSecurityService.getCurrentWifiSSID();
      _currentWifiSSID = wifiResult.ssid;
    } catch (e) {
      debugPrint('Failed to get location/Wi-Fi: $e');
    }
  }

  Future<void> _generateQRCode() async {
    if (_currentLatitude == null ||
        _currentLongitude == null ||
        _currentWifiSSID == null) {
      _showToast('Location and Wi-Fi data not available');
      return;
    }

    try {
      final qrCode = await QRService.generateAttendanceQR(
        sessionId: sessionState!.qrToken,
        classId: classData.timetableId,
        teacherId: (ref.read(currentUserProvider)?.uid) ?? 'anonymous_teacher',
        latitude: _currentLatitude!,
        longitude: _currentLongitude!,
        wifiSSID: _currentWifiSSID!,
        timestamp: DateTime.now(),
      );

      setState(() {
        _currentQRCode = qrCode;
      });
    } catch (e) {
      _showToast('Failed to generate QR code: $e');
    }
  }

  void _startQRRotation() {
    _qrRotationTimer = Timer.periodic(
      const Duration(seconds: 25), // Generate new QR 5 seconds before expiry
      (_) => _generateQRCode(),
    );
  }

  void _stopQRRotation() {
    _qrRotationTimer?.cancel();
    _qrRotationTimer = null;
  }

  String _generateQRToken() {
    return 'QR_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    if (sessionState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('${classData.course} • ${classData.section}'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildLiveControls(),
            const SizedBox(height: 24),
            if (sessionState!.live) ...[
              _buildQRCodeDisplay(),
              const SizedBox(height: 24),
            ],
            _buildInfoRow(),
            const SizedBox(height: 24),
            _buildQuickLinks(),
            const SizedBox(height: 24),
            _buildStatusArea(),
            const SizedBox(height: 24),
            _buildNotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final timeLeft = classData.end.difference(DateTime.now());
    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${classData.course} • ${classData.section}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            classData.room,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${hours}h ${minutes}m left',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.qr_code, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Students scan this code to mark attendance',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _generateQRCode,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_currentQRCode != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: QRService.generateQRWidget(_currentQRCode!),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Generating QR Code...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'QR code refreshes every 30 seconds for security',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isOffline)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You're offline—QR will show, scans will sync later.",
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: sessionState!.live ? _endClass : _startClass,
                  icon: Icon(
                    sessionState!.live ? Icons.stop : Icons.play_arrow,
                  ),
                  label: Text(sessionState!.live ? 'End Class' : 'Start Class'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sessionState!.live
                        ? Colors.red
                        : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: sessionState!.live ? _showQRGenerator : null,
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Show QR Code'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  Widget _buildInfoRow() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            'Present',
            '${sessionState!.present}/${sessionState!.enrolled}',
            Colors.green,
          ),
          _buildInfoItem('Late', '${sessionState!.late}', Colors.orange),
          _buildInfoItem('Grace', '10m', Colors.blue),
          _buildInfoItem('Policy', 'QR + Wi-Fi', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinks() {
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
            'Quick Links',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openRoster(),
                  icon: const Icon(Icons.people),
                  label: const Text('Open Roster'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openDisplay(),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Open Display'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusArea() {
    if (!sessionState!.live) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.qr_code, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'QR token expires in ${_formatDuration(sessionState!.ttl)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Live stats from Firestore
          StreamBuilder(
            stream: FirebaseAttendanceService.watchSession(
              sessionState!.qrToken,
            ),
            builder: (context, snapshot) {
              return StreamBuilder(
                stream: FirebaseAttendanceService.watchSessionAttendance(
                  sessionState!.qrToken,
                ),
                builder: (context, attendanceSnapshot) {
                  final count = attendanceSnapshot.hasData
                      ? (attendanceSnapshot.data as List).length
                      : sessionState!.present;
                  return Text(
                    'Live present: $count',
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
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
            'Class Notes (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add class notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (value) => classNotes = value,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _saveNotes,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startClass() async {
    // Ensure we have location and Wi-Fi data
    if (_currentLatitude == null ||
        _currentLongitude == null ||
        _currentWifiSSID == null) {
      await _getLocationAndWifi();
    }

    try {
      // Create session in Firebase
      final teacherId =
          (ref.read(currentUserProvider)?.uid) ?? 'anonymous_teacher';
      final sessionId = await FirebaseAttendanceService.createSession(
        timetableId: classData.timetableId,
        date: classData.start,
        latitude: _currentLatitude!,
        longitude: _currentLongitude!,
          'location_radius': 50.0,
        },
      );

      // Update session state
      setState(() {
        sessionState!.live = true;
        sessionState!.present = 0;
        sessionState!.late = 0;
        sessionState!.qrToken = sessionId;
      });

      _startTimer();
      await _generateQRCode();
      _startQRRotation();
      _showToast('Live session started');
    } catch (e) {
      _showToast('Failed to start session: ${e.toString()}');
    }
  }

  void _endClass() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Class'),
        content: const Text('Mark all remaining students as Absent?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmEndClass();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark & Close'),
          ),
        ],
      ),
    );
  }

  void _confirmEndClass() async {
    try {
      // End session in Firebase
      await FirebaseAttendanceService.endSession(sessionState!.qrToken);

      setState(() {
        sessionState!.live = false;
      });

      _timer?.cancel();
      _stopQRRotation();
      // Show recap dialog
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Session Recap'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Present: ${sessionState!.present}'),
              Text('Late: ${sessionState!.late}'),
              Text('Total Enrolled: ${sessionState!.enrolled}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                // Simple share/export placeholder
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Recap exported')));
              },
              child: const Text('Export'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      _showToast('Failed to end session: ${e.toString()}');
    }
  }

  void _rotateQR() {
    setState(() {
      sessionState!.qrToken = _generateQRToken();
    });
    _showToast('QR rotated');
  }

  void _showQRGenerator() {
    if (_currentLatitude == null ||
        _currentLongitude == null ||
        _currentWifiSSID == null) {
      _showToast('Location and Wi-Fi data not available');
      return;
    }

    // Generate QR code directly
    _generateQRCode();
  }

  void _openRoster() {
    context.push('/teacher/roster', extra: classData);
  }

  void _openDisplay() {
    context.push('/teacher/attendance-display', extra: classData);
  }

  void _saveNotes() {
    _showToast('Notes saved');
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sessionState!.live) {
        setState(() {
          sessionState!.ttl = sessionState!.ttl - const Duration(seconds: 1);
          if (sessionState!.ttl.inSeconds <= 0) {
            _rotateQR();
            sessionState!.ttl = const Duration(minutes: 45);
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
