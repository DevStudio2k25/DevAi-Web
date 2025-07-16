import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
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
          _watchedVideos = snapshot.docs.map((doc) => doc.data()['videoId'] as String).toSet();
        });
      }
    } catch (e) {
      print('Error fetching watched videos: $e');
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
    // Using medium quality thumbnail for better loading
    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
  }

  Future<void> _markVideoAsWatched(String videoId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Check if already watched
    if (_watchedVideos.contains(videoId)) return;

    try {
      // Add to watched_videos collection
      await FirebaseFirestore.instance.collection('watched_videos').add({
        'userId': userId,
        'videoId': videoId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Increment user tokens
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'tokens': FieldValue.increment(1),
      });

      setState(() {
        _watchedVideos.add(videoId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Earned 1 token for watching the video!'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      print('Error marking video as watched: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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
      print('Error fetching videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getSortedVideos() {
    final unwatchedVideos = _videos.where(
      (video) => !_watchedVideos.contains(_getVideoId(video['url']))
    ).toList();

    final watchedVideos = _videos.where(
      (video) => _watchedVideos.contains(_getVideoId(video['url']))
    ).toList();

    // Sort each list by timestamp
    unwatchedVideos.sort((a, b) => (b['timestamp'] as Timestamp)
        .compareTo(a['timestamp'] as Timestamp));
    watchedVideos.sort((a, b) => (b['timestamp'] as Timestamp)
        .compareTo(a['timestamp'] as Timestamp));

    // Combine lists with unwatched first
    return [...unwatchedVideos, ...watchedVideos];
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

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('d MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Lottie.asset(
                'assets/lottie/DevAi.json',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Watch & Earn',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
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
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary,
                ),
              )
            : _videos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library_outlined,
                          size: 64,
                          color: colorScheme.onPrimary.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No videos available',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 80, 16, 16),
                    itemCount: _videos.length,
                    itemBuilder: (context, index) {
                      final sortedVideos = _getSortedVideos();
                      final video = sortedVideos[index];
                      final videoId = _getVideoId(video['url']);
                      final isWatched = _watchedVideos.contains(videoId);

                      // Add section header for first watched video
                      final isFirstWatchedVideo = isWatched && 
                          (index == 0 || !_watchedVideos.contains(_getVideoId(sortedVideos[index - 1]['url'])));

                      // Define unique border radii for each card based on index
                      BorderRadius _getUniqueBorderRadius() {
                        switch (index % 4) {
                          case 0:
                            return const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(30),
                            );
                          case 1:
                            return const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(8),
                            );
                          case 2:
                            return const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            );
                          case 3:
                            return const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            );
                          default:
                            return BorderRadius.circular(16);
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isFirstWatchedVideo) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 24, bottom: 16, left: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 20,
                                    color: colorScheme.onPrimary.withOpacity(0.9),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Watched Videos',
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withOpacity(0.8),
                              borderRadius: _getUniqueBorderRadius(),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: _getUniqueBorderRadius(),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Thumbnail
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(
                                          width: 120,
                                          height: 90,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                _getThumbnailUrl(video['url']),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: colorScheme.primaryContainer,
                                                    child: Icon(
                                                      Icons.play_circle_outline,
                                                      size: 32,
                                                      color: colorScheme.primary,
                                                    ),
                                                  );
                                                },
                                              ),
                                              // Play overlay
                                              if (!isWatched)
                                                Container(
                                                  color: Colors.black26,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.play_circle_outline,
                                                      size: 32,
                                                      color: Colors.white.withOpacity(0.9),
                                                    ),
                                                  ),
                                                ),
                                              // Watched overlay
                                              if (isWatched)
                                                Container(
                                                  color: Colors.black45,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.check_circle_outline,
                                                      size: 32,
                                                      color: Colors.white.withOpacity(0.9),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Video Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              video['title'],
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: colorScheme.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(video['timestamp']),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Bottom row with token and watch button
                                            Row(
                                              children: [
                                                // Token indicator
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primaryContainer.withOpacity(0.8),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        '+1',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
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
                                                const SizedBox(width: 8),
                                                // Watch Button
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 32,
                                                    child: ElevatedButton.icon(
                                                      onPressed: isWatched ? null : () => _launchUrl(video['url'], videoId),
                                                      icon: Icon(
                                                        isWatched ? Icons.check : Icons.play_arrow,
                                                        size: 16,
                                                      ),
                                                      label: Text(
                                                        isWatched ? 'Watched' : 'Watch Now',
                                                        style: const TextStyle(fontSize: 12),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: isWatched ? colorScheme.surfaceVariant : colorScheme.primary,
                                                        foregroundColor: isWatched ? colorScheme.onSurfaceVariant : colorScheme.onPrimary,
                                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
} 