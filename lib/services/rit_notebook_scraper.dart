import 'dart:io';
import 'package:http/io_client.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class RITNotebookScraper {
  static const String baseUrl = 'https://ritnotebook.pages.dev';
  
  /// Scrape resources from RIT Notebook
  static Future<List<Map<String, dynamic>>> scrapeResources() async {
    try {
      print('Starting RIT Notebook scraping...');
      
      // Create HTTP client with SSL bypass for testing
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      
      final client = IOClient(httpClient);
      
      try {
        // Step 1: Get main resources page
        print('Fetching resources page...');
        final response = await client.get(
          Uri.parse('$baseUrl/notes'),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Connection': 'keep-alive',
          },
        );
        
        print('Resources page response status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final document = parser.parse(response.body);
          final resources = await _extractResources(document);
          
          if (resources.isNotEmpty) {
            print('Found ${resources.length} resources');
            return resources;
          } else {
            print('No resources found, returning mock data');
            return await _getMockResources();
          }
        } else {
          print('Failed to fetch resources page. Status: ${response.statusCode}');
          return await _getMockResources();
        }
        
      } finally {
        client.close();
      }
      
    } catch (e) {
      print('Resources scraping error: $e');
      return await _getMockResources();
    }
  }
  
  /// Extract resources from the page
  static Future<List<Map<String, dynamic>>> _extractResources(Document document) async {
    final resources = <Map<String, dynamic>>[];
    
    try {
      // Look for resource links
      final links = document.querySelectorAll('a[href*=".html"]');
      
      for (var link in links) {
        final href = link.attributes['href'];
        final text = link.text.trim();
        
        if (href != null && text.isNotEmpty) {
          String fullUrl = href;
          if (href.startsWith('/')) {
            fullUrl = '$baseUrl$href';
          } else if (!href.startsWith('http')) {
            fullUrl = '$baseUrl/$href';
          }
          
          resources.add({
            'title': text,
            'url': fullUrl,
            'category': _categorizeResource(text),
            'description': _generateDescription(text),
          });
        }
      }
      
      // If no links found, try alternative approach
      if (resources.isEmpty) {
        final buttons = document.querySelectorAll('button, .btn, .button');
        for (var button in buttons) {
          final text = button.text.trim();
          if (text.toLowerCase().contains('view') || 
              text.toLowerCase().contains('download') ||
              text.toLowerCase().contains('notes')) {
            
            resources.add({
              'title': text,
              'url': '$baseUrl/notes',
              'category': _categorizeResource(text),
              'description': _generateDescription(text),
            });
          }
        }
      }
      
    } catch (e) {
      print('Error extracting resources: $e');
    }
    
    return resources.isNotEmpty ? resources : await _getMockResources();
  }
  
  /// Categorize resource based on title
  static String _categorizeResource(String title) {
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('first') || lowerTitle.contains('1st') || lowerTitle.contains('semester')) {
      return '1st Semester';
    } else if (lowerTitle.contains('second') || lowerTitle.contains('2nd')) {
      return '2nd Semester';
    } else if (lowerTitle.contains('third') || lowerTitle.contains('3rd')) {
      return '3rd Semester';
    } else if (lowerTitle.contains('fourth') || lowerTitle.contains('4th')) {
      return '4th Semester';
    } else if (lowerTitle.contains('cse') || lowerTitle.contains('computer')) {
      return 'CSE';
    } else if (lowerTitle.contains('ece') || lowerTitle.contains('electronics')) {
      return 'ECE';
    } else if (lowerTitle.contains('eee') || lowerTitle.contains('electrical')) {
      return 'EEE';
    } else if (lowerTitle.contains('civil')) {
      return 'Civil';
    } else if (lowerTitle.contains('mech') || lowerTitle.contains('mechanical')) {
      return 'Mechanical';
    } else {
      return 'General';
    }
  }
  
  /// Generate description based on title
  static String _generateDescription(String title) {
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('notes')) {
      return 'Comprehensive study notes and materials';
    } else if (lowerTitle.contains('question') || lowerTitle.contains('qp')) {
      return 'Previous year question papers and solutions';
    } else if (lowerTitle.contains('syllabus')) {
      return 'Official syllabus and curriculum details';
    } else if (lowerTitle.contains('assignment') || lowerTitle.contains('lab')) {
      return 'Lab manuals and assignment guidelines';
    } else {
      return 'Study materials and resources';
    }
  }
  
  /// Get mock resources data (fallback)
  static Future<List<Map<String, dynamic>>> _getMockResources() async {
    return [
      {
        'title': '1st Semester Notes',
        'url': '$baseUrl/notes/first.html',
        'category': '1st Semester',
        'description': 'Comprehensive study notes for first semester subjects including Mathematics, Physics, and Communication English',
      },
      {
        'title': '2nd Semester Notes',
        'url': '$baseUrl/notes/second.html',
        'category': '2nd Semester',
        'description': 'Study materials for second semester subjects including Chemistry, Professional Writing Skills, and Engineering Drawing',
      },
      {
        'title': '3rd Semester Notes',
        'url': '$baseUrl/notes/third.html',
        'category': '3rd Semester',
        'description': 'Notes for core subjects like Data Structures, Digital Principles, and Discrete Mathematics',
      },
      {
        'title': '4th Semester Notes',
        'url': '$baseUrl/notes/fourth.html',
        'category': '4th Semester',
        'description': 'Advanced study materials for Database Management Systems, Operating Systems, and Microprocessors',
      },
      {
        'title': 'Computer Science Stream',
        'url': '$baseUrl/notes/cse.html',
        'category': 'CSE',
        'description': 'Specialized resources for Computer Science & Engineering stream students',
      },
      {
        'title': 'Electronics Stream',
        'url': '$baseUrl/notes/ece.html',
        'category': 'ECE',
        'description': 'Study materials for Electronics & Communication Engineering stream',
      },
      {
        'title': 'Civil Engineering Stream',
        'url': '$baseUrl/notes/civil.html',
        'category': 'Civil',
        'description': 'Resources for Civil Engineering students including Structural Analysis and Hydraulics',
      },
      {
        'title': 'Mechanical Stream',
        'url': '$baseUrl/notes/mech.html',
        'category': 'Mechanical',
        'description': 'Study materials for Mechanical Engineering stream students',
      },
    ];
  }
}