class Student {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String year;
  final String rollNumber;
  final String profileImage; // This field now handles image URLs
  final int totalClasses;
  final int attendedClasses;
  final double attendancePercentage;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.year,
    required this.rollNumber,
    required this.profileImage, // Image URL from API
    required this.totalClasses,
    required this.attendedClasses,
    required this.attendancePercentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'year': year,
      'rollNumber': rollNumber,
      'profileImage': profileImage, // Include image URL in serialization
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
      'attendancePercentage': attendancePercentage,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      profileImage: map['profileImage'] ?? '', // Handle image URL from deserialization
      totalClasses: map['totalClasses'] ?? 0,
      attendedClasses: map['attendedClasses'] ?? 0,
      attendancePercentage: (map['attendancePercentage'] is int)
          ? (map['attendancePercentage'] as int).toDouble()
          : (map['attendancePercentage'] ?? 0.0),
    );
  }
}