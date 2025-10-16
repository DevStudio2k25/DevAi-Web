import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class YouTubeVideosScreen extends StatefulWidget {
  const YouTubeVideosScreen({super.key});

  @override
  State<YouTubeVideosScreen> createState() => _YouTubeVideosScreenState();
}

class _YouTubeVideosScreenState extends State<YouTubeVideosScreen> {
  List<Map<String, dynamic>> _videos = [];
  Set<String> _watchedVideos = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchVideos();
    _fetchWatchedVideos();
  }

  Future<void> _fetchWatchedVideos() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('watched_videos')
            .where('userId', isEqualTo: userId)
            .get();

        setState(() {
          _watchedVideos = snapshot.docs
              .map((doc) => doc.data()['videoId'] as String)
              .toSet();
        });
      }
    } catch (e) {
      debugPrint('Error fetching watched videos: $e');
    }
  }

  String _getVideoId(String url) {
    final uri = Uri.parse(url);
    if (uri.host == 'youtu.be') {
      return uri.pathSegments.first;
    }
    return uri.queryParameters['v'] ?? '';
  }

  String _getThumbnailUrl(String videoUrl) {
    final videoId = _getVideoId(videoUrl);
    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
  }

  Future<void> _markVideoAsWatched(String videoId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    if (_watchedVideos.contains(videoId)) return;

    try {
      await FirebaseFirestore.instance.collection('watched_videos').add({
        'userId': userId,
        'videoId': videoId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'tokens': FieldValue.increment(1),
      });

      setState(() {
        _watchedVideos.add(videoId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Earned 1 token!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marking video as watched: $e');
    }
  }

  Future<void> _fetchVideos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('youtube_links')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _videos = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? 'Untitled',
            'url': data['url'] ?? '',
            'timestamp': data['timestamp'] as Timestamp? ?? Timestamp.now(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredVideos() {
    final filtered = _searchQuery.isEmpty
        ? _videos
        : _videos.where((video) {
            return video['title'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();

    final unwatched = filtered.where(
      (v) => !_watchedVideos.contains(_getVideoId(v['url'])),
    );
    final watched = filtered.where(
      (v) => _watchedVideos.contains(_getVideoId(v['url'])),
    );

    return [...unwatched, ...watched];
  }

  Future<void> _launchUrl(String url, String videoId) async {
    try {
      if (await launchUrl(Uri.parse(url))) {
        await _markVideoAsWatched(videoId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch video: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _getTimeAgo(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredVideos = _getFilteredVideos();
    final unwatchedCount = filteredVideos
        .where((v) => !_watchedVideos.contains(_getVideoId(v['url'])))
        .length;

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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Watch & Earn',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$unwatchedCount videos to watch',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Lottie Animation
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Lottie.asset(
                            'assets/lottie/DevAi.json',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
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
                        hintText: 'Search videos...',
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Videos List
              Expanded(
                child: _isLoading
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
                    : filteredVideos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: Lottie.asset(
                                'assets/lottie/DevAi.json',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No videos available'
                                  : 'No results found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredVideos.length,
                        itemBuilder: (context, index) {
                          final video = filteredVideos[index];
                          final videoId = _getVideoId(video['url']);
                          final isWatched = _watchedVideos.contains(videoId);

                          return _buildVideoCard(
                            context,
                            video,
                            videoId,
                            isWatched,
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

  Widget _buildVideoCard(
    BuildContext context,
    Map<String, dynamic> video,
    String videoId,
    bool isWatched,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWatched
              ? colorScheme.outline.withValues(alpha: 0.2)
              : colorScheme.primary.withValues(alpha: 0.3),
          width: isWatched ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: isWatched ? null : () => _launchUrl(video['url'], videoId),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 120,
                      height: 90,
                      child: Image.network(
                        _getThumbnailUrl(video['url']),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colorScheme.primaryContainer,
                            child: Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Lottie.asset(
                                  'assets/lottie/DevAi.json',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isWatched
                            ? Colors.black.withValues(alpha: 0.7)
                            : colorScheme.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isWatched ? 'Watched' : 'New',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Video Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isWatched
                            ? colorScheme.onSurface.withValues(alpha: 0.6)
                            : colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getTimeAgo(video['timestamp']),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Token Badge
                    if (!isWatched)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.2),
                              colorScheme.secondary.withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Earn +1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: Lottie.asset(
                                'assets/lottie/DevAi.json',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isWatched)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '✓ Completed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
