import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../models/prompt_request.dart';
import '../models/prompt_response.dart';
import '../screens/chat_result_screen.dart';
import '../screens/community_prompt_detail_screen.dart';

class PublicHistoryScreen extends StatefulWidget {
  const PublicHistoryScreen({super.key});

  @override
  State<PublicHistoryScreen> createState() => _PublicHistoryScreenState();
}

class _PublicHistoryScreenState extends State<PublicHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _publicHistory = [];
  Set<String> _unlockedPrompts = {};
  bool _isLoading = true;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  
  // Filter options
  String _currentFilter = 'recent'; // 'recent', 'popular'
  Stream<QuerySnapshot>? _promptsStream;
  Stream<QuerySnapshot>? _unlockedPromptsStream;

  @override
  void initState() {
    super.initState();
    _setupStreams();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _setupStreams() {
    Query query = _firestore.collection('community_prompts');
    
    // Apply sorting based on filter
    if (_currentFilter == 'recent') {
      query = query.orderBy('createdAt', descending: true);
    } else if (_currentFilter == 'popular') {
      query = query.orderBy('likes', descending: true);
    }
    
    query = query.limit(_pageSize);
    
    // Set up stream for unlocked prompts
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _unlockedPromptsStream = _firestore
          .collection('user_unlocked')
          .doc(userId)
          .collection('unlocked_prompts')
          .snapshots();
    }
    
    setState(() {
      _promptsStream = query.snapshots();
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        _loadMoreHistory();
      }
    }
  }
  
  void _changeFilter(String filter) {
    if (_currentFilter != filter) {
      setState(() {
        _currentFilter = filter;
        _publicHistory = [];
        _lastDocument = null;
        _isLoading = true;
        _hasMore = true;
      });
      _setupStreams();
    }
  }

  Future<void> _loadMoreHistory() async {
    if (!_hasMore || _isLoading || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Get more community prompts with pagination
      Query query = _firestore
          .collection('community_prompts');
          
      // Apply sorting based on filter
      if (_currentFilter == 'recent') {
        query = query.orderBy('createdAt', descending: true);
      } else if (_currentFilter == 'popular') {
        query = query.orderBy('likes', descending: true);
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      
      query = query.limit(_pageSize);

      final querySnapshot = await query.get();

      List<Map<String, dynamic>> moreHistory = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Process Firestore timestamps to ISO strings
        Map<String, dynamic> processedData = _processFirestoreData(data);
        
        // Add document ID
        processedData['id'] = doc.id;
        
        moreHistory.add(processedData);
      }

      // Update last document for pagination
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }

      setState(() {
        _publicHistory.addAll(moreHistory);
        _isLoadingMore = false;
        _hasMore = moreHistory.length >= _pageSize;
      });
    } catch (e) {
      print('Error loading more public history: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }
  
  // Helper method to process Firestore data and convert Timestamp objects
  Map<String, dynamic> _processFirestoreData(Map<String, dynamic> data) {
    Map<String, dynamic> processedData = Map<String, dynamic>.from(data);
    
    // Process request object
    if (processedData['request'] != null) {
      final request = Map<String, dynamic>.from(processedData['request'] as Map);
      if (request['timestamp'] != null && request['timestamp'] is! String) {
        try {
          request['timestamp'] = request['timestamp'].toDate().toIso8601String();
        } catch (e) {
          request['timestamp'] = DateTime.now().toIso8601String();
        }
      }
      processedData['request'] = request;
    }
    
    // Process response object
    if (processedData['response'] != null) {
      final response = Map<String, dynamic>.from(processedData['response'] as Map);
      if (response['timestamp'] != null && response['timestamp'] is! String) {
        try {
          response['timestamp'] = response['timestamp'].toDate().toIso8601String();
        } catch (e) {
          response['timestamp'] = DateTime.now().toIso8601String();
        }
      }
      processedData['response'] = response;
    }
    
    // Process main timestamp
    if (processedData['timestamp'] != null && processedData['timestamp'] is! String) {
      try {
        processedData['timestamp'] = processedData['timestamp'].toDate().toIso8601String();
      } catch (e) {
        processedData['timestamp'] = DateTime.now().toIso8601String();
      }
    }
    
    // Process createdAt timestamp
    if (processedData['createdAt'] != null && processedData['createdAt'] is! String) {
      try {
        processedData['createdAt'] = processedData['createdAt'].toDate().toIso8601String();
        // Also set timestamp for compatibility with existing code
        processedData['timestamp'] = processedData['createdAt'];
      } catch (e) {
        processedData['createdAt'] = DateTime.now().toIso8601String();
        processedData['timestamp'] = processedData['createdAt'];
      }
    }
    
    return processedData;
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'Unknown date';
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('MMM d, yyyy • h:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Community Projects'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Filter menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter prompts',
            onSelected: _changeFilter,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: _currentFilter == 'recent' ? colorScheme.primary : null,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Most Recent',
                      style: TextStyle(
                        color: _currentFilter == 'recent' ? colorScheme.primary : null,
                        fontWeight: _currentFilter == 'recent' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'popular',
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: _currentFilter == 'popular' ? colorScheme.primary : null,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Most Popular',
                      style: TextStyle(
                        color: _currentFilter == 'popular' ? colorScheme.primary : null,
                        fontWeight: _currentFilter == 'popular' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.8),
              colorScheme.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Filter indicator
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _currentFilter == 'recent' ? Icons.access_time : Icons.favorite,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentFilter == 'recent' ? 'Most Recent' : 'Most Popular',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // List of prompts
              Expanded(
                child: _promptsStream == null
                  ? Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Lottie.asset(
                          'assets/lottie/DevAi.json',
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: _unlockedPromptsStream,
                      builder: (context, unlockedSnapshot) {
                        // Update unlocked prompts set
                        if (unlockedSnapshot.hasData) {
                          _unlockedPrompts = unlockedSnapshot.data!.docs
                              .map((doc) => doc['promptId'] as String)
                              .toSet();
                        }
                        
                        return StreamBuilder<QuerySnapshot>(
                          stream: _promptsStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Lottie.asset(
                                    'assets/lottie/DevAi.json',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                            
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Container(
                                  margin: const EdgeInsets.all(24),
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.public,
                                            size: 64,
                                            color: colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No Projects Yet',
                                            style: Theme.of(context).textTheme.titleLarge
                                                ?.copyWith(color: colorScheme.onSurface),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Be the first to create a project!',
                                            style: Theme.of(context).textTheme.bodyLarge
                                                ?.copyWith(
                                                  color: colorScheme.onSurface.withOpacity(
                                                    0.7,
                                                  ),
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            // Process the documents
                            final docs = snapshot.data!.docs;
                            
                            // Update last document for pagination
                            if (docs.isNotEmpty) {
                              _lastDocument = docs.last;
                            }
                            
                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: docs.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == docs.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Lottie.asset(
                                          'assets/lottie/DevAi.json',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final doc = docs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final processedData = _processFirestoreData(data);
                                processedData['id'] = doc.id;
                                
                                final request = PromptRequest.fromJson(
                                  processedData['request'] as Map<String, dynamic>,
                                );
                                final response = PromptResponse.fromJson(
                                  processedData['response'] as Map<String, dynamic>,
                                );
                                final timestamp = processedData['timestamp'] as String? ?? processedData['createdAt'] as String?;
                                final displayName = processedData['displayName'] as String;
                                final photoURL = processedData['photoURL'] as String?;
                                final likes = processedData['likes'] as int? ?? 0;
                                final views = processedData['views'] as int? ?? 0;
                                
                                // Check if this prompt is unlocked
                                final isUnlocked = _unlockedPrompts.contains(doc.id);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: InkWell(
                                    onTap: () {
                                      // Increment view count when opening the project
                                      _firestore
                                          .collection('community_prompts')
                                          .doc(doc.id)
                                          .update({
                                        'views': FieldValue.increment(1),
                                      }).catchError((e) => print('Error updating views: $e'));

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CommunityPromptDetailScreen(
                                            promptId: doc.id,
                                            request: request,
                                            response: response,
                                            displayName: displayName,
                                            photoURL: photoURL,
                                            views: views + 1, // Increment locally for immediate feedback
                                            likes: likes,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // User info row
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 16,
                                                          backgroundImage: photoURL != null
                                                              ? NetworkImage(photoURL)
                                                              : null,
                                                          child: photoURL == null
                                                              ? Text(
                                                                  displayName[0].toUpperCase(),
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                )
                                                              : null,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          displayName,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: colorScheme.onSurface,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          _formatDate(timestamp),
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                color: colorScheme.onSurface
                                                                    .withOpacity(0.6),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    // Project info
                                                    Text(
                                                      request.projectName,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            color: colorScheme.primary,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      request.topic,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: colorScheme.onSurface
                                                                .withOpacity(0.8),
                                                          ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        _buildChip(
                                                          context,
                                                          request.platform,
                                                          Icons.devices,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        _buildChip(
                                                          context,
                                                          request.techStack,
                                                          Icons.code,
                                                        ),
                                                        const Spacer(),
                                                        // Engagement metrics
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.remove_red_eye,
                                                              size: 14,
                                                              color: colorScheme.onSurface.withOpacity(0.6),
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '$views',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: colorScheme.onSurface.withOpacity(0.6),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 12),
                                                            Icon(
                                                              Icons.favorite,
                                                              size: 14,
                                                              color: colorScheme.onSurface.withOpacity(0.6),
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '$likes',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: colorScheme.onSurface.withOpacity(0.6),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Unlocked indicator
                                              if (isUnlocked)
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withOpacity(0.8),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.lock_open,
                                                          size: 14,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        const Text(
                                                          'Unlocked',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
