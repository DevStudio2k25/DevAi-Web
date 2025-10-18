import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' show pi;

import 'prompt_form/prompt_form_screen.dart';
import 'about_screen.dart';
import '../widgets/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _topUsers = [];
  bool _loadingTopUsers = false;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _fetchTopUsers();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // Continuous one-direction rotation
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Stream<int> get _userTokensStream {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['tokens'] ?? 0);
  }

  Stream<int> get _userCountStream => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.size);

  Future<void> _fetchTopUsers() async {
    setState(() {
      _loadingTopUsers = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('projectCount', descending: true)
          .limit(6)
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
      debugPrint('Error fetching top users: $e');
      setState(() {
        _loadingTopUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    // Log comprehensive dimensions for preview widget ratio calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final padding = MediaQuery.of(context).padding;

      debugPrint('\n╔═══════════════════════════════════════════════════════╗');
      debugPrint('║     HOME SCREEN - COMPREHENSIVE DIMENSIONS LOG       ║');
      debugPrint('╚═══════════════════════════════════════════════════════╝');
      debugPrint('');
      debugPrint('📱 SCREEN DIMENSIONS:');
      debugPrint('   • Screen Width: ${size.width}');
      debugPrint('   • Screen Height: ${size.height}');
      debugPrint('   • Safe Area Top: ${padding.top}');
      debugPrint('   • Safe Area Bottom: ${padding.bottom}');
      debugPrint(
        '   • Available Height: ${size.height - padding.top - padding.bottom}',
      );
      debugPrint('');
      debugPrint('📐 LAYOUT CONSTANTS:');
      debugPrint('   • Horizontal Padding: 20px (both sides = 40px total)');
      debugPrint('   • Available Content Width: ${size.width - 40}');
      debugPrint('');
      debugPrint('🎯 HEADER SECTION:');
      debugPrint('   • Avatar Radius: 24px (48px diameter)');
      debugPrint('   • Avatar-Text Gap: 12px');
      debugPrint('   • Token Badge Height: ~36px');
      debugPrint(
        '   • Total Header Height: ~88px (20px padding + 48px content + 20px padding)',
      );
      debugPrint('');
      debugPrint('✨ HERO CARD (Generate Project):');
      debugPrint('   • Border Width: 3px (gradient border)');
      debugPrint('   • Inner Padding: 24px');
      debugPrint('   • Icon Size: 32px');
      debugPrint('   • Title Font: 24px');
      debugPrint('   • Border Radius: 28px');
      debugPrint('   • Estimated Height: ~180px');
      debugPrint('');
      debugPrint('👥 COMMUNITY CARD:');
      debugPrint('   • Padding: 24px');
      debugPrint('   • Icon Size: 40px');
      debugPrint('   • Border Width: 2px');
      debugPrint('   • Border Radius: 24px');
      debugPrint('   • Estimated Height: ~120px');
      debugPrint('');
      debugPrint('🏆 TOP CREATORS GRID:');
      debugPrint('   • Grid Columns: 3');
      debugPrint('   • Cross Axis Spacing: 10px');
      debugPrint('   • Main Axis Spacing: 10px');
      debugPrint('   • Child Aspect Ratio: 0.75 (W/H)');
      final cardWidth = (size.width - 40 - 20) / 3; // 40 padding, 20 spacing
      final cardHeight = cardWidth / 0.75;
      debugPrint('   • Card Width: ${cardWidth.toStringAsFixed(2)}px');
      debugPrint('   • Card Height: ${cardHeight.toStringAsFixed(2)}px');
      debugPrint('   • Grid Rows: 2');
      debugPrint(
        '   • Total Grid Height: ${(cardHeight * 2 + 10).toStringAsFixed(2)}px',
      );
      debugPrint('');
      debugPrint('📊 SPACING BETWEEN SECTIONS:');
      debugPrint('   • Header → Hero Card: 8px');
      debugPrint('   • Hero Card → Community: 24px');
      debugPrint('   • Community → Title: 24px');
      debugPrint('   • Title → Grid: 16px');
      debugPrint('   • Grid → Bottom: 100px (navbar space)');
      debugPrint('');
      debugPrint('🎨 ESTIMATED TOTAL CONTENT HEIGHT:');
      final estimatedHeight =
          88 + 8 + 180 + 24 + 120 + 24 + 16 + (cardHeight * 2 + 10) + 100;
      debugPrint('   • Total: ${estimatedHeight.toStringAsFixed(2)}px');
      debugPrint('');
      debugPrint('📏 RECOMMENDED PREVIEW RATIO:');
      final contentWidth = size.width - 40;
      final aspectRatio = contentWidth / estimatedHeight;
      debugPrint('   • Content Width: ${contentWidth.toStringAsFixed(2)}px');
      debugPrint(
        '   • Content Height: ${estimatedHeight.toStringAsFixed(2)}px',
      );
      debugPrint('   • Aspect Ratio (W/H): ${aspectRatio.toStringAsFixed(4)}');
      debugPrint(
        '   • Aspect Ratio (H/W): ${(1 / aspectRatio).toStringAsFixed(4)}',
      );
      debugPrint('');
      debugPrint('💡 FOR PREVIEW WIDGET:');
      debugPrint(
        '   • Use Container with AspectRatio: ${aspectRatio.toStringAsFixed(4)}',
      );
      debugPrint(
        '   • Or Height = Width * ${(1 / aspectRatio).toStringAsFixed(4)}',
      );
      debugPrint('');
      debugPrint('╚═══════════════════════════════════════════════════════╝\n');
    });

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
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User Info
                      Row(
                        children: [
                          _buildHeaderAvatar(context, user, colorScheme),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${user?.displayName?.split(' ').first ?? 'User'}!',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              StreamBuilder<DocumentSnapshot>(
                                stream: user != null
                                    ? FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .snapshots()
                                    : null,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    final projectCount =
                                        snapshot.data?.get('projectCount') ?? 0;
                                    return Row(
                                      children: [
                                        Icon(
                                          Icons.folder_outlined,
                                          size: 14,
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$projectCount Projects',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme.onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Tokens & Info
                      Row(
                        children: [
                          StreamBuilder<int>(
                            stream: _userTokensStream,
                            builder: (context, snapshot) {
                              final tokens = snapshot.data ?? 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                      colorScheme.secondary.withValues(
                                        alpha: 0.2,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Lottie.asset(
                                        'assets/lottie/DevAi.json',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$tokens',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                            ),
                            tooltip: 'About DevAi',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Main Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // Hero Card - Generate Project
                    _buildHeroCard(context),

                    const SizedBox(height: 24),

                    // Community Card
                    _buildCommunityCard(context),

                    const SizedBox(height: 24),

                    // Top Creators Section
                    Text(
                      'Top Creators 🏆',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTopCreatorsGrid(context),

                    const SizedBox(height: 100), // Bottom padding for navbar
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PromptFormScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: SweepGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.8),
                  const Color(0xFF00BCD4).withValues(alpha: 0.8), // Light Cyan
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
                transform: GradientRotation(_glowController.value * 2 * pi),
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                // Primary glow
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
                // Cyan glow
                BoxShadow(
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: _buildCardContent(context, colorScheme),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.2),
                      colorScheme.secondary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: colorScheme.primary,
                  size: 32,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.2),
                      colorScheme.secondary.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward, color: colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
            ).createShader(bounds),
            child: const Text(
              'Generate Project',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your next big idea with AI assistance',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.secondaryContainer.withValues(alpha: 0.6),
            colorScheme.tertiaryContainer.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.secondary.withValues(alpha: 0.3),
                  colorScheme.tertiary.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.people, color: colorScheme.secondary, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                StreamBuilder<int>(
                  stream: _userCountStream,
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.data ?? 0} Developers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'Join our growing community',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCreatorsGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loadingTopUsers) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _topUsers.length,
      itemBuilder: (context, index) {
        final user = _topUsers[index];
        final rankData = _getRankData(index);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: rankData['colors'] as List<Color>,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (rankData['borderColor'] as Color).withValues(
                      alpha: 0.6,
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (rankData['borderColor'] as Color).withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Main Content
                    Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // User Avatar with Animated Ring
                                _buildAnimatedAvatar(
                                  context,
                                  user: user,
                                  rank: index + 1,
                                  rankColor: rankData['borderColor'] as Color,
                                ),
                                const SizedBox(height: 10),
                                // User Name
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    user['displayName'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Divider
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.5),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                        // Project Count
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Projects: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${user['projectCount']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Rank Tag (Top Right Corner)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: rankData['borderColor'] as Color,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(14),
                            bottomLeft: Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (rankData['borderColor'] as Color)
                                  .withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderAvatar(
    BuildContext context,
    User? user,
    ColorScheme colorScheme,
  ) {
    if (user == null) {
      return CachedCircleAvatar(
        radius: 24,
        imageUrl: null,
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(Icons.person, color: colorScheme.primary),
      );
    }

    // Check if current user is in top 3
    final userRank = _topUsers.indexWhere((u) => u['id'] == user.uid);
    final isInTop3 = userRank >= 0 && userRank < 3;

    if (isInTop3) {
      return _buildRankRing(
        context,
        rank: userRank + 1,
        photoURL: user.photoURL,
        colorScheme: colorScheme,
      );
    }

    // Regular avatar without animation
    return CachedCircleAvatar(
      radius: 24,
      imageUrl: user.photoURL,
      backgroundColor: colorScheme.primaryContainer,
      child: Icon(Icons.person, color: colorScheme.primary),
    );
  }

  Widget _buildRankRing(
    BuildContext context, {
    required int rank,
    required String? photoURL,
    required ColorScheme colorScheme,
  }) {
    // Define colors and stops based on rank
    List<Color> colors;
    List<double> stops;

    switch (rank) {
      case 1: // #1 - Rainbow (7 colors)
        colors = [
          const Color(0xFFFF0000), // Red
          const Color(0xFFFF7F00), // Orange
          const Color(0xFFFFFF00), // Yellow
          const Color(0xFF00FF00), // Green
          const Color(0xFF0000FF), // Blue
          const Color(0xFF4B0082), // Indigo
          const Color(0xFF9400D3), // Violet
          const Color(0xFFFF0000), // Red (loop)
        ];
        stops = [0.0, 0.14, 0.28, 0.42, 0.56, 0.70, 0.84, 1.0];
        break;

      case 2: // #2 - Purple/Magenta (4 colors) - Contrasts with gold card
        colors = [
          const Color(0xFFE91E63), // Pink
          const Color(0xFF9C27B0), // Purple
          const Color(0xFFBA68C8), // Light Purple
          const Color(0xFFAB47BC), // Medium Purple
          const Color(0xFFE91E63), // Pink (loop)
        ];
        stops = [0.0, 0.25, 0.5, 0.75, 1.0];
        break;

      case 3: // #3 - Teal/Cyan (2 colors) - Contrasts with silver card
        colors = [
          const Color(0xFF00BCD4), // Cyan
          const Color(0xFF00ACC1), // Dark Cyan
          const Color(0xFF00BCD4), // Cyan (loop)
        ];
        stops = [0.0, 0.5, 1.0];
        break;

      default:
        colors = [colorScheme.primary];
        stops = [1.0];
    }

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // Outer glow
              BoxShadow(
                color: colors[0].withValues(alpha: 0.6),
                blurRadius: 15,
                spreadRadius: 2,
              ),
              // Inner glow
              BoxShadow(
                color: colors[colors.length ~/ 2].withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: colors,
                stops: stops,
                transform: GradientRotation(_glowController.value * 2 * pi),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CachedCircleAvatar(
                    radius: 22,
                    imageUrl: photoURL,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.person, color: colorScheme.primary),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedAvatar(
    BuildContext context, {
    required Map<String, dynamic> user,
    required int rank,
    required Color rankColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    // Show animated ring for top 3 (all users, not just current)
    if (rank <= 3) {
      // Get multi-color gradient based on rank
      List<Color> colors;
      List<double> stops;

      switch (rank) {
        case 1: // #1 - Rainbow (7 colors)
          colors = [
            const Color(0xFFFF0000), // Red
            const Color(0xFFFF7F00), // Orange
            const Color(0xFFFFFF00), // Yellow
            const Color(0xFF00FF00), // Green
            const Color(0xFF0000FF), // Blue
            const Color(0xFF4B0082), // Indigo
            const Color(0xFF9400D3), // Violet
            const Color(0xFFFF0000), // Red (loop)
          ];
          stops = [0.0, 0.14, 0.28, 0.42, 0.56, 0.70, 0.84, 1.0];
          break;

        case 2: // #2 - Purple/Magenta (4 colors) - Contrasts with gold card
          colors = [
            const Color(0xFFE91E63), // Pink
            const Color(0xFF9C27B0), // Purple
            const Color(0xFFBA68C8), // Light Purple
            const Color(0xFFAB47BC), // Medium Purple
            const Color(0xFFE91E63), // Pink (loop)
          ];
          stops = [0.0, 0.25, 0.5, 0.75, 1.0];
          break;

        case 3: // #3 - Teal/Cyan (2 colors) - Contrasts with silver card
          colors = [
            const Color(0xFF00BCD4), // Cyan
            const Color(0xFF00ACC1), // Dark Cyan
            const Color(0xFF00BCD4), // Cyan (loop)
          ];
          stops = [0.0, 0.5, 1.0];
          break;

        default:
          colors = [rankColor];
          stops = [1.0];
      }

      return AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
                // Inner glow
                BoxShadow(
                  color: colors[colors.length ~/ 2].withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: colors,
                  stops: stops,
                  transform: GradientRotation(_glowController.value * 2 * pi),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: CachedCircleAvatar(
                      radius: 28,
                      imageUrl: user['photoURL'],
                      backgroundColor: colorScheme.surface.withValues(
                        alpha: 0.3,
                      ),
                      child: Text(
                        user['displayName'][0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // Regular avatar without animation
    return CachedCircleAvatar(
      radius: 30,
      imageUrl: user['photoURL'],
      backgroundColor: colorScheme.surface.withValues(alpha: 0.3),
      child: Text(
        user['displayName'][0].toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Map<String, dynamic> _getRankData(int rank) {
    switch (rank) {
      case 0: // Diamond
        return {
          'colors': [const Color(0xFFB9F2FF), const Color(0xFF00D4FF)],
          'borderColor': const Color(0xFF00B8D4),
        };
      case 1: // Gold
        return {
          'colors': [const Color(0xFFFFD700), const Color(0xFFFFAA00)],
          'borderColor': const Color(0xFFFF8F00),
        };
      case 2: // Silver
        return {
          'colors': [const Color(0xFFE8E8E8), const Color(0xFFC0C0C0)],
          'borderColor': const Color(0xFF9E9E9E),
        };
      case 3: // Bronze
        return {
          'colors': [const Color(0xFFE5A87C), const Color(0xFFCD7F32)],
          'borderColor': const Color(0xFFBF360C),
        };
      case 4: // Emerald
        return {
          'colors': [const Color(0xFF50C878), const Color(0xFF2E8B57)],
          'borderColor': const Color(0xFF1B5E20),
        };
      default: // Ruby
        return {
          'colors': [
            const Color.fromARGB(255, 223, 63, 124),
            const Color.fromARGB(255, 207, 56, 71),
          ],
          'borderColor': const Color(0xFFB71C1C),
        };
    }
  }
}
