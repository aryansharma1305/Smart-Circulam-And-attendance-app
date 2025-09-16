import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'teacher_home_page.dart';

class AttendanceDisplayPage extends ConsumerStatefulWidget {
  final TeacherClass? classData;
  
  const AttendanceDisplayPage({super.key, this.classData});

  @override
  ConsumerState<AttendanceDisplayPage> createState() => _AttendanceDisplayPageState();
}

class _AttendanceDisplayPageState extends ConsumerState<AttendanceDisplayPage> {
  late TeacherClass classData;
  bool isLive = false;
  String qrToken = '';
  int presentCount = 0;
  int totalCount = 0;
  bool isOffline = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    classData = widget.classData ?? _getDefaultClass();
    _initializeDisplay();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
      status: 'live',
    );
  }

  void _initializeDisplay() {
    isLive = classData.status == 'live';
    qrToken = _generateQRToken();
    presentCount = 38;
    totalCount = classData.enrolled;
    
    if (isLive) {
      _startAutoRotate();
    }
  }

  String _generateQRToken() {
    return 'QR_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _startAutoRotate() {
    _timer = Timer.periodic(const Duration(seconds: 45), (timer) {
      if (isLive) {
        setState(() {
          qrToken = _generateQRToken();
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            if (isOffline) _buildOfflineBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isLive) _buildNotStartedState(),
                    if (isLive) _buildLiveDisplay(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange,
      child: const Text(
        'OFFLINE—scans will sync later',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNotStartedState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.pause_circle_outline,
          size: 120,
          color: Colors.white.withOpacity(0.7),
        ),
        const SizedBox(height: 24),
        const Text(
          'Session not started',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please start the session from the teacher app',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLiveDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Scan to mark attendance',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildQRCode(),
        const SizedBox(height: 24),
        const Text(
          'Token refreshes automatically',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildQRCode() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simulated QR Code using a grid of squares
            _buildQRGrid(),
            const SizedBox(height: 16),
            Text(
              qrToken,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRGrid() {
    return Container(
      width: 200,
      height: 200,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 20,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: 400,
        itemBuilder: (context, index) {
          final random = Random(index);
          return Container(
            color: random.nextBool() ? Colors.black : Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    final timeLeft = classData.end.difference(DateTime.now());
    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes % 60;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${classData.course} • ${classData.room}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${hours}h ${minutes}m left',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$presentCount / $totalCount',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Present',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget buildWithToolbar(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${classData.course} • ${classData.section}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                qrToken = _generateQRToken();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isOffline) _buildOfflineBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isLive) _buildNotStartedState(),
                    if (isLive) _buildLiveDisplay(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
}