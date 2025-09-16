import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/qr_service.dart';
import '../services/location_security_service.dart';
import '../core/theme.dart';

class QRGeneratorWidget extends StatefulWidget {
  final String sessionId;
  final String classId;
  final String teacherId;
  final double latitude;
  final double longitude;
  final String wifiSSID;
  final VoidCallback? onClose;

  const QRGeneratorWidget({
    super.key,
    required this.sessionId,
    required this.classId,
    required this.teacherId,
    required this.latitude,
    required this.longitude,
    required this.wifiSSID,
    this.onClose,
  });

  @override
  State<QRGeneratorWidget> createState() => _QRGeneratorWidgetState();
}

class _QRGeneratorWidgetState extends State<QRGeneratorWidget> {
  QRCodeData? _currentQRCode;
  bool _isGenerating = false;
  String? _errorMessage;
  DateTime? _lastGenerated;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
    _startRotationTimer();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  void _startRotationTimer() {
    _rotationTimer = Timer.periodic(
      const Duration(seconds: 25), // Generate new QR 5 seconds before expiry
      (_) => _generateQRCode(),
    );
  }

  Future<void> _generateQRCode() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final qrCode = await QRService.generateAttendanceQR(
        sessionId: widget.sessionId,
        classId: widget.classId,
        teacherId: widget.teacherId,
        latitude: widget.latitude,
        longitude: widget.longitude,
        wifiSSID: widget.wifiSSID,
        timestamp: DateTime.now(),
      );

      setState(() {
        _currentQRCode = qrCode;
        _lastGenerated = DateTime.now();
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate QR code: ${e.toString()}';
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Attendance QR Code',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onClose,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _generateQRCode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Session Info
            _buildSessionInfo(),
            const SizedBox(height: 20),
            
            // QR Code Display
            Expanded(
              child: _buildQRCodeDisplay(),
            ),
            
            // Controls
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.class_, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class: ${widget.classId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Session: ${widget.sessionId}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.presentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'LIVE',
                  style: TextStyle(
                    color: AppTheme.presentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Lat: ${widget.latitude.toStringAsFixed(4)}, Lng: ${widget.longitude.toStringAsFixed(4)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.wifi, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Wi-Fi: ${widget.wifiSSID}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeDisplay() {
    if (_errorMessage != null) {
      return _buildErrorDisplay();
    }

    if (_isGenerating) {
      return _buildLoadingDisplay();
    }

    if (_currentQRCode == null) {
      return _buildEmptyDisplay();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // QR Code
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: QRService.generateQRWidget(_currentQRCode!),
          ),
          
          const SizedBox(height: 20),
          
          // Timer
          _buildTimer(),
          
          const SizedBox(height: 16),
          
          // Instructions
          Text(
            'Students should scan this QR code to mark attendance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    if (_lastGenerated == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final elapsed = now.difference(_lastGenerated!);
    final remaining = 30 - elapsed.inSeconds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: remaining <= 5 ? Colors.red.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: remaining <= 5 ? Colors.red : AppTheme.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Expires in ${remaining}s',
            style: TextStyle(
              color: remaining <= 5 ? Colors.red : AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Generating QR Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _generateQRCode,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Generating QR Code...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No QR Code Generated',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap refresh to generate a new QR code',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generateQRCode,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
