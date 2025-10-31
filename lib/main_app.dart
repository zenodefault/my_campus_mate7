import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_campus_mate7/screens/profile_screen.dart';
import 'package:my_campus_mate7/screens/timetable_screen.dart';
import 'package:my_campus_mate7/screens/reminders_screen.dart';
import 'package:my_campus_mate7/screens/announcements_screen.dart';
import 'package:my_campus_mate7/screens/notes_screen.dart';
import 'package:my_campus_mate7/screens/attendance_screen.dart';
import 'package:my_campus_mate7/screens/developer_info_screen.dart';
import 'package:my_campus_mate7/screens/settings_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const ProfileScreen(),
    const TimetableScreen(),
    const RemindersScreen(),
    const AnnouncementsScreen(),
    const NotesScreen(),
    const AttendanceScreen(),
    const SettingsScreen(),
    const DeveloperInfoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    // Show message that login is disabled
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login functionality is currently disabled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MyCampusMate',
          style: GoogleFonts.fragmentMono(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6A1B9A),
                    const Color.fromRGBO(0x6A, 0x1B, 0x9A, 0.7),
                  ],
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'MyCampusMate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
                    child: Text(
                      'Your Campus Companion',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF6A1B9A)),
              title: const Text('Student Profile'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Color(0xFF6A1B9A)),
              title: const Text('Timetable'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Color(0xFF6A1B9A)),
              title: const Text('Notes'),
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm, color: Color(0xFF6A1B9A)),
              title: const Text('Reminders'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign, color: Color(0xFF6A1B9A)),
              title: const Text('Announcements'),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF6A1B9A),
              ),
              title: const Text('Attendance'),
              onTap: () {
                _onItemTapped(5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF6A1B9A)),
              title: const Text('Settings'),
              onTap: () {
                _onItemTapped(6);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Color(0xFF6A1B9A)),
              title: const Text('Developer Info'),
              onTap: () {
                _onItemTapped(7);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation();
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.fragmentMono(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF4A148C),
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.fragmentMono(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.fragmentMono(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              child: Text(
                'Logout',
                style: GoogleFonts.fragmentMono(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.red[300]
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
