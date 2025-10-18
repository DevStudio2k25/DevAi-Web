import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Exact recreation of HomeScreen for preview
/// Matches home_screen.dart UI exactly with real user data
/// Uses calculated aspect ratio to maintain proper proportions
class HomePreviewWidget extends StatelessWidget {
  final double scale;
  final bool isInteractive;

  const HomePreviewWidget({
    super.key,
    this.scale = 1.0,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    // Use exact aspect ratio from home screen logs
    // Based on actual measurements:
    // Screen: 436.36 x 972.93
    // Content Width: 396.36px (screen width - 40px padding)
    // Content Height: 904.55px (all sections + spacing)
    // Aspect Ratio (W/H): 0.4382
    // This ensures preview maintains exact same proportions as home screen
    const aspectRatio = 0.4382;

    Widget content = AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary.withOpacity(0.1), colorScheme.surface],
          ),
        ),
        child: Column(
          children: [
            // Header (exact from home_screen.dart)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User Info (Real Data)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        backgroundColor: colorScheme.primaryContainer,
                        child: user?.photoURL == null
                            ? Icon(Icons.person, color: colorScheme.primary)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.displayName?.split(' ').first ?? 'User'}!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          StreamBuilder<DocumentSnapshot>(
                            stream: user != null
                                ? FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .snapshots()
                                : null,
                            builder: (context, snapshot) {
                              final projectCount = snapshot.hasData
                                  ? (snapshot.data?.get('projectCount') ?? 0)
                                  : 0;
                              return Row(
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    size: 14,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$projectCount Projects',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Tokens & Info (Real Data)
                  Row(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: user != null
                            ? FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .snapshots()
                            : null,
                        builder: (context, snapshot) {
                          final tokens = snapshot.hasData
                              ? (snapshot.data?.get('tokens') ?? 0)
                              : 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withOpacity(0.2),
                                  colorScheme.secondary.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.3),
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
                      Icon(Icons.info_outline, color: colorScheme.primary),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: isInteractive
                    ? null
                    : const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Hero Card - Generate Project (exact from home_screen.dart)
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.8),
                            const Color(0xFF00BCD4).withOpacity(0.8),
                            colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.surface,
                              colorScheme.surface.withOpacity(0.95),
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
                                        colorScheme.primary.withOpacity(0.2),
                                        colorScheme.secondary.withOpacity(0.2),
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
                                        colorScheme.primary.withOpacity(0.2),
                                        colorScheme.secondary.withOpacity(0.2),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
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
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Community Card (exact from home_screen.dart)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.secondaryContainer.withOpacity(0.6),
                            colorScheme.tertiaryContainer.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colorScheme.secondary.withOpacity(0.3),
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
                                  colorScheme.secondary.withOpacity(0.3),
                                  colorScheme.tertiary.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.people,
                              color: colorScheme.secondary,
                              size: 40,
                            ),
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
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    final userCount = snapshot.hasData
                                        ? snapshot.data!.size
                                        : 0;
                                    return Text(
                                      '$userCount Developers',
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
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Top Creators Title
                    Text(
                      'Top Creators 🏆',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Top Creators Grid (Real Data - 6 creators in 3x2 grid)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .orderBy('projectCount', descending: true)
                          .limit(6)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return _buildCreatorCard(
                                colorScheme,
                                index + 1,
                                null,
                              );
                            },
                          );
                        }

                        final creators = snapshot.data!.docs;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: creators.length,
                          itemBuilder: (context, index) {
                            return _buildCreatorCard(
                              colorScheme,
                              index + 1,
                              creators[index].data() as Map<String, dynamic>,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Apply scale if needed
    if (scale != 1.0) {
      content = Transform.scale(
        scale: scale,
        alignment: Alignment.topLeft,
        child: content,
      );
    }

    // Disable interaction if needed
    if (!isInteractive) {
      content = IgnorePointer(child: content);
    }

    return content;
  }

  Widget _buildCreatorCard(
    ColorScheme colorScheme,
    int rank,
    Map<String, dynamic>? userData,
  ) {
    // Match exact colors from home_screen.dart
    final rankData = _getRankData(rank, colorScheme);
    final colors = rankData['colors'] as List<Color>;
    final borderColor = rankData['borderColor'] as Color;

    final displayName = userData?['displayName'] ?? 'User $rank';
    final projectCount = userData?['projectCount'] ?? 0;
    final photoURL = userData?['photoURL'];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.3),
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
                      // User Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: photoURL != null
                            ? NetworkImage(photoURL)
                            : null,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        child: photoURL == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 28,
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      // User Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          displayName,
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
                      '$projectCount',
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '#$rank',
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
    );
  }

  Map<String, dynamic> _getRankData(int rank, ColorScheme colorScheme) {
    switch (rank) {
      case 1: // Gold
        return {
          'colors': [
            const Color(0xFFFFD700).withValues(alpha: 0.9),
            const Color(0xFFFFA500).withValues(alpha: 0.8),
          ],
          'borderColor': const Color(0xFFFFD700),
        };
      case 2: // Silver
        return {
          'colors': [
            const Color(0xFFC0C0C0).withValues(alpha: 0.9),
            const Color(0xFF808080).withValues(alpha: 0.8),
          ],
          'borderColor': const Color(0xFFC0C0C0),
        };
      case 3: // Bronze
        return {
          'colors': [
            const Color(0xFFCD7F32).withValues(alpha: 0.9),
            const Color(0xFF8B4513).withValues(alpha: 0.8),
          ],
          'borderColor': const Color(0xFFCD7F32),
        };
      case 4: // Blue
        return {
          'colors': [
            colorScheme.primary.withValues(alpha: 0.8),
            colorScheme.primary.withValues(alpha: 0.6),
          ],
          'borderColor': colorScheme.primary,
        };
      case 5: // Purple
        return {
          'colors': [
            const Color(0xFF9C27B0).withValues(alpha: 0.8),
            const Color(0xFF7B1FA2).withValues(alpha: 0.6),
          ],
          'borderColor': const Color(0xFF9C27B0),
        };
      case 6: // Teal
        return {
          'colors': [
            const Color(0xFF009688).withValues(alpha: 0.8),
            const Color(0xFF00796B).withValues(alpha: 0.6),
          ],
          'borderColor': const Color(0xFF009688),
        };
      default:
        return {
          'colors': [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
            colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
          ],
          'borderColor': colorScheme.outline,
        };
    }
  }
}
