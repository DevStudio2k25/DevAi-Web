import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/app_provider.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/cached_network_image.dart';

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw 'User not authenticated';
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw 'User document not found';
      }

      setState(() {
        _userData = userDoc.data();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
      });
    }
  }

  void _showSuccessDialog(int tokenAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset(
                  'assets/lottie/DevAi.json',
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Congratulations! 🎉',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You received',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Lottie.asset(
                      'assets/lottie/DevAi.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$tokenAmount',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'DevTokens!',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _redeemPromoCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw 'User not authenticated';
      }

      if (_userData == null) {
        throw 'User data not loaded';
      }

      final code = _codeController.text.trim().toUpperCase();

      // Get the promo code document
      final promoCodeQuery = await FirebaseFirestore.instance
          .collection('promo_codes')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (promoCodeQuery.docs.isEmpty) {
        throw 'Invalid promo code';
      }

      final promoCodeDoc = promoCodeQuery.docs.first;
      final promoCodeData = promoCodeDoc.data();

      // Basic validations
      if (promoCodeData['isActive'] != true) {
        throw 'This promo code is no longer active';
      }

      final expiresAt = (promoCodeData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw 'This promo code has expired';
      }

      // Get the list of users who have already used this code
      final usedByUsers = List<String>.from(promoCodeData['usedByUsers'] ?? []);

      // Check if current user has already used this code
      if (usedByUsers.contains(userId)) {
        HapticFeedback.vibrate(); // Add vibration feedback
        setState(() {
          _errorMessage = 'You have already redeemed this code!';
          _isLoading = false;
        });
        return;
      }

      // If user hasn't used the code, proceed with redemption
      try {
        // First update the user's tokens
        final tokenAmount = promoCodeData['tokenAmount'] ?? 0;
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'tokens': FieldValue.increment(tokenAmount)},
        );

        // If token update successful, then add user to usedByUsers array
        await promoCodeDoc.reference.update({
          'usedByUsers': FieldValue.arrayUnion([userId]),
        });

        // Update local token count
        if (!mounted) return;
        final appProvider = context.read<AppProvider>();
        appProvider.addTokens(tokenAmount);

        // Vibrate for success
        HapticFeedback.mediumImpact();

        // Show success dialog
        if (!mounted) return;
        _showSuccessDialog(tokenAmount);

        // Clear the form
        _codeController.clear();

        // Reload user data
        _loadUserData();
      } catch (e) {
        // Vibrate for error
        HapticFeedback.vibrate();

        setState(() {
          _errorMessage = 'Failed to redeem code: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Vibrate for error
      HapticFeedback.vibrate();

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

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
          child: LoadingOverlay(
            isLoading: _isLoading,
            child: CustomScrollView(
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Redeem Promo Code',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // User Profile Card
                        if (_userData != null) ...[
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primaryContainer,
                                  colorScheme.secondaryContainer,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  // Profile Image with glow
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: CachedCircleAvatar(
                                      radius: 35,
                                      backgroundColor: colorScheme.surface,
                                      imageUrl: user?.photoURL,
                                      child: Icon(
                                        Icons.person,
                                        size: 35,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Name and Tokens
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?.displayName ?? 'Anonymous User',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (_userData?['tokens'] != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.surface
                                                  .withValues(alpha: 0.9),
                                              borderRadius:
                                                  BorderRadius.circular(16),
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
                                                  '${_userData?['tokens'] ?? 0}',
                                                  style: TextStyle(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Tokens',
                                                  style: TextStyle(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 14,
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
                          const SizedBox(height: 24),
                        ],

                        // Greeting Message
                        if (user?.displayName != null) ...[
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                              children: [
                                TextSpan(
                                  text: 'Hey ',
                                  style: TextStyle(color: colorScheme.primary),
                                ),
                                TextSpan(
                                  text: user!.displayName!.split(' ')[0],
                                ),
                                const TextSpan(text: ' 👋'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ready to redeem your DevTokens?',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Promo Code Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Info Card with Animation
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              colorScheme.primaryContainer
                                                  .withValues(alpha: 0.5),
                                              colorScheme.secondaryContainer
                                                  .withValues(alpha: 0.5),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Lottie.asset(
                                            'assets/lottie/DevAi.json',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Enter your promo code',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Get free tokens instantly!',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Error Message
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colorScheme.error.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        color: colorScheme.error,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: colorScheme.error,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Promo Code Input
                              TextFormField(
                                controller: _codeController,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Promo Code',
                                  labelStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  hintText: 'ENTER-CODE-HERE',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4),
                                    letterSpacing: 2,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Lottie.asset(
                                        'assets/lottie/DevAi.json',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline.withValues(
                                        alpha: 0.5,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: colorScheme.error,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: colorScheme.error,
                                      width: 2.5,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a promo code';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Submit Button
                              FilledButton(
                                onPressed: _isLoading ? null : _redeemPromoCode,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Lottie.asset(
                                        'assets/lottie/DevAi.json',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Redeem Code',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
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
