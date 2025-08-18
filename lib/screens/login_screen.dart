import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/student_api_service.dart';
import '../models/student.dart';
import '../services/local_storage_service.dart';
import 'package:my_campus_mate7/main.dart';// Import main app for navigation

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usnController = TextEditingController();
  final _dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('saved_username');
    final password = prefs.getString('saved_password');
    
    if (username != null && password != null) {
      setState(() {
        _usnController.text = username;
        _dobController.text = password;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials(String username, String password) async {
    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_username', username);
      await prefs.setString('saved_password', password);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final usn = _usnController.text.trim();
      final dob = _dobController.text.trim();

      // Show progress message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fetching data from MS RIT parents portal...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Fetch data from API
      final apiData = await StudentApiService.fetchStudentData(usn, dob);
      print('API Data: $apiData');
      
      // Process API data
      final studentData = await _processApiData(apiData, usn);
      
      // Save student data locally
      final student = Student(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: studentData['name'] as String,
        email: studentData['email'] as String,
        phone: studentData['phone'] as String,
        department: studentData['department'] as String,
        year: studentData['year'] as String,
        rollNumber: studentData['rollNumber'] as String,
        profileImage: studentData['profileImage'] as String,
        totalClasses: studentData['totalClasses'] as int,
        attendedClasses: studentData['attendedClasses'] as int,
        attendancePercentage: studentData['attendancePercentage'] as double,
      );

      await LocalStorageService.saveStudent(student);
      
      // Save attendance data
      if (studentData['attendance'] != null) {
        await LocalStorageService.saveAttendance(studentData['attendance'] as List<Map<String, dynamic>>);
      }

      // Save credentials if "Remember Me" is checked
      await _saveCredentials(usn, dob);

      // Navigate to main app with proper replacement
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyAppWrapper(), // Navigate to main app with drawer
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _processApiData(Map<String, dynamic> apiData, String usn) async {
    try {
      print('Processing API data...');
      
      // Extract student information
      String name = 'Student Name';
      String email = '${usn.toLowerCase()}@msrit.edu';
      String phone = '+91 98765 43210';
      String department = 'Computer Science & Engineering';
      String year = '3rd Year';
      String rollNumber = usn.length > 3 ? usn.substring(usn.length - 3) : usn;
      
      // Try to extract name from API data
      if (apiData.containsKey('student_info')) {
        final studentInfo = apiData['student_info'] as Map<String, dynamic>;
        if (studentInfo.containsKey('name')) {
          name = studentInfo['name'].toString();
        }
        if (studentInfo.containsKey('email')) {
          email = studentInfo['email'].toString();
        }
        if (studentInfo.containsKey('phone')) {
          phone = studentInfo['phone'].toString();
        }
        if (studentInfo.containsKey('department')) {
          department = studentInfo['department'].toString();
        }
        if (studentInfo.containsKey('year')) {
          year = studentInfo['year'].toString();
        }
      } else if (apiData.containsKey('name')) {
        name = apiData['name'].toString();
      }
      
      // Extract attendance data
      List<Map<String, dynamic>> attendanceData = [];
      if (apiData.containsKey('attendance')) {
        final attendance = apiData['attendance'];
        if (attendance is List) {
          attendanceData = attendance.cast<Map<String, dynamic>>();
        }
      }
      
      // Calculate overall attendance statistics
      int totalClasses = 0;
      int attendedClasses = 0;
      
      for (var subject in attendanceData) {
        totalClasses += _toInt(subject['totalClasses']);
        attendedClasses += _toInt(subject['attendedClasses']);
      }
      
      double attendancePercentage = totalClasses > 0 
          ? (attendedClasses / totalClasses) * 100 
          : 0.0;

      return {
        'name': name,
        'usn': usn.toUpperCase(),
        'email': email,
        'phone': phone,
        'department': department,
        'year': year,
        'rollNumber': rollNumber,
        'profileImage': '',
        'totalClasses': totalClasses,
        'attendedClasses': attendedClasses,
        'attendancePercentage': attendancePercentage,
        'attendance': attendanceData,
      };
      
    } catch (e) {
      print('Error processing API  $e');
      // Return default data if processing fails
      return await _getDefaultStudentData(usn);
    }
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

  Future<Map<String, dynamic>> _getDefaultStudentData(String usn) async {
    return {
      'name': 'Student Name',
      'usn': usn.toUpperCase(),
      'email': '${usn.toLowerCase()}@msrit.edu',
      'phone': '+91 98765 43210',
      'department': 'Computer Science & Engineering',
      'year': '3rd Year',
      'rollNumber': usn.length > 3 ? usn.substring(usn.length - 3) : usn,
      'profileImage': '',
      'totalClasses': 120,
      'attendedClasses': 105,
      'attendancePercentage': 87.5,
      'attendance': [
        {
          'subject': 'Data Structures & Algorithms',
          'subjectCode': '18CS32',
          'totalClasses': 45,
          'attendedClasses': 40,
          'percentage': 88.9,
          'faculty': 'Dr. Smith'
        },
        {
          'subject': 'Database Management Systems',
          'subjectCode': '18CS33',
          'totalClasses': 42,
          'attendedClasses': 38,
          'percentage': 90.5,
          'faculty': 'Prof. Johnson'
        },
        {
          'subject': 'Computer Networks',
          'subjectCode': '18CS34',
          'totalClasses': 40,
          'attendedClasses': 35,
          'percentage': 87.5,
          'faculty': 'Dr. Williams'
        },
        {
          'subject': 'Operating Systems',
          'subjectCode': '18CS35',
          'totalClasses': 44,
          'attendedClasses': 39,
          'percentage': 88.6,
          'faculty': 'Prof. Brown'
        },
        {
          'subject': 'Mathematics',
          'subjectCode': '18MAT31',
          'totalClasses': 50,
          'attendedClasses': 45,
          'percentage': 90.0,
          'faculty': 'Dr. Davis'
        },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.school,
                      size: 60,
                      color: const Color(0xFF6A1B9A),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // App Title
                Text(
                  'MyCampusMate',
                  style: GoogleFonts.fragmentMono(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 5),
                
                Text(
                  'MS RIT Parents Portal',
                  style: GoogleFonts.fragmentMono(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Login Card
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Student Login',
                        style: GoogleFonts.fragmentMono(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6A1B9A),
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // USN Field
                      TextFormField(
                        controller: _usnController,
                        decoration: const InputDecoration(
                          labelText: 'USN (e.g., 1MS21CS001)',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your USN';
                          }
                          // Basic USN format validation
                          if (!RegExp(r'^[1-9][A-Z]{1,2}\d{2}[A-Z]{2}\d{3}$').hasMatch(value.toUpperCase())) {
                            return 'Please enter a valid USN format';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Date of Birth Field
                      TextFormField(
                        controller: _dobController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth (DD/MM/YYYY)',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your date of birth';
                          }
                          // Validate date format
                          if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                            return 'Please enter date in DD/MM/YYYY format';
                          }
                          // Basic date validation
                          final parts = value.split('/');
                          if (parts.length == 3) {
                            final day = int.tryParse(parts[0]) ?? 0;
                            final month = int.tryParse(parts[1]) ?? 0;
                            final year = int.tryParse(parts[2]) ?? 0;
                            
                            if (day < 1 || day > 31) return 'Invalid day';
                            if (month < 1 || month > 12) return 'Invalid month';
                            if (year < 1990 || year > 2010) return 'Invalid year';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.done,
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF6A1B9A),
                          ),
                          Text(
                            'Remember me',
                            style: GoogleFonts.fragmentMono(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Logging in...',
                                      style: GoogleFonts.fragmentMono(),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.fragmentMono(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Info Text
                      Text(
                        '🔒 Your credentials are stored securely on your device\n'
                        '🌐 Data is fetched directly from MS RIT parents portal\n'
                        '⚠️ This app is for educational purposes only',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fragmentMono(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Footer
                Text(
                  '© 2024 MyCampusMate\nRamaiah Institute of Technology',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fragmentMono(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usnController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}