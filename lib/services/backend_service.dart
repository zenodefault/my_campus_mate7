import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  static const String _baseUrl = 'http://10.20.31.253:8000'; // Make sure this is your actual backend IP
  
  // Login and fetch student data
  static Future<Map<String, dynamic>> loginAndScrapeData(String username, String password) async {
    try {
      print('Attempting to connect to: $_baseUrl/login-and-fetch');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/login-and-fetch'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      print('Backend response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveCredentials(username, password);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid credentials. Please check your username and password.');
      } else if (response.statusCode == 422) {
        throw Exception('Validation error. Please check your input data format.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }
  
  // Save credentials securely
  static Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }
  
  // Get saved credentials
  static Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
    return {'username': username, 'password': password};
  }
  
  // Clear saved credentials
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
  }
}