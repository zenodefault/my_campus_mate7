class TimetableEntry {
  final String id;
  final String day;
  final String startTime;
  final String endTime;
  final String subject;
  final String room;

  TimetableEntry({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.room,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'subject': subject,
      'room': room,
    };
  }

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'] ?? '',
      day: map['day'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      subject: map['subject'] ?? '',
      room: map['room'] ?? '',
    );
  }
}