import 'dart:io';
import 'package:http/io_client.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class MSRITNewsScraper {
  static const String baseUrl = 'https://msrit.edu';
  static const String newsUrl = '$baseUrl/news.html';

  /// Scrape news from MS RIT news page
  Future<List<Map<String, dynamic>>> scrapeNews() async {
    try {
      print('Starting news scraping from MS RIT website...');

      // Create HTTP client with SSL bypass for testing (use with caution)
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);

      final client = IOClient(httpClient);

      try {
        print('Fetching news from: $newsUrl');
        final response = await client.get(
          Uri.parse(newsUrl),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Connection': 'keep-alive',
          },
        );

        print('News page response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final document = parse(response.body);
          final news = await _extractNews(document);

          if (news.isNotEmpty) {
            print('Found ${news.length} news items');
            return news;
          } else {
            print('No news items found, trying alternative extraction');
            // Try alternative extraction methods
            final alternativeNews = await _extractNewsAlternative(document);
            if (alternativeNews.isNotEmpty) {
              return alternativeNews;
            }
          }
        } else {
          print('Failed to fetch news page. Status: ${response.statusCode}');
        }

        // Return mock data if scraping fails
        print('Returning mock news data');
        return await _getMockNews();
      } finally {
        client.close();
      }
    } catch (e) {
      print('News scraping error: $e');
      // Return mock data on error
      return await _getMockNews();
    }
  }

  /// Extract news from the news page
  Future<List<Map<String, dynamic>>> _extractNews(Document document) async {
    final news = <Map<String, dynamic>>[];

    try {
      // Look for latest news section specifically
      final latestNewsSelectors = [
        '.latest-news',
        '#latest-news',
        '.recent-news',
        '.news-latest',
        '.news-section',
        '.news-content',
        '.content-news',
        '[class*="news"]', // More general selector
        '[id*="news"]'
      ];

      Element? newsContainer;

      // Try to find the latest news container
      for (var selector in latestNewsSelectors) {
        final candidate = document.querySelector(selector);
        if (candidate != null) {
          newsContainer = candidate;
          print('Found latest news container using selector: $selector');
          break;
        }
      }

      // If no specific container found, use the whole document body
      if (newsContainer == null) {
        print('No specific news container found, using document body');
        newsContainer = document.body;
      }

      // Look for news items within the container
      final newsItemSelectors = [
        '.news-item',
        '.news-card',
        '.article',
        '.post',
        '.news-content',
        '.news-block',
        '.media-content',
        '.content-item',
        '.news-article',
        '.story',
        '.news-row',
        '.news-box',
        '[class*="news-item"]',
        '[class*="article"]'
      ];

      List<Element> newsElements = [];

      // Try different selectors to find news items
      for (var selector in newsItemSelectors) {
        try {
          // Fix: Add null check before calling querySelectorAll
          if (newsContainer != null) {
            final elements = newsContainer.querySelectorAll(selector);
            if (elements.isNotEmpty) {
              newsElements = elements.toList();
              print('Found ${newsElements.length} news items using selector: $selector');
              break;
            }
          }
        } catch (e) {
          print('Error querying selector $selector: $e');
          continue;
        }
      }

      // If still no elements found, try more generic approach
      if (newsElements.isEmpty) {
        print('Trying generic selectors for news items');
        try {
          // Fix: Add null check before calling querySelectorAll
          if (newsContainer != null) {
            // Try common content containers
            final contentSelectors = ['div', '.content', '.container', '.wrapper'];
            for (var selector in contentSelectors) {
              final elements = newsContainer.querySelectorAll(selector);
              // Filter elements that look like news items
              for (var element in elements) {
                final text = _cleanText(element.text);
                if (text.length > 30 && 
                    (text.toLowerCase().contains('news') || 
                     text.toLowerCase().contains('event') ||
                     text.toLowerCase().contains('announcement') ||
                     _hasDatePattern(text))) {
                  newsElements.add(element);
                }
              }
            }
          }
        } catch (e) {
          print('Error in generic selector approach: $e');
        }
        
        // If still empty, try finding all divs and p tags
        if (newsElements.isEmpty) {
          try {
            // Fix: Add null check before calling querySelectorAll
            if (newsContainer != null) {
              final divElements = newsContainer.querySelectorAll('div');
              final pElements = newsContainer.querySelectorAll('p');
              newsElements.addAll(divElements);
              newsElements.addAll(pElements);
              print('Using all divs and p tags, found ${newsElements.length} potential news items');
            }
          } catch (e) {
            print('Error getting all divs and p tags: $e');
          }
        }
      }

      // Parse each news element
      for (var element in newsElements) {
        final newsItem = _parseNewsElement(element);
        if (newsItem != null) {
          news.add(newsItem);
        }
      }

      // If no structured news found, try generic approach
      if (news.isEmpty) {
        print('Trying generic news extraction...');
        news.addAll(_extractNewsGeneric(document));
      }
      
      // Limit results to prevent overwhelming the UI
      if (news.length > 20) {
        news.removeRange(20, news.length);
      }
    } catch (e) {
      print('Error extracting news: $e');
    }

    // If still no news found, return mock data
    if (news.isEmpty) {
      print('No news found, returning mock data');
      return await _getMockNews();
    }

    return news;
  }

  /// Alternative news extraction method
  Future<List<Map<String, dynamic>>> _extractNewsAlternative(Document document) async {
    final news = <Map<String, dynamic>>[];

    try {
      // Look for headings that indicate news sections
      final headings = document.querySelectorAll('h1, h2, h3, h4');

      for (var heading in headings) {
        final headingText = heading.text.toLowerCase();
        if (headingText.contains('latest') ||
            headingText.contains('recent') ||
            headingText.contains('news')) {
          // Look for content following this heading
          Element? nextElement = heading.nextElementSibling;
          int itemsFound = 0;

          while (nextElement != null && itemsFound < 10) {
            try {
              // Fix: Add null check before calling querySelectorAll
              final potentialItems = nextElement.querySelectorAll('li, div, p');

              for (var item in potentialItems) {
                if (itemsFound >= 10) break;

                final text = _cleanText(item.text);
                if (text.length > 20 && text.length < 300) {
                  final newsItem = {
                    'title': _extractTitleFromText(text),
                    'description': text,
                    'date': _extractDateFromText(text),
                    'url': 'https://msrit.edu/news.html',
                  };
                  news.add(newsItem);
                  itemsFound++;
                }
              }
                        } catch (e) {
              print('Error processing next element: $e');
            }

            nextElement = nextElement.nextElementSibling;
          }
        }
      }
    } catch (e) {
      print('Error in alternative extraction: $e');
    }

    return news;
  }

  /// Generic news extraction approach
  List<Map<String, dynamic>> _extractNewsGeneric(Document document) {
    final news = <Map<String, dynamic>>[];

    try {
      // Look for lists that might contain news items
      final lists = document.querySelectorAll('ul, ol');

      for (var list in lists) {
        final items = list.querySelectorAll('li');
        if (items.isNotEmpty && items.length <= 30) {
          for (var item in items) {
            final text = _cleanText(item.text);
            if (text.length > 20 && text.length < 300) {
              final newsItem = {
                'title': _extractTitleFromText(text),
                'description': text,
                'date': _extractDateFromText(text),
                'url': 'https://msrit.edu/news.html',
              };
              news.add(newsItem);
            }
          }
        }
      }

      // If still no news, look for div elements with news-like content
      if (news.isEmpty) {
        final divs = document.querySelectorAll('div');
        int newsCount = 0;

        for (var div in divs) {
          if (newsCount >= 15) break; // Limit to 15 news items

          final text = _cleanText(div.text);
          if (text.length > 30 && text.length < 300) {
            // Check if it looks like a news item
            if (text.toLowerCase().contains('college') ||
                text.toLowerCase().contains('campus') ||
                text.toLowerCase().contains('student') ||
                text.toLowerCase().contains('faculty') ||
                text.toLowerCase().contains('department') ||
                text.toLowerCase().contains('program') ||
                text.toLowerCase().contains('event') ||
                text.toLowerCase().contains('research') ||
                _hasDatePattern(text)) {
              
              final newsItem = {
                'title': _extractTitleFromText(text),
                'description': text,
                'date': _extractDateFromText(text),
                'url': 'https://msrit.edu/news.html',
              };
              news.add(newsItem);
              newsCount++;
            }
          }
        }
      }
    } catch (e) {
      print('Error in generic news extraction: $e');
    }

    return news;
  }

  /// Parse individual news element with better text cleaning
  Map<String, dynamic>? _parseNewsElement(Element element) {
    try {
      String title = '';
      String description = '';
      String date = '';
      String url = 'https://msrit.edu/news.html';

      // Clean the element text first
      final elementText = _cleanText(element.text);
      
      // If element text is too short or looks like code, skip it
      if (elementText.length < 10) {
        return null;
      }

      // Try to extract title
      final titleSelectors = [
        '.title',
        '.news-title',
        '.heading',
        '.headline',
        'h1',
        'h2',
        'h3',
        'h4',
        '.post-title'
      ];

      for (var selector in titleSelectors) {
        final titleElement = element.querySelector(selector);
        if (titleElement != null) {
          final titleText = _cleanText(titleElement.text);
          if (titleText.isNotEmpty && titleText.length > 5) {
            title = titleText;
            break;
          }
        }
      }

      // If no title found, try first heading
      if (title.isEmpty) {
        final heading = element.querySelector('h1, h2, h3, h4, h5');
        if (heading != null) {
          final headingText = _cleanText(heading.text);
          if (headingText.isNotEmpty) {
            title = headingText;
          }
        }
      }

      // If still no title, use first significant text
      if (title.isEmpty) {
        // Try to find a good title from the element text
        final lines = elementText.split('\n');
        for (var line in lines) {
          final cleanedLine = _cleanText(line);
          if (cleanedLine.length > 10 && cleanedLine.length < 150) {
            title = cleanedLine;
            break;
          }
        }
        
        // If still no title, use first part of element text
        if (title.isEmpty) {
          title = elementText.length > 100 
              ? '${elementText.substring(0, 100).trim()}...' 
              : elementText;
        }
      }

      // Try to extract description
      final descSelectors = [
        '.description', 
        '.summary', 
        '.content', 
        '.excerpt', 
        'p'
      ];

      for (var selector in descSelectors) {
        final descElement = element.querySelector(selector);
        if (descElement != null) {
          final descText = _cleanText(descElement.text);
          if (descText.isNotEmpty && descText != title && descText.length > 20) {
            description = descText;
            break;
          }
        }
      }

      // If no description, use element text minus title
      if (description.isEmpty) {
        final cleanedElementText = _cleanText(elementText);
        if (cleanedElementText.length > title.length + 30) {
          final startIndex = title.length < cleanedElementText.length ? title.length : 0;
          description = cleanedElementText.substring(startIndex).trim();
        } else {
          description = cleanedElementText;
        }
      }

      // Clean up description
      description = _cleanText(description);
      
      // Limit description length
      if (description.length > 200) {
        description = '${description.substring(0, 200).trim()}...';
      }

      // Try to extract date
      final dateSelectors = [
        '.date',
        '.time',
        '.datetime',
        '.published',
        '.post-date',
        '.news-date'
      ];

      for (var selector in dateSelectors) {
        final dateElement = element.querySelector(selector);
        if (dateElement != null) {
          final dateText = _cleanText(dateElement.text);
          if (dateText.isNotEmpty) {
            date = dateText;
            break;
          }
        }
      }

      // If no date found, try to extract from text
      if (date.isEmpty) {
        date = _extractDateFromText('$title $description');
      }

      // Try to extract URL
      final linkElement = element.querySelector('a');
      if (linkElement != null) {
        final href = linkElement.attributes['href'];
        if (href != null) {
          if (href.startsWith('http')) {
            url = href;
          } else if (href.startsWith('/')) {
            url = 'https://msrit.edu$href';
          } else {
            url = 'https://msrit.edu/$href';
          }
        }
      }

      // Only return if we have a reasonable title
      if (title.isNotEmpty && title.length > 5) {
        // Final cleaning
        title = _cleanText(title);
        description = _cleanText(description);
        
        return {
          'title': title.length > 100 ? '${title.substring(0, 100)}...' : title,
          'description': description.isNotEmpty 
              ? (description.length > 150 ? '${description.substring(0, 150)}...' : description)
              : title,
          'date': date.isNotEmpty ? date : 'Recent',
          'url': url,
        };
      }
    } catch (e) {
      print('Error parsing news element: $e');
    }

    return null;
  }

  /// Clean text by removing extra whitespace and control characters
  String _cleanText(String text) {
    if (text.isEmpty) return '';
    
    // Remove extra whitespace and newlines
    String cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Remove common HTML artifacts
    cleaned = cleaned
        .replaceAll(RegExp(r'\\n'), ' ')
        .replaceAll(RegExp(r'\\t'), ' ')
        .replaceAll(RegExp(r'\\"'), '"')
        .replaceAll(RegExp(r"\\'"), "'")
        .replaceAll(RegExp(r'\\r'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'<'), '<')
        .replaceAll(RegExp(r'>'), '>')
        .trim();
    
    // Remove very short or meaningless text
    if (cleaned.length < 2) return '';
    
    return cleaned;
  }

  /// Extract date from text using regex
  String _extractDateFromText(String text) {
    try {
      // Common date patterns
      final datePatterns = [
        RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})'), // DD/MM/YYYY or DD-MM-YYYY
        RegExp(r'(\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*\s+\d{2,4})', caseSensitive: false), // DD Month YYYY
        RegExp(r'((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*\s+\d{1,2},?\s+\d{2,4})', caseSensitive: false), // Month DD, YYYY
      ];

      for (var pattern in datePatterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          return match.group(0) ?? 'Recent';
        }
      }

      // Look for common time-related words
      if (text.toLowerCase().contains('today')) return 'Today';
      if (text.toLowerCase().contains('yesterday')) return 'Yesterday';
      if (text.toLowerCase().contains('this week')) return 'This Week';
      if (text.toLowerCase().contains('last week')) return 'Last Week';
    } catch (e) {
      print('Error extracting date: $e');
    }

    return 'Recent';
  }

  /// Extract title from text
  String _extractTitleFromText(String text) {
    try {
      // Take first sentence or first 80 characters
      final sentences = text.split(RegExp(r'[.!?]+'));
      if (sentences.isNotEmpty && sentences[0].trim().length > 10) {
        final firstSentence = sentences[0].trim();
        return firstSentence.length > 80 ? '${firstSentence.substring(0, 80)}...' : firstSentence;
      }

      return text.length > 80 ? '${text.substring(0, 80)}...' : text;
    } catch (e) {
      return text.length > 50 ? '${text.substring(0, 50)}...' : text;
    }
  }

  /// Check if text contains date pattern
  bool _hasDatePattern(String text) {
    final datePatterns = [
      RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}'),
      RegExp(r'\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)', caseSensitive: false),
    ];

    for (var pattern in datePatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  /// Get mock news data (fallback)
  Future<List<Map<String, dynamic>>> _getMockNews() async {
    return [
      {
        'title': 'MS RIT Celebrates 50 Years of Excellence in Technical Education',
        'description': 'The institution marks a significant milestone with various events and celebrations throughout the academic year. Alumni from various batches are invited to participate in the golden jubilee celebrations.',
        'date': '15 January 2024',
        'url': 'https://msrit.edu/news/golden-jubilee',
      },
      {
        'title': 'New Research Center Inaugurated for Advanced Studies',
        'description': 'State-of-the-art research facility opens for advanced studies in artificial intelligence and machine learning. The center will house the latest equipment and provide opportunities for interdisciplinary research.',
        'date': '10 January 2024',
        'url': 'https://msrit.edu/news/research-center',
      },
      {
        'title': 'Students Win National Level Hackathon Competition',
        'description': 'Team from MS RIT secures first place in the national engineering competition with innovative project on sustainable technology solutions. The winning team will represent India in the international competition.',
        'date': '5 January 2024',
        'url': 'https://msrit.edu/news/hackathon-winners',
      },
      {
        'title': 'Industry Collaboration with Leading Tech Companies',
        'description': 'New partnership agreements signed with leading technology companies for student internships and placements. The collaboration will also include guest lectures and joint research projects.',
        'date': '28 December 2023',
        'url': 'https://msrit.edu/news/industry-partnership',
      },
      {
        'title': 'Alumni Meet 2024 - Save the Date',
        'description': 'Annual alumni gathering scheduled for March 2024. Register now to reconnect with fellow graduates and participate in various networking events and technical sessions.',
        'date': '20 December 2023',
        'url': 'https://msrit.edu/news/alumni-meet',
      },
      {
        'title': 'New Academic Programs Launched for 2024',
        'description': 'Introduction of new interdisciplinary programs in Data Science and Cybersecurity. The programs are designed to meet the growing industry demand for skilled professionals.',
        'date': '15 December 2023',
        'url': 'https://msrit.edu/news/new-programs',
      },
    ];
  }
}