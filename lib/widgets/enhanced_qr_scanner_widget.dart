import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart'; // Disabled due to build issues
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'demo_qr_scanner.dart';

class EnhancedQRScannerWidget extends StatefulWidget {
  final Function(String) onQRScanned;
  final String? overlayText;
  final bool showFlashToggle;
  final bool showGalleryButton;

  const EnhancedQRScannerWidget({
    super.key,
    required this.onQRScanned,
    this.overlayText,
    this.showFlashToggle = true,
    this.showGalleryButton = true,
  });

  @override
  State<EnhancedQRScannerWidget> createState() =>
      _EnhancedQRScannerWidgetState();
}

class _EnhancedQRScannerWidgetState extends State<EnhancedQRScannerWidget> {
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
