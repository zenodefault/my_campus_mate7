import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_storage_service.dart';
import '../models/student.dart';
import '../widgets/glassmorphism_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Student? _student;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final student = await LocalStorageService.getStudent();
      if (student == null) {
        print('No student data found. Please login.');
      } else {
        if (mounted) {
          setState(() {
            _student = student;
          });
        }
      }
    } catch (e) {
      print('Error loading student  $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.fragmentMono(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudentData,
            tooltip: 'Refresh Profile Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
              ),
            )
          : _student == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 80,
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No profile data available',
                        style: GoogleFonts.fragmentMono(
                          fontSize: 18, 
                          color: isDarkMode ? Colors.grey[400] : Colors.grey
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadStudentData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                        ),
                        child: Text(
                          'Refresh Data',
                          style: GoogleFonts.fragmentMono(),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Enhanced Profile Header with Image Support
                      GlassmorphismContainer(
                        margin: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF9C27B0),
                              Color(0xFF6A1B9A),
                            ],
                          ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile Image Section
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: _student!.profileImage.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          _student!.profileImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            // Fallback to text avatar if image fails to load
                                            return Container(
                                              color: Colors.white,
                                              child: Center(
                                                child: Text(
                                                  _student!.name.isNotEmpty
                                                      ? _student!.name[0].toUpperCase()
                                                      : 'S',
                                                  style: const TextStyle(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF6A1B9A),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(
                                        // Text avatar when no image URL is provided
                                        color: Colors.white,
                                        child: Center(
                                          child: Text(
                                            _student!.name.isNotEmpty
                                                ? _student!.name[0].toUpperCase()
                                                : 'S',
                                            style: const TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF6A1B9A),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 25),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _student!.name,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _student!.email,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _student!.rollNumber,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 25),

                      // Enhanced Stats Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: GlassmorphismContainer(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? const Color(0xFF2D4A2D)
                                            : const Color(0xFFE8F5E9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.percent,
                                        size: 32,
                                        color: isDarkMode ? Colors.green[300]! : Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${_student!.attendancePercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.green[300] : const Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Attendance',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: GlassmorphismContainer(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? const Color(0xFF1A3A5F)
                                            : const Color(0xFFE3F2FD),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.school,
                                        size: 32,
                                        color: isDarkMode ? Colors.blue[300]! : Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${_student!.attendedClasses}/${_student!.totalClasses}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.blue[300] : const Color(0xFF1565C0),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Classes',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Enhanced Profile Information Section
                      GlassmorphismContainer(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDarkMode ? Colors.grey[700]! : const Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : const Color(0xFF4A148C),
                                ),
                              ),
                            ),
                            _buildInfoTile(
                              icon: Icons.badge,
                              title: 'USN',
                              value: _student!.rollNumber,
                              isDarkMode: isDarkMode,
                            ),
                            _buildInfoTile(
                              icon: Icons.business,
                              title: 'Department',
                              value: _student!.department,
                              isDarkMode: isDarkMode,
                            ),
                            _buildInfoTile(
                              icon: Icons.calendar_today,
                              title: 'Year',
                              value: _student!.year,
                              isDarkMode: isDarkMode,
                            ),
                            _buildInfoTile(
                              icon: Icons.email,
                              title: 'Email',
                              value: _student!.email,
                              isDarkMode: isDarkMode,
                            ),
                            _buildInfoTile(
                              icon: Icons.phone,
                              title: 'Phone',
                              value: _student!.phone,
                              isDarkMode: isDarkMode,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : const Color(0xFFF3E5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.white : const Color(0xFF6A1B9A),
              size: 22,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}