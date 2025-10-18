import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/prompt_request.dart';
import '../models/prompt_response.dart';
import '../screens/community_prompt_detail_screen.dart';
import '../widgets/cached_network_image.dart';

class PublicHistoryScreen extends StatefulWidget {
  const PublicHistoryScreen({super.key});

  @override
  State<PublicHistoryScreen> createState() => _PublicHistoryScreenState();
}

class _PublicHistoryScreenState extends State<PublicHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Set<String> _unlockedPrompts = {};
  String _currentFilter = 'recent';
  String _searchQuery = '';
  Stream<QuerySnapshot>? _promptsStream;
  Stream<QuerySnapshot>? _unlockedPromptsStream;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  void _setupStreams() {
    Query query = _firestore.collection('community_prompts');

    if (_currentFilter == 'recent') {
      query = query.orderBy('createdAt', descending: true);
    } else if (_currentFilter == 'popular') {
      query = query.orderBy('likes', descending: true);
    }

    query = query.limit(50);

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
    });
  }

  void _changeFilter(String filter) {
    if (_currentFilter != filter) {
      setState(() {
        _currentFilter = filter;
      });
      _setupStreams();
    }
  }

  String _getFullText(PromptResponse response) {
    return '''
${response.summary}

${response.techStackExplanation}

${response.features.map((f) => '- $f').join('\n')}

${response.uiLayout}

${response.folderStructure}
''';
  }

  int _getWordCount(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  int _getLineCount(String text) {
    return text.split('\n').length;
  }

  Map<String, dynamic> _processFirestoreData(Map<String, dynamic> data) {
    Map<String, dynamic> processedData = Map<String, dynamic>.from(data);

    if (processedData['request'] != null) {
      final request = Map<String, dynamic>.from(
        processedData['request'] as Map,
      );
      if (request['timestamp'] != null && request['timestamp'] is! String) {
        try {
          request['timestamp'] = request['timestamp']
              .toDate()
              .toIso8601String();
        } catch (e) {
          request['timestamp'] = DateTime.now().toIso8601String();
        }
      }
      processedData['request'] = request;
    }

    if (processedData['response'] != null) {
      final response = Map<String, dynamic>.from(
        processedData['response'] as Map,
      );
      if (response['timestamp'] != null && response['timestamp'] is! String) {
        try {
          response['timestamp'] = response['timestamp']
              .toDate()
              .toIso8601String();
        } catch (e) {
          response['timestamp'] = DateTime.now().toIso8601String();
        }
      }
      processedData['response'] = response;
    }

    if (processedData['createdAt'] != null &&
        processedData['createdAt'] is! String) {
      try {
        processedData['createdAt'] = processedData['createdAt']
            .toDate()
            .toIso8601String();
        processedData['timestamp'] = processedData['createdAt'];
      } catch (e) {
        processedData['createdAt'] = DateTime.now().toIso8601String();
        processedData['timestamp'] = processedData['createdAt'];
      }
    }

    return processedData;
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        if (diff.inHours == 0) {
          return '${diff.inMinutes}m ago';
        }
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      }
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Projects',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search projects...',
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips
                    Row(
                      children: [
                        FilterChip(
                          label: const Text('Recent'),
                          selected: _currentFilter == 'recent',
                          onSelected: (selected) {
                            if (selected) _changeFilter('recent');
                          },
                          backgroundColor: colorScheme.surface,
                          selectedColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: _currentFilter == 'recent'
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontWeight: _currentFilter == 'recent'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Popular'),
                          selected: _currentFilter == 'popular',
                          onSelected: (selected) {
                            if (selected) _changeFilter('popular');
                          },
                          backgroundColor: colorScheme.surface,
                          selectedColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: _currentFilter == 'popular'
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontWeight: _currentFilter == 'popular'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Projects List
              Expanded(
                child: _promptsStream == null
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: _unlockedPromptsStream,
                        builder: (context, unlockedSnapshot) {
                          if (unlockedSnapshot.hasData) {
                            _unlockedPrompts = unlockedSnapshot.data!.docs
                                .map((doc) => doc['promptId'] as String)
                                .toSet();
                          }

                          return StreamBuilder<QuerySnapshot>(
                            stream: _promptsStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  !snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: colorScheme.primary,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '📚',
                                        style: const TextStyle(fontSize: 64),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No projects yet',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Be the first to create!',
                                        style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final docs = snapshot.data!.docs;
                              final filteredDocs = _searchQuery.isEmpty
                                  ? docs
                                  : docs.where((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final processedData =
                                          _processFirestoreData(data);
                                      final request =
                                          processedData['request']
                                              as Map<String, dynamic>;
                                      final projectName =
                                          request['projectName'] as String? ??
                                          '';
                                      final topic =
                                          request['topic'] as String? ?? '';
                                      return projectName.toLowerCase().contains(
                                            _searchQuery.toLowerCase(),
                                          ) ||
                                          topic.toLowerCase().contains(
                                            _searchQuery.toLowerCase(),
                                          );
                                    }).toList();

                              if (filteredDocs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '🔍',
                                        style: const TextStyle(fontSize: 64),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No results found',
                                        style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: filteredDocs.length,
                                itemBuilder: (context, index) {
                                  final doc = filteredDocs[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final processedData = _processFirestoreData(
                                    data,
                                  );
                                  processedData['id'] = doc.id;

                                  final request = PromptRequest.fromJson(
                                    processedData['request']
                                        as Map<String, dynamic>,
                                  );
                                  final response = PromptResponse.fromJson(
                                    processedData['response']
                                        as Map<String, dynamic>,
                                  );
                                  final timestamp =
                                      processedData['timestamp'] as String? ??
                                      processedData['createdAt'] as String?;
                                  final displayName =
                                      processedData['displayName'] as String;
                                  final photoURL =
                                      processedData['photoURL'] as String?;
                                  final likes =
                                      processedData['likes'] as int? ?? 0;
                                  final views =
                                      processedData['views'] as int? ?? 0;
                                  final isUnlocked = _unlockedPrompts.contains(
                                    doc.id,
                                  );

                                  return _buildProjectCard(
                                    context,
                                    doc.id,
                                    request,
                                    response,
                                    displayName,
                                    photoURL,
                                    timestamp,
                                    likes,
                                    views,
                                    isUnlocked,
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

  Widget _buildProjectCard(
    BuildContext context,
    String docId,
    PromptRequest request,
    PromptResponse response,
    String displayName,
    String? photoURL,
    String? timestamp,
    int likes,
    int views,
    bool isUnlocked,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              _firestore
                  .collection('community_prompts')
                  .doc(docId)
                  .update({'views': FieldValue.increment(1)})
                  .catchError((e) => debugPrint('Error updating views: $e'));

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityPromptDetailScreen(
                    promptId: docId,
                    request: request,
                    response: response,
                    displayName: displayName,
                    photoURL: photoURL,
                    views: views + 1,
                    likes: likes,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Row
                  Row(
                    children: [
                      CachedCircleAvatar(
                        radius: 16,
                        imageUrl: photoURL,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Project Name
                  Text(
                    request.projectName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Description
                  Text(
                    request.topic,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Tags with icons
                  Row(
                    children: [
                      // Platform badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withOpacity(0.8),
                              colorScheme.secondary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              request.platform == 'App'
                                  ? Icons.phone_android_rounded
                                  : Icons.web_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              request.platform,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Tech stack badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: colorScheme.secondary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.code_rounded,
                              size: 12,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              request.techStack,
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$views',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('👁', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Text(
                        '$likes',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('❤️', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Content Stats
                  Row(
                    children: [
                      // Word Count
                      Icon(
                        Icons.text_fields_rounded,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getWordCount(_getFullText(response))} words',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Character Count
                      Icon(
                        Icons.abc_rounded,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getFullText(response).length} chars',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Line Count
                      Icon(
                        Icons.format_list_numbered_rounded,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getLineCount(_getFullText(response))} lines',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Lock/Unlock Badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? colorScheme.primary.withValues(alpha: 0.9)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUnlocked
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                isUnlocked ? 'Unlocked' : 'Locked',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? Colors.white
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
