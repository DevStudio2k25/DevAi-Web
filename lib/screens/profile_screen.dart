import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../widgets/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _currentApiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final authService = context.read<AuthService>();
    final apiKey = await authService.getUserApiKey();
    if (mounted) {
      setState(() {
        _currentApiKey = apiKey;
      });
    }
  }

  Stream<DocumentSnapshot> _userDataStream(String? userId) {
    if (userId == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _userDataStream(user?.uid),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final tokens = userData?['tokens'] ?? 0;
              final projectCount = userData?['projectCount'] ?? 0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Header Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.secondaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar with glow effect
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CachedCircleAvatar(
                                radius: 55,
                                imageUrl: user?.photoURL,
                                backgroundColor: colorScheme.surface,
                                child: Text(
                                  (user?.displayName ?? 'U')[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              user?.displayName ?? 'Anonymous',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                color: colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Stats Row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStat(
                                    context,
                                    'Tokens',
                                    tokens.toString(),
                                  ),
                                  Container(
                                    width: 1.5,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          colorScheme.outline.withValues(
                                            alpha: 0.1,
                                          ),
                                          colorScheme.outline.withValues(
                                            alpha: 0.3,
                                          ),
                                          colorScheme.outline.withValues(
                                            alpha: 0.1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildStat(
                                    context,
                                    'Projects',
                                    projectCount.toString(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Logout Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showSignOutDialog(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(
                                    color: colorScheme.error.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.logout_rounded,
                                  color: colorScheme.error,
                                ),
                                label: Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // API Key Card
                      _buildApiKeyCard(context, appProvider),
                      const SizedBox(height: 16),
                      // Promo Code Card
                      _buildPromoCodeCard(context),
                      const SizedBox(height: 16),
                      // Theme Style Selector Card
                      _buildThemeStyleCard(context),
                      const SizedBox(height: 16),
                      // Theme Toggle Card with smooth liquid animation
                      _buildSmoothThemeCard(context, appProvider),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // API Key Card with current key display
  Widget _buildApiKeyCard(BuildContext context, AppProvider appProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasApiKey = _currentApiKey != null && _currentApiKey!.isNotEmpty;
    final displayKey = hasApiKey
        ? '${_currentApiKey!.substring(0, 8)}...${_currentApiKey!.substring(_currentApiKey!.length - 4)}'
        : 'Not Set';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primaryContainer, colorScheme.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.vpn_key_rounded,
                  size: 32,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Key',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gemini API Configuration',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasApiKey ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: hasApiKey ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayKey,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/api-key'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(hasApiKey ? Icons.edit : Icons.add),
              label: Text(hasApiKey ? 'Change Key' : 'Add Key'),
            ),
          ),
        ],
      ),
    );
  }

  // Promo Code Card - Voucher style
  Widget _buildPromoCodeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.secondaryContainer,
            colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Lottie.asset(
                          'assets/lottie/DevAi.json',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Promo Code',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get Free DevTokens',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSecondaryContainer
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Dashed border container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        color: colorScheme.secondary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Click Below Butotn to Redeem Rewards !',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/promo-code'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.redeem),
                    label: const Text('Redeem Code'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Theme Style Selector Card
  Widget _buildThemeStyleCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiaryContainer,
            colorScheme.tertiaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/theme-selector');
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                    color: colorScheme.onTertiaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Style',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose between Classic and Windows 11 themes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onTertiaryContainer.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.onTertiaryContainer,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Smooth Liquid Theme Switcher
  Widget _buildSmoothThemeCard(BuildContext context, AppProvider appProvider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 28,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Theme',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Smooth Liquid Theme Switcher
          _LiquidThemeSwitcher(
            currentMode: appProvider.themeMode,
            onChanged: (mode) => appProvider.setThemeMode(mode),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              // Close dialog first
              Navigator.pop(context);

              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // Navigate to auth screen and clear all previous routes
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/auth', (route) => false);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// Liquid Theme Switcher Widget with smooth animations
class _LiquidThemeSwitcher extends StatefulWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _LiquidThemeSwitcher({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  State<_LiquidThemeSwitcher> createState() => _LiquidThemeSwitcherState();
}

class _LiquidThemeSwitcherState extends State<_LiquidThemeSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getModeIndex(widget.currentMode);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void didUpdateWidget(_LiquidThemeSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMode != widget.currentMode) {
      final newIndex = _getModeIndex(widget.currentMode);
      if (newIndex != _selectedIndex) {
        setState(() {
          _selectedIndex = newIndex;
        });
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getModeIndex(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 0;
      case ThemeMode.dark:
        return 1;
      case ThemeMode.system:
        return 2;
    }
  }

  ThemeMode _getMode(int index) {
    switch (index) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerPadding = 4.0;
        final spacing = 4.0;
        final availableWidth = constraints.maxWidth - (containerPadding * 2);
        final totalSpacing = spacing * 2; // 2 gaps between 3 items
        final itemWidth = (availableWidth - totalSpacing) / 3;

        return Container(
          height: 60,
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Animated liquid background with wave effect
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Main sliding background
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubicEmphasized,
                        left: _selectedIndex * (itemWidth + spacing),
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubicEmphasized,
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primaryContainer,
                                    colorScheme.secondaryContainer,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.3 * value,
                                    ),
                                    blurRadius: 12 * value,
                                    offset: Offset(0, 4 * value),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Liquid wave effect overlay
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubicEmphasized,
                        left: _selectedIndex * (itemWidth + spacing),
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubicEmphasized,
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return CustomPaint(
                                painter: _LiquidWavePainter(
                                  progress: value,
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Theme options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOption(
                    context,
                    icon: Icons.light_mode_rounded,
                    label: 'Light',
                    index: 0,
                    width: itemWidth,
                  ),
                  SizedBox(width: spacing),
                  _buildOption(
                    context,
                    icon: Icons.dark_mode_rounded,
                    label: 'Dark',
                    index: 1,
                    width: itemWidth,
                  ),
                  SizedBox(width: spacing),
                  _buildOption(
                    context,
                    icon: Icons.brightness_auto_rounded,
                    label: 'Auto',
                    index: 2,
                    width: itemWidth,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required double width,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          setState(() {
            _selectedIndex = index;
          });
          _controller.forward(from: 0);
          widget.onChanged(_getMode(index));
        }
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                scale: isSelected ? 1.1 : 1.0,
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

// Liquid Wave Painter for smooth flowing effect
class _LiquidWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _LiquidWavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from top-left corner
    path.moveTo(0, 0);

    // Create wave effect from left to right
    final waveWidth = size.width * progress;
    final waveHeight = size.height;

    // Top wave
    path.lineTo(waveWidth * 0.7, 0);
    path.quadraticBezierTo(
      waveWidth * 0.85,
      waveHeight * 0.2,
      waveWidth,
      waveHeight * 0.5,
    );

    // Right side
    path.lineTo(waveWidth, waveHeight);

    // Bottom
    path.lineTo(0, waveHeight);

    // Close path
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LiquidWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
