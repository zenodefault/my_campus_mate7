import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/backend_service.dart';
import 'login_screen.dart';
import '../widgets/glassmorphism_container.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const DashboardScreen({super.key, required this.studentData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await BackendService.clearCredentials();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
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
                    const Color(0xFF6A1B9A).withOpacity(0.7),
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
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF6A1B9A)),
              title: const Text('Student Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Color(0xFF6A1B9A)),
              title: const Text('Academic Performance'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.percent, color: Color(0xFF6A1B9A)),
              title: const Text('Attendance'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Color(0xFF6A1B9A)),
              title: const Text('Announcements'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Color(0xFF6A1B9A)),
              title: const Text('About MS RIT'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                await BackendService.clearCredentials();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Profile Header with MS RIT branding
            Container(
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
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        'S', // Placeholder for student initial
                        style: GoogleFonts.fragmentMono(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6A1B9A),
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
                          'Student Name', // Will be replaced with actual data
                          style: GoogleFonts.fragmentMono(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'USN: 1MS21XX001', // Will be replaced with actual data
                          style: GoogleFonts.fragmentMono(
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
                            '3rd Year, CSE', // Will be replaced with actual data
                            style: GoogleFonts.fragmentMono(
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
            
            const SizedBox(height: 25),

            // MS RIT Highlights Section
            Text(
              'MS RIT Highlights',
              style: GoogleFonts.fragmentMono(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A148C),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Highlight Cards
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildHighlightCard(
                  title: 'NIRF Rank',
                  value: '#75',
                  subtitle: 'Engineering',
                  icon: Icons.star,
                  color: Colors.purple,
                ),
                _buildHighlightCard(
                  title: 'Architecture',
                  value: '#21',
                  subtitle: 'In India',
                  icon: Icons.architecture,
                  color: Colors.blue,
                ),
                _buildHighlightCard(
                  title: 'Placements',
                  value: '95%',
                  subtitle: 'Average',
                  icon: Icons.work,
                  color: Colors.green,
                ),
                _buildHighlightCard(
                  title: 'Collaborations',
                  value: '60+',
                  subtitle: 'Industries',
                  icon: Icons.handshake,
                  color: Colors.orange,
                ),
              ],
            ),
            
            const SizedBox(height: 30),

            // Academic Performance Section
            Text(
              'Academic Performance',
              style: GoogleFonts.fragmentMono(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A148C),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Marks Table
            GlassmorphismContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Marks',
                    style: GoogleFonts.fragmentMono(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // This will be populated with actual marks data
                  _buildMarksTable(),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // Attendance Section
            Text(
              'Attendance',
              style: GoogleFonts.fragmentMono(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A148C),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Attendance Table
            GlassmorphismContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Attendance',
                    style: GoogleFonts.fragmentMono(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // This will be populated with actual attendance data
                  _buildAttendanceTable(),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // MS RIT Information Section
            Text(
              'About MS RIT',
              style: GoogleFonts.fragmentMono(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A148C),
              ),
            ),
            
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ramaiah Institute of Technology',
                    style: GoogleFonts.fragmentMono(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We are constantly improvising to be at the top. We are ranked No. 75 among 1463 Engineering & No. 21 among 115 Architecture institutions across the country as per NIRF, MOE, Govt. of India, 2024.',
                    style: GoogleFonts.fragmentMono(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Our Values:',
                    style: GoogleFonts.fragmentMono(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildValueItem('Quality & Excellence', 'We are devoted to provide quality education and excellence in all our endeavors.'),
                  _buildValueItem('Research & Innovation', 'We are committed to provide infrastructure and other support for quality research and product development.'),
                  _buildValueItem('Freedom of Expression', 'We are dedicated to the free exchange of ideas in a constructive environment.'),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return GlassmorphismContainer(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.fragmentMono(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.fragmentMono(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: GoogleFonts.fragmentMono(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMarksTable() {
    // This will be populated with actual marks data from the backend
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text(
              'Subject',
              style: GoogleFonts.fragmentMono(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'IA1',
              style: GoogleFonts.fragmentMono(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'IA2',
              style: GoogleFonts.fragmentMono(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'IA3',
              style: GoogleFonts.fragmentMono(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Avg',
              style: GoogleFonts.fragmentMono(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('Data Structures', style: GoogleFonts.fragmentMono())),
            DataCell(Text('25', style: GoogleFonts.fragmentMono())),
            DataCell(Text('28', style: GoogleFonts.fragmentMono())),
            DataCell(Text('27', style: GoogleFonts.fragmentMono())),
            DataCell(Text('26.7', style: GoogleFonts.fragmentMono())),
          ]),
          DataRow(cells: [
            DataCell(Text('Database Systems', style: GoogleFonts.fragmentMono())),
            DataCell(Text('22', style: GoogleFonts.fragmentMono())),
            DataCell(Text('24', style: GoogleFonts.fragmentMono())),
            DataCell(Text('26', style: GoogleFonts.fragmentMono())),
            DataCell(Text('24.0', style: GoogleFonts.fragmentMono())),
          ]),
          DataRow(cells: [
            DataCell(Text('Computer Networks', style: GoogleFonts.fragmentMono())),
            DataCell(Text('27', style: GoogleFonts.fragmentMono())),
            DataCell(Text('25', style: GoogleFonts.fragmentMono())),
            DataCell(Text('28', style: GoogleFonts.fragmentMono())),
            DataCell(Text('26.7', style: GoogleFonts.fragmentMono())),
          ]),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable() {
    // This will be populated with actual attendance data from the backend
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text(
              'Subject',
              style: GoogleFonts.fragmentMono(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Total',
              style: GoogleFonts.fragmentMono(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Present',
              style: GoogleFonts.fragmentMono(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Percentage',
              style: GoogleFonts.fragmentMono(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('Data Structures', style: GoogleFonts.fragmentMono())),
            DataCell(Text('45', style: GoogleFonts.fragmentMono())),
            DataCell(Text('40', style: GoogleFonts.fragmentMono())),
            DataCell(Text('88.9%', style: GoogleFonts.fragmentMono())),
          ]),
          DataRow(cells: [
            DataCell(Text('Database Systems', style: GoogleFonts.fragmentMono())),
            DataCell(Text('42', style: GoogleFonts.fragmentMono())),
            DataCell(Text('38', style: GoogleFonts.fragmentMono())),
            DataCell(Text('90.5%', style: GoogleFonts.fragmentMono())),
          ]),
          DataRow(cells: [
            DataCell(Text('Computer Networks', style: GoogleFonts.fragmentMono())),
            DataCell(Text('40', style: GoogleFonts.fragmentMono())),
            DataCell(Text('35', style: GoogleFonts.fragmentMono())),
            DataCell(Text('87.5%', style: GoogleFonts.fragmentMono())),
          ]),
        ],
      ),
    );
  }

  Widget _buildValueItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.fragmentMono(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: GoogleFonts.fragmentMono(
              fontSize: 13,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}