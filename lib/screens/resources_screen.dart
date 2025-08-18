import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/rit_notebook_scraper.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  List<Map<String, dynamic>> _resources = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final resources = await RITNotebookScraper.scrapeResources();
      setState(() {
        _resources = resources;
        
        // Extract unique categories
        final uniqueCategories = <String>{'All'};
        for (var resource in resources) {
          uniqueCategories.add(resource['category']);
        }
        _categories = uniqueCategories.toList()..sort();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load resources: ${e.toString()}';
      });
      print('Error loading resources: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshResources() async {
    await _loadResources();
  }

  Future<void> _openResourceUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the resource link')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _filterResources() {
    if (_selectedCategory == 'All') {
      return _resources;
    }
    return _resources.where((resource) => resource['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filteredResources = _filterResources();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Study Resources',
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshResources,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
                  ),
                  SizedBox(height: 16),
                  Text('Loading study resources...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadResources,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Category Filter
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Filter by Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _selectedCategory,
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                    
                    // Resource List
                    Expanded(
                      child: filteredResources.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.library_books_outlined,
                                    size: 80,
                                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No resources available',
                                    style: GoogleFonts.fragmentMono(
                                      fontSize: 18,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Check back later for updates',
                                    style: GoogleFonts.fragmentMono(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.grey[500] : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredResources.length,
                              itemBuilder: (context, index) {
                                final resource = filteredResources[index];
                                return _buildResourceCard(resource);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _openResourceUrl(resource['url']),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      resource['title'],
                      style: GoogleFonts.fragmentMono(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF333333),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      resource['category'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              Text(
                resource['description'],
                style: GoogleFonts.fragmentMono(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 15),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RIT Notebook',
                    style: GoogleFonts.fragmentMono(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _openResourceUrl(resource['url']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'View',
                      style: GoogleFonts.fragmentMono(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}