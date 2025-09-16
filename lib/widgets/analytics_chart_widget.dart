import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AnalyticsChartWidget extends StatelessWidget {
  final List<AttendanceTrend> trends;

  const AnalyticsChartWidget({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const Center(child: Text('No data available for chart'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Trend Chart',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildLineChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    final maxValue = trends
        .map((t) => t.attendancePercentage)
        .reduce((a, b) => a > b ? a : b);
    final minValue = trends
        .map((t) => t.attendancePercentage)
        .reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    final padding = range * 0.1; // 10% padding

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: AttendanceChartPainter(
        trends: trends,
        maxValue: maxValue + padding,
        minValue: minValue - padding,
      ),
    );
  }
}

class AttendanceChartPainter extends CustomPainter {
  final List<AttendanceTrend> trends;
  final double maxValue;
  final double minValue;

  AttendanceChartPainter({
    required this.trends,
    required this.maxValue,
    required this.minValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(fontSize: 12, color: Colors.black87);

    // Calculate points
    final points = <Offset>[];
    final stepX = size.width / (trends.length - 1);

    for (int i = 0; i < trends.length; i++) {
      final trend = trends[i];
      final x = i * stepX;
      final y =
          size.height -
          ((trend.attendancePercentage - minValue) / (maxValue - minValue)) *
              size.height;
      points.add(Offset(x, y));
    }

    // Draw filled area
    final path = Path();
    path.moveTo(points.first.dx, size.height);
    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw Y-axis labels
    final yLabels = [maxValue, (maxValue + minValue) / 2, minValue];
    for (final value in yLabels) {
      final y =
          size.height -
          ((value - minValue) / (maxValue - minValue)) * size.height;
      final textPainter = TextPainter(
        text: TextSpan(text: '${value.toStringAsFixed(0)}%', style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    // Draw X-axis labels (every 5th point to avoid crowding)
    for (int i = 0; i < trends.length; i += 5) {
      final trend = trends[i];
      final x = i * stepX;
      final textPainter = TextPainter(
        text: TextSpan(
          text: trend.period.length > 10
              ? trend.period.substring(0, 10)
              : trend.period,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height + 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
