import 'package:flutter/material.dart';

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Info'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E5F5),
              Color(0xFFE1BEE7),
              Color(0xFFCE93D8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: Image.asset(
                    'assets/images/logo.png', // Your app logo
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              const Text(
                'MyCampusMate',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
              ),
              
              const SizedBox(height: 5),
              
              const Text(
                'Your Campus Companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Developers Section
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meet Our Developers',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C),
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Developer 1
                    _buildDeveloperCard(
                      name: 'Naveed H K',
                      usn: 'USN: 1MS24ET031',
                      role: 'Lead Developer',
                      email: 'naveedhk@college.edu',
                      profileImage: 'assets/images/developer1.jpg', // Local asset
                      context: context,
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Developer 2
                    _buildDeveloperCard(
                      name: 'Kenneth Sidhartha Martin',
                      usn: 'USN: 1MS24EC052',
                      role: 'Co Developer',
                      email: 'kennethsm@college.edu',
                      profileImage: 'assets/images/developer2.jpg', // Local asset
                      context: context,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Contact Info
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get In Touch',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Have questions or feedback? We\'d love to hear from you!',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          color: Color(0xFF9C27B0),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'support@mycampusmate.com',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6A1B9A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: Color(0xFF9C27B0),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '+91 98765 43210',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6A1B9A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String usn,
    required String role,
    required String email,
    required String profileImage,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE1BEE7),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Image from Assets
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE1BEE7),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                profileImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to text avatar if image fails to load
                  return Container(
                    color: const Color(0xFF9C27B0),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name.split(' ').map((n) => n[0]).take(2).join() : 'DV',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  usn,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6A1B9A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1BEE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.w600,
                    ),
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