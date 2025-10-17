import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/cached_network_image.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  int? _expandedIndex;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _fetchAllUsers();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllUsers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('projectCount', descending: true)
          .get();

      setState(() {
        _allUsers = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'displayName': doc.data()['displayName'] ?? 'Anonymous',
            'photoURL': doc.data()['photoURL'],
            'projectCount': doc.data()['projectCount'] ?? 0,
            'email': doc.data()['email'] ?? '',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching users: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _allUsers;
    return _allUsers.where((user) {
      return user['displayName'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return const Color(0xFF00D4FF);
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
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
                      'Community',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_filteredUsers.length} developers',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
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
                        hintText: 'Search developers...',
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
              // Users List
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                    : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: colorScheme.error.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: TextStyle(color: colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No developers found',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchAllUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            final actualRank = _allUsers.indexOf(user);
                            return _buildUserCard(context, user, actualRank);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    Map<String, dynamic> user,
    int rank,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTopThree = rank < 3;
    final rankColor = _getRankColor(rank);
    final isExpanded = _expandedIndex == rank;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTopThree
              ? rankColor.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
          width: isTopThree ? 2 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: rankColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: isTopThree
                ? () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : rank;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Rank Number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isTopThree
                          ? rankColor.withValues(alpha: 0.2)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '#${rank + 1}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isTopThree ? rankColor : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Avatar with animated ring for top 3
                  _buildUserAvatar(
                    context,
                    user: user,
                    rank: rank + 1,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 12),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['displayName'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${user['projectCount']} projects',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge for top 3
                  if (isTopThree)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            rankColor.withValues(alpha: 0.8),
                            rankColor.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Top ${rank + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Expand icon for top 3
                  if (isTopThree) ...[
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '▼',
                          style: TextStyle(fontSize: 12, color: rankColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Expanded Content for Top 3
          if (isTopThree && isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Divider(
                      color: rankColor.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Rank',
                          '#${rank + 1}',
                          rankColor,
                        ),
                        _buildStatItem(
                          context,
                          'Projects',
                          '${user['projectCount']}',
                          rankColor,
                        ),
                        _buildStatItem(context, 'Status', 'Active', rankColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(
    BuildContext context, {
    required Map<String, dynamic> user,
    required int rank,
    required ColorScheme colorScheme,
  }) {
    // Show animated ring for top 3
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
          colors = [colorScheme.primary];
          stops = [1.0];
      }

      return AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.6),
                  blurRadius: 12,
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
                      radius: 25,
                      imageUrl: user['photoURL'],
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        user['displayName'][0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
      radius: 28,
      imageUrl: user['photoURL'],
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        user['displayName'][0].toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
