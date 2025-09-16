import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/qr_service.dart';
import '../services/location_security_service.dart';
import '../widgets/qr_scanner_widget.dart';

class TestQRPage extends StatefulWidget {
  const TestQRPage({super.key});

  @override
  State<TestQRPage> createState() => _TestQRPageState();
}

class _TestQRPageState extends State<TestQRPage> {
  QRCodeData? _qrCodeData;
  String _statusMessage = '';
  Color _statusColor = Colors.grey;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _generateTestQR();
  }

  Future<void> _generateTestQR() async {
    try {
      // Fetch live location and Wi-Fi for demo-friendly QR
      final locationResult = await LocationSecurityService.getCurrentLocation();
      final wifiResult = await LocationSecurityService.getCurrentWifiSSID();

      // Demo: Skip location and wifi validation

      final qrData = await QRService.generateAttendanceQR(
        sessionId: 'test_session_123',
        classId: 'class_456',
        teacherId: 'teacher_789',
        latitude: locationResult.latitude!,
        longitude: locationResult.longitude!,
        wifiSSID: wifiResult.ssid!,
        timestamp: DateTime.now(),
      );

      setState(() {
        _qrCodeData = qrData;
        _statusMessage = 'QR Code generated successfully!';
        _statusColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error generating QR: $e';
        _statusColor = Colors.red;
      });
    }
  }

  void _onQRScanned(QRValidationResult result) {
    setState(() {
      if (result.isValid) {
        _statusMessage = 'QR Code validated successfully!';
        _statusColor = Colors.green;
      } else {
        _statusMessage = 'QR validation failed: ${result.error}';
        _statusColor = Colors.red;
      }
      _isScanning = false;
    });
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning for QR code...';
      _statusColor = Colors.blue;
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
      _statusMessage = 'Scanning stopped';
      _statusColor = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _statusColor),
              ),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // QR Code Display
            if (_qrCodeData != null) ...[
              const Text(
                'Generated QR Code:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: _qrCodeData!.data,
                    version: QrVersions.auto,
                    size: 200.0,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateTestQR,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate New QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? _stopScanning : _startScanning,
                    icon: Icon(
                      _isScanning ? Icons.stop : Icons.qr_code_scanner,
                    ),
                    label: Text(_isScanning ? 'Stop Scan' : 'Scan QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isScanning ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Scanner
            if (_isScanning) ...[
              const Text(
                'QR Code Scanner:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: QRScannerWidget(
                      onQRScanned: (qrData) {
                        // Convert String to QRValidationResult for compatibility
                        final result = QRValidationResult(
                          isValid: qrData.isNotEmpty,
                          sessionId: qrData.isNotEmpty ? qrData : null,
                          error: qrData.isEmpty ? 'Invalid QR Code' : null,
                        );
                        _onQRScanned(result);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
