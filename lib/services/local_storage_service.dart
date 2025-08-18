import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/timetable_entry.dart';
import '../models/note.dart';

class LocalStorageService {
  static const String STUDENT_KEY = 'student_data';
  static const String TIMETABLE_KEY = 'timetable_data';
  static const String NOTES_KEY = 'notes_data';
  static const String ATTENDANCE_KEY = 'attendance_data';

  // Student Methods
  static Future<void> saveStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    final studentJson = jsonEncode(student.toMap());
    await prefs.setString(STUDENT_KEY, studentJson);
  }

  static Future<Student?> getStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final studentJson = prefs.getString(STUDENT_KEY);
    
    if (studentJson != null) {
      try {
        final studentMap = jsonDecode(studentJson);
        return Student.fromMap(studentMap);
      } catch (e) {
        print('Error decoding student: $e');
        return null;
      }
    }
    return null;
  }

  static Future<bool> hasStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(STUDENT_KEY);
  }

  static Future<void> clearStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(STUDENT_KEY);
  }

  // Timetable Methods
  static Future<void> saveTimetable(List<TimetableEntry> timetable) async {
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = jsonEncode(timetable.map((entry) => entry.toMap()).toList());
    await prefs.setString(TIMETABLE_KEY, timetableJson);
  }

  static Future<List<TimetableEntry>> getTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = prefs.getString(TIMETABLE_KEY);

    if (timetableJson != null) {
      try {
        final timetableList = jsonDecode(timetableJson) as List<dynamic>;
        return timetableList.map((entry) => TimetableEntry.fromMap(entry)).toList();
      } catch (e) {
        print('Error decoding timetable: $e');
        return [];
      }
    }
    return [];
  }

  static Future<void> addTimetableEntry(TimetableEntry entry) async {
    final currentTimetable = await getTimetable();
    currentTimetable.add(entry);
    await saveTimetable(currentTimetable);
  }

  static Future<void> updateTimetableEntry(TimetableEntry entry) async {
    final currentTimetable = await getTimetable();
    final index = currentTimetable.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      currentTimetable[index] = entry;
      await saveTimetable(currentTimetable);
    }
  }

  static Future<void> deleteTimetableEntry(String id) async {
    final currentTimetable = await getTimetable();
    final updatedTimetable = currentTimetable.where((entry) => entry.id != id).toList();
    await saveTimetable(updatedTimetable);
  }

  // Notes Methods
  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = jsonEncode(notes.map((note) => note.toMap()).toList());
    await prefs.setString(NOTES_KEY, notesJson);
  }

  static Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(NOTES_KEY);

    if (notesJson != null) {
      try {
        final notesList = jsonDecode(notesJson) as List<dynamic>;
        return notesList.map((note) => Note.fromMap(note)).toList();
      } catch (e) {
        print('Error decoding notes: $e');
        return [];
      }
    }
    return [];
  }

  static Future<void> addNote(Note note) async {
    final currentNotes = await getNotes();
    currentNotes.add(note);
    await saveNotes(currentNotes);
  }

  static Future<void> updateNote(Note note) async {
    final currentNotes = await getNotes();
    final index = currentNotes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      currentNotes[index] = note;
      await saveNotes(currentNotes);
    }
  }

  static Future<void> deleteNote(String id) async {
    final currentNotes = await getNotes();
    final updatedNotes = currentNotes.where((note) => note.id != id).toList();
    await saveNotes(updatedNotes);
  }

  // Attendance Methods
  static Future<void> saveAttendance(List<Map<String, dynamic>> attendance) async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = jsonEncode(attendance);
    await prefs.setString(ATTENDANCE_KEY, attendanceJson);
  }

  static Future<List<Map<String, dynamic>>> getAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString(ATTENDANCE_KEY);

    if (attendanceJson != null) {
      try {
        final attendanceList = jsonDecode(attendanceJson) as List<dynamic>;
        return attendanceList.cast<Map<String, dynamic>>();
      } catch (e) {
        print('Error decoding attendance: $e');
        return [];
      }
    }
    return [];
  }

  // Additional utility methods
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(STUDENT_KEY);
    await prefs.remove(TIMETABLE_KEY);
    await prefs.remove(NOTES_KEY);
    await prefs.remove(ATTENDANCE_KEY);
  }

  static Future<bool> hasTimetableData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(TIMETABLE_KEY);
  }

  static Future<bool> hasNotesData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(NOTES_KEY);
  }

  static Future<bool> hasAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(ATTENDANCE_KEY);
  }
}