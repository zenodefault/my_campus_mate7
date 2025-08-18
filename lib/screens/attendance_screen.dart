import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_storage_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<dynamic> _attendanceData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final attendance = await LocalStorageService.getAttendance();
      setState(() {
        _attendanceData = attendance;
      });
    } catch (e) {
      print('Error loading attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading attendance data')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance',
          style: GoogleFonts.fragmentMono(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attendanceData.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.percent_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No attendance data available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Login to view your attendance',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _attendanceData.length + 1, // +1 for header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeader();
                    }
                    final attendance = _attendanceData[index - 1];
                    return _buildAttendanceCard(attendance);
                  },
                ),
    );
  }

  Widget _buildHeader() {
    // Calculate overall attendance
    int totalClasses = 0;
    int attendedClasses = 0;
    
    for (var subject in _attendanceData) {
      if (subject is Map<String, dynamic>) {
        totalClasses += _toInt(subject['totalClasses']);
        attendedClasses += _toInt(subject['attendedClasses']);
      }
    }
    
    double overallPercentage = totalClasses > 0 
        ? (attendedClasses / totalClasses) * 100 
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Overall Attendance',
              style: GoogleFonts.fragmentMono(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '${overallPercentage.toStringAsFixed(1)}%',
              style: GoogleFonts.fragmentMono(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: overallPercentage >= 75 
                    ? Colors.green 
                    : overallPercentage >= 60 
                        ? Colors.orange 
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: overallPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                overallPercentage >= 75 
                    ? Colors.green 
                    : overallPercentage >= 60 
                        ? Colors.orange 
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$attendedClasses/$totalClasses classes attended',
              style: GoogleFonts.fragmentMono(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(dynamic attendance) {
    if (attendance is! Map<String, dynamic>) {
      return const SizedBox.shrink();
    }
    
    final subject = attendance['subject'] as String? ?? 'Unknown Subject';
    final subjectCode = attendance['subjectCode'] as String? ?? 'SUBJ';
    final totalClasses = _toInt(attendance['totalClasses']);
    final attendedClasses = _toInt(attendance['attendedClasses']);
    final percentage = _toDouble(attendance['percentage']);
    final faculty = attendance['faculty'] as String? ?? 'Faculty Name';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subject,
                    style: GoogleFonts.fragmentMono(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: percentage >= 75 
                        ? Colors.green.withOpacity(0.1)
                        : percentage >= 60 
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: GoogleFonts.fragmentMono(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 75 
                          ? Colors.green 
                          : percentage >= 60 
                              ? Colors.orange 
                              : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 5),
            
            Text(
              subjectCode,
              style: GoogleFonts.fragmentMono(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 10),
            
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 75 
                    ? Colors.green 
                    : percentage >= 60 
                        ? Colors.orange 
                        : Colors.red,
              ),
            ),
            
            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$attendedClasses/$totalClasses classes',
                  style: GoogleFonts.fragmentMono(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Faculty: $faculty',
                  style: GoogleFonts.fragmentMono(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}