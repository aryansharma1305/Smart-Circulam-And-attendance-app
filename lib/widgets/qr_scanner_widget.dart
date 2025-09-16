import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart'; // Disabled due to build issues
// Demo permissions - simulating permission_handler
import '../services/qr_service.dart';
import 'demo_qr_scanner.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onQRScanned;
  final String? overlayText;
  final bool showFlashToggle;
  final bool showGalleryButton;

  const QRScannerWidget({
    super.key,
    required this.onQRScanned,
    this.overlayText,
    this.showFlashToggle = true,
    this.showGalleryButton = true,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  @override
  Widget build(BuildContext context) {
    // Use DemoQRScanner instead of mobile_scanner due to build issues
    return DemoQRScanner(
      expectedSessionId: 'demo_session',
      studentName: 'Demo Student',
      courseName: 'Demo Course',
      onQRScanned: (success) =>
          widget.onQRScanned(success ? 'demo_qr_code' : ''),
    );
  }
}
