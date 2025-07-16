import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/prompt_form_screen.dart';
import '../screens/all_users_screen.dart';
import '../screens/project_ideas_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/public_history_screen.dart';
import '../screens/youtube_videos_screen.dart';
import '../widgets/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _topUsers = [];
  bool _loadingTopUsers = false;

  @override
  void initState() {
    super.initState();
    _fetchTopUsers();
  }

  // Stream for user tokens
  Stream<int> get _userTokensStream {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['tokens'] ?? 0);
  }

  Future<void> _fetchTopUsers() async {
    setState(() {
      _loadingTopUsers = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('projectCount', descending: true)
          .limit(5) // Changed from 10 to 5
          .get();

      setState(() {
        _topUsers = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'displayName': doc.data()['displayName'] ?? 'Anonymous',
            'photoURL': doc.data()['photoURL'],
            'projectCount': doc.data()['projectCount'] ?? 0,
          };
        }).toList();
        _loadingTopUsers = false;
      });
    } catch (e) {
      print('Error fetching top users: $e');
      setState(() {
        _loadingTopUsers = false;
      });
    }
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    double? width,
    bool isFullWidth = false,
    int cardIndex = 0,
    Widget? extraContent,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    // Define unique border radii for each card
    BorderRadius _getUniqueBorderRadius() {
      switch (cardIndex % 5) {
        case 0: // First card
          return const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(40),
          );
        case 1: // Second card
          return const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(40),
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(10),
          );
        case 2: // Third card
          return const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(50),
          );
        case 3: // Fourth card (Other Developers' Projects)
          return const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(50),
          );
        case 4: // Fifth card (Watch & Earn)
          return const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(50),
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(10),
          );
        default:
          return BorderRadius.circular(20);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface.withOpacity(0.9),
              colorScheme.surface.withOpacity(0.7),
            ],
          ),
          borderRadius: _getUniqueBorderRadius(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(icon, color: colorScheme.primary, size: 30),
                  ),
                  Icon(Icons.arrow_forward_ios, color: colorScheme.primary),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (extraContent != null) ...[
                    const SizedBox(height: 12),
                    extraContent,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCreatorsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface.withOpacity(0.9),
            colorScheme.surface.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(50),
          topRight: const Radius.circular(5),
          bottomLeft: const Radius.circular(5),
          bottomRight: const Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'Top Creators',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Discover the most innovative developers',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Top Users Grid
            if (_loadingTopUsers)
              Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  // Split users into two rows
                  final firstRowUsers = _topUsers.take(3).toList();
                  final secondRowUsers = _topUsers.length > 3
                      ? _topUsers.sublist(3)
                      : [];

                  return Column(
                    children: [
                      // First Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: firstRowUsers.map((user) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                CachedCircleAvatar(
                                  radius: 25,
                                  backgroundColor: colorScheme.primaryContainer,
                                  imageUrl: user['photoURL'],
                                  child: Text(
                                    user['displayName'][0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user['displayName'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      // Second Row (if users > 3)
                      if (secondRowUsers.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: secondRowUsers.map((user) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Column(
                                children: [
                                  CachedCircleAvatar(
                                    radius: 25,
                                    backgroundColor:
                                        colorScheme.primaryContainer,
                                    imageUrl: user['photoURL'],
                                    child: Text(
                                      user['displayName'][0].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user['displayName'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Stream for total user count
  Stream<int> get _userCountStream => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.size);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo and App Name
                      Row(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DevAi',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              StreamBuilder<int>(
                                stream: _userCountStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      '${snapshot.data} Developers',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Tokens and Actions
                      Row(
                        children: [
                          // Tokens display
                          StreamBuilder<int>(
                            stream: _userTokensStream,
                            builder: (context, snapshot) {
                              final tokens = snapshot.data ?? 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Lottie.asset(
                                        'assets/lottie/DevAi.json',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$tokens',
                                      style: TextStyle(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Action buttons
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.history),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HistoryScreen(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Full-width Generate Project card
                      _buildFeatureCard(
                        context: context,
                        title: 'Generate Project',
                        description: 'Create your next big idea with AI',
                        icon: Icons.generating_tokens,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PromptFormScreen(),
                          ),
                        ),
                        cardIndex: 0, // First card
                      ),

                      // Two cards in a row
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureCard(
                              context: context,
                              title: 'Project Ideas',
                              description: 'Explore innovative concepts',
                              icon: Icons.lightbulb_outline,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProjectIdeasScreen(),
                                ),
                              ),
                              cardIndex: 1, // Second card
                            ),
                          ),
                          Expanded(
                            child: _buildFeatureCard(
                              context: context,
                              title: 'Community Creators',
                              description: 'Connect with top developers',
                              icon: Icons.people_outline,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllUsersScreen(),
                                ),
                              ),
                              cardIndex: 2, // Third card
                            ),
                          ),
                        ],
                      ),

                      // Top Creators Card
                      _buildTopCreatorsCard(context),

                      // Other Developers' Projects Card
                      _buildFeatureCard(
                        context: context,
                        title: 'Other Developers\' Projects',
                        description:
                            'Browse public project histories and learn',
                        icon: Icons.history_edu,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PublicHistoryScreen(),
                          ),
                        ),
                        cardIndex: 3, // Fourth card
                        extraContent: null,
                      ),

                      // Watch & Earn Card
                      _buildFeatureCard(
                        context: context,
                        title: 'Watch & Earn',
                        description: 'Watch tutorials and earn DevTokens',
                        icon: Icons.play_circle_outline,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const YouTubeVideosScreen(),
                          ),
                        ),
                        cardIndex: 4, // Fifth card
                        extraContent: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.8),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
