import 'package:flutter/material.dart';

class AttendanceProgress extends StatelessWidget {
  final double percentage;
  final String subject;

  const AttendanceProgress({
    super.key,
    required this.percentage,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 75 ? Colors.green : 
              percentage >= 60 ? Colors.orange : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text('${percentage.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}